--- 01KV1B24N1SVAGASRXM1EQV663 ---
  topic:      decisions-harness_hub
  importance: medium
  weight:     1.000
  created:    2026-06-13 15:34
  accessed:   2026-06-13 15:34 (x0)
  summary:    [consolidated] harness_hub restructured to owner vision: harness_hub = library of per-use-case PACKAGED HARNESSES exposed as /harness:<name> commands (the harness plugin is now factory + library). Convention codified in docs/packaged-harness-standard.md: orchestrator skill in harness/skills/<name>/, agents in shared harness/agents/ pool (infra shared & unprefixed: build-health-auditor/integration-qa/continuity-steward; specialists per-harness name-prefixed e.g. meta-plugin-registry-curator), registry.json cata...

--- 01KV1BMRRR3H4G3KH5BWZK5617 ---
  topic:      decisions-harness_hub
  importance: high
  weight:     1.000
  created:    2026-06-13 15:44
  accessed:   2026-06-13 19:20 (x4)
  summary:    rust-port harness extended (via /harness:harness, owner-directed) with 3 capabilities, adversarially verified (both gate-integrity + merge-wiring claims CONFIRMED, no must-fix): (1) PORT-AND-MERGE (ADR-0001 rust-port->rust-port-merge arc): port repo X to Rust AND merge each verified unit into destination repo Y, re-verified in Y. New agent rust-port-merge-integrator + skill rust-port-merge + references/merge-ledger.md (landing decision new/merge-into/map-onto-Y-substrate, grit symbol-locks, reuse>duplicate-never-by-narrowing, re-parity-verify in Y). ITERATE gains MERGE step, DONE gains merge-ledger-100%/Y-green, loop_state gains dest_repo + merge counter. (2) Research/discovery agent rust-port-researcher (X<->Y reuse map, reuses code-research+deep-research) + cross-repo reference agent rust-port-cross-repo-referencer (blast-radius/contract map via git-kb callers/callees/impact + meta) + cross-repo-reference skill. (3) AUTOMATED 3-MODEL WORKFLOW, owner chose GATE-PROTECTED split: opus=gates+hard design (architect, parity-verifier, merge-integrator, evolution-steward, cartographer PRE-DONE sweep), sonnet=workers (cartographer-inventory, porter, researcher, continuity), haiku=mechanical (build-health, cross-repo-referencer). KEY LAW: every no-downgrade GATE stays opus; tiering a worker is safe because the opus parity gate catches worker downgrades (cost lever, not correctness risk). Shared agents overridden per-call (scope law), not by editing shared frontmatter. Team 7->10 agents, 11 skills, plugin v1.7.1->1.8.0. Branch feat/rust-port-merge-3model.
  keywords:   rust-port, merge, 3-model, cross-repo, researcher, harness-extension
  embedding:  yes

--- 01KV1EEQJBK4QADAD1KHTZSW4X ---
  topic:      decisions-harness_hub
  importance: high
  weight:     1.000
  created:    2026-06-13 16:33
  accessed:   2026-06-13 16:33 (x0)
  summary:    rust-port MERGE hardened (owner: 'tune it. find gaps and upgrade the rust-port merge'). Independent gap-hunt agent + adversarial verifier (all 9 gaps CLOSED, wired producer->consumer->gate, no gate weakened, no porter-skip hole). 9 gaps, 4 HIGH, all rooted in 'the harness forgot Y is a real, separate, consumer-having, mutable git repo': G1 Y git discipline (per-task worktree+feature branch dest_branch/dest_worktree/dest_base, commit-per-merge to Y, PR-into-Y+auto-merge at merge-DONE, two commits/cycle); G2 DUAL no-downgrade (capture Y's behavioral baseline at DISCOVER -> findings/y-regression.md, diff after each merge; regressing Y's own behavior = [!]/[neq], symmetric with X rule); G3 atomicity (git reset --hard/worktree-discard + grit-lock-release-on-rollback, commit-iff-all-gates-pass); G4 up-front 4-class classification (port-fresh/extend-Y/reuse-Y/map-onto-substrate) from researcher reuse map DRIVES ITERATE - reuse-Y/map-onto SKIP the fresh port and verify Y/substrate against X (no wasted re-ports; still opus-gated against X, reuse-that-diverges reclassifies to extend-Y); G5 Y-drift rebase+re-verify drifted merged units on resume; G6 Y-runnable+substrate-availability fail-fast at DISCOVER; G7 breaking-contract RESOLUTION (additive/shim/version), not just flag (DONE now satisfiable); G8 merge order by Y's dependency graph (callees in Y); G9 dup-scan before new-module, symbol-grain via re-verify, lock-release-on-rollback. KEY GENERAL LESSON (LESSONS.md): any cross-repo-WRITE harness needs worktree+branch+PR per target, atomic commit-iff-pass with tree rollback, BIDIRECTIONAL no-downgrade, up-front reuse-classification driving the loop, target-drift reconciliation. plugin v1.8.0->1.9.0. Branch feat/rust-port-merge-tune.
  keywords:   rust-port, merge, no-downgrade, cross-repo, worktree, gap-fix
  embedding:  yes

