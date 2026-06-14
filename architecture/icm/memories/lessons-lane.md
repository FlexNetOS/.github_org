--- 01KV1MXBAH0RZNBAQ6KGVZMYC6 ---
  topic:      lessons-lane
  importance: high
  weight:     1.000
  created:    2026-06-13 18:26
  accessed:   2026-06-13 18:26 (x0)
  summary:    LANE SESSION LESSONS 2026-06-13 (Phase 7 Round B impl): (1) To nail an EXTERNAL CRATE API offline, read the vendored source in ~/.cargo/registry/src/index.crates.io-*/<crate>-<ver>/ — got instant-acme 0.7.2's Account::create/new_order/authorizations/key_authorization/set_challenge_ready/refresh/finalize(csr.der())/certificate exactly right, compiled first try. (2) RING INVARIANT is the RUNTIME provider (install ring default_provider), NOT the dep graph — aws-lc-rs is ALREADY in lane's default tree via reqwest rustls-tls, so don't false-alarm when cargo tree shows aws-lc under a new feature; verify default tree first. (3) instant-acme default features = hyper-rustls+ring (no aws-lc) — use defaults. (4) A  CLI submodule COLLIDES with  (E0255) — fully-qualify the crate uses to crate::config::. (5) crossterm was already in-tree via comfy-table → adding it as direct dep = 0 new transitive deps; check Cargo.lock before assuming a dep is heavy. (6) For un-CI-able LIVE paths (ACME LE round-trip needs public FQDN+:80), FEATURE-GATE the live driver, keep all pure parts + the mechanism always-compiled+tested, fail-closed when feature off. (7) VISION questions: don't read only the repo's _workspace/ — the real north-star lived in the meta census (ARCHITECTURE-TRUTH.md/NORTH-STAR.md) + .handoff capsule; trace cross-workspace.
  keywords:   instant-acme, vendored crate, offline API, ring, aws-lc, feature gate, crossterm, name collision
  embedding:  yes

