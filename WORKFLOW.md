# WORKFLOW.md — how work flows from task to release

> **Canon:** [`architecture/adr/ADR-0003`](architecture/adr/ADR-0003-dev-git-workflow-policy.md).
> This file is the scannable quick-reference; the ADR is authoritative.

## The one-liner

`develop` is the **trunk**. `main` is the **protected release mirror**. You never touch `main`
directly — it advances only via the automated `develop → main` promotion.

```text
task → worktree off origin/develop → feat/<slug> → PR into develop → CI green → squash-merge
     → promote-develop-to-main (auto, separate identity, rebase) → main → release-please
```

## Branch model

| Branch | Role | Who advances it | Lifetime |
|---|---|---|---|
| `develop` | integration **trunk** — feature PRs land here | feature PRs (squash) | permanent |
| `main` | protected **release mirror** | **only** `promote-develop-to-main.yml` | permanent |
| `master` (forks only) | pristine upstream mirror | upstream sync | permanent |
| `<type>/<slug>` | one task | you | **deleted on merge** |
| renovate/* | dep bumps | renovate[bot] | deleted on merge |

No `staging` branch — `develop` is staging, `main` is release.

## Branch protection (live)

**Both `develop` and `main` require 1 approval** + these 6 required checks: `lint / Lint (mixed)`,
`actionlint .github/workflows`, `markdownlint`, `Validate manifests`, `Hermetic dependency audit`,
`security / Gitleaks secret scan`. (`Trivy`, the `.claude/settings.json` doctor, and Claude review
are **advisory** — not required, don't block merge.) `enforce_admins:false` on both.

Neither branch is review-free. **The agent author never approves or admin-merges its own PR.** The
approval/merge is supplied by a *separate* principal: `PROMOTE_TOKEN` for `develop→main`; the
GitHub App (via envctl) or the owner for `feature→develop`; `RELEASE_TOKEN` for release-please cuts.
You may *arm* auto-merge; a separate principal supplies the approval that releases it.

## The ten answers (full rationale in ADR-0003)

| # | Question | Answer |
|---|---|---|
| 1 | Where is develop work done? | On `develop`, via feature branches cut **off `develop`**. (Forks: work on `develop`, `main`/`master` mirrors upstream.) |
| 2 | Clones / forks / branches / worktrees / staging policy | Full clones only; **don't clone repos not on disk → handoff loop**. Fork only after research-before-fork. Trunk=`develop`, protected=`main`. Feature=`<type>/<slug>` off `develop`. Worktree per task off `origin/develop`. **No staging branch.** |
| 3 | How do PRs move through Actions? | PR→`develop`: `ci.yml` runs; 6 required checks green **+ 1 approval from a separate principal** → squash auto-merge. Then `promote-develop-to-main` auto-promotes to `main` (rebase, `PROMOTE_TOKEN`). Merge to `main` → `release.yml` (automatic once `RELEASE_TOKEN` is wired). Merged feature branches are cleaned up by `delete-merged-branch.yml`. |
| 4 | What happens on failure? | PR goes `BLOCKED`; auto-merge waits. `ci-failure-tracker.yml` opens a `needs-autofix` issue; auto-closes on next green. |
| 5 | How do failures flow back to a session? | `needs-autofix` issue → handoff loop claims → session fixes on a feature branch → green → auto-close + auto-merge. |
| 6 | Tasks per commit? | **≤ 1** — one revertible unit, one Conventional Commit. |
| 7 | Commits per PR? | One **task** per PR; squash-merges to **1 commit on `develop`**. Promote PR is the machine batch. |
| 8 | PRs per repo? | 1 standing promote PR + 1 standing release PR + 0..N short-lived feature PRs (one per active task). |
| 9 | Tasks per worktree? | **Exactly 1** (1 task : 1 branch : 1 worktree). |
| 10 | Worktrees/branches reusable? | No — feature branches + worktrees are ephemeral, deleted on merge. `develop`/`main`/`master` are permanent. |

## Day-to-day (the happy path)

```bash
# 1. start a task off the trunk (never on main)
git fetch origin
git switch -c feat/<slug> origin/develop      # or: meta git worktree / Agent isolation: worktree

# 2. work, committing as you go — one task, Conventional Commits
git commit -m "feat(scope): <imperative summary>"

# 3. push + open PR INTO develop (not main) + arm auto-merge
git push -u origin feat/<slug>
gh pr create --base develop --fill
gh pr merge --auto --squash --delete-branch   # arms it; a SEPARATE principal supplies the approval

# 4. if a required check goes red: read it, fix on the same branch, re-push
gh pr checks
# 5. 6 required checks green + 1 approval (separate principal: App via envctl / owner)
#    -> squash-merges to develop -> promote-develop-to-main carries it to main automatically
```

## Hard rules

- **Never** open a PR with base `main`, and never commit to `main`/`master` directly. `main`
  advances only via `promote-develop-to-main.yml`.
- **One task per branch / PR / worktree.** No mega-PRs (the #102 anti-pattern).
- **Don't approve or admin-merge your own PR on either protected branch** (`develop` *and* `main`
  require 1 approval). A separate principal approves: `PROMOTE_TOKEN` for `develop→main`; the
  GitHub App (via envctl) or the owner for `feature→develop`; `RELEASE_TOKEN` lets release-please
  open release PRs and cut tags. You may arm auto-merge.
- **Don't clone a repo that isn't already on disk** — route adoption to the handoff loop.
- Conventional Commits always (release-please computes bumps from them).
