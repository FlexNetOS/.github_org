# 05 — RuVector Core Substrate

The RuVector substrate is a single interconnected Rust-native system — a "MASSIVE distributed cognitive vector-DB + AGI runtime" of ~216 `crates/` plus ~93 `examples/` (314 `Cargo.toml` total at the time of the walk) — rather than a loose pile of separate example apps. This document renders the proven core of that substrate: the **unifying abstraction** (a small orthogonal trait set over the vector `Vec<f32>`), the **proven crate graph** (340 internal dependency edges across 213 internal crates), the **cognitum** hardware tier (the physical Cognitum Seed appliance), the **ruvix** bare-metal cognition kernel, the **rvf** self-bootstrapping vector-native container format, the **rvm** coherence-native micro-hypervisor, the **rvAgent** Rust-native agent framework, and the surrounding **ruv ecosystem** (ruflo = claude-flow v3, the ruvnet TS→Rust dev pattern). All findings here are code-as-truth (the RuVector prose is treated as untrusted); each concept carries the source memoir's confidence, which is a flat **0.5** for most concepts (or **0.6** for two) — below the 0.7 flag threshold despite being labelled CODE-PROVEN, so material claims are flagged in QUESTIONS below. Dates, paths, crate names, IDs, and verdict revisions are preserved verbatim from the ICM `system-architecture` memoir.

> **Note on confidence.** Every concept in this cluster carries a stored scalar confidence of **0.5** (or **0.6** for `cognitum-seed-activation-ref` and `ruvix-cognition-kernel-subsystem`). All are below the 0.7 threshold and are therefore flagged. The memoir nonetheless marks most as **CODE-PROVEN / walked**; the low scalar appears to be a default rather than a genuine uncertainty signal. Treat the *named facts* (crate names, file paths, types, dep edges) as code-verified and the *interpretive theses* as research-grade.

---

## 1. The unifying abstraction and the proven crate graph

### 1.1 RuVector unifying abstraction (`ruvector-unifying-abstraction`, conf 0.5)

Pass 4b, **CODE-PROVEN 2026-06-09** by reading `core/types.rs`, `core/index.rs`, `attention/traits.rs`, `mincut/lib.rs`. It is **NOT one god-trait** — it is a **SMALL ORTHOGONAL TRAIT SET over ONE universal datum: the vector `Vec<f32>`**. Layers:

1. **VECTOR layer** (`ruvector-core`): datum `VectorEntry{id:VectorId=String, vector:Vec<f32>, metadata}` + `DistanceMetric{Euclidean/Cosine/DotProduct/Manhattan}` + the central trait `VectorIndex{add, add_batch, search(query,k)->Vec<SearchResult>, remove, len}` (`core/src/index.rs:11`) + `EmbeddingProvider` trait (text→vector).
2. **GRAPH layer** (`ruvector-graph` + `ruvector-mincut`): vectors become nodes, `EdgeInfo{src,dst,features}`; mincut exposes `DynamicMinCut`/`DynamicConnectivity`/`ExpanderDecomposition`/`Conductance`/`Cluster`/`ClusterHierarchy`/`EulerTourTree`/`LinkCut` + certificate/witness = the **BOUNDARY/COHERENCE primitive on dynamic graphs**.
3. **ATTENTION/GEOMETRY layer** (`ruvector-attention`): trait hierarchy `Attention{compute(q,keys,values)->Vec<f32>}` → `GraphAttention{compute_with_edges(node_features, &[EdgeInfo])}` → `GeometricAttention{compute_geometric(...,curvature)}` + Sparse/Trainable; plus modules `hyperbolic`/`curvature`/`topology`/`transport`/`info_bottleneck`/`info_geometry`(Fisher, NaturalGradient)/`pde_attention`(GraphLaplacian, diffusion)/`sheaf` = weighted propagation over the vector-graph in Euclidean / hyperbolic / information-geometric space.
4. **DOMAIN layer COMPOSES 1–3**: `ruvector-consciousness` = compose(mincut + coherence + solver + sparsifier + math + cognitive-container) computing **IIT-Phi**; `ruvllm` = compose(attention + gnn + graph + core + sona).

**THESIS = "coherence-aware hypergraph":** nodes = vectors, edges = graph, weights = attention, boundaries/clusters = mincut, persistence = RVF. Domain crates define **NO new substrate** — they are compositions. Corroborated by `RuVector/CLAUDE.md` `brain_partition='get MinCut clusters'`.

Graph relations: `refines` → `ruvector-crate-graph-proven`; `related_to` → `rvf-is-self-bootstrapping-container`; receives `part_of`/`instance_of` from cognitum-gate-tier, examples-interconnection, foundation-solver-math-dag, mcp-brain-server-convergence, ruvix-cognition-kernel-subsystem, rvm-microhypervisor-subsystem.

### 1.2 The proven crate graph (`ruvector-crate-graph-proven`, conf 0.5)

Pass 4a, **CODE-PROVEN 2026-06-09 via parsing 213 `Cargo.toml` manifests** (`/tmp/crate_graph.py`). **PROVES the user's claim**: the crates are ONE interconnected system, NOT separate examples. Metrics: **213 internal crates, 149 with ≥1 internal dep, 340 internal dependency edges.**

**TOP HUBS (in-degree):** `rvf-types` 26, `ruvix-types` 25, `ruvector-core` 24, `ruvector-mincut` 16, `rvf-runtime` 16, `ruvector-attention` 10, `rvf-crypto` 9, `ruvector-gnn` 8, `ruvix-cap` 8, `rvagent-core` 8, `ruvector-graph` 7.

**THREE interlocking clusters that CONVERGE:**

1. **vector/compute core:** `ruvector-core` → gnn/graph/mincut/attention → `ruvllm` + consciousness/perception/neural-trader/prime-radiant.
2. **RVF:** `rvf-types` → rvf-runtime/crypto/wire → `rvf-node` + `rvf-adapter-claude-flow` (the ruflo bridge) / `rvf-adapter-agentdb`.
3. **ruvix Cognition Kernel:** `ruvix-types` → ruvix-cap/region/queue/hal.

**PROOF of interconnection:** `ruvector-mincut` depended on by **18** crates incl. `cognitum-gate-kernel`/`tilezero`, consciousness, perception, mcp-brain-server, prime-radiant; `ruvllm` depends on attention + core + full + gnn + graph + sona. **CONVERGENCE POINT:** `mcp-brain-server` depends on mincut + ruvllm + rvf-runtime (all 3 clusters). The "domain example" crates share the same hub infrastructure = **interconnected by construction**.

### 1.3 Pass-1 shape (`ruvector-pass1-shape`, conf 0.5)

Code-as-truth 2026-06-09 (docs are stale per `claude-hook-blocks-edits`). RuVector (`~/Desktop/meta/RuVector`) is a **MASSIVE distributed cognitive vector-DB + AGI runtime: ~216 Rust crates + 59 npm pkgs.** Layers:

- **vector core** (`ruvector-core` HNSW/SIMD/quantization, REDB),
- **hypergraph DB** (`ruvector-graph`, Neo4j/Cypher-compatible, RAFT cluster),
- **LLM serving** (`ruvllm`: paged attention / KV-cache, Metal/CUDA/CoreML-ANE/Hailo),
- **boundary-first scientific discovery** (min-cut, IIT consciousness Phi, 20+ domain apps: SETI/seismic/EEG/markets),
- **the RVF AGI format cluster.**

Intelligence entry points = MCP servers (mcp-brain, mcp-gate) + npm `@ruvector/*` + `.claude` hooks/skills (claude-flow V3 config). Hardware: SIMD/CUDA/Metal + Hailo-10H NPU (Pi 5). 24 `-wasm` crates (wasm-bindgen). **NOTE: RuVector has NO dependency on ruflo (integration is one-way: ruflo consumes RuVector).**

Graph relations: `part_of` → `stack-topology-reality`; receives `refines` from ruvector-crate-graph-proven, rust-native-system-overview; receives `related_to`/`part_of` from cognitum-is-ruvector-hardware, rvf-kernel-wasm-bridge, mincut-graph-indexzoo, ruflo-is-claude-flow-v3, repo-docs-accuracy.

### 1.4 Knowledge-export scaffold (`ruvector-knowledge-export-scaffold`, conf 0.5; status verified)

`docs/research/knowledge-export/ruvector-knowledge.rvf.json` (23KB, 371 lines) = a RuVector-authored **v2.0-era** knowledge export shaped as `.rvf` segments (META/PROFILE/WITNESS/INDEX/OVERLAY/SKETCH/JOURNAL/CRYPTO/VEC). It is **NOT per-crate detail** (snapshot says **91 crates / 55 ADRs**; repo has since grown to **314 manifests / 180+ ADRs**) → **use as SCAFFOLD only; strict per-crate reads still required.**

**AUTHORITATIVE `dependency_chains`:**

1. **graph_transformer_stack:** `ruvector-core` → gnn → attention → mincut → solver → coherence → verified → graph-transformer (8 verified modules: sublinear/physics/biological/self-organizing/verified-training/manifold/temporal/economic).
2. **llm_stack:** core → sona → {attention, graph, gnn} → `ruvllm` (paged attn, KV cache, Candle, Metal/CUDA/CoreML, GGUF, LoRA).
3. **postgres_stack:** pgrx → simsimd → {solver, math, attention, sona, domain-expansion, mincut-gated-transformer} → `ruvector-postgres` (pg14–17 via pgrx, pgvector drop-in, **230+ SQL fns**).
4. **rvf_stack:** rvf-types → wire → manifest → index → quant → crypto (claims **ML-DSA-65 + Ed25519 + SHAKE-256** — see contradiction in §4) → runtime → adapters/*.

`crate_taxonomy` groups: core_engine(core/graph/math/collections), neural_networks(gnn/attention/graph-transformer/mincut-gated-transformer/sparse-inference/fpga-transformer), solvers_and_algorithms(solver/mincut/filter/dag), llm_serving(ruvllm/-cli/-wasm), persistence(postgres/server). `architectural_eras`: v0.1_foundation → v1.0_expansion → v2.0_unification.

> **Contradiction (recorded in the memoir):** `method-docs-untrusted-code-only` **contradicts** `ruvector-knowledge-export-scaffold` — the export's crate count (91) and the ML-DSA-65 claim are stale/false against code. Use the scaffold for *chains*, not for *counts* or *crypto*.

---

## 2. Research mission and the meta mapping

### 2.1 Mission (`research-mission-ruvector-crate-map`, conf 0.5; status active, user-authoritative)

**MISSION (user-corrected, authoritative):** We are RESEARCHING the ruvnet ecosystem via RuVector by **MAPPING** — specifically (1) how the RuVector example apps all interconnect, and (2) where ruflo fits in. **We have NOT installed or adopted RuVector or ruflo.** We map the RUST-NATIVE crates in RuVector FIRST, then later map them into meta + the meta repos.

**REQUIREMENT:** every crate in RuVector must be THOROUGHLY WALKED (**314 `Cargo.toml`: 216 `crates/`, 93 `examples/`, + roots**). **Method:** read crates DIRECTLY (Bash/Read), **NOT subagents** (forge-loop/weave-relay hijack). The ruflo-wiring deep-dives (pass3/6/6b) matter only as "where ruflo connects to the crate graph" (answer: `ruvector` npm facade → `@ruvector/rvf`=`rvf-node`→`rvf-runtime` / `@ruvector/rvf-wasm`=`rvf-wasm`; + `ruflo-core` witness → `rvf-node`). Coverage tracked in a durable ledger file `~/Desktop/meta/RUVECTOR-CRATE-LEDGER.md`. **Do NOT rat-hole on ruflo internals;** the unit of work is a RuVector crate/cluster.

### 2.2 S1 synthesis — RuVector → meta mapping (`s1-ruvector-meta-mapping`, conf 0.5; NOT YET ADOPTED)

S1 synthesis, grounded in SESSION-HANDOFF + STACK-INTEGRATION-PLANS + Ark Handoff Ledger PRD v2 + the full 314-crate walk. Doc: `~/Desktop/meta/RUVECTOR-META-MAPPING-S1.md`.

**DECISIVE INSIGHT:** the **Ark Handoff Ledger** (12-crate Rust workspace, spec-only) is largely a **FROM-SCRATCH RE-IMPLEMENTATION** of capabilities RuVector ALREADY ships production-grade ⇒ per **T2 (prefer the rust crate)** and **no-rebuild**, DON'T build the 12 Ark crates cold; KEEP the Ark **CONTRACT** (state-precedence + drift sentinels + leases + evidence-backed/provable completion + MCP) as the spec, MAP its engine onto existing crates.

**MAPPING (Ark need → RuVector, verdict):**

| Ark need | RuVector mapping | Verdict |
|---|---|---|
| handoff-ledger | RVF `rvf-runtime`+`rvf-crypto` WitnessChain, or temporal-tensor | ADOPT (tamper-evident) |
| handoff-drift | `ruvector-perception`(BoundaryPredictor) + `ruvector-coherence`(HnswHealthMonitor) + blake3 intent-locks | ADOPT+GLUE |
| handoff-policy | `cognitum-gate-tilezero` `decide()`/Permit-Deny-Defer + `rvf-runtime` governance + neural-trader CoherenceGate | ADOPT |
| lease engine | `weave` `weave_lease_*` ALREADY in meta + `rvm-cap`/`ruvix-cap` | REUSE |
| evidence/completion | `ruvector-verified`(Lean ProofAttestation) + verified-applications::AgentContract | ADOPT (killer feature = PROVABLE work-order) |
| handoff-mcp | mcp-gate/mcp-brain/rvagent-mcp pattern (T11) | ADOPT |
| handoff-git/index | meta worktree + GitKB | REUSE-meta |
| task DAG | `ruvector-dag` (QuDAG governance) | — |
| routing/next-task | `domain-expansion` (bandit selector) | — |
| agent runtime/swarm | rvAgent (`rvagent-core`/subagents/middleware, deployed in a2a-swarm; mirrors Ark sub-agent/swarm classes 1:1) | — |
| hf CLI+daemon+test | thin glue | BUILD |

**NET:** of 12 Ark crates **~8 already exist**; only thin `hf` CLI/daemon/test glue is new.

**RECONCILE the 3 provisional decisions:** (1) SOURCE-OF-TRUTH revise from "weave Jobs SoT" → adopt **Ark STATE-PRECEDENCE** (Git = physical, RVF-witnessed ledger = operational, weave Jobs = coordination VIEW via `correlation_id`) — closes gap#1. (2) WORK-ORDER ENVELOPE = the Ark **`handoff.task.v1`** schema (`id/title/status/priority/objective/path_scope/acceptance_criteria/test_commands/deps/allows_network`) carried end-to-end, made PROVABLE by `ruvector-verified` → closes gap#3; home in a tiny `work_order` crate. (3) V1 SCOPE (smallest) = the Ark loop `hf resume→claim→start→checkpoint→drift→handoff` built on weave leases + RVF witness + thin `hf` CLI, NOT 12 new crates; keep session-relay loop as runner, `hf` replaces narrative `HANDOFF.md`.

**STILL OWED before build:** a SPIKE (RVF-as-ledger ergonomics `rvf-node-napi` vs `rusqlite`; weave-lease↔Ark-lease fit), rename Ark/V2 → **Continuity Ledger Kernel/v1**, decide front-door gap#2 (prompt_hub intake vs MCP federation). **NOT YET ADOPTED — recommendation only.**

> The spike later **PASSED** (4/4 tests, ICM `context-ruvector` 2026-06-09 19:38): `work-order` crate = `handoff.task.v1` envelope + SwarmBundle→WorkOrder seam (carries `workflow_id` as `correlation_id`) + blake3 IntentLock drift sentinel; `ledger` crate = `rusqlite`(WAL) event store + REAL `rvf-crypto` witness chain (standalone, no `rvf-runtime`/napi) + replay. ~150 LOC + 1 path-dep. "S2 LOCKED. RVF vector ledger = scheduled v2." (This is the only live meta→RuVector code edge today: the handoff/ledger path-dep on `rvf-crypto`.) See [02-handoff-continuity](02-handoff-continuity.md).

---

## 3. Cognitum — RuVector's hardware tier

### 3.1 Cognitum is RuVector's hardware (`cognitum-is-ruvector-hardware`, conf 0.5)

**COGNITUM = RuVector's HARDWARE coherence-gate tier** (pass 1). Crates `cognitum-gate-kernel` + `cognitum-gate-tilezero` target **Pi 5 / Hailo-10H NPU "TileZero"** for hardware-accelerated coherence gates; `mcp-gate` exposes anytime-valid coherence permission/veto (**ADR-178**). The physical **COGNITUM SEED** (Pi Zero, 64GB, full agentic stack, on USB) is the hardware embodiment of this tier and the entry point to ruvector/ruflo — but is currently unreachable (network wall + USB secret-key wall). Learn it via its HTML files when reachable. Ties hardware-network-walls to the ruvector stack.

### 3.2 Cognitum Seed activation reference (`cognitum-seed-activation-ref`, conf 0.6; verified via `seed.cognitum.one/guide.html` 2026-06-09)

It is a **ZERO-CONFIG edge appliance** (Raspberry Pi Cortex-A53 / 512MB, Rust `cognitum-agent` at `/opt/cognitum`, systemd `cognitum-agent.service`). On USB it auto-exposes **3 interfaces with NO unlock key:**

1. USB mass-storage **COGNITUM** FAT32 (guide + trust certs);
2. USB-net RNDIS/ECM gadget at **169.254.42.1**;
3. mDNS **cognitum.local**.

**Access:** `ssh genesis@169.254.42.1` (pw `cognitum`); HTTP API port 80 (reads open, writes need bearer token via pairing `POST /api/v1/pair/window` then `/api/v1/pair`); MCP at `http://169.254.42.1/mcp`; RVF store at `/var/lib/cognitum/rvf-store/`.

**CRITICAL RECONCILIATION:** the seed needs **NO secret key**, so the **envctl secret-key USB is a DIFFERENT device — do not conflate.**

**PROBE 2026-06-09:** seed plugged but NOT reachable — no 169.254/usb iface, no COGNITUM mount, no ping, no mDNS, no API. Likely cause = USB OTG **DATA** port not connected (power-only) or RNDIS/ECM gadget not enumerating; fix is physical (replug data port) = **NEEDS-HUMAN hardware action.**

> **Later resolution (ICM `context-cognitum` 2026-06-13 07:46):** access pivoted from MCP to SSH (owner: MCP = token suck, 114 tools/21 groups, ADR-058). SSH key **ENROLLED 2026-06-13**: `ssh genesis@169.254.42.1` pw `cognitum` (the password is printed in the LIVE device-served `/guide` line ~2111, NOT in the static `guide.html` on the read-only COGNITUM drive). Appended `~/.ssh/id_ed25519.pub` (SHA256:wU27yvDRHUJgPMk) to genesis `authorized_keys`; passwordless key-auth verified → host `cognitum-578b` `armv7l`. SSH key possession = candidate envctl-USB possession factor. (See [03-envctl-kasetto](03-envctl-kasetto.md).)

### 3.3 Cognitum Seed boot requirement (`cognitum-seed-boot-requirement`, conf 0.5; user 2026-06-09)

**Hot-plug does NOT enumerate the USB gadget interfaces — the seed must be PLUGGED IN AT BOOT.** Working procedure (used before): boot the OS with the seed already connected; the USB-net gadget (`169.254.42.1`)/mass-storage/mDNS then come up. Replugging while running does not work (likely BIOS USB handoff / gadget-at-boot timing). It was NOT plugged in at last boot, hence currently unreachable. **ACTION = reboot workstation with seed attached (NEEDS-HUMAN).** Until then the seed + its `/mcp` + RVF store stay unreachable.

> **Board-class nuance to reconcile (from §5.1):** activation-ref says **Pi Zero / Cortex-A53 / 512MB**; `cognitum-is-ruvector-hardware` says **Pi 5** for `cognitum-gate-tilezero`; `ruvix` targets **bcm2711 (Pi 4 / CM4 / Pi 400-class)**; the 2026-06-13 SSH probe returned **`armv7l`** (32-bit). These do not all agree — see QUESTIONS.

---

## 4. RVF — the self-bootstrapping vector-native container format

### 4.1 RVF format internals (`rvf-format-internals`, conf 0.5; pass 2, code-verified 2026-06-09)

The `.rvf` file is a **SEGMENT-TYPED binary container**. Segment types (`rvf-types/src/segment_type.rs`): `Vec(0x01)`/`Index(0x02 HNSW)`/`Hot(0x08)`/`Meta(0x07)`/`Journal(0x04)`/`Manifest(0x05)`/`Quant(0x06)`/`Sketch(0x09)`/`Witness(0x0A)`/`Crypto(0x0C)`/`Profile(0x0B)`/`Kernel(0x0E)`/`Ebpf(0x0F)`/`Wasm(0x10)`/`Dashboard(0x11)`/`CowMap(0x20)`/`Refcount`/`Membership`/`Delta`.

**TWO-LEVEL MANIFEST:** Level 0 root = fixed **4096 bytes at EOF**, magic **RVM0 `0x52564D30`**, hotset pointers (Entrypoint/TopLayer/Centroid/QuantDict/HotCache/Prefetch), epoch+count+dim+signature+CRC32C — enables **<5ms boot / approx-query without Level 1**; Level 1 = variable TLV segment directory (loaded async for full quality).

`RvfStore` API (`rvf-runtime/src/store.rs`): `create`/`open`/`open_readonly`/`ingest_batch`/`query`/`query_with_envelope`/`compact`/`delete`/`write_manifest`; has COW engine + membership filter + parent path (branching). Indexing = **3-layer progressive HNSW** (A entry <5ms ~0.70 recall, B ~0.85, C full ≥0.95). Quant = Scalar/Product/BinaryThreshold/ResidualPq.

### 4.2 RVF is a self-bootstrapping container (`rvf-is-self-bootstrapping-container`, conf 0.5; KEY INSIGHT pass 2)

The `.rvf` "AGI file format" is **NOT just storage** and `rvf-kernel` is **NOT a bytecode VM**. The container **EMBEDS real executables** that let a `.rvf` self-bootstrap as compute:

- `rvf-kernel` embeds a Linux **bzImage** / **Hermit unikernel** / **Asterinas** (validates boot-sector magic `0x55AA` + `HdrS` header);
- `rvf-wasm` embeds WASM with roles `Microkernel(0x00` = ~5.5KB **"Cognitum tile runtime"**, 14+ exports)/`Interpreter`/`Combined`/`Extension`/`ControlPlane` targeting Wasm32/WASI/Browser/**BareTile**;
- `rvf-ebpf` embeds eBPF (`XdpDistance` computes L2/cosine in the NIC/kernel fast path, sub-microsecond).

The embedded kernel/microkernel reads the manifest and **mmaps segments directly**. `rvf-types` is `no_std` (runs on wasm/embedded/Hailo/TEE). **THIS is why ruvector is "way more than you think": a `.rvf` is a portable, self-executing, vector-native compute artifact.** The "Cognitum tile runtime" ties directly to the cognitum seed hardware.

### 4.3 RVF kernel + WASM bridge (`rvf-kernel-wasm-bridge`, conf 0.5; pass 1 — the ruvector↔ruflo connection)

**RVF = RuVector Format:** binary append-only vector store (segments + manifest + HNSW index + quantization Int8/RaBitQ + ed25519 witness/proof chain + compaction). Crate cluster `~/Desktop/meta/RuVector/crates/rvf/` (rvf-types/crypto/wire/runtime[VM]/kernel[temporal bytecode]/ebpf/index/quant/federation/adapters). `agentdb.rvf` in ruflo = AgentDB persisted in RVF.

**THE BRIDGE:** RuVector crates compile to WASM (`wasm-bindgen`) → ruflo lazy-loads them with JS fallback (exemplar: `v3/plugins/gastown-bridge` loads `gastown-formula-wasm` + `ruvector-gnn-wasm` via `LazyWasm` cache; **150–352× speedups**) → `rvf-adapters/claude-flow` bridges ruflo `@claude-flow/memory` `RvfBackend` to `rvf-runtime` `RvfStore`. Uses plain wasm-bindgen ES-module exports (**NOT WASM component model / WIT**). **Direction: ruflo CONSUMES RuVector WASM + RVF; RuVector has no ruflo dep.**

### 4.4 RVF witness / governance (`rvf-witness-governance`, conf 0.5; pass 2)

**Tamper-evident witness chain** (`rvf-crypto/src/witness.rs`): `WitnessEntry = {prev_hash[32], action_hash[32]=SHAKE-256(action), timestamp_ns, witness_type(0x00 PROVENANCE / 0x01 COMPUTATION)}`, **73 bytes/entry**, chained via `prev_hash = SHAKE-256(prev)`. `verify_witness_chain` detects tampering.

**Governance** (`rvf-runtime/src/witness.rs`): `GovernanceMode Restricted/Approved/Autonomous`; `PolicyCheck Allowed/Denied/Confirmed`; `GovernancePolicy.hash()`; each task emits a **Witness Bundle** (spec/plan/tool-trace/diff/test-log/outcome/governance-mode/cost/latency/retry). **Governance is EMBEDDED in the container as policy flags + cost bounds, not a central authority.** ed25519 + lineage records for provenance.

> **TWO witness schemes in the ecosystem** (from §6): RVF's is **73-byte SHAKE-256**; RVM's `rvm-witness` is a **lighter, different 64-byte fixed record + FNV-1a hash chain**. `rvm-microhypervisor-subsystem` is marked `alternative_to` `rvf-witness-governance`.

### 4.5 Full rvf-cluster code-walk (`codewalk-rvf-cluster`, conf 0.5; 26 crates, walked, role:memory)

CODE-TRUTH walk of the full rvf cluster (**26 crates**).

**FORMAT CORE (deps prove the stack, T4):**
- `rvf-types`(`no_std` foundation; deps **serde + ed25519-dalek**; types bake GOVERNANCE vocab into the format itself: `BudgetType, AuthorityLevel, AttestationWitnessType, ChecksumAlgo, CompressionAlgo, DeltaEncoding, CowMapEntry, DegradationReason`) →
- `rvf-wire`(binary block layout: `Level0Root[4KB instant-boot root], BlockDirectory, HotEntry, VecBlock, NodeAdjacency, RestartPointIndex`; deps xxhash+crc32c+sha3+subtle) →
- `rvf-manifest`(two-level: `Level1Manifest, SegmentDirectory, TlvRecord, BootState, HotsetPointers, OverlayChain[branching]`);
- `rvf-index`(**SELF-CONTAINED no deps**: `HnswGraph + LayerA/LayerB/LayerC` = 3-layer progressive HNSW, CONFIRMED in code);
- `rvf-quant`(`TemperatureTier, Scalar/ProductQuantizer, CountMinSketch, Quantizer` trait);
- `rvf-crypto`(`WitnessEntry, TeeBoundKeyRecord, QuoteVerifier` trait = TEE remote-attestation; deps **ed25519-dalek + sha3 ONLY**);
- `rvf-runtime`(self-contained over `rvf-types` ONLY: `ActionClass, CoherenceState, CompactionState, DistanceMetric, FilterExpr, EcLevel[erasure coding]`).

> **DOC-CONTRADICTION (FLAG):** knowledge-export claims `rvf-crypto` does **"ML-DSA-65 post-quantum signatures"** but real deps are **ed25519-dalek + sha3 only — NO ML-DSA/dilithium** (PQ crypto lives in `ruvector-dag`/QuDAG, not here). This crate-walk follows the method rule `method-docs-untrusted-code-only` (`instance_of`).

**EXECUTION/SELF-BOOT:**
- `rvf-kernel` = kernel-image **BUILDER** (`KernelBuilder, CpioBuilder, DockerBuildContext, VerifiedKernel`; deps flate2) — builds bootable kernels to embed, **NOT a runtime**.
- `rvf-launch` = **THE SELF-EXECUTING PROOF**: `Launcher/MicroVm/QemuCommand/ExtractedKernel/VmStatus` — extracts embedded kernel from a `.rvf` and **BOOTS IT IN QEMU**.
- `rvf-ebpf` = `EbpfCompiler/CompiledProgram` (XDP kernel-fast-path).
- `rvf-wasm` = cdylib microkernel (`WasmRole/WasmModule/WasmStore/BootstrapChain`; deps **types+crypto+dlmalloc, NOT runtime** = T4 sibling = `@ruvector/rvf-wasm`).
- `rvf-solver-wasm` = cdylib constraint solver (`AdaptiveSolver/Constraint/Acceptance`; types+crypto+dlmalloc).

**BRIDGES/TOOLING:**
- `rvf-node` = napi cdylib wrapping `rvf-runtime` = `@ruvector/rvf` (`RvfDatabase` + Options/Query/Search/Ingest/Compaction) — **THE path ruflo facade loads.**
- `rvf-server` = axum HTTP/SSE over runtime.
- `rvf-cli` = ops CLI (create/compact/derive/freeze/embed-kernel/embed-ebpf).
- `rvf-import` = CSV/NPY.
- `rvf-federation` = **DIFFERENTIAL-PRIVACY FEDERATED LEARNING** (`DiffPrivacyEngine, NoiseMechanism, AggregationStrategy, Contribution`; ties to mcp-brain-server DP).

**ADAPTERS (6, all rlib onto `rvf-runtime`, orphaned-from-TS like claude-flow B0):** `claude-flow`(memory), `agentdb`(`MemoryPattern/RvfIndexAdapter`), `ospipe`(`RvfObservationStore` observation-state pipeline), `agentic-flow`(SWARM consensus: `ConsensusVote/SwarmStoreError/CoordinationError`), `rvlite`(`RvliteCollection`), `sona`(`Experience/ExperienceReplayBuffer/NeuralPatternStore`).

**NET:** rvf = self-bootstrapping vector-native compute container that can boot as a QEMU microVM; governance/witness/attestation baked into the format vocabulary (**T1 at format level**).

---

## 5. ruvix — the bare-metal cognition kernel

### 5.1 RuVix Cognition Kernel subsystem (`ruvix-cognition-kernel-subsystem`, conf 0.6; pass 5, code-confirmed 2026-06-09)

**RUVIX = a from-scratch bare-metal OPERATING SYSTEM.** README: *"RuVix Cognition Kernel — An Operating System for the Agentic Age... understands vectors, graphs, proofs, and coherence scores NATIVELY."* Nested workspace at `RuVector/crates/ruvix/crates/`: `nucleus` (microkernel core), `boot` (+attestation + capability_distribution + manifest), `cap` (capability-based security), `sched`, `physmem`/`dma`/`dtb`/`smp`, `hal`/`aarch64`/`bcm2711`/`drivers`, `net`/`fs`, `proof` (proof engine), **VECGRAPH** (vector-graph native IN-KERNEL), `queue`, `region`, `types`; `rpi-boot` builds `kernel8.img` with `_start` entry; `qemu-swarm` for multi-instance testing. `no_std`.

**Kernel API:** `Kernel/KernelConfig/Syscall/VectorStoreConfig/ProofTier/VectorKey/SyscallResult/Checkpoint` — **SYSCALLS OPERATE ON VECTORS**, in-kernel vector store, proof tiers, capability+attested boot. This is the **OS embodiment of the coherence-aware-hypergraph** and the runtime that powers the cognitum seed (ties to `rvf-wasm` BareTile target + `cognitum-gate-tilezero`). **#2 hub cluster (`ruvix-types` 25 deps).**

> **HARDWARE NUANCE (recorded):** ruvix targets **bcm2711 (Pi 4 / CM4 / Pi 400-class)**; user earlier said seed = "Pi Zero" and `cognitum-gate-tilezero` = "Pi 5" — **reconcile the seed's actual board later.**

### 5.2 ruvix cluster code-walk (`codewalk-ruvix-cluster`, conf 0.5; 28 crates, walked)

CODE-TRUTH walk of ruvix cluster (**28 crates**) = a **GENUINE bare-metal MICROKERNEL OS** for AArch64 / Raspberry Pi (bcm2711 = Pi4/CM4/**Pi5**), proven in real OS code (not metaphor).

> Note: this concept's parenthetical reads "bcm2711=Pi4/CM4/**Pi5**" whereas §5.1 reads "bcm2711 (Pi 4 / CM4 / Pi 400-class)". Both are quoted verbatim; the Pi5-vs-Pi400 difference is an internal inconsistency — see QUESTIONS.

- **FOUNDATION:** `ruvix-types`(no deps; `ObjectType/ProofTier/ProofPayload/KernelError/GraphMutationKind/MsgPriority` — proof+graph baked into kernel types).
- **HARDWARE/HAL:** `ruvix-hal`(`Console/Interrupt/Mmu/Power/Reset` traits), `ruvix-aarch64`(`ExceptionContext/Mmu/ExceptionClass`), `ruvix-bcm2711`(`GPIO/Mailbox/Interrupt, BoardRevision`), `ruvix-drivers`(`Pl011` UART, `Gic`, `ArmGenericTimer`, `MmioReg`), `ruvix-dma`, `ruvix-dtb`(`DeviceTree/FdtHeader` FDT parser), `ruvix-smp`(`CpuId/IpiMessage/IpiTarget` multi-core IPIs), `ruvix-physmem`(`BuddyAllocator/PageFrame/PhysAddr`), `ruvix-net`(ARP/ICMP/EtherType full TCP-IP stack), `ruvix-fs`(`Fat32BootSector/RamInode/DirEntry`), `ruvix-rpi-boot`.
- **MICROKERNEL CORE:** `ruvix-nucleus`(**THE kernel**: `Syscall/SyscallResult/TaskState/TaskPriority` + `AttestPayload/ProofRejectReason/ProofVerifyResult` ⇒ **syscalls are PROOF-VERIFIED**; deps `ruvix-shell`), `ruvix-cap`(capability security + `AuditEntry/Config/Flags` + `SignatureAlgorithm`), `ruvix-region`(`AppendOnlyRegion/ImmutableRegion/MmapBacking/SlabAllocator`), `ruvix-queue`(`KernelQueue/MessageDescriptor/OptimizedRingBuffer` IPC), `ruvix-proof`(`MerkleWitness/AttestationBuilder/ProofCache/MutationType` = Merkle-witnessed proof-gated mutations), `ruvix-boot`(`BootStage/AttestationEntry/WitnessLogEntryType/WitnessExportPolicy` = attested+witnessed boot), `ruvix-shell`(in-kernel shell).
- **DIFFERENTIATOR:** `ruvix-vecgraph` = **VECTORS+GRAPHS IN-KERNEL** (`GraphNode/EdgeEntry/DistanceResult/CoherenceTracker/CoherenceConfig/GraphMutationResult/WitnessEntryType`).
- **SUBSTRATE EDGE (patience paid off):** `ruvix-sched` **DEPENDS ON `ruvector-coherence`** (`NoveltyTracker/NoveltyConfig/PreemptionBoundary` = coherence+novelty-aware scheduling) — concrete **ruvix→ruvector crate edge**, parallels `rvm-sched` cut-pressure.
- **IN-KERNEL SWARM BFT:** `rvf-swarm-demo`(`Coordinator/Validator/Worker` consensus), `ruvix-qemu-swarm`(**PBFT**: `PbftMessage/ClusterStatus/FaultType` across QEMU nodes) — agentic consensus runs **AS kernel tasks**.
- **TOOLING:** `ruvix-cli`(host-side: serialport/ed25519/argon2/aes-gcm flash+talk to board), `ruvix-bench`(vs Linux syscalls), `ruvix-integration`(test harness), `ruvix-demo`(pipeline coordinator).

**RELATIONSHIP:** ruvix = microkernel/OS, rvm = microhypervisor over it (`rvm-types` names itself "RuVix Virtual Machine"); same family; **T1 (proof/cap/witness/coherence/attestation) is the literal OS security foundation.** This is the **cognitum-seed runtime (CONFIRMS pass5).**

---

## 6. rvm — the coherence-native micro-hypervisor

### RVM micro-hypervisor subsystem (`rvm-microhypervisor-subsystem`, conf 0.5; 16 crates, walked; ADR-132..140)

`crates/rvm` (**16 crates, WALKED**) = **RVM "RuVix Virtual Machine": a COHERENCE-NATIVE MICROHYPERVISOR for edge + multi-agent systems** (ADR-132..140). **Distinct from ruvix (kernel/OS): RVM is the hypervisor that runs isolated coherence-domain PARTITIONS (guests).**

| Crate | ADR | Role |
|---|---|---|
| `rvm-types` | ADR-132 | foundation |
| `rvm-hal` | ADR-133 | per-target HW abstraction, AArch64 |
| `rvm-cap` | ADR-135 | capability sys, 3-layer P1/P2 proof |
| `rvm-proof` | ADR-135 | proof-gated state transitions: every partition mutation needs a proof |
| `rvm-partition` | ADR-133 | lifecycle/isolation/coherence-domain |
| `rvm-witness` | ADR-134 | tamper-evident audit = **64-BYTE fixed records + FNV-1a hash chain** — **LIGHTER + DIFFERENT** from `rvf-crypto` witness (73B SHAKE-256); **ecosystem has TWO witness schemes** |
| `rvm-sched` | ADR-132 | DC-4 coherence-aware **2-signal scheduler** = deadline-urgency + **CUT-PRESSURE** ⇒ ties to `ruvector-mincut` |
| `rvm-memory` | ADR-136/138 | guest phys addr space |
| `rvm-coherence` | ADR-139 | real-time coherence scoring + Phi/IIT computation; DEPENDS ON facade ⇒ links RVM to the coherence-aware-hypergraph substrate |
| `rvm-boot` | ADR-137/140 | deterministic phased gated boot, **RVF-gated** |
| `rvm-wasm` | — | optional Wasm guest runtime — partitions host wasm modules |
| `rvm-security` | — | policy decision point = capability+coherence |
| `rvm-kernel` | — | top-level integration wiring all |

**PLACE IN STACK:** ruvix = OS/kernel, RVM = hypervisor, cognitum-gate = HW coherence gate, rvf = bootable `.rvf` container ⇒ together **the bare-metal/edge execution tier behind the cognitum seed.** repo: `github.com/ruvnet/rvm`.

Graph relations: `depends_on` → `ruvector-unifying-abstraction`; `alternative_to` → `rvf-witness-governance`; `related_to` → `ruvix-cognition-kernel-subsystem`.

---

## 7. rvAgent — Rust-native agent framework

### rvAgent (`rvagent-rust-agent-framework`, conf 0.5; 10 crates, walked)

`crates/rvAgent` (**10 crates, WALKED**) = **rvAgent: a COMPLETE RUST-NATIVE coding-agent framework — ruvnet's Rust answer to Claude Code / DeepAgents.**

| Crate | Role |
|---|---|
| `rvagent-core` | typed agent state, config, model resolution, agent **GRAPH**; pass-4a hub in-deg 8 |
| `rvagent-backends` | filesystem/shell/composite/state/store/sandbox protocols |
| `rvagent-tools` | `ls/read/write/edit/glob/grep/execute/todos/task` — **literally Claude Code's toolset**; enum-dispatch, ADR-103 A6 |
| `rvagent-middleware` | pipeline: todolist/filesystem/subagents/summarization/memory/skills/prompt-caching/HITL/**WITNESS**/tool-sanitizer — **DEPENDS ON `ruvector-sona`** for learning/memory |
| `rvagent-subagents` | spec compile/build/orchestrate/result-validate = subagent spawning |
| `rvagent-mcp` | full MCP: tools/resources/transport |
| `rvagent-a2a` | Google Agent2Agent P2P, JSON-RPC/HTTP, `/.well-known/agent.json`, ADR-159 |
| `rvagent-acp` | Agent Communication Protocol server, axum HTTP, auth/rate-limit/TLS |
| `rvagent-cli` | terminal coding agent w/ TUI, sessions, MCP |
| `rvagent-wasm` | browser/Node agent exec |

**ORCHESTRATION-LAYER RECONCILIATION (answers the pass-1/7 open Q):** **rvAgent (Rust-native agent runtime) and ruflo (claude-flow v3 TS runtime) are PARALLEL FRONT-ENDS over the same RuVector substrate, NOT stacked layers** — rvAgent binds via `middleware→ruvector-sona` + its own witness middleware + A2A/ACP/MCP interop; ruflo binds via the "ruvector" npm facade + rvf-node + ruflo-core witness. **weave (our meta stack) is a separate local coordination mesh. Three agent systems, one shared vector/coherence substrate.**

Graph relations: `alternative_to` → `ruflo-is-claude-flow-v3`; `related_to` → `weave-coordination-substrate` (see [04-weave-coordination](04-weave-coordination.md)).

---

## 8. The ruv ecosystem — ruflo, the dev pattern, and the wasm/ts wiring

### 8.1 ruflo = claude-flow v3 (`ruflo-is-claude-flow-v3`, conf 0.5; pass 1)

**RUFLO = CLAUDE-FLOW V3.** `~/Desktop/meta/ruflo` is a TypeScript/Node agent-orchestration runtime published as **claude-flow@3.10.x** (also aliased "ruflo"). LIVE source = `v3/` (`@claude-flow/cli`, guidance, memory, security, hooks, codex; plugins/). LEGACY = `ruflo/` subdir. Hosts **60+ agent types, MoE routing, MCP server (40+ tools: `swarm_init`/`agent_spawn`/`task_orchestrate`/`memory_*`/`neural_*`/`hook_*`), 350+ slash commands + 74+ agents** via `.claude-plugin/`. It is the agentic/plugin **HOST that surfaces RuVector capabilities to Claude Code.** "RuVector needs ruflo to work" = the USE/plugin entry point for RuVector goes through ruflo.

Graph relations: `depends_on` → `ruvector-pass1-shape`; `part_of` → `stack-topology-reality`.

### 8.2 ruvnet dev pattern (`ruvnet-dev-pattern`, conf 0.5; user-authoritative 2026-06-09)

**RUVNET DEV PATTERN** — explains MANY "two implementations" discrepancies across the stack: **ruvnet builds in TypeScript FIRST, then ports to RUST-NATIVE, and KEEPS the old TS code for backward compatibility.** Example: claude-flow (TS) was renamed **ruflo** with rust-native upgrades; old TS remains. So when you find a TS impl AND a Rust impl of the same thing, **the RUST is the current/canonical path and the TS is legacy/compat/fallback.** **napi-rs is the bridge** that exposes the Rust to the TS/Node layer. Breadcrumbs: agentdb repo = `github ruvnet/agentdb`; napi integration breadcrumbs across all rust at `ruvnet/ruv.io`. **RULE: when auditing ruvnet code, treat Rust as truth, TS as legacy unless proven otherwise.**

### 8.3 WASM path + the TS-RVF discrepancy (`wasm-path-and-ts-rvf-discrepancy`, conf 0.5; pass 2, code-verified)

**BUILD:** RuVector crate (crate-type cdylib, e.g. `ruvector-gnn-wasm` with `#[wasm_bindgen]` exports `init/forward/topo_sort/critical_path`) → `wasm-pack build --target web --release` + `wasm-opt -Oz` → `pkg/` → bundled into npm `@claude-flow/plugin-gastown-bridge`.

**LOAD:** ruflo uses Node's **NATIVE WebAssembly** via dynamic `import()` — **NOT wasmtime/wasmer** (`wasm-loader.ts` `LazyWasm`, 5-min idle unload, LRU result caches, batch dedup).

**EXEC:** MCP tool → plugin handler → `LazyWasm.get()` → wasm fn (JSON in/out) → cache; **JS FALLBACK** if WebAssembly unavailable. Registration is **MANUAL per-plugin** (`registerPlugin` + explicit `discovery.ts` list), no auto-scan.

**DISCREPANCY TO RESOLVE:** ruflo's `@claude-flow/memory` `RvfBackend` (`rvf-backend.ts`) is **TYPESCRIPT** (HnswLite + sql.js), **NOT the Rust `rvf-runtime`**. So TWO paths exist: **COMPUTE = RuVector Rust→wasm (gastown); MEMORY = a TS RVF-lite.** Whether the full Rust `rvf-runtime` is used by ruflo (via napi?) or only the TS lite version is an open pass-3 question. → *This is the open question that the multi-pass wiring verdicts below resolve.*

### 8.4 The RVF wiring verdicts — pass 3 → pass 6 → pass-6 correction

This is the most contested chain in the cluster; the three concepts are explicit *revisions* of one another (`pass6 refines pass3`; `pass6-correction refines pass6`). Render all three and note the revision direction.

#### Pass 3 (`rvf-wiring-verdict-pass3`, conf 0.5; status **pass3-TENTATIVE**, invites user confirmation)

**CONFIRMED solid:** the **napi Rust path SHIPS** — `@ruvector/rvf` → `@ruvector/rvf-node` (napi crate at `RuVector/crates/rvf/rvf-node`, wraps **rvf-runtime 0.2.0**, exports `RvfDatabase{create,open,query,ingestBatch,delete,compact,status}`); prebuilt `rvf-node.linux-x64-gnu.node` present. ruflo backend selection (`v3/@claude-flow/memory/database-provider.ts`): RVF → better-sqlite3 → sql.js → JSON.

**AGENT'S READ (needs confirm):** `RvfBackend` lazy-imports `@ruvector/rvf` and stores `nativeDb`, **BUT executes via pure-TS HnswLite**; agentdb-backend uses TS HNSWIndex; so **napi is loaded-but-idle and TS is the ACTIVE default in ruflo today.**

**CAVEAT/CONTRADICTION to resolve:** an **ADR-125** note suggests inlining HnswLite to phase OUT native **IN FAVOR OF TS** — **opposite of ruvnet's stated TS→Rust dev pattern.** **SCOPE NOTE:** this is about RUFLO's current wiring state only; **it does NOT contradict that RuVector's Rust `rvf-runtime` is complete/production-grade.** agentdb = separate npm pkg (`github ruvnet/agentdb`) the agentdb-backend imports. `rvf-migration.ts` migrates legacy JSON/sqlite → RvfBackend.

#### Pass 6 (`rvf-wiring-verdict-pass6`, conf 0.5; status **pass6-PROVEN**, settles pass-3)

**Code-proven:** ruflo's claude-flow **MEMORY** subsystem does **NOT** execute through Rust `rvf-runtime`. In `v3/@claude-flow/memory/src/rvf-backend.ts`, `tryNativeInit()` loads napi `@ruvector/rvf` `RvfDatabase`, `.open()`s it, reports it in `healthCheck`, `.close()`s it on shutdown — **but NO operation** (store/search/query/delete/bulkInsert/clearNamespace) ever calls `nativeDb.*`. All ops run over an **in-memory JS Map (`this.entries`) + pure-TS HnswLite** index (`search()` falls to `bruteForceSearch` when `hnswIndex` is null). When native mode is active, `hnswIndex` is null AND `loadFromDisk` is skipped ⇒ **`nativeDb` is dead weight.** So the napi handle is **loaded-but-vestigial; TS HnswLite/Map is THE active path.**

The **ADR-125 contradiction is RESOLVED:** code matches ADR-125 (comment L17–19: HnswLite is "the single HNSW implementation in the public surface"). `database-provider.ts` selects RVF first but "RVF available" is **"always true via pure-TS fallback."**

The dedicated Rust crate `rvf-adapter-claude-flow` (`RuVector/crates/rvf/rvf-adapters/claude-flow`) is **COMPLETE + 9 passing tests** wrapping `RvfStore` directly, but is a **plain rlib (no cdylib/wasm/napi) and is ORPHANED** — never imported by any TS (only named in a knowledge-export JSON string).

**NUANCE:** the Rust `rvf-runtime` **IS production-grade and IS exercised via napi**, but in a **DIFFERENT layer** — the benchmark/intelligence path `dist/ruvector/vector-db.js` (`loadRuVector`/`createVectorDB`), source of the measured **~1.9×–4.7× HNSW NAPI numbers** — **NOT the agent memory store.** `agentdb-backend.ts` uses the separate "agentdb" npm pkg's `HNSWIndex`, also not the claude-flow Rust adapter.

#### Pass-6 correction (`rvf-wiring-pass6-correction`, conf 0.5; status **pass6-CORRECTED**, role:memory + root-cause)

**CORRECTION to pass6 (which was scoped too narrow):** the memoir generalized "ruflo does NOT execute through Rust rvf-runtime" from the `@claude-flow/memory` `RvfBackend` **ALONE** and **missed the real operational consumers.** **TRUTH: the production Rust RVF IS wired into ruflo, via FOUR paths:**

1. **`@claude-flow/memory` `RvfBackend`** = pure-TS Map + HnswLite, napi handle dead **[this part of pass6 stands].**
2. **`agentdb-backend.ts`** = separate "agentdb" npm `HNSWIndex`.
3. **THE BIG ONE MISSED:** `cli/src/ruvector/vector-db.ts` `loadRuVector()`/`createVectorDB()` imports the **"ruvector" npm facade** (`npm/packages/ruvector/src/index.ts`), which `require()`s `@ruvector/core` (native) then `@ruvector/rvf` (= `rvf-node` napi → `rvf-runtime`) and **DEFAULTS `implementationType='wasm'`** (`@ruvector/rvf-wasm`). Consumed **operationally by SIX intelligence plugins** (semantic-code-search, intent-router, sona-learning, reasoning-bank, hook-pattern-library, mcp-tool-optimizer) + graph-analyzer; persists to `.rvf`; has `isWasm()`. The earlier "just benchmarks" dismissal was **wrong.**
4. **`ruflo-core/scripts/witness/lib.mjs`** `loadRvfNode()` requires `@ruvector/rvf-node` (napi → `rvf-runtime`) for the **witness/audit chain**, JSONL fallback.

ruflo `package.json` deps: **`ruvector ^0.2.27` + `@ruvector/rvf-wasm 0.1.5`.**

**WASM-BRIDGE NUANCE (user hypothesis, made precise):** `@ruvector/rvf-wasm` is built by `cargo build --target wasm32-unknown-unknown rvf-wasm/Cargo.toml` + `wasm-opt`, and **`rvf-wasm` depends on ONLY `rvf-types` + `rvf-crypto`, NOT `rvf-runtime`.** So **native (napi → rvf-runtime) and wasm (rvf-wasm) are TWO interchangeable backends behind the "ruvector" facade, bridged by the `.rvf` FORMAT (`rvf-types`) + `rvf-crypto`, not by compiling `rvf-runtime` to wasm.** `rvf-kernel` likewise couples **via format only.**

**NET: "is production RVF wired into ruflo" = YES** (intelligence facade + witness); **the memory KV backend is the lone exception.**

> **Verdict-revision summary (preserve explicitly):**
> - **Pass 3 (tentative):** "napi loaded-but-idle, TS is the active default" — invites confirmation.
> - **Pass 6 (proven, settles pass 3):** confirms the memory backend is pure-TS and the napi handle is vestigial *there*; but then over-generalised to "ruflo does NOT execute through Rust rvf-runtime."
> - **Pass-6 correction (corrected):** the over-generalisation was wrong — production Rust RVF **is** wired in via the **intelligence facade** + **witness chain** (4 paths). The **memory KV backend remains the sole TS-only exception.** Net answer: **YES, production RVF is wired into ruflo.**

---

## Cross-references

- [01-meta-control-plane](01-meta-control-plane.md) — the `meta` CLI / control plane that would later host these crates; this cluster is "not yet adopted."
- [02-handoff-continuity](02-handoff-continuity.md) — the Continuity Ledger Kernel (`hf` + `.handoff/`); the **only live meta→RuVector code edge** is the handoff ledger's path-dep on `rvf-crypto`; S1 maps the Ark contract onto RVF witness, weave leases, `ruvector-verified`.
- [03-envctl-kasetto](03-envctl-kasetto.md) — the **envctl secret-key USB is a DIFFERENT device** from the Cognitum Seed (do not conflate); SSH-key possession as a candidate envctl-USB factor.
- [04-weave-coordination](04-weave-coordination.md) — weave is the **separate local coordination mesh**; rvAgent `related_to` `weave-coordination-substrate`; the hf→weave Leaser/ClaimGate is the a2a template.
- [06-cognitive-codewalk](06-cognitive-codewalk.md) — the consciousness/boundary-discovery example families, cognitum-gate-tier, the agentic pipeline, mcp-brain-server convergence (the codewalk-* concepts that `refine`/`instance_of` this cluster).
- [07-frontdoor-integration](07-frontdoor-integration.md) — RuVocal (HF Chat UI on `ruvector-postgres`/pgvector) → mcp-bridge → prompt_hub `/vibe` → SwarmBundle → `handoff.task.v1`; the front-door mapping (gap#2) referenced by S1.
- [08-gaps-seams-merge](08-gaps-seams-merge.md) — the open seams, the wiring-verdict contradictions, the board-class reconciliation, and "not-yet-adopted" status carried here.

---

## QUESTIONS (contradictions / ambiguities / low-confidence material claims)

1. **RVF wiring verdict revision (pass 3 → 6 → 6-correction):** the chain reverses itself — pass 6 declares "ruflo does NOT execute through Rust rvf-runtime," then the pass-6 correction declares "production RVF IS wired into ruflo (4 paths)." The *reconciled* net answer is **YES, via the intelligence facade + witness; memory KV backend is the lone TS-only exception.** Is the pass-6-correction the **final** verdict, or is a further pass owed to fully reconcile the ADR-125 "phase out native in favor of TS" note (still true only for the *memory* backend)?
2. **wasm/ts RVF discrepancy:** is the dual-backend model now settled — i.e. native(`rvf-node`→`rvf-runtime`) and wasm(`rvf-wasm`, deps only `rvf-types`+`rvf-crypto`) are **two interchangeable backends bridged by the `.rvf` format**, with the TS HnswLite/Map confined to `@claude-flow/memory`? The "ruvector" facade **defaults `implementationType='wasm'`** — does that mean the *default* operational path is wasm (rvf-wasm), not napi?
3. **rvf-crypto post-quantum claim:** the knowledge-export and `rvf_stack` chain both assert `rvf-crypto` ships **ML-DSA-65** PQ signatures; the code-walk proves deps are **ed25519-dalek + sha3 ONLY** (PQ lives in `ruvector-dag`/QuDAG). The code-truth (no ML-DSA) is the FLAGGED resolution — confirm no downstream doc still relies on the false claim.
4. **Cognitum Seed board class — unresolved inconsistency.** `cognitum-seed-activation-ref` says **Pi Zero / Cortex-A53 / 512MB**; `cognitum-is-ruvector-hardware` says **Pi 5** (for `cognitum-gate-tilezero`); `ruvix-cognition-kernel-subsystem` says **bcm2711 = Pi 4 / CM4 / Pi 400-class**; `codewalk-ruvix-cluster` says **bcm2711 = Pi4/CM4/Pi5**; the 2026-06-13 SSH probe returned **`armv7l`** (32-bit, consistent with Pi Zero/older, NOT Pi 4/5 aarch64). What board is the actual seed, and does ruvix (aarch64/bcm2711) even run on it?
5. **Two witness schemes:** the ecosystem ships **two** tamper-evident witness formats — RVF `rvf-crypto` (73B, SHAKE-256) and RVM `rvm-witness` (64B, FNV-1a). Are these intentionally distinct (heavy vs light tiers), and which is canonical for the meta handoff ledger? (S1 adopts the RVF/SHAKE-256 one.)
6. **Confidence floor:** every concept in this cluster stores **0.5–0.6** confidence yet is labelled **CODE-PROVEN / walked**. Is the 0.5 a default that should be raised post-verification, or a genuine "interpretation may be wrong" signal? Named facts (crate names, file paths, types, dep edges) should be near-certain; the interpretive theses (e.g. "coherence-aware hypergraph") are the genuinely <0.7 part.
7. **ADR-125 vs ruvnet dev pattern:** ADR-125 ("inline HnswLite, phase out native in favor of TS") runs *opposite* to the stated TS→Rust dev pattern (Rust is canonical). Pass 6 calls this "resolved" only for the *memory* backend. Is ADR-125 scoped solely to `@claude-flow/memory`, or does it signal a broader reversal?

## LESSONS (confirmed facts / decisions / verified verdicts)

1. **The crate graph is ONE interconnected system, code-proven.** Parsing **213 `Cargo.toml`** manifests gives **213 internal crates / 149 with ≥1 internal dep / 340 internal dependency edges**; top hubs `rvf-types`(26), `ruvix-types`(25), `ruvector-core`(24); convergence point `mcp-brain-server` depends on all three clusters. The "domain examples" share hub infra ⇒ interconnected by construction. (`ruvector-crate-graph-proven`)
2. **The unifying abstraction is a small orthogonal trait set over `Vec<f32>`, not a god-trait** — VECTOR (`VectorIndex`, `core/src/index.rs:11`) / GRAPH (mincut) / ATTENTION-GEOMETRY / DOMAIN-as-composition; thesis = "coherence-aware hypergraph." Code-proven 2026-06-09. (`ruvector-unifying-abstraction`)
3. **COGNITUM = RuVector's hardware tier; the Cognitum Seed is its physical embodiment.** Zero-config edge appliance, `ssh genesis@169.254.42.1` (pw `cognitum`), MCP at `/mcp`, RVF store at `/var/lib/cognitum/rvf-store/`; **needs no secret key ⇒ NOT the envctl secret-key USB.** Must be plugged in **at boot** to enumerate USB gadget interfaces. SSH key enrolled 2026-06-13 (host `cognitum-578b`, `armv7l`). (`cognitum-is-ruvector-hardware`, `cognitum-seed-activation-ref`, `cognitum-seed-boot-requirement`)
4. **A `.rvf` is a self-bootstrapping, vector-native compute container — not just storage.** It embeds real executables (Linux bzImage / Hermit / Asterinas via `rvf-kernel`; WASM microkernels incl. the ~5.5KB "Cognitum tile runtime" via `rvf-wasm`; eBPF via `rvf-ebpf`) and `rvf-launch` extracts + **boots the embedded kernel in QEMU**. Two-level manifest: 4096-byte Level-0 root at EOF, magic **RVM0 `0x52564D30`**, <5ms boot; 3-layer progressive HNSW. (`rvf-is-self-bootstrapping-container`, `rvf-format-internals`, `codewalk-rvf-cluster`)
5. **Governance/witness/attestation are baked into the RVF format vocabulary (T1 at format level).** Tamper-evident witness chain = 73B/entry, SHAKE-256 prev-hash chaining; `GovernanceMode Restricted/Approved/Autonomous`; embedded as policy flags + cost bounds, not a central authority. (`rvf-witness-governance`)
6. **ruvix is a GENUINE from-scratch bare-metal microkernel OS** (no metaphor) for AArch64/Raspberry Pi where **syscalls operate on vectors and are proof-verified**; `ruvix-vecgraph` puts vectors+graphs in-kernel; concrete **ruvix→ruvector edge**: `ruvix-sched` depends on `ruvector-coherence`. ruvix = OS, RVM = hypervisor over it ("RuVix Virtual Machine"), same family; this is the cognitum-seed runtime. (`ruvix-cognition-kernel-subsystem`, `codewalk-ruvix-cluster`)
7. **RVM is a coherence-native micro-hypervisor running isolated coherence-domain partitions** (ADR-132..140); `rvm-sched` uses deadline-urgency + **CUT-PRESSURE** (ties to `ruvector-mincut`); proof-gated state transitions; **ecosystem has TWO witness schemes** (RVM 64B/FNV-1a vs RVF 73B/SHAKE-256). repo `github.com/ruvnet/rvm`. (`rvm-microhypervisor-subsystem`)
8. **rvAgent and ruflo are PARALLEL front-ends over the same RuVector substrate, NOT stacked layers.** rvAgent is a complete Rust-native coding-agent framework (Claude Code's toolset, A2A/ACP/MCP, `middleware→ruvector-sona`); ruflo = claude-flow v3 (TS). weave is a separate meta-local mesh. **Three agent systems, one shared vector/coherence substrate.** (`rvagent-rust-agent-framework`, `ruflo-is-claude-flow-v3`)
9. **ruvnet dev pattern (user-authoritative): TS-first, then Rust-native port, keep TS for compat — treat Rust as truth, TS as legacy unless proven otherwise; napi-rs is the bridge.** This explains the recurring "two implementations." (`ruvnet-dev-pattern`)
10. **Final reconciled wiring answer: production Rust RVF IS wired into ruflo** via the "ruvector" intelligence facade (6 plugins + graph-analyzer) and the ruflo-core witness chain (napi→`rvf-runtime`); the **`@claude-flow/memory` KV backend is the sole TS-only exception** (pure-TS Map+HnswLite, napi handle vestigial; matches ADR-125). native(napi→rvf-runtime) and wasm(`rvf-wasm`, deps only rvf-types+rvf-crypto) are interchangeable backends bridged by the `.rvf` format. (`rvf-wiring-verdict-pass3` → `rvf-wiring-verdict-pass6` → `rvf-wiring-pass6-correction`)
11. **S1 decision (critical, NOT YET ADOPTED): do NOT build the 12-crate Ark Handoff Ledger from scratch** — ~8 of 12 capabilities already exist in RuVector; adopt the Ark CONTRACT onto existing crates (RVF+witness=ledger, weave leases=claim engine, `ruvector-verified`+AgentContract=provable work-order=`handoff.task.v1`, cognitum-gate/rvf-runtime=policy, `domain-expansion`=routing, rvAgent=runtime, MCP=seam); SoT = Ark state-precedence (Git>RVF-ledger>weave-Jobs-view). The validating spike **PASSED 4/4** (`rusqlite`+`rvf-crypto` witness, ~150 LOC). Rename Ark/V2 → **Continuity Ledger Kernel**. (`s1-ruvector-meta-mapping`)
12. **Method discipline that produced these facts:** RuVector prose is **UNTRUSTED**; only code, real Cargo dep edges, `pub` signatures, and tests are truth; the knowledge-export JSON is a **scaffold** (91 crates / 55 ADRs vs real 314 / 180+) for *chains* only, never counts; **read crates directly, not via subagents.** (`research-mission-ruvector-crate-map`, `ruvector-knowledge-export-scaffold`)
