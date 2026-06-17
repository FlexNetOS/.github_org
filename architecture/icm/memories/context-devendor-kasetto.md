--- 01KV0248GTY4Z13ABCYYQMN1K3 ---
  topic:      context-devendor-kasetto
  importance: medium
  weight:     1.000
  created:    2026-06-13 03:38
  accessed:   2026-06-13 03:38 (x0)
  summary:    [consolidated] The `retry_on_failure` feature has been fully implemented in `crates/runner/src/config.rs` and `runner.rs`: a `u32` field added to `TuiConfig` with default value 1, controlling how many consecutive no-progress runs trigger a per-task stall before the global STALL_THRESHOLD = 3 limit. | All config deserialization tests pass, including legacy YAML without the field (defaults to 1), explicit values, and round-trip serialization; all runner tests pass (22 tests across the workspace). | The implement...

