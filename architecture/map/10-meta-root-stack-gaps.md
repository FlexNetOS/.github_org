# 10 — Meta-Root Stack-Integration, Gaps & Session State

This document folds the **authoritative meta-root planning/status docs** (`STACK-INTEGRATION-PLANS.md`, `GAP-REGISTER.md`, `NORTH-STAR.md`, `SESSION-HANDOFF.md`, `NEEDS-HUMAN.md` — all at `~/Desktop/meta/`) into the ICM-derived map. Where [`map/02`](./02-handoff-continuity.md), [`map/07`](./07-frontdoor-integration.md), and [`map/08`](./08-gaps-seams-merge.md) render the *memoir's* view of the continuity kernel, the front door, and the gaps, these docs supply the **owner-ratified vision** (NORTH-STAR), the **chosen connectors to build** (STACK-INTEGRATION-PLANS), the **15-item code-scored gap register** (GAP-REGISTER), the **latest session checkpoint** (SESSION-HANDOFF), and the **live human-required queue** (NEEDS-HUMAN). They are authoritative *prose*, so the standing law applies — **code is truth; docs are untrusted prose** — and any doc-vs-code contradiction is flagged inline.

> Provenance: STACK-INTEGRATION-PLANS authored 2026-06-09; GAP-REGISTER scored 2026-06-12; NORTH-STAR v2 2026-06-13; SESSION-HANDOFF session 6 closed 2026-06-13; NEEDS-HUMAN refreshed 2026-06-12 late evening. These are newer than the ICM memoir export this map's `01..08` were rendered from, so they **update** several map claims (see "Reconciliation" below).

---

## NORTH-STAR.md — the durable vision (steward's compass)

`NORTH-STAR.md` is **v2 (2026-06-13)** — the document the steward (ADR-0005) reasons against; *"It changes only by owner intent — never silently."* Its sharpening over v1 (distilled 2026-06-12 from the 15-item vision register, memoir laws, and the proven loop) is the reframing of `NEEDS-HUMAN` from a permanent wall into a **scaffold** to be replaced by a model carrying the human's skillset.

**The North Star:** a **multi-provider, multi-model agentic system that runs on full autopilot, end to end.** A single person states a direction; the system designs → builds → proves → ships → operates → improves itself across as many ventures as that person directs. Every place a human was once required (reviewer, operator, specialist, approver) is **filled by a model carrying that human's skillset**. The destination is a **single-person conglomerate** — one director, many businesses, all built and managed by the system.

**The six tenets:** (1) multi-provider, model-agnostic — `envctl` injects whatever credentials a model needs on demand; (2) end-to-end autopilot — synthesize → plan → build → verify → review → ship → operate → learn, witnessed at every step, fail-closed at every gate; (3) `NEEDS-HUMAN` is a scaffold, not a feature; (4) direction in, system builds; (5) co-learning and self-upgrading — the loop improves the loop (ICM/memoir); (6) the single-person conglomerate.

**The destination state (verbatim shape):**

```text
prompt_hub (front door) turns intent into handoff.task.v1 envelopes
  -> hf claims with weave leases, works in fresh worktrees,
     checkpoints into the witnessed fleet ledger
  -> PRs gate on real CI plus a code-omniscient AI gatekeeper
     (a required status check, never a bot-approve)
  -> GitHub-native auto-merge lands green work
  -> vox speaks milestones, ICM remembers, kb holds the plans,
     n8n shows the map, the Cognitum Seed hardware-anchors witness chains
```

`RuVector` is the agentic OS this rides on; `teri`+`shimmy` give it a swarm-prediction engine; `lane`+`obscura` give it the network and the web; `kasetto`+`envctl` give every agent its environment and model credentials. Beyond *shipping* code the system **operates** what it ships.

**`NEEDS-HUMAN` as a scaffold — the demolition plan** (four wall-classes, each with the capability to build):

| Wall (escalates today) | Replaced by | Capability to build |
|---|---|---|
| Account / billing / auth | account-operations model + `envctl` credential injection | a model that holds/uses accounts safely, secrets auto-injected on demand |
| Scope expansion | planning model under an owner-ratified scope policy | widens scope within owner-set bounds, escalates only a *change of intent* |
| Irreversible action | a verification model that earns trust to proceed | provable pre-checks + reversible staging |
| Physical-world action | remote-hands / robotics, or the honest residual | the one class that may legitimately remain |

**The ten laws (non-negotiable):** (1) code is truth — *RuVector/ruflo docs are traps*; (2) adopt-then-extend, never downgrade; (3) never destroy work (no reset --hard / clean -fd / force-push / history rewrites; snapshot before batches); (4) **state precedence: Git > witnessed ledger > task cards > ADRs > narrative**; (5) worktrees for all changes; (6) fail-closed merges (green required checks + native auto-merge; never merge red; never bot-approve); (7) genuine org forks only, pin-branch records intentional drift, never pull ruvector/ruflo toward upstream; (8) no unrequested org infra/visibility changes (*the 2026-06 private-flip broke CI for 8 days*); (9) plan in kb, execute in `.handoff` (ADR-0003); (10) memory is mandatory (icm/memoir/capsules).

**Build-order law (verbatim):** `kasetto preflight → weave a2a conventions → front-door dispatch (HFTASK-0003/0019) → reviewer/gatekeeper (0010) → batch verbs (0008/0009) → RuVocal LAST (0022)`.

**The steward's rubric + scope law:** decide autonomously on reversible repo-scoped changes via the proven loop; escalate physical-world / account-billing-auth / irreversible deletion / visibility / mass-mutation-across-third-party-forks. **Scope law (learned 2026-06-12, two classifier denials):** a steward verdict authorizes sequencing *within* an explicitly granted scope — it can never *expand* scope. One denial → narrow once and retry; second denial → escalate verbatim. **Permanent (never delegated):** anything that changes *this document* or the *intent* of the work.

---

## STACK-INTEGRATION-PLANS.md — three plans (pre-implementation)

Authored **2026-06-09**, companion to the ICM memoir `system-architecture`. **Status: planning only — do not implement until a plan is chosen.** This is the doc that names the **connectors/seams to build** for autonomy.

**Ground truth restated:** the stack is **not a pipeline** — independent, mostly-Rust tools integrating only through two substrates: the **weave mesh** (live coordination) and **committed files on disk** (durable truth). No tool calls another in code today. The completion-state table (evidence-based):

| Tool | State | Build contracts against it? |
|---|---|---|
| kasetto | ~95%, v3.0.0, production | yes — most-done |
| weave v0.2 **core** | done + 38 tests | yes |
| weave **autonomous dispatch** | does not exist (poll-only; JobRunner deferred) | no |
| prompt_hub **core** | ~85%, 724 tests | yes |
| prompt_hub **dispatch** | SwarmBundle struct has zero outbound wiring | must build |
| obscura | complete Rust headless browser + obscura-mcp | ready (unwired) |
| envctl env-manager (ph 0–5) | ~90% | yes |
| envctl secrets daemon (ph 6–8) | ~30%, 15+ `todo!()`, server-mode CRITICAL | no |
| rusty-idd | ~85% (real repo: `~/Desktop/idd-merge-idd`) | mostly |
| n8n-loop harness | ~60%, no proven end-to-end cycle | unproven |

**The real blocker (autonomy unlock) — three missing connectors that live in the gaps:** (1) **prompt_hub → dispatch**: no `export` from `SwarmBundle` to anything actionable; (2) **weave → autonomous run**: jobs are poll-only, no JobRunner that claims + spawns; (3) **the contract**: no work-order envelope spanning `prompt_hub → rusty-idd → weave → agent`. Autonomy *already exists* via the file-based **session-relay loop** — **every plan must integrate with the existing loop, not replace it.**

**Plan A — Contract-first.** Define ONE Work-Order Envelope (WOE) and retrofit every tool. Proposed envelope:

```jsonc
{
  "woe_version": 1,
  "id": "woe_<ulid>",
  "intent": "natural-language ask",
  "role": "rust-implementer",            // maps to prompt_hub Role
  "origin": "prompt_hub|n8n|cron|meta",  // which door minted it
  "plan_ref": "idd:AI_MERGE/07_tasks/..",
  "weave_job_id": "job_...",             // coordination handle
  "acceptance": ["criterion", "..."],
  "guards": { "budget_usd": 5.0, "rbac_role": "...", "apply_mode": true },
  "state": "draft|queued|running|done|failed|needs-human",
  "artifacts": [{ "kind": "pr", "ref": "..." }],
  "handoff_ref": "_workspace/HANDOFF.md#next_item"
}
```

Sequence: ship a tiny shared Rust crate `work_order` → prompt_hub `export_work_order()` → weave ingests WOE as a `Job` (`correlation_id` = WOE id) → rusty-idd emits a WOE per task → the session-relay loop reads/writes WOE state. Pros: every future seam trivial. Cons: slowest to first value; touches every repo.

**Plan B — Source-of-truth-first.** Crown weave `jobs` as the single authoritative task store; everything syncs to it via `correlation_id`. weave `Job` already has `state`, `attempt_id` fencing, `correlation_id`, `result_json`, `artifacts_json`, cooperative cancel. Pros: fastest route to "agents agree on what's done" — attacks the highest-leverage gap (#1). Cons: weave has no autonomous dispatch, so **the loop stays the runner** (fine — current reality).

**Plan C — Front-door-first.** Make prompt_hub the single canonical intake; other doors become thin shims. Sequence: build prompt_hub's missing outbound (`SwarmBundle → weave Job(s)`) → point n8n/cron/`meta` at `/vibe` → demote `/prompt-loop` + direct `weave job_create` to shims. Pros: gives prompt_hub its missing role. Cons: requires the prompt_hub→weave seam anyway.

**Recommendation (the chosen path):** *"Start with B's spine using A's envelope, and C falls out."* (1) ship the tiny `work_order` envelope; (2) carry it as a **weave Job** and make weave Jobs the source of truth; (3) build the two missing connectors — `prompt_hub → WOE → weave Job` (which also makes prompt_hub canonical — C for free) and teach the **session-relay loop** to read/write WOE state on Jobs; (4) **defer** weave's JobRunner and obscura wiring — *the loop is the runner.*

**Open decisions before implementation (verbatim):** authoritative store (weave Jobs recommended); envelope home (`work_order` crate vs extend weave `Job`); loop integration (loop polls Jobs vs weave notifies loop); v1 scope (which end-to-end path to prove first).

**Research Log Round 2 (2026-06-09):** provisional user decisions — source-of-truth = weave Jobs is the easy first pick (confirm only after research rules out missed pieces); envelope home decided after a spike; v1 scope = smallest/simplest upgrade first. Notes the **meta architecture canon** (10 originals + compliance rules), the **envctl merge** (env-ctl name to retire → `secretd`/`secrets`; no `.kb/`; poor handoff), and the **new handoff package** at `~/Downloads/tmp/handoff` ("Ark Handoff Ledger PRD V2", **spec only, 0% code**, 12-crate design; rename: drop "Ark" + "V2"). Next research task (deferred): **ruvector / ruflo**.

---

## GAP-REGISTER.md — the 15-item vision register, scored from code (2026-06-12)

**Contract:** nothing closes without evidence (file/commit/API output). Verdicts: DONE / PARTIAL / GAP / DESIGN-OPEN. Inputs: `ARCHITECTURE-TRUTH.md` (62-unit census), `VERIFICATION-REPORT.md`, memoir, census workflow `wf_a40b236a`. The 15 items and their verdicts:

1. **Architecture/history truth; repo roles; kb↔handoff fit** — DONE (this session). Freeze seam in **ADR-0003**; build n8n visual map. (P2 done; ADR-0003 → P4)
2. **Every repo hosts `.handoff` + policy; loop_lib autonomous upgrades** — **total GAP**: `.handoff/` in exactly **1/58** repos; loop-state convention split `_workspace/` vs `.handoff/` vs ad-hoc; POLICY v2 has no continuity layer. → **ADR-0004** (per-repo layout + sync) → policy **P7** → tiered rollout incl. loop_lib. (P4)
3. **kasetto + envctl = env control** — PARTIAL: seam LIVE one-way (`agent-env.toml` ↔ `kasetto sync --locked` CI gate). → ADR the split; sync fork 3.0.0→3.1.0; rename `env_manager_agent`→kasetto (NEEDS-HUMAN #6). (W1)
4. **lane = network engineering/control; obscura = its upgrade** — PARTIAL: lane active (TLS reverse proxy); obscura = Rust headless browser (V8/CDP, 7 crates), **pure mirror, zero integration**; **lane relay (cross-machine) still unfinished — standing wall**. (W2)
5. **weave = a2a + session-to-session** — PARTIAL→DONE: **ADR-0002** five-surface contract PROVEN in production (handoff PR#3/#4, leases/jobs/verdicts). Extend session-to-session continuity (`hf session` verb **HFTASK-0007** is the consumer). (W3)
6. **MiroFish full-feature Rust port; teri/shimmy** — PARTIAL foundation confirmed: **teri IS a MiroFish rewrite** (census-independent); shimmy = the Ollama slot. → feature-parity matrix; **teri = the vehicle** (extend, never port fresh). (W4)
7. **Archon = harness-builder agent** — GAP: Archon = pure tracking fork (zero FlexNetOS commits, stale `harness-upgrade` branch 24-behind). → bring-up plan as harness-builder over harness_hub. (W5)
8. **Harness repo census** — DONE: 10 harness-plane repos censused. (W5)
9. **rusty-idd = IDD end-to-end** — PARTIAL: control plane built+active (25 ralph cycles); missing `scripts/ralph-idd.sh`; **no intent→delivery e2e proof yet**. (W6)
10. **prompt_hub = ruvector/ui front door for non-technical users** — **GAP at the seam**: core healthy (3 crates, **1085 tests**, loop coherent at cycle 82) but **zero MCP server + zero outbound dispatch** — both sides of the front-door seam unbuilt. → **HFTASK-0003** (Intent→envelope synthesis — THE crux) + **HFTASK-0019** (transport ADR); RuVocal stays LAST (**0022**). (W7)
11. **Is ruvector (all-crates) integrated?** — **honest GAP**: 314/314 mapped; adopted = **`rvf-crypto` only** (handoff ledger path-dep — the single live code edge). (W8)
12. **Launch ruvector UI; fix broken loop harnesses** — GAP + corrected premise: no UI surfaces loop state; "broken harnesses" mostly FALSE (weave/lane/rusty-idd closed legitimately; real issues = handoff's stale cards D3, prompt_hub drift D5, lifeos dead paths D9). (W7 + P4)
13. **Per-repo `.handoff` ↔ central handoff sync** — DESIGN-OPEN: zero implementations; **ADR-0004** settles per-repo contents + aggregation. (P4)
14. **Replace the NEEDS-HUMAN human with a steward agent** — DESIGN-READY: approvals → code-omniscient AI gatekeeper; NEEDS-HUMAN = 7 items + 3 standing walls, **0/7 actioned by human**. → **NORTH-STAR.md + ADR-0005 + steward definition**. (P6)
15. **envctl secret injection/relay + COGNITUM seed setup** — PARTIAL **unblocked today**: COGNITUM mounted+readable (`/run/media/drdave/COGNITUM`); envctl secretd 1–5 sanctioned. (W1)

**Census defects → owners (D1–D12):** D1 (claude-plugins dead gitkb), D2 (vault_hub vendored kasetto), D3 (handoff 22 stale cards → `hf checkpoint --sync-cards`), D10 (teri stale docs), D12 (shimmy boot-banner) all **RESOLVED**; D4 (12 husk repos → NEEDS-HUMAN #5), D5 (prompt_hub identity drift — main CI greened via **prompt_hub#78**, rename still W7), D11 (harness_hub misattribution → W5) remaining.

**W8 RuVector scoreboard (item 11's evidence):** **rvf-crypto = INTEGRATED** (the only live code edge, handoff/ledger path-dep); planned on carded tasks — RVF ledger v2 (HFTASK-0006), cognitum-gate (HFTASK-0017), AgentContract (HFTASK-0004), domain-expansion routing (HFTASK-0018), RuVocal (HFTASK-0022, LAST). **Honest answer: 1 family of ~12 integrated.**

**Sequencing verdict:** (1) **P4** fleet `.handoff` → (2) **W1** env-control+COGNITUM ‖ **W4** MiroFish parity → (3) **W7** front-door seam (HFTASK-0003/0019, the P0 cruxes) with **W3** weave re-verify as substrate → (4) **P6** steward → (5) W2/W5/W6/W8 behind; **RuVocal (0022) LAST**.

---

## SESSION-HANDOFF.md — the latest checkpoint (session 6, FIX-MISSION)

`closed_utc: 2026-06-13` (session 6 — FIX-MISSION; began Fable 5, continued Opus 4.8 after Fable outage). `authoritative_memory`: ICM `context-meta` 01KV03Z2R1… (FIX-MISSION COMPLETE) + the witnessed fleet ledger. `resume_point`: `/resume` (hf resume packet) → confirm prompt_hub#77 merged → then the owner queue + next tranche.

**Session 6 (FIX-MISSION) — all six FIX tasks shipped via the proven loop** (worktree → PR → witnessed checkpoint → native auto-merge):
- **FIX-1 teri** (`teri#3`, merged): clap parses before config (`--help`/`--version` keyless); missing-key error states the **envctl injection contract** (vault-held key, child-env only — never raw `export`); new `src/preflight.rs` refuses stub/canned backends; 152 tests.
- **FIX-2 resume count** (`handoff#10`): `hf resume --json` recomputes live (237/238 == ledger truth; root cause = stale-packet echo).
- **FIX-3 kernel verbs** (`handoff#11`): `hf task mint --from-kb`, `checkpoint --sync-cards` (D3: 6 cards → done), terminal `hf done`.
- **FIX-4 kb silent drop** (`meta#21`): root cause = git-kb 0.2.10 reads `.kb/workspaces/main/` while docs said `.kb/workspace/`; backfilled 4 dropped docs; re-pointed `.kb/AGENTS.md` + `.claude/skills/gitkb`.
- **FIX-5 small PRs**: `claude-plugins#1` (marketplace → FlexNetOS/meta), `vault_hub#2` (de-vendor kasetto), `shimmy#5` (serve banner = true post-discovery count).
- **FIX-6 enforcement kit** (`meta#20` + `agent#2` + `harness_hub#2`, LIVE): `/handoff /resume /mint /checkpoint /fleet`; skills `handoff-discipline` + `verifier-cli`; `handoff-steward` agent; Stop/PreCompact `hf` hooks; **agent-guard `[[file_patterns]]`** denying new `*HANDOFF*/*-PROMPT*.md` outside `.handoff/`; `p7-conformance.yml` CI.

**Four stuck P7 seed PRs** (`meta#15`, `atc#2`, `rusty-idd#39`) all merged. **prompt_hub#77** was blocked by prompt_hub's own pre-existing red `main` CI → **prompt_hub#78** greens main, unblocking #77 + the dependabot stack #63–76.

**New owner-queue items (added to NEEDS-HUMAN.md):** **D** — two `.claude/settings.json` hook entries (PreToolUse `Write|Edit` guard + SessionStart `hf-resume.sh`); **E** — FlexNetOS fork of `gitkb/gitkb-claude-plugin`.

**Earlier sessions (carried in the same file):** session 5 (portability mission, ADR-0006/0007/0008 — envctl = box materializer; 40 symlinks now point into meta; `repowire` incident → unit disabled); session 5 upgrade mission (ARCHITECTURE-TRUTH/GAP-REGISTER/NORTH-STAR/ADR-0003/0004/0005, 21/21 A/B repos P7-seeded); session 4 (adversarial verification, all clusters PASS); session 3 (autonomous loop e2e proven, ADR-0002); session 2 (RuVector→meta foundation, spike promoted into `~/Desktop/meta/handoff`).

**Method rules (carried):** code is truth, recall → VERIFY → act; worktrees for all changes; archive-first for $HOME mutations; never downgrade (version guard); **no subagents in RuVector/ruflo/envctl**; `systemctl --user disable` deletes symlinked units (disable first, link after); rtk hook rewrites bare `cargo`/`grep`/`curl` → use `rtk proxy <cmd>` for raw output; single-writer-per-repo (re-verify `git log` HEAD after pulls).

> **HFTASK readiness queue (from the resume blocks):** `HFTASK-0007` (P0: `hf session start|end` + `kasetto sync --locked` preflight + session-ledger location) → `HFTASK-0003 + 0019` (P0/P1: Intent→envelope synthesis + MCP-vs-HTTP transport ADR) → `HFTASK-0010` (separate-role reviewer + gatekeeper as required check) → `HFTASK-0008/0009` (branch/remote policy engine; `--batch N` + cycle counter) → **RuVocal (0022) LAST**.

---

## NEEDS-HUMAN.md — the live human-required queue (refreshed 2026-06-12 late evening)

Per **ADR-0005 (needs-human steward)**, split into *owner decisions* (steward-escalated under the scope law — one approval each unlocks autonomous execution) and *genuine walls*. Original 7-item queue status at refresh: **0/7 actioned**.

**Owner decisions (steward-escalated):**
- **A. P7 `.handoff` stub batches** (classifier-blocked twice → scope law): 21 A/B repos seeded; two remaining batches need explicit scope grant — `bash /tmp/p7drive.sh` (11 org-owned hubs) and optional third-party fork stubs.
- **B. Cognitum Seed — replug into a data-capable USB-C port.** Mass storage reads but the USB-Ethernet gadget never enumerates. Unlocks 114-tool MCP + hardware witness anchoring + custody-signed packets.
- **C. meta dependabot alerts** (8 on main: 1 high, 5 moderate, 2 low).
- **D. Two `settings.json` hook entries** (classifier-blocked): PreToolUse `Write|Edit` guard activation + SessionStart `hf-resume.sh`. Both scripts ship inert; these two lines are the on-switch.
- **E. Fork `gitkb/gitkb-claude-plugin` into FlexNetOS** (org infra, classifier-blocked). Related: the `~/.local/bin/git-kb` 78MB copy is unpinned with no source checkout.

**Genuine walls (8):** (1) delete auto-suffix fork artifacts `shimmy-1`/`teri-1` (irreversible deletion); (2) org-secrets listing + **`PARENT_REPO_PAT` grant to the parent repo** — hard evidence (run 27439121673): the secret resolves **empty inside meta's own workflows**, so release PRs cannot pass required checks / auto-merge until the grant lands; (3) `meta_dashboard_cli` / `meta-plugins` visibility; (4) `meta_plugin_api` disposition (archive preferred); (5) unregistered org repos (`harness`, `slim`, `global_projects_config`, `demo-repository`); (6) optional rename `env_manager_agent` → `kasetto`; (7) atc workflow-approval gating (`action_required` blocks autonomy on atc); (8) `.github` repo P7 stub (needs 1 human review — bot approval forbidden by design).

**Standing hardware/network walls:** lane relay unfinished → cross-machine paths unreliable; envctl vault gated by its separate USB secret-key device (distinct from the Seed); Cognitum storage readable, only the data-port replug remains.

**flexnetos app/runner mission (ADR-0007/0008):** **G** — create the GitHub App (least-privilege: Checks write, Contents read, PRs read/write, Metadata read; webhook events `pull_request`/`push`/`check_suite`); **H** — archive the now-empty `flexnetos_secrets` repo (retired per ADR-0007); **I** — visibility RESOLVED (`flexnetos_github_app` flipped public via `gh api -X PATCH ... -f visibility=public`).

---

## Reconciliation with the ICM map

Where these meta-root docs **confirm**, **update**, or **contradict** [`map/02`](./02-handoff-continuity.md), [`map/07`](./07-frontdoor-integration.md), and [`map/08`](./08-gaps-seams-merge.md):

**CONFIRM:**
- **The three missing connectors** (STACK-INTEGRATION-PLANS "real blocker"; A.1 `critical-missing-seams`) match `map/08 §A.1` verbatim — prompt_hub outbound dispatch, weave JobRunner (deferred), the work-order contract. Confirmed.
- **The five competing task truths** (Plan B/`map/08 §A.2 gap-multiple-task-truths`) and the **source-of-truth hierarchy** (NORTH-STAR law 4 = `map/00`/`map/02 L2.2`/`map/08 L8.5`) — Git > witnessed ledger > task cards > ADRs > narrative; weave Jobs = a coordination *view*. Confirmed.
- **Roles locked** (NORTH-STAR destination; `map/07 L7.2`): prompt_hub = single canonical intake, RuVocal = primary human UI, CLI/n8n/meta = thin shims (Plan C). Confirmed.
- **Fail-closed, GitHub-native auto-merge; ADR-0002 weave a2a; ADR-0001 ship policy** (NORTH-STAR law 6, build-order law; `map/02 §5`, `map/08 B.2`). Confirmed, with GAP-REGISTER item 5 upgrading ADR-0002 to **PROVEN in production**.
- **The dead-end zellij dashboard** (`map/02 L2.9`/`map/07 §1`) — NORTH-STAR/the docs do not revive it; the front door is prompt_hub + RuVocal.

**UPDATE (these docs are newer than the memoir export):**
- **prompt_hub test count / loop cycle:** `map/07` renders 1085 tests at cycle 80–83; the docs add that the **construction loop FINISHED its backlog (2026-06-13), shipping PRs #94–#106**, and **prompt_hub#78 greened main** (unblocking #77 + dependabot #63–76). Material to `map/07 Q7.5` — file:line seam refs (`models.rs:528+547`, `server.rs:38-95`) **must be re-validated against current HEAD**.
- **`.handoff` fleet rollout:** GAP-REGISTER item 2 (`.handoff/` in 1/58 repos) + SESSION-HANDOFF (**21/21 A/B repos seeded**, prompt_hub adopted the full kernel via its own PRs #82/#83 — *member rule: NO local `ledger.db`, events go to the FLEET ledger `meta/.handoff`*) advance `map/02`'s single-repo kernel into a fleet-wide rollout under **ADR-0004 single-ledger**.
- **NEEDS-HUMAN reframed:** NORTH-STAR v2 turns `map/08`'s "hard walls" into **temporary scaffolds with demolition plans** (steward replaces the human). The walls remain real *today* but are no longer presented as permanent.
- **kernel verbs:** the docs confirm the shipped `hf` verb set (`init/seed/status/claim/checkpoint/done/handoff/resume/task mint`; **no `hf drift`/`hf policy`**) over the spec-only 12-crate Ark design — consistent with `map/02 L2.5`, now with `checkpoint --sync-cards` + terminal `hf done` shipped.

**CONTRADICT / FLAG (code-is-truth):**
- **Plan B "crown weave Jobs as the single authoritative task store"** contradicts the **locked source-of-truth hierarchy** (NORTH-STAR law 4; `map/00`/`map/02 L2.2`) where weave Jobs are explicitly a *view, never the crowned source of truth*. **Resolution:** STACK-INTEGRATION-PLANS is dated 2026-06-09 *planning*; the later locked decision (also 2026-06-09, `decision-log` body governs per `map/01 L1.6`) supersedes Plan B's literal framing — weave Jobs carry the WOE as a **coordination view** synced by `correlation_id`, not the crowned truth. The Plan B *spine* (sync via `correlation_id`) survives; its *crowning* language does not.
- **rusty-idd repo path:** STACK-INTEGRATION-PLANS lists the "real repo" as `~/Desktop/idd-merge-idd`, while `map/08 B.2` and the canon name it `FlexNetOS/rusty-idd` at `~/Desktop/meta/rusty-idd`. Treat the canonical published repo as authoritative; the `~/Desktop/idd-merge-idd` path is a stale local-checkout reference.
- **prompt_hub "dispatch IS NOW BEING BUILT"** (`map/07 §2.2`, 5+ `dispatch` hits) vs **"zero outbound dispatch"** (GAP-REGISTER item 10, re-confirmed by census). Code-is-truth: the `dispatch` *string hits* exist but **no production seam** does — `work_orders_from_bundle` is test-only mirror code (`map/02 L2.6`). The gap stands until HFTASK-0003/0019 land.

---

## Answers to open/partial map questions

Each cites the doc + section; verdict reflects what the authoritative docs resolve vs. what remains code-open.

**Q2.2 — Ledger location (worktree ledger vs ADR-0004 single-ledger); was HFTASK-0007 decided?** — **PARTIAL.** ADR-0004 single-ledger is **policy**: member repos have **NO local `ledger.db`** — their events go to the **FLEET ledger `meta/.handoff`** (SESSION-HANDOFF, prompt_hub member rule; GAP-REGISTER item 2/13). The `map/02 §5.4` hazard is real and now guarded — a member running `hf checkpoint` from its own worktree must redirect to `$META_ROOT/.handoff/ledger.db`. **But HFTASK-0007 itself (the `hf session start|end` verb that owns the session-ledger-location design point) is NOT yet built** — it sits at the head of the readiness queue (SESSION-HANDOFF resume blocks: "P0: session-ledger location"). So the *policy* is resolved (single fleet ledger, ADR-0004), the *session-verb implementation* that operationalizes it is still open. (Source: SESSION-HANDOFF §RESUME/REMAINING; GAP-REGISTER items 2/13.)

**Q2.3 / Q7.1 / Q7.2 — The SwarmBundle→handoff.task.v1 front-door seam (MCP server HFTASK-0019; /vibe Intent synthesis HFTASK-0003); is the spike a path to production?** — **OPEN-confirmed (the gap stands).** GAP-REGISTER item 10 scores prompt_hub a **GAP at the seam**: *"zero MCP server + zero outbound dispatch — both sides of the front-door seam unbuilt."* HFTASK-0019 (transport ADR: MCP-vs-HTTP) and HFTASK-0003 (Intent→envelope synthesis — "THE crux") are both **carded but unbuilt**, sitting at P0/P1 in the readiness queue (SESSION-HANDOFF; build-order law: front-door dispatch is gated behind kasetto preflight + weave a2a conventions). The validated spike (`map/02 §2.2`) is a **design proof, not production** — `work_orders_from_bundle` is test-only mirror code never in the `hf` bin; HFTASK-0003/0019 must implement it for real. (Source: GAP-REGISTER item 10; SESSION-HANDOFF readiness queue; NORTH-STAR build-order law.)

**Q4.4 / Q8.6 (CRITICAL) — Have the autonomous-loop / session-relay hooks been migrated off the RETIRED weave-repowire predecessors and scoped out of subagent/headless contexts?** — **PARTIAL.** Partially addressed, not fully closed. SESSION-HANDOFF session 5 records a **`repowire` incident** (`incidents/repowire-unit-crash-loop`): the unit crash-looped on a missing binary → **disabled (reversible)**, owner questions filed. The earlier 2026-06-09 anchor (`map/02 §5.1`) records OPTION 1 COMPLETE: settings.json hooks repointed off `weave-mcp-daemon-tools` → `~/.cargo/bin/weave` and **all retired repowire hooks neutered → `true`**. But: (a) NEEDS-HUMAN item **D** shows the FIX-6 lifecycle hooks (`Write|Edit` guard + SessionStart resume) are **still owner-gated and not yet activated** (classifier-blocked); (b) the method rule **"no subagents in RuVector/ruflo/envctl"** (SESSION-HANDOFF, every session) is the *operational workaround*, confirming the hooks are not yet safely scoped for subagent/headless contexts. So the retired-binary references are neutered/disabled but the **clean migration + scoping into the lifecycle is owner-gated and incomplete**. (Source: SESSION-HANDOFF session 5 repowire incident + session 6 NEEDS-HUMAN D; method rules.)

**Q4.6 — rvAgent⇄weave bridge + N-reviewers→one-verdict reducer (R5); still open? hf still the sole junction?** — **OPEN-confirmed.** GAP-REGISTER W8 scoreboard lists `rvAgent / a2a-swarm` as **planned** (open-q #3 bridge; verdict reducer = open-q #4), with **"ADR-0002 keeps hf as junction."** Nothing in these docs builds the bridge or the reducer. `hf` remains the sole junction between weave (meta-local mesh) and the rvAgent A2A substrate (consistent with `map/00`/`map/05 L5.5`). (Source: GAP-REGISTER W8 scoreboard, rvAgent row.)

**Q8.3 / Q8.4 — The single work-order envelope schema (with weave Job.correlation_id) + the three autonomy connectors (prompt_hub export_to_weave, weave JobRunner, work-order contract) — who/what/when?** — **PARTIAL (designed + sequenced, not built).** The **schema is authored** — STACK-INTEGRATION-PLANS Plan A specifies the WOE (`woe_version`, `id`, `intent`, `role`, `origin`, `plan_ref`, `weave_job_id`, `acceptance`, `guards`, `state`, `artifacts`, `handoff_ref`) and the spike's `handoff.task.v1` envelope (`map/02 §2.2`) is its validated form, carrying `workflow_id` as `correlation_id`. The **chosen plan is recorded**: "B's spine using A's envelope, C falls out" — ship the `work_order` crate, carry it as a weave Job synced by `correlation_id`, build `prompt_hub → WOE → weave Job` + teach the session-relay loop, **defer weave's JobRunner** (the loop is the runner). **Who/when:** owned by **HFTASK-0003/0019** (the front-door cruxes, P0/P1) gated behind kasetto preflight + weave a2a per the build-order law; sequenced as **W7** (with W3 weave re-verify) in GAP-REGISTER step 3. **Not yet built.** (Source: STACK-INTEGRATION-PLANS Plan A + Recommendation; GAP-REGISTER sequencing verdict step 3; NORTH-STAR build-order law.)

**Q8.7 — The duplicate `run:` key in promote-verify.yml — fixed?** — **OPEN-confirmed (no evidence of a fix).** None of the five meta-root docs records a fix for the verified duplicate `run:` key in `promote-verify.yml` (`map/08 B.2`: "second wins"). GAP-REGISTER item 9 (rusty-idd) lists open rusty-idd debts (missing `scripts/ralph-idd.sh`, stale NEEDS-HUMAN/HANDOFF docs, seam ADR, no e2e proof) but does **not** mention the promote-verify duplicate-key fix. Absent positive evidence, treat it as still open. (Source: GAP-REGISTER item 9; no fix reference in any of the five docs.)

---

## Cross-references

- [`../map/00-overview.md`](./00-overview.md) — the one-screen model; the two-substrate truth, the source-of-truth hierarchy, and the autonomy-loop diagram these docs operationalize.
- [`../map/02-handoff-continuity.md`](./02-handoff-continuity.md) — the `hf` Continuity Ledger Kernel, the spike-validated `SwarmBundle → handoff.task.v1` seam, the ship policy, and the §5.4 single-ledger hazard that ADR-0004 (here) resolves into a fleet rule.
- [`../map/07-frontdoor-integration.md`](./07-frontdoor-integration.md) — prompt_hub + RuVocal as the front door; the seam contract and HFTASK-0003/0019/0020/0021/0022 these docs sequence and (partly) supersede with newer construction-loop state.
- [`../map/08-gaps-seams-merge.md`](./08-gaps-seams-merge.md) — the three missing connectors, the five competing task truths, the hardware/network walls, and the rusty-idd merge model that STACK-INTEGRATION-PLANS, GAP-REGISTER, and NEEDS-HUMAN render as owner-ratified plans and a live queue.
