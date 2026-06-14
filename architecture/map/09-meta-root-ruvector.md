# 09 — Meta-root Ruvector docs: the authoritative crate-walk

This document folds the four **meta-root** Ruvector planning docs (`~/Desktop/meta/RUVECTOR-*.md`)
into the architecture map. Where [`05-ruvector-substrate.md`](05-ruvector-substrate.md) and
[`06-cognitive-codewalk.md`](06-cognitive-codewalk.md) render the ICM `system-architecture` memoir
(stored prose, flat 0.5 confidence), these four files are the **primary research artifacts the memoir
was distilled from** — the per-batch runbook, the 314-crate coverage ledger, the multi-pass research
log, and the locked S1 meta-mapping. They are **authoritative over ICM prose** for crate counts, the
proven dep graph, the RVF-wiring verdict, the wasm-vs-napi path, cognitum, the witness tiers, and the
doc-vs-code traps. They obey the same doctrine the map does — **code is truth; docs (including these)
are untrusted prose** — so the contradictions they themselves caught (and the few that survive between
them) are flagged below rather than blindly trusted.

---

## RUVECTOR-RUNBOOK.md — the per-batch narrative + the cross-cutting theses

`RUVECTOR-RUNBOOK.md` is the **single source of narrative truth** for the exhaustive crate walk
(survives context resets). It carries the hard method rules, the per-batch log (B0–B17j), the
agentic-pipeline synthesis, and — most valuably for the map — a numbered set of **cross-cutting theses
(T1–T15)** that generalize what the walk found.

**Method (hard rules, verbatim).** (1) **CODE-TRUTH ONLY** — untrusted: repo `.md`, Cargo
`description`, `//!`/`///` doc-comments, ADR prose, **and the knowledge-export JSON** (v2.0 narrative,
"claims 91 crates vs real 314"); trust only real `[dependencies]` edges, real `pub` type/trait/fn
signatures, struct fields, tests; when prose ≠ code, **code wins + FLAG it**. (2) **Read crates
DIRECTLY** (Bash/Read), **no subagents** in RuVector/ruflo/envctl (forge-loop/weave-relay hijack
hazard). (3) Extractor = `~/Desktop/meta/.rvwalk.py`. **Coverage: 314 / 314 — STRICT COMPLETE.**

**The theses that EXTEND the ICM map** (the map renders the conclusions; the runbook gives them IDs and
ranks them):

- **T1 — Two models, one stack.** Data model = coherence-aware hypergraph (nodes=vectors,
  edges=graph, weights=attention, boundaries=mincut, persistence=RVF). Control model =
  **governed/gated/attested compute** (coherence-gate + policy-gate + Lean-proof + witness + budget
  seam). *"This is the real unifying signature, not vectors."* The map states T1; the runbook is its
  canonical statement.
- **T4 — Format is the integration substrate.** Native (`rvf-runtime`/napi) and wasm (`rvf-wasm`) are
  **sibling backends bridged by the `.rvf` format (`rvf-types`) + `rvf-crypto`**, not by recompiling
  runtime→wasm. `rvf-types` is the #1 dep hub (26 dependents). This is the precise mechanism behind the
  map/05 §8.3–8.4 wiring discussion.
- **T5 — Multiple witness schemes (one pattern).** RVF = SHAKE-256/73B (`rvf-crypto`); RVM =
  FNV-1a/64B (`rvm-witness`); ruvix = Merkle-witness (`ruvix-proof`) + attested boot (`ruvix-boot`).
  **Different tiers, same tamper-evident-audit pattern** — the runbook names a *third* witness scheme
  (ruvix Merkle) the ICM map's two-scheme framing omits. (See *Corrections* below.)
- **T7 — Patience rule.** A crate that looks orphaned has its Rust-native consumer further along; first
  proof = `ruvix-sched` consumes `ruvector-coherence` (a real kernel→substrate edge).
- **T11 — MCP is the universal control seam.** `mcp-gate`/`mcp-brain`/`agentic-robotics-mcp`/
  `rvagent-mcp` + ruflo all expose a uniform MCP server interface.
- **T12 — A vector-index/DB ZOO behind common traits** — *"~a dozen interchangeable index/store impls
  — HNSW, Vamana(`diskann`), IVF(`rairs`), ACORN(`acorn`), RaBitQ, hyperbolic, micro-HNSW,
  `delta-index`, `router-core`, `rulake`, `tiny-dancer-core`, `rvlite`, `rvf-index`, `core` — behind
  `VectorIndex`/`AnnIndex`/`FilteredIndex` traits … For meta adoption: pick by trait, not by crate.
  (`router-core` is a DB, not a router — trap.)"*
- **T2/T3/T14/T15** restate the map's "TS=legacy, Rust=truth", "ruflo binds via the `ruvector` npm
  facade", "examples are agentic ROLES", and "the agentic role concentrates in the INTEGRATION
  examples" theses with code anchors.

**Doc-contradictions caught (code vs prose)** — the runbook's consolidated trap list (authoritative;
these are the source of map/06's scattered trap notes and directly answer Q6.4):

| Crate | Doc/blurb says | Code proves |
|---|---|---|
| `ruvector-dag` | "DAG for query-plan optimization" | **QuDAG post-quantum governance/consensus** (KEM/DSA, staking, proposals, self-healing) |
| `ruvector-coherence` | "sheaf-Laplacian engine" | **lightweight HNSW health/spectral monitor** (deps: only serde) |
| `ruvector-fpga-transformer` | "FPGA backend" | **coherence/policy-gated accelerator engine** (ed25519, daemon) |
| `rvf-crypto` | export claims "ML-DSA-65 post-quantum signatures" | **`ed25519-dalek` + `sha3` ONLY — no ML-DSA** (PQ lives in `ruvector-dag`/QuDAG) |
| `thermorust` | (name-trap, sits next to `ruos-thermal`) | **Ising/Hopfield spin-glass energy-model engine** (statistical physics) |
| `ruvector-crv` | (trap) "CRV" | **Controlled Remote Viewing** protocol → embedding-consensus; `AOLDetection` = **hallucination/bias detection** |
| `ruvector-domain-expansion` | (trap) "domain expansion" | **contextual-bandit / Thompson-sampling task router** (ArmId/BetaParams/regret), RVF-persisted |
| `ruQu` vs `ruqu-core` | (name-collision) | `ruQu` = **QEC MWPM decoder for the cognitum gate**; `ruqu-*` = a **real quantum simulator** (gates/VQE/QAOA/Grover) |
| `ruvector-router-core` | (name-trap) "router" | **a full embeddable vector DB** (HNSW + quant + redb) |
| `prime-radiant` | export says "visualization/dashboard component" | **a second GPU-accelerated (`wgpu`) convergence runtime** composing the whole substrate + an agentic apply/adjust loop |

**The agentic pipeline (B17 synthesis, end-to-end, proven in code):** DATA FEEDERS (`data-*`:
finance/SEC-EDGAR/OpenAlex/sensors → embeddings) → DISCOVERY AGENTS (boundary family = early-warning
perception; consciousness family = Φ/emergence) → AGGREGATION/LEARNING (`train-discoveries` sublinear
ETL; `mcp-brain` collective) → ORCHESTRATION (`a2a-swarm` rvAgent/A2A; MCP seams;
`verified-applications` = formally-verified `AgentContract`s) → EDGE FLEET (`ruvector-edge` P2P+ZK,
`edge-net` wasm, `esp32` tiny-agents, `ios` assistant, `cloudrun` GPU) — all governed by the coherence
gate (cognitum) and persisted/witnessed via RVF. `sevensense`/`exo-research` are the satellite product
+ incubation arm (off-substrate).

---

## RUVECTOR-CRATE-LEDGER.md — the 314-crate coverage ground truth

`RUVECTOR-CRATE-LEDGER.md` is the **durable per-crate checklist**: `[x]` walked / `[~]` surface /
`[ ]` untouched, grouped by cluster, each row carrying the crate's real Cargo description, its
on-disk path, and the batch that walked it. **It is the authoritative crate inventory** — every
"~314 crates" claim in the ICM map traces here.

**Authoritative count:** *"Total: 314 crates across 196 clusters."* Every row is `[x]` —
**0 `[~]` left**. This is the hard number that corrects the knowledge-export's stale 91 and the
pass-1 "~216 crates" framing (216 = `crates/` only; 314 = `crates/` 216 + `examples/` 93 + roots).

**The major clusters it enumerates (with exact crate counts), all fully walked:**

- `crates/ruvix` — **28 crates** (the bare-metal microkernel OS; `ruvix-nucleus`/`-cap`/`-sched`/
  `-vecgraph`/`-proof`/`-boot`/`-bcm2711` etc.; `ruvix-sched` → `ruvector-coherence` edge confirmed).
- `crates/rvf` — **26 crates** (`rvf-types`→`-wire`→`-manifest`→`-index`→`-quant`→`-crypto`→`-runtime`;
  `rvf-node` napi = `@ruvector/rvf`; `rvf-wasm`; `rvf-launch` QEMU; 6 `rvf-adapters/*`).
- `crates/rvm` — **16 crates** (coherence-native microhypervisor, ADR-132..140; `rvm-witness`
  64-byte/FNV-1a).
- `crates/rvAgent` — **10 crates** (Rust-native coding-agent framework; `rvagent-core/-tools/
  -middleware/-subagents/-mcp/-a2a/-acp/-cli/-wasm/-backends`).
- `examples/exo-ai-2025` — **21 crates** (9 `exo-*` library crates B17e + 11 research apps B17f +
  workspace).
- `examples/vibecast-7sense` — **12 crates** (`sevensense-*`, independent bioacoustic product).
- `examples/data` — **5**, `examples/ruvLLM` — **3**, plus ~70 single-crate example clusters
  (each boundary/consciousness/edge domain app).

**Per-crate Cargo descriptions the ledger preserves (and the map should treat as code-verified
labels, not theses):** e.g. `ruvector-postgres` = *"pgvector drop-in … 230+ SQL functions"*;
`ruvector-mincut` = *"World's first subpolynomial dynamic min-cut"*; `rvf-crypto` = *"SHA-3 hashing
and Ed25519 signing"* (note: the Cargo description **itself** says ed25519+sha3, corroborating the
code-walk over the knowledge-export's ML-DSA claim); `ruvector-verified` = *"proof-carrying vector
operations … lean-agentic dependent types"*; `prime-radiant`'s Cargo blurb says *"sheaf Laplacian
mathematics … hallucination detection"* (the blurb the code-walk overrules — see B15 trap).

**Two `hnsw_rs` rows are flagged EXTERNAL** (vendored patches of upstream, not ruvector crates) and
the `Cargo.toml`/`tests`/`docs/musica` rows are correctly classified as non-crate or example —
useful precision the ICM map summarizes only as "~314 manifests".

---

## RUVECTOR-RESEARCH.md — the multi-pass log that produced the RVF-wiring verdict

`RUVECTOR-RESEARCH.md` is the **chronological pass log** (PASS 1 → PASS 6b, all 2026-06-09). It is the
primary evidence trail behind map/05 §8.3–8.4 (the most-contested chain in the cluster) and behind the
hardware/entry context. It is authoritative for the **wiring verdict's final shape** and the
**wasm-vs-napi resolution**.

**PASS 1 — Shape.** RuVector = *"massive distributed cognitive vector-DB + AGI runtime: ~216 Rust
crates + ~59 npm pkgs"*; ruflo = *"claude-flow v3 … `claude-flow@3.10.x`"*, the TS host that surfaces
RuVector to Claude Code; **direction is one-way — ruflo CONSUMES RuVector; RuVector has no ruflo dep.**

**PASS 2 — RVF internals.** The `.rvf` is a segment-typed container with a two-level manifest (Level-0
root = fixed 4096 B at EOF, magic `RVM0`, **<5 ms boot**; Level-1 = TLV directory). **KEY INSIGHT:**
a `.rvf` **embeds real executables** (Linux bzImage / Hermit / Asterinas in `rvf-kernel`; a ~5.5 KB
"Cognitum tile runtime" wasm microkernel in `rvf-wasm`; eBPF XDP in `rvf-ebpf`) → it is a
self-bootstrapping, vector-native compute artifact, not mere storage. Witness = `WitnessEntry{prev_hash,
action_hash=SHAKE-256(action), timestamp_ns, type}`, **73 B, chained**.

**PASS 3 → PASS 6 → PASS 6 CORRECTION → PASS 6b — the wiring verdict, in order:**

- **PASS 3 (tentative):** the napi Rust path **ships** (`@ruvector/rvf` → `@ruvector/rvf-node` wraps
  `rvf-runtime` 0.2.0; prebuilt `rvf-node.linux-x64-gnu.node` present); but ruflo's `RvfBackend`
  appears to execute via pure-TS `HnswLite` ⇒ "napi loaded-but-idle, TS active." Flags the **ADR-125**
  contradiction (a note suggesting *inline HnswLite, phase OUT native in favor of TS* — opposite of
  the stated TS→Rust pattern).
- **PASS 6 (proven, scoped to `@claude-flow/memory`):** confirms `RvfBackend` opens/health-reports/
  closes the napi handle but **never calls `nativeDb.*`** for any op; every op runs over JS `Map` +
  `HnswLite` (`bruteForceSearch` when `hnswIndex` is null). The dedicated Rust adapter crate
  `rvf-adapter-claude-flow` is **complete-but-orphaned** (9 passing tests, plain `rlib`, imported by
  nothing). ADR-125 *resolved* — the code matches it; ruflo deliberately runs TS for portability.
- **PASS 6 CORRECTION (same day, explicit):** *"the verdict above was scoped TOO NARROW … 'Rust RVF
  isn't wired into ruflo' is **wrong**."* The `RvfBackend`-specific facts all stand, but the
  generalization missed the real operational Rust consumers.
- **PASS 6b — the FINAL verdict (four paths, two bridges):** a full operational sweep found the
  consumers PASS 6 skipped. The authoritative table:

  | Path | Resolves to | Rust? | Consumers |
  |---|---|---|---|
  | `@claude-flow/memory` `RvfBackend` | TS `Map`+`HnswLite` (napi handle dead) | no (TS) | legacy memory KV |
  | `@claude-flow/memory` `agentdb-backend` | `agentdb` npm `HNSWIndex` | sep. pkg | hybrid memory |
  | `cli/src/ruvector/vector-db.ts` → `ruvector` npm facade | `@ruvector/core`(native) → `@ruvector/rvf`=`rvf-node`→`rvf-runtime` → `@ruvector/rvf-wasm`=`rvf-wasm` | **yes (native OR wasm)** | **6 intelligence plugins** + graph-analyzer + benchmark |
  | `plugins/ruflo-core/scripts/witness/lib.mjs` `loadRvfNode` | `@ruvector/rvf-node`→`rvf-runtime` → JSONL fallback | **yes (napi)** | **witness / audit chain** |

  **The facade `npm/packages/ruvector/src/index.ts` `require`s `@ruvector/rvf` and defaults
  `implementationType='wasm'`** (exposes `isWasm()`, persists `ruvector-<pid>.rvf`); ruflo
  `package.json` deps include `ruvector ^0.2.27` + `@ruvector/rvf-wasm 0.1.5`. The two bridges:
  **native/napi** = `@ruvector/rvf`←`rvf-node`←`rvf-runtime` (full std VM); **wasm** =
  `@ruvector/rvf-wasm`←`rvf-wasm`, which depends on **only `rvf-types`+`rvf-crypto`, NOT `rvf-runtime`**
  (no_std, `dlmalloc`). So "rvf-runtime feeds the wasm bridge" is **true at the data/format level,
  false at the code-dependency level** — they are siblings over `rvf-types` (= why it is the #1 hub).

- **CORRECTED VERDICT (verbatim):** *"the production Rust RVF — `rvf-runtime` (native/napi) **and**
  `rvf-wasm` (wasm) — **IS operationally wired into ruflo**, through the `ruvector` intelligence facade
  (6 plugins) and the ruflo-core witness subsystem. The lone exception is the legacy
  `@claude-flow/memory` KV backend, whose napi handle is dead. 'Is production RVF wired into ruflo?' =
  **YES.**"*

**Hardware/entry context (PASS-1 + cognitum-seed section):** the **Cognitum seed** is *"physical Pi
Zero (64GB)"* — note this is the early/looser framing the later board-class question disputes; the
seed needs **no secret key** so the **envctl secret-key USB is almost certainly a different device —
do not conflate**; the seed exposes 3 interfaces with no unlock key (USB mass-storage `COGNITUM`
FAT32 / USB-net `169.254.42.1` / mDNS `cognitum.local`), SSH `genesis@169.254.42.1` pw `cognitum`,
MCP at `/mcp`, RVF store `/var/lib/cognitum/rvf-store/`.

---

## RUVECTOR-META-MAPPING-S1.md — the locked "adopt-don't-rebuild" decision

`RUVECTOR-META-MAPPING-S1.md` is the **post-walk synthesis** that turns the crate map into a meta-stack
decision. **Status: MAPPING + RECOMMENDATION — RuVector/ruflo NOT yet adopted** (but its core
decisions were subsequently user-confirmed / S2-LOCKED, per map/05 §2.2 and map/02).

**The decisive insight (verbatim):** *"the Ark Handoff Ledger … is, in large part, a **from-scratch
re-implementation of capabilities RuVector already ships production-grade**."* Per T2 (prefer the Rust
crate) + the no-rebuild instinct, S1 **flips the plan: don't build the 12 Ark crates cold — map each
need onto an existing crate + a thin glue layer.** Keep the Ark *contract* (state-precedence, drift
sentinels, leases, evidence-backed completion, MCP) as the spec; its *engine* mostly already exists.

**The Ark-need → RuVector-crate mapping (verdict legend: ADOPT / GLUE / BUILD / REUSE-meta):**

| Ark need | RuVector equivalent (code-walked) | Verdict |
|---|---|---|
| `handoff-ledger` | RVF (`rvf-runtime` append-only segments + `rvf-crypto` WitnessChain SHAKE-256); or `ruvector-temporal-tensor`; sqlite fallback | ADOPT (RVF) / GLUE |
| `handoff-drift` | `ruvector-perception` (`BoundaryPredictor`, `DeltaWitness`) + `ruvector-coherence` (`HnswHealthMonitor`) + blake3 intent-locks | ADOPT + GLUE |
| `handoff-policy` | `cognitum-gate-tilezero` (`decide→Permit/Deny/Defer`) + `rvf-runtime` governance + `neural-trader-coherence::CoherenceGate` | ADOPT |
| lease engine | **weave `weave_lease_*` — ALREADY in our stack** + `rvm-cap`/`ruvix-cap` | REUSE-meta |
| evidence / completion | `ruvector-verified` (Lean `ProofAttestation`) + `verified-applications::AgentContract` | ADOPT (*"the killer feature"*) |
| `handoff-mcp` | `mcp-gate`/`mcp-brain`/`rvagent-mcp` pattern (T11) | ADOPT pattern |
| `handoff-git` / `handoff-index` | meta `meta worktree` + GitKB (`.kb`) + `ruvector-graph` | REUSE-meta |
| task DAG / `hf plan` | `ruvector-dag` (QuDAG governance DAG, **not** query-plan) | ADOPT / BUILD-thin |
| routing / next-task | `ruvector-domain-expansion` (contextual-bandit/Thompson, ≥8 consumers) | ADOPT |
| agent runtime / swarm | `rvAgent` (deployed in `a2a-swarm`; mirrors Ark sub-agent/swarm 1:1) | ADOPT |
| `hf` CLI + daemon + test | thin orchestration over the above | BUILD-thin |

**Net (verbatim):** *"of the 12 Ark crates, ~8 have a production-grade RuVector or meta equivalent;
only the thin `hf` CLI + daemon + test-runner glue is genuinely new."*

**Locked decisions (the parts that hardened past recommendation):**

- **Ledger tech (CONFIRMED, §5c):** **v1 ledger = `rusqlite` (SQLite/WAL) + `rvf-crypto::WitnessChain`**
  (a STANDALONE crate usable without `rvf-runtime`/napi). **Full `rvf-runtime` (RVF vector-native
  ledger) = the scheduled V2 upgrade, next-priority.** `rvf-node` is a **napi Node binding, NOT a DB**
  — a Rust `hf` CLI uses `rvf-runtime`/`rusqlite` directly, never `rvf-node`; `rvf-node` is reserved as
  the **TS read-bridge** (RuVocal/ruflo) only.
- **Front door (CODE-FOUND, §5b/§5d):** RuVector's canonical intake is **conversational chat →
  `mcp-bridge` → MCP servers** (T11). **RuVocal** (`ui/ruvocal`) = a fork of HuggingFace Chat UI on
  **pgvector = `ruvector-postgres`** + `mcp-bridge`; **prompt_hub** (Rust/axum) = `/vibe` →
  `SwarmBundle` → `dispatch`. **Roles:** prompt_hub = single canonical intake; RuVocal = its UI;
  CLI/n8n/meta = thin shims (Plan C). **Key seam to build:** `SwarmBundle → handoff.task.v1` + dispatch
  over MCP.
- **Naming (§5b):** drop "Ark"/"V2" entirely — it is the **`handoff` / `.handoff`** kernel.
- **Law (§5b):** **ADOPT what is built, then add to it. RuVector becomes the FOUNDATION** the meta
  stack adds to (not a peer).

**One-line synthesis (verbatim):** *"The meta autonomy stack doesn't need 12 new crates — it needs the
Ark contract (state-precedence + drift + provable completion) wired onto RuVector's existing engines:
RVF (ledger/witness), weave (leases), `ruvector-verified`+`AgentContract` (provable work-order),
`domain-expansion` (routing), `cognitum-gate` (policy), and `rvAgent` (runtime) — exposed through the
universal MCP seam."*

---

## Corrections to the ICM map

Where these meta-root docs refine, correct, or out-resolve [`05-ruvector-substrate.md`](05-ruvector-substrate.md)
and [`06-cognitive-codewalk.md`](06-cognitive-codewalk.md):

- **Crate-count framing.** map/05 §1.3 carries the pass-1 "~216 Rust crates + 59 npm pkgs"; the
  ledger's authoritative number is **314 crates / 196 clusters** (216 `crates/` + 93 `examples/` +
  roots). The map already cites 314 in §1.1; §1.3's "~216" should be read as *`crates/`-only*, not the
  estate total. No contradiction — just the precise denominator.
- **The wiring verdict is FINAL at pass-6b, not pass-6.** map/05 §8.4 renders pass-3 → pass-6 →
  "pass-6 correction" and frames pass-6 as "settles pass-3". The research log shows the **pass-6
  conclusion was explicitly recanted the same day** as *"scoped TOO NARROW … wrong"*, and **pass-6b**
  (four paths, two bridges) is the operative verdict: **production Rust RVF IS wired into ruflo**
  (facade + 6 plugins + ruflo-core witness); the `@claude-flow/memory` KV backend is the **sole**
  TS-only exception. A reader of map/05 §8.4 alone could mistake the narrow pass-6 "TS is THE active
  path" line for the final answer — it is not. (map/05's L5.6 in the ledger has this right; the §8.4
  prose should be read with pass-6b as the terminus.)
- **A THIRD witness scheme exists.** map/05 §4.4 + QUESTIONS_LESSONS L5.8 frame **two** witness schemes
  (RVF 73B/SHAKE-256 vs RVM 64B/FNV-1a). The runbook's **T5** names a **third**: ruvix's
  **Merkle-witness** (`ruvix-proof`) + **attested boot witness log** (`ruvix-boot`,
  `WitnessLogEntryType`/`WitnessExportPolicy`). The "two tiers" framing is incomplete — it is
  *at least three* tamper-evident schemes over one pattern (RVF heavy/canonical, RVM light in-hyper,
  ruvix Merkle in-kernel).
- **The default operational path is WASM, not napi.** map/05 §8.4 emphasizes the napi `rvf-runtime`
  path and the TS-vs-Rust contest; the research log (pass-6b) is explicit that the `ruvector` facade
  **defaults `implementationType='wasm'`** (`rvf-wasm`, deps `rvf-types`+`rvf-crypto` only) and that
  napi is the *alternative* backend. The ICM map under-states that the **shipped default** is the wasm
  microkernel path. (Answers Q5.2.)
- **Cognitum board class — the docs themselves disagree, flag preserved.** RESEARCH.md PASS-1 calls the
  seed *"Pi Zero (64GB)"*; its cognitum-seed section quotes the guide as *"Cortex-A53 / 512MB"*; the
  runbook T6 says *"bcm2711 = Pi"*; the 2026-06-13 SSH probe returned `armv7l`. **These do not
  reconcile** — carried as an open hardware question (Q5.4), unchanged by these docs.
- **prime-radiant / dag / coherence / router-core traps are now CANONICAL.** map/06 leaves Q6.4 open
  ("confirm in the canonical source"); the runbook's consolidated trap table **is** that canonical
  source-walk: each is a code-verified override of its blurb (dag=QuDAG governance, coherence=HNSW
  health monitor, prime-radiant=GPU convergence runtime, router-core=vector DB). Q6.4 is answered.

---

## Cross-references

- [`../map/05-ruvector-substrate.md`](05-ruvector-substrate.md) — the ICM-rendered substrate map this
  document extends/corrects (crate graph, RVF internals, witness, ruvix, rvm, rvAgent, S1 mapping).
- [`../map/06-cognitive-codewalk.md`](06-cognitive-codewalk.md) — the ICM-rendered B-series codewalk
  (examples-as-agentic-roles, cognition/consciousness tier, cognitum hardware gate, doc-vs-code traps).
- [`../map/00-overview.md`](00-overview.md) — the one-screen estate model (RuVector = the COMPUTE
  SUBSTRATE plane; `handoff/ledger → rvf-crypto` = the one live meta↔RuVector code edge).
- [`../QUESTIONS_LESSONS.md`](../QUESTIONS_LESSONS.md) — the reconciliation ledger these docs answer
  Q5.1/Q5.2/Q5.3/Q5.5/Q6.1/Q6.4 against (Section 2.5/2.6).
