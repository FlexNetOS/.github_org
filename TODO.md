# TODO — current changes needed

> Working TODO list for the FlexNetOS/.github umbrella repo. Separate from `USER.TODO.md` (human-only actions; agent appends only to `## Agent-flagged user actions`).
> Applied changes move to `CHANGELOG.md`. Per-session logs land in `SESSIONS.md`.
> The full deep-research plan that produced this list lives at `data/brain-data/research/my-github-reconciliation.md`.

**Last updated:** 2026-06-17 (SESSION-2026-06-17-007 — control-plane upgrades continuation on `feat/control-plane-upgrades-continuation`)
**Branch:** `feat/control-plane-upgrades-continuation`
**PR target:** `feat/control-plane-upgrade` → `develop`
**Status:** Implementing follow-up phases from `architecture/plan/2026-06-17-github-control-plane-upgrades-plan.md`. Duplicative fleet-policy applier removed; canonical `scripts/apply-github-policies.py` retained.

---

## Meta control-plane gap closure (Phases 1–9)

Companion plan: `data/brain-data/research/my-github-reconciliation.md` §"meta-gap-closure".

- [x] **Phase 1** — Reusable meta Rust CI, callable semantic PR title, full-clone guard.
- [x] **Phase 2** — Cross-repo dispatch templates (`reusable-notify-parent.yml`, `reusable-notify-downstream.yml`, `reusable-child-update-sync.yml`).
- [x] **Phase 3** — Policy-as-code for this repo (`scripts/apply-github-policies.py`, `.github/policies/*.json`) + labels-as-code (`.github/labels.yml`, `sync-labels.yml`).
- [x] **Phase 4** — Repo onboarding template pack (`docs/templates/repo-onboarding/`) + reusable auto-format.
- [x] **Phase 5** — Security/hermeticity/MCP governance (`mcp-doctor.py`, reusable audit workflows, pinned MCP image).
- [x] **Phase 6** — Handoff/P7 conformance (packet, session log, TODO/CHANGELOG sync).
- [x] **Phase 7** — Secret/Renovate governance.
- [x] **Phase 8** — Rust binary release reusable workflow.
- [x] **Phase 9** — Bookkeeping + stacked PR merge coordination.
- [x] **Phase 10** — Research meta/envctl secret/token wiring (dossier + token-name fixes).

---

## Control-plane upgrade follow-up phases

Companion plan: `architecture/plan/2026-06-17-github-control-plane-upgrades-plan.md`.

- [x] **Phase 1** — Workflow hardening and consistency (dependency-review pin, branch-target guard tracking, wiki-lint PR trigger).
- [ ] **Phase 1.3** — Add `timeout-minutes` to reusable-workflow caller jobs in `ci.yml`. **Blocked by GitHub Actions syntax:** `timeout-minutes` is not permitted on jobs that use `uses:` to call reusable workflows; timeouts live inside the reusable workflows.
- [x] **Phase 2** — Git hooks upgrades (pre-commit JSON check, pre-push protected-ref block, branch-name style, prepare-commit-msg, post-merge, post-checkout warning).
- [x] **Phase 3** — Rules/policies upgrades (squash-merge message controls, commit-message pattern ruleset, CODEOWNERS team, signed tags, retire redundant legacy branch protection — applied live).
- [ ] **Phase 3.4** — Add ruleset `bypass_actors` for the release bot/app (deferred until actor ID/slug is known).
- [x] **Phase 4** — Applier/doctor/test upgrades (schema validation, full ruleset/branch-protection `--check`, `--json` output for all modes, Makefile targets, release-env/CODEOWNERS checks).
- [x] **Phase 5** — Operational/security upgrades (pin remaining actions, CI badges, label pre-creation, runner-availability check in `secrets-rotate.yml`).
- [ ] **Phase 5.5** — Provision `RELEASE_TOKEN`/`PROMOTE_TOKEN` from `meta/envctl` (blocked: vault locked).
- [x] **Phase 6** — Bookkeeping + PR #135 (merged via admin override after resolving develop conflicts).

### Post-merge corrections
- [x] **github-policy-drift strict promotion reverted to REPORT_ONLY** — the default `GITHUB_TOKEN` cannot read branch protection, rulesets, or repo settings. Re-promote after provisioning `POLICY_DRIFT_TOKEN` from `meta/envctl` and confirming one green strict run.

### Deep-review upgrade follow-ups (`architecture/plan/2026-06-17-deep-review-upgrade-plan.md`)
- [x] **2.1** — Make `apply-github-policies.py` `_rule_params_match` symmetric so surplus/removed live rule parameters are detected. Also added the API-injected defaults (`required_reviewers`, `required_review_thread_resolution`, `do_not_enforce_on_create`) to `rulesets.json` and applied live so `--check` is green.
- [x] **2.3** — Reconcile fleet policy templates: verified only the 4 canonical files remain (`rust-canon/{branch-protection,repo-settings,rulesets}.json` + `branch-target-develop/rulesets.json`); `rust-canon/rulesets.json` is the canonical fleet ruleset source, no loose duplicates.
- [x] **2.4** — Deduplicate `apply-fleet-policies.py`/`apply-github-policies.py` — satisfied by the thin fleet wrapper (#162) importing the core applier functions from the canonical `apply-github-policies.py`.
- [x] **4.5** — Defend reusable workflows against script injection: move interpolated `inputs.*` / `github.*` values into `env:` and quote `"$VAR"` in `run:` shells (PR #155).
- [x] **4.8** — Tighten `mcp-doctor.py` `SECRET_RE` to catch AWS access-key IDs (`AKIA…`/`ASIA…`) in addition to GitHub/GitLab/OpenAI tokens; 40-hex SHA false positives remain excluded.
- [ ] **4.9** — Paginate GitHub reads in `apply-*-policies.py` (`list_rulesets`, `check_environments`). **Deferred to token provisioning** — live verification needs `POLICY_DRIFT_TOKEN` (default `GITHUB_TOKEN` cannot read rulesets/environments). See `architecture/plan/2026-06-17-pre-rename-finish-plan.md` Phase 2.

---

## Meta-foundation confirmation (P1–P7)

Companion plan: `data/brain-data/research/my-github-reconciliation.md` §"Phased reconciliation".

- [x] **P1** — Remove retired submodule ghost references from `CONTRIBUTING.md`, `Makefile`, and `manifest-drift.yml`.
- [x] **P2** — Add semantic PR title gate (`.github/workflows/semantic-pr-title.yml`) + local `commit-msg` hook.
- [x] **P3** — Replace Dependabot with Renovate (`renovate.json5`, remove `.github/dependabot.yml`).
- [x] **P4** — Correct docs that falsely describe reusable workflows as "scaffolds" (`README.md`, `RELEASING.md`) and document the release-token operational gate.
- [x] **P5** — Document dual use of `PROMOTE_TOKEN`/`RELEASE_TOKEN` and add `delete-merged-branch.yml` bot.
- [x] **P6** — Refresh `docs/github-automation-roadmap.md` targets to match current state.
- [x] **P7** — Write `.handoff` capsule summarizing confirmed vs deferred foundation work.
- [x] **Policy infrastructure** — Docs-only additive changes still route through `develop`; branch-guard exemptions do not override branch-target policy. Documented in `AGENTS.md`, `CLAUDE.md`, `WORKFLOW.md`, and `architecture/adr/ADR-0003-dev-git-workflow-policy.md`.

---

## GitHub doctor hygiene (TDD loop — closed 2026-06-16)

- [x] **Dependabot → Renovate check in `scripts/github-doctor.py`.** Replaced the stale `Dependabot config` check with a `Renovate config` check that accepts `renovate.json`/`renovate.json5` at repo root or under `.github/`. Added a triple-verify test at `scripts/tests/test-github-doctor.sh` (contract output, no Dependabot residue, offline `make github.doctor`) and a CI job in `manifest-drift.yml` to keep it green.

## CI-failure autofix (follow-on to `ci-failure-tracker.yml`)

> `ci-failure-tracker.yml` is now **LIVE on `main`** (promoted via PR #67): it watches the umbrella's workflows and opens an issue tagged `ci-failure` + `needs-autofix` referencing the failed run + per-job logs whenever CI fails. The autofix loop below consumes those issues.

- [ ] **Autofix failed workflows from `needs-autofix` issues.** Build the loop that picks up an open `ci-failure` issue, fetches the referenced run/job logs, diagnoses the root cause, and opens a fix PR against the failing branch (or comments a diagnosis when the fix needs human judgement). Candidate trigger: `issues` (labeled `needs-autofix`) → dispatch a Claude autofix job; or a scheduled sweep over open `ci-failure` issues. On success the tracker's `resolve` job auto-closes the issue when the workflow next goes green.
  - Gate: do not enable write-mode autofix on `main` until the tracker has run green for ≥1 cycle and the issue-noise/dedupe behaviour is confirmed sane on a feature branch.
  - First create the `ci-failure` + `needs-autofix` repo labels (the tracker assumes they can be applied; `github.rest.issues.create` will create missing labels on first use, but pre-creating them with colors/descriptions is cleaner).

## `.claude/settings.json` hygiene (gated G8 trim — non-required CI red)

> Surfaced SESSION-2026-05-29-015. After the splice repair (#71) settings.json is valid JSON, but the `.claude/settings.json hygiene` doctor + `Trivy filesystem + IaC` (both **non-required**, non-blocking) stay red on pre-existing violations.

- [ ] Remove the 4 hardcoded `/home/` marketplace paths (`ecc`, `karpathy-skills`, `omc`, `understand-anything`) and the forbidden `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` key from tracked `.claude/settings.json`; relocate marketplace defs to user-global `~/.claude/settings.json`. **Gated:** user-environment change — could disable plugin marketplaces for this project. (overlaps the G8 trim item below)

## Pre-adoption dossier review gate (Phase 0 — GATED, human decision)

Companion plan: `~/.claude/plans/sprightly-shimmying-charm.md`. Cross-references the 17-gap plan in `data/brain-data/research/my-github-reconciliation.md`. Each dossier's section 9 gates every irreversible action below.

- [ ] Review `data/brain-data/research/ai-top-utility.md` section 9 — origin is FlexNetOS-owned (G3a exits 0, not 13).
- [ ] Review `data/brain-data/research/n8n.md` section 9 — already forked; sync cadence, local-changes question.
- [ ] Review `data/brain-data/research/fabro.md` section 9 — **go/no-go on `gh repo fork fabro-sh/fabro --org FlexNetOS`** (IRREVERSIBLE).
- [ ] Review `data/brain-data/research/paperclip.md` section 9 — **go/no-go on `gh repo fork paperclipai/paperclip --org FlexNetOS`** (IRREVERSIBLE).

## Adoption execution (GATED on Phase 0; reversibility tooling now exists in `scripts/g3*`)

- [ ] Per `ai-top-utility.md` §6 — convert `repos/ai-top-utility/` → `repos/owned/ai-top-utility/` submodule + MANIFEST entry (OWNED). Use `scripts/g3a-can-convert.sh` → `g3b` → `g3c` then submodule add.
- [ ] Per `n8n.md` §6 — set up `develop` on `FlexNetOS/n8n`, convert to `repos/forked/n8n/` submodule + MANIFEST entry (FORKED).
  - ✓ MANIFEST entry → `branch: develop` + pnpm/docker toolchain + notes (SESSION-2026-05-29-005).
  - ✓ Build verified healthy; all §10 dossier decisions resolved.
  - blocked by: UA-2026-05-29-003 (develop-branch push + submodule conversion; needs human `git push`).
- [ ] Per `fabro.md` §6 (gated by §9 + explicit user OK) — fork, set up develop, convert to `repos/forked/fabro/` + MANIFEST entry.
- [ ] Per `paperclip.md` §6 (gated by §9 + explicit user OK) — fork, set up develop, convert to `repos/forked/paperclip/` + MANIFEST entry.
  - ✓ Full dossier complete (Phases 1–3 verified; SESSION-2026-05-29-009).
  - ✓ Local setup: `repos/paperclip feat/local-setup` — pnpm install, build, dev server, AGENTS.md hierarchy.
  - Fork explicitly **deferred** by user (§10: "No go" as of 2026-05-29). Revisit when priority resolved vs. fabro.
  - blocked by: user go/no-go decision.

## Per-fork org-only setup (Phase B/C/D — once each fork exists, on `develop`)

- [ ] `.github/CODEOWNERS`: add `* @FlexNetOS/maintainers`.
- [ ] `.github/FUNDING.yml`: copy from umbrella.
- [ ] `.github/FLEXNETOS-ENV.md`: pointer to umbrella `secrets/envs/dev.env.tmpl` + `direnv allow`.
- [ ] `.github/workflows/ci.yml`: thin caller using umbrella reusable workflows.
- [ ] Branch protection on mirror branch (`main`/`master`): linear history, block direct pushes.
- [ ] Branch protection on `develop`: PR + 1 review.

**Out of scope (would break upstream sync):** internal package renames, Docker image refs, README badges, upstream-authored docs.

## MANIFEST ↔ `.gitmodules` reconciliation (P4 closure, Option B lockfile) — DEFERRED

> Deferred from the additive pass: this refactors the **working** `submodules.*` machinery, so it is not additive. Tracked as **G4/G5 in `.omc/plans/open-questions.md`**. Decide the open question before starting.

- [ ] Author `scripts/materialize-gitmodules.sh` (deterministic; `--check`/`--write`/stdout).
- [ ] Extend `repos/MANIFEST.yaml` with optional `shallow:` field (S4 content-equivalence).
- [ ] Move `tools/{cpython,actionlint,gitleaks,trivy,node,bun,uv}` + `network/slim` into MANIFEST with `groups: [build-tooling] shallow: true`.
- [ ] Rewrite `make submodules.add` to go MANIFEST → `materialize --write` → `submodule init && update` (no raw `git submodule add`); add guardrail `grep -rn 'git submodule add' scripts/ Makefile | grep -v materialize` returns empty.
- [ ] Add `make submodules.materialize-resolve` (S5) and `make submodules.init GROUP=<name>` (G17).
- [ ] Flip the `submodules-materialize-noop` job in `manifest-drift.yml` from placeholder to a real check once the pattern lands.

## USER.TODO#5 sequencing (detector DONE; branch targets set)

- [ ] **CRITICAL:** No `gh repo fork ... --org FlexNetOS` until the original-side cleanup is verified per-fork. See memory `feedback-fork-after-original-setup`.
  - Dirty diffs captured at `data/brain-data/research/fork-remediation/` (SESSION-2026-05-28-006). Next step per `/clone-setup`: `make research.pack URL=<upstream>` for each repo — gated on UA-2026-05-28-005 (`gh auth login`). (SESSION-2026-05-28-007)

## n8n + n8n-mcp service persistence

- [ ] **n8n and n8n-mcp are running as unmanaged background processes** — both die on reboot. Create systemd user units (or pm2 config) so they auto-start. n8n: `node packages/cli/bin/n8n start` via dotenvx from `repos/n8n/`. n8n-mcp: `node dist/mcp/index.js` from `repos/n8n/mcp/n8n-mcp/` with env from `.env`.
- [ ] **n8n-mcp `.env` is not pass-managed** — `AUTH_TOKEN` and `N8N_API_KEY` are plaintext in `repos/n8n/mcp/n8n-mcp/.env` (gitignored). Consider wiring via `direnv` + `pass` after UA-2026-05-29-003 (n8n submodule conversion) lands.

## Reservations (carry-forward)

1. ✅ **6+ scripts now built** (SESSION-005): `claude-settings-doctor.js`, `g3a/g3b/g3c-*.sh`, `reconcile-stray-clones.sh`, `check-user-todo-step5.sh`, `open-questions-lint.js`, extended `runner-doctor.sh`. (Materialize/lockfile script remains deferred — see open-questions.)
2. **2 of 4 stray clones halt at G3a UNSAFE-MISMATCH** — `fabro` (`fabro-sh/fabro`), `paperclip` (`paperclipai/paperclip`). `ai-top-utility` is FlexNetOS-owned (exits 0). Each halting clone needs manual operator triage; cannot be automated without violating P5.
3. **6 local-only unmerged branches retained** (SESSION-2026-05-29-015) — real in-flight work with no PRs, kept during branch cleanup: `feat/ci-autofix-claude` (github-agentic-os runner), `feat/github-agentic-os-runner`, `feat/github-automation-doctor`, `docs/root-claude-md`, `fix/pr24-settings-json`, `fix/architecture-crosslinks`. Open PRs when ready; recoverable from the all-refs backup bundle either way.

## Out of scope (deferred per ralplan)

- USER.TODO#5 itself (upstream operator task; gated).
- `.github/copilot-instructions.md` path audit.
- Toolchain version bumps.
- GitHub App automation refactor (recent commits stable).
- `v1.0.0` tag cut (USER.TODO step 10).
