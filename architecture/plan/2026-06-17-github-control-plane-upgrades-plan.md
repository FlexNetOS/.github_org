# Plan: Implement GitHub control-plane upgrades

**Date:** 2026-06-17  
**Session:** SESSION-2026-06-17-007  
**Branch:** `feat/control-plane-upgrades` (cut from `develop`)  
**PR target:** `develop`  
**Related:** PR #116 (control-plane upgrade Phases 0–8), `data/brain-data/research/my-github-reconciliation.md`

## Context

The systematic control-plane upgrade (Phases 0–8) is committed and live. A subsequent gap-search pass found additional upgrade opportunities across workflows, hooks, rules/policies, and operational tooling. This plan records how to implement them safely.

## Constraints

- **Meta repo ownership:** `FlexNetOS/.github` (this repo) owns GitHub-specific settings, toolchains, configs, workflows, hooks, and policy-as-code. All changes to those surfaces land here.
- **User-global is a symlink:** `~/.claude/settings.json`, `~/.mcp.json`, and similar user-global files are **symlinks** into the canonical tree. The canonical files live in the meta/envctl repo (`~/Desktop/meta/envctl/home/`). Do not edit `~` directly; edit the canonical file and re-link.
- **Secrets and environment live in `meta/envctl`:** Runtime secrets (`RELEASE_TOKEN`, `PROMOTE_TOKEN`, `CLAUDE_CODE_OAUTH_TOKEN`, etc.) are stored in `meta/envctl`'s secrets engine (or the legacy `pass` vault in `secrets/store/` while reconciliation is in progress). Workflows reference them only via `${{ secrets.* }}` or envctl injection. No secret literals are committed.
- **Branch discipline:** all implementation work is on a feature branch off `develop`; no direct edits to `main`/`develop`/`trunk`.

## Phase 1 — Workflow hardening and consistency

**Goal:** close supply-chain, observability, and trigger gaps identified in the gap search.

### Tasks

1. **Add `branch-target-guard` to `ci-failure-tracker.yml` watch list.**
   - File: `.github/workflows/ci-failure-tracker.yml`
   - Change: add `Branch Target Guard` to the `workflows:` list under `workflow_run`.
   - Rationale: newly introduced required check must be tracked like the others.

2. **Pin `actions/dependency-review-action` to a SHA digest.**
   - File: `.github/workflows/dependency-review.yml`
   - Change: replace `@v5` with a pinned SHA comment.
   - Rationale: aligns with the repo's supply-chain policy; Renovate will keep it updated.

3. **Add `timeout-minutes` to caller jobs in `ci.yml`.**
   - File: `.github/workflows/ci.yml`
   - Change: add `timeout-minutes` to the `lint` and `security` caller jobs (defense in depth even though reusable workflows have timeouts).

4. **Add workflow-level permissions and scope to `claude-code-review.yml`.**
   - File: `.github/workflows/claude-code-review.yml`
   - Change: move `permissions` to workflow level, restrict to non-draft PRs, and add `paths` once the repo has non-docs code.
   - Rationale: the workflow requests `id-token: write`; its trust surface should be explicit.

5. **Filter `delete-merged-branch.yml` trigger by base branch.**
   - File: `.github/workflows/delete-merged-branch.yml`
   - Change: add `branches: [main, develop]` under `on: pull_request:`.
   - Rationale: avoids running on PRs closed against feature branches where deletion is irrelevant.

6. **Add `paths` trigger to `wiki-lint.yml` for PRs.**
   - File: `.github/workflows/wiki-lint.yml`
   - Change: add `on: pull_request: paths: ['wiki/**']`.
   - Rationale: lint wiki changes before merge, not just nightly.

7. **Promote `github-policy-drift` from REPORT_ONLY to STRICT.**
   - File: `.github/workflows/manifest-drift.yml`, `.github/workflows/promote-strict.md`
   - Change: remove `continue-on-error: true` from `github-policy-drift` after it runs green on one PR cycle; record promotion in `promote-strict.md`.
   - Caveat: may require a PAT with `administration: read` if the default `GITHUB_TOKEN` cannot read branch protection/rulesets. The PAT must be sourced from `meta/envctl` and injected as a repo secret (e.g., `POLICY_DRIFT_TOKEN`).

### Verification

- `tools/bin/actionlint .github/workflows/*.yml` passes.
- `make verify` passes.
- A test PR shows all expected checks, including `Branch Target Guard`, are required and reported.

---

## Phase 2 — Git hooks upgrades

**Goal:** extend local guards to catch policy drift and malformed config before push.

### Tasks

1. **Add policy JSON syntax check to `pre-commit`.**
   - File: `.githooks/pre-commit`
   - Change: validate `.github/policies/*.json` with `python3 -m json.tool` before commit.
   - Rationale: malformed policy JSON must not reach `develop`.

2. **Block direct pushes to `develop` in `pre-push`.**
   - File: `.githooks/pre-push`
   - Change: add `refs/heads/develop` to the protected ref blocklist.
   - Rationale: the branch-target policy requires all changes via PR, including to `develop`.

3. **Add branch-name style check to `pre-push`.**
   - File: `.githooks/pre-push`
   - Change: warn or block branch names that do not match `type/short-slug` convention.
   - Rationale: enforces Conventional Commit/branch naming consistency.

4. **Add `prepare-commit-msg` hook (new).**
   - File: `.githooks/prepare-commit-msg`
   - Change: if the commit message is empty/default, prepend the Conventional Commit prefix inferred from the branch name (e.g., `feat/...` → `feat(...): `).
   - Rationale: defense in depth when `commit-msg` hook is bypassed.

5. **Add `post-merge` hook (new).**
   - File: `.githooks/post-merge`
   - Change: run `make verify` after merges from `origin/main` or `origin/develop`.
   - Rationale: catches upstream-side regressions immediately after pull/merge.

6. **Warn on uncommitted changes in `post-checkout`.**
   - File: `.githooks/post-checkout`
   - Change: if landing on a protected branch with uncommitted changes, emit a stronger warning.

### Verification

- `make install-hooks` configures the new hooks.
- Test each hook path manually on a scratch branch.
- `make verify` still passes.

---

## Phase 3 — Rules, policies, and branch protection

**Goal:** harden server-side rules and align `CODEOWNERS` with the policy engine.

### Tasks

1. **Add squash-merge message controls to repo settings.**
   - File: `.github/policies/repo-settings.json`
   - Change: add `squash_merge_commit_title` and `squash_merge_commit_message` set to `PR_TITLE` / `PR_BODY`.
   - Rationale: standardizes squash commits for release-please.

2. **Add `required_signatures` or `commit_message_pattern` to rulesets.**
   - File: `.github/policies/rulesets.json`
   - Change: add a `commit_message_pattern` rule enforcing Conventional Commits on `main` and `develop`.
   - Rationale: server-side enforcement complements local hooks.

3. **Create/repoint `CODEOWNERS` to a writable team and enable code-owner review.**
   - File: `.github/CODEOWNERS`
   - Files: `.github/policies/branch-protection.json`, `.github/policies/rulesets.json`
   - Change: create or confirm `@FlexNetOS/maintainers` exists, update `CODEOWNERS` to use it, then flip `require_code_owner_reviews` / `require_code_owner_review` to `true`.
   - Caveat: requires org-level team management; coordinate with envctl if team membership is controlled there.

4. **Add bypass actors to rulesets.**
   - File: `.github/policies/rulesets.json`
   - Change: add a `bypass_actors` entry for the release bot/app with `bypass_mode: pull_request`.
   - Rationale: emergency hotfixes can flow without disabling rulesets.

5. **Harden tag ruleset.**
   - File: `.github/policies/rulesets.json`
   - Change: add `required_signatures` to `protect-release-tags`.
   - Rationale: release tags should be signed.

6. **Plan retirement of legacy branch protection.**
   - File: `.github/policies/branch-protection.json`
   - Change: once rulesets are proven for one release cycle, remove the redundant legacy branch protection entries for `main`/`develop` and keep only settings not expressible in rulesets.
   - Rationale: avoids dual enforcement and confusion.

### Verification

- `python3 scripts/apply-github-policies.py --dry-run` shows expected changes.
- `python3 scripts/apply-github-policies.py --apply` succeeds.
- `python3 scripts/apply-github-policies.py --check` reports no drift.

---

## Phase 4 — Policy applier / doctor / test upgrades

**Goal:** make the policy toolchain self-checking and CI-friendly.

### Tasks

1. **Add lightweight schema validation to `apply-github-policies.py`.**
   - File: `scripts/apply-github-policies.py`
   - Change: before apply/dry-run/check, validate that each ruleset rule has the required keys (`type`, and `parameters` when required).
   - Rationale: fail fast on malformed policy files.

2. **Extend `--check` to compare full ruleset payloads.**
   - File: `scripts/apply-github-policies.py`
   - Change: fetch each ruleset and compare its rules/conditions against the committed spec (not just names).
   - Rationale: detects manual UI edits or partial applies.

3. **Extend `--check` to compare branch protection details.**
   - File: `scripts/apply-github-policies.py`
   - Change: compare `required_linear_history`, review count, `dismiss_stale_reviews`, etc.

4. **Add `--json` output mode to the applier.**
   - File: `scripts/apply-github-policies.py`
   - Change: optional machine-readable output for CI summary / PR comment.

5. **Add `github.policy.apply` and `github.policy.check` Makefile targets.**
   - File: `Makefile`
   - Change: add convenience targets wrapping the Python script.

6. **Extend `github-doctor.py` checks.**
   - File: `scripts/github-doctor.py`
   - Change: add checks for `release` environment deployment policy and `CODEOWNERS` team validity.

7. **Add schema stage to `test-github-policies.sh`.**
   - File: `scripts/tests/test-github-policies.sh`
   - Change: Stage 0 validates policy JSON structure before parse.

### Verification

- `bash scripts/tests/test-github-policies.sh` passes.
- `python3 scripts/github-doctor.py` reports new checks OK.
- `make verify` passes.

---

## Phase 5 — Operational / security upgrades

**Goal:** close supply-chain, secret-management, and visibility gaps.

### Tasks

1. **Pin remaining unpinned third-party actions.**
   - Files: all `.github/workflows/*.yml`
   - Change: find actions still using moving tags (`@v5`, `@v6`, `@latest`) and pin to SHA digests.
   - Rationale: supply-chain hardening.

2. **Document OIDC trust policy for `claude-code-review.yml`.**
   - File: `.github/workflows/claude-code-review.yml`, `docs/github-automation-roadmap.md`
   - Change: document why `id-token: write` is requested and the intended token audience.

3. **Add CI badges to `README.md`.**
   - File: `README.md`
   - Change: add badges for `ci`, `manifest-drift`, and `promote-develop-to-main`.

4. **Pre-create `ci-failure` and `needs-autofix` labels.**
   - One-time action: use `gh label create` (or include a labels-as-code file).
   - Rationale: avoids lazy label creation with default colors.

5. **Ensure `RELEASE_TOKEN` and `PROMOTE_TOKEN` are sourced from `meta/envctl`.**
   - Files: `.github/workflows/release.yml`, `.github/workflows/promote-develop-to-main.yml`
   - Change: confirm secrets are registered in `meta/envctl` and injected as repo/org secrets. Document the secret names and rotation schedule.

6. **Add runner availability check to `secrets-rotate.yml`.**
   - File: `.github/workflows/secrets-rotate.yml`
   - Change: fail loudly (not silently) if the self-hosted runner labels are unavailable.

7. **Add `CODE_OF_CONDUCT.md` / `SECURITY.md` policy check (optional).**
   - File: `scripts/github-doctor.py`
   - Change: verify org-wide health files exist.

### Verification

- `make verify` passes.
- `python3 scripts/github-doctor.py` passes.
- All workflows have pinned actions.

---

## Phase 6 — Bookkeeping and PR

### Tasks

1. Update `TODO.md` to track each phase.
2. Update `CHANGELOG.md` under `[Unreleased]`.
3. Update `SESSIONS.md` with a new session entry.
4. Update `.github/workflows/promote-strict.md` when `github-policy-drift` is promoted.
5. Open PR to `develop`.

---

## Suggested execution order

The phases are designed to be mostly independent, but the safest order is:

1. Phase 1 (workflow fixes)
2. Phase 4 (applier/doctor improvements) — do this before Phase 3 so the extended `--check` validates the policy changes.
3. Phase 3 (rules/policies)
4. Phase 2 (hooks)
5. Phase 5 (operational/security)
6. Phase 6 (bookkeeping + PR)

Phases 1, 2, 4, and 5 can be done in parallel if desired because they touch disjoint files.

---

## Rollback

- All changes are in this repo; rollback is `git revert` on the feature branch or `git reset` before merge.
- Live GitHub policy changes applied via `apply-github-policies.py` are reversible by reverting the JSON file and re-running `--apply`.
- `meta/envctl` secrets are not modified by this plan; only workflow references to existing secrets are added.

---

## Dependencies outside this repo

- `meta/envctl` (`~/Desktop/meta/envctl`, origin `FlexNetOS/envctl`) is the source of truth for secrets and user-global config. Any new PAT needed for `github-policy-drift` must be minted there and injected as a repo/org secret.
- Org-level team `@FlexNetOS/maintainers` must exist before `CODEOWNERS` can be repointed.
