--- 01KTGFGJXTERT6GKNSKGAJRHC3 ---
  topic:      decisions-embedding-search
  importance: high
  weight:     0.904
  created:    2026-06-07 02:24
  accessed:   2026-06-07 02:24 (x0)
  summary:    ort (pykeio/ort) is a safe Rust wrapper around ONNX Runtime C API via FFI (ort-sys crate). Key findings from crates.io API:

v1.16.3 (yanked, Nov 2023): Rust 2021, MSRV 1.70, 193K downloads. load-dynamic feature uses libloading to dynamically load libonnxruntime at runtime.

v2.0.0-rc.12 (Mar 5, 2026): Rust 2024 edition, MSRV 1.88, 871K downloads. Still contains unsafe blocks for FFI (libloading::Library::new, CStr::from_ptr). Does NOT bundle ONNX Runtime — requires system-provided libonnxruntime (.so/.dylib/.dll). Supports CUDA, DirectML, CoreML, OpenVINO via features.

Implication for prompt-hub: ort satisfies the embedding model requirement (bge-m3 works with ONNX), BUT it violates the #![forbid(unsafe_code)] invariant — it uses unsafe for FFI to ONNX C API. Requires onnxruntime shared library installed on target system (not dependency-light). v2 RC status means not yet fully stable.
  keywords:   ort, ONNX Runtime, embedding, FFI, unsafe, rust crate

