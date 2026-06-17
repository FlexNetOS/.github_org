--- 01KV1B29P2KK1Y0DX9Z29RF5HF ---
  topic:      preferences
  importance: medium
  weight:     1.000
  created:    2026-06-13 15:34
  accessed:   2026-06-13 15:34 (x0)
  summary:    [consolidated] OWNER ARCHITECTURE INTENT (2026-06-12, verbatim direction): envctl HOLDS THE SECRETS and is DESIGNED TO AUTO-INJECT API keys when a tool needs them — teri included. So teri's LLM_API_KEY handling must be wired through envctl's injection seam (crates/secrets-engine/src/inject.rs + secretctl/secretd phases 1-5 + the proven kasetto agent-env.toml sync --locked pattern), NOT documented as 'export LLM_API_KEY'. Expected shape: envctl run -- teri ... (child env injection) and/or agent-env.toml secret ...

--- 01KV1HQKJQSSQXDNDAFFZZKENY ---
  topic:      preferences
  importance: critical
  weight:     1.000
  created:    2026-06-13 17:30
  accessed:   2026-06-13 17:30 (x0)
  summary:    OWNER PREFERENCE (harness design): give agents a CALLABLE SKILL, never hard-wired per-agent hooks/forced steps. Verbatim: 'the agents must have a skill to call and query icm as needed. that makes this harness flexible for use anywhere. you are trying to reduce the agent ability. the lead model will delegate the task at runtime like always.' So: capabilities (ICM memory, etc.) are exposed as runtime-delegated SKILLS the lead/orchestrator hands to agents to use as-needed — NOT prescribed as fixed recall/store steps baked into each agent definition. Hard-wiring reduces agent ability + portability. Applied: new shared harness/skills/icm-memory/SKILL.md (recall-before-work + store-on-trigger + graceful no-op when ICM absent so it's portable anywhere), wired into rust-port available skills + eject + the packaged-harness-standard shared-skill set. plugin v1.10.0. Also: owner corrected me for over-asking scoping questions about the kasetto-verify + Archon-port USES — the lead delegates those at runtime; don't interrogate, make the harness flexible.
  keywords:   harness, agents, skill, icm, flexibility, delegation
  embedding:  yes

--- 01KV1RX767XW3PFPNN49EZ3M1X ---
  topic:      preferences
  importance: critical
  weight:     1.000
  created:    2026-06-13 19:36
  accessed:   2026-06-13 19:36 (x0)
  summary:    OWNER DIRECTIVE (2026-06-13, verbatim): 'never downgrade | always upgrade | stale code is usually incomplete work | work that must be complete and upgraded. not removed and downgraded.' Meaning: when you encounter stale/orphaned/uncommitted code or branches, treat it as INCOMPLETE WORK to carry FORWARD (merge/rebase/complete + upgrade), NEVER git restore/discard/remove it as 'drift'. Corrected my instinct this session: I git-restored two forward-moved files (.handoff/active.md 17/33->reverted to 15/28; .agent/skills-catalog.md 1541->reverted to 1527) and initially mis-read the orphaned HFTASK-0032 rollup branch as 'missing' — the right move was to rebase it forward (done). Derived views (active.md, skills-catalog) get upgraded by their GENERATORS (hf handoff; skills indexer), not hand-edited or frozen stale. Implement tasks FULLY: no stubs, no 'simplified for now', no dropped branches.
  keywords:   downgrade, upgrade, stale-code, incomplete-work, orphaned-branch
  embedding:  yes

