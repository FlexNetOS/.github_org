--- 01KTZA2NCK8Y7MTZ5RDWMR3ATE ---
  topic:      context-core-arch-baseline
  importance: critical
  weight:     1.000
  created:    2026-06-12 20:38
  accessed:   2026-06-13 07:52 (x2)
  summary:    **System Architecture Baseline (Meta-Repo Discipline)**

This codebase operates as a meta-repository of independent projects/git repositories. The following principles are mandatory for stability and continuity:
1.  **Command Prefixing:** All external CLI commands, especially Git operations (`git add`, `git commit`, etc.), MUST be prefixed with `rtk` (e.g., `rtk git status`). This is non-negotiable for token efficiency and process safety.
2.  **Handoff Protocol:** Work continuity requires the use of dedicated skills like `/handoff`, `/checkpoint`, or similar state management tools, enforced by the `handoff-discipline` skill to track all transitions (fix/feature/etc.).
3.  **Cross-Repo Operations:** All commands spanning multiple repositories must use `meta git` or `meta exec -- <cmd>`. Never assume monorepo behavior.
4.  **Knowledge Management:** The process of *discovering*, *planning* (ADR), and *documenting* must precede any implementation. Decisions should be stored in ICM with high importance, and all significant work must link back to a structured task list/memory record.

This baseline captures the core invariants from build processes, tooling standards, and session continuity requirements derived across multiple operational phases.
  keywords:   architecture baseline, meta-repo rules, rtk usage, handoff protocol
  embedding:  yes

