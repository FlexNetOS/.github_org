--- 01KTZCY519MVQ5P1K572C71VWH ---
  topic:      decisions-meta/dev_process
  importance: high
  weight:     0.975
  created:    2026-06-12 21:28
  accessed:   2026-06-12 21:28 (x0)
  summary:    This project is governed by several mandatory architectural rules that must be followed for all future development and decision-making. 
1. **ICM Usage:** ICM (Infinite Context Memory) is MANDATORY for persistent memory recall, storage of decisions, error resolution, and progress tracking. All significant changes must be logged via `icm store` to maintain a verifiable audit trail across sessions.
2. **RTK Prefixing:** The Token-Optimized CLI proxy (`rtk`) MUST be used to prefix all external commands (e.g., `git`, `cargo`, `tsc`) to ensure token efficiency and compatibility with the meta-repo structure. Raw commands must be wrapped using `rtk` or passed through via `meta rtk`.
3. **FlexNetOS Discipline:** All work must follow FlexNetOS documentation practices, prioritizing context creation (`git kb create task/incident`) over direct coding fixes for non-trivial items. The document IS the plan.
4. **ADR Process Rule (CRITICAL):** Any Architecture Decision Record (ADR) MUST include deep web research and cross-referencing *before* finalization to prevent shallow analysis from leading to poor decisions.

These rules define the project's operational contract for development continuity.
  keywords:   architecture, process rule, rtk, icm, flexnetos
  embedding:  yes

