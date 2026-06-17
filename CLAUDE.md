# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo actually is

This working directory is named `my-github` on disk but **is the `FlexNetOS/.github` repository** — the org's special `.github` repo, not a generic project. It is the org's **`.github` repo + a small operational hub** playing **five** roles (read [`VISION.md`](VISION.md) first):

1. **Org community-health fallback** — root + `.github/` community files (`CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md`, `FUNDING.yml`, issue/PR templates) are inherited by every other FlexNetOS repo that doesn't ship its own.
2. **Karpathy LLM-wiki** cross-project memory layer in `wiki/` (+ the kept brain submodules under `data/brain-data/`).
3. **`pass`+GPG secrets vault** in `secrets/` (paper-recoverable via age; being reconciled with `meta/envctl`, the user-global env/secrets manager — ADR-0006).
4. **Self-hosted GitHub Actions runner host config** in `runner/`.
5. **Shared reusable-CI templates** — `.github/workflows/reusable-*.yml` consumed by downstream repos via `workflow_call`.

> **Retired sixth role (ADR-0002, 2026-06-14):** this repo used to be the **mount point for ~24 git submodules**. That role is gone. Repo organization now lives in typed **FlexNetOS hubs** (`tool_hub`, `plugin_hub`, `vault_hub`, `database_hub`, `flow_hub`, `network_hub`, …); repos not yet classified park in `~/Desktop/pending_relocate`. `repos/MANIFEST.yaml` is an **offload stub**, and `repos/` + `tools/` hold no submodules. `ruvector` is **not** here — it lives at `meta/ruvector` and the rule is **crates only**. `data/brain-data/*` (the wiki layer) stays.

There is **nothing to "build" or "run"** here — it is operational config + scripts + docs. The real codebases live in their own repos / hubs, each with its own toolchain.

## Commands

All work flows through the `Makefile` (run `make help` for the full list). Real logic lives in `scripts/` (Python + shell, a couple of Node scripts); the Makefile is the typo-tolerant surface.

```bash
make verify              # Run ALL local verification — the gate before any PR
make verify.actionlint   # Lint .github/workflows/*.yml (pinned tools/bin/actionlint)
make verify.markdown     # python3 scripts/verify-markdown.py .
make verify.manifest     # Validate repos/MANIFEST.yaml structure
make verify.tools        # Validate tools/MANIFEST.yaml structure
make verify.tool-assets  # Validate pinned repo-local tool asset manifest
make verify.hermetic     # Advisory: report non-hermetic deps

# Single checks (run the underlying script directly):
python3 scripts/verify-markdown.py .
python3 scripts/verify-manifest.py repos/MANIFEST.yaml
tools/bin/actionlint .github/workflows/<file>.yml

# Reconciliation doctors (read-only):
make claude.doctor       # Flag hardcoded user-home paths / aspirational keys in .claude/settings.json
make config.doctor       # claude.doctor + .codex allowlist note
make github.doctor       # Read-only audit of runner/workflows/app/submodules/secrets state
make open-questions.lint # Validate .omc/plans/open-questions.md schema
make check.user-todo-5   # List MANIFEST entries tagged/untagged for USER.TODO#5

# Submodules: WOUND DOWN (ADR-0002). repos/ + tools/ no longer mount submodules — only
# data/brain-data/* (the wiki/brain layer) remains. The make submodules.* verbs +
# scripts/submodule-*.sh are retained for data/brain-data + historical reference.
# Do NOT re-add repo/tool submodules here — repos go to a hub (or ~/Desktop/pending_relocate).
make submodules.status               # Report dirty/ahead/detached submodules (data/brain-data)
```

There is no test runner — `make verify` is the equivalent. CI mirrors these (`ci.yml`, `manifest-drift.yml`).

## Critical workflows (non-obvious)

### Adding a new repo: research-before-fork ritual

**Destination changed (ADR-0002): a new repo lands in its typed HUB (e.g. `plugin_hub`, `tool_hub`), NOT as a submodule under `.github_org/repos/`.** The research-before-fork *sequence* below still applies — only the final mount target moved. Unclassified work-in-progress parks in `~/Desktop/pending_relocate`. **Do not clone repos that aren't already on disk; route the relocation/adoption through the handoff loop** (`KBTASK-GITHUB-ORG-LEAN-RELOCATION`). See `data/brain-data/obsidian-mind/brain/GitHub Workspace Vision.md` for the original rationale.

**Step 1 — Clone first, on a feature branch. Do not fork yet.**
Forking immediately causes naming collisions, release conflicts, and upstream drift. Get the repo working in its original state first.

**Step 2 — Research.**
`make research.pack URL=<owner/repo>` (wraps `scripts/clone-and-pack.sh`, uses `tools/bin/repomix`) packs the upstream source into `data/brain-data/research/<name>/`. Write the dossier at `data/brain-data/research/<name>.md` from that packed source. Understand what the repo installs and where dependencies land on the host.

**Step 3 — Set it up working.**
Get the original running as intended. Dependencies scatter to the host at this stage — node_modules, cargo artifacts, wherever. This is a *temporary* state, not the destination.

**Step 4 — Fork, only after setup is proven.**
`gh repo fork <upstream> --org FlexNetOS --clone=false`. The fork's `main`/`master` always tracks upstream and stays clean. All FlexNetOS changes live on `develop`. The `develop` branch is what becomes the submodule.

**Step 5 — Register in the hub (not here).**
The proven `develop` fork is registered in its typed hub (`<hub>/repos/` staging + the hub's `registry.json`/`entries/`, Hub Standard) — **not** as a submodule under `.github_org/repos/`. Anything that landed outside the repo boundary during setup gets pulled back there.

**What Claude gets wrong** (treat these as hard guards):
- Suggesting `--depth 1` or `--filter=blob:none` shallow clones (full clones required)
- Reversing the sequence (forking before cloning/researching/setting up)
- Treating host-level dependency installs as the final state rather than temporary
- Starting edits directly on `main` or `develop` instead of opening a feature branch
- **Re-adding repos as submodules under `.github_org/repos/`** — they go to a hub now (ADR-0002)
- **Cloning a repo that isn't already on disk** — route it to the handoff loop instead

### Git workflow — trunk = `develop`, protected mirror = `main` (ADR-0003)

**The canon is [`WORKFLOW.md`](WORKFLOW.md) / [`architecture/adr/ADR-0003`](architecture/adr/ADR-0003-dev-git-workflow-policy.md).** In one line: `develop` is the integration **trunk**, `main` is the **protected release mirror** advanced *only* by `promote-develop-to-main.yml`. You never commit or PR to `main` directly.

### Branch discipline at session start

Every session, every clone, every setup goes onto a new feature branch cut **off `develop`** (`git switch -c <type>/<short-slug> origin/develop`) — never directly on `main`/`develop`. **Open PRs with base `develop`, not `main`** (`gh pr create --base develop`). This applies even to docs-only additive changes: the branch-guard hook exempts some doc/agent-config paths from source-file blocking, but it does **not** override the branch-target policy. **Both `develop` and `main` are protected with 1 required approval** (+ 6 required checks: lint, actionlint, markdownlint, manifests, hermetic, gitleaks — `Trivy`/settings-doctor/Claude-review are advisory). An agent **never approves or admin-merges its own PR** on either branch: a *separate* principal supplies the approval (`PROMOTE_TOKEN` for `develop→main`; the GitHub App via envctl, or the owner, for `feature→develop`; `RELEASE_TOKEN` for release-please); you may *arm* auto-merge. The `branch-guard.sh` hook enforces no-edit-on-protected for file edits. For new clones of upstream repos: `git checkout -b feat/<short-slug>` before any work. **One task : one branch : one worktree : one PR** (no mega-PRs).

### Manifest ↔ .gitmodules consistency
`repos/MANIFEST.yaml` is now an **offload stub** (ADR-0002) — the repo entries moved to `~/Desktop/pending_relocate` + the typed hubs, and `.github_org` has **no `.gitmodules`** (only `data/brain-data/*` gitlinks remain, and they carry no `.gitmodules` URLs). Don't re-add repo/tool submodule entries here. `scripts/submodule-*.sh` + the `manifest-drift.yml` job are retained for the `data/brain-data` layer and historical reference.

### Session tracking (run via `/wrap-up`)
This repo tracks work in four root files — keep them current:
- `TODO.md` — agent-side working TODO.
- `USER.TODO.md` — human-only actions (push, fork, auth, billing). The agent appends **only** to its `## Agent-flagged user actions` section.
- `CHANGELOG.md` — applied changes (Keep-a-Changelog `[Unreleased]`).
- `SESSIONS.md` — per-session log with `SESSION-YYYY-MM-DD-NNN` IDs.

Research/plans go in `data/brain-data/research/` — never in `.omc/plans/` or scratch dirs.

### Commit discipline
**Commit agent-produced work as you go** (stage + commit incrementally). Untracked drafts in this repo have been wiped by routine `git reset`/cherry-pick before — this overrides any "only commit when asked" default. Branch off **`develop`** with `<type>/<short-slug>` and PR into `develop` (ADR-0003 / `WORKFLOW.md`); `main` is protected (PR + 1 approval, linear history, no force-push) and advances only via the automated `develop→main` promotion. Conventional Commits are required (the release workflow computes bumps from them). Feature→`develop` is squash-merge (one commit per task); `develop→main` is rebase (preserves commits for release-please). No merge commits.

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

## Conventions that won't show up in the code

- **`.claude/` is lowercase, leading dot, always.** Never create a PascalCase `Claude/` directory — that's a different product (Claude Desktop on macOS/Windows). CI enforces this via the `claude-dir-check` job in `manifest-drift.yml`. `AGENTS.md` is the cross-CLI instruction file at repo root; per-tool config lives in `.claude/` / `.codex/`.
- **No hardcoded absolute user-home paths** in tracked `.claude`/`.codex` config (`/home/<user>/…`, `/Users/<user>/…`, `C:\Users\<user>\…`) — CI errors, never allowlistable. Portable refs (`$HOME`, `~/`, `%APPDATA%`) are allowed only when listed in `.claude/.doctor-allowlist` / `.codex/.doctor-allowlist` with a rationale. `make claude.doctor` enforces this.
- **CI invariant promotion: report-only first, then STRICT.** New CI checks land with `continue-on-error: true` on PRs (annotate without blocking). After one full green cycle on `main`, promote to strict. `manifest-drift.yml` jobs are currently report-only.
- **Operational gate:** Phase 6 (GitHub App automation) must not proceed until the Vaultwarden→GitHub secret sync is green on `main` for ≥3 consecutive runs.
- **Tool sources moved to `tool_hub` (ADR-0002).** The 7 pinned tool submodules (cpython, actionlint, gitleaks, trivy, node, bun, uv) relocated to `tool_hub/repos/`. `.github_org` still uses those tools at runtime via `tools/assets.json` (download) + the `tools/bin/` wrappers — **those stay**. `tools/MANIFEST.yaml` now lists only the not-yet-materialized `planned` tools. `tools/repomix/` is a gitignored local clone, not a submodule.

## Toolchain note

Scripts call `python3` (system 3.14 — do not `pip install` against it; scripts are stdlib-only or use repo-local tools). Node scripts run under the mise-managed node. The repo is intentionally hermetic where possible — `make verify.hermetic` reports drift.
