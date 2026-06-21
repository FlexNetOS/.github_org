# AGENTS.md — FlexNetOS `.github` umbrella

Cross-CLI instruction file for AI agents (Codex, Gemini, Copilot, etc.).
Claude Code users: see `CLAUDE.md` for the full reference. This file summarises
the constraints that apply to **all** agents.

---

<!-- ALWAYS-ON-RULES v1 — identical block; keep in sync across AGENTS.md · CLAUDE.md · .github/AGENTS.md · .claude/AGENTS.md · .codex/AGENTS.md. Source: meta/.kb/AGENTS.md (FlexNetOS Agent Guide) + owner rule 2026-06-21. -->

## Always-on rules (non-negotiable — every agent, every session)

These apply to **all** agents and CLIs (Claude, Codex, Gemini, Copilot) in every session, on top of any directory-specific notes.

1. **Finish what's surfaced.** "Stale" or "orphaned" work is *unfinished* work — never overlook it or pass it off. The default is to complete and **merge** it (investigate → finish → verify → commit → PR → merge), not preserve-and-report. Surfacing an issue without resolving it is not allowed.
2. **Always upgrade, never downgrade.** No stubs, no `todo!()`, no "simplified for now", no dropped branches, no weakening an existing rule or guard. Carry stale/orphaned refs forward with url+SHA — never delete them.
3. **Document before implementing.** Non-trivial work gets its tracking doc/plan first (bug → incident, feature → task); trivial typos and one-liners excepted.
4. **Verify before claiming done.** Never assert complete / fixed / passing without running the real check (build, fmt, clippy, test, CI gates). If the verification method is unclear, ASK.
5. **Trace everything to an accountable human.** Commits reference their task/issue; child work links its parent; the chain of responsibility stays clear.

---

## What this repo is

`my-github` on disk = the `FlexNetOS/.github` org-wide repository (at
`~/Desktop/meta/.github_org`). It is the org's **`.github` repo + a small
operational hub** — community-health files, the Karpathy LLM-wiki (`wiki/` +
`data/brain-data/`), a `pass`+GPG secrets vault, a self-hosted runner host
config, and shared reusable CI templates. **Nothing to build or run at the top
level.** Real codebases live in their own repos / typed **hubs**, not here.

> **ADR-0002 (2026-06-14):** this repo is **no longer the submodule mount point**.
> Repo organization moved to typed FlexNetOS hubs (`tool_hub`, `plugin_hub`,
> `vault_hub`, …); unclassified repos park in `~/Desktop/pending_relocate`.
> `repos/MANIFEST.yaml` is an offload stub. `ruvector` lives at `meta/ruvector`
> (**crates only**). `data/brain-data/*` stays.

---

## Non-negotiable constraints

### 1. Branch discipline

**Never edit source files directly on `main`, `master`, or `trunk`.**

```bash
# At the start of every session:
git checkout -b feat/<short-descriptive-name>
```

The `branch-guard.sh` hook blocks `Edit`/`Write` on protected branches for
source files. It cannot be worked around — fix the branch, then edit.

Exempt from the hook's source-file block: `.claude/**`, `.omc/**`, `.github/**`,
`CLAUDE.md`, `AGENTS.md`, `README.md`, `docs/**/*.md`. This exemption lets the
hook avoid false positives on doc/agent-config files; it does **not** override
the branch-target policy. All work, including docs-only additive changes, still
routes through a feature branch targeting `develop`.

### 2. External-repo sequence — never skip, never reverse

1. **Clone first** — new feature branch, original upstream, do not fork yet
2. **Research** — `make research.pack URL=<owner/repo>`, write dossier at `data/brain-data/research/<name>.md`
3. **Set it up working** — run as intended; host deps are temporary, not the destination
4. **Fork** — `gh repo fork <upstream> --org FlexNetOS --clone=false`; `main`/`master` tracks upstream clean, `develop` carries FlexNetOS changes
5. **Register in the hub** — land the proven `develop` fork in its typed hub (`<hub>/repos/` + the hub's `registry.json`/`entries/`), **not** as a submodule under `.github_org/repos/` (ADR-0002). Do **not** clone repos that aren't already on disk — route adoption through the handoff loop.

Forking before step 3 is complete has previously broken repos. This gate is mandatory.

### 3. Full clones only

No `--depth 1`, no `--filter=blob:none`. The Vision requires full clones — workspace reproducibility depends on complete history.

### 4. External deps belong in the git graph — in a HUB, not here

Every external dependency belongs in the git graph, organized into its typed **hub** (ADR-0002) — **not** as a submodule under `.github_org/repos/` (that role is retired). Unclassified work parks in `~/Desktop/pending_relocate` with its url+SHA preserved (never-downgrade). Never delete a stale/orphaned repo reference — carry it forward.

### 5. Secrets never in git

Secrets are injected at runtime via `pass` + `direnv`. `.env.example` files (keys listed, values empty) are committed; actual `.env` files never are.

---

## Canonical paths

| Location | Purpose |
|---|---|
| `~/Desktop/meta/.github_org` | Canonical repo root (the `FlexNetOS/.github` repo) |
| `repos/MANIFEST.yaml` | Offload stub (ADR-0002) — repos moved to hubs / `~/Desktop/pending_relocate` |
| `data/brain-data/research/` | Research dossiers and plans — **never** `.omc/plans/` |
| `secrets/store/` | `pass`-managed GPG vault |
| `runner/` | Self-hosted GitHub Actions runner config |

---

## Architecture artifacts

Design-time artifacts live under the single `architecture/` root (see
[`architecture/README.md`](architecture/README.md)). The installed skills are routed
here, overriding their built-in defaults:

| Stage | Skill | Output path |
|---|---|---|
| PRD | `ecc:plan-prd`, `ecc:prp-prd` | `architecture/prd/PRD-NNNN-<slug>.md` |
| ADR | `ecc:architecture-decision-records` | `architecture/adr/ADR-NNNN-<slug>.md` |
| Spec | `ccg:spec-research` -> `spec-plan` -> `spec-impl` | `architecture/openspec/` (run from `architecture/`) |
| Plan | `writing-plans`, `oh-my-claudecode:plan` | `architecture/plan/YYYY-MM-DD-<slug>-plan.md` |

`architecture/README.md` is the PRD/ADR registry + numbering source of truth.
`architecture/.claude/` is git-ignored. Submodule rollout is deferred.

---

## Key commands

```bash
make verify              # Run ALL local verification (gate before any PR)
make verify.manifest     # Validate repos/MANIFEST.yaml (now an offload stub)
make submodules.status   # data/brain-data submodule status (repo/tool submodules retired — ADR-0002)
make research.pack URL=<owner/repo>   # Clone + repomix-pack upstream for research
make claude.doctor       # Audit .claude/settings.json for bad paths
```

---

## What agents get wrong

- Suggesting shallow/partial clones (`--depth 1`, `--filter`)
- Forking before the original is cloned and working
- Treating `_work/repos/` as the canonical path (canonical is `workspace/my-github`)
- Putting research or plans in `.omc/plans/` (must be `data/brain-data/research/`)
- Editing on `main` instead of a feature branch
- Treating host-level installs as permanent (they are temporary; land the result in its hub)
- Re-adding repos as submodules under `.github_org/repos/`, or cloning a repo not already on disk (ADR-0002)
- Skipping the `make research.pack` step before writing a dossier

---

## Session tracking

Four root files — keep them current via `/wrap-up`:

| File | Owner | Purpose |
|---|---|---|
| `TODO.md` | agent | Working TODO |
| `USER.TODO.md` | human | Human-only actions; agent appends only to `## Agent-flagged user actions` |
| `CHANGELOG.md` | both | Applied changes (Keep-a-Changelog `[Unreleased]`) |
| `SESSIONS.md` | agent | Per-session log (`SESSION-YYYY-MM-DD-NNN` IDs) |

---

## Full reference

See `CLAUDE.md` for the complete command reference, per-project conventions,
toolchain details, and CI invariant rules.

See `data/brain-data/obsidian-mind/brain/GitHub Workspace Vision.md` for the
architectural rationale behind every constraint above.
