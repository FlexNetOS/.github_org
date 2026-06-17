--- 01KV15S45CG4BAZMYJKSREM4FA ---
  topic:      context-lane
  importance: high
  weight:     1.000
  created:    2026-06-13 14:01
  accessed:   2026-06-13 18:27 (x5)
  summary:    lane's .handoff continuity kernel ALREADY EXISTS on origin/main (prior session): lane-specific context/capsule.json + README.md + packets/tasks .gitkeeps. GOTCHA: handoff-loop-init's hf init idempotency only checks LOCAL working dir — on a stale local main (behind origin) it didn't see the existing kernel and ran hf init anyway, producing GENERIC handoff-default content (capsule project_name='handoff'/RuVector, not lane). Lesson: git fetch BEFORE running handoff-loop-init. Net useful gap found+fixed: origin/main's .gitignore had ZERO .handoff rules, so a local hf ledger.db could be accidentally committed. PR #29 (lane) lands ONLY the P7 residency guard: .handoff/ledger.db + .handoff/*.db. Auto-merge armed, green pending.
  keywords:   handoff, hf init, kernel, gitignore, ledger, stale checkout
  embedding:  yes

--- 01KV1C6AQZHVYS80MG9C50VJMT ---
  topic:      context-lane
  importance: high
  weight:     1.000
  created:    2026-06-13 15:53
  accessed:   2026-06-13 15:53 (x0)
  summary:    LANE IMPLEMENTATION SESSION 2026-06-13 (owner directive: 'obscura and phase 7 need implementation first; phase B as described but A must finish first'). Decoded: Phase A (prereqs) gates Phase B (Option-B seam). A1=obscura impl/integration (separate repo — NOT empty: it's a real 8-crate built engine obscura-browser/cdp/dom/js/mcp/net/cli, 188 commits; 'implementation'=estate integration+build/verify); A2=finish lane Phase 7 Round B (lane's scope). SHIPPED: PR #31 docs(roadmap) re-sequence Phase A gates B + corrected obscura-state error in ADR/VISION. PR #32 feat(install): 'lane install --service' — FIRST Phase-7 Round B feature (A2). src/service.rs (pure systemd-unit/launchd-plist renderers + user-level install()) + src/cli/install.rs (--service/--enable/--print/--json); ExecStart re-execs binary with _LANE_DAEMON=1; ARCHITECTURE.md service module contract + docs/commands.md; +5 tests=228 green; clippy/fmt clean; 100% Rust-native; auto-merge armed. REMAINING Phase 7 Round B: ACME, config template, reverse-tunnel syntax, inspect TUI, multi-hop tunnel. Then Phase B seam (ADR-0001 docs/adr), then Phase C lane relay.
  keywords:   phase 7, install service, systemd, launchd, implementation, A2, sequencing
  embedding:  yes

--- 01KV1E2HTC9EYXR7HBV8SMMYPF ---
  topic:      context-lane
  importance: high
  weight:     1.000
  created:    2026-06-13 16:26
  accessed:   2026-06-13 16:26 (x0)
  summary:    LANE PHASE 7 ROUND B PROGRESS (2026-06-13, driving per owner 'keep driving Round B'): #32 lane install --service (systemd/launchd, MERGED). #33 feat(share) reverse-tunnel forward syntax 'lane share R:[remotePort:][localHost:]localPort' (auto-merge armed) — new src/tunnel/forward.rs ForwardSpec+FromStr, threaded ClientOptions.local_host through client forward path (empty=>localhost), positional [FORWARD] arg + resolve_target exactly-one-of --port/spec; KEY INSIGHT: NO wire-format change needed (forward target is client-side; remote_port advisory since lane assigns public URL by subdomain/domain; tunnel server not in repo). +12 tests=240 green, clippy/fmt clean, 100% Rust-native. REMAINING Round B: ACME (--acme, network-heavy), lane config template (self-contained), lane inspect TUI (large), multi-hop tunnel (greenfield). Then Phase B seam (ADR-0001), Phase C lane relay. Pattern: one feature per PR, worktree-per-task, auto-merge.
  keywords:   phase 7, round B, reverse tunnel, share, forward spec, implementation
  embedding:  yes

--- 01KV1GB5GV6JEHA2TWR1SK0MW2 ---
  topic:      context-lane
  importance: high
  weight:     1.000
  created:    2026-06-13 17:06
  accessed:   2026-06-13 17:06 (x0)
  summary:    LANE PHASE 7 ROUND B — 4 of 6 DONE (2026-06-13): #32 install --service (systemd/launchd, MERGED), #33 share reverse-tunnel R: syntax (MERGED), #34 config template (MERGED — project::render_template starter .lane.yaml, no template-engine dep), #35 lane inspect live request-inspector TUI (auto-merge armed — new pure src/inspect.rs Entry::parse+State + src/cli/inspect.rs crossterm alt-screen/raw-mode TUI tailing access log, comfy-table render, non-TTY snapshot fallback; crossterm dep ALREADY in-tree via comfy-table = 0 new transitive deps; +12 tests=254). KEY: config name-collision gotcha — cli/mod.rs has  so a  CLI submodule needs crate uses fully-qualified to crate::config::. REMAINING Round B (2): ACME --acme (network-heavy, needs real LE challenge — hard to verify unattended), multi-hop tunnel (greenfield, needs tunnel server not in repo). Both are server/network-dependent → best deferred or done when those endpoints exist. After Round B completes => Phase A2 done; Phase A1=obscura integration (separate repo) still gates Phase B seam (ADR-0001). Pattern holding: one feature per PR, worktree-per-task, auto-merge, ARCHITECTURE+docs+backlog synced each PR.
  keywords:   phase 7, round B, config template, inspect TUI, crossterm, implementation
  embedding:  yes

--- 01KV1HXSGVGFC195308192ZFH8 ---
  topic:      context-lane
  importance: high
  weight:     1.000
  created:    2026-06-13 17:34
  accessed:   2026-06-13 17:34 (x0)
  summary:    LANE PHASE 7 ROUND B — 5 of 6 DONE (2026-06-13). #36 feat(acme) lane start --acme FEATURE-GATED Let's Encrypt issuance (auto-merge armed): new src/acme.rs — always-compiled pure parts (AcmeParams::validate, directory_url, challenge_path, ChallengeStore, minimal HTTP-01 serve_http01 responder, 7 tests) + #[cfg(feature=acme)] issue() via instant-acme 0.7.2 (account->order->http-01->finalize rcgen CSR->download) + fail-closed no-feature stub. start --acme/--acme-email/--acme-staging; cert written to ~/.lane/acme/<domain>/; proxy resolver (proxy::server load_leaf/ensure_leaf) PREFERS on-disk ACME cert via cert::acme_exists/load_acme_tls/write_acme. KEY LEARNINGS: (1) instant-acme default features = hyper-rustls+ring (NOT aws-lc) — use defaults, no need to disable; (2) aws-lc-rs is ALREADY in lane's default tree (via reqwest rustls-tls) — lane's ring invariant is the RUNTIME provider install, not the dep tree, so acme feature introduces no new violation; (3) read vendored crate source in ~/.cargo/registry/src to nail an external API offline. Both default AND --features acme clippy-clean; 261 tests. REMAINING Round B (1): multi-hop tunnel (greenfield, needs tunnel server NOT in repo → can't fully verify in-repo, same constraint as ACME's live path). After that Phase A2 complete; Phase A1=obscura integration (separate repo) gates Phase B seam (ADR-0001).
  keywords:   phase 7, round B, acme, letsencrypt, feature-gated, instant-acme, implementation
  embedding:  yes

--- 01KV1TK2RW0ZWK2KT2MWGD7TMS ---
  topic:      context-lane
  importance: high
  weight:     1.000
  created:    2026-06-13 20:05
  accessed:   2026-06-13 20:05 (x0)
  summary:    lane session 2026-06-13: delivered owner's 'next 5 tasks' = Phase-7 Round B COMPLETED 6/6 (multi-hop tunnel lane share --hop SOCKS5/HTTP chains, PR #38) + Phase-8 lane web governed-egress seam mechanism (webpolicy #39, src/web seam+CLI+config #40, ADR-0001 ratified). Integrated main green: 351 tests default / 350 --features obscura, clippy+fmt clean, 100% Rust-native. main @ c20a326. NEXT per owner sequence 1→4→3: step 4 = pivot to Phase A1 obscura integration (repo FlexNetOS/obscura — build+verify 8 crates + exercise MCP surface; the real gate that un-gates lane's live lane web), then step 3 = lane DONE-gate. Resume from _workspace/HANDOFF.md.
  keywords:   Phase-7, Phase-8, multi-hop, lane web, milestone
  embedding:  yes

--- 01KTYSY3KMDQT0WP9X8RBS026W ---
  topic:      context-lane
  importance: medium
  weight:     0.950
  created:    2026-06-12 15:56
  accessed:   2026-06-12 15:56 (x0)
  summary:    [consolidated] Weave's multi-crate workspace (weave-core ← weave-inject ← weave-mcp ← weave) is interim; single-crate architecture is the goal after meta workspace alignment (WL-043 deferred). | Weave CI requires 6 blocking checks on master: rustfmt, clippy, test, build (libsql backend), sign, libsql+sign. | Weave process: Always create worktrees from origin/develop after `git fetch`; develop branch mirrors master via fast-forward. | Weave invariants are security-critical: no shell spawning (Command only), all...

