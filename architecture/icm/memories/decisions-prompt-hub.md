--- 01KTJNTKDJKEZQKEE6EFNPM92A ---
  topic:      decisions-prompt-hub
  importance: high
  weight:     0.927
  created:    2026-06-07 22:53
  accessed:   2026-06-07 22:53 (x0)
  summary:    Cycle 68 architect plan designed malware-scan feature: heuristic-based malware detection for prompt payload/file upload scanning. Key decisions: (1) Single-file module at src/malware_scan.rs, no external deps; (2) Feature gate malware-scan = [] in both Cargo.toml files; (3) Types: ScanResult enum (Clean/Suspicious/Malicious), MalwareKind enum (6 variants), MalwareScanConfig with builder; (4) 5 detection strategies: magic number validation, shellcode patterns (NOP sleds/x86 syscalls/overlong unicode), script injection in documents, encoded payload detection (entropy+base64), extension-vs-content mismatch; (5) Hub wiring: new field (Arc<Mutex<Config>>), configure_malware_scan()/scan_for_malware()/scan_file_for_malware() methods; (6) 8 unit tests + 2 hub integration tests; (7) Shannon entropy threshold >7.5 bits/byte for suspicious text files. No migrations needed (in-memory only). Pattern mirrors sandbox/chaos feature gates. | Research on 4 embedding runtime options for prompt-hub (Rust 2024, #![forbid(unsafe_code)], multi-platform):

1) ort (pykeio/ort) - Mature ONNX Runtime bindings. ort-sys is raw FFI with unsafe extern "system" fn pointers; public ort crate wraps safely but uses unsafe internally (libloading, pointer ops). Requires ONNX C/C++ runtime via bundled binaries or system lib. Supports all embedding models including bge-m3. Heavy dependency footprint. NOT compatible with #![forbid(unsafe_code)] since both ort-sys and ort use unsafe extensively.

2) candle (huggingface/candle) - Pure Rust ML framework. Uses unsafe internally for GPU kernels but Tensor API is safe. Smaller binaries, serverless-focused. candle-onnx supports ONNX model loading but embedding model support still growing. 20k+ stars. Could work with #![forbid(unsafe_code)] at the crate level if only safe APIs are used.

3) fastembed-rs (Anush008/fastembed-rs) - Lightweight wrapper around ort for embeddings specifically. Default feature uses ort with bundled ONNX binaries, no Tokio needed. Extensive model catalog (bge-m3, all-MiniLM, nomic, Qwen3). Optional candle backend via qwen3/nomic-v2-moe features. 12k+ downloads on crates.io. Depends on ort which is unsafe, so cannot satisfy #![forbid(unsafe_code)] directly.

4) Remote API - Zero local dependencies, no unsafe code needed. But requires network access, introduces latency/privacy concerns, costs per-request. No offline capability.

Key constraint: prompt-hub requires #![forbid(unsafe_code)]. Both ort and fastembed-rs depend on unsafe code in their upstream (ort-sys is entirely FFI). The only viable path for forbid-safe code would be candle via its safe Tensor API, or a remote-only approach. | For prompt-hub's embedding/search backend selection, four inference runtimes were evaluated: (1) ort (ONNX Runtime FFI wrapper — C library dependency, ~60MB shared lib, mature model support but heavy); (2) candle (pure Rust, no unsafe, lighter but growing model coverage); (3) fastembed-rs (lightweight onnxruntime-lite FFI wrapper); (4) remote API (zero deps, online-only). Key tradeoff: ort gives widest model compatibility at cost of dependency footprint and dynamic linking; candle is the only truly safe/pure-Rust option but has narrower current model coverage. Recommendation for offline-first crate with #![forbid(unsafe_code)] target: start with remote API for dev, then candle as primary embedded engine once target models (bge-m3) are supported, keeping ort as an optional feature-gated fallback for users who need exotic models.
  keywords:   malware-scan, architecture, feature-design, prompt-hub, cycle-68, embedding-runtime, ort, candle, fastembed-rs, onnx, unsafe-code, forbid-unsafe, bge-m3, embedding, runtime, fastembed, inference, architecture-decision, sandbox, cycle-65, security, voice, cycle-66, VoicePipelineEngine, feature-flag, local-llm, architect-plan, cycle-67, P1-recovery, Ollama, llamafile, ort-sys, FFI, unsafe, adversarial-verification, claim-verification, gradual-rollout, canary, cargo.tomc, feature-gate, stateless-engine, cycle-64, canary-replace
  raw:        auto-consolidated from 10 memories

--- 01KTJVSR3GN42Y6WVA7DVMR33B ---
  topic:      decisions-prompt-hub
  importance: high
  weight:     0.927
  created:    2026-06-08 00:37
  accessed:   2026-06-08 00:37 (x0)
  summary:    Implemented offline feature for prompt_hub with 6 files changed:
1. prompt-hub/Cargo.toml - added offline = [] feature flag
2. prompthub/Cargo.toml - added offline = ["prompt-hub/offline"] forwarding
3. prompt-hub/src/lib.rs - added #[cfg(feature = "offline")] pub mod offline + re-exports for OfflineConfig, SyncStatus, ConflictEntry, OfflineStore
4. prompt-hub/src/offline.rs (~400 LOC) - full implementation with types: SyncStatus enum, ConflictEntry struct, Change enum (Create/Update/Delete), OfflineConfig (default: auto_sync=false, LWW), ConflictStrategy (LastWriteWins/LocalWins/ServerWins/Merge), OfflineStore with CRUD ops + change tracking + conflict resolution
5. prompt-hub/src/hub.rs - added offlined field to PromptHub struct, enable_offline_mode() / sync() / get_sync_status() / offlined() methods
6. prompt-hub/tests/test_offline.rs - 2 integration tests (full hub offline flow, sync conflict detection)

Clippy: clean with -D warnings across --all-features. Unit tests: 10 passed in offline::tests module. Integration tests: 2 passed.
  keywords:   offline, feature, implementation, prompt-hub

