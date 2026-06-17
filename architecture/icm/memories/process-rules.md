--- 01KTZ914JDYW8DRSC83MTWFSXB ---
  topic:      process-rules
  importance: critical
  weight:     1.000
  created:    2026-06-12 20:20
  accessed:   2026-06-12 20:20 (x0)
  summary:    API Constraint Adherence: When performing tool operations based on provided documentation (like a skill's internal reference), I must strictly adhere to the *defined* tool names and signatures. My previous error using `gitkb_search` was because it does not exist in the explicit Skill definition; the correct, available methods are `kb_semantic`, `kb_search`, etc. When unsure, I must review the provided skill documentation for a mapping between the intended function and the callable tool name.
  keywords:   process-rule, tool-usage, api-adherence
  embedding:  yes

--- 01KTZ97R6RPQ2CPECNY9T2YKCJ ---
  topic:      process-rules
  importance: critical
  weight:     1.000
  created:    2026-06-12 20:23
  accessed:   2026-06-12 20:23 (x0)
  summary:    Search Failure Recovery Protocol: When a conceptually ideal tool (e.g., semantic search) is required but not explicitly available in the current API set, first attempt to map its intent to an existing, documented function via `gitkb` skills list. If mapping fails, document the *intent* and the resulting failure state in ICM as a "Lesson Learned" before selecting the closest functional alternative (e.g., use `kb_search` or `kb_semantic` if it exists) rather than stopping entirely. Never assume an abstract capability without finding its concrete tool counterpart.
  keywords:   agentic-autonomy, failure-recovery, tool-mapping
  embedding:  yes

