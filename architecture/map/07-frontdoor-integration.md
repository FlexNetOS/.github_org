# 07 — The Front Door & External Integration Glue

This map renders the **intake/intent layer** of the meta stack — `prompt_hub` as the canonical "front door" and `RuVocal` (the RuVector chat UI) as its primary human face — together with the **cross-cutting and external glue** that surrounds it: `n8n` (external workflow glue), `mcp-brain-server` (the pi.ruv collective-brain convergence crate), `rtk` (token optimization), `icm` (persistent memory), and the `yazelix` terminal/workstation entry. The product vision is a non-technical "vibe coder" who speaks fuzzy intent into RuVocal, which `prompt_hub` mints into versioned, guard-railed work-orders that a RuVector agent swarm executes as a **single-person agentic conglomerate, multi-business**. The central open work is the **RuVocal ↔ prompt_hub seam** — both sides exist, but no transport connects them yet and nothing synthesizes a vibe Intent into a `handoff.task.v1` work-order.

> Confidence note: nearly all concepts in this document carry a memoir confidence of **0.5** (`s1-resolved-frontdoor-ledger-naming` is **0.6**). Per the rendering directive, all material claims below are flagged as **< 0.7 confidence** — treat them as code-walk findings under active construction, not settled fact. The status labels (`verified`, `pass5-proven`, `user-confirmed`, `open`) are the memoir's own labels and are preserved verbatim.

---

## 1. The front door: `prompt_hub`

> Concept: `prompt_hub-front-door` — labels `type:layer, role:intake, status:verified` — **confidence 0.5**

`prompt_hub` is the **INTAKE/INTENT layer** — the literal "front door." It is a **Rust 2024 workspace** at `~/Desktop/meta/prompt_hub`, comprising **3 crates**:

- `prompt-hub` — library
- `prompthub` — CLI
- `prompthub-server` — axum server

It is **libsql-backed**. Its job is to turn fuzzy natural-language intent into **versioned, role-targeted, guard-railed prompt artifacts** *before any agent runs*.

**Key surfaces:**

- `vibe <request>` — NL → deliverable
- `get <role> <intent>` — prompt routing
- `SwarmBundle` + `AgentIdentity` + handoff templates — the bridge to a swarm

It is also the **guardrail / audit point**: versioning, RBAC, injection sanitize, budget/cost, quality-gate.

**STATUS:** the capability exists but is **NOT code-wired as the actual intake yet**; `prompt_hub` itself is **under active construction by its own prompt-loop harness crew**.

### 1.1 Construction-loop reality (from memory dumps)

These operational facts come from the ICM memory topic dumps (not the memoir graph), and qualify the "under active construction" status:

- The **prompt_hub construction loop FINISHED the backlog (2026-06-13)**: all **45 `.handoff` cards done** (was 30/40 at resume). Shipped as **PRs #94–#106, one card per PR**. (`context-prompt_hub`, high)
- **Handoff adoption is COMPLETE** in 2 PRs: **#82 migrated data** (40 `handoff.task.v1` cards + derived packet + capsule + active + history; `_workspace` archived); **#83 copied the full `.handoff` kernel substrate** from `meta/handoff/.handoff` and adapted it to a member repo (`policy.toml` origin `FlexNetOS/prompt_hub`, trunk `main`, prefix `prompt-`). (`decisions-prompt_hub`, critical)
- **Member rules (ADR-0004 §3):** NO local `ledger.db` (member events go to the **FLEET ledger** `meta/.handoff`), no `fleet/` census. (`decisions-prompt_hub`)
- **Required CI checks:** Check / Clippy / Format / Test (ubuntu+macos+windows stable) / Cargo Audit / Cargo Deny. Documentation / Mutants / Coverage are **NOT required**. Windows test jobs are the slow gate. (`context-prompt_hub`)
- Test count: **1085 tests** (up from 724 on 06-09); its prompt-loop harness hit **cycle 80** (later **cycle 83** per `context-prompt_hub`; **cycle 67** added a `local_llm` module per `context-prompt-hub`). (`seam-spec-ruvocal-prompthub-2026-06-11` + memory dumps)

### 1.2 Embedding-backend decision (cross-cutting to prompt_hub)

`prompt-hub` requires **`#![forbid(unsafe_code)]`**, which constrains its embedding/inference runtime. Four runtimes were evaluated (`decisions-prompt-hub`, high):

1. **`ort`** (ONNX Runtime FFI wrapper) — widest model support incl. `bge-m3`, but `ort-sys` is raw unsafe FFI; cannot satisfy `#![forbid(unsafe_code)]`.
2. **`candle`** (pure Rust) — the only truly safe/pure-Rust path at the crate level if only safe `Tensor` APIs are used; model coverage still growing.
3. **`fastembed-rs`** — lightweight `ort` wrapper; depends on unsafe `ort` upstream.
4. **Remote API** — zero local deps, online-only.

**Recommendation:** start with remote API for dev, then **`candle`** as primary embedded engine once target models (`bge-m3`) are supported, keeping `ort` as an optional feature-gated fallback. A later note (`decisions-prompt-hub-embedding-backend`, high) records that **`fastembed-rs` v5.13.4** (2026-04-27, Apache-2.0) is **zero-unsafe / pure safe Rust**, supports ONNX (`ort 2.0.0-rc.12`) and Candle via feature flags, pre-bundles ONNX Runtime binaries (no system C/C++ install), and covers BGE-M3 / MiniLM / Qwen3 / nomic — which partially reopens the safe-Rust path through `fastembed-rs` rather than raw `ort`.

> **QUESTION:** the embedding-backend decision is not fully closed — `decisions-prompt-hub` recommends `candle`, while `decisions-prompt-hub-embedding-backend` later finds `fastembed-rs` is itself zero-unsafe. Which is the adopted backend for `prompt-hub`'s embedded search?

---

## 2. Front-door mapping: RuVocal ↔ prompt_hub

> Concept: `frontdoor-mapping-ruvocal-prompthub` — labels `type:integration, status:user-directed, tag:critical, role:intake` — **confidence 0.5**
> Graph links: `refines → prompt_hub-front-door`, `refines → gap-front-door-ambiguity`, `part_of → s1-ruvector-meta-mapping`

This is the **user-critical (2026-06-09)** front-door mapping: map the RuVector UI front door (**RuVocal**) **WITH** `prompt_hub`. It is **CODE-TRUTH** (walked from source).

### 2.1 What RuVocal is

`RuVocal` lives at `RuVector/ui/ruvocal` (manifest `rvf.manifest`). Self-describing as: *"RuVector AI-Powered Intelligent Assistant with MCP tools, voice, multi-model support; connects to collective intelligence network; **FORK OF HUGGINGFACE CHAT UI** with PostgreSQL + PGVECTOR backend."*

Therefore:

- **RuVocal = forked HuggingFace Chat UI (SvelteKit)** on **PGVECTOR = `ruvector-postgres`** (the walked pgvector drop-in) + MCP tools + voice + `pi.ruv` brain network.
- Its **`mcp-bridge` subpackage** = *"routes AI tool calls to backend services with multi-provider chat proxy"* — i.e. chat-UI → MCP + multi-LLM proxy.

### 2.2 What prompt_hub contributes

`prompt_hub` (`~/Desktop/meta/prompt_hub`; Rust axum) = the **VIBE-CODING INTAKE**: `/vibe` + `/api/` routes. Code evidence:

- `vibe`/`vibe_code` (26 hits)
- `SwarmBundle` (13 hits)
- `dispatch` (5+ hits → **DISPATCH IS NOW BEING BUILT**, which updates the old "SwarmBundle zero outbound wiring" gap)
- `export_yaml`/`markdown`/`jsonl`

`prompt_hub` is for **NON-TECHNICAL vibe coders** to run a **SINGLE-PERSON AGENTIC CONGLOMERATE MULTI-BUSINESS** (still in dev, already enormous, critically needed).

### 2.3 The mapping (closes `gap-front-door-ambiguity`)

```text
vibe coder
  -> RuVocal chat UI            (presentation; pgvector = ruvector-postgres)
  -> mcp-bridge                 (tool-call router + multi-provider proxy)
  -> prompt_hub /vibe           (CANONICAL INTENT INTAKE)
  -> SwarmBundle
  -> handoff.task.v1            (THE WORK-ORDER ENVELOPE = gap#2 meets gap#3 HERE)
  -> dispatch via MCP seam
  -> RuVector agent swarm       (rvAgent / a2a-swarm)
       governed by cognitum-gate, witnessed by RVF, tracked in .handoff ledger
  -> results back to chat
```

**ROLES (verbatim):**

- `prompt_hub` = the **single canonical INTAKE** (intent-minting).
- `RuVocal` = its **primary human UI**.
- Other doors (CLI / n8n / meta) = **thin shims to `prompt_hub`** (this is "Plan C").

**KEY SEAM TO BUILD:** `SwarmBundle → handoff.task.v1` envelope + dispatch over MCP (`mcp-bridge` transport).

**ALREADY-REAL CONNECTION:** RuVocal's vector backend = pgvector = `ruvector-postgres` — the UI is **already on a RuVector crate**.

**PRODUCT VISION:** a non-technical person vibes intent into RuVocal → `prompt_hub` mints work-orders → RuVector agent swarm executes the multi-business conglomerate, **gated / witnessed / ledgered**.

---

## 3. S1 decisions: ledger + naming (front-door resolution)

> Concept: `s1-resolved-frontdoor-ledger-naming` — labels `type:decision, status:user-confirmed, tag:critical, role:planning` — **confidence 0.6**
> Graph links: `refines → s1-ruvector-meta-mapping`, `related_to → gap-front-door-ambiguity`, `related_to → rvf-wiring-pass6-correction`

**S1 DECISIONS (user-confirmed 2026-06-09):**

- **LEDGER #1 APPROVED:** v1 = **`rusqlite` (SQLite/WAL) + `rvf-crypto::WitnessChain`** (standalone, no `napi`) for tamper-evidence.
- **RVF VECTOR-NATIVE LEDGER (full `rvf-runtime`) = V2 UPGRADE**, scheduled as next-priority task when it fits. User rationale: valuable because the **ENTIRE RuVector system is built on the vector database**, so a vector-native handoff ledger aligns with the foundation.
- **`rvf-node`** (napi cdylib Rust→Node addon wrapping `rvf-runtime`) = **TS read-bridge only** (for RuVocal / ruflo), **never** for the Rust `hf` CLI.
- **NAMING:** the target = the **handoff / `.handoff` kernel** at `~/Downloads/tmp/handoff` (**drop Ark/V2**).
- **LAW:** *adopt-what's-built then extend*; **RuVector = the FOUNDATION** the meta stack adds to.
- **FRONT DOOR:** `RuVector/ui/ruvocal` = SvelteKit chat-ui + `mcp-bridge` subpackage ⇒ canonical intake = **chat → mcp-bridge → MCP**.
- **CRITICAL NEXT (user):** map the RuVector UI front door **WITH** `prompt_hub` — `prompt_hub` is the meta-stack intake (still in dev, already enormous, critically needed for non-technical vibe coders to run a single-person agentic conglomerate multi-business). → see §2.

> **LESSON (confirmed decision):** the front-door ledger and naming are resolved — v1 ledger is `rusqlite` + `rvf-crypto::WitnessChain`; the RVF vector-native ledger is the scheduled V2 upgrade; the canonical kernel name is **handoff / `.handoff`** (Ark/V2 dropped); `rvf-node` is a TS read-bridge only. This is the highest-confidence concept in this theme (0.6).

---

## 4. The seam contract: RuVocal ↔ prompt_hub (2026-06-11)

> Concept: `seam-spec-ruvocal-prompthub-2026-06-11` — labels `type:seam-spec, status:open, session:2026-06-11, role:intake, tag:critical` — **confidence 0.5**
> Graph links: `refines → frontdoor-mapping-ruvocal-prompthub`; related: `spike-validated-handoff-seam-ledger`

**STATUS: open** — gap re-confirmed on both sides, contract specified.

**CONTEXT:** the locked front-door decision = `prompt_hub` (canonical intent intake) + RuVocal (primary human UI). **HFTASK-0022 (P1) + HFTASK-0003 (P0)** own the build.

### 4.1 Code findings (2026-06-11)

**RuVocal side** = `RuVector/ui/ruvocal`, package name **`chat-ui` v0.20.0** (HuggingFace Chat-UI fork):

- **Postgres-native NOW:** `src/lib/server/database/postgres.ts` present, **ZERO `MONGODB_URL` refs** in `src` — the fork swapped Mongo → Postgres (pgvector = `ruvector-postgres`); `rvf.manifest.json` at root.
- **`mcp-bridge` subpackage v1.0.0** = `mcp-stdio-kernel.js` (~5KB) + test-harness + Dockerfile/cloudbuild (a **Cloud-Run-able stdio MCP bridge**).
- **RuVocal has ZERO `prompt_hub` references.**

**prompt_hub side** = 3-crate workspace (`prompt-hub` lib / `prompthub` CLI / `prompthub-server` axum), **1085 tests** (up from 724 on 06-09); its prompt-loop harness hit **cycle 80**; repo ahead 3, clean.

Server routes (`server.rs:38-95`):

- `/api/v1/vibe/code` POST → `routes::vibe_code` (`routes.rs:767`) → `hub.vibe_code(request, UserInput, skill_level)` → `{artifacts, summary, confidence}`.
- `/api/v1/swarm/bundle` GET → `generate_bundle` (`routes.rs:484`) folds **STORED PROMPTS by role** into **ad-hoc JSON** — it does **NOT** construct the typed `SwarmBundle`.

The `SwarmBundle` struct (`prompt-hub/src/models.rs:528`):

```rust
SwarmBundle {
    workflow_id: Uuid,
    role_prompts: HashMap<Role, String>,
    handoff_template: String,
    consistency_report: Vec<Conflict>,
    evolution_suggestions: Vec<String>,
}
// no dispatch fields
```

**ZERO MCP server/client code** in all three crates; the only outbound HTTP client = `qdrant.rs` (vector search).

**GAP:** no transport between RuVocal and `prompt_hub`, and **no Intent → envelope synthesis anywhere**.

### 4.2 Seam contract (per ADR-0001 §11 + S1 §5d)

```text
vibe coder -> RuVocal chat -> mcp-bridge (tool router + multi-provider proxy) -> prompt_hub intake
```

`prompt_hub` must:

- **(a) Expose a transport the bridge can call** — *MCP server vs plain HTTP + bridge-translation* is the **OPEN HFTASK-0019 decision**.
- **(b) Synthesize the vibe Intent → `handoff.task.v1` envelope.**

  Vibe `Intent` (`models.rs:547`):

  ```text
  Intent {
    raw_text, domain, role, task_type, complexity, urgency, extracted_entities
  }
  ```

  → `handoff.task.v1` envelope:

  ```text
  handoff.task.v1 {
    id, title, status, priority, objective, path_scope,
    acceptance_criteria, test_commands, dependencies, blocked_by,
    allows_network, allows_dependency_addition
  }
  ```

  **THE CRUX:** the synthesized `path_scope` / `acceptance_criteria` / `test_commands` must be **REAL** — otherwise downstream gates cannot verify (**HFTASK-0003**).

- **(c) Carry `workflow_id` as `correlation_id`** end-to-end into **weave Jobs**.
- **(d) Round-trip results:** `hf status --json` / `hf watch` (**HFTASK-0020**) feeds RuVocal; the `correlation_id` round-trip is summarized back to chat (**HFTASK-0021**). The witnessed ledger is the **read-model** — **build NO new dashboard.**

**BLOCKERS:** none technical; **pure build sequencing.**

**REFERENCES:** `prompthub-server/src/server.rs:38-95`, `routes.rs:484+767`, `prompt-hub/src/models.rs:528+547`, `ui/ruvocal/{package.json, mcp-bridge/, rvf.manifest.json, src/lib/server/database/postgres.ts}`; concepts `frontdoor-mapping-ruvocal-prompthub` + "Front door + Mission Control + Delivery (handoff)".

> **QUESTION (open seam):** HFTASK-0019 is undecided — does `prompt_hub` expose an **MCP server** for the bridge to call, or **plain HTTP + bridge-translation**? This is the gating transport decision for the whole front door.
>
> **QUESTION:** how is the vibe `Intent` synthesized into a **real** `path_scope` / `acceptance_criteria` / `test_commands` (not placeholders)? Nothing in the three crates does this synthesis today (HFTASK-0003 crux).

---

## 5. External glue: `n8n`

> Concept: `n8n-external-glue` — labels `type:layer, role:external-glue, status:verified` — **confidence 0.5**
> Graph links: `depends_on → substrate-weave-mesh`, `part_of → stack-topology-reality`

`n8n` is the **EXTERNAL WORKFLOW / GLUE layer**. `~/Desktop/meta/n8n` is the **OFFICIAL n8n monorepo** (**v2.25.1, pnpm, 22+ pkgs**) **PLUS a harness overlay** (`.claude` agents/skills: `n8n-loop`, `run-n8n`, `workflow-ops`; `.lane.yaml` HTTPS relay).

Wired into the stack via:

- **weave mesh** — handoff of the **n8n API key + MCP bearer token over `weave_send`, not files**.
- **dual MCP servers** — `n8n-mcp` (public-api) + `n8n-builtin` (`/mcp-server/http` bearer).
- **GitHub auto-merge on green** — `harness-workflows-validate.yml`.

Harness state lives in `_workspace/` (`HANDOFF.md`, DataTable ledgers `handoff_packets` / `session_events`). **Harness scripts use `bun`; n8n source stays pnpm / Node for CI.**

(Memory note `context-n8n` records two blocked backlog items D-1 / D-2 and the `N8N_APPLY` safety default, but treats them as ephemeral operational status already captured in git history `132820071c` / `09672a3054` — not durable architecture.)

---

## 6. The convergence crate: `mcp-brain-server`

> Concept: `mcp-brain-server-convergence` — labels `type:component, status:pass5-proven, tag:critical` — **confidence 0.5**
> Graph links: `instance_of → ruvector-unifying-abstraction`, `part_of → ruvector-crate-graph-proven`; related: `codewalk-cognitum-gate-tier`; `codewalk-prime-radiant-and-infra → alternative_to → mcp-brain-server-convergence`

`mcp-brain-server` = the **CONVERGENCE crate** = the **`pi.ruv.io` collective brain** (pass 5, code-confirmed). Its **Cargo deps prove it composes the FULL substrate** (all 3 clusters at once):

```text
ruvector-sona
ruvector-mincut (canonical)
ruvector-nervous-system
ruvector-domain-expansion
ruvector-delta-core
ruvector-solver (forward-push)
ruvector-sparsifier
ruvector-consciousness (phi)
ruvllm (minimal)
+ rvf-types / crypto / wire / FEDERATION / runtime
```

**Modules (`src/`):** `store / graph / cognitive / drift / symbolic / trainer / optimizer / ranking / reputation / aggregate / embeddings / midstream / pipeline` + `web_ingest / web_memory / web_store` + `pubmed` (scientific-literature ingest) + `gcs` (Google Cloud Storage) + `voice` + `auth / rate_limit / routes / verify`. **Bins** include `ruvllm-embedder`.

In sum, it is a **FEDERATED (`rvf-federation`) RVF vector store** + **mincut partitioning** + **IIT-phi consciousness** + **ruvllm embeddings** + **drift tracking** + **web/pubmed ingestion**, served over **HTTP + brain MCP tools** (`brain_search` / `share` / `partition` [= MinCut clusters] / `drift`).

Per `RuVector/CLAUDE.md`: **1500+ memories, 350K+ graph edges**, deployed as **`ruvbrain` on Google Cloud Run `us-central1`**, **differential privacy eps=1.0**, **7 Cloud Scheduler optimization jobs**.

This crate is **the literal proof that mincut + ruvllm + rvf are one interconnected system.**

(For the RuVector substrate that this crate composes, see `05-ruvector-substrate`.)

---

## 7. Cross-cutting: `rtk` (token optimization)

> Concept: `rtk-token-optimization` — labels `type:cross-cutting, role:optimization, status:verified` — **confidence 0.5**
> Graph link: `related_to → stack-topology-reality`

**`rtk` (Rust Token Killer)** lives at `~/Desktop/meta/rtk-tokenkill`. It is a **token-optimized CLI proxy** giving **60–90% savings on dev ops** by filtering verbose output (git / cargo / gh / test / build / docker …).

Applied **transparently**:

- via a **Claude Code PreToolUse hook** (`command → rtk command`), and
- via **interactive bash aliases** in `~/.config/yazelix/shell_bash.sh`.

**Meta commands:** `rtk gain`, `rtk discover`, `rtk proxy`.

**Critically: `rtk` is NOT in the request pipeline** — it wraps every *tool call* underneath.

Supporting memory facts: **`rtk` 0.42.0** is wired across Claude Code, Gemini, Codex, Devin (and Kimi), with **`rtk verify` passing 145/145 tests**; Claude Code uses a native PreToolUse Bash hook via `rtk hook claude` (`context-rtk`, `context-rtk-tokenkill`).

---

## 8. Cross-cutting: `icm` (persistent memory)

> Concept: `icm-persistent-memory` — labels `type:cross-cutting, role:memory, status:verified` — **confidence 0.5**
> Graph link: `related_to → stack-topology-reality`

**ICM (Infinite Context Memory)** lives at `~/Desktop/meta/icm`. It provides **persistent cross-session memory via MCP + CLI**:

- **recall / store** by **topic + importance**, plus
- **`memoir`** structured knowledge graphs (concepts + typed links: `part-of` / `depends-on` / `related-to` / `refines` / `superseded-by` …).

**Mandatory-store triggers:** error resolved, design decision, user preference, task complete.

It is **SQLite-backed; embeddings deferred** (fast writes).

> **This memoir IS an ICM artifact** — the `system-architecture` memoir that this entire `architecture/map/` set is rendered from is itself an ICM memoir export. ICM is therefore both a component of the stack and the substrate this map is sourced from.

---

## 9. Workstation entry: terminal / Yazelix

> Concept: `terminal-yazelix-stack` — labels `type:context, role:terminal, status:verified` — **confidence 0.5**
> Graph link: `depends_on → envctl-os-foundation`

This is **WORKSTATION ENTRY (context, not core).** The flow:

```text
login shell /bin/bash
  -> ~/.bashrc auto-enter block (injected by envctl) runs 'yzx enter' on every interactive shell
  -> Yazelix (Zellij multiplexer + Yazi sidebar + Helix + Codex right pane)
       panes default to nushell (settings.jsonc default_shell=nu)
```

**Double enforcement of Yazelix:** the app-menu "Ghostty" icon is actually **`com.yazelix.Yazelix.Ghostty.desktop`** (`Exec=yzx desktop launch`), **not plain ghostty** — so Yazelix is enforced both by the launcher *and* the `.bashrc` hook.

**The escape hatch:** plain `/usr/bin/ghostty` + `com.mitchellh.ghostty.desktop` exist as the bypass.

**Notes:** `.zshrc` is **dormant** (ForgeCode boilerplate; zsh is not the login shell). `/terminal-setup` is **blocked** because it refuses VTE/multiplexer contexts **AND** is unnecessary (Ghostty supports `Shift+Enter` natively).

This layer **depends on `envctl-os-foundation`** (the OS-foundation layer that injects the `.bashrc` block) — see `03-envctl-kasetto`.

---

## Questions

1. **HFTASK-0019 (transport, open):** Does `prompt_hub` expose an **MCP server** for `mcp-bridge` to call, or **plain HTTP + bridge-translation**? This is the gating decision for the entire RuVocal → prompt_hub seam. (§4)
2. **Intent → envelope synthesis (HFTASK-0003 crux):** How does `prompt_hub` synthesize a vibe `Intent` into **real** `path_scope` / `acceptance_criteria` / `test_commands`? Nothing in the three crates does this today, and placeholder values would break downstream gates. (§4)
3. **Embedding backend (not fully closed):** `decisions-prompt-hub` recommends `candle`; the later `decisions-prompt-hub-embedding-backend` finds `fastembed-rs` v5.13.4 is itself zero-unsafe and `bge-m3`-capable. Which is the adopted backend under `#![forbid(unsafe_code)]`? (§1.2)
4. **Front-door wiring status:** `prompt_hub-front-door` is labeled `status:verified` yet states the capability "is NOT code-wired as the actual intake yet." Confirm the intended reading: *capability verified by code-walk, but not yet activated as the live intake.* (§1)
5. **Low-confidence flag:** all front-door/integration concepts are at **0.5 confidence** (only `s1-resolved-frontdoor-ledger-naming` is 0.6). The seam contract's file:line references (e.g. `models.rs:528+547`, `server.rs:38-95`) should be re-validated against current `prompt_hub` HEAD before being relied on for the build, since the construction loop has since shipped PRs #94–#106. (§4)

## Lessons

- **Front-door ledger + naming are RESOLVED** (`s1-resolved-frontdoor-ledger-naming`, user-confirmed 2026-06-09, conf 0.6): v1 handoff ledger = **`rusqlite` (SQLite/WAL) + `rvf-crypto::WitnessChain`** (standalone, no napi); the **RVF vector-native ledger is the scheduled V2 upgrade**; canonical kernel name = **handoff / `.handoff`** (Ark/V2 dropped); **`rvf-node` is a TS read-bridge only**, never for the Rust `hf` CLI.
- **Roles are locked:** `prompt_hub` = the **single canonical intake** (intent-minting); **RuVocal** = its primary human UI; all other doors (CLI / n8n / meta) are **thin shims** to `prompt_hub` ("Plan C").
- **Already-real connection:** RuVocal's vector backend is pgvector = **`ruvector-postgres`** — the UI is already running on a RuVector crate (the front door is partly wired to the foundation).
- **Witnessed ledger = the read-model:** results round-trip via `hf status --json` / `hf watch` — **build NO new dashboard** (HFTASK-0020/0021).
- **`mcp-brain-server` is the convergence proof:** its Cargo dep graph composes mincut + ruvllm + rvf-federation in one crate, deployed as `ruvbrain` on Cloud Run `us-central1` (1500+ memories, 350K+ edges, eps=1.0, 7 scheduler jobs) — the literal evidence that the substrate is one interconnected system.
- **`rtk` wraps tool calls, not requests:** 60–90% dev-op token savings via PreToolUse hook + yazelix shell aliases; not part of the user-request pipeline.
- **ICM is both component and source:** this entire memoir/map is an ICM artifact; ICM is SQLite-backed with embeddings deferred for fast writes.
- **Yazelix is doubly enforced** (app-launcher desktop file + envctl-injected `.bashrc` hook), with plain ghostty as the deliberate escape hatch.

## Cross-references

- [`01-meta-control-plane`](./01-meta-control-plane.md) — the meta CLI / control plane; the `meta` door is a thin shim to `prompt_hub`.
- [`02-handoff-continuity`](./02-handoff-continuity.md) — the `handoff` / `.handoff` kernel, `hf` CLI, `handoff.task.v1` envelope, witnessed ledger (the seam's downstream).
- [`03-envctl-kasetto`](./03-envctl-kasetto.md) — `envctl-os-foundation`, which injects the `.bashrc` auto-enter block that the Yazelix terminal stack depends on.
- [`04-weave-coordination`](./04-weave-coordination.md) — weave mesh / weave Jobs; n8n key handoff over `weave_send`, and the `correlation_id → weave Jobs` carry in the seam contract.
- [`05-ruvector-substrate`](./05-ruvector-substrate.md) — the RuVector crate graph (`ruvector-postgres`, mincut, ruvllm, rvf-federation) that RuVocal and `mcp-brain-server` are built on.
- [`08-gaps-seams-merge`](./08-gaps-seams-merge.md) — `gap-front-door-ambiguity`, `critical-missing-seams`, and the open RuVocal↔prompt_hub seam tracked there.
