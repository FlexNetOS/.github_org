--- 01KTFZ3JB0KF1NK90DX1A5ZS75 ---
  topic:      context-weave-harness-loop
  importance: high
  weight:     0.919
  created:    2026-06-06 21:38
  accessed:   2026-06-07 14:33 (x2)
  summary:    Added first-class Codex seven-layer harness orchestration to weave. New src/harness.rs builds/dry-runs/executes weave harness ide-merge-ide, wrapping .claude/skills/weave-loop/scripts/ralph-weave.sh. Defaults: Kimi Code preflight/review via kimi-legacy -r 3c6e42cf-090d-4553-a84b-e63fb9c511c1, implementation via ollama launch claude --model minimax-m3:cloud --, WEAVE_APPLY=1 for no-human loop unless --safe. CLI supports worktree/budget/max-iters/sleep/agent/kimi overrides and JSON dry-run. README and HARNESS-CHANGELOG documented it; integration/unit tests added. Verified cargo fmt --all -- --check, cargo clippy --all-targets -- -D warnings, cargo test --quiet all pass with 84 tests.
  keywords:   weave, harness, codex7, ide-merge-ide, kimi, ollama, minimax

