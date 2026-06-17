--- 01KTD9ZAWBXE23QMP7CEKRXZ9J ---
  topic:      decisions-idd-merge
  importance: high
  weight:     0.918
  created:    2026-06-05 20:50
  accessed:   2026-06-06 18:54 (x5)
  summary:    rusty-idd .cargo/audit.toml is SHARED (auto-loaded by every cargo audit incl. promote-verify.yml). So a vulnerability (e.g. time RUSTSEC-2026-0009) must NOT go in it — that would defeat the develop->main promotion wall. Vulns are fixed forward or tolerated via a per-workflow --ignore flag in ci.yml; only accepted unmaintained-WARNINGS go in the shared baseline. A3 bincode/yaml-rust = accepted-risk (syntect 5.3.0 latest still pulls them; dropping = losing TUI highlight-code capability = forbidden downgrade); documented in docs/rusty-idd/security-advisories.md.
  keywords:   cargo-audit, supply-chain, accepted-risk, promote-verify, syntect

--- 01KTD9Z85FRG02X6G1PBE6F2Y0 ---
  topic:      decisions-idd-merge
  importance: high
  weight:     0.900
  created:    2026-06-05 20:50
  accessed:   2026-06-05 21:03 (x2)
  summary:    idd-merge-loop auto-merge RACE: stacking two cycle commits on ONE auto-merging PR strands the later commit — CI greens the 1st commit and GitHub squash-merges before the 2nd is pushed. A1+A2 hit this (A2 stranded, recovered via cherry-pick onto fresh branch off advanced develop). RULE: ONE PR PER CYCLE; never add a commit to a PR with auto-merge armed; if prior PR still open, stack the next cycle off ITS branch. Baked into _workspace/loop_state.md pr_policy + HANDOFF.
  keywords:   auto-merge, race, one-pr-per-cycle, idd-merge-loop, stacking

