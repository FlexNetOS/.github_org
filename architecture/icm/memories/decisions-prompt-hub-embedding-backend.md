--- 01KTGF628RFDREXA288PTZ1EA0 ---
  topic:      decisions-prompt-hub-embedding-backend
  importance: high
  weight:     0.912
  created:    2026-06-07 02:19
  accessed:   2026-06-07 04:01 (x1)
  summary:    fastembed-rs v5.13.4 (2026-04-27, Apache-2.0) supports ONNX (ort 2.0.0-rc.12) and Candle (candle-nn/candle-core 0.10.2) via feature flags. Zero unsafe code — pure safe Rust. Default features include ort-download-binaries-native-tls which pre-bundles ONRT binaries (no system C/C++ install). Supports CUDA/Metal/MKL/directx. Model coverage: BGE-M3, MiniLM, image embeddings, reranking, Qwen3/nomic (opt-in). Dependencies: hf-hub 0.5.0 for model downloading from HuggingFace Hub. Key advantage over ort crate: no system-level ONRT dependency — uses bundled binaries via feature flag.
  keywords:   fastembed-rs, ONNX Runtime, Candle, embedding, inference runtime, safe Rust, ort, model coverage
  raw:        Features: ort-download-binaries, ort-load-dynamic, cuda, cudnn, metal, directml. No unsafe blocks in source.

