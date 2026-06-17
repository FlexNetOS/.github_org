# GitHub automation roadmap

This is the queue for turning `FlexNetOS/.github` into the org's reusable GitHub control plane. The rule is small, safe, stacked PRs: each pass adds one verified automation layer, then hands off the next target.

## In flight

| Branch | Purpose | Base | Status |
| --- | --- | --- | --- |
| `feat/control-plane-upgrade` | Systematic upgrade of workflows, hooks, branch protection, rulesets, Renovate, and repo settings | `develop` | open |

## Recently landed

| Surface | What it does | Location |
| --- | --- | --- |
| `.handoff` continuity layer | Capsule, README, migration packet for meta-conformity | `.handoff/` |
| Trivy false-positive suppression | Allow-rule for research repomix archives + contract test | `trivy-secret.yaml`, `scripts/tests/test-trivy-secret-suppressions.sh` |
| Claude settings hygiene | Removed forbidden env key and hardcoded `/home/` marketplace paths | `.claude/settings.json` |
| Semantic PR/commit gate | Validates PR titles and local commits against Conventional Commits | `.github/workflows/semantic-pr-title.yml`, `.githooks/commit-msg` |
| Renovate automation | Dependency updates grouped by ecosystem, dashboard-approved | `renovate.json` |
| Branch promotion | Perpetual `develop → main` promote PR with separate-identity auto-approval | `.github/workflows/promote-develop-to-main.yml` |
| Release wiring | `release.yml` wired to `RELEASE_TOKEN` with automatic `push: main` trigger | `.github/workflows/release.yml`, `.github/workflows/reusable-release.yml` |
| Merged-branch cleanup | Deletes feature-branch heads after merge while preserving protected/upgrade branches | `.github/workflows/delete-merged-branch.yml` |
| CI failure tracker | Opens `ci-failure`/`needs-autofix` issues on watched workflow failures | `.github/workflows/ci-failure-tracker.yml` |

## Definition of done

The GitHub process is fully automated when a maintainer can run a local doctor, see every missing GitHub control-plane surface, and activate each layer from documented dry-run-first scripts without committing secrets or mutating the host by surprise.

- [x] One-command local doctor for runner, workflows, GitHub App, submodules, secrets, policy, releases, and live GitHub status.
- [x] Local/self-hosted runner install/register/remove/status path with dry-run-first safety.
- [x] Reusable workflow templates and caller examples for lint, test, build, typecheck, security, secrets, submodules, and release.
- [x] GitHub App manifest template, permission matrix, private-key storage guidance, and installation-token smoke test.
- [ ] Subrepo/submodule graph validation against `repos/MANIFEST.yaml`, `.gitmodules`, and live GitHub remotes.
- [ ] Vaultwarden/Bitwarden secret sync and rotation docs with no committed secret values or real local mapping file.
- [x] Branch/ruleset/CODEOWNERS/community-health audit path (policy-as-code in `.github/policies/`, `scripts/apply-github-policies.py`).
- [x] Renovate, release, and security automation checks documented and locally verifiable.
- [x] Manual activation points are explicit for any step needing GitHub admin permissions, runner registration tokens, private keys, or host service changes.
- [x] Active work is represented as focused PRs with CI/check status monitored.

## Ralph phases

### Phase 1 — Baseline and doctor

Status: **done** (CI gating deferred until expected surfaces stabilize).

Deliverables:

- [x] `docs/github-automation-roadmap.md` queue.
- [x] `scripts/github-doctor.py` read-only offline/live/JSON/strict doctor.
- [x] `make github.doctor` entry point.
- [ ] `make github.doctor STRICT=1` or equivalent gating in CI once expected surfaces are present.

Acceptance:

- The doctor runs without secrets.
- Live GitHub checks are optional and degrade to warnings when `gh` is unavailable.
- Missing surfaces are reported as action items, not silently ignored.

### Phase 2 — Local runner lifecycle

Status: **done**.

Existing surfaces:

- `runner/install.sh`
- `runner/register.sh`
- `runner/ephemeral-spawn.sh`
- `runner/systemd/runner-spawn@.service`
- `runner/systemd/runner-spawn@.timer`
- `docs/self-hosted-runner.md`

Deliverables:

- [x] Add `runner/.env.example` with labels, runner directory, scope, service mode, and dry-run defaults.
- [x] Add `scripts/runner-doctor.sh` or fold deeper runner checks into `scripts/github-doctor.py`.
- [x] Add `runner.remove` / `runner.doctor` Make targets.
- [x] Confirm install/register scripts refuse destructive or host-mutating actions unless explicit flags are set.

Acceptance:

- Registration tokens are fetched live and never stored in git.
- Default mode is dry-run/read-only.
- Untrusted fork PRs cannot land on local runners by default.

### Phase 3 — Reusable workflows

Status: **present**.

Existing surfaces include reusable lint, test, build, typecheck, security, release, secrets, and submodule workflows under `.github/workflows/`, plus `auto-review-merge.yml`, `promote-develop-to-main.yml`, `ci-failure-tracker.yml`, `semantic-pr-title.yml`, and `delete-merged-branch.yml`.

Next deliverables:

- [x] Add caller examples for normal repos, submodule repos, and secrets-aware repos.
- [x] Add concurrency cancellation and job timeouts to caller workflows.
- [x] Add branch-target guard for `main`.
- [x] Run dependency review on PRs to `develop` as well as `main`.
- [ ] Add a workflow permission matrix documenting required `permissions:` and secrets per reusable workflow.
- [ ] Add local `act --list` guidance or a repo-local wrapper that never requires secrets by default.
- [x] Run CI on stacked PR branches (`branches: ['**']`) so every PR layer reports checks.
- [x] Add same-repo upgrade-only auto-review/auto-merge gating that never checks out PR code.
- [x] Add semantic PR title validation and local commit-message hook.

### Workflow permission matrix

| Workflow | `contents` | `pull-requests` | `issues` | `id-token` | `actions` | Secrets / notes |
| --- | --- | --- | --- | --- | --- | --- |
| `ci.yml` | read | — | — | — | — | none (uses reusable workflows) |
| `manifest-drift.yml` | read | write | — | — | — | none (report-only comments) |
| `claude-code-review.yml` | read | read | read | **write** | — | `CLAUDE_CODE_OAUTH_TOKEN` (OIDC exchange, sourced from `meta/envctl`) |
| `release.yml` | write | write | — | — | — | `RELEASE_TOKEN` (from `meta/envctl`) |
| `promote-develop-to-main.yml` | write | write | — | — | — | `PROMOTE_TOKEN` (from `meta/envctl`) |
| `ci-failure-tracker.yml` | read | write | write | — | — | none (default `GITHUB_TOKEN`) |
| `dependency-review.yml` | read | — | — | — | — | none |
| `security.yml` / reusable | read | — | — | — | — | none (SARIF upload uses built-in `github/codeql-action`) |

Notes:
- `id-token: write` is only requested when an action performs an OIDC exchange (currently `claude-code-review.yml`). The token audience is `github.com/anthropics/claude-code-action` and the `sub` claim is `repo:FlexNetOS/.github:pull_request`.
- Release/promote tokens are **not** stored in this repo; `meta/envctl` injects them as repository/org secrets.

Acceptance:

- Every reusable workflow has explicit permissions.
- Caller examples use GitHub-hosted runners unless they intentionally request the local label set.
- Secrets are named consistently with `secrets/github-secrets.tsv.example`.

### Phase 4 — GitHub App automation

Status: **materialized**.

Existing surfaces:

- `github-app/manifest.example.json`
- `github-app/permissions.md`
- `scripts/github-app-token-smoke.py`
- `docs/templates/github-app/token-smoke.md`
- `make github-app.smoke`

Deliverables:

- [x] Add `github-app/manifest.example.json`.
- [x] Add `github-app/permissions.md` least-privilege matrix.
- [x] Add `scripts/github-app-token-smoke.py` that reads env vars, signs a JWT, requests an installation token, masks output, and fails closed without secrets.
- [x] Document Vaultwarden storage for the app private key and webhook secret.
- [ ] Add workflow examples that consume an app-derived token only on trusted paths.

Acceptance:

- No real private key, app ID, installation ID, client secret, or webhook secret is committed.
- App permissions are separated by task class: read-only audit, PR automation, workflow dispatch, repository administration.

### Phase 5 — Subrepo/submodule graph

Status: **partially present**. External repos moved to typed hubs and `~/Desktop/pending_relocate` per ADR-0002; `repos/MANIFEST.yaml` is now an offload stub. Only `data/brain-data/*` gitlinks remain in this repo.

Existing surfaces:

- `repos/MANIFEST.yaml`
- submodule helper scripts (retained for `data/brain-data`)
- `manifest-drift.yml` (retired repo/tool submodule checks; still validates the manifest stub)

Next deliverables:

- [ ] Add a live remote audit that compares manifest URLs to GitHub API results.
- [ ] Add a `.gitmodules` drift check (only relevant for `data/brain-data` gitlinks).
- [ ] Add docs for adding/removing/updating owned, forked, and external subrepos in typed hubs.

Acceptance:

- Nested source trees are either registered submodules or ignored until canonicalized.
- `make verify` catches manifest shape and submodule drift.

### Phase 6 — Secrets and policy sync

Status: **partially present**.

Existing surfaces:

- `scripts/secrets-sync-github-from-bitwarden.sh`
- `secrets/github-secrets.tsv.example`
- `secrets/README.md`
- `.gitignore` rule for the real local mapping file
- `.github/policies/` policy-as-code specs
- `scripts/apply-github-policies.py` dry-run-first applier

Next deliverables:

- [ ] Add dry-run CI smoke test with stubbed `bw` and `gh`.
- [x] Add branch protection/ruleset/CODEOWNERS audit script.
- [ ] Document secret rotation from Vaultwarden through GitHub repo/env/org secrets.
- [x] Wire `RELEASE_TOKEN` repo secret and enable automatic `release.yml` triggers.

Acceptance:

- Real mapping file remains private.
- Scripts never print cleartext secret values.
- Policy/ruleset changes are audited before enforcement.

### Phase 7 — Full control-plane loop

Status: **planned**.

Next deliverables:

- [ ] Promote `make github.doctor` into the top-level operator command.
- [ ] Add a generated or documented report section for each control-plane area.
- [ ] Add recovery playbooks for failed runner registration, failed workflow dispatch, failed GitHub App token exchange, submodule drift, and stale secrets.

Acceptance:

- A maintainer can identify the next safe action from one local command.
- Non-dry-run actions require explicit flags and state exactly what they will change.
