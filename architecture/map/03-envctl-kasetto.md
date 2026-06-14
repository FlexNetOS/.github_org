# 03 — envctl (Secrets Engine / OS Foundation) + kasetto (Agent Provisioner)

This document renders the ICM `system-architecture` memoir cluster covering **envctl** — the
deepest OS/ENV/SECRETS foundation layer of the FlexNetOS meta-workspace — and **kasetto**, the
declarative agent-environment provisioner one layer up. envctl manages a whole workstation
declaratively (44 TOML components, a pure-Rust secrets vault, certs/CA, USB-gated lock, hash-chained
audit) and, critically, *holds the secrets and auto-injects API keys when a tool needs them* via
`crates/secrets-engine/src/inject.rs` + the `secretctl`/`secretd` surface. kasetto provisions each
agent's own toolkit (skills + MCP baseline). Their seam is **one-way** (envctl → kasetto, already
live) and a 2026-06-12 decision **unifies kasetto into envctl** as a pure-Rust `crates/agent-env`
crate. Every concept below is rendered faithfully; most carry **confidence 0.5** (snapshot facts, not
abstractions) — flagged where it matters. Path on disk: `~/Desktop/meta/envctl`.

> **Confidence note:** Of the 10 concepts in this cluster, 8 are at **confidence 0.5** and 2
> (`envctl-git-workflow-develop-master-2026-06-12`, `envctl-harness-upgrade-2026-06-12`) at **0.6**.
> These are verified point-in-time snapshots, not low-trust guesses, but treat exact percentages /
> phase-completion numbers as time-sensitive. Several inject-seam stubs documented as `todo!()` in
> the memoir were **partially landed** by 2026-06-13 PR work (see §3.4) — the memoir lags the code.

---

## 1. envctl as the OS Foundation layer

**Concept:** `envctl-os-foundation` — labels `type:layer`, `role:env-secrets`, `status:verified`
(confidence 0.5).

OS/ENV/SECRETS FOUNDATION — **the deepest layer**. A pure-Rust **8-crate workspace** at
`~/Desktop/meta/envctl`.

Binaries:

- `envctl` — CLI
- `envctl-gui` — egui GUI
- `secretd` — async tokio gRPC daemon

Workspace members (verified 2026-06-11, the 8 crates):

```text
cli, engine, gui, secretctl, secretd, secrets-engine, secrets-proto, secrets-store-libsql
```

What it does: manages a whole workstation **declaratively** —

- **44 TOML components** (each carrying lifecycle / deps / verify); a 2026-06-11 code snapshot
  counted **13 manifest TOMLs** with ~70 `[[...]]` blocks, including `agent-env.toml`,
  `dashboard.toml`, `ai-clis.toml`, `gpu.toml`, `nix-yazelix.toml`.
- a **pure-Rust secrets vault**, **certs/CA**, **USB-gated lock**, **hash-chained tamper-evident
  audit**.

**API surface:** gRPC over a Unix socket at `$SECRETCTL_SOCK`
(`= XDG_RUNTIME_DIR/env-ctl/control.sock`), exposing **6 services** (Vault / Relay / Certs / Lock /
Audit) with an **`apply=false` dry-run default + confirm gates**; the server **server-streams** an
`Event` oneof.

> THIS layer is what injects the **yazelix auto-enter block** and `$SECRETCTL_SOCK` into `~/.bashrc`.
> Agents dial it via `tonic`. **Relay mints bearer tokens ≤24h, peer-bound.**

### 1.1 The Engine (single shared library)

From `seam-spec-envctl-meta-env-2026-06-11`: the **Engine** is a *single shared sync non-printing
library*, **Event-emitting**; the **CLI and GUI drive the identical API**. It brings the box to
declared state via verbs:

```text
auto-detect / install / auto-fix / reset / add-repo / graph / lock / doctor
```

with **fail-closed guards** and a **dry-run default + `--apply`**.

---

## 2. envctl as the meta-environment agent manager (seam spec)

**Concept:** `seam-spec-envctl-meta-env-2026-06-11` — labels `type:seam-spec`, `status:open`,
`role:env-secrets`, `tag:critical` (confidence 0.5).

**STATUS: open** — the role splits in two halves: the **env-manager half is READY**, the
**secrets-runtime half is NOT.**

**Task brief:** *"envctl must be wired as the meta-environment agent manager."*

**Finding (code-grounded, 2026-06-11):** envctl was at `master`, last commit `faf8936` (2026-06-09);
a `_workspace/STOP` kill-switch was present (forge-loop intentionally halted 2026-06-09); the working
tree showed deleted `_workspace` session artifacts (uncommitted cleanup).

**Role (verdict):** envctl **IS** the meta-environment manager. The Engine brings the box to declared
state. Via `agent-env.toml` it **ALREADY** manages the agent-environment layer by **delegating to
kasetto** (see §6). Its harness skills (`feature-forge`, `forge-loop`, `session-relay`,
`env-install-loop`, `auto-provision`) are the proven agent-manager runtime patterns. The **zellij
multi-pane dashboard remains a confirmed DEAD END** (user directive: do not revive).

### 2.1 The seam contract (consume envctl three ways)

Loops consume envctl through exactly three doors:

1. **Box preflight** — `envctl auto-detect --json` (an `EnvReport`) / `doctor` as a **session-start
   gate**.
2. **Agent-env** — delegated to the **kasetto** component (already wired; see §6).
3. **Secrets** — `secretctl` → `secretd` gRPC over `$SECRETCTL_SOCK` (UDS; services
   Vault / Relay / Certs / Lock / Audit; `apply=false` dry-run default + confirm gates; relay mints
   peer-bound bearers ≤24h) — the **designed `PARENT_REPO_PAT` replacement**, but **DO NOT BUILD
   AGAINST IT** until `ProviderMint` / `inject` / `run_child` land (secretd phases 6–8, ~30% at
   snapshot time).

**Consequences (verbatim verdict):** treat **env-manager + doctor as a buildable-now contract**;
treat **secrets-runtime as roadmap**; loops keep using **org-level PATs** in the interim.

**References:** `envctl/Cargo.toml` members; `crates/secrets-engine/src/{seam.rs,inject.rs,lib.rs:1547,ca.rs:10}`;
`manifest/agent-env.toml`; `envctl/CLAUDE.md`.

---

## 3. The secrets-engine (relay / broker / injector)

**Concept:** `envctl secrets-engine (relay/broker)` — labels `domain:security`, `type:reference`,
`project:handoff`, `crate:envctl-secrets-engine` (confidence 0.5).

Location: `~/Desktop/meta/envctl/crates/secrets-engine` (lib `envctl_secrets`). It is the **secret
relay/injection tool** to integrate into the handoff loop-v2 (ADR-0001 §9.5 / R10, **HFTASK-0013**).
It is the **deterministic enforcement layer BENEATH the AI gatekeeper** — a credential broker on a
*virtual-credit-card* model: it holds the real secrets and hands out short-lived, revocable,
peer-bound bearer tokens, swapping them for the real key **only at egress**.

> Used as a **LIBRARY** by `secretd` (tonic gRPC daemon) and `secretctl` (client over UDS).

### 3.1 VAULT (production-grade & tested)

- **XChaCha20-Poly1305** per-record AEAD (`vault/crypto.rs` `seal`/`open`).
- Canonical **AAD binding**: a fixed **39-byte** canonical table binding `table` / `row_id` /
  `version` / `dek_generation` (`vault/aad.rs`).
- **LUKS-style DEK keyslots** — `Argon2id` + USB; **DEK in RAM only**; `Argon2id`/`HKDF` dual-KEK
  keyslots wrap a random DEK (`keyslot.rs`).
- **Hash-chained, DEK-anchored audit** (tamper-evident). The DEK-keyed tail anchor advances only when
  the vault is unlocked, so a store-level attacker cannot forge the chain.

### 3.2 BROKER (`decide.rs` — pure, default-deny)

`BROKER::decide` is a **pure sync DEFAULT-DENY policy fn** →
`RelayDecision::{Allow, Deny{reason}}` over **~25 `DenyReason`s**: host / path / method allowlists,
peer binding, budgets, rate, clock-rollback, enabled/revoked/expiry (wall **and** `CLOCK_BOOTTIME`),
canonical-upstream, peer-uid-pid, SNI, presence-gate. Plus a **fail-closed presence**
`GateState(Unproven -> deny)` — a **drop-in MERGE-GATE** for the handoff loop.

- `gate.rs` = `PresenceGate` trait + `GateState{Present, AbsentSince, Unproven}`, fail-closed.
- `token.rs` = `blake3` keyed-MAC bearer + row-MAC, **constant-time** verify (shared
  constant-time MAC comparison for both wire-bearer and row-metadata verifiers; a flipped stored-MAC
  bit must no longer verify).
- `policy.rs` = `RelayPolicy`, `clamp_ttl` (the `≤24h` `MAX_BEARER_TTL_SECS` choke),
  `canonical_upstreams` (`Github => api.github.com, uploads.github.com`).

The **canonical upstream host allowlist per provider (HF-11)** means the swap **REFUSES any other
host** — even a tampered `host_allow` listing an attacker host is rejected, because the relay is
`UpstreamNotAllowed` by default (default-deny) unless the daemon supplies a matching policy.

### 3.3 RELAY (mint / swap)

- `relay_mint` issues a `≤24h` **peer-bound, revocable** `evrelay_`-prefixed **bearer** (**only the
  MAC is persisted**); USB-gated; returns `Bearer{raw zeroized, token_id}`.
- `relay_swap` (async) swaps the bearer for the **real key ONLY at egress** (to `Upstream::send`).
  **20+ tests prove the key NEVER reaches the worker / events / audit** (`tests/relay.rs`, 20+
  tamper/rollback/leak tests, all green).
- Net effect: **REPLACES `PARENT_REPO_PAT` for `api.github.com` today.**

### 3.4 Stubs and the inject seam (the memoir lagged the code)

The memoir snapshot (`seam-spec-…`, `context-envctl-secrets`) recorded these as **greenfield STUBS /
`todo!()`**:

- **GitHub `ProviderMint`** — native scoped sub-token: only `NoMint` (`seam.rs`
  `ProviderMint::mint_scoped` defaults `Err(MintError::Unsupported)`); native GitHub
  fine-grained-PAT / sub-token minting **unbuilt**. `Unsupported` is deliberate so the **proxy-swap
  path is the universal fallback**.
- **`inject.rs`** — `inject.rs:39+48` `todo!()` (`injection_template`, `discover_profile`); child-env
  injection (`Phase 6/8`).
- **`run_child`** — `lib.rs:1547+1555` `todo!()` (`Engine::run` / `run_child` region).
- **MITM CA** — `ca.rs:10` `todo!()` (`LocalCa`); `lib.rs:14` doc: *"relay/CA/run paths remain
  todo!() (Phase 4+)"*.
- **`RealUsbProbe::keyfile_for`** — `seam.rs:37` `todo!()`.
- `secretd` `Run`/inject **UNIMPLEMENTED** in Phase 6; data-plane swap is **Phase 8**.

> **Inject-seam UPDATE (durable memories, 2026-06-13) — the memoir lags here.** Phase-8 data-plane
> work landed in two PRs against the auto-injection seam:
>
> - **PR-1 (data-plane proxy):** the relay data-plane proxy is **a hyper server implementing the
>   engine's `Upstream` seam**; its upstream client seeds its `RootCertStore` from
>   `webpki_roots::TLS_SERVER_ROOTS`; it handles **base-URL repoint** and `HTTPS_PROXY`. Modes:
>   **BaseUrlRepoint + HttpsProxyMitm for all 4 providers; `NativeSubtoken` shell.** The proto adds
>   `message ResolvedInjection { ProviderKind provider; DataPlaneMode mode; map<string,string> env;
>   repeated string ca_env_keys; string proxy_url; string base_url; }`. CA env keys for the MITM mode
>   are `NODE_EXTRA_CA_CERTS`, `CURL_CA_BUNDLE`, `GIT_SSL_CAINFO` (each set to `ca_pem_path`);
>   `BaseUrlRepoint`/`NativeSubtoken` use `ca_env_keys = vec![]`. **MITM leaves are NEVER mintable
>   here** — they are minted in-RAM inside the relay-gated proxy resolver. Acceptance tests (PR-1)
>   run **SYNC** through the `engine()` construction pattern in `tests/relay.rs`; the real key must
>   **NEVER** appear in emitted events (`resolved_env_never_contains_the_real_key`).
>   **`injection_template` now takes a `mode: DataPlaneMode` parameter** (was a 4-arg `todo!()`).
> - **PR-2 (daemon wiring):** at PR-1 time `injection: None` — wiring `injection_template`/
>   `run_child` into the daemon is **PR-2**. **PR-2b (env-ctl run):** open question **OQ1 (peer
>   binding) chosen as UID-PRIMARY** — mint with `client_pid=0`, **NOT exec-replace** (because
>   `broker/decide.rs` check 11b only enforces `client_pid` when bound, and `proxy.rs:401` sends
>   `peer_pid:None` per request, re-checking only uid; a non-`None` pid bind would deny every swap
>   with `PeerMismatch`). The child runs as the same uid as `secretctl`, so uid-binding holds.
>   `secretd Relay.Mint` now fills `MintResp.injection` (fail-closed `None` if `proxy_addr` unbound)
>   via `conv::injection_to_proto` + `inject::injection_template`; `secretctl Cmd::Run`:
>   `mint -> ChildEnvPlan -> in-process Engine::run_child -> exit(code)`. Branch
>   `secrets-inject-pr2b`, **NOT committed** at snapshot time.

### 3.5 Maturity verdict

VAULT + BROKER + `relay_swap` are **fully implemented + heavily tested**. The
**`ProviderMint`/`NativeSubToken` seam** (`seam.rs` `MintRequest{repos,perms,ttl}`/`ScopedToken`) is
the *intended* `PARENT_REPO_PAT` replacement but is a **STUB**; `inject.rs`/`run_child` env-overlay to
`gh`/`git` was a **STUB** at memoir time, now partially landed (§3.4). Persistence note (code):
`secrets-store-libsql` stores the vault/keyslots; XDG config root is `…/.config/env-ctl`.

> **Operational warning (durable, importance high):** **Do NOT restart or rebuild the
> `env-ctl.service` `secretd` daemon on a hunch.** On 2026-06-13, restarting it "to pick up a newer
> binary" (a) exposed a notify/shutdown restart-loop in the stale on-disk binary and (b) led to a
> `cargo install` of a wrong build over `~/.cargo/bin/secretd`, **taking the vault down**. Recovery
> required FF-ing envctl `master` to the merged USB-factor PR and rebuilding with the right feature
> flag. (Relates to the GitHub-App bootstrap's seal step, which depends on the vault being unlocked.)

> **Seed-factor / unlock (decision, 2026-06-13, envctl#61 merged):** the **Seed transport** switched
> from shelling `ssh` to a **direct pure-Rust pinned-CA HTTPS client** (`ring`-only rustls) hitting
> `POST /api/v1/custody/sign` — this fixes `secretctl` unlock failing under the `env-ctl.service`
> systemd sandbox (`ProtectHome=read-only` broke `ssh` known_hosts). **Token-at-rest LOCKED:**
> `ENVCTL_SEED_TOKEN` env **or** a `0600` file at `$XDG_DATA_HOME/env-ctl/seed-token` (inside the
> unit `ReadWritePaths`); rotation = re-mint-on-demand via the USB-only pair window. `no-C` stays
> green. The relay gate routes through **Profile S** (cached, seed-factor). (Do **not** conflate the
> USB secret-key hardware wall with the cognitum seed — distinct walls.)

---

## 4. Drift and merge state (env-ctl → envctl)

**Concept:** `envctl-drift-and-merge-state` — labels `type:drift-audit`, `status:verified`,
`tag:critical` (confidence 0.5). Verified **2026-06-09**.

### 4.1 MERGE

`env-ctl` was **structurally MERGED into `envctl`**: the secrets crates
`secretd` / `secretctl` / `secrets-engine` / `secrets-proto` / `secrets-store-libsql` now live in
`envctl`'s `Cargo.toml`; the **old `env-ctl` repo was trashed.**

### 4.2 Naming cleanup INCOMPLETE — `env-ctl` name to be RETIRED

The name `env-ctl` still **lingers** and should be retired. Residue:

- `$SECRETCTL_SOCK` points at `…/env-ctl/control.sock` (`~/.bashrc:161`)
- `manifest/env-ctl.toml`
- systemd unit `env-ctl.service`
- XDG dirs `~/.local/{share,state}/env-ctl` (and config root `…/.config/env-ctl`)
- docs / backlog refs

**Proposed new name:** `secretd` or `secrets`.

### 4.3 DRIFT from meta canon

- **(a)** **NO `.kb`** — uses `docs/` (`ARCHITECTURE` / `PRD` / `ROADMAP`) instead of the FlexNetOS
  `context/` discipline.
- **(b)** **IS** in `.meta.yaml` (ok).
- **(c)** **correctly NOT a plugin** (standalone tool), so the absence of `loop_lib`/plugin-protocol
  is fine.
- **(d)** built its **OWN harness** (`forge-loop` / `session-relay` / `continuity-steward`) mimicking
  `weave-harness-loop`.
- **(e)** **HANDOFF is POOR**: narrative "paste this file" prose; mixes architecture + checkpoint;
  duplicated root vs `_workspace` `HANDOFF.md`; no machine-parseable resume schema; no weave
  heartbeat.

**Realign work:** retire the `env-ctl` name; add `.kb`; adopt the structured session-relay HANDOFF
schema.

---

## 5. envctl git workflow — develop / master

**Concept:** `envctl-git-workflow-develop-master-2026-06-12` — labels `type:decision`, `tag:critical`,
`session:2026-06-12`, `role:workflow` (**confidence 0.6**). Definition timestamp: 2026-06-13,
**WORKING**.

- **`develop`** = the **integration/working branch** + the **GitHub DEFAULT** branch.
- **`master`** = a **protected MIRROR**, auto-synced from `develop` via
  `.github/workflows/sync-master.yml` (ff-push on every `develop` push, **no-downgrade guarded**).

**`master` protection (CORRECTED — mirror-compatible):**

```text
allow_force_pushes:            false
allow_deletions:               false
required_linear_history:       FALSE
required_pull_request_reviews: NULL
enforce_admins:                false
```

> **Why those two are FALSE/NULL (gotcha, see errors-resolved):** `required_linear_history` and
> `required_pull_request_reviews` **BREAK the token ff-mirror** — `GH006`: merge-commits forbidden;
> the classic-protection `github-actions` bypass is **not honored for a raw push**.

A consolidated durable memory adds the same picture with one extra knob: branch protection on
`master` = **PR-required count=0**, `github-actions` bypass for auto-sync, no force-push/delete, linear
history, `enforce_admins=false` (the recovery valve). (Note the apparent linear-history phrasing
difference between the consolidated note and the corrected memoir definition — see **QUESTIONS**.)

**Workflow:** work in **FRESH worktrees off `develop`** → PR to `develop` → merge → **auto-promote to
`master`**.

**Verified:** PR **#38** (harness upgrade) merged to `develop`; `sync-master` ff'd `master` to
`d69f452` successfully. All WIP consolidated (all 5 real WIP branches merged to `develop`+`master`).
Remote = `develop` + `master` (+ active feature branches like `feat/envctl-portability-c`). Safety
bundle: `/tmp/envctl-pre-reconcile-2026-06-12.bundle`.

---

## 6. The kasetto agent provisioner

**Concept:** `kasetto-agent-provisioner` — labels `type:layer`, `role:agent-env`, `status:verified`
(confidence 0.5).

The **AGENT-ENV layer** — but a **declarative CONFIG/PACKAGE manager for agents, NOT a
runtime/container manager**. Rust **single crate**; binaries `kasetto` + `kst` (`kst` = alias binary,
same CLI).

- **Intake:** `kasetto.yaml` listing agents (**21 presets**: `claude_code`, `cursor`, `codex`,
  `opencode`, `gemini_cli`, …), plus skills / commands / MCPs from **remote git sources**
  (ref-pinnable).
- **Transform:** each asset → per-agent formats (`McpServers` / `VsCodeServers` / `OpenCode` /
  `CodexToml`; `Markdown` / `PromptMd` / `GeminiToml` …) and installs into each agent's dirs.
- **Lock:** `kasetto.lock` (**v2**, hash + source + revision keyed) = **authoritative for
  reproducible sync** (`--locked` / `--frozen` for CI).
- **Scope:** **Global** (`~/.config/kasetto`) or **Project** (`./.kasetto`).
- **NO runtime coupling** to envctl/weave; **the lock file is the contract.**

CLI surface (from the seam spec): `init / sync / add / remove / lock / list / doctor / clean / self /
completions`.

---

## 7. The kasetto ↔ agent-env seam (one-way, already live)

**Concept:** `seam-spec-kasetto-agent-env-2026-06-11` — labels `type:seam-spec`, `status:decided`,
`role:agent-env`, `tag:critical` (confidence 0.5).

**STATUS: decided** — role confirmed; **one-way integration ALREADY LIVE**; remaining = spelling +
source-repo flags.

**Spelling:** the task brief said "Kasseto"; the **correct name is `kasetto`** (zero icm/filesystem
hits for "kasseto").

**Finding (2026-06-11):** kasetto **v3.1.0** installed at `~/.local/bin/{kasetto,kst}`. The source
checkout `~/Desktop/workspaces/kasetto-main` is **NOT a git repo** (a GitHub "main" archive extract)
at **v3.0.0** — **STALE** vs the installed 3.1.0 binary; **kasetto is NOT in `.meta.yaml`** and **no
local canonical clone exists**.

**Operating model:** declarative `kasetto.yaml` (sources = git or local paths carrying
skills/commands/MCPs) → per-agent transforms (21 presets) → installs into `.claude/`, `.codex/`, etc.;
`kasetto.lock` v2 = the reproducibility contract; `sync --locked` / `--frozen` = the CI drift gate.
**ZERO source references to envctl/weave/ruvector/prompt_hub** — a config-time provisioner with **NO
runtime coupling, BY DESIGN; the lock file IS the interface.**

### 7.1 Integration ALREADY LIVE (one-way, envctl → kasetto)

`envctl/manifest/agent-env.toml` registers **kasetto as an envctl component**:

> *"kasetto is the agent-env twin of envctl … one layer up — it manages the agent's own toolkit
> (skills + MCP baseline) instead of the OS toolchain."*

The component lifecycle:

```text
detect  = binary present
install = kasetto sync
fix     = kasetto sync
verify  = kasetto --version && kasetto sync --locked
remove  = kasetto clean --project
```

The envctl repo **carries its own `kasetto.yaml` + `kasetto.lock`** sourcing `./agent-skills`
(`source_revision: local`), and envctl's `CLAUDE.md` **mandates**: `.claude`/`.codex` are
**kasetto-provisioned, never hand-edited**; **CI enforces `kasetto sync --locked`.**

### 7.2 Seam contract going forward

kasetto = the **agent-environment provider at provisioning time** for every loop workspace. The `hf`
session start (**HFTASK-0007** worktree creation) should run **`kasetto sync --locked` as a preflight
gate** so the agent toolkit is locked before work begins (same pattern as envctl's `env-install-loop`
gate). Repos opt in by carrying `kasetto.yaml` sourcing their `agent-skills/` dir. **No runtime API is
needed or should be invented.**

**Consequences:** this seam is effectively **CLOSED for v1** (provisioning path proven in envctl).
Remaining work = replicate the pattern per-repo + the two flags. **OPEN:** (1) locate/clone kasetto's
canonical source repo and register it (or formally accept vendor-binary status); (2) propagate the
`kasetto` spelling into future briefs.

**References:** `workspaces/kasetto-main/{Cargo.toml,src/cli.rs,src/lock.rs}`,
`envctl/manifest/agent-env.toml`, `envctl/{kasetto.yaml,kasetto.lock}`, envctl `CLAUDE.md` agent-env
section.

---

## 8. kasetto → envctl unification (the merge decision)

**Concept:** `kasetto-envctl-unification-2026-06-12` — labels `type:decision`, `tag:critical`,
`session:2026-06-12`, `role:agent-env` (confidence 0.5).

**DECISION (ADR-0001, `envctl/.handoff/decisions`):** **UNIFY kasetto** (the agent-env provisioner —
**`FlexNetOS/env_manager_agent`**, installed **3.1.0**, tags to **3.2.0**) **INTO envctl** as a
**pure-Rust crate `crates/agent-env`**, driven via the **Engine API** (engine module + Events;
CLI `envctl agent {sync,add,remove,lock,list,clean}` + GUI parity).

> This supersedes the "kasetto is a vendor binary, NOT in `.meta.yaml`" state from §7 — note the
> source repo name surfaces here as `FlexNetOS/env_manager_agent` (see **QUESTIONS** re: the
> canonical-clone gap).

**NO DOWNGRADE / no feature lost** — preserve all:

- **all 11 verbs** including v3.1 `add` / `remove` / `lock` (`--check`, `--upgrade-package`);
- **6-key + `extends`** yaml schema;
- **21-agent preset**;
- **multi-host source resolver** (GitHub / GHE / GitLab / Bitbucket / Codeberg / Gitea / Forgejo +
  browser-url rewrite + **tar-slip guard** + **env-only creds**);
- **5 command-format + 4 MCP-merge ADDITIVE never-clobber transforms** (must keep the global
  **broker / repowire / weave** servers);
- **3 lock modes**.

**Already ported:** envctl has already ported kasetto **§2 lock** (`crates/engine/src/lock.rs`,
**FNV-1a**) + **§16 runtime** + **doctor** + **`lock --check`**.

**Lock unification:** adopt **SHA-256** (kasetto's).

**INVARIANT:** kasetto **passes envctl's `no-c` gate as-is**; the **ONLY cleanup = drop
`mimalloc`/`libmimalloc-sys`** (the C allocator).

**Stale doc flag:** `docs/KASETTO-FEATURES.md` is stale (v3.0.0). **Backlog Epic C = TASK-0011..0018.**

---

## 9. envctl handoff full-sync plan

**Concept:** `envctl-handoff-fullsync-plan-2026-06-12` — labels `type:plan`, `tag:critical`,
`session:2026-06-12`, `role:continuity` (confidence 0.5). ADR-0001 **Epic A**.

At snapshot, `envctl/.handoff` was **~30%** (a Tier-B stub: `capsule` + `README` + `loop/`).

**Per ADR-0004:** a per-repo `.handoff` holds **git-committed TEXT ONLY**; events flow to the shared
`meta/.handoff/ledger.db`; **packets are RENDERED by `hf`, never hand-written.**

**KEYSTONE BLOCKER:** the `hf` binary was not built / on PATH. **NOTE:** `hf` was already BUILT in a
spike (`[[buildout-hf-cli-proper-handoff]]`) and the **kernel now lives at `meta/handoff`** (a
registered `.meta.yaml` project, **`FlexNetOS/handoff`**); per `[[s1-ruvector-meta-mapping]]` the
ledger engine **maps onto existing RuVector crates (RVF WitnessChain)** — build **thin `hf` glue**,
don't rebuild 12 crates cold.

**PLAN:**

- **TASK-0001** — build + install `hf` from `meta/handoff` (relocate per the env-ownership
  procedure).
- **TASK-0002** — `hf`-seed envctl `.handoff` **Tier-A** (render `policy.toml` / `hooks` / `policies`
  / `active.md` / `packets/latest.md` / `skills`; **no per-repo `ledger.db`**).
- **TASK-0003** — `p7-conformance` CI gate.

**Task schema** = `handoff.task.v1` (id `^TASK-[0-9]{4,}$`).

> **`no-C` cross-check (decision, 2026-06-13):** the `hf` continuity kernel (`meta/handoff`) links
> **bundled C SQLite** via its ledger crate (`rusqlite`/`libsqlite3-sys`, static). This is **NOT an
> envctl `no-c.sh` violation** (separate workspace, not an envctl crate), so it **does not block
> TASK-0001** — but it conflicts with the agenticOS Epic A north star *"pure-Rust, no C in the trust
> boundary."* A C-free kernel would require a kernel-side port of `meta/handoff`'s ledger crate off
> `rusqlite` — out of the envctl `no-c` gate's scope. Flagged in `loop_state` needs_human/supervise.

---

## 10. envctl harness upgrade (the Feature Forge crew)

**Concept:** `envctl-harness-upgrade-2026-06-12` — labels `type:decision`, `tag:critical`,
`session:2026-06-12`, `role:harness` (**confidence 0.6**).

The **envctl harness** is **git-tracked, OUTSIDE kasetto** — the **Feature Forge crew**.

**Agents (`.claude/agents/`):**

- `feature-architect` (Plan)
- `rust-implementer` (g-p)
- `invariant-guardian` (g-p)
- `continuity-steward` (g-p)
- **NEW** `handoff-kernel-engineer` (g-p, 2026-06-13) for **Epic A** (cross-repo `hf`-kernel
  build/seed; owns the **ledger-residency / packets-rendered / p7** invariants; wired into
  feature-forge **Epic-A Build** routing).

**Skills (`.claude/skills/`):** `feature-forge` (orchestrator), `rust-feature-impl`
(+`references/{verification,kasetto-absorption}.md`), `forge-loop`, `session-relay`,
`env-install-loop`, `auto-provision`, **`handoff-sync` (NEW, Epic A)**.

**UPGRADE 2026-06-12/13:**

- migrated durable state `_workspace/` → `.handoff/loop/` (`backlog` / `loop_state` / `cycle` /
  `HANDOFF` / sentinels; legacy read-only fallback for in-flight successors);
- **`hf`-aware continuity** (`hf checkpoint`/`handoff`/`resume`/`done` when on PATH, else hand-written
  `HANDOFF`; **precedence Git > ledger > cards > active > packet**);
- `kasetto-absorption` **no-downgrade playbook**;
- `no-c.sh` **Gate 3.5 catches `mimalloc`**;
- meta-CLI fixes (`meta project list --json`; `meta git worktree status <slug>`);
- `loop_state.md` seeded to the **counter schema** (the budget guard was inert).

**Shipped via PR#38 + #39** to `develop` → `master`. See `[[harness-upgrade-hardening-ultraplan-2026-06-12]]`.

---

## Cross-references

- [01-meta-control-plane](01-meta-control-plane.md) — the `meta` CLI / `.meta.yaml` registry; envctl
  **is in `.meta.yaml`**, kasetto was **NOT** at snapshot (its source repo `FlexNetOS/env_manager_agent`
  is named in the unification decision §8). `meta git worktree`/`meta project list --json` are the
  CLI fixes carried by the harness upgrade (§10).
- [02-handoff-continuity](02-handoff-continuity.md) — ADR-0001 §9.5 / R10 / HFTASK-0013 wants the
  secrets-engine broker as the **MERGE-GATE** (§3.2); envctl's `.handoff` full-sync plan (§9) and the
  `hf`-aware continuity (§10) consume the `meta/handoff` kernel. ADR-0004 governs ledger residency.
- [04-weave-coordination](04-weave-coordination.md) — envctl's drift note flags its own harness as
  *mimicking* `weave-harness-loop` (§4.3d); the kasetto MCP-merge must **keep the global `weave`
  server** (§8); the envctl HANDOFF lacked a weave heartbeat (§4.3e).
- [05-ruvector-substrate](05-ruvector-substrate.md) — the `hf` ledger engine **maps onto RuVector
  crates (RVF WitnessChain)** rather than rebuilding 12 crates cold (§9).
- [07-frontdoor-integration](07-frontdoor-integration.md) — the `secretctl`→`secretd` secrets path is
  the **`PARENT_REPO_PAT` replacement** for tool egress (§2.1, §3.3); the GitHub-App bootstrap's seal
  step depends on the vault being unlocked (§3.5).
- [08-gaps-seams-merge](08-gaps-seams-merge.md) — the **open** secrets-runtime half (`ProviderMint` /
  `inject` / `run_child` stubs, §3.4), the `env-ctl` naming-retirement debt (§4.2), the kasetto
  canonical-clone gap (§7.2), and the kasetto→envctl unification backlog (Epic C, §8) all belong to
  the gaps/seams ledger.

---

## QUESTIONS (flag for the synthesizer)

1. **inject-seam: memoir vs code drift.** The memoir (`seam-spec-…`, `context-envctl-secrets`,
   conf 0.5) records `inject.rs` `injection_template`/`run_child`/`ProviderMint` as **`todo!()`
   stubs**, but durable memories from **2026-06-13** show PR-1 added the `mode: DataPlaneMode`
   parameter to `injection_template` and PR-2b wired `MintResp.injection` + `Engine::run_child`
   (branch `secrets-inject-pr2b`, **NOT committed**). **What is the *current committed* state of the
   inject seam — is PR-1 merged, and is PR-2/PR-2b landed or still on an uncommitted branch?**
2. **kasetto location contradiction.** §7 (seam-spec, 2026-06-11) says kasetto is **NOT in
   `.meta.yaml`**, has **no canonical clone**, source repo unknown — while §8 (unification decision,
   2026-06-12) names the source repo **`FlexNetOS/env_manager_agent`** at 3.1.0→3.2.0. **Was the
   canonical repo located between 06-11 and 06-12, and is `crates/agent-env` (the unification target)
   built yet, or still backlog (Epic C TASK-0011..0018)?**
3. **`master` linear-history phrasing conflict.** The **corrected** git-workflow definition (§5) sets
   `required_linear_history: FALSE` (because linear history breaks the ff-mirror, `GH006`), but a
   **consolidated** durable memory describing the same `master` protection lists *"linear history"*
   as enabled. **Which is the live protection state on `master` — is linear history ON or OFF?**
4. **secretd phase-completion %.** The seam spec says "secretd phases 6–8 ~30%"; the handoff plan
   says `.handoff` was ~30%. Both are point-in-time. **What phase is `secretd` actually at now, given
   the 06-13 inject/seed-factor work?** (Material to the "DO NOT BUILD AGAINST IT" caveat in §2.1.)
5. **`env-ctl` naming retirement — chosen name.** Memoir proposes `secretd` **or** `secrets` as the
   replacement for the `env-ctl` residue. **Has a final name been chosen, and is the socket-path /
   systemd-unit / XDG migration scheduled (it touches `~/.bashrc:161`, `env-ctl.service`, XDG dirs)?**

## LESSONS (confirmed facts / decisions / verdicts to carry forward)

- **envctl is the deepest layer (OS/ENV/SECRETS foundation):** a pure-Rust 8-crate workspace at
  `~/Desktop/meta/envctl`; binaries `envctl`/`envctl-gui`/`secretd`; gRPC over UDS at
  `$SECRETCTL_SOCK` with 6 services (Vault/Relay/Certs/Lock/Audit), dry-run default + confirm gates.
- **The secrets-engine VAULT + BROKER + relay_swap are production-grade and heavily tested**
  (XChaCha20-Poly1305 AEAD, 39-byte canonical AAD, Argon2id/HKDF dual-KEK keyslots, DEK-in-RAM,
  hash-chained audit; pure default-deny broker over ~25 DenyReasons; 20+ relay tests prove the real
  key never reaches worker/events/audit). It **REPLACES `PARENT_REPO_PAT` for `api.github.com`
  today.**
- **env-manager half is buildable-now; secrets-runtime half is roadmap.** Consume envctl three ways
  (preflight `auto-detect --json`, agent-env via kasetto, secrets via `secretctl`→`secretd`). **DO
  NOT build against the secrets path until `ProviderMint`/`inject`/`run_child` land.** Loops use
  org-level PATs in the interim.
- **env-ctl was structurally merged into envctl (2026-06-09)** and the old repo trashed; **the
  `env-ctl` name is now naming residue to retire** (socket path, `env-ctl.service`, `env-ctl.toml`,
  XDG dirs). Proposed name: `secretd`/`secrets`.
- **git workflow (WORKING):** `develop` = working + GitHub default; `master` = protected ff-mirror via
  `.github/workflows/sync-master.yml`. **`required_linear_history` and `required_pull_request_reviews`
  must stay FALSE/NULL** or the token ff-mirror breaks (`GH006`). Work in fresh worktrees off
  `develop`.
- **kasetto is a config-time provisioner, NOT a runtime/container manager** — the **lock file is the
  interface**, zero runtime coupling by design. The envctl→kasetto seam is **one-way and already
  live** (`agent-env.toml` registers kasetto; `.claude`/`.codex` are kasetto-provisioned, never
  hand-edited; CI enforces `kasetto sync --locked`).
- **DECISION (ADR-0001): unify kasetto INTO envctl** as pure-Rust `crates/agent-env` driven by the
  Engine, **NO downgrade** (all 11 verbs, 21 presets, multi-host resolver with tar-slip guard,
  additive never-clobber MCP merge keeping broker/repowire/weave). **Invariant: passes the `no-c`
  gate; only cleanup = drop `mimalloc`.** Adopt SHA-256 lock. Backlog Epic C = TASK-0011..0018.
- **Handoff:** per ADR-0004, per-repo `.handoff` is **git-committed TEXT ONLY**; the `hf` kernel lives
  at `meta/handoff` (`FlexNetOS/handoff`) and maps onto **RuVector RVF WitnessChain** — build thin
  glue, don't rebuild 12 crates. Schema `handoff.task.v1` (`^TASK-[0-9]{4,}$`).
- **The harness ("Feature Forge crew") is git-tracked OUTSIDE kasetto** — 5 agents (incl. NEW
  `handoff-kernel-engineer`) + 7 skills; durable state migrated `_workspace/` → `.handoff/loop/`;
  `hf`-aware continuity with precedence **Git > ledger > cards > active > packet**.
- **OPERATIONAL: never restart/rebuild `env-ctl.service` `secretd` on a hunch** — it took the vault
  down on 2026-06-13; recovery needed FF-ing `master` to the USB-factor PR and the correct feature
  flag. Seed-factor unlock now uses a pure-Rust pinned-CA HTTPS client to `POST /api/v1/custody/sign`
  (envctl#61).
