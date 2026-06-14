--- 01KTDC1T4ZJTP7FK9JX69Q04JN ---
  topic:      context-idd-merge
  importance: high
  weight:     0.919
  created:    2026-06-05 21:26
  accessed:   2026-06-06 20:09 (x10)
  summary:    idd-merge-loop EPIC A COMPLETE (supply-chain & build hygiene), shipped as PRs #26-#31 to develop, each one-PR-per-cycle with auto-merge: A1 cargo-audit CI gate + shared .cargo/audit.toml baseline; A2 time 0.3.41->0.3.47 (RUSTSEC-2026-0009 fixed); A3 bincode/yaml-rust accepted-risk (docs/rusty-idd/security-advisories.md); A4 pin CI @1.96.0 + msrv job @1.88.0 + per-crate rust-version (core=1.74, spec/runner/tui/cli=1.88); A5 flake.nix hard assert rustc>=1.88; A6 dup-versions documented no-op (docs/rusty-idd/dependency-duplication.md). MSRV floor=1.88 (edition2024 + let-chains stabilized 1.88 + time 0.3.47 + ratatui 0.30). Suite stayed 429 throughout (upgrade-only). Next: Epic B (runtime robustness) starting B1. develop->main promotion unblocked but deferred to full-backlog DONE.
  keywords:   epic-a, supply-chain, msrv, 1.88, cargo-audit, rusty-idd, complete

