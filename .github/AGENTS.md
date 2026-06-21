<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-28 -->

# .github/

## Purpose
GitHub community health files and CI/CD workflows for the FlexNetOS org. Files at this level serve as org-wide defaults inherited by all FlexNetOS repos that don't ship their own.

<!-- ALWAYS-ON-RULES v1 — identical block; keep in sync across AGENTS.md · CLAUDE.md · .github/AGENTS.md · .claude/AGENTS.md · .codex/AGENTS.md. Source: meta/.kb/AGENTS.md (FlexNetOS Agent Guide) + owner rule 2026-06-21. -->

## Always-on rules (non-negotiable — every agent, every session)

These apply to **all** agents and CLIs (Claude, Codex, Gemini, Copilot) in every session, on top of any directory-specific notes.

1. **Finish what's surfaced.** "Stale" or "orphaned" work is *unfinished* work — never overlook it or pass it off. The default is to complete and **merge** it (investigate → finish → verify → commit → PR → merge), not preserve-and-report. Surfacing an issue without resolving it is not allowed.
2. **Always upgrade, never downgrade.** No stubs, no `todo!()`, no "simplified for now", no dropped branches, no weakening an existing rule or guard. Carry stale/orphaned refs forward with url+SHA — never delete them.
3. **Document before implementing.** Non-trivial work gets its tracking doc/plan first (bug → incident, feature → task); trivial typos and one-liners excepted.
4. **Verify before claiming done.** Never assert complete / fixed / passing without running the real check (build, fmt, clippy, test, CI gates). If the verification method is unclear, ASK.
5. **Trace everything to an accountable human.** Commits reference their task/issue; child work links its parent; the chain of responsibility stays clear.

## Key Files

| File | Description |
|------|-------------|
| `CODEOWNERS` | Code ownership rules for this repo |
| `PULL_REQUEST_TEMPLATE.md` | Default PR description template |
| `actionlint.yaml` | actionlint configuration (ignores advisory rules) |
| `dependabot.yml` | Dependabot version update config |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `workflows/` | GitHub Actions CI/CD workflows (reusable + repo-specific) |
| `ISSUE_TEMPLATE/` | Issue templates inherited by all FlexNetOS repos |

## For AI Agents

### Working In This Directory
- Workflow changes trigger `make verify.actionlint` automatically via pre-commit
- All `workflow_call` reusable workflows must be in `workflows/reusable-*.yml`
- CI invariant: new checks land with `continue-on-error: true` first, then promote to strict after one green cycle on `main`
- Never pin `actions/checkout` to SHA without updating the `actionlint.yaml` allowlist

### Testing Requirements
- `make verify.actionlint` must exit 0 after any workflow change
- Run `tools/bin/actionlint .github/workflows/<file>.yml` for individual file checks

### Common Patterns
- Reusable workflows use `workflow_call` trigger
- Job names follow `kebab-case` convention
- Secrets passed via `secrets: inherit` in callers
