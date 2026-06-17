--- 01KTGFPMS85DCZ5R7AHRC4WR20 ---
  topic:      decisions-embedding-runtime
  importance: high
  weight:     0.904
  created:    2026-06-07 02:28
  accessed:   2026-06-07 02:28 (x0)
  summary:    fastembed-rs 5.16.0 crate analysis: (1) Dependency footprint is heavy - depends on ort, candle-nn/core, tokenizers, hf-hub, safetensors, serde_json, ndarray, image plus build-deps intel-mkl-src/accelerate-src (~12 direct deps with 50+ transitive crates). (2) Safety: no unsafe in fastembed's own metadata but delegates to ort FFI layer; forbid(unsafe_code) on host crate blocks it. (3) Default features pull in full ONNX C runtime via ort-download-binaries-native-tls + MKL acceleration. GPU backends available via mkl/cuda/cudnn/metal/directml features. (4) Model support: BGE family, Nomic, Qwen3 via feature flags; HF download at runtime. (5) No Tokio dependency - synchronous APIs for encoding.
  keywords:   fastembed, embedding-runtime, ort, candle, inference-backends, crate-dependency
  raw:        Deps: anyhow, hf-hub, image, ndarray, ort, safetensors, serde_json, serde, tokenizers, candle-nn/core, intel-mkl-src, accelerate-src. Features: default (ort-download-binaries-native-tls, hf-hub-native-tls, image-models), qwen3, nomic-v2-moe, mkl, cuda, cudnn, metal, directml, optimum-cli, online.

