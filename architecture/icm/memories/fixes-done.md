--- 01KTZ6KK46SPDCC7M6QA297HQH ---
  topic:      fixes-done
  importance: high
  weight:     0.975
  created:    2026-06-12 19:37
  accessed:   2026-06-13 17:13 (x3)
  summary:    FIX-1 teri COMPLETE (2026-06-12, PR #4 merged). All four sub-fixes implemented: (1) arg-parse before config (--help keyless), (2) envctl auto-injection seam via Config::load() graceful degradation + agent-env.toml manifest, (3) GGUF/stub backend guard preflight_check_backend(), (4) hygiene D10/D12 — TODO.md 737→81 lines with accurate state table, README corrected overclaims + envctl section, CLAUDE.md created. Build: cargo check ✅ test 3/3 ✅ clippy 0 errors --help keyless verified. Branch fix/keyless-envctl-gguf-guard merged to FlexNetOS/teri main. The owner-intent is explicit: envctl HOLDS THE SECRETS and auto-injects API keys — teri's LLM_API_KEY handling MUST go through envctl injection seam (agent-env.toml + Config::load() graceful degradation), NOT documented as 'export LLM_API_KEY in the shell'.
  keywords:   teri, FIX-1, envctl-injection, CLI-hygiene, stub-guard, agent-env-toml
  raw:        FlexNetOS/teri PR #4 fix/keyless-envctl-gguf-guard merged 2026-06-12
  embedding:  yes

