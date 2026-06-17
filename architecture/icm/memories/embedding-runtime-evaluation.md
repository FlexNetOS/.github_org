--- 01KTGKQGJYTP58AM9MR369HWS3 ---
  topic:      embedding-runtime-evaluation
  importance: high
  weight:     0.904
  created:    2026-06-07 03:38
  accessed:   2026-06-07 03:38 (x0)
  summary:    Claim: "fastembed-rs v5.13.4 supports both ONNX Runtime and Candle backends through Cargo feature flags, with onnx-download-binaries-native-tls as a default feature." Refuted: (1) TextEmbedding always uses ort/ONNX -- no general Candle backend exists; Candle only for qwen3/nomic-v2-moe models. (2) Quote erroneously listed candle-nn/candle-core 0.10.2 as a feature flag when it is an optional dependency, not a [features] entry. (3) No 'candle' feature or equivalent backend-switch exists. (4) Correct default feature is ort-download-binaries-native-tls, not onnx-download-binaries-native-tls.
  keywords:   fastembed-rs, claim verification, Candle backend, ort, ONNX, feature flags

