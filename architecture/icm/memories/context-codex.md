--- 01KTFKT32HKNN2D41Y53NJ1YAS ---
  topic:      context-codex
  importance: high
  weight:     0.881
  created:    2026-06-06 18:20
  accessed:   2026-06-06 18:20 (x0)
  summary:    Created and validated the Codex Rust CLI development environment in /home/drdave/Desktop/meta/codex. Updated flake.nix devShell to use codex-rs/rust-toolchain.toml via rust-overlay, added just/cargo-nextest/cargo-insta/bazelisk/native deps, updated flake.lock rust-overlay to 2026-06-06 so Rust 1.95.0 is available, added local ignored .envrc with use flake, ran nix develop validation, just install, and cargo check -p codex-cli --bin codex successfully.
  keywords:   codex, rust, nix, devshell, cli

--- 01KTFMP5XRGKM67S5RQBAS77JA ---
  topic:      context-codex
  importance: high
  weight:     0.881
  created:    2026-06-06 18:35
  accessed:   2026-06-06 18:35 (x0)
  summary:    Built the seven-layer Codex Deep Code Harness in /home/drdave/Desktop/meta/codex. Added tools/codex-harness with a dependency-free Node CLI for repo indexing, prompt rendering, codex exec JSON/schema orchestration, schemas for debug/repo-map/review reports, workflow prompts, MCP config template, and hook telemetry script. Added project Codex agents explorer/debugger/reviewer/runtime-tracer/patcher, project config enabling hooks and agent limits, hooks.json for SessionStart/PostToolUse/Stop telemetry, and .codex/skills/deep-code-harness. Updated .gitignore for generated harness runs/telemetry. Validated with bunx prettier, node --check, JSON parsing, index generation, and prompt generation.
  keywords:   codex, harness, subagents, mcp, hooks, debugging

--- 01KTFN5M84FERXPMT6EYM6JNCN ---
  topic:      context-codex
  importance: high
  weight:     0.881
  created:    2026-06-06 18:44
  accessed:   2026-06-06 18:44 (x0)
  summary:    Added local Codex custom slash prompt /prompts:upgrade-target at ~/.codex/prompts/upgrade-target.md. It invokes -code-harness, accepts TARGET and optional SCOPE, and constrains work to upgrade-only fixes: versions, model strings, directly related prompts, tooling commands, config, schemas, or lockfiles; stop if broader product/business logic changes would be required. It also encodes the user preference for bun/bunx over pnpm/node for local JS tooling.
  keywords:   codex, slash-command, upgrade-target, deep-code-harness, bun

