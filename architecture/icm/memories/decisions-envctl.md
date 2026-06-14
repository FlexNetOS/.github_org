--- 01KV0G9XT5N50VV07CY0ERYEVX ---
  topic:      decisions-envctl
  importance: medium
  weight:     1.000
  created:    2026-06-13 07:46
  accessed:   2026-06-13 07:46 (x0)
  summary:    [consolidated] hf continuity kernel (meta/handoff) links bundled C SQLite via its ledger crate (rusqlite/libsqlite3-sys, static). NOT an envctl no-c.sh violation (separate workspace, not an envctl crate) so it does not block TASK-0001. But it conflicts with the agenticOS Epic A north star 'pure-Rust, no C in the trust boundary'. If the kernel itself must be C-free, that is a kernel-side port of meta/handoff's ledger crate off rusqlite — out of envctl no-c gate scope. Flagged in loop_state needs_human/supervise...

--- 01KV0HZAY8FVR5M6JQ7MHBMZNK ---
  topic:      decisions-envctl
  importance: high
  weight:     1.000
  created:    2026-06-13 08:15
  accessed:   2026-06-13 08:15 (x0)
  summary:    PR-2b secrets auto-injection (env-ctl run): OQ1 peer-binding chosen as UID-PRIMARY (mint with client_pid=0), NOT exec-replace. Reason: broker/decide.rs check 11b only enforces client_pid when bound; PR-2a proxy.rs:401 sends peer_pid:None per request and re-checks only uid, so a non-None pid bind would deny every swap (PeerMismatch). Child runs as same uid as secretctl so uid binding holds. secretd Relay.Mint now fills MintResp.injection (fail-closed None if proxy_addr unbound) via conv::injection_to_proto + inject::injection_template. secretctl Cmd::Run: mint->ChildEnvPlan->in-process Engine::run_child->exit(code). Branch secrets-inject-pr2b, NOT committed.
  keywords:   envctl, secrets, secretd, secretctl, injection, peer-binding, OQ1, env-ctl-run, PR-2b
  embedding:  yes

--- 01KV0JMZ6MY7X19XS7605FGT1W ---
  topic:      decisions-envctl
  importance: high
  weight:     1.000
  created:    2026-06-13 08:27
  accessed:   2026-06-13 17:13 (x1)
  summary:    envctl seed-factor Seed transport switched from shelling ssh to a direct pure-Rust pinned-CA HTTPS client (ring-only rustls, already in graph) hitting POST /api/v1/custody/sign — fixes secretctl unlock failing under the env-ctl.service systemd sandbox (ProtectHome=read-only broke ssh known_hosts). Token-at-rest decision LOCKED: ENVCTL_SEED_TOKEN env or 0600 file at $XDG_DATA_HOME/env-ctl/seed-token (inside unit ReadWritePaths); rotation = re-mint-on-demand via USB-only pair window under stable client envctl-daemon. no-C stays green. envctl#61 merged 2026-06-13. Criterion 3 (live unlock) owner-gated. KBTASK-SEED-UNLOCK-UNDER-SYSTEMD.
  keywords:   envctl, seed-factor, custody, rustls, systemd, unlock, cognitum-seed
  embedding:  yes

