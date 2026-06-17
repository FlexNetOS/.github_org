# Codemap — FlexNetOS/.github (on disk: `.github_org`)

**Target:** `/home/drdave/Desktop/meta/.github_org` (the org's magic `.github` repo).
**Mission:** refactor into the `meta` peer-repo architecture; slim to **roles 1 + 6**
(community-health fallback + reusable CI), extract/migrate the other four roles to peers.
**Nature:** operational config + scripts + docs. **Nothing to build/run**; `make verify` is the gate.

Every claim below is grounded at `path` (and `path:line` where load-bearing).

---

## 1. Top-level structure

| Dir | Holds | Size / maturity |
| --- | --- | --- |
| `.github/` | **The enduring surface.** 21 workflows, CODEOWNERS, ISSUE_TEMPLATE/, PR template, dependabot.yml, actionlint.yaml, AGENTS.md | Real/operational |
| `repos/` | 4 committed gitlinks (`ai-top-utility`, `fabro`, `n8n`, `paperclip`) + `MANIFEST.yaml` (~28 aspirational) + README | **Drifted** (gitlinks ≠ manifest, no `.gitmodules`) |
| `wiki/` | Karpathy LLM-wiki: `purpose.md`, `schema.md`, `pages/`, `index.md`, `log.md`, AGENTS.md | Real scaffold, 12 files / 76K |
| `secrets/` | `pass`+GPG vault scaffold: `store/`, `envs/`, `recovery/`, `github-secrets.tsv.example` | Scaffold, 15 files / 100K |
| `runner/` | Self-hosted runner host config: install/register/remove/ephemeral-spawn scripts, `policies/` (runner-group, pr-from-fork), `systemd/` units | Real config, 11 files / 64K |
| `network/` | `service-map.yaml`, `MANIFEST.yaml`, `scripts/`, `docs/`, + `slim/` gitlink | Scaffold, 8 files / 48K |
| `data/` | `brain-data/` — 76M, 5 nested gitlinks (DeepTutor, deepwiki-rs, obsidian-mind, obsidian-second-brain, obsidian-skills) + research dossiers | **Heaviest dir (76M)** |
| `scripts/` | 30 files: verify-*, doctors, submodule-*, secrets-*, bootstrap, one-off g3* migration scripts, `hooks/` | Mixed (KEEP/RETIRE/DROP split) |
| `tools/` | 7 tool gitlinks (cpython, actionlint, gitleaks, trivy, node, bun, uv) + `bin/` wrappers + `MANIFEST.yaml` + `assets.json` | Real, the only `.gitmodules`-mapped set |
| `architecture/` | `adr/` (only ADR-0001 on disk), `prd/`, `plan/`, `openspec/`, README | Scaffold, 13 files / 108K |
| `github-app/` | `manifest.example.json`, `permissions.md` (2 files) | Thin scaffold, 16K |
| `.claude/` | 46 files / **6.0M** — agents, plugins, homunculus, identity, ecc-tools | Heavy config |
| `.codex/` | `config.toml`, `agents/`, AGENTS.md (6 files) | Config |
| `.agents/` | `skills/` (2 files) | Thin |
| `.omc/` | 97 files / 620K — `plans/`, `sessions/`, `state/`, `autoresearch/`, project-memory.json | Regenerable caches |
| `profile/` | `README.md` only — org landing page | Role-1 artifact, 1 file |
| `docs/` | 12 cross-org operational docs (fork-workflow, directory-layout, hermetic-toolchain, automation-roadmap, self-hosted-runner) | Real docs |
| Root | `VISION.md`, `MIGRATION.md`, `README.md`, community-health (`CODE_OF_CONDUCT`, `CONTRIBUTING`, `SECURITY`, `SUPPORT`, `FUNDING.yml`, `MAINTAINERS`, `LICENSE`), `Makefile`, `SESSIONS.md` (93.6K), `USER.TODO.md` (34.1K), `CHANGELOG.md` (38.9K), `TODO.md` | Mixed roles |

---

## 2. Role realization (the 6 VISION roles)

| Role | VISION ref | On disk | Real vs scaffold | Refactor verdict |
| --- | --- | --- | --- | --- |
| **1. Community-health fallback** | `VISION.md:12` | root `*.md` + `.github/` (`CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md`, `FUNDING.yml`, `ISSUE_TEMPLATE/`, `PULL_REQUEST_TEMPLATE.md`, `profile/README.md`) | **Real/operational** | **KEEP** (requires `.github` name) |
| **2. ~24 submodule mount** | `VISION.md:25` | `repos/` (4 gitlinks), `tools/` (7), `network/slim`, `data/brain-data/*` (5); `repos/MANIFEST.yaml`; `scripts/submodule-*.sh` | **Drifted machinery** — 17 real gitlinks, only 7 mapped in `.gitmodules` | **MIGRATE** → `.meta.yaml` peers; RETIRE machinery |
| **3. Karpathy LLM-wiki** | `VISION.md:45` | `wiki/` (`purpose.md`, `schema.md`, `pages/`); `.github/workflows/wiki-lint.yml` | Scaffold | **MOVE** → `flexnetos_wiki` |
| **4. `pass`+GPG secrets vault** | `VISION.md:60` | `secrets/` (`store/`, `recovery/`); `scripts/secrets-*.sh`; `.github/workflows/secrets-rotate.yml`; `reusable-secrets.yml` | Scaffold | **MOVE — but SUPERSEDED**: ADR-0007 routes secrets → `envctl` (not `flexnetos_secrets`); see §5 |
| **5. Self-hosted runner host** | `VISION.md:76` | `runner/` (scripts, `policies/`, `systemd/`); `docs/self-hosted-runner.md`; `network/` | **Real config** | **MOVE** → `flexnetos_runner` (P0 per ADR-0008) |
| **6. Reusable-CI templates** | `VISION.md:89` | `.github/workflows/reusable-*.yml` (8) | **Real, fully-shaped** (documented inputs, least-priv `permissions:`, matrices) — NOT yet tagged `@v1` (`VISION.md:107` "Today the workflows are scaffolds" — understated; the YAML is real, only the release tag is missing) | **KEEP** (requires `.github` name) |

---

## 3. The enduring surface — workflows + org policy (roles 1 + 6, the KEEP-set)

### `.github/workflows/*.yml` (21 files), classified

**A. Reusable CI templates (Role 6 — KEEP, the reason this repo exists):**
| File | Real? |
| --- | --- |
| `reusable-build.yml` | Real — language dispatcher (bun/node/python/rust/mixed), `permissions: contents: read` (`reusable-build.yml:38`) |
| `reusable-lint.yml` | Real (6.9K) |
| `reusable-test.yml` | Real (4.9K) |
| `reusable-typecheck.yml` | Real (3.1K) |
| `reusable-security.yml` | Real (4.6K) |
| `reusable-release.yml` | Real (4.5K) |
| `reusable-secrets.yml` | Real (3.9K) — **tied to Role 4**, follows secrets to envctl? (open) |
| `reusable-submodule-bump.yml` | Real — **RETIRE** (meta replaces submodule model) |

No `TODO/scaffold/placeholder/stub` markers found in any `reusable-*.yml` (grep clean) — these are production-shaped, only missing the `@v1` moving tag.

**B. This repo's own CI (KEEP, slim):**
| File | Role |
| --- | --- |
| `ci.yml` | Self-CI; dogfoods `reusable-lint.yml` + manifest-validate + actionlint + markdownlint + hermetic-audit + security (`ci.yml:21-60`) |
| `dependency-review.yml` | Generic (661B) |
| `release.yml` | Generic (653B) |
| `claude.yml`, `claude-code-review.yml` | Claude automation |
| `auto-review-merge.yml` (8.6K), `ci-failure-tracker.yml`, `promote-develop-to-main.yml` | This repo's PR/release ops machinery |

**C. Submodule/manifest machinery (RETIRE — replaced by meta):**
| File | Fate |
| --- | --- |
| `submodule-bump.yml` | RETIRE |
| `manifest-drift.yml` | RETIRE (also hosts `claude-dir-check`, report-only) |
| `wiki-lint.yml` | MOVE → flexnetos_wiki |
| `secrets-rotate.yml` | MOVE → secrets home (envctl?) |

### Org-policy artifacts
- `.github/CODEOWNERS` — present (KEEP)
- `.github/dependabot.yml` — present (KEEP)
- `.github/actionlint.yaml` — present (KEEP)
- `.github/ISSUE_TEMPLATE/` (bug_report, feature_request, documentation, config) + `PULL_REQUEST_TEMPLATE.md` (KEEP)
- `runner/policies/{runner-group.md, pr-from-fork.md}` — runner-group allowlist + PR-from-fork gate (MOVE with runner)
- Branch protection: described in `CLAUDE.md` (`main` protected, PR+1 approval, linear history) — **policy is documented, not codified as an artifact in-repo** (gap for a meta-native org-policy story)

---

## 4. Submodule reality vs MANIFEST (Role 2 drift — QUANTIFIED)

**17 committed gitlinks** (mode 160000 in HEAD, via `git ls-tree -r HEAD`):
- `tools/`: actionlint, bun, cpython, gitleaks, node, trivy, uv **(7)**
- `repos/`: ai-top-utility, fabro, n8n, paperclip **(4)**
- `network/slim` **(1)**
- `data/brain-data/`: DeepTutor, deepwiki-rs, obsidian-mind **(3)** + `my-wiki-knowledge/.claude/obsidian-second-brain`, `obsidian-skills` **(2)** = **5**

**Only 7 have `.gitmodules` mappings** (all `tools/*`). The other **10 gitlinks have NO `.gitmodules` entry** → this is why `git submodule status` returns **empty / errors** (MIGRATION.md:30 flags `DeepTutor` specifically; in fact all of `repos/`, `network/`, `data/` are unmapped).

**`repos/MANIFEST.yaml`** claims ~28 owned/forked/external repos (~30 `repo:`/`url:` lines) but only **4** of them are actually committed as gitlinks. **`tools/MANIFEST.yaml`** (~26 lines) covers the 7 real tool gitlinks.

**Drift summary:** manifest is **aspirational** (≈28) vs **17 real gitlinks** vs **7 `.gitmodules`-mapped**. Three-way inconsistency. `ruvector` + `weftos` are in the discard set (MIGRATION.md:32).

---

## 5. Meta-integration state

- **This repo is ALREADY a registered meta peer.** Parent `/home/drdave/Desktop/meta/.meta.yaml:111` declares `github_org:` → `repo: git@github.com:FlexNetOS/.github.git`, `path: .github_org`, `tags: [org, ci]`. Comment at `.meta.yaml:108-110` notes the in-progress refactor (`tasks/github-meta-refactor`, slim to roles 1+6).
- **It is its own independent git repo** (`git remote -v` → `FlexNetOS/.github.git`; `git rev-parse --show-toplevel` = `.github_org`) — i.e. it conforms to the peer model (independent remote/history) already.
- **Parent gitignores it** (`/home/drdave/Desktop/meta/.gitignore:77` `.github_org/`) — correct meta-repo discipline (child repos are NOT part of parent history).
- **The MOVE-target peers are ALREADY declared in parent `.meta.yaml`:** `flexnetos_runner` (`:127`), `flexnetos_github_app` (`:130`), `flexnetos_wiki` (`:133`), `flexnetos_brain` (`:136`). So the destinations are grounded as registry entries even if not yet populated/extracted.
- **Plan supersession (evidence in parent `.meta.yaml:122-126`):** MIGRATION.md's `flexnetos_secrets` (role 4) is **RETIRED → envctl** per **ADR-0007** (envctl already owns vault/secretd/broker + ProviderMint GitHub-token seam; a second store = split-brain). `flexnetos_github_app` + `flexnetos_runner` are **P0 per ADR-0008**. **NOTE:** ADR-0007/0008 are *referenced* but only **ADR-0001** exists on disk under `architecture/adr/` here — the governing ADRs live in the meta workspace KB, not in this repo (traceability gap).
- **No `.meta.yaml` inside this repo** — correct; it is a leaf peer, not a nested meta.

**Net:** the registry-level integration is DONE (peer entry + destination peers + gitignore). The unfinished work is **content extraction + machinery retirement**, not registration.

---

## 6. Build / run / verify surface

No build. The gate is **`make verify`** (`Makefile:28`):
`verify.tool-assets verify.actionlint verify.markdown verify.manifest verify.tools verify.hermetic`.

| Target | Does |
| --- | --- |
| `verify.actionlint` | `tools/bin/actionlint .github/workflows/*.yml` |
| `verify.markdown` | `scripts/verify-markdown.py .` |
| `verify.manifest` / `verify.tools` | `verify-manifest.py` on repos/ + tools/ MANIFEST |
| `verify.hermetic` | advisory non-hermetic-dep report |
| `submodules.*` | init/add/bump/sync/status (Role-2 machinery → RETIRE) |
| `*.doctor` (github/claude/config/runner) | read-only audits |
| `research.pack URL=` | clone+repomix for the research-before-fork ritual |

**CI mirror:** `ci.yml` runs lint+manifest-validate+actionlint+markdownlint+hermetic-audit+security; `manifest-drift.yml` is report-only (`continue-on-error`). The `verify.manifest`/`verify.tools` checks and `submodule-bump`/`manifest-drift` workflows are exactly the machinery slated for RETIRE — so the verify gate itself shrinks as Role 2 leaves.

---

## Could-not-map / gaps for completeness sweep
- **ADR-0007 / ADR-0008** governing the secrets→envctl + runner/app-P0 decisions are referenced in parent `.meta.yaml` but **not present on disk** here (only ADR-0001). Their full text lives in the meta workspace KB — verifier/analyst should fetch from there if the decision rationale matters.
- **`reusable-secrets.yml` + `secrets-rotate.yml` fate** is open now that secrets → envctl (do the secrets CI templates follow to envctl, stay as generic Role-6 templates, or get dropped?).
- I did not open every one of the 21 workflows line-by-line (sampled `reusable-build.yml`, `ci.yml`; grepped all for scaffold markers). A D3 analyst should confirm each reusable's input contract + least-priv block for the "production-ready slim KEEP-set" claim.
- `network/` internal split (which parts → runner vs own peer) is an open question (MIGRATION.md:87).
