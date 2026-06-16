# Changelog

## 1.0.0 (2026-05-27)


### Features

* add github-conventions ECC bundle ([95a5c2e](https://github.com/FlexNetOS/.github/commit/95a5c2ebf1debbc8f300fcf0e77423a6b9e81ffc))
* scaffold FlexNetOS .github mega-umbrella ([6ee1630](https://github.com/FlexNetOS/.github/commit/6ee1630a887cdb6e8610608d757d9f5211c125a8))
# CHANGELOG

> Applied changes to the FlexNetOS/.github umbrella repo. Entries are dated and reference the source TODO item or research artifact where applicable.
> Forward-looking work lives in `TODO.md`. Session wrap-ups live in `SESSIONS.md`. Deep research artifacts live in `data/brain-data/research/`.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this repo aims to adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) once `v1.0.0` is cut (see `USER.TODO.md` step 10).

**Ownership handoff (UA-2026-05-28-001):** This file is hand-maintained until `v1.0.0` is tagged. At that point, the operator renames `## [Unreleased]` below to `## [0.x.0-bootstrap] - <date>`, then activates `release.yml` (release-please). Release-please will manage `## [Unreleased]` and all version sections from that point forward, auto-generating entries from Conventional Commits. The bootstrap history below is preserved as a versioned section. The `release.yml` workflow is currently `workflow_dispatch`-only pending USER.TODO org/App setup — do not activate it before those gates pass.

---

## [Unreleased]

### Changed (SESSION-2026-06-16-005)
- **Docs accuracy: reusable workflows are no longer "scaffolds".** Updated `README.md` and `RELEASING.md` to reflect that `.github/workflows/reusable-*.yml` contain real bodies and are consumed by the umbrella's own `ci.yml`. `RELEASING.md` now documents the operational gate blocking automatic releases (`release.yml` is `workflow_dispatch`-only until the org-level release token is wired). (P4)

### Removed (SESSION-2026-06-16-005)
- `.github/dependabot.yml` — retired in favor of Renovate (`renovate.json5` already present). Dependabot was duplicating update noise and conflicting with the Renovate dependency-dashboard workflow. (P3)

### Added (SESSION-2026-06-16-005)
- `.github/workflows/semantic-pr-title.yml` — org-level reusable workflow that validates PR titles against Conventional Commits using `amannn/action-semantic-pull-request@v5`. Includes `scopes:` allowlist matching repo topics and a `types:` allowlist. Can be called as a reusable workflow or copied as a required status check. (P2)
- `.githooks/commit-msg` — local commit-message hook that enforces the same Conventional Commit format at `git commit` time. Install with `git config core.hooksPath .githooks`. (P2)
- `renovate.json5` configuration additions: enabled `dependencyDashboardApproval: true`, grouped GitHub Actions minor/patch updates, and pinned digest updates for Actions to reduce PR noise. (P3)

### Fixed (SESSION-2026-06-16-005)
- Removed retired submodule references from `CONTRIBUTING.md`, `Makefile`, and `.github/workflows/manifest-drift.yml` that still pointed to `.github_org/repos/` submodules after ADR-0002 moved external repos to typed hubs. `make submodules.status` now only reports on `data/brain-data`. (P1)

### Notes (SESSION-2026-06-16-005)
- Branch target for this work: `docs/meta-foundation-confirmation`. The session is intentionally additive/doc-only; no submodule mutations, no forks, no secret writes, no `main` branch edits.
- New user-action item added: `UA-2026-06-16-001` — wire release token and re-enable automatic `release.yml` triggers.

### Changed (SESSION-2026-05-29-015)
- **PR pipeline driven to finish line.** Repaired `develop` CI and resolved all open PRs: (PR #71) fixed `reusable-typecheck.yml` duplicate `run:` key + losslessly repaired the spliced `.claude/settings.json` (valid JSON; kept the complete copy — 8 hook events / 16 plugins / 5 marketplaces / 28 commands; discarded 335-line duplicate had 0 unique commands); (PR #74) salvaged the unique `network/` slim control-plane scaffolding (8 files absent from develop); (PR #67) squash-promoted develop→main. `main` and `develop` are now content-identical. (SESSION-2026-05-29-015)
- `TODO.md` — de-duplicated the triplicated "CI-failure autofix" section and collapsed the 8-deep stacked `**Last updated:**`/`**Branch:**` header to a single current line (merge-accumulation cruft from concurrent-session merges). (SESSION-2026-05-29-015)

### Added (SESSION-2026-05-29-015)
- `network/` slim control-plane scaffolding — `service-map.yaml`, `scripts/slim-doctor.sh`, `scripts/slim-status.sh`, `README.md`, `MANIFEST.yaml`, `docs/{local-domains,slim-review,tailscale-vs-slim}.md` — salvaged from the superseded #66/#51 branches before they were closed (PR #74). (SESSION-2026-05-29-015)

### Removed (SESSION-2026-05-29-015)
- Closed **PR #66** (`feat/github-app-automation`) and **PR #51** (`infra/network-slim-control-plane`) as **superseded** — old umbrella branches whose merge would have deleted ~2.58M lines / 258 files of newer develop content; all deliverables already on develop, unique `network/` part salvaged via #74. Deleted ~16 merged + 7 cruft + 2 post-merge remote branches; remote pruned to `main` + `develop`. (SESSION-2026-05-29-015)

### Notes (SESSION-2026-05-29-015)
- `ci-failure-tracker.yml` is now live on `main` (workflow_run activates only from the default branch). Non-required CI checks `.claude/settings.json hygiene` + `Trivy filesystem + IaC` remain red on the gated G8 violations (hardcoded marketplace paths + `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`) — tracked in TODO, not addressed (user-environment change). Admin merges + the settings.json repair were explicitly user-authorized. All-refs backup bundle retained at `~/my-github-allrefs-backup-20260529T102823.bundle`. No `gh repo fork`, no submodule mutations. (SESSION-2026-05-29-015)

### Added (SESSION-2026-05-29-012)
- `data/brain-data/research/n8n-mcp.md` — complete 12-section dossier for `czlonkowski/n8n-mcp` v2.56.0 (Phases 1-3 verified). MIT license, npm+tsc stack, SQLite self-contained DB, 1851 n8n node docs, 17 management tools when `N8N_API_KEY` configured. (research: n8n-mcp)
- `data/brain-data/research/n8n-mcp/` — repomix full + compressed packs + summary (764 files, HEAD `0f3d3f5`).
- `repos/n8n/mcp/n8n-mcp` — n8n-mcp added as git submodule inside `repos/n8n` at path `mcp/n8n-mcp`. Built (npm install + tsc), SQLite node DB populated (823 nodes, 2352 templates). Running on port 3001.
- `repos/n8n/mcp/n8n-mcp/.env` — local HTTP config: PORT=3001, N8N_API_URL=http://localhost:5678, WEBHOOK_SECURITY_MODE=moderate, TRUST_PROXY=1. API key from `pass n8n/api-key`. (gitignored)
- `secrets/store/n8n/api-key` — n8n instance API key (pass-encrypted, user-stored 2026-05-29).
- `secrets/store/n8n/mcp/token` — n8n-mcp AUTH_TOKEN (pass-encrypted; resolves UA-2026-05-29-005).
- `n8n.test` slim domain — `https://n8n.test → localhost:5678` registered.
- `n8n-mcp.test` slim domain — `https://n8n-mcp.test → localhost:3001` registered; MCP endpoint verified with 17 management tools via JSON-RPC `tools/list`.
- slim CA cert installed in system trust store (`/usr/local/share/ca-certificates/slim.crt`); `slim doctor` CA trust ✓ for all domains.

### Fixed (SESSION-2026-05-29-012)
- `network/slim/internal/doctor/trust_linux.go` — CA trust doctor check looked for `rootCA.pem` (the CA cert basename) but `TrustCA()` actually installs `slim.crt`. Fixed: replaced `filepath.Base(cert.CACertPath())` with `const anchorName = "slim.crt"`. Rebuilt and installed atomically via temp-file swap while daemon was live. (SESSION-2026-05-29-012)

### Notes (SESSION-2026-05-29-012)
- n8n and n8n-mcp are running as unmanaged background processes — see TODO for persistence tracking item.
- UA-2026-05-29-005 closed: `pass n8n/mcp/token` confirmed populated by user.
- No `gh repo fork` for n8n-mcp. No umbrella-level submodule mutations (n8n not yet a registered umbrella submodule — blocked by UA-2026-05-29-003). No push to origin.

### Added (SESSION-2026-05-29-011)
- `.github/workflows/reusable-typecheck.yml` — new reusable TypeScript type-check workflow (`tsc --noEmit`) for bun and node projects. Prefers the repo's `typecheck` script; falls back to `node_modules/.bin/tsc`. Starts report-only on PRs per CI invariant promotion pattern. Inputs: `language`, `working-directory`, `tsconfig-path`, `strict`. Caller snippet documented in the header. actionlint clean. (SESSION-2026-05-29-011)
- `README.md` — added `reusable-typecheck.yml` to the `.github/workflows/` tree; updated caller snippet example to chain `typecheck` between `lint` and `test` with `needs:`.

### Changed (SESSION-2026-05-29-010)
- `.github/workflows/manifest-drift.yml` — promoted three jobs to STRICT (removed `continue-on-error: true`): `claude-settings-doctor` (unblocked by G8 trim), `claude-dir-check` and `open-questions-lint` (were already recorded as promoted in `promote-strict.md` since 2026-05-28 but the flag was never removed — gap fixed). `check-user-todo-step5` (informational) and `submodules-materialize-noop` (deferred G4/G5) remain REPORT_ONLY. Renamed `claude-settings-doctor` job from "(report-only)" name variant. (TODO: CI invariant promotion — CLOSED)
- `repos/MANIFEST.yaml` — set `branch: develop` for `everything-claude-code`, `oh-my-claudecode`, `oh-my-pi` (was `branch: main`). Vision: `develop` carries FlexNetOS changes; `main`/`master` mirrors upstream. (TODO: USER.TODO#5 MANIFEST branch targets — CLOSED)
- `~/.claude/settings.json` (user-global, not in repo) — migrated 4 hook entries previously hardcoded in `.claude/settings.json`: `ccg/subagent-context.js` (PreToolUse Bash|Agent), `ccg/session-start.js` (SessionStart startup|clear|compact), `ccg/workflow-state.js` + `ccg/skill-router.js` (UserPromptSubmit). Now use portable `${CLAUDE_CONFIG_DIR:-$HOME/.claude}` paths. (TODO: G8 — CLOSED)

### Fixed (SESSION-2026-05-29-010)
- `.claude/skills/install-github-app/SKILL.md` (lines 156, 277) — added `text` language tag to two bare fenced code blocks that caused `make verify.markdown` failures.
- `data/brain-data/research/n8n-mcp.md` (line 141) — same fix: `text` tag on bare verification output block.

### Decisions recorded (2026-05-29)
- G8 trim was already committed in `4f16178 refactor(settings)` on this branch before this session started; `make claude.doctor` confirmed 0 violations. This session confirmed the state and migrated the 4 previously-missing hook entries to `~/.claude/settings.json`.
- `check-user-todo-step5` CI job: no promotion planned per `promote-strict.md` (intentionally informational).
- `submodules-materialize-noop` CI job: deferred until `scripts/materialize-gitmodules.sh` lands (G4/G5).

### Added (SESSION-2026-05-29-009)
- `data/brain-data/research/paperclip.md` — complete 13-section dossier for `paperclipai/paperclip` (Phase 1–3 verified). Stack: pnpm monorepo, Drizzle+Postgres, better-auth, React 19, Express v5, native `sharp`+`embedded-postgres` (patched). License: MIT, no CLA. Fork deferred per user (§10 "No go"). (research: paperclip)
- `data/brain-data/research/paperclip/` — repomix full pack + compressed pack + summary (2,578 files, HEAD 9eac727). (research: paperclip)
- `repos/paperclip feat/local-setup` branch — `.envrc` (direnv), `.paperclip/config.json` (loopback mode), `.paperclip/.env` (`PAPERCLIP_BIND=loopback`, `PAPERCLIP_TELEMETRY_DISABLED=1`). Build clean, dev server confirmed on 127.0.0.1:3091. (TODO: paperclip adoption)
- `repos/paperclip/` AGENTS.md hierarchy: `server/`, `ui/`, `cli/`, `packages/`, `skills/` created; root updated with FlexNetOS §12. All parent refs validate. (deepinit)

### Fixed (SESSION-2026-05-29-009)
- `Makefile` `research.pack` target — `$$BRANCH` → `$${BRANCH:-}` to prevent `unbound variable` under `.SHELLFLAGS := -eu -o pipefail -c`. (commit on `feat/todo-session-2026-05-28-006`)

### Decisions recorded (2026-05-29, SESSION-2026-05-29-009)
- `paperclip` fork deferred: user "No go" at §10. `repos/paperclip feat/local-setup` is a pre-fork working copy.
- Root cause of `local_trusted requires server.bind=loopback`: system `HOST=0.0.0.0` overrides Paperclip's loopback inference. Fix: `PAPERCLIP_BIND=loopback` in `.paperclip/.env`.
- Migration 0092 (`cloud_upstream_connections`) locally generated, not in upstream — keep untracked; committing it breaks integration tests.
- `workspace-runtime.test.ts` port 3090 failures are environment-only (CC session holds the port). Pass in CI.

### Notes (SESSION-2026-05-29-009)
- Work split across two branches: umbrella `feat/todo-session-2026-05-28-006` (dossier + Makefile) and `repos/paperclip feat/local-setup` (setup + AGENTS.md). Bookkeeping committed to `feat/session-2026-05-29-007` (current HEAD at wrap-up time; branch switch root cause not identified).
- No `gh repo fork`, no submodule mutations, no push to origin for paperclip repos.

### Added (SESSION-2026-05-29-008)
- `.github/workflows/ci-failure-tracker.yml` — watches the umbrella's top-level CI workflows (ci, manifest-drift, release, secrets-rotate, wiki-lint, auto-review-merge, promote-develop-to-main, dependency-review, submodule-bump) via `workflow_run`. On a `failure` conclusion it opens (or updates) a tracking issue tagged `ci-failure` + `needs-autofix` whose body **references the run log URL and each failed job's log URL** (branch, commit, event, run id). Dedupes by `ci-failure: <workflow> on <branch>` title so repeat failures append a comment instead of spawning duplicates (the `secrets-rotate.yml` pattern). A companion `resolve` job auto-closes the issue when the same workflow next succeeds on that branch. House conventions: `@v6`/`@v9` action pins, blocked default permissions (`contents: read`, `issues: write`, `actions: read`), `concurrency` guard. actionlint clean; both inline `github-script` bodies pass `node --check` under the async wrapper github-script uses. (commit 4c25173; TODO: ci-failure-autofix)
- `TODO.md` — new "CI-failure autofix" section: the follow-on loop that consumes `needs-autofix` issues (fetch logs → diagnose → open fix PR), gated behind one green tracker cycle, plus a note to pre-create the `ci-failure`/`needs-autofix` labels. (SESSION-2026-05-29-008)

### Notes (SESSION-2026-05-29-008)
- `workflow_run` only activates from the workflow file on the **default branch (main)** — a GitHub platform rule, so the tracker will not fire from the feature branch; it goes live after merge. The `ci-failure`/`needs-autofix` labels do not exist yet (`issues.create` mints them on first use). No submodule mutations, no `gh repo fork`, no host installs during the substantive work. The branch also carries unrelated commits from concurrent work (`23751e2` reusable-typecheck, `18eb003` prior SESSION-007 wrap-up) — this session's own substantive commit is `4c25173`.

### Added (SESSION-2026-05-29-006)
- `architecture/` — single common root for the umbrella's design-time artifacts: `prd/`, `adr/`, `plan/`, and `openspec/` (OpenSpec OPSX engine), plus `README.md` (lifecycle map + routing table + PRD/ADR registry). Built via the OPSX multi-model flow (Claude + codex/gpt-5.5): spec-research → spec-plan → spec-impl → adversarial review → archive.
- `architecture/prd/PRD-0001-architecture-framework.md` (via `ecc:plan-prd`), `architecture/adr/ADR-0001-architecture-artifact-homes.md` (via `ecc:architecture-decision-records`), and the archived OpenSpec change `2026-05-29-architecture-framework` promoting capability spec `openspec/specs/architecture-framework/spec.md` (6 requirements).
- `architecture/openspec/config.yaml` (umbrella context + rules) and `project.md`.

### Changed (SESSION-2026-05-29-006)
- `CLAUDE.md` + `AGENTS.md` — added an identical **Architecture artifacts** routing block directing `ecc:plan-prd`/`prp-prd`, `ecc:architecture-decision-records`, `ccg:spec-*`, and `writing-plans`/`plan` outputs into `architecture/` (overriding their built-in defaults).
- `docs/directory-layout.md` — documented the `architecture/` top-level entry.
- `scripts/verify-markdown.py` — exclude gitignored `architecture/.claude/` (OpenSpec init tooling) from markdown lint, mirroring the `.claude/plugins/` precedent.
- `.gitignore` — ignore `architecture/.claude/` (OpenSpec init AI-tooling, local only).

### Fixed (SESSION-2026-05-29-006)
- `architecture/` cross-links repointed to the archived change path (`changes/archive/...`). PR #27 squash-merged before the post-archive link fix, shipping 5 broken relative links to develop; caught by `/wrap-up` verification, fixed forward in PR #29. (unblocks: UA-2026-05-29-004)

### Notes (SESSION-2026-05-29-006)
- Framework merged to develop via PR #27 (`9b6ef51`); cross-link fix follows in PR #29. Built via full multi-model OPSX (Claude + codex); antigravity backend unavailable. `architecture/.claude/` gitignored (OpenSpec init tooling). No submodule/`docs`-relocation/`lifeos` changes.

### Fixed (SESSION-2026-05-29-007)
- `.claude/settings.json` — repaired malformed JSON. Two settings objects were spliced together (stray `],` at the `extraKnownMarketplaces` boundary), making the file invalid so `/doctor` flagged it and Claude Code silently dropped all settings. Reconstructed losslessly: kept the richer hooks block + `permissions` + `extraKnownMarketplaces` from block 1, carried over the unique tail keys (`sandbox`, `advisorModel`, `theme`, `teammateMode`, `omcHud`, `skip*` flags) from block 2; verified all 28 hook commands in the dropped duplicate block were already present in the kept block (0 unique commands lost). Now 13 valid top-level keys. (commit b970ac5)

### Added (SESSION-2026-05-29-007)
- `.mcp.json` — registered `n8n-mcp` HTTP MCP server (`http://localhost:5678/mcp-server/http`) using `Bearer ${N8N_MCP_TOKEN}` env interpolation, mirroring the existing `github`/`${GITHUB_TOKEN}` server per the file's no-secret-literals rule. (commits b970ac5 + 787f449; unblocks: UA-2026-05-29-005)
- `~/.claude.json` (global, not in repo) — same `n8n-mcp` server at user scope, hardened with `Bearer ${N8N_MCP_TOKEN:-}` (empty default) so a missing env var in any shell degrades to a 401 instead of failing the parse of the whole global config. (SESSION-2026-05-29-007)

### Removed (SESSION-2026-05-29-007)
- `.claude/settings.json.corrupt.bak` and `~/.claude.json.bak.1780053267` — session backups, removed after the repair verified clean. (SESSION-2026-05-29-007)

### Decisions recorded (2026-05-29)
- n8n-mcp bearer token is stored via env-var indirection (`N8N_MCP_TOKEN`), never as a literal in any tracked or global config — confirmed against Claude Code docs that `${VAR}` expansion is supported in HTTP `headers`. The real JWT was never written to disk. (SESSION-2026-05-29-007)

### Notes (SESSION-2026-05-29-007)
- No `gh repo fork`, no submodule mutations, no push to origin, no host-side installs. Only `.claude/settings.json` and `.mcp.json` were committed (feature branch `feat/install-github-app`). Global `~/.claude.json` was edited in place (user-scope MCP, not version-controlled).

### Added (SESSION-2026-05-29-006)
- `.github/workflows/promote-develop-to-main.yml` — auto-promote workflow: triggers on `ci` `workflow_run` success on `develop`; finds or creates a perpetual `develop → main` PR; auto-approves via `PROMOTE_TOKEN` (admin PAT, different actor from `github-actions[bot]` PR creator so GitHub allows the review); enables auto-merge with `--rebase` to preserve conventional commits for release-please. (SESSION-2026-05-29-006)
- `.claude/skills/install-github-app/SKILL.md` — skill for Phase 4 GitHub App automation setup. (SESSION-2026-05-29-006)
- `PROMOTE_TOKEN` repo secret — set from `pass show github/personal/cli`; identity `drdave-flexnetos` with full `repo` + `workflow` scopes. (SESSION-2026-05-29-006)

### Changed (SESSION-2026-05-29-006)
- `main` branch protection — added 6 required CI status checks in strict mode: `lint / Lint (mixed)`, `actionlint .github/workflows`, `markdownlint`, `Validate manifests`, `Hermetic dependency audit`, `security / Gitleaks secret scan`. Existing 1-approval + linear-history + no-force-push rules preserved. (SESSION-2026-05-29-006)
- `develop` branch protection — created: same 6 CI gates, 1 approval, no force-push, `strict=false` (feature branches don't need to rebase on main before merging to develop). (SESSION-2026-05-29-006)
- Repo `allow_auto_merge` — enabled (required for `gh pr merge --auto` to work). (SESSION-2026-05-29-006)
### Added (SESSION-2026-05-29-006)
- `architecture/` — single common root for the umbrella's design-time artifacts: `prd/`, `adr/`, `plan/`, and `openspec/` (OpenSpec OPSX engine), plus `README.md` (lifecycle map + routing table + PRD/ADR registry). Built via the OPSX multi-model flow (Claude + codex/gpt-5.5): spec-research → spec-plan → spec-impl → adversarial review → archive.
- `architecture/prd/PRD-0001-architecture-framework.md` (via `ecc:plan-prd`), `architecture/adr/ADR-0001-architecture-artifact-homes.md` (via `ecc:architecture-decision-records`), and the archived OpenSpec change `2026-05-29-architecture-framework` promoting capability spec `openspec/specs/architecture-framework/spec.md` (6 requirements).
- `architecture/openspec/config.yaml` (umbrella context + rules) and `project.md`.

### Changed (SESSION-2026-05-29-006)
- `CLAUDE.md` + `AGENTS.md` — added an identical **Architecture artifacts** routing block directing `ecc:plan-prd`/`prp-prd`, `ecc:architecture-decision-records`, `ccg:spec-*`, and `writing-plans`/`plan` outputs into `architecture/` (overriding their built-in defaults).
- `docs/directory-layout.md` — documented the `architecture/` top-level entry.
- `scripts/verify-markdown.py` — exclude gitignored `architecture/.claude/` (OpenSpec init tooling) from markdown lint, mirroring the `.claude/plugins/` precedent.
- `.gitignore` — ignore `architecture/.claude/` (OpenSpec init AI-tooling, local only).

### Fixed (SESSION-2026-05-29-006)
- `architecture/` cross-links repointed to the archived change path (`changes/archive/...`). PR #27 squash-merged before the post-archive link fix, shipping 5 broken relative links to develop; caught by `/wrap-up` verification, fixed forward in PR #29. (unblocks: UA-2026-05-29-004)

### Notes (SESSION-2026-05-29-006)
- Framework merged to develop via PR #27 (`9b6ef51`); cross-link fix follows in PR #29. Built via full multi-model OPSX (Claude + codex); antigravity backend unavailable. `architecture/.claude/` gitignored (OpenSpec init tooling). No submodule/`docs`-relocation/`lifeos` changes.

### Added (SESSION-2026-05-29-005)
- `.claude/AGENTS.md`, `.github/AGENTS.md`, `scripts/AGENTS.md`, `tools/AGENTS.md`, `data/brain-data/research/AGENTS.md` — deepinit AGENTS.md hierarchy with `<!-- Parent: -->` tags + per-directory AI-agent guidance; `scripts/AGENTS.md` documents all 26 scripts. Architect-approved (26/26 after fix). (commits 1ca3663 + efba627)
- `.omc/autoresearch/codebase-health/` — autoresearch mission: `mission.md`, `evaluator.json` (`make verify`), `runs/run-001/` iteration-0001 PASS + decision log. (SESSION-2026-05-29-005)
- `data/brain-data/research/n8n/repomix-summary.md` + `.gitignore` — repomix compressed-pack summary for n8n; large XML packs gitignored. (research: n8n)
- Memory: `feedback-n8n-pnpm-version.md`, `feedback-n8n-build-fix-2026-05-29.md` — n8n requires pnpm 10.32.1 (11.x breaks build); full healthy-build recipe. (created during session)

### Changed (SESSION-2026-05-29-005)
- `data/brain-data/research/n8n.md` — §10 decisions resolved (license SUL-approved, sync as-needed, telemetry free-tier, EE local-host-only); §9 build verified healthy; §12 discrepancies. (research: n8n)
- `repos/MANIFEST.yaml` — n8n entry `branch: master` → `develop`, toolchain `[node]` → `[node, pnpm, docker]`, groups + notes added. (SESSION-2026-05-29-005)

### Added (SESSION-2026-05-29-004)
- `repos/n8n/.env.local` — 585-line, 23 KB comprehensive free-tier self-hosting config (22 named sections + 1 EE-only reference block); covers AI nodes, community packages, Python code node, MFA, Prometheus metrics, public API, task runners in internal mode. Gitignored in `repos/n8n/`. (research: n8n)
- `data/brain-data/research/n8n.md` §13 — n8n build fix recipe (tsc-alias + pnpm 10.x + turbo sh shim). (commits 56a2b18 + 876210a on `feat/session-2026-05-29-002`)
- `data/brain-data/research/n8n.md` §14 — comprehensive self-hosting env var reference table (23 categories, all @Env() decorators catalogued from 44+ source files). (research: n8n)
- Memory `feedback-n8n-pnpm-version.md` — pnpm version requirement (use pnpm@10.32.1; pnpm 11.x breaks n8n build) and correct turbo invocation.
- Memory `feedback-n8n-build-fix-2026-05-29.md` — step-by-step build fix recipe for n8n post-pnpm-11 poisoning.

### Changed (SESSION-2026-05-29-004)
- n8n build fixed from pnpm 11.x poisoned state: ran `tsc-alias` on `packages/core`, `@n8n/ai-workflow-builder.ee`, `@n8n/task-runner` to resolve 35+ unresolved `@/` aliases; reinstalled with `bunx pnpm@10.32.1 install --frozen-lockfile`; executed turbo build via sh shim (not `node turbo`). All 59 tasks passed. (research: n8n)

### Decisions recorded (2026-05-29, SESSION-2026-05-29-004)
- n8n self-hosting uses SQLite (`DB_TYPE=sqlite`) as default free-tier database.
- All EE modules (SAML, source-control.ee, external-secrets.ee, dynamic-credentials.ee) excluded from `.env.local`; EE vars documented in a commented-out block only.
- Python task runner enabled but requires host venv at `$HOME/.n8n/task-runners/python/venv`; other features are healthy without it.

### Notes (SESSION-2026-05-29-004)
- n8n `/healthz` verified → HTTP 200 `{"status":"ok"}`; `/rest/settings` returns valid JSON with `communityNodesEnabled: true`; 0 ERROR/FATAL in startup log.
- n8n research commits are on `feat/session-2026-05-29-002`, not on the current branch — push/merge both branches when ready.

### Added
- `TODO.md` — working TODO list for active changes (separate from `USER.TODO.md` for human-only setup steps).
- `CHANGELOG.md` — this file; tracks applied changes per project convention.
- `SESSIONS.md` — session wrap-up log (plural; logs all session summaries with session IDs, reference code, and location).
- `data/brain-data/research/my-github-reconciliation.md` — full ralplan consensus deliverable (iteration 3, APPROVED) covering VISION/PLAN/USER.TODO gap analysis, the `.claude` vs `Claude` directory resolution, and the 17-gap reconciliation plan.
- `data/brain-data/research/ai-top-utility.md` — pre-adoption dossier (FlexNetOS-owned, no upstream). (research: 4-clone-adoption)
- `data/brain-data/research/n8n.md` — pre-adoption dossier (already forked to `FlexNetOS/n8n`; needs `develop` branch + path normalization). (research: 4-clone-adoption)
- `data/brain-data/research/fabro.md` — pre-adoption dossier (third-party upstream `fabro-sh/fabro`; `gh repo fork` gated by section 9). (research: 4-clone-adoption)
- `data/brain-data/research/paperclip.md` — pre-adoption dossier (third-party upstream `paperclipai/paperclip`; `gh repo fork` gated by section 9). (research: 4-clone-adoption)
- Cross-session memory at `~/.claude/projects/.../memory/`:
  - `my-github-umbrella-model.md` — Model B authoritative + umbrella vision (no host-side installs, single-clone reproducibility).
  - `fork-workflow-branch-model.md` — `main`/`master` <-> upstream, `develop` <-> FlexNetOS branch model per `docs/fork-workflow.md`.
- Companion plan at `~/.claude/plans/sprightly-shimmying-charm.md` — the 4-clone adoption thread (Model B, Phase 0 dossier gate, research-before-fork rule).
- **Additive reconciliation tooling** (SESSION-2026-05-28-005, PR #20):
  - `scripts/claude-settings-doctor.js` — report-only `.claude/settings.json` hygiene scanner (hardcoded user-home paths + aspirational keys; allowlist-aware; never modifies the live file). (research: my-github-reconciliation G1/G7)
  - `scripts/g3a-can-convert.sh`, `scripts/g3b-backup-branch.sh`, `scripts/g3c-stash-and-move.sh`, `scripts/reconcile-stray-clones.sh` — reversibility chain (predicate + backup + dry-run move + orchestrator). (research: G3a-d)
  - `scripts/check-user-todo-step5.sh` — MANIFEST USER.TODO#5 tag detector. (research: G11)
  - `scripts/open-questions-lint.js` — open-questions schema validator. (research: G15)
  - `.claude/settings.canonical.json`, `.claude/.doctor-allowlist`, `.codex/.doctor-allowlist` — doctor reference shape + allowlists. (research: G6/G9)
  - `.omc/plans/open-questions.md` — 6 seeded entries (G3 triage, G4/G5 deferred, G15, G16).
  - `.github/workflows/manifest-drift.yml` — REPORT_ONLY CI: `claude-dir-check`, settings doctor, user-todo-5, open-questions-lint, deferred materialize-noop. (research: G14/G15-claude-dir)
  - Makefile targets: `claude.doctor`, `config.doctor`, `check.user-todo-5`, `open-questions.lint`.

- `.claude/skills/clone-setup/SKILL.md` — three-phase research-before-fork automation: `make research.pack` → code-first analysis (manifest → compressed pack → source → README last, enforced) → verified setup in `.attic/research-work/<name>/`; mandatory §12 Discrepancies table; `gh repo fork` never called by the skill. (SESSION-2026-05-28-006)

### Changed
- `.claude/skills/wrap-up/SKILL.md` — step 7 now commits all session work (7a: uncommitted substantive files), commits bookkeeping (7b), pushes branch to origin (7c), and opens a PR via `gh pr create` (7d); done-when item 6 updated from "committed, not pushed" to "committed, pushed, PR open"; do-not list updated (removed "Don't push", added "Don't force-push"); step 8 report now includes PR URL. (SESSION-2026-05-29-002)
- `scripts/runner-doctor.sh` — extended with `ps`-based orphan/ghost runner-process detection. (SESSION-2026-05-28-005; research: G12)
- `CONTRIBUTING.md` — added AI-tooling directory convention (`.claude` not `Claude`), CI-invariant promotion pattern, doctor allowlist policy, `.gitmodules` merge-conflict note. (SESSION-2026-05-28-005; research: G10/G14/G9)
- `README.md` — added Repo-navigation table + Phase-6 Vaultwarden operational gate. (SESSION-2026-05-28-005; research: G13)
- `Makefile` — added the reconciliation-tooling target block. (SESSION-2026-05-28-005)

### Changed (2026-05-29)
### Added (2026-05-29)
- `data/brain-data/research/slim.md` — full pre-adoption dossier for `nilbuild/slim`: identity, purpose, stack, license (PolyForm Shield 1.0.0 — non-compete noted), §10 decisions resolved, §11 decision log filled. Phase 1-3 verified: `go build` + `go test ./...` PASS at HEAD `9c07a08`. (SESSION-2026-05-29-003; research: slim)
- `data/brain-data/research/slim/` — repomix pack (full + compressed) + summary for `nilbuild/slim`. (SESSION-2026-05-29-003)
- `repos/MANIFEST.yaml` — new `NETWORK` section; `network/slim` entry (forked, pending UA-2026-05-29-001). (SESSION-2026-05-29-003)
- `network/slim/.mise.toml` — pins Go 1.25.10 for the slim clone; committed to inner repo. (SESSION-2026-05-29-003)
- HTTPS local dev domains live via slim proxy: `https://ollama.test` (11434), `https://openwebui.test` (8080), `https://gitnexus.test` (4747), `https://firecrawl.test` (3002). All return HTTP 200. (SESSION-2026-05-29-003)

### Changed (2026-05-29)
- `network/slim/internal/proxy/handler.go` — **fix:** removed `pr.Out.Host = pr.In.Host` in the reverse-proxy `Rewrite` func; outbound requests now use `Host: localhost:PORT` so backends that enforce Host-header security (Ollama, etc.) accept proxied requests. Committed to inner repo. (SESSION-2026-05-29-003)
- `.claude/skills/clone-setup/SKILL.md` — **fix:** added `HARD RULES` section and `Idempotency` decision table to prevent false-positive health detection on re-runs; script's `✅ Step 0 complete` is now documented as "pack available" not "healthy"; fork gate overrides script output. (SESSION-2026-05-29-001)
- `.claude/skills/clone-setup/SKILL.md` — **feat:** added `Setup philosophy` section: (1) local-host-only free tier over paid cloud (service substitution table + docker-compose-first heuristic), (2) tooling preference order (Rust/cargo → bunx → mise → direnv), (3) always full-feature dev setup (never `--production`/`--slim`). (SESSION-2026-05-29-001)

### Removed
- _(none yet)_

### Decisions recorded (2026-05-28)
- **Model B authoritative**: submodules live INSIDE `my-github/repos/{owned,forked,external}/`, NOT as `$HOME/_work/repos/_forks/` siblings. The doc `docs/directory-layout.md` describes the retired model and must be rewritten (queued in `TODO.md`).
- **Rename scope = Org-only**: CODEOWNERS, branch protection, FUNDING.yml, FLEXNETOS-ENV.md only. Internal package names (`package.json:name`, `Cargo.toml:name`, Docker image refs) deliberately untouched to keep upstream sync conflict-free.
- **Submodule `.github` overrides + caller workflows** inherit umbrella reusables via `uses: FlexNetOS/.github/.github/workflows/reusable-*.yml@main`. Switch to `@v1` once tagged.
- **Research-before-fork is a hard rule**: per-clone dossier must exist on disk at `data/brain-data/research/<name>.md` before any `gh repo fork` runs. Codified in cross-session memory `feedback-fork-after-original-setup.md` after the ruflu/ruvector incident.
- **G4/G5 lockfile pattern deferred** (SESSION-2026-05-28-005): the MANIFEST→`.gitmodules` materialize/lockfile refactor was deliberately excluded from the additive-tooling pass because it refactors the working `submodules.*` machinery (not additive). Tracked in `.omc/plans/open-questions.md`; the `submodules-materialize-noop` CI job is a placeholder until it lands.

### Corrections to prior work (2026-05-28)
- `data/brain-data/research/my-github-reconciliation.md` Reservation 2 — `ai-top-utility` was listed as "likely UNSAFE-MISMATCH". Verified origin is `https://github.com/FlexNetOS/ai-top-utility.git` (FlexNetOS-owned, no upstream remote). Correction recorded in `data/brain-data/research/ai-top-utility.md` cross-reference block, in the reconciliation doc Reservation 2 note, and in `TODO.md` Reservations section.

### Notes
- Convention established on 2026-05-28 per user instruction: research/plans go in `data/brain-data/research/`; root carries `TODO.md` (todo), `CHANGELOG.md` (applied), `SESSIONS.md` (session wrap-up). Prior `.omc/plans/my-github-reconciliation.md` was moved to the canonical research location.
- **No `gh repo fork` calls have been made.** All forks remain gated behind dossier section 9 review + explicit per-clone go-ahead.
- **No submodule conversions have been performed.** All 4 clones still sit flat at `repos/<name>/` (neither documented place).
- **No `repos/MANIFEST.yaml` entries have been added** for the 4 adoptees.
- **2026-05-28 (restore):** All root tracking files (`TODO.md`, `CHANGELOG.md`, `SESSIONS.md`) and the 4 pre-adoption dossiers + reconciliation plan were accidentally removed and recreated on branch `feat/restore-session-wrapup-files`. They had never been committed (untracked working-tree files), confirming the `feedback-always-commit` rule. This restore commits them so they cannot be lost to a routine `git reset` again.

### Added (SESSION-2026-05-28-003)
- `.omc/plans/ralplan-browser-choice.md` — ralplan v5 six-layer Linux workstation architecture (Pi-hole + dnscrypt-proxy + Cloudflare/Quad9 → vproxy → Slim → Firefox + Bifrost + Obscura, with trippy diagnostic sidecar). 5 iterations of consensus planning; status `pending approval`. **Misfiled per convention — see `UA-2026-05-28-003`.**
- `scripts/install-v5-architecture.sh` — 7-phase install script for the v5 architecture with `--dry-run` and `--phase N` flags, pre-flight prereq checks, abort-before-DNS-swap safety, recovery runbook embedded in epilogue. `bash -n` clean. Not yet executed.
- `USER.TODO.md` — 3 new UA items: `UA-2026-05-28-002` (rotate leaked Anthropic + OpenRouter keys), `UA-2026-05-28-003` (move v5 plan to canonical `data/brain-data/research/` path), `UA-2026-05-28-004` (decide whether `3dd0ef4` should remain on `main`).

### Decisions recorded (2026-05-28, SESSION-2026-05-28-003)
- **Six-layer workstation architecture (ralplan v5):** per-purpose tools at each layer (DNS / outbound proxy / local DNS+HTTPS / browser / LLM gateway / automation browser) rather than overloading one browser. Rejected: Edge (Linux second-class), Brave (user rejection), Chrome (auto-update friction), Chrome for Testing (more wiring than bundled chromium), bundled chromium as default (obscura is purpose-built). Decoupling pattern is brand-agnostic and recoverable per-layer.
- **Hard rule: feature branch before session work.** Installed globally at `~/.claude/hooks/branch-guard.sh` + matching `SessionStart` and `PreToolUse:Edit|Write|MultiEdit` entries in `~/.claude/settings.json` + new "Hard rule" section in `~/.claude/CLAUDE.md`. SessionStart warns when HEAD is `main`/`master`/`trunk`; PreToolUse blocks Edit/Write on source files (allows `.claude/`, `.omc/`, `.github/`, `CLAUDE.md`, `AGENTS.md`, `docs/**/*.md`). Per-repo allowlist + override supported; session bypass via `BRANCH_GUARD_OFF=1`. Outside-repo files unaffected.

### Notes (SESSION-2026-05-28-003)
- **Branch-guard install is *global*, not committed to this repo** — lives under `~/.claude/`. Backup at `~/.claude/settings.json.bak-pre-branch-guard-20260528-135800`.
- **Secrets at `$HOME` (outside repo, chmod 600, not committed):** `~/bifrost/.env`, `~/pihole/pihole_password.txt`, `~/vproxy/.env`. Anthropic + OpenRouter keys in `~/bifrost/.env` must be rotated immediately — see `UA-2026-05-28-002`.
- **Convention violation flagged:** v5 plan committed to `.omc/plans/ralplan-browser-choice.md` rather than the canonical `data/brain-data/research/v5-workstation-architecture.md`. Tracked in `UA-2026-05-28-003`.
- **`3dd0ef4` first landed on `main`, not on a feature branch.** Wrap-up notes that the new branch-guard rule (installed *during the same session*) would have prevented this. The commit is now also reachable from `feat/restore-session-convention-files` (this branch); see `UA-2026-05-28-004` for the decision about whether to keep it on `main`.

### Added (SESSION-2026-05-28-007)
- `AGENTS.md` — new cross-CLI instruction file: repo identity, branch discipline, 5-step Vision sequence (clone→research→setup→fork→submodule), full-clone-only rule, secrets policy, what agents get wrong, session tracking. (research: GitHub Workspace Vision)
- `data/brain-data/research/fork-remediation/` — dirty state snapshots for 3 fork-violated repos (everything-claude-code, oh-my-claudecode, oh-my-pi): `.patch` files + `ecc-untracked/` agentic-os subsystem (30 files) + 10-step remediation `README.md`. (TODO: USER.TODO#5)

### Changed (SESSION-2026-05-28-007)
- `CLAUDE.md` — added full 5-step Vision sequence + "What Claude gets wrong" hard guards + "Branch discipline at session start" subsection.
- `USER.TODO.md` — replaced 7× `_work/repos/my-github` → `workspace/my-github` (old-path migration); appended UA-2026-05-28-005/006/007.
- `repos/MANIFEST.yaml` — fixed header contradiction about `.gitmodules` regeneration; updated weftos + archon notes; removed stale `_work/repos/actions-runner/` ref.
- `secrets/store/.gpg-id` — replaced placeholder with real GPG fingerprint `6EC33743AA0CB75126F63F8765A937C4164F966F`.
- `tools/bin/repomix` — use `bunx` over `npx` (workspace uses bun 1.3.13 via mise); npx fallback retained.
- `.gitignore` — added `.claude/plugins/cache/`, `.claude/plugins/marketplaces/`, `.claude/plugins/data/` (555 MB plugin cache; regenerated by `omc install`).
- `scripts/verify-markdown.py` — added `.attic` to EXCLUDE_PARTS; 4 new EXCLUDE_PREFIXES for third-party dirs; result: `OK: 58 markdown files checked`.
- `.claude/agents/wrap-up-verifier.md` — fixed 1 bare fence (` ``` ` → ` ```text `).
- `.claude/skills/clone-setup/SKILL.md` — fixed 3 bare fences.
- `.claude/skills/wrap-up/SKILL.md` — fixed 2 bare fences.

### Decisions recorded (2026-05-28, SESSION-2026-05-28-007)
- **Fork-first violation confirmed** for everything-claude-code, oh-my-claudecode, oh-my-pi: all three set up from forks before clone/research/setup (Vision sequence violated). Dirty diffs captured before remediation. Correct sequence: clone upstream fresh → `make research.pack` → verify setup → `gh repo fork` → develop branch → apply patches → submodule. See `data/brain-data/research/fork-remediation/README.md`.
- **`tools/repomix/` stays gitignored** (not a submodule); promotion to MANIFEST/.gitmodules deferred until/unless FlexNetOS forks repomix.
- **`make verify` clean baseline**: 3 tool assets, 58 markdown files, 28 manifest entries, 13 tool entries — all pass on `feat/todo-session-2026-05-28-006`.

### Notes (SESSION-2026-05-28-007)
- **No `gh repo fork` calls made.** All fork remediation gated on UA-2026-05-28-005 (`gh auth login`).
- **No push to origin. No submodule mutations.**
- **MANIFEST `branch:` entries** for everything-claude-code, oh-my-claudecode, oh-my-pi still say `branch: main` — should be `branch: develop` per Vision; tracked in `TODO.md`.
- Session work fully committed (4 commits) on `feat/todo-session-2026-05-28-006`.

---

## Conventions

- **Date format:** ISO 8601 (YYYY-MM-DD).
- **Sections per release:** Added / Changed / Deprecated / Removed / Fixed / Security (Keep a Changelog standard).
- **Cross-references:** When an entry implements a `TODO.md` item, include a brief `(TODO: <item-name>)` tag. When it implements a research recommendation, include `(research: <slug>)`.
- **Pre-`v1.0.0`:** all entries land under `[Unreleased]`. After `v1.0.0` is cut per USER.TODO step 10, cut a dated release header above `[Unreleased]`.
