# 06 — The Cognitive / AI Codewalk

This document renders the ICM `system-architecture` memoir's guided "codewalk" (the **B-series** strict, code-verified walk) of the **RuVector** cognitive/AI system — a large Rust-native substrate of ~314 crates whose discovery/sensor/agent fleet, cognition/consciousness substrate, exo-cognitive runtime, agentic-integration seams, and edge-agent deployment surface were walked tier by tier. It also covers the cross-cutting **stacks and domains** the walk surfaced: the foundation solver/math/DAG layer, the graph-transformer stack, the LLM/sona serving stack, the markets/quantum domain, the mincut/graph index-zoo, the prime-radiant convergence runtime, the robotics/embodied tier, the ANN-index/quantization kernel family, and the JS/TS bridge sweep. The central thesis the walk confirms (**T1**): the unifying signature of the whole ecosystem is **governed / gated / attested compute** — a coherence-gate + policy-gate + proof + witness + budget seam recurs everywhere; "coherence-aware hypergraph" is the data model, "gated/attested compute" is the control model.

> **Confidence note:** Every `codewalk-*` concept in this document carries a source confidence of **0.50** (the two `todo-reexplore-*` method-notes carry **0.60**). Per the synthesis brief, all material claims here are below the 0.70 threshold and should be read as **strict-walk findings pending independent verification**. Facts are preserved verbatim from the memoir; module/crate/example names, tier IDs, and type names are reproduced faithfully and not invented.

---

## Framing: how the examples interconnect, and why they are agentic roles

### Examples interconnect through shared hub crates (`codewalk-examples-interconnection`, conf 0.50)

**CODE-TRUTH B17** (examples interconnection map, 90 example crates via dependency graph). The mission answer — **how the examples interconnect: they interconnect THROUGH SHARED HUB CRATES, not by calling each other.** Dominant shared hubs (by # of example crates depending):

| Hub crate | # example crates depending |
|---|---|
| `ruvector-mincut` | 21 |
| `ruvector-coherence` | 19 |
| `ruvector-core` | 11 |
| `ruvector-graph` | 6 |
| `ruvector-consciousness` | 6 |
| `ruvector-gnn` | 5 |
| `ruvector-domain-expansion` | 5 |
| `ruvector-attention` | 4 |
| `ruvector-solver` | 3 |
| `ruvector-data-framework` | 3 |
| `rvf-types` | 3 |

**Key finding:** the DOMAIN examples are **ONE PIPELINE parameterized by dataset** — the boundary-discovery family (seti / earthquake / cmb / frb / weather / market / health / pandemic / music / void / infrastructure / brain) + the consciousness family (climate / cmb / ecosystem / gene / gw / quantum) are the **SAME mincut + coherence (+ consciousness IIT-Phi) engine** applied to different domains (radio astronomy, seismology, cosmology, EEG, genomics, markets…). `mincut`(boundary) + `coherence`(scoring) is the literal shared backbone, confirming the coherence-aware-hypergraph + boundary-discovery thesis **in the examples**.

**THREE TIERS of examples:**
1. **ruvector-coupled domain apps** (majority): direct deps on `mincut` + `coherence` + `core` + `consciousness` + `gnn` + `attention` + `solver`.
2. **exo-ai-2025 = SATELLITE WORKSPACE** (`exo-core` / `backend-classical` / `exotic` / `federation` / `hypergraph` / `manifold` / `node` / `temporal` / `wasm` + 11 consciousness-research apps: neuromorphic-spiking, quantum-cognitive-superposition, time-crystal-cognition, sparse-persistent-homology, demand-paged-cognition, federated-collective-phi, causal-emergence, meta-sim-consciousness, hyperbolic-attention, thermodynamic-learning, conscious-language-interface) — consuming ruvector via **PUBLISHED crates.io deps** (`ruvector-core` / `ruvector-graph` `'0.1'`), NOT path = a parallel research stack on the ruvector SDK.
3. **vibecast-7sense** (`sevensense-core` / `vector` / `audio` / `embedding` / `interpretation` / `learning` / `analysis` / `api`) = **SELF-CONTAINED** multimodal 7-sense stack; does NOT depend on ruvector crates = independent app built alongside.

**Minor clusters:** `ruvector-data-framework` (3 ingestion examples: climate / edgar[SEC] / openalex); `rvf-examples` / `rvf-desktop` / `rvf-kernel-optimized` (use `rvf-*` directly); `ruvllm-esp32` / `-flash` (LLM inference ON ESP32 microcontroller); `ruvector-robotics-examples`; `onnx-embeddings`; `scipix`; `a2a-swarm` (agent-to-agent); `ruvector-cloudrun-gpu` (deploy); `ruvector-ios-wasm` (iOS).

**Where ruflo/agents enter:** examples are mostly **HEADLESS Rust domain apps** (not agent-driven); agents enter the stack via the **MCP seams** (`mcp-gate` / `mcp-brain` / `agentic-robotics-mcp`) + the `ruvector` npm facade, NOT via the example apps (except `a2a-swarm`). *Note: 35 'no-dep' examples were exo-/sevensense- sub-crates (regex prefix miss), resolved here.*

### The examples ARE agentic roles (`examples-are-agentic-roles`, conf 0.50, user-stated)

**USER REFRAME (authoritative):** the RuVector examples are NOT demos — **by design each plays a PART/ROLE in the live RuVector agentic system.** The walk must surface each example's **agentic role**, not just "which crates it composes." Given ample proof of RuVector agentic automation (`mcp-gate` coherence-permission, `mcp-brain` shared brain, `a2a-swarm` agent-to-agent, domain-expansion routing, `federated-collective-phi`, MCP-as-universal-seam **T11**), the boundary-discovery + consciousness examples are the system's **DOMAIN-SPECIALIST DISCOVERY/SENSOR AGENTS** — each a specialized boundary-detection agent (seti = radio-sensing, earthquake = seismic, cmb/frb = astro, health/pandemic = bio, market = financial, etc.) that contributes to the collective.

**Walk lens going forward:** for each example, detect agentic wiring — MCP server, brain client/contribution, A2A/ACP endpoint, federation/collective, daemon/continuous-loop vs one-shot, RVF/witness output, weave, swarm — and state its **role in the mesh** (sensor / discovery / decision / aggregator / edge-node). The examples = the **EDGE AGENTS** the orchestration layer (ruflo / rvAgent / weave) coordinates and the brain aggregates. This reframes `codewalk-examples-interconnection` + `codewalk-b17a` (which under-read them as "thin demos").

---

## B17a — Boundary discovery: astro / geo family (`codewalk-b17a-boundary-astro-geo`, conf 0.50)

**CODE-TRUTH B17a** (strict, boundary-discovery astro/geo family, **6 examples**). ALL depend on **ONLY** `ruvector-mincut` + `ruvector-coherence` (no external domain libs); all are thin `main.rs` binaries (no pub API, logic in `main()`). Source `//!` docs confirm **T13** verbatim:

- **boundary-discovery** = reference ("Boundary-First Scientific Discovery: graph-structural analysis detects phase boundaries INVISIBLE to amplitude-based methods").
- **seti-boundary-discovery** ("faint structured signals buried in noise that amplitude-based detectors CANNOT see").
- **seti-exotic-signals** ("Gallery of Exotic Signals boundary-first finds that amplitude SETI misses").
- **earthquake-boundary-discovery** ("Earthquake Precursor Detection via Boundary-First").
- **cmb-boundary-discovery** ("CMB Cold Spot Boundary-First").
- **frb-boundary-discovery** ("FRB Population Boundary Discovery, CHIME-like catalog").

Each = the **SAME `mincut`(boundary) + `coherence`(scoring) engine** applied to a different dataset (radio SETI / seismology / cosmology / fast-radio-bursts). The shared thesis "boundary-first beats amplitude-based" is restated in every example's doc. **No traps.** Confirms `codewalk-examples-interconnection` at source level.

---

## B17b — Boundary agents: bio / social / infra, predictive early-warning (`codewalk-b17b-boundary-agents-predictive`, conf 0.50)

**CODE-TRUTH B17b** (strict + AGENTIC-ROLE lens, boundary bio/social/infra family, **8 examples**). **Agentic role** (the user's point): every boundary example is a **PREDICTIVE EARLY-WARNING AGENT** — detects a regime/state transition BEFORE amplitude methods can, then emits an alert/report. = the deployed/specialized form of `ruvector-perception`'s `BoundaryPredictor` / `BoundaryForecast` / `detect_boundary` (**B9**), one per domain.

Roles:
- **health-boundary-discovery** — CONTINUOUS-MONITOR loop + emits-report; wearable-sensor health-state transitions healthy → overtraining → sick → recovery.
- **pandemic-boundary-discovery** — outbreak detection **~60 DAYS BEFORE** case counts, from 8 public-health monitoring signals' cross-correlation.
- **market-boundary-discovery** — market-REGIME change before obvious; asset-correlation boundaries (ties to neural-trader regime detection).
- **infrastructure-boundary-discovery** — bridge structural failure **MONTHS BEFORE** collapse; sensor-correlation degradation.
- **brain-boundary-discovery** — PRE-SEIZURE detection; 16-ch EEG 600s Normal → Pre-ictal → Seizure → Post-ictal (brain-connected).
- **weather-boundary-discovery** — hidden weather regime changes under smooth sinusoid.
- **music-boundary-discovery** — genre boundaries from graph structure not audio thresholds.
- **void-boundary-discovery** — cosmic void boundary information content.

ALL compose `ruvector-mincut` + `coherence` only; mostly single-file (health / earthquake / void run loops = continuous monitors; rest one-shot capability + report). **COLLECTIVE AGENTIC ROLE** = the **DOMAIN-SPECIALIST EARLY-WARNING / PERCEPTION AGENT FLEET** of RuVector (bio / epidemic / finance / civil-infra / neuro / weather / audio / cosmology): each a predictive sensor that fires BEFORE the event; the orchestration layer (ruflo / rvAgent / weave / MCP) coordinates them and the shared brain aggregates their discoveries. Unifying agentic value: **boundary-first = PREDICT regime changes early.** Reframes B17a (astro/geo = the radio/seismic/cosmic sensing agents).

---

## B17c — Consciousness Phi agents (`codewalk-b17c-consciousness-phi-agents`, conf 0.50)

**CODE-TRUTH B17c** (strict + agentic lens, consciousness family, **6 examples**). ALL depend **ONLY** on `ruvector-consciousness` (the IIT-Phi engine, **B9**). **Agentic role** = the **Phi-MEASUREMENT / EMERGENCE-ANALYSIS agents** (complement to B17a/b early-warning PERCEPTION agents): each is a "Consciousness Explorer" applying integrated-information Phi to a domain's correlation/transition matrix to detect emergent/integrated organization, emitting `AnalysisResults` + text + SVG reports.

Roles:
- **climate-consciousness** — Phi over 7 climate-teleconnection indices' correlation matrix.
- **cmb-consciousness** — Phi + CAUSAL EMERGENCE + NULL TESTING on Cosmic Microwave Background sky; `SkyMapResults` / `PowerSpectrum` / `CrossFreqResults` / `EmergenceSweepResults` = **most rigorous**.
- **ecosystem-consciousness** — Phi over food-web networks; `TrophicLevel` / `Species` / `Ecosystem` = ecosystem integration.
- **gene-consciousness** — Phi over gene regulatory networks; `GeneNetwork` / `TransitionMatrix`.
- **gw-consciousness** — Phi over gravitational-wave stochastic background from pulsar timing; `GWSpectrum`.
- **quantum-consciousness** — Phi over quantum-circuit measurement statistics; `QuantumCircuit` / `CircuitResult`.

These are richer than the boundary one-shots (real pub types) but still **one-shot analysis pipelines** (emit reports/SVG; **NO** brain-client/loop/MCP wiring in their own source — the federation/collective-Phi orchestration lives in `federated-collective-phi` (exo research) + `mcp-brain`).

**NET:** boundary family (`mincut` + `coherence`) = early-warning PERCEPTION agents; consciousness family (`ruvector-consciousness` Phi) = INTEGRATION/EMERGENCE-MEASUREMENT agents; together = RuVector's **SCIENTIFIC-DISCOVERY AGENT FLEET** (perception of boundaries + measurement of integration) over the shared substrate, invokable by the agentic orchestration and aggregated by the brain.

---

## B17d — Neuro / bio / temporal (`codewalk-b17d-neuro-bio-temporal`, conf 0.50)

**CODE-TRUTH B17d** (strict, code-verified, neuro/bio/temporal, **7 examples**). **CODE-TRUTH CORRECTION:** marker-grep falsely flagged agentic wiring (`mcp` / `serve` / `brain`) on several; reading actual lines proved **FALSE POSITIVES** — `brain` = the organ ("normal brain activity"), `router` = a `RouterError` enum variant (spike routing), no real `mcp` / `axum` / `serve` / `reqwest`. **NONE** of these examples self-host as agents; all are **ONE-SHOT analysis/sim pipelines.** *(Lesson: verify markers against real lines; trust code not even one's own grep.)*

Roles:
- **real-eeg-analysis** — `mincut` + `coherence` on REAL EEG = seizure-boundary detection on actual recordings.
- **real-eeg-multi-seizure** — coherence-only multi-seizure EEG.
- **seizure-clinical-report** — `mincut` + `coherence` → clinical report from seizure EEG.
- **seizure-therapeutic-sim** — `mincut` + `coherence` → simulate therapeutic intervention on seizure dynamics.
- **spiking-network** — deps `core` + `gnn` = REAL spiking neural net sim: `IzhikevichNeuron` / `IzhikevichParams` + `LIFNeuron` / `LIFParams` (Leaky Integrate-and-Fire) + `NetworkConfig` / `Stats` + `SpikingError`; neuromorphic compute primitive.
- **rvdna** — **THE MOST-COMPOSED EXAMPLE**, 9 ruvector crates `core` + `attention` + `gnn` + `graph` + `dag` + `math` + `filter` + `collections` + `solver` = real GENOMICS pipeline: `CigarOp` (sequence alignment), `CallConfidence` / `FilterStatus` (variant calling), `Cyp2c19Allele` (PHARMACOGENOMICS drug-metabolism gene), `BiomarkerClassification`, `AminoAcid`, `Codec`.
- **temporal-attractor-discovery** — `mincut` + `coherence` = dynamical-systems attractor discovery via boundaries.

**Agentic role:** invokable domain CAPABILITIES (clinical-neuro perception, neuromorphic compute, genomics, attractor discovery), NOT self-hosting agents — the agentic layer (`mcp-*` / a2a / federation / brain) wraps & invokes them. `rvdna` = strongest proof the examples deeply COMPOSE the substrate. The clinical-neuro cluster (real-eeg + 2 seizure + brain-boundary-discovery) = a coherent **epilepsy/EEG capability suite**.

---

## B17e — Exo-cognitive substrate: exo-ai-2025 library crates (`codewalk-b17e-exo-cognitive-substrate`, conf 0.50)

**CODE-TRUTH B17e** (strict + verified, exo-ai-2025 library crates, **9**). `exo-ai-2025` = a **SELF-CONTAINED "Advanced Cognitive Substrate" SDK** (exocortex-style) layered on ruvector, satellite workspace (consumes ruvector via crates.io `0.1`). **CODE-VERIFIED:** NO exo crate does real network I/O (no `reqwest` / `tonic` / `quinn` / `libp2p`) — the "NET/distrib" markers were false (word-matches `peer` / `node`); examples provide **capabilities/protocols**, not self-hosting networked agents.

Crates:
- **exo-core** (deps `ruvector-core` + `graph`) = hypergraph cognitive substrate: `CoherenceBackend` / `ConsciousnessLevel` / `Hyperedge` / `HypergraphResult` / `ManifoldDelta` / `FilterOperator`; foundation all build on.
- **exo-hypergraph** = hypergraph + persistent-homology `Filtration` + `ForwardPushPpr` (personalized PageRank).
- **exo-manifold** (deps `exo-core` + `domain-expansion` + `ndarray`) = learned manifolds: `SirenLayer` (SIREN sinusoidal implicit neural fields), `ManifoldEngine` / `Deformer`, `GradientDescentRetriever`, `TransferManifold`, `StrategicForgetting` (continual learning).
- **exo-temporal** = causal reasoning: `CausalGraph` / `CausalConeType` (light-cone causality) / `TemporalPhase` / `AnticipationHint`.
- **exo-exotic** (`//!` "Karl Friston Free Energy Principle — brain as prediction machine") = **ACTIVE INFERENCE engine**: `CognitivePhase` / `DreamState` / `DevelopmentStage` / `DecisionOutcome` / `CoordinationState` / `AttractorType`.
- **exo-federation** (deps `exo-core` + `domain-expansion` + `pqcrypto-kyber` + `chacha20poly1305` + `hmac` + `sha2` + `zeroize`) = **FEDERATED COHERENT-COMMIT CONSENSUS with POST-QUANTUM crypto**: `ConsensusMessage` / `CommitResult` / `CoherentCommitResult` / `FederationScope` / `Capability` / `PayloadType`; **TRANSPORT-AGNOSTIC** (no network lib) = consensus PROTOCOL + crypto, not a daemon; the genuinely agentic/distributed-leaning crate (`federated-collective-phi` rides on this).
- **exo-backend-classical** (deps `exo-core` + `manifold` + `temporal` + `federation` + `exotic` + `ruvector-core`/`graph`/**DOMAIN-EXPANSION** + `thermorust` + `dither`) = **the INTEGRATING RUNTIME**: runs cognitive `CycleResult` cycles composing all exo subsystems, routed by domain-expansion; `ExoGraphDomain` / `ExoRetrievalDomain` / `DitheredQuantizer`.
- **exo-node** (napi) + **exo-wasm** (wasm) = JS/browser bridges (`ExoSubstrateNode` / `ExoSubstrate` / `Pattern`).

**Agentic role:** alternative cognitive-substrate runtime; `exo-federation` = multi-agent PQ-secured consensus protocol; `exo-exotic` = active-inference decision engine; `exo-backend-classical` = domain-expansion-routed cognitive-cycle runtime. **PATIENCE-PAYOFF:** `domain-expansion` now consumed by postgres + robotics + exo-backend-classical + exo-manifold + exo-temporal + exo-exotic + exo-federation = **THE pervasive routing brain** (the runtime hot-swap selector, ties `interchangeable-parts-runtime-hotswap`).

---

## B17f — Exo research prototypes (`codewalk-b17f-exo-research-prototypes`, conf 0.50)

**CODE-TRUTH B17f** (strict + verified, exo-ai-2025/research apps, **11**). **KEY CODE-TRUTH:** all 11 have **ZERO internal deps** (no `exo-*` or `ruvector-*` deps) = **STANDALONE one-shot SIMD research prototypes/simulations** that REIMPLEMENT their own primitives, NOT integrated with the substrate. `//!` docs repeat "SIMD-Optimized Operations for X." **VERIFIED FALSE POSITIVES** (trust code): `federated-collective-phi` "tonic/NET" = a comment (deps are `serde`-ONLY); it SIMULATES federated consensus IN-PROCESS via `ConsensusNode` / `ConsensusResult` types, not a networked daemon. `meta-sim` "loop/async" = `for _ in 0..time_steps` sim loop, not a daemon. So **NONE** are deployed networked agents.

Apps:
1. **neuromorphic-spiking** — bit-parallel SIMD spike propagation.
2. **quantum-cognitive-superposition** — quantum-inspired cognition SIMD.
3. **time-crystal-cognition** — Floquet periodic dynamics.
4. **sparse-persistent-homology** — sub-cubic TDA + SIMD matrix.
5. **demand-paged-cognition** — memory-mapped neural fields, demand-paging large fields from disk.
6. **federated-collective-phi** — IN-PROCESS SIMULATION of distributed collective IIT-Phi consensus: `ConsensusNode` / `ConsensusResult`; explores the collective-consciousness pattern.
7. **causal-emergence** — Hierarchical Causal Consciousness (HCC) framework.
8. **meta-sim-consciousness** — ergodic meta-simulation of consciousness.
9. **hyperbolic-attention** — Lorentz/hyperboloid model, learnable curvature adaptation.
10. **thermodynamic-learning** — physics-based intelligence, thermodynamic learning algos.
11. **conscious-language-interface** — CONSCIOUSNESS-AWARE ROUTER + spike-embedding bridge + language interface + novel learning.

**Agentic role:** **RESEARCH/INCUBATION ARM** — independent novel-algorithm explorations of agentic-cognitive primitives (collective consciousness, conscious routing, neuromorphic, active-inference-adjacent) that may PROMOTE into the main ruvector crates later (ruvnet research → productization pattern). Distinct from the deployed domain examples (boundary/consciousness families) which DO compose the substrate. **exo research = not yet wired in** (parallels the orphaned-adapter pattern: incubating).

> **Re-explored:** see open item [`todo-reexplore-b17f-exo-research`](#open-item--re-explore-b17f-exo-research-todo-reexplore-b17f-exo-research-conf-060) below for the resolved algorithm-level finding.

---

## B17g — SevenSense bioacoustic platform (`codewalk-b17g-sevensense-bioacoustic`, conf 0.50)

**CODE-TRUTH B17g** (strict + verified, vibecast-7sense / sevensense, **11 crates**). **KEY:** this is an **INDEPENDENT DDD BIOACOUSTIC-ANALYSIS PLATFORM, NOT a ruvector example** — `sevensense-core` `//!` = "7sense bioacoustic analysis"; uses its **OWN stack** (Qdrant + instant-distance for vectors, ONNX/`ort` for embeddings, its own GNN), **ZERO `ruvector`/`rvf` deps** (confirms it is a **CO-LOCATED SIBLING PRODUCT**, not part of the RuVector agentic substrate).

Bounded contexts (DDD):
- **sevensense-core** — shared types/traits: `AnalysisTarget` / `Type`, `AudioFormat`, `ConfidenceError`.
- **sevensense-audio** — DSP ingestion: `symphonia` decode + `rubato` resample + `realfft` + `hound` WAV; `AudioIngestionService` / `SignalQuality` / `RecordingStatus`.
- **sevensense-embedding** — ONNX `ort` audio embedding: `ExecutionProvider` / `ModelStatus` / `InferenceError` / `BatchStatus`.
- **sevensense-vector** — QDRANT-backed vector store + instant-distance HNSW; `DistanceMetric` / `EdgeType` / `ExportFormat` — **NOT ruvector**.
- **sevensense-analysis** — clustering/anomaly + event-driven: `ClusteringMethod` / `AnomalyType` / `LinkageMethod` / `EventPublishError`.
- **sevensense-learning** — OWN GNN: `GnnLayer` / `GnnModelType` / `Aggregator` / `Device`.
- **sevensense-interpretation** — evidence-backed CLAIM generation: `Claim` / `ClaimBuilder` / `ClaimGenerator` / `EvidenceRefType` = explainability.
- **sevensense-api** — **THE service surface**: `axum` + `async-graphql` + `utoipa-swagger` + `governor` rate-limiting, composes all contexts; `ApiError` / `ProcessingStatus`.
- Plus **sevensense-benches**, **vibecast-tests**, **performance-report** (test/bench/script).

**VERIFIED:** only `sevensense-api` has a real network service (`axum`/graphql); `tonic`/`hyper` markers on other crates = transitive/comments. **Agentic role in RuVector = NONE** (independent product); demonstrates the ruvnet team's app pattern (DDD + Qdrant + ONNX + GraphQL). **CONTRAST** with the domain examples that DO compose ruvector (boundary/consciousness/rvdna). *Note: "vibecast" + "7sense" = the product name; the `vibecast-7sense` example dir holds this whole sibling app.*

> **Re-explored:** see open item [`todo-reexplore-b17g-sevensense`](#open-item--re-explore-b17g-sevensense-todo-reexplore-b17g-sevensense-conf-060) below for the resolved finding (Perch 2.0 bird-song product, future migration target).

---

## B17h — Agentic integration examples (`codewalk-b17h-agentic-integration`, conf 0.50)

**CODE-TRUTH B17h** (strict + verified, the OVERTLY-AGENTIC integration examples, **5**). **THIS** is where real agentic wiring concentrates (NOT the domain demos).

- **a2a-swarm** (deps `rvagent-cli` + `reqwest`; `//!` = "rvAgent A2A swarm demo — orchestrator binary") = **THE deployed MULTI-AGENT ORCHESTRATOR**: coordinates rvAgent agents over the A2A (Agent2Agent/Google) protocol = rvAgent + A2A in action.
- **verified-applications** (deps `ruvector-verified` = Lean proof crate **B4**) = **FORMAL VERIFICATION APPLIED TO AGENT GOVERNANCE**: types `AgentContract`, `CertifiedConfig`, `DiagnosticBundle` / `Step`, `ForensicBundle` / `ForensicInvariants`; `//!` covers "Multi-Agent Contract Enforcement" + "Financial Order Routing Integrity" + "On-Device Medical Diagnostics with Forensic[ invariants]." ⇒ **FORMALLY-VERIFIED AGENT CONTRACTS** (`AgentContract`) — directly relevant to the meta work-order/governance decision (S1/S2): **a verified contract = a provable work-order.**
- **ospipe** (OSpipe; `axum` + `TcpListener` service) = **OS-CAPTURE OBSERVATION → VECTOR PERCEPTION DAEMON**: `CaptureSource` / `FrameContent` / `IngestResult` / `QuantizationMethod` / `QueryRoute` + content-safety gate; ties to `rvf-adapter-ospipe` (**B6** observation-state → RVF) — captures OS/screen state, makes it queryable.
- **ruvector-robotics-examples** (deps `ruvector-robotics`) = robot-swarm examples via MCP + consensus (verified MCP + Consensus markers) = `agentic-robotics-mcp` + `ruvector-robotics` deployed (robot swarm, MCP-controlled, multi-robot consensus).
- **refrag-pipeline-example** (deps `ruvector-core`) = **REFRAG RAG context COMPRESS/EXPAND pipeline** (`CompressionStrategy` / `RefragAction` / `PolicyError`, policy-gated tensor projection); compute-only.

**NET:** the agentic ROLE the user pointed to lives HERE — `a2a-swarm` (rvAgent swarm orchestrator), `verified-applications` (verified agent contracts), `ospipe` (perception daemon), robotics (MCP + consensus swarm). Confirms **T11** (MCP seam) + **T1** (now with `AgentContract` formal verification) + rvAgent as deployable agent runtime. **KEY S1 INPUT:** `ruvector-verified` + `AgentContract` = formally-verified agent contracts = candidate substrate for the meta work-order envelope / governed continuity ledger.

---

## B17i — Edge agent fleet (`codewalk-b17i-edge-agent-fleet`, conf 0.50)

**CODE-TRUTH B17i** (strict + verified, rvf/edge/esp32/onnx, **10**). **THE DEPLOYED EDGE-AGENT FLEET across the device spectrum.**

- **ruvector-edge** = **REAL P2P EDGE AGENT**: deps `ruv-swarm-transport` (the ruv-swarm P2P layer) + `bulletproofs` + `merlin` (ZERO-KNOWLEDGE proofs) + `gundb` (decentralized P2P graph DB) + `ed25519`/`x25519`/`aes-gcm`; types `AgentRole` / `MessagePayload` / `CompressedData` / `ArtifactType` = distributed swarm node, ZK-proofed, agent-messaging, tensor compression for net transfer.
- **ruvector-edge-net** = `@ruvector/edge-net` wasm node — **PATIENCE PAYOFF:** COMPOSES the **B16** standalone wasm-only crates (`ruvector-exotic-wasm` + `learning-wasm` + `nervous-system-wasm` + `economy-wasm`) ⇒ their Rust consumer FOUND (not orphaned); types `BrainOperation` + `AmmError` (automated-market-maker) + `AttackType` + `AttentionType` = browser edge agent with brain ops + economy/AMM + learning + security.
- **ruvllm-esp32** = `no_std` **TINY-LLM INFERENCE ON ESP32 microcontroller** (`esp-idf` + `heapless` + `postcard`); `ClusterTopology` / `CommunicationBus` = multi-MCU CLUSTERING (microcontroller LLM cluster).
- **ruvector-mmwave-sensor** = ESP32 firmware for MR60 mmWave radar (`esp-idf` + `ruvector-mmwave` **B13**).
- **ruvector-ios-wasm** = ON-DEVICE iOS PERSONAL-ASSISTANT agent (`ActivitySuggestion` / `CalendarEventType` / `CommEventType` / `AppCategory` / `Capability`).
- **rvf-desktop** = `wry`/`tao` DESKTOP GUI wrapping "Causal Atlas" dashboard (`tiny_http`).
- **rvf-kernel-optimized** = VERIFIED Linux-kernel + eBPF → RVF embedding (deps `ruvector-verified`; `VerifiedIngestPipeline` / `KernelEmbedResult` / `VerifiedRvfConfig`) = formally-verified self-boot container.
- **rvf-examples** = full RVF feature showcase (whole rvf stack + launch/QEMU + server + ruqu).
- **ruvector-onnx-embeddings** = GPU (`wgpu`) ONNX embedding service (`ort` + `tokenizers`, `reqwest` model download; `ExecutionProvider` / `GpuMode`).
- **ruvector-cloudrun-gpu** = `axum` GPU deploy on Google Cloud Run (`ruvector-core`/`gnn`/`attention`/`graph`; `AutonomousModel` / `Industry` / `SimdCapability`).

**Agentic role:** deployed edge-agent fleet spanning **cloud** (cloudrun) → **desktop** (rvf-desktop) → **browser/wasm** (edge-net, ios) → **P2P swarm** (ruvector-edge via `ruv-swarm-transport` + ZK + gundb) → **microcontroller** (esp32 clustered LLMs). **NEW external dep to map:** `ruv-swarm-transport` (ruv-swarm P2P) = another agent-coordination substrate alongside weave / A2A / MCP.

---

## B17j — Data ingestion and demos (`codewalk-b17j-data-ingestion-and-demos`, conf 0.50)

**CODE-TRUTH B17j** (FINAL example slice, **~18**).

**DATA-ACQUISITION/INGESTION AGENTS:**
- **ruvector-data-framework** (deps `ruvector-onnx-embeddings`; finance & economics API integrations → embeddings = the ingestion hub) ← **ruvector-data-edgar** (SEC EDGAR filings), **ruvector-data-openalex** (OpenAlex academic papers API), **ruvector-data-climate** (climate sensor-network graph construction) = the system's external **DATA FEEDERS** (finance/SEC/academic/sensors → vector store).
- **train-discoveries** (deps `ruvector-core` + `solver` = "Discovery ETL Pipeline using RuVector Sublinear Solver") = the **AGGREGATION/LEARNING LOOP** that processes the discovery-agents' outputs (the other half of the discovery fleet: boundary/consciousness agents DISCOVER → train-discoveries aggregates/trains).
- **ruvllm-esp32-flash** ("RuvLLM ESP32 — Tiny Agents on Heterogeneous SoCs") = embedded AGENT deployment on microcontrollers/SoCs.
- **ruvllm** (`examples/ruvLLM`; deps `core` + `gnn` + `attention` + `graph` + `ruvllm-lib` + `sona`) = LLM memory compression/abstraction app.
- **musica** (dep `ruvector-mincut`) = audio source separation via mincut graph-parameter optimization.

**MATH/CAPABILITY DEMOS** (mostly mincut/solver):
- **mincut-examples** + **temporal-attractors-mincut-demo** + **subpolynomial-time-mincut-demo** (mincut algorithm demos).
- **prime-radiant-category** (Category Theory + Topos module on `ruvector-solver`).
- **delta-behavior** ("Mathematics of Systems That Refuse to Collapse" = robustness/dynamics, no deps).
- **ultra-low-latency-sim** (Bit-Parallel SIMD Simulation Primitives, no deps, standalone like exo-research).
- **ruvector-scipix** (scientific compute, standalone).
- **ruvector-benchmarks** (bench lib, `core` + `rvf`).

**BRIDGES:** **prime-radiant-advanced-wasm** (wasm build of prime-radiant convergence runtime), **ruvector-onnx-embeddings-wasm** (wasm onnx embedder).

**NET:** completes the example fleet picture — **DATA FEEDERS** (data-*) + **DISCOVERY AGENTS** (boundary/consciousness B17a–c) + **AGGREGATION** (train-discoveries) + **EDGE AGENTS** (B17i) + **ORCHESTRATION** (a2a-swarm / verified-applications B17h) = a full **autonomous scientific-discovery + agentic pipeline**. **ALL 314 crates now STRICT-WALKED.**

---

## Cognition / consciousness substrate (`codewalk-cognition-consciousness-layer`, conf 0.50) — B9

**CODE-TRUTH B9** (cognition/consciousness substrate, **7 crates**).

- **ruvector-consciousness** = **GENUINE IIT-Phi engine**: 5 Phi algorithms (`ExactPhiEngine`, `ChebyshevPhiEngine`, `GeoMipPhiEngine`, `GreedyBisectionPhiEngine`, `HierarchicalPhiEngine`), `CauseEffectStructure` / `Distinction`, `Bipartition` + `GrayCodePartitionIter`, `build_mi_matrix(TPM)` → `build_sparse_laplacian`, `CausalEmergenceEngine` / `EmergenceResult`, `coarse_grain` / `degeneracy` / `ces_complexity`, `ComputeBudget`; deps `ruvector-solver` + `sparsifier` + `mincut` + `math` + `coherence` + `cognitive-container`.
- **ruvector-cognitive-container** (**KEYSTONE**, deps `serde` ONLY, self-contained) = a **DETERMINISTIC, EPOCH-BUDGETED, WITNESSED, COHERENCE-GATED execution container** = **T1 incarnate as software**: `CognitiveContainer` / `ContainerConfig` / `ContainerEpochBudget` / `ContainerSnapshot` / `ContainerWitnessReceipt` / `EpochController` / `Arena` / `MemorySlab` / `ComponentMask` / `Phase` / `CoherenceDecision` / `VerificationResult` / `TickResult`; `phase_budget(Phase)` / `phase_used`, `consume(ticks)`, `latest_receipt`, `deterministic_hash`. Consumed by `ruvector-verified` (**B4**) + consciousness. **The unit of governed cognition** (CLAUDE.md "cognitive container /30s").
- **ruvector-nervous-system** (deps `rand` + `ndarray`, self-contained) = bio-inspired: `BTSPAssociativeMemory` / `BTSPLayer` / `BTSPSynapse` (Behavioral-Timescale Synaptic Plasticity), Hopfield, HDC (hyperdimensional computing, `HdcError`), `CircadianController` / `Scheduler` / `Phase` (SLEEP/WAKE consolidation: `allows_consolidation` / `allows_learning`), `BackpressureController`, `BudgetGuardrail`, `apply_ewc`.
- **TRAP — ruvector-crv** = Controlled Remote Viewing protocol mapped onto embeddings (deps `attention` + `gnn` + `mincut`): `StageI-IV` encoders, `AOLDetection` (Analytic Overlay = CRV term ⇒ here HALLUCINATION/BIAS detection), `SketchElement` / `SignalLineProbe` / `GestaltType` / `SpatialRelationType`, `consensus(embeddings)`, `CrvSessionManager` ⇒ staged embedding-consensus + bias-detection pipeline.
- **TRAP — ruvector-domain-expansion** = **NOT** "domain expansion" literally; a **CONTEXTUAL MULTI-ARMED BANDIT / Thompson-sampling TASK ROUTER**: `ArmId` / `BetaParams` / `ContextBucket` / `BucketRegret` / `AccelerationScoreboard` / `CostCurve` / `PlateauAction`, `boosted_score(bucket,arm,thompson_sample)`, `check_plateau`, routes `OrchestrationCategory` / `PlanningCategory` / `RustTaskCategory` to best policy, persists to RVF (`rvf-types`/`wire`/`crypto`). = Rust-native of ruflo MoE routing.
- **ruvector-perception** (deps `mincut` + `sha2`) = boundary-perception (`BoundaryPredictor` / `detect_boundary` / `Modality` / `Stimulus` / `Hypothesis`, `decide(novelty,coherence,contradiction)`, `forecast`) PLUS custody/anti-spoof (`CaptchaVerifier` / `ChallengeResponse` / `CustodyLedger` / `CustodyRecord` / `DeltaWitness`, `enroll(signature)`) = perception WITH provenance.
- **ruvector-temporal-tensor** (NO deps) = delta-encoded TIERED time-series tensor store: `AdaptiveTiering` / `Tier` / `TierChangeReason`, `DeltaChain` / `Header` / `Record`, `apply_delta`, `CoherenceCheck` / `Result`, `EpochTracker`, `WitnessEvent`, `ReconstructPolicy`.

**T1 PERVASIVE:** budget + witness + coherence in every crate (`ComputeBudget`, `BudgetGuardrail`, `ContainerEpochBudget` + `WitnessReceipt` + `CoherenceDecision`, `CustodyLedger`, `WitnessEvent` + `CoherenceCheck`). **NEW:** `cognitive-container` is the software T1 unit; `domain-expansion` routes tasks (consumer of RVF, MoE-equivalent).

---

## Cognitum hardware coherence-gate tier (`codewalk-cognitum-gate-tier`, conf 0.50) — B8

**CODE-TRUTH B8:** the **COGNITUM HARDWARE COHERENCE-GATE tier** = the **PHYSICAL ROOT of thesis T1** (governed/gated/attested compute), plus the agent-facing MCP seams.

**GATE PIPELINE** (ADR-178 anytime-valid coherence permit/veto, proven in code):
1. **cognitum-gate-kernel** (`cdylib` `no_std`; deps `ruvector-mincut` + `libm`) = PER-TILE runtime: `CompactGraph` + `ArenaCactus` / `CactusNode` (cactus mincut rep), `add_cut_hypothesis` / `add_connectivity_hypothesis`, `EvidenceAccumulator` with `LogEValue` (ANYTIME-VALID e-values / log-likelihood), `FixedPointWeight` (no FPU on tile), `aggregate_tile_evidence(&[LogEValue;255])` across 255 tiles, `CanonicalWitnessFragment`. **The hardware tile COMPUTES mincut coherence evidence.**
2. **cognitum-gate-tilezero** (deps `ruvector-mincut` + `blake3` + `ed25519` + `tokio`) = **TILE-0 COORDINATOR**: async `decide(ActionContext)` → `GateDecision` (permit/deny/defer = `EvidenceDecision` / `DecisionOutcome`), `collect_reports(TileReport)`, `aggregate_evidence`, `aggregate_shift_pressure` (cut-pressure / coherence-shift, ties `rvm-sched` + `ruvix-sched`), emits **SIGNED REPLAYABLE `WitnessReceipt` chain** (`verify_receipt_chain` / `replay` / `get_receipt` / `export_receipts_json`).
3. **mcp-gate** (bin; deps `cognitum-gate-tilezero`) = **MCP SERVER** (`run_stdio`) exposing the gate as tools: `PermitActionResponse` / `DenyResponse` / `DeferResponse` + `EvidentialInfo` + `GetReceipt`; `to_action_context`, `with_tilezero(Arc<RwLock<TileZero>>)`, `GateThresholds`. **THIS IS WHERE AGENTS (ruflo / rvAgent / Claude) ASK THE HARDWARE FOR PERMISSION** — the seed's `/mcp` endpoint.

**BRAIN SEAM:** **mcp-brain** (bin; deps `reqwest` + `sona` + `sha3`) = MCP client/server to **pi.ruv.io shared brain**: `BrainClient` / `BrainEmbedder` / `BrainPipeline` / `BrainMemory`, `get` / `promote_page` / `revoke_node` / `list_deltas` / `lora_latest`, `VoteDirection` + `BetaParams` (Bayesian reputation).

**NPU HARDWARE:**
- **hailort-sys** (FFI `-sys` to HailoRT NPU lib, `version_triple`).
- **ruvector-hailo** (deps `hailort-sys` + `candle`: `HailoDevice` / `HefEmbedder` / `HefEmbedderPool` / `HefPipeline` NPU embeddings via HEF Hailo-Executable-Format, `CpuEmbedder` candle fallback, `WordPieceTokenizer`, `chip_temperature`).
- **ruvector-hailo-cluster** (6 bins: hailo-worker / embed / stats / bench / mmwave-bridge; deps `tonic`-gRPC + `governor` + `ed25519` + `ruvector-mmwave` + `ruvector-hailo` + `ruvllm`: `HailoClusterEmbedder` / `GrpcTransport` / `HashShardRouter` / `HealthChecker` / `FleetValidation` / `EmbeddingCache`; power-of-two-choices LB, gossip health, fleet model-fingerprint, ruvllm `generate`, mmwave radar bridge) = the distributed **cognitum-seed NPU FLEET/mesh**.

**EDGE:** **ruos-thermal** (bin, linux sysfs; `ThermalSensor` / `CpuTemp` / `ClockProfile`, `apply_profile` / `target_max_hz` / `estimated_watts` = DVFS thermal governor).

**DOC-NAME-TRAP:** `thermorust` is **NOT** thermal mgmt — it is an **ISING/HOPFIELD/SPIN-GLASS energy-model engine** (`EnergyModel` trait, `Ising` / `SoftSpin`, `free_energy`, `langevin_noise`, `hopfield_memory`, `inject_spikes`; deps `rand` only) = statistical-physics annealing/associative-memory, used by energy-based/boundary/consciousness examples.

**SYNTHESIS:** coherence = mincut e-value evidence computed **IN HARDWARE** (255 tiles); tile-zero aggregates → signed permit/veto receipt; `mcp-gate` is the agent API. **T1 has a literal HARDWARE root.** The cognitum seed = ruvix kernel + Hailo NPU (`ruvector-hailo`) + coherence gate (`cognitum-gate-*`) via `mcp-gate`, clustered (`ruvector-hailo-cluster`), thermal-governed (`ruos-thermal`).

---

## Delta / distributed / persistence tier (`codewalk-delta-distributed-tier`, conf 0.50) — B10

**CODE-TRUTH B10** (delta-* CRDT family + distributed/persistence tier, **11 crates**). **HONEST tier** (no traps; governance/witness seam is in COMPUTE/COGNITION crates, NOT this plumbing).

**DELTA FAMILY:**
- **ruvector-delta-core** (deps `simsimd` + `lz4` + `zstd`) = windowed delta-compression STREAM engine (`DeltaStream` / `DeltaOp` / `DeltaCompressor` / `DeltaValue` / `EncodingType` / `WindowType` / `AverageAggregator`).
- **ruvector-delta-graph** (dep `delta-core`) = delta-encoded graph mutations + `DeltaAwareTraversal` (`EdgeDelta` / `GraphDelta` / `EdgeOp` / `PropertyOp`).
- **ruvector-delta-index** (dep `delta-core`) = **INCREMENTAL SELF-REPAIRING HNSW** (`DeltaHnsw`, `IncrementalUpdater`, `GraphRepairer` / `LocalRepair` / `RepairStrategy`, `QualityConfig`) = the live-update index.
- **ruvector-delta-consensus** (dep `delta-core` + `tokio`) = CRDT layer (`GCounter`, `CausalDelta` / `CausalOrder`, `DeltaConsensus`, `DeltaGossip`, `ConflictStrategy` / `ClippedMergeResolver` / `FirstWriteWinsResolver`, `DeliveryStatus`).

**DISTRIBUTED:**
- **ruvector-raft** = textbook Raft (`RaftState` / `Message`, `AppendEntries`, `InstallSnapshot`, `LeaderState`, `ElectionTimer`, `LogEntry`).
- **ruvector-cluster** = `ClusterManager` + `ConsistentHashRing` + `DagConsensus` / `DagVertex` (DAG consensus alt to raft) + `ShardStatus` + `TransactionType`.
- **ruvector-replication** = CDC `ChangeEvent` + `ClockOrdering` (vector clocks) + `FailoverManager` / `Policy` + `LastWriteWins` + `SyncMode` + `Checkpoint`.
- **ruvector-snapshot** = PITR backup (`SnapshotManager` / `SnapshotStorage` trait / `LocalStorage`, `flate2` + `sha2`).

**ACCESS/SERVING (+ patience-payoffs):**
- **ruvector-postgres** = big `pgrx` cdylib **pgvector-DROP-IN** that embeds the WHOLE compute stack as SQL (deps `pgrx` + `simsimd` + `fastembed` + `ruvector-mincut-gated-transformer` + `solver` + `math` + `attention` + `sona` + **DOMAIN-EXPANSION**); huge SQL/Cypher AST (`Expression` / `Clause` / `BinaryOperator` / `Aggregate`, `EmbeddingModel` / `AttentionType` / `FusionMethod` / `AgentType` / `EdgeType`) = the "230+ SQL functions" crate ⇒ **CONSUMER of domain-expansion bandit router** (T7 patience-payoff).
- **ruvector-server** = `axum` REST Qdrant-like (`Create` / `Search` / `Upsert` / `Health`).
- **ruvector-node** = `cdylib` + `napi` = `@ruvector/core` (deps `core` + `collections` + `filter` + `metrics`; `Js*` types) = **THE NATIVE BACKEND the `ruvector` TS facade prefers** (confirms ruflo wiring at crate level) + Rust consumer of collections/filter/metrics.

**NET:** standard distributed-vector-DB machinery (Raft + CRDT + sharding + replication + snapshot + REST + PG + napi); the `@ruvector/core` native module = `ruvector-node`.

---

## Foundation: solver / math / DAG (`codewalk-foundation-solver-math-dag`, conf 0.50)

**CODE-TRUTH walk** (deps + types, **NOT docs**) of graph-transformer-stack foundation crates.

**KEY DOC-CONTRADICTION:** **ruvector-dag**'s Cargo blurb says "DAG for query plan optimization" but real deps (`pqcrypto-dilithium`, `pqcrypto-kyber`, `zeroize`, `sha2`, `tokio`) + real types (`DsaError` / `KemError` / `KeystoreError` / `IdentityError` / `GovernanceError` / `ProposalStatus` / `ProposalType` / `StakingError` / `RewardSource` / `SyncStatus` / `RedundancyStrategy` / `DriftTrend` / `HealthStatus`) + mods (`qudag` / `healing` / `sona`) prove it is a **QuDAG-style POST-QUANTUM GOVERNANCE/CONSENSUS DAG** (staking, proposals, KEM/DSA identity keystore, self-healing, drift/health monitoring) — **NOT a query-plan optimizer.** Code wins; flag doc.

Other crates (code-verified):
- **ruvector-solver** = real `Neumann` / `ConjugateGradient` / `ForwardPush` / `BackwardPush` / `Bmssp` / `HybridRandomWalk` solvers + `CsrMatrix`, PLUS a budget/audit **GOVERNANCE layer** (`ComputeBudget`, `BudgetEnforcer`, `AuditBuilder`, `ComputeLane`, `ComplexityClass`) the blurb omits — **sublinear solving is budget-metered + audited.**
- **ruvector-math** = honest: TDA (`AlphaComplex` / `BettiNumbers` / `BottleneckDistance` / `FilteredSimplex`), tensor-networks (`CPDecomposition` / `DenseTensor`), info-geometry (`DiagonalNaturalGradient`), spectral (`Chebyshev`), SDP/SOS (`BoundsCertificate`); deps `nalgebra` / `rand` / `rayon`.
- **ruvector-collections** = honest thin wrapper over `ruvector-core` (`Collection` / `CollectionManager` / `Config` / `Stats`; + primality ADR-151).
- **ruvector-graph** = real deps `core` + `cluster` + `raft` + `replication` (genuinely distributed); mods cypher / hyperedge / transaction / distributed / storage.

**PATTERN OBSERVED:** ruvnet crates carry a recurring governance/witness/budget/proof seam **even in "pure compute" crates.**

---

## Graph-transformer stack (`codewalk-graphtransformer-stack`, conf 0.50)

**CODE-TRUTH walk** (deps + types) of the rest of the graph-transformer stack.

1. **ruvector-verified** = **THE FORMAL-PROOF BACKBONE**: deps `lean-agentic` (Lean theorem prover) + `ruvector-cognitive-container`; types `ProofKind` / `ProofTier` / `ProofEnvironment` / `ProofAttestation` / `FastTermArena` / `BuiltinDecl` / `ConversionCache` / `VerifiedInsertPrecondition` / `VerifiedOp` / `VerifiedStage` / `TierDecision` ⇒ tiered Lean-backed attested proof-gating. Roots the ecosystem-wide proof seam (`rvm-proof`, graph-transformer `ProofClass`, solver audit).
2. **ruvector-gnn** = Rust-native intelligence pipeline: `ElasticWeightConsolidation` + `ColdTierEwc` + `ColdTierTrainer` (EWC++ continual-learning = CONSOLIDATE step), `GraphMAE` / `Decoder` (masked autoencoder, self-supervised), `GATEncoder`, `GRUCell`, `AdaptiveHotset`, `Hyperbatch` + `memmap2` / `page_size` (cold-tier >RAM training), `CompressedTensor`. deps just `ruvector-core` + `ndarray`.
3. **ruvector-graph-transformer** = **CONVERGENCE crate**, deps CODE-CONFIRM the chain `{verified, gnn, attention, mincut, solver, coherence}`; types expose 8 modules: `ManifoldType` / `LieGroupType` (geometric), `HebbianRule` / `GrowthRuleKind` / `InhibitionStrategy` (bio/self-org), `ConservativePdeAttention` (physics), `ComplexityBound` / `ComplexityClass` (sublinear), `CausalGraphTransformer` (temporal/causal), `TrainingInvariant` / `ProofClass` / `ProofRequirement` / `AttestationChain` (verified-training), `EnergyGateResult`, `RollbackStrategy`, `StorageTier`.
4. **DOC-CONTRADICTION — ruvector-coherence** blurb = "sheaf-Laplacian coherence engine" but real deps = **ONLY `serde`**; real types = `HnswHealthMonitor` / `SpectralCoherenceScore` / `SpectralConfig` / `SpectralTracker` / `DeltaMetric` / `HealthAlert` / `QualityResult` / `CsrMatrixView` ⇒ it is a **LIGHTWEIGHT HNSW health + spectral-drift MONITOR, not a heavy sheaf engine.** Flag.
5. **ruvector-graph** = genuine **DISTRIBUTED property/hypergraph DB** (code: `petgraph` + `roaring`, 3 Cypher parsers `nom`/`pest`/`lalrpop`, gRPC federation `tonic`/`prost`/`tower`/`hyper`, raft + cluster + replication deps, `redb`, ART index, `IsolationLevel`, `FederationStrategy` / `GossipMessage` / `MembershipEvent`).
6. **ruvector-filter** = honest payload-index/filter (`FilterExpression` / `PayloadIndex` / `Evaluator`) over core.

**NEW:** `lean-agentic` is an external proof dependency to map.

---

## LLM / sona serving stack (`codewalk-llm-sona-stack`, conf 0.50)

**CODE-TRUTH walk** of LLM-serving + sona stack.

- **ruvllm** = full production LLM runtime: deps `ruvector-core` + `sona` + `attention` + `graph` + `gnn` + `candle-core` / `candle-nn` / `candle-transformers` (HF Candle) + `tokenizers` + `hf-hub` + `memmap2`; types = `AcceleratorType`, `AneOptimization` / `AneStrategy` (Apple Neural Engine), `BNNSActivationFunction` / `BNNSDataType` (Apple BNNS), `CblasOrder` / `CblasTranspose` (BLAS), `Architecture`, `ChatTemplate`, `CacheTier` / `CacheQuantization` / `CacheLocation` (KV-cache tiering), `CalibrationMethod` / `CalibrationDomain` (quant calibration), `AblationMode`, `AgentState` / `AgentType`, and **CRUCIALLY** an enum ⇒ **ruvllm NATIVELY MODELS claude-flow agents** (code anchor for "where ruflo fits" — ruflo agent roles exist as a Rust type in ruvllm).
- **ruvllm_sparse_attention** = lean subquadratic attention kernel (`SubquadraticSparseAttention`, `IncrementalLandmarks`, `FastGrnnGate`, `KvCache` / `KvCacheF16`, `Tensor3`, `AttentionBackend` trait; deps `rayon` / `half` / `libm` only).
- **ruvllm_retrieval_diffusion** = tiny RAG-diffusion (`Retriever` / `Diffuser` / `RetrievalConfig` / `SamplingConfig`; dep = `ruvllm_sparse_attention` only).
- **ruvector-sparse-inference** = PowerInfer-style edge engine (GGUF loader `GgufTensorType` / `Value`, `BertEmbeddings` / `BertLayer`, `PrecisionLane` / `LaneQuantizer` mixed-precision, `GraduationDecision` / `TransitionReason` hot/cold neuron prediction, `AngularEmbedding` RoPE; deps `ndarray` / `memmap2` / `half`).
- **ruvector-fpga-transformer** = **GATED ACCELERATOR ENGINE** (not just FPGA): types `CoherenceConfig` / `CombinedGate` / `DefaultCoherenceGate` / `DefaultPolicyGate` / `GateDecision` + `ed25519-dalek` signing + `DaemonConnection` / `DaemonConfig`; **the cognitum coherence-gate pattern recurs here.**
- **sona** (dir) = **agent-factory + federated-learning + LoRA system**: `AgentFactory` / `AgentHandle` / `AgentStats` / `AgentExport` / `AgentContribution`, `FederatedTopology`, `AggregationResult`, `TrainingMethod`, `AdapterConfig` (LoRA), `PatternType`, `BackgroundLoop`; inline `wasm-bindgen` AND `napi` bridges.

**MAJOR CROSS-CUTTING** (code-backed): the ecosystem's true unifying signature = **GOVERNED / GATED / ATTESTED COMPUTE** — a coherence-gate + policy-gate + proof + witness + budget seam recurs across `solver` (budget/audit), `verified` (Lean proof), `fpga-transformer` (gates), `graph-transformer` (attestation), `rvm` (proof/coherence). **"Coherence-aware hypergraph" is the data model; "gated/attested compute" is the control model.**

---

## Markets / quantum exotic domain (`codewalk-markets-quantum-domain`, conf 0.50) — B12

**CODE-TRUTH B12** (markets + quantum exotic domain, **9 crates**).

**NEURAL-TRADER** = a **COHERENCE-GATED + WITNESSED trading system** (T1 applied to finance), 4 crates:
- **neural-trader-core** (deps `anyhow` + `serde`; traits `Embedder` / `EventIngestor` / `GraphUpdater`, `MarketEvent` → `GraphDelta`, `StateWindow`, `NodeKind` / `EdgeKind` = markets-as-graph abstraction).
- **neural-trader-coherence** (`CoherenceGate` trait + `CoherenceDecision` + `GateConfig` / `Context` + `ThresholdGate` + `VerifiedToken` + `WitnessReceipt` + `WitnessLogger` trait + `RegimeLabel` = trades are **COHERENCE-GATED and WITNESSED**, same pattern as cognitum tier).
- **neural-trader-replay** (deps `core` + `coherence`; `MemoryStore` trait, `ReplaySegment`, `ReservoirStore` [reservoir sampling], `InMemoryReceiptLog`, `SegmentLineage`, `CoherenceStats` = experience replay + witness-receipt lineage).
- **neural-trader-strategies** (deps `core` + `coherence` + `ruvector-attention`; `AttentionScalper`, `CoherenceArb`, `ExpectedValueKelly` [Kelly sizing], `CoherenceChecker`, `RiskDecision`, `RejectReason` = real strategies using attention).

**ruvector-kalshi** (deps `neural-trader-*` + `rsa` + `reqwest` + `tokio-tungstenite` + `BrainClient`) = **LIVE KALSHI PREDICTION-MARKET client**: REST + websocket `FeedDecoder`, RSA-signed orders (`Signer` / `Credentials`), `post`/`cancel`/`amend_order`, orderbook, `list_markets`.

**SHARP TRAP PAIR** (distinct dirs, near-identical names, OPPOSITE purposes):
- **(A) ruQu** (capital Q) is **NOT quantum computing** — deps `ruvector-mincut` + `cognitum-gate-tilezero` + `fusion-blossom` + `ruvector-mincut-gated-transformer`; types `GateDecision` / `ActionType` / `BoundaryId` / `DriftDirection` / `DriftProfile` / `TileAssignment` / `DetectorEvent` / `Precondition` / `LogRecord`; = a **QEC-STYLE minimum-weight-perfect-matching DECODER** (`fusion-blossom` = surface-code MWPM lib) **APPLIED TO THE COGNITUM COHERENCE GATE**: decodes per-tile `DetectorEvents` into robust boundary/gate decisions. **ARCHITECTURAL BRIDGE: B8 gate ↔ mincut ↔ QEC decoding.**
- **(B) ruqu-core / ruqu-algorithms / ruqu-exotic** (lowercase) = **GENUINE quantum-computing simulator**:
  - **ruqu-core** (`Gate` / `PauliOp` / `QuantumCircuit` / `BasisGateSet` / `Kraus` `amplitude_damping` / `MitigationStrategy` / `ExtrapolationMethod` [zero-noise] / `QecControlLoop` / `BackendType` / `JobStatus` = gate-level sim + noise + error-mitigation + simulated cloud backend).
  - **ruqu-algorithms** (dep `ruqu-core`; `VqeConfig` / `Result` [h2_hamiltonian], `QaoaConfig` / `Result` [`build_qaoa_circuit` / `cut_value` = maxcut], `GroverConfig` / `Result`, `SurfaceCodeConfig` / `Layout` [distance_3] = VQE/QAOA/Grover/surface-code QEC).
  - **ruqu-exotic** (dep `ruqu-core`; `ConceptSuperposition` / `ConceptScore` / `CollapseResult` [`collapse(context,seed)`] / `CounterfactualResult`, `check_entanglement` / `interference` / `no_cloning` / `phase_kickback` / `superposition` = quantum-INSPIRED concept reasoning / quantum cognition).

**NET:** neural-trader proves T1 generalizes to a trading domain; `ruQu` links the hardware gate to QEC decoding; `ruqu-*` is a real QC sim. `ruQu` is a **CONSUMER of `cognitum-gate-tilezero` + `mincut-gated-transformer`** (patience).

---

## Mincut / graph compute + index-zoo (`codewalk-mincut-graph-indexzoo`, conf 0.50) — B14

**CODE-TRUTH B14** (mincut/graph compute + cryptic-named crates, **9**).

- **ruvector-mincut-gated-transformer** (deps `thiserror` + `serde` + `getrandom`, self-contained) = mincut-GATED transformer: `GateDecision` / `GateReason`, `KVQuantKeyMode` / `KVQuantValueMode` (KV-cache quant), `CacheTier` / `EvictionDecision`, `ExitReason` (EARLY EXIT), `LambdaDensitySchedule`, `add_spike(time,polarity)` spiking input, `adapt_thresholds(QualityFeedback)`, int8 embeddings; consumed by `ruvector-postgres`.
- **ruvector-attn-mincut** (deps `serde` + `sha2`) = attention + Dinic max-flow MIN-CUT gating: `AttentionGraph` / `AttentionOutput`, `DinicSolver`, `min_cut(graph,s,t)`, `graph_from_logits`, `attn_softmax`, `HysteresisTracker`, `WitnessEntry` (T1); lightweight attention-mincut primitive.
- **ruvector-mincut-brain-node** (deps `ruvector-mincut` + `getrandom`, no pub types) = thin `napi` binding exposing mincut to Node for the brain.
- **ruvector-graph-condense** (deps `ruvector-mincut`) = **GRAPH DATASET CONDENSATION**: `DiffCutCondenser` / `DiffCutConfig`, `CondensedGraph` / `Node` / `Edge`, `condense(DynamicGraph,NodeFeatures)`, `cut_inflation`, `accuracy(preds,labels,mask)` = distills graph to tiny synthetic one preserving GNN training accuracy.
- **TRAP — ruvector-router-core** (deps `redb` + `memmap2` + `simsimd` + `rkyv`) = **NOT request-routing**; a **FULL EMBEDDABLE VECTOR DB**: `VectorDB` / `VectorDbBuilder`, `HnswIndex` / `HnswConfig`, `Storage`, `QuantizedVector`, `SearchQuery` / `Result`, `calculate_compression_ratio` / `distance`.
- **ruvector-decompiler** (deps `ruvector-mincut` + `ort` [ONNX Runtime] + `regex` + `ndarray`) = **ML-ASSISTED BINARY DECOMPILER**: infers names/declarations (`InferredName` / `Declaration` / `DeclKind` / `Confidence` / `InferenceContext` / `InferenceFeedback` / `ModelFormat` / `LayerType`) over a mincut `build_reference_graph(declarations)`; real ML decompilation.
- **ruvector-acorn** (deps `rand` + `rayon`) = FILTERED-ANN index implementing the **ACORN algorithm**: `AcornGraph`, `AcornIndex1` + `AcornIndexGamma` (ACORN-1 / ACORN-gamma variants), `FlatFilteredIndex`, `FilteredIndex` trait = predicate-agnostic filtered vector search.
- **ruvector-rairs** (deps `rand` + `serde`) = IVF ANN index: `IvfFlat`, `RairsSeil` / `RairsStrict`, `AnnIndex` trait, `nearest_centroid` / `two_nearest` / `train(corpus)`.
- **ruvector-rulake** (deps `ruvector-rabitq` + `sha3`) = **VECTOR DATA-LAKE**: `RuLake` / `RuLakeBundle`, `FsBackend` / `LocalBackend` (multi-backend), `Consistency` / `Generation` / `RefreshResult`, witness-keyed cache (`cache_refcount_of(witness)`), `append(collection,id,vector)`, `avg_prime_ms`.

**META-PATTERN (INDEX/DB ZOO):** RuVector ships ~a dozen **INTERCHANGEABLE** vector index/store impls behind common traits (`VectorIndex` / `AnnIndex` / `FilteredIndex`) — HNSW, Vamana (diskann), IVF (rairs), ACORN (acorn), RaBitQ, hyperbolic-hnsw, micro-hnsw, delta-index, router-core, rulake (lake), tiny-dancer-core, rvlite, rvf-index, core; different ALGORITHMS × different DEPLOYMENT SHAPES (embeddable / lake / postgres / server / router). **TRAP:** `router-core` named "router" but is a vector DB. Witness/T1 recurs (`attn-mincut` `WitnessEntry`, `rulake` witness cache).

---

## Prime-radiant + infra / CLIs (`codewalk-prime-radiant-and-infra`, conf 0.50) — B15

**CODE-TRUTH B15** (prime-radiant + infra/CLIs, **16 base crates** incl 4 prior-deep-walked + 2 fuzz).

**MAJOR + DOC-TRAP:** **prime-radiant** — export calls it "visualization/dashboard component" but real deps compose the **WHOLE substrate**: `cognitum-gate-kernel` + `ruvector-sona` + `gnn` + `mincut` + `hyperbolic-hnsw` + `nervous-system` + `attention` + `raft` + `core` + `graph` + `ruvllm` + **WGPU** (GPU compute) + `sqlx`; types `ApplyResult` / `ActionError` / `AdjustmentReason` / `BindingType` / `Activation` / `AttentionMode` = an **AGENTIC APPLY/ADJUST CONTROL LOOP.** ⇒ prime-radiant is a **SECOND GPU-ACCELERATED CONVERGENCE RUNTIME** alongside `mcp-brain-server` (it is gated by `cognitum-gate-kernel`). It is also a **claude-flow plugin** (`@claude-flow/plugin-prime-radiant` 0.1.5) = a place ruflo plugs into the GPU cognitive runtime. **NOT a dashboard.**

- **rvlite** (deps `ruvector-core` + `wasm-bindgen` / `web-sys` + `rvf-runtime` / `rvf-types`; cdylib) = **wasm-first LITE EMBEDDABLE vector store** with a query DSL (`Aggregate` / `AggregationFunction` / `BinaryOp` / `Direction` / `DataType` / `DistanceMetric`); bridged to RVF by `rvf-adapter-rvlite`.

**INFRA** (honest):
- **ruvector-metrics** (`prometheus` + `HealthChecker` / `MetricsRecorder` / `CollectionHealth` / `Readiness`; consumed by `ruvector-node`).
- **ruvector-profiler** (`LatencyStats` / `MemoryTracker` / `EnergyResult` / `MockPowerSource` = latency + memory + **ENERGY** profiler for edge power).

**TOOLS/BINS:**
- **ruvector-bench** (bin: datasets + latency + memory + `plotters` + `pprof` + `jemalloc` + `hdf5`; deps `core` + `mincut` + `coherence` + `cognitive-container` + `cognitum-gate-kernel`).
- **ruvector-cli** (bin: `GraphCommands` / `HooksCommands` / `StorageBackend`, deps `core` + `graph` + `gnn` + `postgres` + `axum` = main CLI with hooks).
- **ruvllm-cli** (bin: `ModelDefinition` / `QuantPreset`, `ruvllm` + `hf-hub` model mgmt).
- **ruvector-router-cli** (thin CLI over `router-core`).
- **ruvector-attention-cli** (bin over attention, serves `axum`).

**BRIDGE:** **ruvector-router-ffi** (cdylib + napi over `router-core`: `VectorDB` / `DbOptions` / `SearchResultJS` = napi binding of the router-core vector DB).

Also marked walked (prior deep passes): `ruvector-core` / `ruvector-mincut` / `ruvector-attention` (covered by `ruvector-unifying-abstraction`), `mcp-brain-server` (`mcp-brain-server-convergence`), + 2 fuzz harness dirs. **CONVERGENCE CRATES are now TWO:** `mcp-brain-server` (HTTP/cloud brain) + `prime-radiant` (GPU local runtime, claude-flow plugin).

---

## Robotics / embodied tier (`codewalk-robotics-embodied-tier`, conf 0.50) — B13

**CODE-TRUTH B13** (agentic-robotics + embodied/edge tier, **9 crates**). **TWO DISTINCT ROBOTICS LAYERS.**

**(1) MIDDLEWARE/TRANSPORT — `agentic-robotics-*` = a Rust-native ROS2/ROS3 ALTERNATIVE on Zenoh + DDS:**
- **agentic-robotics-core** (deps `zenoh` + `rustdds` [DDS] + `cdr` [Common Data Representation] + `rkyv`; `Publisher` / `Subscriber` / `Service` / `Queryable` / `RobotState` / `Pose` / `Point3D` / `PointCloud` / `Serializer` = pub-sub robotics middleware).
- **agentic-robotics-rt** (`RTPriority` / `Deadline` / `PriorityScheduler` / `ROS3Executor` / `LatencyTracker` [`hdrhistogram`] = real-time deadline executor).
- **agentic-robotics-embedded** (`EmbeddedConfig` / `EmbeddedPriority` MCU).
- **agentic-robotics-mcp** (`McpServer` / `McpTool` / `StdioTransport` / `axum` = **ROBOT-AS-MCP-SERVER**, agents control robot via MCP).
- **agentic-robotics-node** (cdylib + napi: `AgenticNode` / `Publisher` / `Subscriber`).
- **agentic-robotics-benchmarks** (`criterion`).

**(2) COGNITION — `ruvector-robotics`** (deps `ruvector-domain-expansion` + `rvf-runtime` + `rvf-types`) = robot decision layer: **BEHAVIOR TREES** (`BehaviorNode` / `BehaviorStatus` / `DecoratorType`), multi-robot `FormationType`, `CognitiveMode` / `CognitiveState`, `ActionType`, persisted to RVF, using domain-expansion bandit router ⇒ **2ND CONSUMER of domain-expansion** (after `ruvector-postgres`) + consumer of `rvf-runtime` (patience-payoffs).

**SENSORS:** **ruvector-mmwave** (NO deps, `no_std`) = MR60 60GHz mmWave RADAR driver (`Mr60Parser` / `Event`; Seeed MR60BHA presence/vitals), feeds `esp32-mmwave-sensor` example + `ruvector-hailo-cluster` mmwave-bridge (B8).

**EDGE-ML:** **ruvector-tiny-dancer-core** (deps `redb` + `rusqlite` + `simsimd` + `ndarray`) = tiny-model edge inference/serving core: `FastGRNN` (Microsoft EdgeML gated RNN), `QuantizationMode` / `ModelType`, `CircuitBreaker` / `CircuitState` (resilience), `AdminServer` / `Config` / `State`, `BatchIterator`, `Candidate` ranking = the "Tiny Dancer neural routing core."

**PATTERN:** robotics mirrors the agent split (transport-middleware vs cognition) = (agentic-robotics middleware) vs (ruvector-robotics cognition), like (rvAgent runtime) vs (ruvector substrate). **T11 (NEW THESIS): MCP IS THE UNIVERSAL CONTROL SEAM** — every subsystem exposes itself as an MCP server: `mcp-gate` (coherence gate), `mcp-brain` (shared brain), `agentic-robotics-mcp` (robot), `rvagent-mcp` + ruflo (agents). One uniform agent-facing interface across the whole stack.

---

## ANN-index / quantization kernel family (`codewalk-ann-index-quant-family`, conf 0.50) — B11

**CODE-TRUTH B11** (ANN-index/quantization compute kernels, **7 base crates**). **HONEST tier, real algorithms, no traps.**

- **ruvector-diskann** (deps `memmap2` + `simsimd` + `bytemuck`) = real DiskANN: `VamanaGraph` + `ProductQuantizer` + memory-mapped `FlatVectors` + `GpuBackend` / `GpuDistanceContext` + `VisitedSet`; disk-resident ANN for >RAM datasets.
- **ruvector-rabitq** (deps `rand`) = RaBitQ binary quantization: `RabitqIndex` / `RabitqPlusIndex` / `RabitqAsymIndex`, `BinaryCode`, `RandomRotation` / `Kind`, `CpuKernel` / `KernelCaps` (SIMD), `cos_lut`, `encode_query_packed`; the **32× compressor.**
- **ruvector-hyperbolic-hnsw** (deps `nalgebra` + `ndarray`) = HNSW in hyperbolic/Poincaré space: `HyperbolicHnsw`, `PoincareConfig`, `DualSpaceIndex` (Euclidean + hyperbolic), `CurvatureRegistry`, `TangentCache` (`build_tangent_cache`), `HyperbolicShard` / `ShardStrategy`, `HierarchyMetrics`; hierarchical-data ANN.
- **ruvector-dither** (NO deps) = dithered quantization: `PiDither` / `GoldenRatioDither` / `ChannelDither`, `DitherSource` trait, `quantize_dithered(x,bits,eps,source)` / `quantize_to_code` / `quantize_batch`, `anti_resonance`; decorrelates quant error.
- **ruvector-sparsifier** (deps `serde` + `rayon`) = **SPECTRAL GRAPH SPARSIFICATION**: `SpectralSampler`, `EffectiveResistanceEstimator`, `SpectralAuditor`, `AdaptiveGeoSpar`, `Backbone`, `EdgeImportance`, `LocalImportanceScorer`, `SparseGraph`, `do_local_rebuild`; **CONSUMED BY `ruvector-consciousness` (B9)** = patience-payoff.
- **ruvector-cnn** (deps `nalgebra` + `image`) = quantization-aware CNN for image embeddings: `AvgPool2d`, `Activation` / `ActivationType`, `BackboneType`, `TripletDistance`, `QuantizationMode` / `Scheme` / `Type` (+ dither `anti_resonance`), `AugmentationConfig`, `NodeType` / `NodeParams` (compute-graph repr); **backs medical-imaging examples** (dragnes / HAM10000 skin cancer).
- **micro-hnsw-wasm** (NO deps) = minimal pure-Rust HNSW for wasm.

**T9 HOLDS:** pure compute kernels, almost no governance seam (only `SpectralAuditor` in sparsifier). Bridge siblings present (`cnn-wasm` / `diskann-node` / `hyperbolic-hnsw-wasm` / `rabitq-wasm` / `sparsifier-wasm`) = T4 napi/wasm exports — to verify in a dedicated bridge sweep. **CONSUMERS:** sparsifier → consciousness; rabitq / diskann / hyperbolic-hnsw = pluggable index backends for core/rvf; cnn → vision examples; dither → cnn/quant.

---

## Bridge sweep — JS/TS distribution surface (`codewalk-bridge-sweep`, conf 0.50) — B16

**CODE-TRUTH B16** (bridge sweep, **46 `-wasm` / `-node` crates**). ALL confirmed cdylib (wasm) or cdylib + napi (node) = the npm `@ruvector/*` build artifacts; **T4** (format/trait bridging) at scale. **THREE classes:**

1. **THIN 1:1 bindings** (logic in already-walked base): `rabitq-wasm`, `solver-node`/`wasm`, `gnn-node`/`wasm`, `diskann-node`, `verified-wasm`, `sparse-inference-wasm`, `cnn-wasm`, `acorn-wasm`, `consciousness-wasm`, `fpga-transformer-wasm`, `graph-condense-wasm`, `decompiler-wasm`, `temporal-tensor-wasm` (0 pubs), `mincut-brain-node` (0), `mincut-gated-transformer-wasm`, `rabitq-wasm`, `router-wasm`, `sparsifier-wasm`, `tiny-dancer-node`/`wasm`, `ruqu-wasm`, `micro-hnsw-wasm` (self-contained), `ruvector-node` (napi core), `ruvector-router-ffi` (napi router-core).
2. **RICH-API bindings** (large JS surface, logic still in base): `ruvector-attention` has THREE bridges `attention-node` (172 pubs) / `attention-wasm` (62) / `attention-unified-wasm` (103); `ruvector-wasm` (208 = the WASM core build, **DISTINCT** from `ruvector-node` the napi core build); `delta-wasm` (109 wraps delta-core); `graph-wasm` (67 wraps core); `graph-transformer-node` (72) / `wasm` (74); `mincut-node` (50) / `mincut-wasm` (46); `math-wasm` (50); `hyperbolic-hnsw-wasm` (50); `nervous-system-wasm` (89); `neural-trader-wasm` (92); `domain-expansion-wasm` (43 wraps rvf).
3. **STANDALONE WASM-ONLY** (no Rust base crate, genuine wasm-native impls): `ruvllm-wasm` (419 pubs = **wasm-native LLM runtime** since candle does not target wasm), `ruvector-economy-wasm` (84 = agent-economy graph modeling), `ruvector-learning-wasm` (104 = RL/learning bundle), `ruvector-exotic-wasm` (141 = exotic algos bundle), `ruvector-dag-wasm` (13).

**NET:** bridges = the JS/TS distribution surface; the `@ruvector/core` native = `ruvector-node` (napi), `@ruvector/core` wasm = `ruvector-wasm`, `@ruvector/rvf-wasm` = `rvf-wasm` crate (B6). **All crates/ now walked (220/314); only examples/ remain.**

---

## Open items (method-notes flagged for re-exploration)

These two concepts are explicit **method-notes** (status: `open`, type: `method-note`, conf **0.60**) recorded by the walk as areas that needed re-exploration. Both were subsequently **RESOLVED** at the algorithm level; the resolved findings are reproduced below. They remain listed here as the walk's open-item ledger.

### Open item — re-explore B17f exo research (`todo-reexplore-b17f-exo-research`, conf 0.60)

**RESOLVED** (B17f re-explore, algorithm-level): the exo-ai-2025/research prototypes are **NEXT-GEN PRIMITIVES INCUBATING** (not merely standalone), **2 are CONNECTED:**

1. **11-conscious-language-interface** = a "Consciousness-Aware Router" that **EXTENDS ruvLLM's FastGRNN router with consciousness metrics (Phi)** to "make routing decisions based on the current conscious state"; types `CapabilityAutoTuner` / `AdaptiveLRController` / `CoherenceMetric` / `BridgeConfig` (spike-embedding bridge) = a Phi/coherence-GATED ROUTER that auto-tunes capabilities. **HIGHLY RELEVANT** to `interchangeable-parts-runtime-hotswap` + `domain-expansion`: it is the conceptual **NEXT STEP for the runtime selector** — route/hot-swap by consciousness/coherence state, not just bandit regret.
2. **06-federated-collective-phi** = distributed **COLLECTIVE-CONSCIOUSNESS MEASUREMENT** algorithm: `DistributedPhiCalculator` + `ConsensusCoordinator` + `CriticalCouplingCalculator` + `qualia_distance` + `is_collective_consciousness_emergent` + `ConsciousnessPhase` / `State` = the "is the swarm coherent/emergent" metric for a multi-agent collective (ties to `exo-federation` + `mcp-brain` collective).
3. **01-neuromorphic-spiking** = bit-parallel SIMD spike net + billion-neuron IIT-Phi (`BitParallelSpikeNetwork` / `PolychronousGroup` / `ConsciousnessEngine`); **CAVEAT (trust-code):** its `//!` claims "13.78 quadrillion spikes/second" + "Nobel-level breakthroughs" = **UNVERIFIED PROSE/marketing** (code is a real bit-parallel SIMD spike net; throughput number not proven).

**NET:** incubation arm = future promotions into `ruvector-nervous-system` / `ruvllm-router` / `domain-expansion`. Most notable for the meta plan: the **Phi-aware router** (conscious-language-interface) as a candidate evolution of the hot-swap selection criterion. Still standalone crates (zero internal deps) = research staging, **adopt-when-promoted.**

### Open item — re-explore B17g sevensense (`todo-reexplore-b17g-sevensense`, conf 0.60)

**RESOLVED** (B17g re-explore): 7sense (vibecast-7sense) = a **"Bioacoustic Intelligence Platform"** that transforms **BIRD CALLS** into searchable embedding space using **Perch 2.0** (Google bird-song NN) + HNSW, for biodiversity/conservation/species-ID (**329 tests, 85% coverage** = a real mature product; DDD, Qdrant-backed).

**WHY IT'S IN THE REPO / THE CONNECTION (code-verified):** it reaches RuVector at **NEITHER compile NOR runtime** (zero `pi.ruv`/brain/mcp/rvf/cognitum/ruvector refs in source) — it is a **CO-LOCATED REFERENCE PRODUCT**: the applied/commercial instance of the exact pattern RuVector embodies (audio → embeddings → vector-search → discovery), built standalone on Qdrant + Perch2.0. **Connection = THEMATIC + a FUTURE MIGRATION TARGET, not code:** migrate Qdrant → ruvector index-zoo, Perch2.0 → ruvllm/onnx-embeddings, its own GNN → `ruvector-gnn`, Qdrant-search → rvf. It is the **"what you build ON the foundation" blueprint** — aligns with user's "RuVector = foundation we add to." Root README references it as a showcase. The "7 senses" ≈ its 7 functional bounded contexts (audio / embedding / vector / analysis / learning / interpretation / api). **NOT part of the agentic substrate; it's a consumer-app exemplar / adoption candidate.** *(Also surfaced: an `examples/meta-cognition-spiking-neural-network` dir referencing 7sense — separate example, note for completeness.)*

---

## Cross-references

- [`05-ruvector-substrate.md`](./05-ruvector-substrate.md) — the RuVector substrate / unifying-abstraction tiers (RVF, `ruvector-core`, the cognitum hardware seed, sona, rvAgent/ruflo) that this codewalk's examples and stacks all compose. **Most-related sibling.** This document's tier walk repeatedly back-references substrate tiers B4 (`ruvector-verified` Lean proofs), B6 (RVF + adapters), B8 (cognitum gate), B9 (cognition/consciousness), and the T-series theses (T1 gated/attested compute, T4 wasm/napi bridges, T11 MCP-as-universal-seam, T13 boundary-first).
- [`01-meta-control-plane.md`](./01-meta-control-plane.md) — the meta workspace / work-order / governed-continuity-ledger plane; the **S1 input** noted in B17h (`ruvector-verified` + `AgentContract` = formally-verified agent contracts = candidate substrate for the meta work-order envelope).
- [`07-frontdoor-integration.md`](./07-frontdoor-integration.md) — the front-door / ruvocal / prompt-hub integration surface (`frontdoor-mapping-ruvocal-prompthub` links to B17h).
- [`08-gaps-seams-merge.md`](./08-gaps-seams-merge.md) — the gaps/seams analysis, including the `gap-missing-integration-contract` linked from B17h and the doc-vs-code contradictions flagged throughout this walk (ruvector-dag, ruvector-coherence, prime-radiant, router-core).
