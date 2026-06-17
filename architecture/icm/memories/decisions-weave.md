--- 01KV1QJZ84CR6YK9J9F3VMQC0A ---
  topic:      decisions-weave
  importance: medium
  weight:     1.000
  created:    2026-06-13 19:12
  accessed:   2026-06-13 19:12 (x0)
  summary:    [consolidated] weave WL-049 obscura integration (ADR-0002 accepted): SPAWN-AND-SPEAK stdio MCP, NOT a crate dep. weave spawns 'obscura mcp' (separate binary, stdio newline-delimited JSON-RPC) via argv-only std::process::Command and acts as a minimal hand-rolled MCP CLIENT (std::io + serde_json, NO tokio/async/V8 in weave). All web surfaces (dashboard WL-048, web WL-049) are CLI subcommands + ONE dispatcher tool, NOT 35 eager MCP tools (ADR-0003 token-light). Heavyweight deps (reqwest, browser) stay behind feat...

