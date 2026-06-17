--- 01KV1QK2TZ4NYP3R09DJ0RF0CQ ---
  topic:      decisions-handoff
  importance: medium
  weight:     1.000
  created:    2026-06-13 19:13
  accessed:   2026-06-13 19:13 (x0)
  summary:    [consolidated] [consolidated] [consolidated] [consolidated] FORGOTTEN DIRECTIVES (user, critical) for ADR-0001/handoff: (1) ENVCTL has a SECRET RELAY/INJECTION tool that must be INTEGRATED into the loop's secrets handling (refines ADR §9.5 - not just GitHub org secrets; use envctl's relay/injection). (2) The handoff pkg SOURCE must be cross-referenced against ~/Downloads/tmp/handoff (or /tmp/handoff) IN CASE a LITE version was created - current ~/Desktop/meta/handoff might be a downgrade/lite of a fuller versi...

--- 01KV1SGAGYYSV0T2JY1FDD86XX ---
  topic:      decisions-handoff
  importance: high
  weight:     1.000
  created:    2026-06-13 19:46
  accessed:   2026-06-13 19:46 (x0)
  summary:    HFTASK-0033 (verify_rollup_provenance + hf fleet status 3-layer verification) gatekeeper verdict: APPROVE, witnessed (hf review verdict HFTASK-0033 0 approve --by gatekeeper; KERNEL 414->415). Independently confirmed the load-bearing provenance bridge: rollup_from (ledger lib.rs:389,406) STORES origin_action_hash=hash_action(event_type,work_order_id,payload_json); verify_rollup_provenance (lib.rs:501-518) RECOMPUTES the SAME recipe from stored content + byte-compares to origin_action_hash -> faithful by construction, tamper(payload_json) breaks it (proven by detects_tampered_row test, the failure direction). Scope clean: handoff/** only (ledger+hf), NO Cargo.toml (no-dep honored), verifier pure SELECT (read-only+no-network honored), P7/forbidden_ledger/collect_rows/verify_witness_chain untouched (no downgrade; 0034 surface not entered). Evidence re-run: 71 tests (15 ledger+56 hf), clippy --all-targets -D warnings clean (PR#30 mirror), fmt clean. LIVE hf fleet status: (i) central 433/433 witnessed; (ii) 3 per-repo chains standalone (handoff 414ev/414witnessed); (iii) provenance FAITHFUL 407/407, JSON has rollup_provenance+per_repo_chains_verified+members[].per_repo_chain. AC met verbatim. NON-BLOCKING finding: live P7 warnings (prompt_hub/weave stray ledger.db) + 407 handoff rows in FLEET ledger are pre-existing 0032 data state (owner-flagged open) — this change REPORTS them, correct. NEXT: hf done HFTASK-0033 --pr N after PR; then HFTASK-0034 (P7 flip).
  keywords:   HFTASK-0033, rollup-provenance, gatekeeper, verify_rollup_provenance, fleet-status, ADR-0004
  embedding:  yes

