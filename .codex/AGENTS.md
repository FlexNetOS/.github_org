# ECC for Codex CLI

This supplements the root `AGENTS.md` with a repo-local ECC baseline.

<!-- ALWAYS-ON-RULES v1 — identical block; keep in sync across AGENTS.md · CLAUDE.md · .github/AGENTS.md · .claude/AGENTS.md · .codex/AGENTS.md. Source: meta/.kb/AGENTS.md (FlexNetOS Agent Guide) + owner rule 2026-06-21. -->

## Always-on rules (non-negotiable — every agent, every session)

These apply to **all** agents and CLIs (Claude, Codex, Gemini, Copilot) in every session, on top of any directory-specific notes.

1. **Finish what's surfaced.** "Stale" or "orphaned" work is *unfinished* work — never overlook it or pass it off. The default is to complete and **merge** it (investigate → finish → verify → commit → PR → merge), not preserve-and-report. Surfacing an issue without resolving it is not allowed.
2. **Always upgrade, never downgrade.** No stubs, no `todo!()`, no "simplified for now", no dropped branches, no weakening an existing rule or guard. Carry stale/orphaned refs forward with url+SHA — never delete them.
3. **Document before implementing.** Non-trivial work gets its tracking doc/plan first (bug → incident, feature → task); trivial typos and one-liners excepted.
4. **Verify before claiming done.** Never assert complete / fixed / passing without running the real check (build, fmt, clippy, test, CI gates). If the verification method is unclear, ASK.
5. **Trace everything to an accountable human.** Commits reference their task/issue; child work links its parent; the chain of responsibility stays clear.

## Repo Skill

- Repo-generated Codex skill: `.agents/skills/.github/SKILL.md`
- Claude-facing companion skill: `.claude/skills/.github/SKILL.md`
- Keep user-specific credentials and private MCPs in `~/.codex/config.toml`, not in this repo.

## MCP Baseline

Treat `.codex/config.toml` as the default ECC-safe baseline for work in this repository.
The generated baseline enables GitHub, Context7, Exa, Memory, Playwright, and Sequential Thinking.

## Multi-Agent Support

- Explorer: read-only evidence gathering
- Reviewer: correctness, security, and regression review
- Docs researcher: API and release-note verification

## Workflow Files

- No dedicated workflow command files were generated for this repo.

Use these workflow files as reusable task scaffolds when the detected repository workflows recur.
