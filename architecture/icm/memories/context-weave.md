--- 01KV1B2FP1KBJ3GVZ4Y6BBWXKP ---
  topic:      context-weave
  importance: medium
  weight:     1.000
  created:    2026-06-13 15:34
  accessed:   2026-06-13 15:34 (x0)
  summary:    [consolidated] [consolidated] [consolidated] Converted migration briefing to tracked task. | All linked to handoff state.", | "summary": "PR #77 BLOCKED by 3 pre-existing CI failures (docs, coverage, safety) — NOT caused by the PR itself. | "summary": "Census found 12 empty-or-stub repos (my-wiki, network_hub, flow_hub, database_hub, template_hub, vault_hub, plugin_hub, tool_hub, etc.). | "role": "Pure-Rust Cargo workspace (8 crates) that declaratively manages this dual-RTX-5090 box: env-manager (engine+cli+gu...

--- 01KV1DQGPGF5DBCK2G023XYBZ3 ---
  topic:      context-weave
  importance: high
  weight:     1.000
  created:    2026-06-13 16:20
  accessed:   2026-06-13 16:20 (x0)
  summary:    weave session 2026-06-13 FINAL state: master==develop==1a9bc1f. Shipped WL-046/047/048/049 + FOUR runtime /verify-found fixes (PRs #72-80): kill false-success (#76), SSRF encoded-loopback bypass (#78), SSRF QA coverage + artifact cleanup, domain-'*'-wildcard footgun (#80). Repowire-superset: 35/36 + governed obscura web access. NEXT: WL-050 token-light progressive-disclosure MCP (ADR-0003). Standing process debts: (a) deny git push/gh pr to weave-* subagents (self-delivery hazard, #77), (b) CI duplicate-run concurrency fix, (c) WL-053 capture mux socket in peer target.
  keywords:   weave, session, WL-049, WL-050, verify
  embedding:  yes

--- 01KV1H9MR9C9J16CVNARD12S01 ---
  topic:      context-weave
  importance: high
  weight:     1.000
  created:    2026-06-13 17:23
  accessed:   2026-06-13 17:23 (x0)
  summary:    weave session 2026-06-13b: shipped the next 4 mission cards as 4 merged PRs (#82 WL-050, #84 WL-051, #83 WL-053, #85 WL-052). develop==b7c13c2 (master syncing via sync-master). Baseline 581 sqlite / 541 libsql, green. WL-050: token-light progressive-disclosure MCP — 73 eager flat weave_* tools collapsed to ONE standing 'weave' meta-tool (modes search/describe/call/list); tool_catalog() is the canonical 73-op registry; eager-flat fallback via WEAVE_MCP_EAGER=1; meta call re-applies safe-HTTP dangerous gate to inner op + refuses self-recursion. WL-051: token-light is now a CLAUDE.md invariant + CI budget gate MAX_STANDING_TOOLS_BYTES=8192 (standing_mcp_surface_is_within_token_budget test). WL-053: capture $TMUX socket at registration (persisted on EXISTING peers.socket column - NO schema change) and thread tmux -S <socket> through inject/spawn/kill/liveness; socket-less peers keep historical argv. WL-052: docs-only foundation - docs/MULTI-SURFACE-PARITY.md proves CLI+MCP at full parity, dashboard(read-only)+bots(relay) v1 baseline; remaining write-parity decomposed into WL-052a (dashboard write) + WL-052b (bot commands).
  keywords:   WL-050, WL-051, WL-052, WL-053, mcp, parity, token-light
  embedding:  yes

--- 01KV1PB7K4S573ASCDE52SE3RQ ---
  topic:      context-weave
  importance: high
  weight:     1.000
  created:    2026-06-13 18:51
  accessed:   2026-06-13 18:51 (x0)
  summary:    weave session 2026-06-13c (3 tasks 'knock out the next three'): PR #87 CI concurrency fix (push scoped to master/develop + concurrency group, kills the duplicate-run flake that forced reruns all prior session); PR #88 bundles WL-052a (dashboard --write: bearer-gated POST /api routed through the SAME dispatch_request->call_tool handler as MCP/CLI, read-only default POST->403, +2 integration tests) AND WL-052b (Telegram bot /inbox //peers //sessions //help via the same handler, read-only v1, pure parser/mapper/formatter +3 unit tests, Slack reuses grammar=follow). Both honor the one-handler-many-surfaces design law (route to same handler, never parallel impl). Added PullConsent::empty() in mcp.rs. Gate green: 610 surfaces tests, clippy clean default/libsql/surfaces/libsql+surfaces. NOT YET MERGED at session end (#87/#88 armed auto-merge; merge-train means each goes BEHIND as the other merges -> resume must merge develop+push to re-arm). Worktrees still present: weave-ci-concurrency, weave-wl052a-dash.
  keywords:   WL-052a, WL-052b, CI, dashboard, bot, one-handler
  embedding:  yes

--- 01KV1R19MQFJ3W3S4047VYHJGC ---
  topic:      context-weave
  importance: medium
  weight:     1.000
  created:    2026-06-13 19:20
  accessed:   2026-06-13 19:20 (x0)
  summary:    A `compile_error!` in `main.rs` rejects enabling both features together.
  keywords:   kind:constraint

--- 01KV1R19MXRGJTGJ81B631MWKS ---
  topic:      context-weave
  importance: medium
  weight:     1.000
  created:    2026-06-13 19:20
  accessed:   2026-06-13 19:20 (x0)
  summary:    1304:pub fn federated_sessions(local: &dyn Store, extra: &[StoreSource]) -> Result<Vec<SessionView>> {
  keywords:   kind:bugfix

--- 01KV1R58JYTTGGQVAZ77AS6T3F ---
  topic:      context-weave
  importance: medium
  weight:     1.000
  created:    2026-06-13 19:22
  accessed:   2026-06-13 19:22 (x0)
  summary:    `ledger.db`; do NOT hand-write packets.
  keywords:   kind:preference

--- 01KV1R58K3MH4S7WC6CB3QS0SQ ---
  topic:      context-weave
  importance: medium
  weight:     1.000
  created:    2026-06-13 19:22
  accessed:   2026-06-13 19:22 (x0)
  summary:    A concurrent `meta/handoff` session shipped them: `hf fleet status`/`fleet render`
  keywords:   kind:milestone

--- 01KV1R58K67R7Y73B2XZ6AJB6X ---
  topic:      context-weave
  importance: medium
  weight:     1.000
  created:    2026-06-13 19:22
  accessed:   2026-06-13 19:22 (x0)
  summary:    The installed `~/.local/bin/hf` was rebuilt
  keywords:   kind:bugfix

--- 01KV1R58K8XBJG4B8T7WA116XM ---
  topic:      context-weave
  importance: medium
  weight:     1.000
  created:    2026-06-13 19:22
  accessed:   2026-06-13 19:22 (x0)
  summary:    **FINDING-0002's blocker is RESOLVED**
  keywords:   kind:bugfix

--- 01KV1R58KB78SW7KA3JMHCZGVQ ---
  topic:      context-weave
  importance: medium
  weight:     1.000
  created:    2026-06-13 19:22
  accessed:   2026-06-13 19:22 (x0)
  summary:    CAUTION: a concurrent session may still be active in `meta/handoff` — do NOT commit/build
  keywords:   kind:preference

--- 01KV1R58KEC6Q29BF90GK88N9N ---
  topic:      context-weave
  importance: medium
  weight:     1.000
  created:    2026-06-13 19:22
  accessed:   2026-06-13 19:22 (x0)
  summary:    NOTE: the broken `.kb` SessionStart hook was already FIXED (`meta/.claude/settings.json`:
  keywords:   kind:bugfix

--- 01KV1R5BFN02WM81C1STF30TJX ---
  topic:      context-weave
  importance: medium
  weight:     1.000
  created:    2026-06-13 19:23
  accessed:   2026-06-13 19:23 (x0)
  summary:    `.handoff/README.md` (FLEET ledger = `meta/.handoff/ledger.db`; member packets via `hf fleet
  keywords:   kind:architecture

--- 01KV1TXFD4REFDH459EG06TN70 ---
  topic:      context-weave
  importance: high
  weight:     1.000
  created:    2026-06-13 20:11
  accessed:   2026-06-13 20:11 (x0)
  summary:    weave-loop CYCLE 1 (autonomous resume 2026-06-13): WL-034 static mailbox export DONE -> PR #90 (auto-merge armed, CI green except slow libsql builds pending). weave export --out <path> [--for <id>] [--limit N]: self-contained offline XSS-safe HTML of caller's mailbox, vanilla-JS client search. New weave-core/src/export.rs holds pure render_mailbox_html + CENTRALIZED html_escape (single XSS source; weave-mcp dashboard now reuses it). XSS hinge: messages embed as JSON in <script type=application/json> with </ -> <\/ breakout neutralization, rendered via textContent; <noscript> fallback html_escaped. Reuses Store::history (per-identity) -> NO Store/schema/dual-backend change, NO new dep, NO standing MCP tool (ADR-0003). Gate GREEN 590 sqlite/550 libsql + surfaces + sign. Guardian APPROVE. Filed WL-034b (whole-DB cross-identity export needs new dual-backend all_messages() + privacy decision - deferred). Reconciled stale latest.md packet: WL-050/051/052/053/052a all landed since WL-049; WL-052a(#88) flipped to [x]. cycles_this_session=1/3. Next mechanical item WL-035 (mailbox backup/restore, atm-core parity) - start AFTER #90 merges to avoid backlog.md conflict.
  keywords:   weave, WL-034, mailbox-export, html, xss, export.rs, weave-loop, PR90
  embedding:  yes

