# 04 — weave: The Agent-to-Agent Coordination Substrate (Mesh), Its Lineage, and Obscura

`weave` is the single **coordination substrate** of the FlexNetOS estate — a dependency-light Rust binary that is the *only live cross-agent coordination channel* in the stack. Any tool "integrates" with the estate by becoming a **weave peer** (registering, sending messages, claiming durable jobs), not by direct API calls. This document renders weave's substrate model, the A2A seam contract a new tool builds against, weave's lineage (it is the upgrade/successor of `mcp-broker` and the Rust port of `repowire`, both now formally retired) and its planned `obscura` browser, plus two named gaps: the autonomous loops that still use the *retired* weave-repowire predecessors, and the production-ready obscura browser that is ready but unwired.

> **Confidence note.** In `system-architecture.graph.json`, every concept in this memoir carries a uniform export-default `confidence: 0.5`. That blanket number is **not** a per-claim assessment. The real per-concept signal is the `status:` label, preserved verbatim below (`verified`, `decided`, `user-stated`, `blocking`). Where a fact is genuinely uncertain, it is flagged inline and in the QUESTIONS section; otherwise treat `verified`/`decided` items as confirmed.

---

## weave — the coordination substrate

> Concept: `weave-coordination-substrate` · labels: `type:layer`, `role:orchestration`, **`status:verified`** · graph confidence 0.5 (export default)

weave is a **COORDINATION SUBSTRATE (not a pipeline orchestrator)**. It is a single dependency-light Rust binary **v0.2.0** (CLI + MCP server in one).

**Broker = SQLite.** SQLite *is* the broker at `~/.local/share/weave/messages.db` (override with `WEAVE_DB`); an optional **libsql** backend exists; an optional **`weaved` presence daemon** exists.

**Tables:** `messages`, `reads`, `peers`, `asks`, `ask_groups`, `jobs`, `outbox`, `pull_cursor`.

**Surface:** 50+ `weave_*` MCP tools.

**Work enters 3 ways:**

1. `weave_send` (a message)
2. `weave_job_create` — a **durable, poll-only job queue** with **`attempt_id` fencing tokens**
3. cross-store **outbox** delivery

**INVARIANT — owner-only-writes:** a process writes only its own store; foreign stores are **read-only**.

**No autonomous dispatch/spawn** (that is a future epic).

`prompt_hub` / `envctl` appear **only as TEST peer names** — there is **no real integration** with them. Any tool becomes a peer by registering + sending + claiming jobs.

### Relationships (from the graph)

- `substrate-weave-mesh` → `weave-coordination-substrate` (the mesh is this substrate in its integration role)
- `seam-spec-weave-a2a-2026-06-11` → `weave-coordination-substrate`
- `weave-lineage-and-obscura` → `weave-coordination-substrate`
- Consumers/observers pointing at the substrate: `prompt_hub-front-door`, `rusty-idd-merge-planner`, `rvagent-rust-agent-framework`, `gap-missing-integration-contract`
- `weave-coordination-substrate` → `envctl-os-foundation`, `stack-topology-reality`

---

## Integration substrate #1 — the weave mesh

> Concept: `substrate-weave-mesh` · labels: `type:substrate`, **`status:verified`**, `tag:critical` · graph confidence 0.5 (export default)

The weave mesh is **INTEGRATION SUBSTRATE #1** and **the ONLY live cross-agent coordination channel.**

- Tools join as **peers** — registering `name + mux + pane + git tags`.
- Peers exchange **messages / asks** and coordinate **durable work** via the `jobs` table with `attempt_id` fencing.
- **Live consumers today:** the **n8n harness** (secret handoff over `weave_send`) and the **session-relay heartbeats**.
- **Everything else that "integrates" does so by becoming a weave peer, not by direct API calls.**

Graph link: `continuity-session-relay` → `substrate-weave-mesh` and `n8n-external-glue` → `substrate-weave-mesh` confirm those two named consumers. See [02 — Handoff & Continuity](./02-handoff-continuity.md) for the session-relay loop that beats on this mesh.

---

## The A2A seam contract — decided 2026-06-11

> Concept: `seam-spec-weave-a2a-2026-06-11` · labels: `type:seam-spec`, **`status:decided`**, `session:2026-06-11`, `role:orchestration`, `tag:critical` · graph confidence 0.5 (export default)

**STATUS: decided** — the substrate is **ready to build against**; the verdict + dispatch + protocol-bridge gaps are specified.

**Context / task brief:** *"weave must be integrated for agent-to-agent communication and orchestration."*

### Finding (code review 2026-06-11)

weave = a **sanctioned 4-crate workspace v0.2.0**:

```text
weave-core  <-  weave-inject  <-  weave-mcp  <-  weave (bin)
# one static binary
```

- `develop == master == clean` through **PR #60 (2026-06-11)**; the docs sanction the workspace.
- The **dual-backend gate is green**; `master` is protected by **6 CI checks**.

### Coordination surface (`weave-core/src/model.rs`)

- **`Job` (line 951)** — the work-queue lifecycle row: a `JobState` machine; **`attempt_id` fencing token set on CLAIM**; `correlation_id` (carries the **`handoff.task.v1` id** per locked decision — **weave Jobs = coordination VIEW, never source of truth**); `source_kind` / `source_id`; `progress_events_json` (append-only); cooperative-cancel fields; `result` / `error` / `artifacts` JSON.
- **`Lease` (line 1199, WL-024 / WL-029)** — an **advisory path lease** `{ resource (normalized, ancestor-conflict detection), holder, acquired, expires (TTL ≤ 24h), note }`.
- **`ReviewItem` (line 1114, WL-020)** — **VERIFIED still has NO verdict field** (`{ id, pr_url, title, author, repo, state Open/Merged/Closed, review_requested_at, reviewed_at, reviewed_by }`). Therefore **verdicts must ride permission asks** (WL-021: `Approved` / `Denied` / `Timeout`, via an answer body `== "approve"`) **plus** a `review_verdict` event in **hf's OWN ledger** (locked **R6** decision: **hf enforces the gate, weave only records**).

**NO autonomous dispatch:** spawn sites exist only in `weave-inject` (terminal pane injection); Jobs are **poll-only**; the `JobRunner` is a **future epic** — the **session-relay loop stays the runner**.

### Proven integration pattern (first real consumer)

`handoff/hf/src/lease.rs` — a **`Leaser` trait** with a `WeaveCli::from_env()` impl that **shells out to the weave binary** (`Command::new`, **no crate dependency**), gated by `ClaimGate::{ Refuse, Proceed, ProceedDegraded }` → **graceful ledger-only degradation when no mesh is present** (HFTASK-0002 DONE).

### A2A CONTRACT for any new tool

1. **Identity:** `resolve_me()` = `flag > $WEAVE_SESSION > basename(cwd)`; the `peers` table maps `name -> (mux, pane)` captured at `SessionStart`.
2. **Messaging:** `weave_send` / `inbox` / `thread`; SQLite broker at `~/.local/share/weave/messages.db` (`WEAVE_DB` override); **owner-only-writes** invariant; per-reader read tracking; **broadcasts are never injected**.
3. **Durable work:** `job_create -> job_claim` (attempt fencing) `-> job_update -> job_result`.
4. **Mutual exclusion:** `lease_reserve / release / sweep` with path-conflict semantics.
5. **Approval:** `ask` / `permission` tools.

**Transport choice:** CLI subprocess (the hf-proven path) **or** MCP stdio (`weave-mcp`, 50+ `weave_*` tools). `weave-core` is path-dep-able, but the **subprocess seam is the sanctioned pattern**.

### RuVector side — a parallel A2A substrate

`rvAgent` ships `rvagent-a2a` (Agent2Agent protocol, **ADR-159**) + `rvagent-acp` + `rvagent-mcp` — a **PARALLEL a2a substrate**. **Bridging `weave` (mesh) ⇄ `rvAgent` (A2A) is NOT designed; today `hf` is the only junction.** Also **missing:** the **N-reviewers → one-verdict reducer** (~50–100 LOC, **R5**).

### Consequences

- Build **leases / jobs / messages** against weave **NOW**; do **not** wait for `JobRunner`.
- Keep **verdicts out-of-band**.
- Treat **weave ⇄ rvAgent bridging** as an explicit **open design item**.

### References

`weave-core/src/model.rs:951` / `:1114` / `:1199`; `weave/CLAUDE.md`; `handoff/hf/src/lease.rs` + `main.rs:90-123`; memoir `weave-coordination-substrate`; R5 / R6 research notes.

> Graph links: `loop-e2e-proof-2026-06-12` → this seam, and `ship-loop-proof-2026-06-12` → this seam (the loop e2e/ship proofs exercise the A2A seam). See [01 — Meta Control Plane](./01-meta-control-plane.md) and [08 — Gaps, Seams & Merge State](./08-gaps-seams-merge.md).

---

## weave lineage and obscura (user-authoritative)

> Concept: `weave-lineage-and-obscura` · labels: `type:lineage`, **`status:user-stated`**, `tag:critical` · graph confidence 0.5 (export default)
>
> **NOTE — this concept is `status:user-stated`** (asserted by the owner, not independently code-verified at the time of capture). The companion concept `weave-lineage-retired` below is the **verified** resolution of the same lineage.

**WEAVE LINEAGE (user-authoritative):** weave is the **UPGRADE / successor of two earlier projects** — it **absorbs `mcp-broker`** and is the **Rust PORT of `repowire`**. **weave is still INCOMPLETE.**

**Browser / web capability:** weave will use **`h4ckf0r0day/obscura`** (a browser) **NOT Chrome/chromium** — relevant for any agent web-automation or fetch path.

**Implication:** weave's final shape is **bigger than its current code**; design the coordination substrate against the **intended post-merge weave** (mcp-broker features + repowire port + obscura browser), **not just v0.2.0 today**.

> Graph links: `weave-lineage-and-obscura` → `weave-coordination-substrate`; `obscura-ready-unwired` → `weave-lineage-and-obscura`; `weave-lineage-retired` → `weave-lineage-and-obscura`.

---

## Lineage resolved (verified)

> Concept: `weave-lineage-retired` · labels: `type:lineage`, **`status:verified`** · graph confidence 0.5 (export default)

**LINEAGE RESOLVED (verified):** weave **FORMALLY RETIRED** `mcp-broker` + `repowire` (`weave/ARCHITECTURE.md` **section 8**, **2026-06**).

- **`mcp-broker`** = a **Python poll-only mailbox** (standalone `~/Desktop/mcp-broker-server.py`; `messages` / `reads` tables; `broker_*` tools) — its **semantics are absorbed by weave Tier-2 cross-store pull**.
- **`repowire`** = a **Python daemon + push + tmux-only** tool (GitHub `prassanna-ravishankar/repowire`, **archived, never cloned**) — its **feature parity is absorbed daemon-free as weave epics P1–P5**.
- The **`weaved` presence daemon IS shipped.**
- **v0.3 roadmap PLANNED (not built):** **P1** stop-boundary wake, **P4** HTTP MCP transport, **P6** iTerm2 injector.
- `weave-mcp-daemon-tools` = a **duplicate / worktree of weave, same source.**

> This verified concept **resolves** the `user-stated` lineage above: the absorption is now formal (documented in `weave/ARCHITECTURE.md §8`), and the predecessors are retired rather than active.

---

## Obscura — production-ready, but unwired

> Concept: `obscura-ready-unwired` · labels: `type:component`, **`status:verified`** · graph confidence 0.5 (export default)

**OBSCURA (verified):** a **COMPLETE, production-ready Rust headless browser** (`h4ckf0r0day/obscura`, repo at `~/Desktop/meta/obscura`).

- **7 crates**, including **`obscura-mcp`** (an MCP stdio server exposing `browser_navigate` / `click` / `fill` / `evaluate` / `snapshot` / `network_requests`, etc.) and **`obscura-cdp`** (Chrome DevTools Protocol, Puppeteer/Playwright-compatible).
- **30 MB** vs Chrome's **200 MB+**.
- **weave → obscura integration is PLANNED, NOT BUILT** — there is **zero build edge / feature flag in weave**.
- **Intended role:** weave **delegates** agent web-automation / scraping to obscura **via MCP** instead of spawning Chrome.
- **NOT a blocker** — it is **ready to wire whenever needed.**

> **Note — sibling estate corroboration (from `lane` memories, for cross-reference only; not part of the 7 assigned weave concepts):** obscura is corroborated as a real **8-crate built engine** (`obscura-browser` / `cdp` / `dom` / `js` / `mcp` / `net` / `cli`, ~**188 commits**) and is the network plane's **"stealth headless browser for AI agents."** The **`lane`** repo took the *parallel* obscura-seam decision **ADR-0001** (governed-egress proxy; obscura spawned as a managed **child process**, **not** a crate dep — "Option B"), which the lane memory explicitly notes **mirrors weave's WL-049 / ADR-0002**. weave's own obscura decision (`decisions-weave`, **WL-049 / ADR-0002 accepted**) is **SPAWN-AND-SPEAK stdio MCP**: weave spawns `obscura mcp` (separate binary, stdio newline-delimited JSON-RPC) via argv-only `std::process::Command` and acts as a minimal hand-rolled MCP **client** (`std::io` + `serde_json`, **no tokio/async/V8 in weave**). The two repos converge on the same pattern: **delegate to obscura over MCP as a child process, never as a crate dependency.** See [03 — envctl & kasetto](./03-envctl-kasetto.md) for the lane/network-plane context and [08 — Gaps, Seams & Merge State](./08-gaps-seams-merge.md) for the seam ledger.

---

## Gap / root cause — loops still use the *retired* weave-repowire

> Concept: `loops-use-stale-weave-repowire` · labels: `type:root-cause`, **`status:blocking`**, `tag:critical` · graph confidence 0.5 (export default)

**ROOT CAUSE of broken tooling (user-confirmed 2026-06-09):** the autonomous **LOOPS + session-relay HOOKS** across the stack (envctl `forge-loop`, etc.) **STILL USE the OLD weave-repowire** (the **pre-merge Python predecessors**), **NOT current weave**.

- The hooks are **BROKEN / MISCONFIGURED** and **BREAK TOOLING** — they **fire in subagent / non-interactive contexts and hijack them** (e.g. an **Explore agent returned `forge-loop "backlog item-2 / forge-loop-smoke"` chatter instead of its report**).
- This **IS a concrete instance of the envctl drift from meta canon:** the loop envctl built **never migrated off retired weave-repowire onto current weave.**

**FIX DIRECTION:**

1. **Migrate loops / hooks to current weave** (retire weave-repowire usage).
2. **Scope hooks so they do not fire in subagents / headless.**
3. **Fix the misconfiguration.**

**Until fixed:** **read crate files DIRECTLY** for these repos rather than spawning subagents.

> Graph links: `loops-use-stale-weave-repowire` → `weave-lineage-retired` (it uses the *retired* predecessors), → `envctl-drift-and-merge-state`, → `subagent-forge-hook-hazard`. See [03 — envctl & kasetto](./03-envctl-kasetto.md) and [08 — Gaps, Seams & Merge State](./08-gaps-seams-merge.md).

---

## Supplementary timeline (from `context-weave` / `decisions-weave` memories)

These memory dumps post-date the memoir's v0.2.0 snapshot and show weave advancing well past it. They are **supplementary** (not among the 7 assigned concepts) and are preserved for fidelity; where they appear to contradict the memoir's `v0.2.0` / "still incomplete" framing, that is **forward motion**, not an error (see QUESTIONS).

- **Architecture (interim → goal):** the multi-crate workspace `weave-core ← weave-inject ← weave-mcp ← weave` is **interim**; a **single-crate architecture is the goal** after meta-workspace alignment (**WL-043 deferred**).
- **CI:** master requires **6 blocking checks**: `rustfmt`, `clippy`, `test`, `build (libsql backend)`, `sign`, `libsql+sign`.
- **Process:** always create worktrees from `origin/develop` after `git fetch`; `develop` mirrors `master` via fast-forward.
- **Security invariants are critical:** no shell spawning (`Command` only); a `compile_error!` in `main.rs` rejects enabling both backend features (`sqlite` + `libsql`) together.
- **WL-049 / ADR-0002 (accepted):** obscura integration = **SPAWN-AND-SPEAK stdio MCP**, not a crate dep (detailed in the obscura section above).
- **WL-050 / ADR-0003 (token-light):** the **73 eager flat `weave_*` tools collapsed to ONE standing `weave` meta-tool** (modes `search` / `describe` / `call` / `list`); `tool_catalog()` is the canonical 73-op registry; eager-flat fallback via `WEAVE_MCP_EAGER=1`. This **supersedes the memoir's "50+ `weave_*` MCP tools" surface** (see QUESTIONS).
- **WL-051:** token-light is now a `CLAUDE.md` invariant + a CI budget gate `MAX_STANDING_TOOLS_BYTES=8192`.
- **WL-052 / 052a / 052b:** multi-surface parity — CLI + MCP + dashboard (read-only) + bots (relay); "one-handler-many-surfaces" design law (dashboard `--write` and Telegram/Slack bots route through the **same** `dispatch_request -> call_tool` handler as MCP/CLI).
- **WL-053:** capture the `$TMUX` socket at registration (persisted on the existing `peers.socket` column — no schema change) and thread `tmux -S <socket>` through inject/spawn/kill/liveness.
- **WL-034:** static mailbox export (`weave export --out <path>`) — offline XSS-safe HTML of a caller's mailbox (PR #90).
- **Standing process debts (2026-06-13):** (a) deny `git push` / `gh pr` to `weave-*` subagents (self-delivery hazard, PR #77); (b) CI duplicate-run concurrency fix (landed PR #87); (c) WL-053 mux-socket capture.

---

## Cross-references

- [01 — Meta Control Plane](./01-meta-control-plane.md) — the loop/control plane that runs *against* the A2A seam; `meta-repo-control-plane`.
- [02 — Handoff & Continuity](./02-handoff-continuity.md) — `hf` is the **first real weave consumer** and the **only weave⇄rvAgent junction**; session-relay is the JobRunner-in-lieu and the mesh's live heartbeat consumer.
- [03 — envctl & kasetto](./03-envctl-kasetto.md) — `envctl forge-loop` is the locus of the **stale weave-repowire** root cause; `lane` (network plane) holds the parallel obscura seam (ADR-0001).
- [05 — RuVector Substrate](./05-ruvector-substrate.md) — `rvAgent`'s **parallel A2A substrate** (`rvagent-a2a` / ADR-159, `rvagent-acp`, `rvagent-mcp`); bridging to the weave mesh is undesigned.
- [07 — Frontdoor Integration](./07-frontdoor-integration.md) — `prompt_hub-front-door` points at the weave substrate; today only a **TEST peer name**, not a real integration.
- [08 — Gaps, Seams & Merge State](./08-gaps-seams-merge.md) — the seam ledger and open gaps: missing rvAgent bridge, N→1 verdict reducer, obscura-unwired, loops-on-stale-weave-repowire, `gap-missing-integration-contract`.

---

## QUESTIONS (contradictions, ambiguous refs, gaps, low-confidence claims)

1. **Tool-surface count contradiction.** The memoir (`weave-coordination-substrate`, A2A seam) states **"50+ `weave_*` MCP tools"** / "50+ weave_* tools", but the `context-weave` memory (2026-06-13, WL-050/ADR-0003) says the surface was **collapsed from 73 eager flat tools to ONE standing `weave` meta-tool** (with `tool_catalog()` as a 73-op registry and `WEAVE_MCP_EAGER=1` fallback). Which surface is current for the architecture map — the 50+/73 eager tools, or the single token-light meta-tool? (Likely the meta-tool superseded it post-memoir; needs confirmation.)
2. **Version vs. roadmap drift.** The memoir pins weave at **v0.2.0** and "still INCOMPLETE," but memories run through **WL-034 → WL-053** and "Repowire-superset: 35/36 + governed obscura web access." Is v0.2.0 still the released version, and is the "still incomplete" framing stale relative to the 2026-06-13 sessions?
3. **`weave-lineage-and-obscura` is `status:user-stated`, not verified.** The owner asserts weave is the Rust port of `repowire` and the absorber of `mcp-broker`. `weave-lineage-retired` (verified) confirms the *retirement / absorption*. Confirm the two are fully reconciled — i.e., is the "Rust PORT of repowire" claim itself code-verified, or only the retirement (`weave/ARCHITECTURE.md §8`)?
4. **`loops-use-stale-weave-repowire` (status:blocking) — is it still open?** User-confirmed 2026-06-09. Have the envctl `forge-loop` / session-relay hooks since been migrated off retired weave-repowire onto current weave, and were the subagent-firing hooks scoped to not fire in headless/subagent contexts? (Resolution would close `subagent-forge-hook-hazard` and the envctl drift.)
5. **`obscura-ready-unwired` (status:verified) — wiring status.** The memoir says "zero build edge/feature flag in weave," yet `decisions-weave` records **WL-049/ADR-0002 accepted** (spawn-and-speak obscura MCP). Is obscura now *decided-and-specified-but-not-built*, *partially built*, or *shipped*? The crate count also differs: memoir "7 crates" vs the lane-memory corroboration "8-crate built engine." Which is authoritative?
6. **rvAgent ⇄ weave bridge + N→1 verdict reducer.** Both are explicitly **NOT designed / missing** (R5). Confirm they remain open and that `hf` is still the sole junction.
7. **Uniform `confidence: 0.5`.** All seven concepts carry the export-default 0.5; per the `status:` labels several are `verified`/`decided`. Confirm the map should trust the `status:` label over the numeric confidence (assumed here).

---

## LESSONS (confirmed facts / decisions / verdicts)

- **weave is a coordination substrate, not a pipeline orchestrator** — a single dependency-light Rust binary (CLI + MCP server in one); **SQLite is the broker** at `~/.local/share/weave/messages.db` (`WEAVE_DB` override); optional libsql backend; optional `weaved` presence daemon. (`status:verified`)
- **The weave mesh is the ONLY live cross-agent coordination channel.** Everything integrates by becoming a **weave peer** (register → send → claim jobs), not by direct API calls. Live consumers: the **n8n harness** and **session-relay heartbeats**. (`status:verified`, `tag:critical`)
- **Owner-only-writes is the core invariant:** a process writes only its own store; foreign stores are read-only.
- **Work enters 3 ways:** `weave_send`, `weave_job_create` (durable poll-only queue with `attempt_id` fencing tokens), and cross-store outbox delivery. **No autonomous dispatch/spawn** (future epic) — **Jobs are poll-only**, the `JobRunner` is a future epic, and the **session-relay loop is the runner**.
- **A2A seam DECIDED 2026-06-11** — the substrate is ready to build against. weave = a sanctioned **4-crate workspace v0.2.0** (`weave-core ← weave-inject ← weave-mcp ← weave`), one static binary; `develop == master == clean` through **PR #60**; `master` protected by **6 CI checks** (`rustfmt`, `clippy`, `test`, `build(libsql)`, `sign`, `libsql+sign`). (`status:decided`, `tag:critical`)
- **The A2A contract for any new tool** has 5 parts: identity (`resolve_me() = flag > $WEAVE_SESSION > basename(cwd)`), messaging (`weave_send`/`inbox`/`thread`, owner-only-writes, broadcasts never injected), durable work (`job_create → job_claim → job_update → job_result`), mutual exclusion (`lease_reserve/release/sweep`), approval (`ask`/`permission`). **Sanctioned transport = subprocess seam** (CLI), or MCP stdio; `weave-core` is path-dep-able but subprocess is preferred.
- **weave Jobs are a coordination VIEW, never source of truth** — `correlation_id` carries the `handoff.task.v1` id; **hf enforces the gate, weave only records** (locked R6). `ReviewItem` has **NO verdict field** (WL-020, verified) — verdicts ride permission asks (WL-021) plus a `review_verdict` event in hf's own ledger.
- **Proven first consumer = `handoff/hf/src/lease.rs`** — a `Leaser` trait + `WeaveCli::from_env()` that shells out to the weave binary (no crate dep), with `ClaimGate::{Refuse, Proceed, ProceedDegraded}` for graceful ledger-only degradation when no mesh is present (HFTASK-0002 DONE).
- **Lineage RETIRED (verified):** weave **formally retired `mcp-broker` + `repowire`** (`weave/ARCHITECTURE.md §8`, 2026-06). `mcp-broker` (Python poll-only mailbox, `broker_*` tools) → absorbed as weave Tier-2 cross-store pull; `repowire` (Python daemon+push+tmux-only, `prassanna-ravishankar/repowire`, **archived, never cloned**) → parity absorbed daemon-free as weave epics **P1–P5**. `weaved` presence daemon **IS shipped**. v0.3 roadmap **PLANNED (not built):** P1 stop-boundary wake, P4 HTTP MCP transport, P6 iTerm2 injector. `weave-mcp-daemon-tools` = duplicate/worktree, same source.
- **Obscura is a complete, production-ready Rust headless browser** (`h4ckf0r0day/obscura`, `~/Desktop/meta/obscura`) — `obscura-mcp` (MCP stdio: `browser_navigate/click/fill/evaluate/snapshot/network_requests`) + `obscura-cdp` (CDP, Puppeteer/Playwright-compatible); **30 MB vs Chrome 200 MB+**. **weave→obscura is PLANNED NOT BUILT** (zero build edge/feature flag in weave) but **NOT a blocker** — ready to wire on demand. weave's accepted seam (WL-049/ADR-0002): **spawn `obscura mcp` as a child process over stdio JSON-RPC; weave is a hand-rolled MCP client; NO tokio/async/V8 in weave; obscura is NOT a crate dep.**
- **ROOT CAUSE (status:blocking, user-confirmed 2026-06-09):** the autonomous **loops + session-relay hooks (envctl `forge-loop`, etc.) still use the RETIRED weave-repowire Python predecessors, not current weave.** The hooks are broken/misconfigured, fire in subagent/non-interactive contexts and **hijack them** (an Explore agent returned forge-loop smoke chatter instead of its report). **Workaround until fixed: read crate files directly rather than spawning subagents.** Fix = migrate loops/hooks to current weave + scope hooks out of subagents/headless.
- **A parallel A2A substrate exists on the RuVector side** — `rvagent-a2a` (Agent2Agent, ADR-159) + `rvagent-acp` + `rvagent-mcp`. **weave⇄rvAgent bridging is NOT designed; `hf` is the only junction.** The N-reviewers→one-verdict reducer (~50–100 LOC, R5) is also missing.
