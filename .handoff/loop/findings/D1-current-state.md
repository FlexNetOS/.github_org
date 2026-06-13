# D1 — Current-state inventory & role realization

**Dimension:** For each of the 6 VISION roles, is it real/operational or scaffold/aspirational, and where exactly does it live on disk? Maturity verdict per role.

**Method:** Source inspection (file `file`/`wc`, line-level reads of representative artifacts, `git ls-tree -r HEAD` for gitlinks, grep for scaffold markers). Reasoning is from the bytes on disk, not the prose in VISION.md.

---

### CLAIM D1.1 — Role 1 (community-health fallback) is REAL/operational.

All seven canonical community-health files exist with substantive content, at the two locations GitHub's fallback mechanism reads (repo root + `.github/`), plus the org-landing `profile/README.md`.

Evidence:
- Root files (all present, non-trivial): `CODE_OF_CONDUCT.md` (28 ln), `CONTRIBUTING.md` (120 ln / 5.7K), `SECURITY.md` (89 ln / 3.7K), `SUPPORT.md` (41 ln), `FUNDING.yml` (21 ln), `MAINTAINERS.md` (36 ln), `LICENSE` (21 ln).
- `.github/` org-policy surface: `.github/CODEOWNERS` (655 B), `.github/PULL_REQUEST_TEMPLATE.md` (1.4K), `.github/dependabot.yml` (584 B), `.github/ISSUE_TEMPLATE/{bug_report.yml,feature_request.yml,documentation.yml,config.yml}` (all present, 0.6–2.4K each).
- `profile/README.md` (39 ln / 2.3K) — the org public landing page (Role-1 artifact).
- Mechanism described `VISION.md:12-23`.

Confidence: **high** (these are content files; presence + size is the operational test, and GitHub renders them by name).

---

### CLAIM D1.2 — Role 2 (~24-submodule mount) is DRIFTED machinery: 17 real gitlinks, only 7 mapped in `.gitmodules`, manifest claims ~28. Three-way inconsistent.

The submodule role exists as machinery but is internally inconsistent — the canonical "mount point" is only half-wired.

Evidence:
- **17 committed gitlinks** in HEAD (`git ls-tree -r HEAD | awk '$2=="commit"'`): `tools/{actionlint,bun,cpython,gitleaks,node,trivy,uv}` (7), `repos/{ai-top-utility,fabro,n8n,paperclip}` (4), `network/slim` (1), `data/brain-data/{DeepTutor,deepwiki-rs,obsidian-mind}` + `.../my-wiki-knowledge/.claude/{obsidian-second-brain,obsidian-skills}` (5).
- **`.gitmodules` maps only 7** — all `tools/*` (`grep 'path =' .gitmodules` → exactly the 7 tool paths). The other 10 gitlinks (`repos/*`, `network/slim`, `data/brain-data/*`) have **no** `.gitmodules` entry → `git submodule status` cannot see them.
- **`repos/MANIFEST.yaml` claims ~28-29 entries** (29 `name:`/`url:`-style entry lines via grep), but only 4 of them (`ai-top-utility, fabro, n8n, paperclip`) are actually committed gitlinks. Note: MANIFEST uses `url:` keys, not `repo:` (`grep 'repo:'` → 0).
- VISION.md:25-43 describes a manifest-driven `git submodule add` flow that the on-disk state does not match.

Confidence: **high** (gitlink list and `.gitmodules` are exact, reproducible counts).

---

### CLAIM D1.3 — Role 3 (Karpathy LLM-wiki) is SCAFFOLD: harness + docs present, ZERO actual wiki pages.

The wiki has its purpose/schema documentation and a lint harness, but the content tree is empty — every `pages/*` directory holds only a `.gitkeep`.

Evidence:
- `find wiki/pages -type f ! -name '.gitkeep'` → **0 files**. The four content buckets (`pages/concepts/`, `pages/entities/`, `pages/sources/`, `pages/synthesis/`) each contain only `.gitkeep`.
- `wiki/assets/.gitkeep`, `wiki/raw/README.md` — also empty placeholders.
- What IS real: `wiki/purpose.md` (97 ln), `wiki/schema.md` (242 ln), `wiki/index.md` (51 ln), `wiki/log.md` (18 ln), `wiki/AGENTS.md`, `wiki/README.md` — i.e. the *governance + schema*, not the *knowledge*.
- Lint harness: `.github/workflows/wiki-lint.yml` exists (referenced `VISION.md:57`).
- Total `wiki/` = 76K / 12 files, but all 12 are scaffolding/docs.

Verdict: **scaffold** — the frame is real, the memory layer is empty. Matches codemap's "scaffold".

Confidence: **high**.

---

### CLAIM D1.4 — Role 4 (`pass`+GPG secrets vault) is PARTIAL→REAL: it holds 4 genuine PGP-encrypted secrets, not placeholders.

This is the most under-stated role in the codemap (which called it flatly "scaffold"). The store contains real, decryptable-by-the-right-key encrypted blobs — operational vault content.

Evidence:
- `file secrets/store/openai/personal.gpg` → `PGP RSA encrypted session key - keyid: 5B50D66F E264FD21 RSA (Encrypt or Sign) 4096b` (675 B). Same for `secrets/store/github/personal/cli.gpg` (619 B, same keyid). These are real GPG-armored ciphertexts, not `.example`/templates.
- **4 real `.gpg` blobs** under `secrets/store/`: `openai/personal.gpg`, `github/personal/cli.gpg`, `n8n/api-key.gpg`, `n8n/mcp/token.gpg`.
- Real `pass`-store metadata: `secrets/store/.gpg-id`, `secrets/store/runner/.gpg-id`, top-level `secrets/.gpg-id` + `secrets/.gpg-id.runner` (the two-key model from `VISION.md:62`).
- Scaffold parts coexist: `secrets/envs/*.env.tmpl` (3 templates), `secrets/github-secrets.tsv.example`, `secrets/recovery/README.md`, `secrets/README.md`.
- Total 100K / 15 files.

Verdict: **partial, leaning real** — a working `pass` store with live secrets + recovery docs; the env-injection layer is templated. **DRIFT note:** codemap §2 marks this "scaffold", which understates it — there is real encrypted state here, which raises the data-loss stakes for any MOVE/extract (relevant to D4/D6).

Confidence: **high** on the encrypted-blob reality (`file` output is dispositive); **medium** on "fully operational" (cannot decrypt without the private key, so I can't prove the plaintext is current/non-stale).

---

### CLAIM D1.5 — Role 5 (self-hosted runner host config) is REAL config.

Four substantive, guarded bash scripts plus policy docs and systemd units — real install/register/spawn/remove lifecycle, defaulting to dry-run.

Evidence:
- `runner/install.sh` (104 ln) — real logic: downloads runner release, idempotent, `DRY_RUN="${DRY_RUN:-1}"` default-safe, `--execute` requires `CONFIRM=1` (`runner/install.sh:9-16`, head read). Not an echo stub.
- `runner/register.sh` (139 ln), `runner/ephemeral-spawn.sh` (73 ln), `runner/remove.sh` (108 ln) — 424 lines of bash total.
- Policy artifacts: `runner/policies/runner-group.md`, `runner/policies/pr-from-fork.md` (the untrusted-fork gate, `VISION.md:81-83`).
- systemd units: `runner/systemd/actions.runner.flexnetos.service.tmpl`, `runner-spawn@.service`, `runner-spawn@.timer`.
- `runner/.env.example`, `runner/README.md`. Total 64K / 11 files.

Verdict: **real** (host config that an operator runs; correctly dry-run-guarded).

Confidence: **high**.

---

### CLAIM D1.6 — Role 6 (reusable-CI templates) is REAL/operational and DOGFOODED — directly refuting `VISION.md:107` "Today the workflows are scaffolds".

The eight `reusable-*.yml` files contain full, concrete CI job logic (real toolchain setup, real lint/build/test commands, conditional language dispatch, artifact upload), carry documented `workflow_call` inputs and least-privilege `permissions:` blocks, and are **actually consumed by this repo's own `ci.yml`**. The only thing missing is the `@v1` release tag.

Evidence:
- 8 files, 1030 lines total: `reusable-build.yml` (127 ln), `reusable-lint.yml` (174 ln), `reusable-test.yml` (137 ln), `reusable-security.yml` (154 ln), `reusable-release.yml` (118 ln), `reusable-secrets.yml` (114 ln), `reusable-typecheck.yml` (104 ln), `reusable-submodule-bump.yml` (102 ln).
- **No scaffold markers**: `grep -nEi 'TODO|FIXME|scaffold|placeholder|stub|not implemented'` across all `reusable-*.yml` → **0 hits**.
- **Real job logic, not echo stubs** — `reusable-lint.yml` runs `ruff check` + `black --check` for python (`reusable-lint.yml:160-163`), `cargo fmt --check` + `cargo clippy` with `-D warnings` toggle (`reusable-lint.yml:165-174`), `bun run lint`/`npm run lint` guarded by `jq -e '.scripts.lint'` (`:139-154`); `reusable-build.yml` runs `cargo build --release --all-features` / `uv build` / `npm ci && npm run build` with `actions/upload-artifact@v4` (`reusable-build.yml:81-127`).
- **Documented inputs + least-priv permissions**: `reusable-build.yml:11-39` (typed `workflow_call` inputs with descriptions; `permissions: contents: read`); `reusable-lint.yml:13-37` (same shape, `permissions: contents: read` at `:36-37`). Matches the `VISION.md:89-95` contract.
- **Dogfooded / consumed NOW**: `.github/workflows/ci.yml:23` `uses: ./.github/workflows/reusable-lint.yml` and `ci.yml:62` `uses: ./.github/workflows/reusable-security.yml` — this repo's own CI calls the reusables.
- **What IS genuinely missing (the kernel of truth in VISION.md:107)**: `git tag -l` → **0 tags**. No `@v1` (or any) tag exists, so downstream cannot pin `@v1` yet. `RELEASING.md` (3.1K) documents the release-please + moving-major-tag path to v1.

Verdict: **REAL/operational, NOT scaffold.** The codemap (§2 / `codemap.md:46`) is correct; **`VISION.md:107` is stale/inaccurate** — it conflates "untagged" with "scaffold". The YAML is production-shaped and in active use; only the moving release tag is absent.

Confidence: **high** (job logic, permissions, input contracts, and the in-repo `uses:` callers are all directly cited; tag absence is verified by `git tag -l`).

---

### CLAIM D1.7 — DRIFT summary across roles (over/under-built vs VISION).

Evidence-backed deltas between what VISION.md describes and what's on disk:
- **Role 6 — VISION under-states reality.** `VISION.md:107` says "scaffolds"; the YAML is real and dogfooded (D1.6). Drift = doc-vs-code, doc is behind.
- **Role 4 — codemap under-states reality.** Codemap calls secrets "scaffold"; there are 4 real PGP-4096 blobs (D1.4). Drift = analysis-vs-code, analysis is behind; raises extract data-loss stakes.
- **Role 2 — under-built vs VISION.** VISION.md:25 promises a ~24-entry manifest-driven submodule mount; on disk only 4 of ~28 manifest repos are gitlinked and only 7 of 17 gitlinks are `.gitmodules`-mapped (D1.2). Three-way drift; the role is half-wired.
- **Role 3 — under-built vs VISION.** VISION.md:45 describes an active "memory layer"; the `pages/` tree is empty (D1.3). Frame-only.
- **Roles 1 & 5 — match VISION.** No material drift.

Confidence: **high** (each delta traces to a D1.x claim above).

---

## Current-state verdict

Of the six roles, **three are genuinely real/operational** — Role 1 (community-health: all canonical files present at both fallback locations), Role 5 (runner: 424 lines of dry-run-guarded lifecycle scripts + policies + systemd units), and Role 6 (reusable CI: 8 fully-implemented `workflow_call` templates, 1030 lines, documented inputs + least-priv permissions, **actively dogfooded by `ci.yml`** — the only missing piece is the `@v1` git tag, of which there are currently zero). **One role is partial-but-real** — Role 4 (secrets: a working `pass`/GPG store holding 4 live PGP-RSA-4096 encrypted secrets, with the env-injection layer still templated). **Two roles are scaffold/drifted** — Role 3 (wiki: schema + lint harness exist but the `pages/` content tree is entirely `.gitkeep`, zero knowledge) and Role 2 (submodule mount: three-way drift — ~28 manifest entries vs 17 committed gitlinks vs only 7 `.gitmodules` mappings). The single most important correction this dimension delivers: **`VISION.md:107`'s "Today the workflows are scaffolds" is factually wrong as of HEAD** — the reusable workflows are production-shaped and in use; "scaffold" describes only the absent release tag, not the YAML. The secondary correction: the secrets vault is more real (live encrypted blobs) than the codemap's "scaffold" label implies, which materially raises the data-loss risk on any extract/MOVE.
