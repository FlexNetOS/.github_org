<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-28 -->

# .claude/

## Purpose
Claude Code configuration for the FlexNetOS/.github umbrella. Contains skills, hooks, session config, settings, and agent definitions used by Claude Code in this project.

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
| `settings.json` | Project Claude Code settings — permissions, hooks, environment |
| `settings.local.json` | Local overrides (not committed) |
| `settings.canonical.json` | Canonical reference for settings structure |
| `ecc-tools.json` | ECC tool registry |
| `identity.json` | Project identity metadata |
| `.doctor-allowlist` | Allowlist for `make claude.doctor` portable-path checks |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `skills/` | Local project skills (clone-setup, wrap-up, etc.) |
| `plugins/` | Installed Claude Code plugins (cached) |
| `projects/` | Per-project persistent memory |
| `agents/` | Agent definitions |
| `session-env/` | Session environment snapshots |
| `homunculus/` | Homunculus agent config |
| `ide/` | IDE integration config |
| `downloads/` | Cached downloads |
| `.omc/` | OMC state for Claude config work |

## For AI Agents

### Working In This Directory
- `settings.json` is tracked; `settings.local.json` is gitignored
- Run `make claude.doctor` after any settings change to catch hardcoded paths
- Never add absolute user-home paths to tracked settings files — use portable refs (`$HOME`, `~/`)
- Skills in `skills/` are invoked via `/skill-name` in Claude Code

### Testing Requirements
- `make claude.doctor` must exit 0 (no hardcoded paths in tracked config)
- `make config.doctor` for combined Claude + Codex check

### Common Patterns
- Hooks live in `settings.json` under `hooks` key
- Permissions in `settings.json` under `permissions.allow`
