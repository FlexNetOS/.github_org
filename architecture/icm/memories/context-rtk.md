--- 01KTFNYZ13NJ8MY0S5PNZ5ENKX ---
  topic:      context-rtk
  importance: high
  weight:     0.904
  created:    2026-06-06 18:58
  accessed:   2026-06-06 18:58 (x0)
  summary:    Verified RTK 0.42.0 wiring across Claude Code, Gemini, Codex, and Devin. Claude Code has native PreToolUse Bash hook rewriting commands via 'rtk hook claude' and rtk verify passes 145/145 tests. Gemini now has global BeforeTool run_shell_command hook at ~/.gemini/hooks/rtk-hook-gemini.sh invoking 'rtk hook gemini'. Codex RTK 0.42 uses prompt-level wiring only: ~/.codex/AGENTS.md includes ~/.codex/RTK.md with 'Always prefix shell commands with rtk'. RTK 0.42 has no native Devin init target, so Devin was wired with native global always-on rules in ~/.config/devin/AGENTS.md plus Windsurf-compatible ~/.windsurf/rules/rtk.md with trigger: always_on; 'devin rules show rtk' reports Activation always-on.
  keywords:   rtk, claude, codex, gemini, devin, hooks

--- 01KTFV0MM5EZWBA13CKVH3YV2V ---
  topic:      context-rtk
  importance: high
  weight:     0.904
  created:    2026-06-06 20:26
  accessed:   2026-06-06 20:26 (x0)
  summary:    Verified Kimi CLI RTK path. Active 'kimi' resolves to /home/drdave/.local/bin/kimi (Kimi Code 0.11.0); active 'rtk' resolves to /home/drdave/.local/bin/rtk (rtk 0.42.0). Kimi Code embedded source loads ~/.kimi-code/AGENTS.md, so added ~/.kimi-code/AGENTS.md instructing shell commands to use absolute RTK path /home/drdave/.local/bin/rtk. 'kimi doctor' validates ~/.kimi-code/config.toml and skips only missing tui.toml. Legacy kimi-cli 1.47.0 remains at ~/.local/share/uv/tools/kimi-cli/bin via symlinks, but its installed Python source has no hook implementation found for 'hooks'.
  keywords:   kimi, rtk, path, kimi-code, AGENTS

