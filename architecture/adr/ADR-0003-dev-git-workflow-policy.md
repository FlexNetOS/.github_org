# ADR-0003 — Development & Git Workflow Policy (trunk = `develop`, protected mirror = `main`)

- **Status:** accepted
- **Date:** 2026-06-14
- **Deciders:** owner (FlexNetOS), `.github_org` session
- **Supersedes / clarifies:** the "Branch off `main`" wording in `CLAUDE.md`, `AGENTS.md`,
  `CONTRIBUTING.md` (pre-trunk model)
- **Relates to:** [ADR-0002](ADR-0002-lean-github-org-relocate-to-hubs.md) (lean `.github_org`),
  the fleet handoff/ledger ADR series (ADR-0004 single FLEET ledger), envctl ADR-0006
- **Namespace note:** this is the **`.github_org`-local** ADR series
  (`architecture/adr/ADR-000N`). It is distinct from the meta-fleet ADR series (the
  `ADR-0001 gh-aw` / `ADR-0004 ledger` / `ADR-0006 envctl` referenced elsewhere live in their
  own repos). Numbers collide across namespaces by design; cite the repo when in doubt.

## Context

The owner stopped a brute-force attempt to land PR `.github#102` and named the real issue:
**the development / pull-request workflow was never written down.** #102 is the symptom — a
long-lived `research/*` branch that bundled many unrelated tasks (architecture ingestion +
ADR-0002 lean restructuring + ICM dump + CI SHA-pinning) into one mega-PR **targeting the
protected `main` branch directly**, which then deadlocked on a review the authoring agent cannot
self-supply (separation-of-privilege), while also being **RED** on real required checks.

The owner posed ten questions that this ADR defines and answers (see **Decision**).

### Ground truth at decision time (cited, not aspirational)

- **Branches exist:** `main` (protected trunk-of-record), `develop` (integration trunk),
  feature branches `<type>/<slug>`, renovate branches. `develop` and `main` had **diverged
  `4/15`** (`git rev-list --left-right --count origin/main...origin/develop`) — the trunk and the
  protected mirror drifted apart, a direct symptom of the undefined flow.
- **A trunk model already exists in code but was undocumented:**
  - `.github/workflows/promote-develop-to-main.yml` — on `ci` success on `develop`, maintains a
    perpetual `develop → main` promote PR, **auto-approves with `PROMOTE_TOKEN`** (a *separate*
    actor → GitHub permits the approval; this is the separation-of-privilege seam), and
    **rebase** auto-merges to preserve each Conventional Commit for release-please.
  - `.github/workflows/auto-review-merge.yml` — arms `gh pr merge --auto --squash` for eligible
    PRs; never checks out PR code (`pull_request_target` + `github-script`); forks always blocked.
  - `.github/workflows/ci.yml` — runs on **all** branches and **all** PR bases: `lint`,
    `manifest-validate`, `actionlint`, `markdownlint`, `hermetic-audit` (advisory), `security`
    (CodeQL + Trivy + Gitleaks).
  - `.github/workflows/ci-failure-tracker.yml` — on any watched-workflow failure, opens/updates a
    tracking issue labeled `ci-failure` + `needs-autofix`; auto-closes it on the next green run.
    **This is the existing failure → flowback signal.**
  - `.github/workflows/release.yml` + `reusable-release.yml` — release-please; **manual-dispatch
    only** until the org-level `RELEASE_TOKEN` (App/PAT via envctl) is wired.
  - `.github/workflows/delete-merged-branch.yml` — cleans up merged feature-branch heads while
    preserving protected branches and automated upgrade branches.
  - `.github/workflows/claude-code-review.yml` / `claude.yml` — Claude PR review + `@claude`.
- **Docs said the older model:** `CONTRIBUTING.md` / `CLAUDE.md` said "Branch off `main`",
  contradicting the live `develop`-trunk + promote machinery. `CONTRIBUTING.md` is the
  **org-wide inherited** fallback; `CLAUDE.md`/`AGENTS.md` are the **agent operating** docs.
- **Branch protection (live `gh api`, 2026-06-14) — BOTH branches require review:**
  | | required approvals | linear history | required status checks | `enforce_admins` |
  |---|---|---|---|---|
  | `main` | **1** | yes | the 6 below | false |
  | `develop` | **1** | no (merge commits OK) | the 6 below | false |

  Required checks (identical on both): `lint / Lint (mixed)`, `actionlint .github/workflows`,
  `markdownlint`, `Validate manifests`, `Hermetic dependency audit`, `security / Gitleaks secret
  scan`. **`Trivy`, the `.claude/settings.json` doctor, and Claude review are NOT required** —
  they are advisory and do not block merge. **Correction to the ICM `map/01` fleet profile** which
  claimed develop had "NO required reviews (autonomous-loop compatible)": that is **false** for
  this repo — `develop` requires 1 approval just like `main`. `enforce_admins:false` means an admin
  principal can land a PR; that is the seam a *separate* trusted principal uses.
- **Owner principle (2026-06-13, recorded `decisions-meta`):** *every repo gets `develop` (trunk)
  + `main`/`master` (protected mirror), create-if-missing — roll out AFTER the envctl protection
  mechanism is proven.* envctl is the proven precedent.

## Decision

`develop` is the **integration trunk**; `main` is the **protected release mirror**. Work flows
`task → feature branch (off develop) → PR into develop → CI-gated squash-merge → automated
promote develop→main → release-please`. `main` is **never** committed or PR'd to directly by a
human or agent; it advances **only** via `promote-develop-to-main.yml`.

This dissolves the agent-can't-self-approve deadlock **without** relying on a review-free trunk
(both branches require 1 approval). The deadlock is broken because **the approval/merge is always
supplied by a *separate* trusted principal, never by the PR author**:
- `develop → main`: `promote-develop-to-main.yml` auto-approves with `PROMOTE_TOKEN` (a distinct
  actor → GitHub accepts the approval) and rebase auto-merges.
- `feature → develop`: the approval comes from the GitHub App (via envctl) or the owner — the
  designated separate principals — and `enforce_admins:false` lets that admin principal land it.

The agent author may arm auto-merge (`gh pr merge --auto`) but must **never** approve or
admin-merge its **own** PR on either protected branch — that would collapse the separation of
privilege. Agent PRs still target `develop` (so `main` is only ever reached via promotion), but
the separation property comes from *who approves*, not from the trunk being unguarded.

### Answers to the ten questions

**Q1 — Where is the develop work done?**
On `develop`. Day-to-day work lands on `develop` through short-lived feature branches cut **off
`develop`**. `main` is downstream and protected; it receives work only via the automated promote
PR. (Exception — **forks of upstream repos**: `main`/`master` mirrors pristine upstream and is
never touched locally; *all* FlexNetOS work lives on `develop`. See the research-before-fork
ritual in `CLAUDE.md`.)

**Q2 — Policy for clones / forks / branches / worktrees / staging.**

| Lifecycle object | Policy |
|---|---|
| **Clone** | Full clone (never `--depth 1` / `--filter=blob:none`), checked out onto a feature branch before any edit. **Do not clone a repo that is not already on disk** — route adoption to the handoff loop (`KBTASK-GITHUB-ORG-LEAN-RELOCATION`). |
| **Fork** | Only after the research-before-fork ritual proves setup (`gh repo fork <upstream> --org FlexNetOS --clone=false`). Fork `main`/`master` tracks pristine upstream; `develop` carries FlexNetOS work; the proven `develop` is what registers in a hub (ADR-0002). |
| **Trunk** | `develop` — the integration branch; where feature PRs merge. Permanent. |
| **Protected mirror** | `main` (and `master` on upstream-tracking forks). Permanent, protected, machine-advanced only. |
| **Feature branch** | `<type>/<short-slug>` (`feat/`, `fix/`, `docs/`, `ci/`, `chore/`, `refactor/`, `perf/`, `test/`, `build/`, `revert/`), cut **off `develop`**, **one task**, short-lived, **deleted on merge**, never reused. No long-lived `research/*` mega-branches. |
| **Worktree** | One per active task/ship, created fresh off `origin/develop`, removed after the ship merges. Ephemeral; never reused across tasks (ADR-0001 ship policy; `meta git worktree` / Agent `isolation: worktree`). |
| **Staging branch** | **None.** `develop` *is* the staging/integration layer; `main` *is* release. Do not introduce a third long-lived branch. |

**Q3 — How do PRs move through GitHub Actions?**
1. Push a feature branch / open a PR into `develop` → `ci.yml` (+ `manifest-drift.yml`,
   `dependency-review.yml` on main-targeted PRs, `claude-code-review.yml`) run on it.
2. `develop` requires the 6 checks green **+ 1 approval from a separate principal** (App via
   envctl / owner — never the author). With those met the PR squash-merges (auto-merge armed via
   `gh pr merge --auto --squash`, or `auto-review-merge.yml` for upgrade PRs) → **one Conventional
   Commit per task on `develop`**.
3. `promote-develop-to-main.yml` fires on `ci` success on `develop`, maintains the perpetual
   `develop → main` promote PR, auto-approves via `PROMOTE_TOKEN` (separate identity), and
   **rebase** auto-merges when green → `main` advances, commits preserved.
4. Merge to `main` drives `release.yml` (release-please) — version computed from Conventional
   Commits; currently `workflow_dispatch`-only until the org-level `RELEASE_TOKEN` is wired.
5. Merged feature branches are deleted by `delete-merged-branch.yml`, while protected branches and
   automated upgrade branches are preserved.

**Q4 — What happens if there is a failure?**
The PR self-blocks (`mergeStateStatus = BLOCKED`); armed auto-merge stays armed but will not
merge until checks go green. (Common silent culprits here: `Trivy`, `.claude/settings.json
hygiene`, `markdownlint`, `manifest-validate`; in Rust repos: `Format`/`cargo fmt`, `Gitleaks`.)
`ci-failure-tracker.yml` detects the failed run and opens/updates a tracking issue labeled
`ci-failure` + `needs-autofix` with the failing jobs + log links; it auto-closes that issue on
the next green run.

**Q5 — How do failed-PR triggers flow back to the session to fix?**
The `needs-autofix` tracking issue is the canonical signal. Flowback:
`failure → ci-failure-tracker issue (needs-autofix) → handoff loop claims it (hf task mint /
KBTASK) → a session fixes on a feature branch → green → auto-close + auto-merge`.
For the immediate local loop, the pushing session reads `gh pr checks`, fixes, re-pushes; green
completes the armed auto-merge. No human unless a real human-wall (sudo/hardware/external auth).
*(Automation gap: the issue→session routing is currently handoff-mediated/manual; full
auto-routing is a follow-up — see QUESTIONS_LESSONS §F.)*

**Q6 — How many tasks per commit?**
**≤ 1.** A commit is the smallest revertible unit and implements part or all of exactly **one**
task. Never bundle two tasks in one commit. Each commit message is a valid Conventional Commit.

**Q7 — How many commits per PR?**
A feature PR represents **exactly one task**. Use as many working commits as aid review; the PR
**squash-merges to one Conventional Commit on `develop`** (so the trunk carries one commit per
task). The `develop → main` promote PR is the machine-managed exception — it batches the
per-task commits and rebases them onto `main`.

**Q8 — How many PRs per remote (repo)?**
At steady state: **1 standing promote PR** (`develop → main`, perpetual, machine-managed) **+ 1
standing release PR** (release-please, perpetual) **+ 0..N short-lived feature PRs** (one per
active task). No hard cap, but keep concurrent feature PRs few and short-lived to minimize rebase
churn. Forks add nothing here — they sync, they don't PR upstream from here.

**Q9 — How many tasks per git worktree?**
**Exactly 1.** One task : one feature branch : one worktree. Worktrees are not shared across
tasks.

**Q10 — Are worktrees and branches reusable, or when are they deleted?**
- **Feature branches:** ephemeral — **deleted on merge** (enable delete-branch-on-merge), never
  reused. (Gap: `auto-review-merge.yml` currently does *not* delete; reconcile — see §F.)
- **Worktrees:** ephemeral — created fresh off `origin/develop`, removed after the ship merges
  (Agent auto-removes unchanged worktrees). Never reused.
- **`develop` / `main` / `master`:** permanent, never deleted.
- **Promote PR branch (`develop`) / release-please branch:** permanent / machine-managed.

### PR lifecycle (state machine)

```text
task (KBTASK/HFTASK)
  └─ worktree off origin/develop  ─┐  (1 task : 1 worktree : 1 branch)
       └─ feat/<slug> commits      │  (≤1 task/commit, Conventional)
            └─ PR → develop ───────┘
                 ├─ CI green ──▶ squash-merge ──▶ 1 commit on develop
                 │                                   └─ promote-develop-to-main (auto, PROMOTE_TOKEN, rebase) ──▶ main ──▶ release-please
                 └─ CI red  ──▶ BLOCKED + ci-failure-tracker issue (needs-autofix) ──▶ handoff loop ──▶ fix ──▶ (green)
```

## Consequences

**Positive**
- The agent-self-approval deadlock is dissolved by *who approves* (a separate principal), not by a
  review-free trunk: agent PRs go to `develop`, and both protected crossings are approved by a
  separate principal (App via envctl / owner / `PROMOTE_TOKEN`).
- One unambiguous flow for task→commit→PR→CI→promote→release, with explicit failure flowback.
- Granularity rules (1 task : 1 commit-on-trunk : 1 PR : 1 worktree) stop mega-PRs like #102.

**Required follow-ups (tracked in QUESTIONS_LESSONS §F)**
1. **#102 specifically (owner-chosen: re-target → develop, squash):** its **6 required checks are
   GREEN**; the only merge blocker is the **1 approval** (must come from a separate principal). The
   advisory failures (`Trivy`, `.claude/settings.json` doctor, Claude review) are **not required**
   and do not block merge — clean them up separately (the settings-doctor finding is env-manager
   config, ADR-0006/envctl territory). Because the branch was cut from `main` it is **15 commits
   behind `develop`** with overlapping `architecture/`, so re-targeting needs a `develop`→branch
   merge-resolve first, then squash-merge to `develop` (1 commit). It must never merge to `main`
   directly.
2. **Reconcile the `develop`/`main` `4/15` divergence** so the one-way promote flow holds going
   forward (promote develop→main; fast-forward/replay main's 4 orphan commits onto develop).
3. **Update operating docs** to this canon: `CLAUDE.md` + `AGENTS.md` ("branch off `develop`"),
   and add a pointer from `CONTRIBUTING.md`.
4. **Enable delete-branch-on-merge** and reconcile `auto-review-merge.yml`'s no-delete behavior.
5. **Close the failure→session auto-routing gap** (Q5): wire `needs-autofix` issues into the
   handoff loop intake.
6. **Phased rollout** of the `develop`-trunk model fleet-wide per the owner's 2026-06-13 principle
   — only after envctl protection is proven; align the mechanism with envctl's proven precedent.

**Negative / costs**
- Two long-lived branches per repo (`develop` + `main`) to keep in sync; the promote workflow and
  branch protection must both be configured per repo before the model is safe there.
