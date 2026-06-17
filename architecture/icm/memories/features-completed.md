--- 01KTJKJFQPSAWY5TJXXS8WPBA8 ---
  topic:      features-completed
  importance: high
  weight:     0.904
  created:    2026-06-07 22:14
  accessed:   2026-06-07 22:14 (x0)
  summary:    Implemented chaos-automation feature for prompt_hub:
- Feature flag added to prompt-hub/Cargo.toml (chaos-automation = ["chaos"]) and prompthub/Cargo.toml (chaos-automation = ["prompt-hub/chaos-automation"])
- Created prompt-hub/src/chaos_auto.rs with types: ChaosSchedule, ChaosRunRecord, ChaosTrigger, AlertAction, ChaosAutoConfig, ChaosAuto struct, TrendDirection enum
- Key methods on ChaosAuto: new(), shutdown(), evaluate_trend() (linear regression), recent_pass_rate(), run_chaos(), trigger_run(), spawn_task(), history(), history_mut(), is_enabled()
- Added chaos_auto field to PromptHub struct in hub.rs with #[cfg(feature = "chaos-automation")]
- Added chaos_auto() accessor and start_chaos_auto() lifecycle method on PromptHub
- Module declared in lib.rs alphabetically between chaos and circuit-breaker
- 6 unit tests in chaos_auto.rs (trend_rising, trend_falling, trend_stable, history_rotation, alert_on_threshold, trend_insufficient_data)
- 4 integration tests in prompt-hub/tests/test_chaos_auto.rs (records_and_stores_run, history_respects_max_entries, trend_detection_works_end_to_end, all_public_types_accessible)
- Clippy clean (-D warnings), all features compile, tests pass
  keywords:   chaos-automation, feature-implementation, prompt-hub, chaos-auto, clippy-clean

