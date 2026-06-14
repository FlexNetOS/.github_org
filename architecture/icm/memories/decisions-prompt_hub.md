--- 01KV10DJN5KEC3BXWC47WAYB1A ---
  topic:      decisions-prompt_hub
  importance: critical
  weight:     1.000
  created:    2026-06-13 12:28
  accessed:   2026-06-13 18:27 (x4)
  summary:    prompt_hub handoff adoption COMPLETE in 2 PRs: #82 migrated DATA (40 handoff.task.v1 cards + derived packet + capsule + active + history, _workspace archived). #83 copied the FULL kernel .handoff SUBSTRATE structure from meta/handoff/.handoff (reference) + adapted to member: policy.toml (origin FlexNetOS/prompt_hub, trunk main, prefix prompt-), policies/rules.toml (fail-closed gates + protected-file guard + blocked cmds), hooks/{hooks.toml,loop-entry.sh,session-end.sh} (member model: render via 'hf fleet render prompt_hub', invoke prompt-loop skill), skills/session-resume.skill.md, decisions/ADR-0001-adopt-handoff-kernel.md. STRUCTURE PARITY with kernel confirmed. MEMBER RULES (ADR-0004 §3): NO local ledger.db (never copy kernel's binary history; member events -> FLEET ledger meta/.handoff), no fleet/ census. Hooks present but NOT auto-wired into .claude/settings.json (classifier blocked as unauthorized behavior change; left opt-in, documented in README). hf fleet render -> Done 27/40. Next card PHTASK-0028 (P0 default-features build fix). LESSON: 'copy the .handoff directory' meant copy the FULL reference structure (substrate dirs), not just populate the thin seed.
  keywords:   handoff, hf, .handoff, migration, ledger-kernel, intent_lock, prompt-loop, ADR-0004, blake3
  embedding:  yes

--- 01KV17RMZQGFDK483YQYNK6MQQ ---
  topic:      decisions-prompt_hub
  importance: high
  weight:     1.000
  created:    2026-06-13 14:36
  accessed:   2026-06-13 16:20 (x1)
  summary:    PROMPT_HUB LOOP LESSONS (2026-06-13): (L1) The migrated 2026-06-07 audit backlog carries STALE 'dead/incomplete module' claims — multimodal_input.rs + templates.rs were ALREADY fully implemented; the real gap was WIRING. ALWAYS verify code-vs-prose per card (Rust-native invariant: code wins). (L2) Worktree-per-cycle is MANDATORY — concurrent sessions switch branches under you (confirmed: PR#92 from another session landed mid-session). Use git worktree add off origin/main; never work in shared meta/prompt_hub checkout. (L3) hf MEMBER-MODEL: 'hf fleet render prompt_hub' ALWAYS targets meta/prompt_hub (main checkout), never a worktree — a worktree cycle CANNOT render its own packet; packet is derived + regenerates on resume from merged cards (cards=source of truth). Do NOT commit a packet from a worktree; commit cards+active+code only. (L4) default-features build can be masked by CI-only-all-features — add explicit default-build job (PHTASK-0028). (L5) Cycle PRs serialize on shared .handoff packet/active; branch off latest main each cycle.
  keywords:   prompt_hub, lessons, worktree, hf-member-model, stale-backlog, default-features
  embedding:  yes

--- 01KTQ4VEGYSQBN1GA37RAY7GBZ ---
  topic:      decisions-prompt_hub
  importance: medium
  weight:     0.857
  created:    2026-06-09 16:33
  accessed:   2026-06-09 16:33 (x0)
  summary:    [consolidated] Design created for P1 accessibility output formatting feature (WCAG-compliant prompt output). Key decisions: no new deps, pure stdlib + serde_json; types in single file accessibility.rs; transform() returns Result<AccessibleOutput> with 4 variants (PlainText, StructuredJson, DyslexiaFriendly, HighContrastBraille); hub integrates accessible_output(+) and accessible_output_all(); braille uses U+2800 base with dot-7 (0x40) for case distinction; dyslexic uses middot separators + unicode line spacing...

