# 02 — Handoff, Continuity Ledger (`hf`), the Autonomous Loop, and the Session-Relay

This document is the faithful, reorganized "identical map" of the ICM `system-architecture` memoir concepts that describe how FlexNetOS keeps work continuous across agent sessions and how the no-human-in-the-loop autonomous shipping loop runs. The spine is the **Handoff Loop v2** decision (ADR-0001) and its **Continuity Ledger Kernel** — owned by the `hf` CLI, recorded as a witnessed (tamper-evident) ledger, coordinated through weave leases, and gated by GitHub-native fail-closed auto-merge. Around that spine sit two continuity substrates (committed files; the session-relay) and the verified end-to-end proofs that the loop actually ships code with no human merge action. All paths, `HFTASK-NNNN` ids, ADR ids, dates, and verdicts are preserved verbatim from ICM.

> Confidence flags: most concepts in this cluster carry ICM `confidence: 0.5`, with two at `0.6` (`Front door + Mission Control + Delivery`, `handoff-ledger-ark-spec`, `session-handoff-2026-06-09`). Per task rules, concepts at `<0.7` are flagged inline as `[confidence: X]`. No concept here is `<0.6`, so all are surfaced rather than demoted, but their decision/forecast claims should be read as research-backed positions, not settled invariants.

---

## 1. The decision spine — Handoff Loop v2 (ADR-0001)

### 1.1 Handoff Loop v2 (ADR-0001) — the session + shipping lifecycle

Labels: `domain:arch`, `type:decision`, `project:handoff`, `adr:0001`. [confidence: 0.5]

**Status: Accepted, research-backed.**

Handoff Loop v2 is the Continuity Ledger Kernel's session-and-shipping lifecycle, owned by the `hf` CLI as **first-class verbs**, recorded as **witnessed ledger events**, and configured by `.handoff/policy.toml`. Its five pillars:

1. **Per-session git worktrees** via `meta_git_lib`'s worktree engine — created off `origin/develop`, holding a weave path-scope lease, recycled on merge, with a sync preflight that **refuses on drift**.
2. **Branch / remote policy** — `develop` ↔ `master` with fast-forward; clone / fork.
3. **Batch-checkout 3–5 leased tasks per cycle** (so the loop never stalls) → **ONE squash commit** → a single PR at `cycle_flush=4`.
4. **Phased reviewer**: `cloud_ultra` (`/code-review ultra`) → `swarm_local` (ruvector/ruflo `rvAgent`), behind a **TRANSITIONAL permission gate**.
5. **`hf sync`** mirrors `.meta.yaml` / `.gitignore` / `.kb` **one-way from the ledger**.

Canonical dotdir = **`.handoff`** (`.hf` does not exist). Tasks `HFTASK-0007..0011`.

`.links` (ICM `relation`): the following are all **`part_of`** Handoff Loop v2 — `Front door + Mission Control + Delivery`, `Surgical AI gatekeeper`, `hf claim mesh lease (HFTASK-0002)`, `gh-aw separation-of-privilege gate`, and `FlexNetOS branch/CI-CD model`.

### 1.2 Front door + Mission Control + Delivery (the INPUT / OBSERVE / OUTPUT surfaces)

Labels: `domain:arch`, `type:decision`, `project:handoff`, `adr:0001`. [confidence: 0.6] — `part_of` Handoff Loop v2.

ADR-0001 §11/§12/§13 + R13/R14 (hand-verified). The diagnosis: the handoff loop had heavy **process** coverage but thin/absent **INPUT, OBSERVE, OUTPUT** surfaces.

- **FRONT DOOR (§11)** — the REAL front door = `meta/RuVector/ui` (**RuVocal**, an unmodified HuggingFace Chat-UI fork with `mcp-bridge/`) + **`prompt_hub`** (the intent engine: `vibe`/`get`/`generate_swarm_bundle`; axum `/vibe` + `/generate_bundle`). **CORRECTION (user):** the `envctl`/`loop-forge` zellij multi-pane dashboard was **ATTEMPTED and FAILED — it is a DEAD END**, not a reuse precedent; do not revive it. RuVocal is the surface and needs prompt_hub integration (`HFTASK-0022`, now P1). **NO MCP server on either prompt_hub OR hf side (verified)** → "over the MCP seam" is **unbuilt**; transport = HTTP / crate-dep / build-seam (`HFTASK-0019`). SwarmBundle `role_prompts` are prompt **STRINGS, empty-in-prod**; `work_orders_from_bundle` is **MIRRORED + TEST-ONLY** (never in the `hf` bin).
- **CRUX:** synthesize a `vibe` Intent into REAL `handoff.task.v1` `path_scope` / `acceptance` / `test_commands`, or dispatched WorkOrders are **unverifiable by the gates** (`HFTASK-0003` upgraded to a real spec).
- **MISSION CONTROL (§12)** — no UI surfaces loop state; the **witnessed ledger (§7) IS the read-model** → `hf status --json` / `hf watch` (`HFTASK-0020`) feeding RuVocal (**not a new dashboard**).
- **DELIVERY (§13)** — `correlation_id` = `workflow_id` is already on every WorkOrder → round-trip the merged result to RuVocal / prompt_hub `summarize` (`HFTASK-0021`).
- **RuVector coverage gaps (R13, crates verified):** cognitum-gate (`HFTASK-0017`), domain-expansion routing (`0018`), MCP seam (`0019`).

### 1.3 Surgical AI gatekeeper (full code knowledge) — the no-human end-state

Labels: `domain:arch`, `type:decision`, `project:handoff`, `adr:0001`. [confidence: 0.5] — `part_of` Handoff Loop v2; `depends_on` `envctl secrets-engine (relay/broker)`.

ADR-0001 §5b / `HFTASK-0014`. The end-state that replaces **ALL** human-in-the-loop approvals in the handoff loop: a **surgical AI gatekeeper** that **MUST have full code knowledge** — complete queryable codebase intelligence via `git kb` code index (`kb_callers` / `kb_impact`) and/or RuVector — so it judges a PR against its **full blast radius** (callers / callees / invariants), not just the diff. It is the `swarm_local` reviewer (`HFTASK-0010`) upgraded with mandatory full-code grounding.

**TWO LAYERS:**
- **(judgment)** the code-omniscient AI gatekeeper decides approve / deny;
- **(enforcement)** `envctl broker::decide` (see [`envctl secrets-engine (relay/broker)`](./03-envctl-kasetto.md)) is the **deterministic default-deny gate** that alone releases the token / permits the merge — **compromising the AI still cannot bypass the broker**.

`permission_gate` is transitional toward **THIS gatekeeper, NOT toward a human**; the human approver is **scaffolding removed once gatekeeper + broker are trusted**. This realizes the no-human-in-the-loop north star safely.

### 1.4 The gh-aw separation-of-privilege gate (adopted guardrail)

> Not on this theme's assigned concept list, but it is `part_of` Handoff Loop v2 (§5a) and is load-bearing context for §1.3. Rendered briefly for faithfulness; the full concept lives in the security/integration theme.

PR-automation guardrail adopted from GitHub Agentic Workflows (`github/gh-aw`) into Handoff Loop v2 §5a: worker/reviewer agents run **read-only** and emit structured intents/verdicts **as DATA**; a separate trusted, narrowly-scoped, **non-agent** job performs `gh pr create`/`merge` — **agents never hold the merge token**. The reviewer verdict stays **OUT-OF-BAND in weave state, never a native GitHub APPROVE** (a bot APPROVE silently satisfies branch-protection required-reviews and defeats the gate; gh-aw issue #25439). `gh-aw` deliberately ships **NO merge safe-output**.

---

## 2. The continuity kernel — spec, spike, build-out, relocation

This is the build history of the kernel, in dependency order. The graph chains it: `handoff-ledger-ark-spec` (spec) → `spike-validated-handoff-seam-ledger` (`refines` the spec) → `buildout-hf-cli-proper-handoff` (`refines` the spike) → `handoff-kernel-relocated-to-meta` (`refines` the build-out).

### 2.1 handoff-ledger-ark-spec — the specification (spec-only, 0% code)

Labels: `type:component`, `status:spec-only`, `tag:critical`. [confidence: 0.6]

NEW HANDOFF PACKAGE (verified **2026-06-09**) at `~/Downloads/tmp/handoff` — a user-built replacement for the poor file-based `HANDOFF.md`. **STATUS: SPECIFICATION ONLY, 0% code** (31KB "Ark Handoff Ledger PRD V2" + 3 JSON schemas `task` / `packet` / `session-event` + templates + `backlog.yaml` of 15 P0/P1 tasks; describes a **12-crate Rust workspace not yet built**; ~15–25 weeks to MVP).

DESIGN (much stronger than `HANDOFF.md`): **ledger-backed continuity** — a SQLite event stream + a **STATE-PRECEDENCE HIERARCHY**:

```text
Git HEAD / worktrees / diffs
  > .handoff/ledger.db
  > tasks/task.yaml
  > decisions/adr.md
  > active.md
  > packets/latest.md  (non-authoritative)
```

plus **drift sentinels** (intent / scope / acceptance hashes), **lease transactions** (atomic claim/release, WAL, file locks), **policy gates**, and an `hf` CLI (verbs: `init`, `index`, `resume`, `claim`, `start`, `checkpoint`, `test`, `drift`, `handoff`).

**NAMING DEBT** to refactor before adoption: "Ark" (a meaningless placeholder) and "V2" (no prior version exists) throughout — rename to e.g. **Continuity / Session Ledger Kernel**, drop V2 to v1. Meant to **REPLACE** the session-relay `HANDOFF.md`; standalone; optional MCP bridge; does **NOT yet reference weave / `cycle_budget`**. NEEDS dev work before adoption.

`.links`: `handoff-ledger-ark-spec` is `alternative_to` [`continuity-session-relay`](#41-continuity-session-relay--the-file-based-relay-pattern) and `related_to` [`substrate-committed-files`](#42-substrate-committed-files--integration-substrate-2).

### 2.2 spike-validated-handoff-seam-ledger — the spike (passing 4/4)

Labels: `type:component`, `status:spike-passing`, `tag:critical`. [confidence: 0.5] — `refines` the ark-spec; `instance_of` `s1-ruvector-meta-mapping`; `depends_on` `codewalk-rvf-cluster`; `related_to` `frontdoor-mapping-ruvocal-prompthub`.

**SPIKE BUILT + PASSING (2026-06-09, user-authorized)** at `~/Downloads/tmp/handoff/spike` — a cargo workspace, 2 crates, `cargo test = 4/4 GREEN`, 5.7s build. It **VALIDATES the v1 `.handoff` design with ADOPTED production crates (no rebuild):**

- **`work-order` crate** = the `handoff.task.v1` envelope: `Status`/`Priority` enums + `WorkOrder{schema, id, title, status, priority, objective, path_scope, acceptance_criteria, test_commands, deps, blocked_by, allows_network, allows_dependency_addition}` + provenance `correlation_id` + `role` + `IntentLock`. **THE SEAM** `work_orders_from_bundle(SwarmBundle) -> Vec<WorkOrder>`: prompt_hub `SwarmBundle{workflow_id, role_prompts: HashMap<Role,String>, handoff_template, ...}` → one provable WorkOrder per role, each carrying `workflow_id` as **CORRELATION_ID** — the single cross-ref handle that closes **gap#1 task-truth** + **gap#3 contract**.
- **`IntentLock`** = `blake3(objective)` / `blake3(path_scope)` / `blake3(acceptance)` = the `.handoff` **drift sentinel**; `intent_unchanged()` detects goal-drift (**TEST PASSES**).
- **`ledger` crate** = `rusqlite` (bundled SQLite, WAL pragma) event store: `append` / `record_transition` / `all_events` / `replay_latest_status` (reconstructs latest status per work-order id = **state-precedence tier-2 replay**) + `verify_witness_chain` using **REAL** `rvf-crypto::{create_witness_chain, verify_witness_chain, WitnessEntry{prev_hash, action_hash, timestamp_ns, witness_type}}` — the STANDALONE production witness crate (`std` feature, **NO `rvf-runtime` / NO napi**) — for tamper-evidence.
- **END-TO-END TEST:** `SwarmBundle` → 2 work orders → 6 witnessed lifecycle events in rusqlite → replay both to `Done` → RVF witness chain over all 6 verifies. ~150 LOC glue + 1 path-dep on `rvf-crypto`.

PROVES: (a) the `SwarmBundle` → `handoff.task.v1` seam, (b) the `rusqlite` + `rvf-crypto`-witness ledger v1, (c) the blake3 drift sentinel, (d) replay. This is a **SPIKE (validation), not the final build**; the RVF vector-native ledger remains the scheduled **v2**. Next: wire to weave leases (`claim`) + a real prompt_hub `SwarmBundle` + a ruvector-verified `AgentContract` proof.

### 2.3 buildout-hf-cli-proper-handoff — the `hf` CLI (built, passing, self-applying)

Labels: `type:component`, `status:built-passing`, `tag:critical`, `role:continuity`. [confidence: 0.5] — `refines` the spike and `refines` `session-handoff-2026-06-09`.

**BUILD-OUT (2026-06-09 s2):** the `hf` CLI is built and produces a **PROPER `.handoff` handoff packet (self-applying)**, at `~/Downloads/tmp/handoff/spike/hf` (added to the spike workspace; `cargo build` green).

- **Verbs:** `init` / `seed` / `status` / `claim` / `checkpoint` / `handoff` / `resume[--json]`. Built on `work-order` (the `handoff.task.v1` envelope) + `ledger` (rusqlite WAL + `rvf-crypto` witness).
- **`hf handoff`** compiles **`handoff.packet.v2`** (North Star + state-precedence + `progress[done/total + witnessed-events-verified]` + `remaining[next-safe-first]` + next-best-task + exact resume commands + a machine JSON summary) to `.handoff/packets/latest.md` + `active.md`. **`hf resume`** prints it; **`hf resume --json`** emits the machine summary.
- **next_safe** = resume an in-progress (`Claimed`/`Checkpointed`) task first, else the first backlog task with deps `Done`.

**RAN END-TO-END** from `~/Downloads/tmp/handoff`: `init` → `seed` (6 real continuation task cards `HFTASK-0001..0006`) → `claim HFTASK-0001` → `checkpoint` → `handoff` → `resume` = a fresh agent gets project / objective / done / remaining / next-task / next-command with **2 tamper-evident events verified**. The `.handoff` dir is now live (`ledger.db`, `tasks/*.task.json`, `packets/latest.md`, `active.md`, `context/capsule.json`). `SESSION-HANDOFF.md` updated as the canonical resume point.

**CONTINUATION BACKLOG (in `.handoff`):**
- `0001` fold spike into the handoff pkg + rename (Continuity Ledger Kernel, v1);
- `0002` wire weave leases into `hf claim`;
- `0003` real prompt_hub `SwarmBundle` → `handoff.task.v1` dispatch over MCP;
- `0004` ruvector-verified `AgentContract` proof at handoff;
- `0005` `hf drift` gate;
- `0006` RVF vector-native ledger v2.

**NOT YET ADOPTED into production;** spike + `hf` prove the design end-to-end.

### 2.4 handoff-kernel-relocated-to-meta — relocation to its own meta repo

Labels: `type:decision`, `status:done`, `tag:critical`, `role:continuity`. [confidence: 0.5] — `refines` the build-out; `instance_of` `meta-architecture-canon` (see [01-meta-control-plane](./01-meta-control-plane.md)).

**RELOCATION DONE (user-directed):** the handoff / Continuity-Ledger-Kernel was moved from the TEMP staging path `~/Downloads/tmp/handoff` to its proper home **`~/Desktop/meta/handoff`** as its **OWN GIT REPO** (`git init` done), per the meta-repo convention (every stack tool = a separate `FlexNetOS/` repo under `~/Desktop/meta`, registered in `.meta.yaml` + `.gitignore`). Done: added `handoff: repo git@github.com:FlexNetOS/handoff.git` to `.meta.yaml`, and `handoff/` to the meta `.gitignore`.

**Layout:**

```text
~/Desktop/meta/handoff/
  Cargo.toml            # workspace
  work-order/
  ledger/
  hf/
  docs/                 # PRD + backlog
  schemas/              # task / packet / session json
  AGENTS.md
  .handoff/             # runtime: ledger.db, tasks/*.task.json, packets/latest.md
```

The `rvf-crypto` path-dep is now **RELATIVE** (`../../RuVector/crates/rvf/rvf-crypto`) — both under `meta`. `cargo test` green (4/4) + `hf handoff`/`resume` work from the new home.

**SCOPE: local move only (NO GitHub push yet** — that outward step confirmed separately: create + push `FlexNetOS/handoff`). OLD `~/Downloads/tmp/handoff` = superseded/archival (spec copied, crates moved out). `SESSION-HANDOFF.md` resume paths updated. **RESUME** = `cd ~/Desktop/meta/handoff && ./target/debug/hf resume`. `HFTASK-0001` updated to "finalize naming (Continuity Ledger Kernel) + push `FlexNetOS/handoff` repo".

**Key invariant:** the `.handoff` RUNTIME dir is **per-repo continuity state (like `.git`)** — it lives at the root of whatever repo `hf` points at.

---

## 3. The claim mesh — `hf claim` as a weave-coordinated lease

### 3.1 hf claim mesh lease (HFTASK-0002)

Labels: `domain:arch`, `type:implementation`, `project:handoff`, `crate:hf`. [confidence: 0.5] — `part_of` Handoff Loop v2.

`hf claim` is **mesh-coordinated, not ledger-local**: `hf/src/lease.rs` reserves an **advisory weave lease** on resource `handoff:claim:<task-id>` (slash-free ⇒ exact-match = **one holder per task**) via `weave lease reserve` **BEFORE** recording the ledger `Claimed` event.

- **Cross-peer conflict** ⇒ refuse claim;
- **same-holder re-reserve** ⇒ heartbeat (TTL extend);
- **weave absent / old** ⇒ degrade to **ledger-only** (offline / CI safe).

Implementation: a `Leaser` trait + `WeaveCli` (no shell, explicit argv) + pure `parse_reserve` / `gate` (unit-tested). `hf release` frees the lease.

**NOTE:** the `lease` CLI lives in the **newer weave** (the `weave-mcp-daemon-tools` build), **not** the installed `~/.cargo/bin/weave`; override via the **`HF_WEAVE_BIN`** env var. (See [04-weave-coordination](./04-weave-coordination.md).)

---

## 4. The continuity substrates — files and the session-relay

These two substrates predate and coexist with the `hf` kernel. The graph marks `handoff-ledger-ark-spec` as `alternative_to` `continuity-session-relay` — the file-based relay is the pattern the ledger kernel is intended to **replace** (its `HANDOFF.md`), while committed files remain the durable backbone.

### 4.1 continuity-session-relay — the file-based relay pattern

Labels: `type:cross-cutting`, `role:continuity`, `status:verified`. [confidence: 0.5] — `depends_on` [`substrate-committed-files`](#42-substrate-committed-files--integration-substrate-2) and `depends_on` `substrate-weave-mesh` (see [04-weave-coordination](./04-weave-coordination.md)).

The CONTINUITY MECHANISM enabling **no-human-in-the-loop**. The pattern lives in `weave-harness-loop/.claude/skills/session-relay` + the `continuity-steward` agent.

- **AUTHORITATIVE resume signal = committed `_workspace/HANDOFF.md`** (survives all restarts). weave `relay:handoff` / `relay:resumed` broadcasts are **OBSERVABILITY only, not the payload**.
- **`HANDOFF.md` schema:** `closed_utc`, `branch`, `worktree(abs)`, `cycle_budget`, `cycles_total`, `last_item` / `next_item`, `landed_this_session[sha+subject]`, `open_findings`, `decisions`, `dead_ends`, `verify_on_resume[]`.
- **`loop_state.md`** tracks `cycle_budget(=3)` / `cycles_this_session(reset on resume)` / `cycles_total` / `apply_mode`.
- **Resume:** read `HANDOFF.md` → run `verify-on-resume.sh` (fail → write `NEEDS-HUMAN` + halt) → broadcast `resumed` → continue.
- **Handoff at `cycle_budget`** via a one-shot `CronCreate{recurring:false}` ~3 min out, then **STOP** (a fresh session spawns).
- **Bootstrap hazard:** if the last commit touched weave wire files (`mcp.rs` / `store.rs` / `inject.rs` / `setup.rs`), **pin a known-good weave before the live heartbeat**.

### 4.2 substrate-committed-files — integration substrate #2

Labels: `type:substrate`, `status:verified`, `tag:critical`. [confidence: 0.5] — `related_to` `handoff-ledger-ark-spec`, `gap-multiple-task-truths`; the dependency target of `continuity-session-relay`.

**INTEGRATION SUBSTRATE #2: committed files on disk as the source of truth — the durable, restart-surviving backbone.**

Instances:
- `_workspace/HANDOFF.md` (resume signal),
- `_workspace/backlog.md` + `loop_state.md` (per-harness task state),
- `kasetto.lock` (provisioning truth — see [03-envctl-kasetto](./03-envctl-kasetto.md)),
- `rusty-idd` `AI_MERGE/` markdown + `.idd/LOCK.md` (plan truth),
- `prompt_hub` `_workspace/` harness state.

**Files beat the mesh:** when in doubt the committed file wins (the weave heartbeat is best-effort, and is skipped during bootstrap hazards).

---

## 5. The proofs — the loop ran end-to-end with no human merge

Two verified evidence concepts (2026-06-12) demonstrate that the loop and the ship policy actually run in production, plus the session-handoff anchor and the harness-upgrade hardening facts.

### 5.1 session-handoff-2026-06-09 — the 06-09 session anchor

Labels: `type:handoff`, `status:active`, `tag:critical`. [confidence: 0.6] — `related_to` `handoff-ledger-ark-spec`; `refines` `decision-log-2026-06-09`.

SESSION HANDOFF **2026-06-09** (see `~/Desktop/meta/SESSION-HANDOFF.md`).

- **DONE:** full stack architecture mapped (**47 concepts**); ruvector / ruflo researched passes 1–5 (`RUVECTOR-RESEARCH.md`); envctl / meta-canon / handoff-pkg researched; integration plans drafted (`STACK-INTEGRATION-PLANS.md`).
- **OPTION 1 COMPLETE:** `settings.json` hooks repointed stale `weave-mcp-daemon-tools/target/debug/weave` → `/home/drdave/.cargo/bin/weave` (4×) AND all retired repowire hooks neutered → `true` (notification + 2× session + prompt + 2× stop); verified JSON valid, 0 repowire, 0 daemon-tools refs.
- **OPTION 2 COMPLETE:** `envctl/_workspace/STOP` kill-switch created (forge-loop source stopped; n8n / weave loops left running).
- **USER-ACTION REQUIRED (HARD-BLOCKED, agent cannot self-grant):** user must manually add a settings-write permission rule (allow `Edit`/`Write` on `~/.claude/settings.json`) via `/permissions`.
- **GO-FORWARD:** (1) continue research until every crate detail is walked → a code-backed plan (next: `rvf-adapter-claude-flow` to settle the ruflo ↔ Rust-RVF verdict; `rvAgent` vs `ruflo` vs `weave`; remaining ruvector crates) — read crates DIRECTLY (subagent hook-hijack, though hooks now point at the current weave). (2) **FIRST IMPLEMENTATION = finish the handoff package** `~/Downloads/tmp/handoff` (Ark Handoff Ledger, spec-only) because it HOSTS task + implementation organization — rename Ark/V2 first. Provisional: weave Jobs source-of-truth (reconcile vs handoff-ledger), envelope-after-spike, smallest-upgrade-first.

### 5.2 loop-e2e-proof-2026-06-12 — ONE full no-human cycle ran end-to-end

Labels: `type:evidence`, `status:verified`, `session:2026-06-12`, `domain:autonomous-loop`, `tag:critical`. [confidence: 0.5] — `refines` `seam-spec-weave-a2a-2026-06-11` (see [08-gaps-seams-merge](./08-gaps-seams-merge.md)).

**STATUS: verified** — ONE full **no-human** cycle ran end-to-end through the handoff kernel (**2026-06-12**, org-audit mission Phase 5).

**PIPE (both tasks, real work, zero mocks):**

```text
handoff.task.v1 card
  -> weave Job w/ correlation (job_1781288389… / job_1781288736…) + fenced claim (attempt_id)
  -> hf claim (weave lease handoff:claim:<id>; canonical lease-capable weave build —
       ~/.cargo/bin/weave is STALE pre-WL-024, use meta/weave target/release via HF_WEAVE_BIN)
  -> fresh worktree (meta git worktree create hftask-00xx;
       RuVector symlink satisfies ledger's rvf-crypto path dep)
  -> implement -> witnessed checkpoints -> hf ship
  -> REQUIRED checks -> GitHub-NATIVE auto-merge -> verdict round-trip
  -> develop FF -> hf handoff -> weave job result
```

- **TASK A (`HFTASK-0012` slice):** handoff CI born green (PR#2, `00fdf85`) — `ci.yml` `Test(ubuntu,macos)`/`Clippy`/`Format` each cloning `FlexNetOS/meta-ruvector` as a sibling `RuVector/` for the `rvf-crypto` relative path dep + `notify-parent.yml`; the 4 checks made **REQUIRED (strict)** on protected `master`; also fixed `hf` clippy `unnecessary_map_or` + fmt drift (handoff gates were red before).
- **TASK B (`HFTASK-0009` slice):** `hf ship` v0 **BOOTSTRAPPED** — its first execution **shipped its own implementation** (single squash-style commit → push → PR#3 → `gh pr merge --auto --squash` armed → `pr_opened` event); GitHub **auto-merged `1894a7c` on green checks WITH NO AGENT MERGE ACTION** (the fail-closed **R11** model in production); `hf review verdict` records `review_verdict` in the witnessed ledger, fed by a weave permission-ask round-trip (`ask_66_1781294399867172`, answer body `approve` — **R6 channel, never a GitHub APPROVE**).
- **ADR-0002 `weave-a2a-conventions` merged (docs/):** the 5-surface contract (identity / leases / jobs / messaging / out-of-band verdicts) + CLI-subprocess transport rule + stale-binary preflight.
- **Witness chain verified: 16 events.**
- **CAVEATS / GAPS (honest):** the reviewer was **orchestrator-as-stand-in** (a separate-role `cloud_ultra`/swarm reviewer = `HFTASK-0010` remainder); `pr_opened` wrote to the **WORKTREE's ledger** (session-ledger location = `HFTASK-0007` design point; the canonical copy was recorded via checkpoint in the main checkout); `--batch`/cycle-counter **not built** (deps `0007`/`0008`); kasetto `sync --locked` preflight deferred to `0007` (no session verb yet); `HFTASK-0003`/`0019` (envelope synthesis + transport) and RuVocal untouched per readiness order.
- **REFERENCES:** `FlexNetOS/handoff` PR#2 + PR#3, `.handoff/packets/latest.md`, `docs/adr-0002-weave-a2a-conventions.md`, `org-protection-rollout-2026-06-12`, `decision-log-2026-06-09` (R6/R11), `HFTASK-0009`/`0010`/`0012` cards.

### 5.3 ship-loop-proof-2026-06-12 — the commit→push→PR→merge policy ran on three repos

Labels: `type:evidence`, `status:verified`, `session:2026-06-12`, `domain:ship-policy`, `tag:critical`. [confidence: 0.5] — `refines` `seam-spec-weave-a2a-2026-06-11` and `adr-2026-06-11-open-questions`.

**STATUS: verified** — the commit → push → PR → merge policy ran **end-to-end on three repos (2026-06-12)**. CONTEXT: the user asked for the meta loop ship policy, a commit of all pending changes, and proof the loop runs the merge; handoff publication had just been unblocked by the human.

**EVIDENCE:**
1. **WEAVE** (the only protected repo): PR **#61** "docs: reframe the workspace as interim" merged **2026-06-12T03:42Z** with ALL required checks green (rustfmt, clippy, test, build libsql, sign, libsql+sign, +CodeQL) — the protected fail-closed merge loop works in production. **SUPERSESSION recorded:** the multi-crate workspace is now **INTERIM** (work within the 4 crates, no new crates, collapse to single-crate after meta alignment; `backup/*` tags retained) — this revises `seam-spec-weave-a2a-2026-06-11`'s "sanctioned permanent" stance.
2. **HANDOFF:** published canonically at **`FlexNetOS/handoff`** (PUBLIC, `master`; `drdave-flexnetos` URL redirects); local origin normalized to `git@github.com:FlexNetOS/handoff.git`; `NEEDS-HUMAN.md` closed via PR **#1** (squash-merged `e47777f`); `develop` mirror branch pushed; the `hf` ledger is live (**22 tasks**; `HFTASK-0001` checkpointed with publication evidence; its 06-09 weave lease already expired). **OPEN-QUESTIONS #10 (handoff publish) RESOLVED.**
3. **META PARENT:** `dashboard-tab-grouping` carries the RuVector research corpus (`runbook` / `ledger` / `S1` / `plans` / `session-handoff` / `.rvwalk.py` — open-questions **#11 RESOLVED**, docs now tracked), `.meta.yaml` registration (handoff + plugins + provides/tags), workspace member sync, codex + agent tooling; an accidental `weave-handoff` GITLINK removed (`714abca` — child checkouts are gitignored, never embedded; `weave-handoff/` = a second weave checkout on `chore/backlog-handoff` recording `WL-043..045`); PR **#9** opened into `main`, gated on the real CI (`clone-child-repos.sh` then a 3-OS test matrix + clippy + integration + format) — merge only on green.
- **CONCURRENCY NOTE:** the user's IDE session was committing in parallel (`1072644` combined commit authored user-side, `c8dd01e` lockfile bump, GitToolBox commit in handoff) — **single-writer-per-repo discipline matters; verify state before every git mutation.**

**POLICY (the answer of record, ADR-0001 §3–§5 + R11):**

```text
fresh worktree off origin/develop|main
  -> batch 3-5 tasks/cycle
  -> ONE squash commit per cycle (conventional message + task refs + Co-authored-by)
  -> push branch
  -> PR into trunk (never push trunk)
  -> GitHub-native fail-closed auto-merge on required checks
       (CI + AI gatekeeper as a required status check;
        verdicts out-of-band via permission-ask + ledger event;
        never bot-approve, never override red)
  -> post-merge ff develop, delete branch, recycle worktree, hf handoff + ledger events
```

Protection is enforced **only on weave today**; elsewhere **the agent IS the fail-closed gate by convention** until `HFTASK-0012` lands CI / protection.
**REFERENCES:** `FlexNetOS/weave#61`, `FlexNetOS/handoff#1`, `FlexNetOS/meta#9`, handoff `e47777f`, meta `1072644`/`714abca`, the `hf` ledger checkpoint `HFTASK-0001`.

### 5.4 harness-upgrade-hardening-ultraplan-2026-06-12 — hardened facts (kernel gotchas)

Labels: `type:reference`, `tag:critical`, `session:2026-06-12`, `role:harness`. [confidence: 0.5] — `refines` `envctl-harness-upgrade-2026-06-12` (see [03-envctl-kasetto](./03-envctl-kasetto.md)).

ULTRAPLAN-HARDENED facts for the envctl harness upgrade. **CRITICAL GOTCHAS:**

1. The shipped `hf` (`meta/handoff/hf/src/main.rs`) resolves a **CWD-RELATIVE** `.handoff/ledger.db` — running `hf checkpoint` from the envctl worktree would **CREATE `envctl/.handoff/ledger.db`, violating ADR-0004 single-ledger**; MUST redirect to `$META_ROOT/.handoff/ledger.db` + a fail-closed guard.
2. `hf` packets are **RENDERED** (`hf handoff` → `.handoff/packets/latest.md` = `handoff.packet.v2`, auto-writes `active.md`); the `continuity-steward`'s `.handoff/loop/HANDOFF.md` is a **non-authoritative human companion only**. Precedence: `Git > .handoff/ledger.db > tasks/*.task.json > active.md > packet`.
3. **`hf` VERBS that actually exist:** `init` / `seed` / `status` / `claim` / `checkpoint(--auto/--note)` / `done(--pr)` / `handoff` / `resume(--json)` / `task mint`. **`hf done` is the terminal `Done` transition** (`claim`/`checkpoint` never mark done). **NO `hf drift` / `hf policy`.** The next-task picker = `hf resume --json` `next_task_id` (`next_safe`).
4. **META-CLI CORRECTIONS (verified vs `meta_*` repos):** `meta list-projects --names` does NOT exist → use `meta project list --json`; `meta git worktree list <slug>` takes NO slug → use `meta git worktree status <slug>`. Verified-correct: `meta git worktree create --repo/--all/--ephemeral/--ttl`, `exec --include/--parallel`, `meta --json git worktree exec`, `meta exec -r`, `meta git snapshot create/restore`. `meta_mcp` exposes NO worktree tools (shell to the CLI).
5. **OTHER P0s:** a legacy `_workspace` fallback alias for in-flight successors; `ralph-provision.sh` migrates ALL sites incl. the here-doc prompt; `- [!!]` SUPERVISED items REFUSE auto-run → `NEEDS-HUMAN`; extend `ci/gates/no-c.sh` to grep `mimalloc|libmimalloc-sys`; the agent-env lock = a SEPARATE SHA-256 section, leave `engine/src/lock.rs` FNV-1a untouched.

---

## Cross-references

- **[01-meta-control-plane](./01-meta-control-plane.md)** — `handoff-kernel-relocated-to-meta` is `instance_of` `meta-architecture-canon` (the every-tool-is-its-own-repo convention; `.meta.yaml` + `.gitignore` registration). The `meta git worktree` engine (`meta_git_lib`) is the per-session worktree provider for Handoff Loop v2 pillar 1, and the meta-CLI corrections in §5.4 belong to that plane.
- **[03-envctl-kasetto](./03-envctl-kasetto.md)** — the `Surgical AI gatekeeper` `depends_on` `envctl secrets-engine (relay/broker)`: `broker::decide` is the deterministic default-deny enforcement layer. `kasetto.lock` is an instance of `substrate-committed-files`. `harness-upgrade-hardening-ultraplan-2026-06-12` `refines` `envctl-harness-upgrade-2026-06-12`. The shared grit backend / Phase-8 `secretctl run` data-plane dependency surfaces from the same harness work.
- **[04-weave-coordination](./04-weave-coordination.md)** — `hf claim mesh lease` reserves `weave lease reserve` on `handoff:claim:<task-id>`; `continuity-session-relay` `depends_on` `substrate-weave-mesh`; the `HF_WEAVE_BIN` / stale-binary preflight, the ADR-0002 weave-a2a 5-surface contract, weave Jobs + correlation, and R6 out-of-band verdicts all live here.
- **[05-ruvector-substrate](./05-ruvector-substrate.md)** — the `rvf-crypto` witness crate (`create_witness_chain` / `verify_witness_chain`) is the tamper-evidence backbone of the ledger (`spike-validated-handoff-seam-ledger`, `instance_of` `s1-ruvector-meta-mapping`, `depends_on` `codewalk-rvf-cluster`); the gatekeeper's "full code knowledge" can be grounded in RuVector; RuVector coverage gaps `HFTASK-0017/0018/0019`.
- **[06-cognitive-codewalk](./06-cognitive-codewalk.md)** — `spike-validated-handoff-seam-ledger` `depends_on` `codewalk-rvf-cluster`; the gatekeeper's `git kb` / `kb_callers` / `kb_impact` full-blast-radius grounding is the codewalk capability.
- **[07-frontdoor-integration](./07-frontdoor-integration.md)** — `Front door + Mission Control + Delivery` defines RuVocal + prompt_hub as the INPUT surface and the witnessed ledger as the OBSERVE read-model; `spike-validated-handoff-seam-ledger` is `related_to` `frontdoor-mapping-ruvocal-prompthub`; the `SwarmBundle` → `handoff.task.v1` seam, `HFTASK-0019`/`0020`/`0021`/`0022` originate here.
- **[08-gaps-seams-merge](./08-gaps-seams-merge.md)** — `substrate-committed-files` is `related_to` `gap-multiple-task-truths` (the spike's `correlation_id` closes gap#1 task-truth + gap#3 contract); `loop-e2e-proof-2026-06-12` and `ship-loop-proof-2026-06-12` both `refine` `seam-spec-weave-a2a-2026-06-11`; ship-loop also `refines` `adr-2026-06-11-open-questions`; the `gh-aw separation-of-privilege gate` is the merge-seam guardrail.
