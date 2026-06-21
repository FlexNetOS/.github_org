---
name: org-implementation-loop
description: "Autonomously implement a BACKLOG of FlexNetOS/.github changes (harness-upgrade targets / HUTs, config cleanups, CI/doc/skill work) one-branch-one-PR until done. ALWAYS use when asked to: 'run the loop', 'work through the HUTs/backlog', 'auto-implement the targets', 'keep building', 'loop on the roadmap', 'resume the implementation loop', or drive the org-implementation-loop. Each cycle takes the next undone backlog item through org-change-architect → org-change-implementer → org-change-guardian, gates on `make verify`, opens a PR into develop with auto-merge armed, runs an evolution retrospective, checkpoints, and self-paces. Do NOT use for a single ad-hoc edit (just do it) or for tasks needing host/secret/owner gates (surface those instead)."
---

# Org Implementation Loop (Ralph, .github-native)

You drive a **self-perpetuating loop** that implements a durable backlog of changes to the
`FlexNetOS/.github` umbrella — autonomously, one target at a time, each as **one branch : one PR
into `develop`**. The loop's intelligence lives in **`backlog.md` + the per-cycle checkpoints on
disk**, NOT in conversation memory — so a fresh session resumes it with zero loss.

This is the `.github`-native sibling of `harness:forge-loop`. Where forge-loop runs the Rust
`feature-forge` crew against cargo gates, this loop runs the **org crew**
(`org-change-architect` → `org-change-implementer` → `org-change-guardian`) against **`make verify`
+ the repo doctors**, because `.github_org` is a config/CI/docs repo with no app and no cargo.

## Crew (sub-agent pipeline — all `model: "opus"`)

| Role | Agent (`subagent_type`) | Mutates? | Job |
|------|-------------------------|----------|-----|
| Architect | `org-change-architect` | no | Turn the next backlog item into a plan + acceptance criteria + verify recipe |
| Implementer | `org-change-implementer` | yes | Execute the plan on the cycle's branch; commit; run the verify recipe |
| Guardian | `org-change-guardian` | no | Independently run `make verify` + doctors; PASS / FAIL with evidence |
| Retrospective | `harness:evolution-steward` | proposes | After each cycle: what did this teach the harness; route low-risk upgrades |
| Handoff | `harness:continuity-steward` | yes (checkpoint) | At the cycle budget, write the cold-start resume checkpoint |

Default execution is the **sub-agent pipeline** (the `Agent` tool, sequential per target) because it
needs no team-comms tooling and is fully resumable. If agent-team tools (`TeamCreate`/`SendMessage`)
are available and several targets are independent, a team MAY run cycles concurrently — but never let
two cycles touch the same files (`CHANGELOG.md` is the usual collision; serialize those).

## Phase 0: Context check (initial vs resume vs partial)

1. Read `.claude/skills/org-implementation-loop/backlog.md`. It is the source of truth for what is
   done / in-progress / todo.
2. Read `_workspace/` under the repo root if it exists — per-target plans, guardian verdicts, and the
   loop checkpoint (`_workspace/loop-checkpoint.md`) live there.
3. Branch:
   - **Initial** — no `_workspace/`, backlog has todo items → start at the first todo.
   - **Resume** — `_workspace/loop-checkpoint.md` exists → read it, reconcile against `backlog.md`
     and open PRs (`gh pr list --state open`), and continue at the next undone item. A target whose
     PR is already open/merged is DONE — do not redo it.
   - **Partial** — user names one target → run a single cycle for just that target.
4. Confirm the green baseline before mutating: `make verify` on `develop` must be green (or its only
   failures are known pre-existing carry-overs recorded in `backlog.md`). If `develop` is genuinely
   red, fix that first or surface it — do not stack new work on a red trunk.

## The cycle (one backlog item)

For the next `todo` item `T`:

1. **Branch.** `git switch -c <type>/<short-slug> origin/develop` (type from T: `fix`/`feat`/`chore`/
   `ci`/`docs`). Mark T `in-progress` in `backlog.md` (commit that bookkeeping later with the work).
2. **Architect.** `Agent(subagent_type: "org-change-architect", model: "opus")` with T's id, title,
   and the research evidence. It returns a plan + acceptance criteria + verify recipe. Save to
   `_workspace/<T>_architect_plan.md`. If it says "split this target", update `backlog.md` (replace T
   with the sub-targets) and restart the cycle on the first sub-target.
3. **Implement.** `Agent(subagent_type: "org-change-implementer", model: "opus")` with the plan.
   It edits on the branch, runs the verify recipe, commits. Save its report to
   `_workspace/<T>_impl_report.md`.
4. **Guard.** `Agent(subagent_type: "org-change-guardian", model: "opus")` with the criteria +
   the implementer report. It independently runs `make verify` + doctors.
   - **FAIL** → route the verdict back to the implementer (step 3) with the guardian's evidence.
     Retry once. Still FAIL → leave the branch, mark T `blocked` in `backlog.md` with the reason,
     and move to the next item (never merge a red change, never fake a pass).
   - **PASS / PASS WITH WARNINGS** → continue.
5. **PR.** Push the branch; `gh pr create --base develop` with a body built from the architect plan +
   guardian evidence (include warnings). Arm auto-merge: `gh pr merge <n> --auto --squash`. That is the
   loop's **last** action on the PR. An **automated separate principal** approves it — the
   flexnetos-github-app via envctl / `auto-review-merge.yml` — never the loop, never the owner; the
   agent must not self-approve (ADR-0003 C-F3 §G). The PR then merges on green with no human. If it
   shows `BLOCKED`, that means the App-approval token (`AUTOMERGE_APPROVE_TOKEN`) is not provisioned yet
   — a one-time envctl/Phase-6 ops gate recorded once as `needs-owner` in `backlog.md`, **not** a signal
   to ask the owner to approve this PR. Never tell the owner to approve or merge a PR.
6. **Record.** Mark T `done (PR #n)` in `backlog.md`. Append a one-line entry to `CHANGELOG.md`
   `[Unreleased]` (guard the CHANGELOG collision: if another open loop PR already edits the same
   anchor, note it in the PR body instead and reconcile at merge).
7. **Evolve.** `Agent(subagent_type: "harness:evolution-steward", model: "opus")` with this cycle's
   plan + verdict + any friction. It proposes harness upgrades (agent/skill/orchestrator/backlog
   edits); apply only low-risk in-scope ones via a follow-up loop item, escalate structural ones to
   the owner. Record any harness change in the CLAUDE.md change-history table.

## Self-pacing & handoff (resumability)

- **Cycle budget:** default **3 cycles per session** (each cycle is several opus agents — expensive).
  After the budget, or if context is getting long, STOP issuing new cycles.
- At stop, invoke `Agent(subagent_type: "harness:continuity-steward", model: "opus")` to write
  `_workspace/loop-checkpoint.md` (state + pointers, not narrative): backlog status, open PR numbers,
  the next undone item, and any `blocked` reasons. A fresh session resumes from that file (Phase 0).
- Never block waiting on a PR to merge — auto-merge is armed; the loop's job is to *open* green PRs,
  not to babysit the merge queue. The automated principal (App via envctl / `auto-review-merge.yml`)
  approves and merges them on green — the owner is never the approver. Never frame a PR as "awaiting
  owner approval"; a missing approval is a one-time token-provisioning ops gate, not a per-PR ask.

## Guardrails (the loop must never)

- ...merge its own PR, self-approve, or open a PR against `main`. PRs target `develop`; approval is
  supplied by an **automated** separate principal (App via envctl / `auto-review-merge.yml`), never the
  PR author and never the human owner (ADR-0003 C-F3 §G).
- ...tell the owner to approve or merge a PR, or stack PRs "awaiting owner approval". The pipeline is
  full-auto on green. A missing automated approval is a one-time envctl token gate (`needs-owner` in
  `backlog.md`), surfaced once — not a recurring human-in-the-loop step.
- ...introduce a downgrade (stub / dropped branch / weakened guard) to make a target "pass". A target
  that can only be met by downgrading is `blocked`, not done.
- ...edit `secrets/store/**`, print a token, run a host install, or clone a repo not already on disk.
  Those are owner/host gates — record them in `backlog.md` as `needs-owner` and skip.
- ...expand a target's PR beyond its scope. Adjacent discoveries become new backlog items.
- ...stack work on a red `develop`. Green baseline first.

## Test Scenarios

- **Happy path:** backlog has `HUT-5` (todo) → architect plans the `tool-assets-validate` CI job →
  implementer adds it report-only + the local mirror → guardian runs `make verify.tool-assets` +
  `actionlint` (green) → PR into `develop`, auto-merge armed → backlog marks `HUT-5 done (PR #n)` →
  evolution-steward notes "CI job added report-only per promotion rule" → next item.
- **Error path:** implementer's change fails `make verify.markdown` → guardian returns FAIL with the
  exact lint line → orchestrator routes back to implementer (retry 1) → still fails → `HUT-x` marked
  `blocked: markdownlint <file>:<line>` in `backlog.md`, branch left for inspection, loop proceeds to
  the next item. No PR opened for the blocked target.
- **Resume path:** fresh session, `_workspace/loop-checkpoint.md` says `HUT-2 done (#212), HUT-3
  in-progress` and `gh pr list` shows #212 open → loop treats HUT-2 as done, re-enters HUT-3 from its
  branch, continues.

## Backlog

The live queue is `.claude/skills/org-implementation-loop/backlog.md` (seeded with HUT-2…HUT-7).
Edit THAT file to add/reorder/retire targets — the loop reads it every Phase 0.
