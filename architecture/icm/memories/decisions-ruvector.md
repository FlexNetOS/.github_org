--- 01KTQCSQ7CKYJYS10YE434DATA ---
  topic:      decisions-ruvector
  importance: critical
  weight:     1.000
  created:    2026-06-09 18:52
  accessed:   2026-06-09 18:52 (x0)
  summary:    S1 done: RuVector->meta mapping (doc RUVECTOR-META-MAPPING-S1.md). Key decision: do NOT build the 12-crate Ark Handoff Ledger from scratch — adopt the Ark CONTRACT (state-precedence/drift/provable-completion/MCP) onto existing crates: RVF+witness=ledger, weave leases=claim engine, ruvector-verified+AgentContract=provable work-order envelope (=handoff.task.v1 schema), cognitum-gate/rvf-runtime governance=policy, domain-expansion=next-task routing, rvAgent=agent runtime, MCP=universal seam. ~8 of 12 Ark crates already exist; only thin hf CLI/daemon/test glue is new. Reconciled provisional decisions: SoT=Ark state-precedence (Git>RVF-ledger>tasks; weave Jobs=coordination view, NOT crowned), envelope=handoff.task.v1 made provable, v1=the hf resume->claim->checkpoint->drift->handoff loop on existing engines. Owed: spike (RVF-as-ledger vs rusqlite; weave-lease fit), rename Ark/V2, decide front-door gap#2. NOT YET ADOPTED.
  keywords:   s1, mapping, ark-handoff-ledger, work-order, state-precedence, ruvector-verified, weave-leases, rvf-witness, domain-expansion, rvagent, not-adopted

--- 01KTQESQMF5JAREP43JDQJ7DBA ---
  topic:      decisions-ruvector
  importance: critical
  weight:     1.000
  created:    2026-06-09 19:26
  accessed:   2026-06-09 19:26 (x0)
  summary:    User-confirmed S1 decisions + front-door mapping. LEDGER #1 APPROVED: v1=rusqlite+rvf-crypto witness; RVF vector-native ledger=scheduled V2 (next-priority; aligns continuity layer with the vector-DB foundation). FRONT-DOOR MAPPING (closes gap#2): RuVocal (RuVector/ui/ruvocal = HF Chat UI fork on pgvector=ruvector-postgres + MCP + voice; mcp-bridge=tool-call router+multi-provider proxy) is the human UI; prompt_hub (Rust/axum /vibe -> SwarmBundle -> dispatch[now being built]) is the CANONICAL INTENT INTAKE for non-technical vibe coders running a single-person agentic-conglomerate multi-business. Flow: vibe coder -> RuVocal chat -> mcp-bridge -> prompt_hub /vibe -> SwarmBundle -> handoff.task.v1 envelope (gap#2 meets gap#3) -> dispatch via MCP -> rvAgent/a2a swarm, gated(cognitum)/witnessed(RVF)/ledgered(.handoff). KEY SEAM TO BUILD: SwarmBundle->handoff.task.v1 + MCP dispatch. Already-real: RuVocal vector backend = ruvector-postgres. Other doors (CLI/n8n/meta) = shims to prompt_hub. Doc: RUVECTOR-META-MAPPING-S1.md sec 5c/5d.
  keywords:   frontdoor, ruvocal, prompt_hub, pgvector, ruvector-postgres, swarmbundle, handoff-task, vibe, multi-business, ledger-v2-rvf

--- 01KTQ5R8C7EMG9DX73V6E1VTFG ---
  topic:      decisions-ruvector
  importance: high
  weight:     0.927
  created:    2026-06-09 16:48
  accessed:   2026-06-09 16:48 (x0)
  summary:    Pass-6 code-proven verdict: ruflo's @claude-flow/memory RvfBackend does NOT execute through Rust rvf-runtime. napi @ruvector/rvf RvfDatabase is opened/health-reported/closed but never used by any store/search/query op — all run over in-memory Map + pure-TS HnswLite. Rust crate rvf-adapter-claude-flow is complete (9 tests) but orphaned rlib, imported by no TS. Rust RVF napi IS real but in a different layer (dist/ruvector/vector-db.js intelligence/benchmark path, source of ~1.9-4.7x HNSW numbers), not the agent memory store. ADR-125 contradiction resolved: code matches it (HnswLite is the single public HNSW impl). Settles RUVECTOR-RESEARCH.md pass 3.
  keywords:   rvf, ruflo, napi, wiring, verdict, pass6, claude-flow, hnswlite

