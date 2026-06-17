# Dossier: `meta/envctl` — FlexNetOS secret-management tool

**Date:** 2026-06-17  
**Source repo:** `/home/drdave/Desktop/meta/envctl` (`FlexNetOS/envctl`)  
**Cross-ref repo:** `/home/drdave/Desktop/meta/.github_org` (`FlexNetOS/.github`)  
**Scope:** How `envctl` stores/provisions secrets and what it means for wiring the `.github` reusable-workflow tokens.

---

## 1. What `envctl` is and its purpose

`envctl` is the FlexNetOS **user-global environment + secrets manager**. It is a pure-Rust Cargo workspace whose role is to bring the developer workstation to a declared state and to **hold secrets and auto-inject API keys** into child processes without letting the real key leak into shell env, history, logs, or git.

Two halves live in the same repo:

| Half | Crates | Purpose |
| --- | --- | --- |
| **Environment manager** | `envctl-engine`, `envctl` (CLI), `envctl-gui` | Component/manifest engine: `install`, `auto-detect`, `add-repo`, `auto-fix`, `reset`, `lock`, `doctor`. |
| **Secrets stack** | `envctl-secrets-engine`, `envctl-secretd`, `envctl-secretctl`, `envctl-secrets-proto`, `envctl-secrets-store-libsql` | AEAD-encrypted vault, credential broker, local CA, and auto-injection runtime. |

The secrets stack is the successor to the legacy `pass`+GPG store in `.github_org/secrets/` (ADR-0007). The design docs state that `envctl` is intended to become the single source of truth for FlexNetOS tokens, including the GitHub tokens consumed by the `.github` reusable workflows.

Key design properties:

- **Daemon TCB:** plaintext DEK and real upstream keys live only in `secretd` RAM, zeroized on drop, with `mlockall` + `RLIMIT_CORE=0`.
- **Dual keyslot:** USB keyfile (HKDF) OR passphrase (Argon2id) opens the vault; 1-of-2 by default, optional require-both.
- **Relay/broker model:** clients get short-lived (`<=24h`), peer-bound relay bearers; the broker swaps the bearer for the real key at egress to canonical upstream hosts.
- **Auto-injection:** `env-ctl run -- <cmd>` overlays provider-shaped env deltas onto the child only.

Sources: `envctl/README.md`, `envctl/docs/secrets/ARCHITECTURE.md`, `envctl/docs/secrets/CHARTER.md`, `.github_org/CLAUDE.md`, `.github_org/architecture/adr/ADR-0002-lean-github-org-relocate-to-hubs.md`.

---

## 2. Directory/file structure relevant to secrets, tokens, GitHub, and CI

### 2.1 `envctl` repo layout

```text
envctl/
├── Cargo.toml / Cargo.lock          # workspace
├── crates/
│   ├── cli/                         # envctl CLI (env/secrets verbs merge here)
│   ├── engine/                      # envctl-engine component model
│   ├── gui/                         # envctl-gui dashboard
│   ├── secretctl/                   # secretctl CLI (thin gRPC client)
│   ├── secretd/                     # secrets daemon
│   ├── secrets-engine/              # vault, broker, inject, CA logic
│   ├── secrets-proto/               # gRPC control-plane contract
│   └── secrets-store-libsql/        # durable libSQL backend
├── manifest/
│   ├── env-ctl.toml                 # systemd user unit for secretd
│   └── agent-env.toml               # kasetto agent-env bridge
├── docs/secrets/
│   ├── ARCHITECTURE.md
│   ├── THREAT-MODEL.md
│   ├── DESIGN-NOTES.md
│   ├── ROADMAP.md
│   ├── SERVER-MODE.md
│   ├── AUTO-INJECT-STATUS.md
│   └── ops/
│       ├── 02-envctl-component.md
│       ├── 03-usb-ceremony.md
│       ├── 04-backup-rotation.md
│       └── 06-run-inject-ux.md
├── docs/secrets/api/control-plane.proto
├── docs/secrets/db/schema.sql
└── home/                            # canonical home tree (symlinked by envctl)
```

### 2.2 Runtime file layout (Profile A)

```text
~/.config/env-ctl/                 # config, trusted roots, profiles
~/.local/share/env-ctl/   (0700)   # vault.db, CA public cert
~/.local/state/env-ctl/   (0700)   # audit mirror, logs
$XDG_RUNTIME_DIR/env-ctl/ (0700)   # control.sock / secretd.sock
USB <PARTUUID>:/env-ctl/keyfile    # 64-byte USB keyfile
```

### 2.3 `.github_org` secrets/CI surfaces that interact with `envctl`

```text
.github_org/
├── secrets/
│   ├── README.md                    # pass/GPG store + Bitwarden sync docs
│   ├── github-secrets.tsv.example   # mapping to GitHub Actions secrets
│   └── store/                       # GPG-encrypted blobs (legacy, moving to envctl)
├── scripts/
│   ├── secrets-doctor.py            # verify declared secrets exist on GitHub
│   ├── secrets-sync-github-from-bitwarden.sh
│   └── secrets-*.sh                 # inject/rotate/mirror helpers
└── .github/workflows/
    ├── reusable-secrets.yml         # inject pass secrets into GITHUB_ENV (self-hosted)
    ├── secrets-rotate.yml           # weekly stale-secret scan
    ├── reusable-notify-parent.yml
    ├── reusable-notify-downstream.yml
    ├── reusable-child-update-sync.yml
    ├── reusable-release.yml
    ├── reusable-rust-release.yml
    ├── release.yml
    ├── promote-develop-to-main.yml
    └── sync-labels.yml
```

Sources: `envctl/docs/secrets/ARCHITECTURE.md §11`, `envctl/manifest/env-ctl.toml`, `.github_org/secrets/README.md`.

---

## 3. How `envctl` stores/provisions secrets

`envctl` is **not** a wrapper around `pass`, Bitwarden, or `.env` files. It is a standalone vault. The broader org still uses `pass`+GPG and a Bitwarden/Vaultwarden sync script, but those are documented as legacy/transitional paths being superseded by `envctl`.

### 3.1 Storage model

- **At-rest:** `~/.local/share/env-ctl/vault.db` (libSQL/SQLite backend) contains only AEAD ciphertext.
- **Crypto per record:** XChaCha20-Poly1305 with a fresh 24-byte nonce; canonical AAD binds table tag, row id, version, and DEK generation.
- **Master key:** a random 32-byte DEK wrapped by one or two LUKS-style keyslots:
  - USB keyfile → HKDF-SHA256 → KEK
  - Passphrase → Argon2id (m=1 GiB, t=4, p=4, v0x13) → KEK
- **Audit:** hash-chained tamper-evident `audit_log` committed synchronously before security-relevant RPCs return.

### 3.2 Provisioning/local injection

| Mechanism | What it does | Where real key lives |
| --- | --- | --- |
| `env-ctl run -- <cmd>` | Mints `<=24h` bearer, overlays env onto child, `execvp`s it. | Never in child; swapped by broker. |
| `.env-ctl` profiles | Per-directory relay-name lists (no secrets). | Names only; vault holds keys. |
| `secretctl secret add/get/list/rm/rotate` | CRUD for stored secrets. | Ciphertext in vault.db. |
| `secretctl relay create/mint/revoke` | Named relay policies + bearer minting. | Real key in daemon TCB. |
| `secretctl vault init/unlock/lock` | Lifecycle of DEK + keyslots. | DEK in daemon RAM only. |
| Local CA (`ca init/issue/...`) | Vault-backed MITM CA for `HTTPS_PROXY` tools. | CA key sealed under DEK. |

### 3.3 GitHub-specific egress

- The engine knows a `Provider::Github` with canonical hosts `{api.github.com, uploads.github.com}`.
- `crates/secrets-engine/src/inject.rs` maps GitHub to `GH_TOKEN` + `GITHUB_TOKEN` env vars.
- Two egress modes are relevant:
  - **BaseUrlRepoint:** sets `GITHUB_API_URL=http://127.0.0.1:<relay>` + `GH_TOKEN`/`GITHUB_TOKEN` bearer.
  - **HttpsProxyMitm:** sets `HTTPS_PROXY` + CA env; broker decrypts TLS and injects `Authorization: Bearer <real key>`.
  - **NativeSubToken:** shell exists (`inject.rs` `DataPlaneMode::NativeSubtoken`) but actual GitHub App token minting is the `ProviderMint` seam.
- `crates/secrets-engine/src/mint_github.rs` implements GitHub App installation-token minting (RS256 JWT → `POST /app/installations/{id}/access_tokens`). This is intended to replace `PARENT_REPO_PAT`, but the `ProviderMint` seam defaults to `NoMint` (unsupported) in the current code.

### 3.4 Legacy org paths still in use

| Path | Source | Destination | Notes |
| --- | --- | --- | --- |
| `pass` store | `.github_org/secrets/store/` | local shell via `direnv`, CI via `reusable-secrets.yml` | Being retired → envctl per ADR-0007. |
| Bitwarden/Vaultwarden | `scripts/secrets-sync-github-from-bitwarden.sh` | GitHub Actions repo/env/org secrets | Preferred "next-gen" path until envctl can sync. |
| `gh secret set` | maintainer workstation | GitHub Actions secrets | Manual/ad-hoc today. |

Sources: `envctl/docs/secrets/ARCHITECTURE.md §5-9`, `envctl/crates/secrets-engine/src/inject.rs`, `envctl/crates/secrets-engine/src/mint_github.rs`, `.github_org/secrets/README.md`.

---

## 4. Tokens/secrets known for `FlexNetOS/.github` and `FlexNetOS/meta*` repos

The following secret names are documented in `.github_org` workflows, onboarding templates, and the `secrets/github-secrets.tsv.example` mapping.

### 4.1 Org-level secrets (intended for `FlexNetOS` org)

| Secret name | Used by | Scope/target | Documented need |
| --- | --- | --- | --- |
| `PARENT_REPO_PAT` | `reusable-notify-parent.yml`, `reusable-notify-downstream.yml`, `reusable-child-update-sync.yml`, `reusable-auto-format.yml` (commented), onboarding templates | Org, granted to child repos | Cross-repo `repository_dispatch`, PR creation, check-wait. Needs `repo` scope (or fine-grained `contents:write` + `pull_requests:write`). |
| `REPO_WRITE_PACKAGES_PAT` | `secrets/github-secrets.tsv.example` (mapped), `docs/github-automation-roadmap.md` | Org | "FlexNetOS release dispatch PAT" — release dispatch. |
| `RELEASE_TOKEN` | `.github/workflows/release.yml`, `reusable-release.yml`, `reusable-rust-release.yml`, onboarding `release.yml` | Org (or repo secret on `.github`) | `contents:write`, `pull-requests:write`, `issues:write` for release-please / semantic-release / asset upload. |
| `CARGO_REGISTRY_TOKEN` | `secrets/github-secrets.tsv.example` | Org | crates.io publishing token. |
| `HOMEBREW_TAP_TOKEN` | `secrets/github-secrets.tsv.example` | Org | Homebrew tap update PAT. |
| `LABEL_SYNC_TOKEN` | `docs/github-automation-roadmap.md` only | Org | Org-scoped label management (`sync-labels.yml`). **Not referenced by any workflow file.** |
| `PROMOTE_TOKEN` | `.github/workflows/promote-develop-to-main.yml`, `WORKFLOW.md`, `ADR-0003` | Repo/org | Auto-approves the perpetual `develop → main` PR. Needs `repo` scope. |

### 4.2 Repo-level / env-level secrets

| Secret name | Used by | Target | Notes |
| --- | --- | --- | --- |
| `CLAUDE_CODE_OAUTH_TOKEN` | `.github/workflows/claude.yml`, `.github/workflows/claude-code-review.yml` | `FlexNetOS/.github` | OIDC exchange for Claude Code review. |
| `N8N_MCP_TOKEN` | `.mcp.json`, `~/.claude.json` | local/user env | Bearer for local n8n-mcp server; stored via `pass`/env, not in repo. |
| `GITHUB_TOKEN` | Most workflows | default `github.token` | Built-in; used where cross-repo scope is not required. |

### 4.3 Name-mapping ambiguities

- `RELEASE_TOKEN` is what `release.yml` / `reusable-release.yml` consume.
- `REPO_WRITE_PACKAGES_PAT` is what `secrets/github-secrets.tsv.example` calls the "release dispatch PAT". It is unclear whether these are two separate credentials or the same credential referenced under two names.
- `LABEL_SYNC_TOKEN` is listed in the automation roadmap but `sync-labels.yml` actually uses `${{ secrets.GITHUB_TOKEN }}`. Either the workflow is under-scoped or the token name is aspirational.

Sources: `.github_org/.github/workflows/reusable-*.yml`, `.github_org/.github/workflows/release.yml`, `.github_org/.github/workflows/promote-develop-to-main.yml`, `.github_org/secrets/github-secrets.tsv.example`, `.github_org/docs/templates/repo-onboarding/README.md`, `.github_org/docs/github-automation-roadmap.md`, `.github_org/WORKFLOW.md`.

---

## 5. Commands/scripts to inject/list/sync GitHub Actions/org secrets

### 5.1 `envctl`/`secretctl` commands (local vault)

| Command | Purpose |
| --- | --- |
| `secretctl status` | Vault lock status. |
| `secretctl vault init --apply` | Create vault + DEK + passphrase keyslot. |
| `secretctl keyslot enroll --usb --partuuid <UUID> --apply` | Add USB keyslot. |
| `secretctl keyslot enroll --passphrase --apply` | Add passphrase keyslot. |
| `secretctl unlock` | Unlock vault (USB-first, passphrase fallback). |
| `secretctl secret list` | List stored secrets (metadata only). |
| `secretctl secret add <name> --provider github --value-stdin [--broker-only]` | Store a GitHub credential. |
| `secretctl secret get <name> --reveal --apply` | Reveal plaintext (audited; refused for broker-only). |
| `secretctl relay create <name> --secret <name> --provider github --mode <mode> --host api.github.com ...` | Create relay policy. |
| `secretctl relay mint <name>` | Mint a `<=24h` bearer. |
| `secretctl run --relay <name> -- <cmd>` | Run child with injected env. |

After merge, the verbs fold into `envctl secret|vault|relay|ca|run`.

### 5.2 GitHub CLI (`gh`) — the actual GitHub Actions secret interface

`envctl` does not currently push secrets to GitHub. The maintainer still uses `gh`:

```bash
# Org secret
gh secret set PARENT_REPO_PAT --org FlexNetOS --visibility private

# Repo secret
gh secret set RELEASE_TOKEN --repo FlexNetOS/.github

# Environment secret
gh secret set RELEASE_TOKEN --repo FlexNetOS/meta --env production

# List
gh secret list --org FlexNetOS
gh secret list --repo FlexNetOS/.github
```

### 5.3 Existing `.github_org` helper scripts

| Script | Purpose |
| --- | --- |
| `scripts/secrets-sync-github-from-bitwarden.sh` | Reads `secrets/github-secrets.tsv` and calls `gh secret set` for repo/env/org scopes. Supports `BW_SERVER`, `BW_SESSION`, dry-run. |
| `scripts/secrets-doctor.py` | Reads the TSV mapping and checks each declared secret via `gh secret list`. |
| `scripts/secrets-inject.sh` | Renders `envs/*.env.tmpl` with `pass` values (used by `reusable-secrets.yml`). |
| `scripts/secrets-rotate.sh` | Lists pass entries older than 90 days. |
| `.github/workflows/reusable-secrets.yml` | Injects pass-managed secrets into `$GITHUB_ENV` on the self-hosted runner. |
| `.github/workflows/secrets-rotate.yml` | Weekly stale-secret issue opener. |

Sources: `envctl/crates/secretctl/src/cli.rs`, `envctl/docs/secrets/ops/06-run-inject-ux.md`, `.github_org/secrets/README.md`, `.github_org/scripts/secrets-sync-github-from-bitwarden.sh`, `.github_org/scripts/secrets-doctor.py`.

---

## 6. Maintainer playbook: set secrets for the new reusable workflows using `envctl`

`envctl` is the **source of truth for the credential value**, but the **GitHub Actions secret still has to be written via `gh secret set`** (or the Bitwarden sync script). The recommended pattern keeps the real token inside the daemon TCB and never in the parent shell.

### 6.1 One-time: stand up the vault

```bash
cd /home/drdave/Desktop/meta/envctl
cargo build --release -p envctl-secretd -p envctl-secretctl
envctl install secretd          # installs systemd user unit

# Create vault with passphrase keyslot + USB keyslot
secretctl vault init --apply
secretctl keyslot enroll --usb --partuuid <PARTUUID> --apply
secretctl keyslot enroll --passphrase --apply
```

USB enrollment is required for on-box operation (`FS-S22`).

### 6.2 Store the master GitHub credential in `envctl`

For the cross-repo/release workflows you need a long-lived credential. Two supported shapes:

**A. Personal Access Token (works today)**

```bash
secretctl secret add github/flexnetos-cross-repo --provider github --value-stdin --broker-only
# paste the PAT
```

**B. GitHub App private key (intended future, once `ProviderMint` is wired)**

```bash
secretctl secret add github/flexnetos-app-key --provider github --value-stdin --broker-only
# paste the App private key PEM
```

### 6.3 Create a GitHub relay policy

```bash
secretctl relay create gh-flexnetos \
  --secret github/flexnetos-cross-repo \
  --provider github \
  --mode base_url_repoint \
  --host api.github.com \
  --path /repos/FlexNetOS \
  --path /repos/FlexNetOS/.github \
  --method GET --method POST
```

For tools that ignore `GITHUB_API_URL`, use `--mode https_proxy_mitm` (requires CA trust).

### 6.4 Push the required GitHub Actions secrets without exposing them to the shell

```bash
# PARENT_REPO_PAT -> org secret available to child repos
secretctl run --relay gh-flexnetos -- \
  gh secret set PARENT_REPO_PAT --org FlexNetOS --visibility private

# RELEASE_TOKEN -> .github repo secret
secretctl run --relay gh-flexnetos -- \
  gh secret set RELEASE_TOKEN --repo FlexNetOS/.github

# CARGO_REGISTRY_TOKEN / HOMEBREW_TAP_TOKEN at org level
secretctl run --relay gh-flexnetos -- \
  gh secret set CARGO_REGISTRY_TOKEN --org FlexNetOS --visibility private

secretctl run --relay gh-flexnetos -- \
  gh secret set HOMEBREW_TAP_TOKEN --org FlexNetOS --visibility private
```

Inside the child `gh` process, `GH_TOKEN`/`GITHUB_TOKEN` hold a short-lived broker bearer; the real PAT is swapped in only when the request leaves for `api.github.com`.

### 6.5 Verify

```bash
# local
secretctl secret list
secretctl relay list

# GitHub side
gh secret list --org FlexNetOS
gh secret list --repo FlexNetOS/.github
# or use the existing doctor
cd /home/drdave/Desktop/meta/.github_org
python3 scripts/secrets-doctor.py
```

### 6.6 Alternative: keep using the Bitwarden sync script

Until `envctl` has a native GitHub sync path, maintainers can keep the canonical values in Vaultwarden/Bitwarden and run:

```bash
export BW_SESSION="$(bw unlock --raw)"
cd /home/drdave/Desktop/meta/.github_org
make secrets.sync-github-bw DRY_RUN=1
make secrets.sync-github-bw
```

Sources: `envctl/docs/secrets/ops/02-envctl-component.md §5.3`, `envctl/docs/secrets/ops/03-usb-ceremony.md`, `envctl/docs/secrets/ops/06-run-inject-ux.md`, `.github_org/secrets/README.md`.

---

## 7. Gaps and ambiguities that block wiring the secrets

### 7.1 `envctl` implementation gaps

| Gap | Evidence | Impact |
| --- | --- | --- |
| **No native GitHub Actions secret sync** | No `secretctl github-secret-set` or equivalent command exists. | Maintainer must still use `gh secret set` or the Bitwarden script. |
| **`ProviderMint` default is `NoMint`** | `crates/secrets-engine/src/seam.rs` default impl returns `Err(MintError::Unsupported)`. | GitHub App installation-token minting (`mint_github.rs`) is implemented but not wired as the active mint path. |
| **`NativeSubToken` is a shell only** | `inject.rs` has the enum variant and env mapping, but no real sub-token minting is plumbed through `secretd`. | Cannot yet hand out scoped 1h `GH_TOKEN` automatically. |
| **No vault import command** | ADR-0007 handoff assumes `secretctl import`, but `secretctl secret add` is the only ingest path. | Migration from `pass`/`flexnetos_secrets` is manual and high-stakes. |
| **`.env-ctl` trusted-root UX unspecified** | `DESIGN-NOTES.md OI-3` and `ops/06-run-inject-ux.md §7` flag the format/location of `~/.config/env-ctl/trusted-roots` as not locked. | Blocks fail-closed profile discovery. |
| **`secretd` user unit vs. system unit** | `ops/06-run-inject-ux.md §5` notes the shipped unit type is unverified. | Deployment instructions may need correction. |

### 7.2 `.github_org` secret-name confusion

| Gap | Evidence | Impact |
| --- | --- | --- |
| **`RELEASE_TOKEN` vs. `REPO_WRITE_PACKAGES_PAT`** | `release.yml` expects `RELEASE_TOKEN`; `secrets/github-secrets.tsv.example` uses `REPO_WRITE_PACKAGES_PAT` for "release dispatch". | Risk of setting the wrong name or duplicate credentials. |
| **`LABEL_SYNC_TOKEN` unused** | Roadmap lists it for `sync-labels.yml`, but the workflow uses `secrets.GITHUB_TOKEN`. | Either an unimplemented hardening step or stale documentation. |
| **`PARENT_REPO_PAT` not granted to `FlexNetOS/meta` itself** | `architecture/map/01-meta-control-plane.md` and `QUESTIONS_LESSONS.md` note org secret resolves empty inside meta's own workflows. | Release Please fails; needs human grant via GitHub UI or `gh api`. |

### 7.3 Operational/transition gaps

| Gap | Evidence | Impact |
| --- | --- | --- |
| **Legacy `pass` store still authoritative** | `.github_org/secrets/store/` contains real GPG ciphertext; `reusable-secrets.yml` and `secrets-rotate.yml` still depend on it. | Two secret stores (`pass` and `envctl`) coexist = split-brain risk until migration is complete. |
| **No CI-native envctl injection** | `reusable-secrets.yml` only knows `pass`; it cannot read from `secretd`. | Self-hosted CI cannot yet consume envctl-managed secrets. |
| **Bitwarden sync is one-way** | `secrets-sync-github-from-bitwarden.sh` overwrites GitHub; editing in GitHub is lossy. | Rotation workflow must be source-driven. |

Sources: `envctl/crates/secrets-engine/src/seam.rs`, `envctl/crates/secrets-engine/src/inject.rs`, `envctl/docs/secrets/DESIGN-NOTES.md`, `envctl/docs/secrets/ops/06-run-inject-ux.md`, `.github_org/secrets/github-secrets.tsv.example`, `.github_org/.github/workflows/sync-labels.yml`, `.github_org/architecture/map/01-meta-control-plane.md`, `.github_org/architecture/QUESTIONS_LESSONS.md`.

---

## 8. Summary

`envctl` is the intended long-term secrets authority for FlexNetOS, but the GitHub Actions wiring is still a **hybrid manual process**:

1. `envctl` holds the real credential (PAT or App key) in its AEAD vault.
2. The maintainer uses `secretctl run --relay gh-... -- gh secret set ...` to push the value to GitHub without exposing it to the parent shell.
3. Until `envctl` has a native GitHub sync surface, the legacy `scripts/secrets-sync-github-from-bitwarden.sh` and `gh secret set` remain the practical tools.
4. Blockers before fully trusting this path:
   - Wire/enable the GitHub `ProviderMint` (`mint_github.rs`) so `NativeSubToken` works.
   - Resolve `RELEASE_TOKEN` vs. `REPO_WRITE_PACKAGES_PAT` naming.
   - Grant `PARENT_REPO_PAT` to `FlexNetOS/meta` itself.
   - Decide `LABEL_SYNC_TOKEN` fate.
   - Complete migration of the `pass` store into `envctl` and retire `reusable-secrets.yml`'s `pass` dependency.
