# QUESTIONS & LESSONS — architecture reconciliation ledger

This is the **reconciliation ledger** for the `architecture/` map. It has exactly two sections:

- **Section 1 — Questions:** every misalignment, contradiction, ambiguity, or low-confidence
  claim found while ingesting the ICM `system-architecture` memoir (`architecture/icm/`) into
  the synthesized map (`architecture/map/`), and while walking the meta-root docs and `meta*`
  repos. These are **not** asked of the owner — they are answered by searching the codebase.
- **Section 2 — Lessons:** the confirmed ground truths carried forward, **including the answers**
  to Section-1 questions once found in the code/docs.

Each question has a status: `OPEN`, `ANSWERED → Lnn`, or `PARTIAL`. When a question is answered,
the answer is written as a Lesson and the question is cross-linked. Questions/Lessons are grouped
by the eight subsystem maps. Source: ingested 2026-06-13 from ICM (123 concepts, 218 links, 69
memory topics) + the parallel synthesis of `architecture/map/01..08`. **Section-1 question statuses
are updated authoritatively in the [Addendum (2026-06-13)](#addendum--resolutions--new-questions-from-the-meta-root-docs--meta-repo-walk-2026-06-13)
at the end** — it folds in the meta-root docs (maps 09–11) and the `meta*` repo walk (map 12), with
many answers verified against live code.

> Calibration note carried from ingestion: in `system-architecture.graph.json` nearly every
> concept carries a uniform export-default `confidence: 0.5` (0.6/0.8 for a few). That blanket
> number is **extraction** confidence, not per-claim fact confidence. The real signal is each
> concept's `status:` label (`verified` / `decided` / `user-stated` / `provisional` / `blocking`).
> Questions below privilege the `status:` label and flag genuinely uncertain claims.

---

## Section 1 — Questions

### 1.1 Meta control-plane (`map/01-meta-control-plane.md`)

- **Q1.1** `decision-log-2026-06-09` is labelled `status:provisional` yet its body says
  "Supersedes the provisional version" and "DECISIONS (LOCKED 2026-06-09)" — which is
  authoritative, the label or the body? — **ANSWERED → L1.6**
- **Q1.2** Branch protection scope conflict: the `FlexNetOS branch/CI-CD model` and `policy-v2`
  concepts say only `weave/master` is protected fleet-wide, but `org-audit-results-2026-06-12`
  corrects this to **3** protected repos (`.github/main`, `lane/main`, `weave/master`). Should
  the earlier concepts be annotated as superseded? — **ANSWERED → L1.7**
- **Q1.3** The 2026-06-13 `decisions-meta` memory mandates every repo get a `develop` branch +
  protected `main`/`master` mirror (create-if-missing), contradicting the branch-model's "no
  develop anywhere but weave." Is develop-mirrors-master now fleet canon, and is the old
  statement retired? — **PARTIAL → L1.8**
- **Q1.4** Protection-inventory conflict: `org-protection-rollout` reports 24 protected + 26
  auto-merge (2026-06-12), but `decisions-meta` reports `allow_auto_merge` on 63 repos with
  protection only on `icm/main` + `envctl/develop` under new repo-owned tooling (2026-06-13).
  Was the mass rollout rolled back/reclassified, and which is the current inventory? — **OPEN**
- **Q1.5** The `fastembed-rs` pulls-unsafe-via-`ort` constraint (a material prompt_hub
  embedding-backend fact) is in the `decisions-architecture` memory but not a graph concept —
  is it captured in the front-door/embedding map or unmapped? — **ANSWERED → L7.x / L1.9**
- **Q1.6** 18/20 control-plane concepts carry `confidence:0.5` despite several being
  `status:verified/accepted` — is 0.5 a default emitted regardless of verification (extraction
  confidence), or a genuine low-confidence flag? — **ANSWERED → calibration note above**

### 1.2 Handoff & continuity (`map/02-handoff-continuity.md`)

- **Q2.1** Naming/status drift: `handoff-ledger-ark-spec` describes a spec-only 12-crate, 15–25-week
  workspace with an `hf` verb set incl. `hf drift`/`hf policy`, yet
  `harness-upgrade-hardening-ultraplan` records the **shipped** `hf` has **no** `hf drift`/`hf policy`
  and adds `done`/`seed`/`task mint`. Which verb set is authoritative, and is the 12-crate spec
  superseded by the 2-crate spike + shipped `hf`? — **ANSWERED → L2.5**
- **Q2.2** Ledger-location contradiction: `loop-e2e-proof` says `pr_opened` wrote to the
  **worktree's** ledger ("session-ledger location = HFTASK-0007 design point"), while
  `harness-upgrade` warns that CWD-relative `.handoff/ledger.db` creates per-worktree DBs that
  violate ADR-0004 single-ledger. Which is the resolved policy, and was HFTASK-0007 decided? — **OPEN**
- **Q2.3** Front-door seam unbuilt: "NO MCP server on either prompt_hub OR hf side (verified)" and
  `work_orders_from_bundle` is "MIRRORED + TEST-ONLY (never in hf bin)". So the
  `SwarmBundle → handoff.task.v1` seam the spike validated does **not** exist in the production
  `hf` binary. Is the validated spike a path to production, or must HFTASK-0003/0019 re-implement
  it? — **PARTIAL → L2.6**
- **Q2.4** Alternative-to vs replacement: the graph marks `handoff-ledger-ark-spec` as
  `alternative_to` `continuity-session-relay`, but the prose says the kernel **replaces** the
  relay's `HANDOFF.md`. Is the file-based session-relay deprecated, co-running, or is `hf`'s
  rendered packet now the relay? — **ANSWERED → L2.7**

### 1.3 envctl & kasetto (`map/03-envctl-kasetto.md`)

- **Q3.1** Inject-seam memoir-vs-code drift: the memoir records `injection_template`/`run_child`/
  `ProviderMint` as `todo!()` stubs, but 2026-06-13 memories show PR-1 (`DataPlaneMode`) and
  PR-2b (`MintResp.injection`, `Engine::run_child`, branch `secrets-inject-pr2b` NOT committed)
  partially landed. What is the current **committed** state of the inject seam? — **PARTIAL → L3.6**
- **Q3.2** kasetto location contradiction: 06-11 seam-spec says kasetto is NOT in `.meta.yaml`
  with no canonical clone; 06-12 unification names source repo `FlexNetOS/env_manager_agent`
  (3.1.0→3.2.0). Was the repo located, and is `crates/agent-env` built or still Epic-C backlog
  (TASK-0011..0018)? — **OPEN**
- **Q3.3** `master` branch protection: the corrected git-workflow sets `required_linear_history:false`
  (linear history breaks the ff-mirror, GH006), but a consolidated memory lists "linear history"
  as enabled. Is linear history ON or OFF on `master` now? — **ANSWERED → L3.7**
- **Q3.4** secretd phase %: the seam spec says "phases 6-8 ~30%". What phase is `secretd` actually
  at after the 06-13 inject/seed-factor work — material to the "DO NOT BUILD AGAINST IT" caveat? — **OPEN**
- **Q3.5** env-ctl naming retirement: the proposed replacement name is `secretd` OR `secrets` —
  has a final name been chosen, and is the socket/systemd-unit/XDG migration scheduled? — **OPEN**

### 1.4 weave coordination (`map/04-weave-coordination.md`)

- **Q4.1** Tool-surface contradiction: the memoir says "50+/73 eager `weave_*` MCP tools" but
  `context-weave` WL-050/ADR-0003 collapsed them to ONE standing `weave` meta-tool
  (`tool_catalog()` = 73-op registry, `WEAVE_MCP_EAGER=1` fallback). Which surface is current? — **ANSWERED → L4.5**
- **Q4.2** Version/roadmap drift: the memoir pins `v0.2.0` "still INCOMPLETE" but memories run
  WL-034..WL-053 + "Repowire-superset 35/36". Is v0.2.0 current, and is "incomplete" stale vs
  the 2026-06-13 sessions? — **PARTIAL → L4.6**
- **Q4.3** `weave-lineage-and-obscura` is `status:user-stated` (not code-verified): is the "Rust
  PORT of repowire" claim itself verified, or only the retirement? — **ANSWERED → L4.7**
- **Q4.4** `loops-use-stale-weave-repowire` (`status:blocking`, user-confirmed 2026-06-09): have
  the envctl forge-loop / session-relay hooks since been migrated off retired weave-repowire onto
  current weave and scoped out of subagent/headless contexts (closes `subagent-forge-hook-hazard`)? — **OPEN (critical)**
- **Q4.5** obscura wiring status: memoir says "zero build edge/feature flag in weave" but
  `decisions-weave` records WL-049/ADR-0002 accepted (spawn-and-speak) — decided-but-not-built,
  partial, or shipped? Crate count differs (7 vs 8). — **ANSWERED → L4.8**
- **Q4.6** rvAgent⇄weave bridge and the N-reviewers→one-verdict reducer (~50–100 LOC, R5) are both
  marked NOT designed/missing — confirm they remain open and `hf` is still the sole junction. — **OPEN**

### 1.5 RuVector substrate (`map/05-ruvector-substrate.md`)

- **Q5.1** Is the pass-6-correction the FINAL RVF wiring verdict, or is a further pass owed to
  reconcile ADR-125 (phase out native in favor of TS), which remains true only for the memory
  backend? — **ANSWERED → L5.6**
- **Q5.2** wasm/ts discrepancy: the `ruvector` facade DEFAULTS `implementationType='wasm'` (rvf-wasm,
  deps only rvf-types+rvf-crypto) — does that mean the default operational path is wasm, not the
  napi `rvf-runtime` path? — **OPEN**
- **Q5.3** rvf-crypto post-quantum: the knowledge-export claims ML-DSA-65, but the code-walk proves
  ed25519-dalek + sha3 ONLY (PQ lives in `ruvector-dag`/QuDAG). Confirm no downstream doc relies on
  the false ML-DSA claim. — **ANSWERED → L5.7**
- **Q5.4** Cognitum Seed board class is internally inconsistent (Pi Zero/Cortex-A53/512MB vs Pi 5 vs
  bcm2711 Pi4/CM4/Pi400 vs Pi4/CM4/Pi5); the 2026-06-13 SSH probe returned `armv7l` (32-bit). What
  is the actual board, and does ruvix (aarch64/bcm2711) even run on it? — **OPEN (hardware)**
- **Q5.5** Two tamper-evident witness schemes coexist (RVF 73B/SHAKE-256 vs RVM 64B/FNV-1a) —
  intentional heavy/light tiers, and which is canonical for the meta handoff ledger? (S1 adopts the
  RVF one.) — **ANSWERED → L5.8**

### 1.6 Cognitive codewalk (`map/06-cognitive-codewalk.md`)

- **Q6.1** `todo-reexplore-b17f`: are the exo-ai-2025 prototypes (`conscious-language-interface`,
  `federated-collective-phi`) actually wired into `ruvllm-router`/`exo-federation`, or purely
  incubating? The "13.78 quadrillion spikes/second" claim needs code-level throughput verification. — **OPEN**
- **Q6.2** `todo-reexplore-b17g`: `vibecast-7sense` reaches RuVector at neither compile nor runtime
  (zero ruvector/rvf/cognitum refs) — confirm it is a co-located reference product, not a hidden
  runtime dependency. — **PARTIAL → L6.4**
- **Q6.3** All `codewalk-*` tier facts are `confidence:0.5` — is the entire tier structure (b17a..j
  ordering, hub-crate counts, agentic-role assignments) a strict-walk finding pending independent
  verification? — **PARTIAL** (per calibration note: named facts near-certain, theses genuinely <0.7)
- **Q6.4** Doc-vs-code contradictions remain open seams: `ruvector-dag` (blurb "query-plan optimizer"
  vs code "PQ governance DAG"), `ruvector-coherence` (blurb "sheaf-Laplacian engine" vs code
  "lightweight HNSW health monitor"), `prime-radiant` (blurb "dashboard" vs code "GPU convergence
  runtime"), `router-core` (named "router" but is a vector DB). Confirm in the canonical source. — **OPEN**

### 1.7 Front-door & integration (`map/07-frontdoor-integration.md`)

- **Q7.1** HFTASK-0019 (open): does prompt_hub expose an MCP server for mcp-bridge, or plain
  HTTP + bridge-translation? Gates the whole front door. — **OPEN**
- **Q7.2** HFTASK-0003 crux: how is the `/vibe` Intent synthesized into REAL
  `path_scope`/`acceptance_criteria`/`test_commands`? Nothing in the 3 crates does this today. — **OPEN**
- **Q7.3** Embedding backend not fully closed: `decisions-prompt-hub` recommends candle, but
  `decisions-prompt-hub-embedding-backend` finds fastembed-rs v5.13.4 is zero-unsafe-in-own-source
  and bge-m3-capable — which is adopted under `#![forbid(unsafe_code)]`? — **PARTIAL → L7.5**
- **Q7.4** `prompt_hub-front-door` is `status:verified` yet "NOT code-wired as actual intake yet" —
  confirm: capability verified by code-walk but not activated as live intake. — **ANSWERED → L7.6**
- **Q7.5** seam-spec file:line refs (`models.rs:528+547`, `server.rs:38-95`) should be re-validated
  vs current prompt_hub HEAD since PRs #94–#106 have since shipped. — **OPEN**

### 1.8 Gaps, seams & merge (`map/08-gaps-seams-merge.md`)

- **Q8.1** GAP — which of the five competing "task truths" is authoritative, and who designates it? — **ANSWERED → L8.5 (source-of-truth hierarchy)**
- **Q8.2** GAP — is prompt_hub the canonical single front door, or is precedence/federation defined
  across the competing intake paths? — **ANSWERED → L7.6 / L2.7**
- **Q8.3** GAP — what is the one work-order envelope schema (with weave `Job.correlation_id`), and
  who authors it? — **OPEN**
- **Q8.4** Autonomy unlock — who builds the three connectors (prompt_hub `export_to_weave`, weave
  `JobRunner` dispatcher deferred to P10/P11, the work-order contract) and integrates with — not
  replaces — the file-based session-relay loop? — **OPEN**
- **Q8.5** Hardware walls — who fully develops `lane`, who controls the USB secret key (envctl
  secretd / ruvector entry point), and how does the COGNITUM SEED Pi-Zero stack mount/activate? — **OPEN (hardware)**
- **Q8.6** Hazard — who scopes/migrates the broken forge-loop/weave relay hooks in
  `.claude/settings.json` off stale weave-repowire so they stop firing in subagents and injecting
  false instructions? (= Q4.4) — **OPEN (critical)**
- **Q8.7** rusty-idd — who fixes the verified duplicate `run:` key in `promote-verify.yml`? — **OPEN**

### 1.9 Settings / harness reconciliation (this session)

- **Q9.1** The `settings.canonical.json` reference said user-global hooks (ruvector/ccg/gitnexus/
  global) are "drift to be dropped" and `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` "must not appear",
  contradicting "never downgrade." **CORRECTED (owner directive 2026-06-13 + ADR-0006):** the premise
  was wrong — **meta/envctl IS the env manager**; the env block + plugin marketplaces are intentional
  meta-controlled config, never drift. The doctor's forbidden agent-teams key was removed and the
  canonical reference rewritten. — **ANSWERED → L9.1, L9.4**
- **Q9.2** Do Claude Code marketplace `source.path` values tilde/env-expand? **ANSWERED:** No — Claude
  Code reads `source.path` directly (no shell expansion), so the portability fix is the **envctl
  template-substitution pass at link time** (ADR-0006, like `envctl/home/.claude/settings.json.tmpl`
  with `${META_ROOT}`), which renders the correct per-host path — **not** a trim. Note: the 5 paths
  currently point at `/home/drdave/_work|repos/...` which **do not exist on this box** → those
  marketplaces are stale/incomplete work to carry forward (per "never downgrade"), not to drop.
  — **ANSWERED → L9.5**

---

## Section 2 — Lessons

Confirmed ground truths carried forward (and answers to Section-1 questions).

### 2.1 Meta control-plane

- **L1.1** `meta` is a **meta-repo of ~60 independent `FlexNetOS/` git repos** (NOT a monorepo);
  each member builds/publishes independently; the root `Cargo.toml` is dev-convenience only.
- **L1.2** The stack is **NOT a wired pipeline** — loose integration via **two substrates**
  (the weave mesh + committed files on disk). No tool calls prompt_hub/rusty-idd/kasetto/weave
  directly in code (the one live code edge is `handoff/ledger → rvf-crypto` witness chain).
- **L1.3** **Code is truth; all RuVector prose is untrusted** (README = marketing,
  `CLAUDE.md` = upstream claude-flow config; the knowledge-export claims 91 crates vs a real ~314).
- **L1.4** **Never-downgrade guard is real and has fired correctly** (rtk 0.42.2>0.42.0 skipped;
  kasetto 3.1.0>3.0.0 link-inversion held). A component's "detect" must encode the full desired
  end-state, not a single sentinel.
- **L1.5** **gh-aw separation-of-privilege:** agents emit verdicts as **data** and never hold the
  merge token; verdicts stay out-of-band in weave; a bot `APPROVE` would defeat required-reviews;
  merge is an Environment-gated non-agent job.
- **L1.6** *(answers Q1.1)* `decision-log-2026-06-09` — the **body governs**; it is the LOCKED
  version that supersedes the earlier provisional one. The `status:provisional` label is stale.
- **L1.7** *(answers Q1.2)* Current protected set (org-audit, adversarially re-verified): **3 repos**
  — `.github/main`, `lane/main`, `weave/master`. The "only weave" statements are **superseded**;
  weave remains the only one with `develop` + the full 6-check protection.
- **L1.8** *(partial Q1.3)* The 2026-06-13 direction is **develop-mirrors-master fleet-wide via
  repo-owned tooling** (create-if-missing). This is the newest canon; the old "no develop but weave"
  is being retired but the rollout is mid-flight (see Q1.4 inventory conflict).
- **L1.9** *(answers Q1.5)* `fastembed-rs` writes zero unsafe in its own source but depends on `ort`
  (ONNX C++ FFI) which is extensively unsafe — so under `#![forbid(unsafe_code)]`, depending on
  fastembed is **not** safe-only. Material to prompt_hub's embedding backend (see L7.5).
- **L1.10** Portability = **total internalization** with **envctl as the single box materializer**;
  contract = "real file in meta, symlink INTO meta, never out"; secrets/state never internalize
  (ADR-0006/0007/0008).
- **L1.11** Verified completion baselines (2026-06-09): kasetto ~95%, weave core done+tested,
  prompt_hub core ~85%, obscura complete, envctl 0-5 ~90%, rusty-idd ~85%. **None of the stack
  projects are finished** — they are built simultaneously in parallel; multiple front doors /
  competing task stores are an artifact of unfinished concurrent construction.

### 2.2 Handoff & continuity

- **L2.1** The **Continuity Ledger Kernel** (`hf` CLI) is real and self-applying:
  `init/seed/status/claim/checkpoint/done/handoff/resume[--json]/task mint`; it bootstrapped its
  own shipping (`hf ship v0` shipped its own implementation, GitHub auto-merged with no agent merge
  action); published canonically at **`FlexNetOS/handoff`** (master, public). Witness chain verified
  16 events; ledger live.
- **L2.2** **State-precedence (conflict-resolution rule):**
  Git HEAD/worktrees/diffs > `.handoff/ledger.db` > `tasks/*.task.json` > `decisions/adr.md` >
  `active.md` > `packets/latest.md` (non-authoritative). Packets + `active.md` are **rendered** by
  `hf handoff`, never hand-edited.
- **L2.3** The no-human gate is **two-layer, fail-closed**: a code-omniscient AI gatekeeper decides
  approve/deny, but **envctl `broker::decide`** is the deterministic default-deny enforcement that
  alone releases the token — compromising the AI cannot bypass the broker.
- **L2.4** `hf claim` is **weave-mesh-coordinated**: it reserves a slash-free weave lease
  `handoff:claim:<task-id>` (one holder per task) BEFORE the ledger Claimed event, heartbeats,
  refuses on cross-peer conflict, degrades to ledger-only when weave is absent. Needs the
  lease-capable weave build via `HF_WEAVE_BIN` (`~/.cargo/bin/weave` is STALE, pre-WL-024).
- **L2.5** *(answers Q2.1)* The **shipped `hf`** verb set is authoritative
  (`init/seed/status/claim/checkpoint/done/handoff/resume/task mint`); there is **no** `hf drift`/
  `hf policy`. The 12-crate, 15–25-week Ark spec is **superseded** by the 2-crate spike + the
  shipped CLI (see also L5.9).
- **L2.6** *(partial Q2.3)* Verified at ingestion: there is **no MCP server on prompt_hub or hf**,
  and `work_orders_from_bundle` is test-only mirror code (never in the `hf` bin). The
  `SwarmBundle → handoff.task.v1` seam is validated-in-spike but **not in production** — HFTASK-0003/
  0019 own building it for real.
- **L2.7** *(answers Q2.4)* The ledger kernel is intended to **replace** the file-based
  session-relay's `HANDOFF.md`; the committed `HANDOFF.md` continuity-steward file is a
  **non-authoritative human companion** while `hf`'s rendered packet is the real handoff. The relay
  loop remains the runner until `JobRunner` lands.
- **L2.8** **Ship policy of record** (ADR-0001 §3–§5, R11): fresh worktree off `origin/develop|main`
  → batch 3–5 tasks/cycle → ONE squash commit → PR into trunk (never push trunk) → GitHub-native
  fail-closed auto-merge → post-merge ff `develop` + recycle worktree + `hf handoff`.
  Single-writer-per-repo discipline (parallel IDE commits caused state races).
- **L2.9** The **envctl zellij multi-pane dashboard front-door is a confirmed DEAD END** — do not
  revive it. RuVocal + prompt_hub are the real front door.

### 2.3 envctl & kasetto

- **L3.1** `envctl` is the **deepest layer**: a pure-Rust 8-crate workspace at `~/Desktop/meta/envctl`;
  gRPC over a UDS at `$SECRETCTL_SOCK` (= `XDG_RUNTIME_DIR/env-ctl/control.sock`); services
  Vault/Relay/Certs/Lock/Audit; `apply=false` dry-run default + confirm gates.
- **L3.2** `secrets-engine` **VAULT + BROKER + relay_swap are production-grade & heavily tested**
  (XChaCha20-Poly1305 AEAD, Argon2id/HKDF dual-KEK, DEK-in-RAM, hash-chained audit; pure default-deny
  broker over ~25 DenyReasons; 20+ tests prove the real key never reaches worker/events/audit).
  Already replaces `PARENT_REPO_PAT` for `api.github.com`.
- **L3.3** Split-readiness: the **env-manager half is buildable now; the secrets-runtime half is
  roadmap** — DO NOT build against `secretctl`/`secretd` until `ProviderMint`/inject/run_child land;
  loops use org-level PATs in the interim.
- **L3.4** `env-ctl` was **structurally merged into `envctl`** (2026-06-09), old repo trashed; the
  `env-ctl` name is residue to retire (socket path, `env-ctl.service`, `env-ctl.toml`, XDG dirs).
- **L3.5** **kasetto is a config-time provisioner, NOT a runtime/container manager** — the lock file
  is the interface, zero runtime coupling by design; the envctl→kasetto seam is one-way and already
  live (`agent-env.toml`; `.claude`/`.codex` are kasetto-provisioned, never hand-edited; CI enforces
  `kasetto sync --locked`). **Decision ADR-0001:** unify kasetto INTO envctl as pure-Rust
  `crates/agent-env` via the Engine API, **no downgrade** (11 verbs, 21 presets, additive
  never-clobber MCP merge), adopt SHA-256 lock; only cleanup = drop mimalloc; Epic-C TASK-0011..0018.
- **L3.6** *(partial Q3.1)* Memoir lags code: by 2026-06-13, PR-1 (`DataPlaneMode injection_template`)
  and PR-2b (`secretd MintResp.injection` + `Engine::run_child`) had **partially landed** — but PR-2b
  branch `secrets-inject-pr2b` was NOT yet committed. Treat the "all `todo!()`" snapshot as stale;
  exact committed state still to confirm in-repo (carried to task #5).
- **L3.7** *(answers Q3.3)* On `master`, **`required_linear_history` MUST stay FALSE** and
  `required_pull_request_reviews` NULL — otherwise the token-driven ff-mirror (`sync-master.yml`)
  breaks with GH006. The "linear history enabled" memory is wrong/stale.
- **L3.8** **OPERATIONAL HAZARD:** never restart/rebuild the `env-ctl.service`/`secretd` on a hunch —
  it took the vault down on 2026-06-13; recovery needed an FF of `master` to the USB-factor PR + the
  correct feature flag. Seed-factor unlock now uses pure-Rust pinned-CA HTTPS to
  `POST /api/v1/custody/sign` (envctl#61).

### 2.4 weave coordination

- **L4.1** `weave` is a **coordination substrate** (one dependency-light Rust binary = CLI + MCP
  server in one); **SQLite IS the broker** at `~/.local/share/weave/messages.db` (`WEAVE_DB`
  override); optional libsql backend + `weaved` presence daemon; tables
  `messages/reads/peers/asks/ask_groups/jobs/outbox/pull_cursor`; **owner-only-writes** invariant.
- **L4.2** The weave mesh is the **only live cross-agent channel** — everything integrates by
  becoming a weave peer (register → send → claim jobs), never by direct API calls. Live consumers:
  the n8n harness (secret handoff) + session-relay heartbeats.
- **L4.3** **No autonomous dispatch/spawn** — Jobs are poll-only (`attempt_id` fencing tokens),
  `JobRunner` is a future epic, the session-relay loop stays the runner.
- **L4.4** Proven first consumer: `handoff/hf/src/lease.rs` — a `Leaser` trait + `WeaveCli::from_env()`
  shelling out to the weave binary (NO crate dep), gated by
  `ClaimGate::{Refuse,Proceed,ProceedDegraded}` for graceful ledger-only degradation (HFTASK-0002 DONE).
- **L4.5** *(answers Q4.1)* The **current MCP surface is ONE standing `weave` meta-tool**
  (`tool_catalog()` exposing a 73-op registry; `WEAVE_MCP_EAGER=1` falls back to eager `weave_*`
  tools). The "50+/73 eager tools" memoir line describes the pre-WL-050 surface (ADR-0003 collapsed it).
- **L4.6** *(partial Q4.2)* v0.2.0 is the sanctioned release line; "still incomplete" is relative —
  WL-034..WL-053 + "Repowire-superset 35/36" show active progress past the memoir snapshot. Exact
  current tag carried to task #5.
- **L4.7** *(answers Q4.3/Q4.5)* Lineage is **verified-retired**: weave formally retired `mcp-broker`
  (Python poll-only mailbox, absorbed as a Tier-2 cross-store pull) and `repowire` (Python daemon,
  parity absorbed daemon-free as epics P1–P5) per `weave/ARCHITECTURE.md §8`. The "Rust port of
  repowire" framing is user-stated; the **retirement** is the code-verified fact.
- **L4.8** *(answers Q4.5)* **obscura** is a complete production-ready Rust headless browser
  (`obscura-mcp` + `obscura-cdp`, ~30MB) at `~/Desktop/meta/obscura`; weave→obscura is
  **decided-but-not-built** (accepted seam WL-049/ADR-0002 = spawn `obscura mcp` child over stdio
  JSON-RPC; weave is the hand-rolled MCP client; obscura is NOT a crate dep), zero build edge yet —
  ready to wire, not a blocker.
- **L4.9** **ROOT CAUSE (carry-forward, Q4.4/Q8.6):** the autonomous loops + session-relay hooks
  still reference the **retired weave-repowire** predecessors, fire in subagent/non-interactive
  contexts, and hijack them. Workaround = read crate files directly rather than spawning subagents.
  Fix = migrate loops/hooks to current weave + scope them out of subagents/headless.

### 2.5 RuVector substrate

- **L5.1** **CODE-PROVEN crate graph:** ~213 `Cargo.toml` parsed, 340 internal dep edges; top hubs
  `rvf-types`(26)/`ruvix-types`(25)/`ruvector-core`(24); `mcp-brain-server` converges all clusters.
  (The full estate is ~314 crates; the knowledge-export's 91 is a partial scaffold, never a count.)
- **L5.2** `cognitum` = RuVector's **hardware tier**; the physical **Cognitum Seed** is its
  embodiment. It needs **no secret key**, so it is **NOT** the envctl secret-key USB (do not conflate);
  must be plugged in at boot to enumerate USB-gadget interfaces; SSH enrolled 2026-06-13 (host
  `cognitum-578b`, `armv7l`).
- **L5.3** A `.rvf` is a **self-bootstrapping vector-native compute container** (embeds a Linux
  bzImage / Hermit / Asterinas + a WASM "Cognitum tile runtime" + eBPF; `rvf-launch` boots it in
  QEMU) — not mere storage; governance/witness/attestation are baked into the format.
- **L5.4** `ruvix` is a genuine from-scratch **bare-metal microkernel OS** where syscalls operate on
  vectors and are proof-verified (`ruvix-sched → ruvector-coherence`); `ruvix` = OS, `RVM` =
  hypervisor over it.
- **L5.5** `rvAgent` and `ruflo` are **parallel front-ends** over the same RuVector substrate (not
  stacked); weave is a separate meta-local mesh — three agent systems, one shared substrate.
  `ruvnet` dev pattern (user-authoritative): TS-first then Rust-native port, keep TS for compat;
  napi-rs is the bridge; treat Rust as truth, TS as legacy.
- **L5.6** *(answers Q5.1)* Reconciled RVF wiring verdict: **production Rust RVF IS wired into ruflo**
  (intelligence facade across 6 plugins + `ruflo-core` witness via napi→`rvf-runtime`); the
  `@claude-flow/memory` KV backend is the **sole TS-only exception** (matches ADR-125). The
  pass6-correction is the operative verdict.
- **L5.7** *(answers Q5.3)* `rvf-crypto` is **ed25519-dalek + sha3 only** — the "ML-DSA-65"
  post-quantum claim is **false marketing** (PQ lives in `ruvector-dag`/QuDAG). Do not rely on the
  ML-DSA claim anywhere downstream.
- **L5.8** *(answers Q5.5)* Two witness schemes are **intentional tiers**: RVF (73B records,
  SHAKE-256) is the heavy/canonical chain — **adopted by S1 for the meta handoff ledger**; RVM
  (64B, FNV-1a) is the light in-hypervisor scheme.
- **L5.9** **S1 decision (critical, not-yet-fully-adopted):** do NOT rebuild the 12-crate Ark Handoff
  Ledger — ~8 of 12 already exist; adopt the Ark **contract** onto RVF witness + weave leases +
  ruvector-verified + cognitum-gate + domain-expansion + rvAgent. The spike PASSED 4/4
  (rusqlite + rvf-crypto witness). (Reconciles with L2.5.)

### 2.6 Cognitive codewalk

- **L6.1** RuVector examples **interconnect THROUGH shared hub crates** (`ruvector-mincut`=21,
  `ruvector-coherence`=19, `ruvector-core`=11 dependents), not by calling each other; the domain
  examples are ONE mincut + coherence (+ consciousness-Phi) pipeline parameterized by dataset.
- **L6.2** Three example macro-tiers: (1) ruvector-coupled domain apps; (2) `exo-ai-2025` satellite
  workspace consuming ruvector via crates.io 0.1; (3) self-contained `vibecast-7sense` with **zero**
  ruvector deps.
- **L6.3** Thesis **T1 (governed/gated/attested compute) has a literal hardware root:**
  `cognitum-gate-kernel` (255 tiles, anytime-valid LogEValue evidence) → `cognitum-gate-tilezero`
  (signed `WitnessReceipt` chain) → `mcp-gate` (agent permission API); the same coherence-gate +
  witness + budget seam recurs across solver/verified/fpga-transformer/neural-trader/graph-transformer.
- **L6.4** *(partial Q6.2)* `vibecast-7sense` is a **co-located reference product** with no ruvector
  edge (compile or runtime); its Qdrant→index-zoo / Perch2.0→ruvllm migration is **aspirational, not
  implemented**. The b17f/b17g areas are the explicitly-flagged re-exploration TODOs.
- **L6.5** **T11: MCP is the universal control seam** — `mcp-gate`, `mcp-brain`,
  `agentic-robotics-mcp`, `rvagent-mcp` + `ruflo` all expose a uniform MCP server interface;
  `ruvector-domain-expansion` (Thompson-sampling bandit router) is the pervasive task-routing brain.

### 2.7 Front-door & integration

- **L7.1** Front-door **ledger + naming RESOLVED** (s1, user-confirmed 2026-06-09): v1 ledger =
  `rusqlite` (SQLite/WAL) + `rvf-crypto::WitnessChain` (standalone, no-napi); the RVF vector-native
  ledger is scheduled V2; kernel name = `handoff`/`.handoff` (Ark/V2 dropped); `rvf-node` = TS
  read-bridge only.
- **L7.2** Roles locked: **prompt_hub = single canonical intent-minting intake; RuVocal = primary
  human UI; CLI/n8n/meta doors = thin shims to prompt_hub** (Plan C). RuVocal's vector backend =
  pgvector = `ruvector-postgres` (the UI is already on a RuVector crate).
- **L7.3** The witnessed ledger is the **read-model** — build NO new dashboard (results round-trip
  via `hf status --json` / `hf watch`, HFTASK-0020/0021).
- **L7.4** `mcp-brain-server` is the **convergence proof**: one crate composing
  `mincut + ruvllm + rvf-federation`, deployed as **`ruvbrain` on Cloud Run** (us-central1, 1500+
  memories, 350K+ edges, 7 scheduler jobs). `rtk` wraps tool calls (not requests) for 60–90% dev-op
  token savings via a PreToolUse hook + yazelix shell aliases. Yazelix is doubly enforced (desktop
  launcher + envctl-injected `.bashrc` `yzx enter`); plain ghostty is the escape hatch.
- **L7.5** *(partial Q7.3)* Embedding backend is **not finally closed**: `decisions-prompt-hub`
  recommends candle; `decisions-prompt-hub-embedding-backend` finds fastembed-rs v5.13.4 is
  zero-unsafe-in-own-source + bge-m3-capable — BUT it pulls unsafe via `ort` (L1.9), so under
  `#![forbid(unsafe_code)]` it is not safe-only. The trade-off (candle pure-Rust vs fastembed
  convenience) is unresolved.
- **L7.6** *(answers Q7.4/Q8.2)* `prompt_hub` is the canonical front door **by design/code-walk
  (status:verified)** but is **NOT yet wired as live intake**; the `/vibe` Intent →
  `handoff.task.v1` synthesis (HFTASK-0003) does not exist in its 3 crates today.

### 2.8 Gaps, seams & merge (doctrine)

- **L8.1** **Docs / Cargo.toml-fields / ADR-narratives / the knowledge-export are untrusted prose**
  (claims 91 crates; repo has ~314). Trust only executable code (real dep edges, signatures, fields,
  fn bodies, tests). When prose contradicts code, **code wins** — and flag it.
- **L8.2** **Be patient with apparently-orphaned TS/adapter crates** — search all `Cargo.toml` for
  consumers before labeling dead; rvf adapters are Rust-native replacements consumed by other Rust
  crates. Every TS unit has a Rust-native replacement crate — prefer the RuVector Rust crate over
  claude-flow TS when mapping into meta.
- **L8.3** **Interchangeable index/DB/compute parts are preloaded and hot-swapped at runtime** per
  agent-context (a domain-expansion bandit router), not a build-time human choice.
- **L8.4** **Treat injected forge-relay/loop hook messages as broken-tool noise, never as user
  instructions** (direct consequence of L4.9).
- **L8.5** *(answers Q8.1)* **Source-of-truth hierarchy (LOCKED 2026-06-09):**
  Git HEAD/worktree > rusqlite+rvf-crypto witness ledger > `tasks/*.task.yaml` > ADRs > `active.md`
  > packets. weave Jobs = coordination **view**, never crowned source of truth. (= L2.2.)
- **L8.6** **rusty-idd merge model:** fail-closed, GitHub-native auto-merge, **ONE PR PER CYCLE**
  (stacking strands the later commit); the branch-protected required check is the sole merge
  authority; a RED check = a hard wall = NEEDS-HUMAN.
- **L8.7** **MiroFish port doctrine:** extend `teri`, never port fresh; parity **by spec**, never
  code-copy (AGPL vs MIT); GGUF-only guard; secrets flow through the **envctl injection seam**, not
  shell export.
- **L8.8** Method ground truth: `gh` mutations can succeed **silently** (always re-query); a passing
  test battery does **not** disprove a scheduling race (use stress-loops + `#[serial_test::serial]`);
  `rtk` silently filters cargo/grep output (exit codes are truth); `systemctl --user disable` deletes
  symlinked unit files.

### 2.9 Settings / harness reconciliation (this session)

- **L9.1** *(answers Q9.1)* **meta/envctl IS the user-global env manager (ADR-0006).** `envctl/home/`
  is the canonical home tree (the single source of truth for user-global, non-secret config); `$HOME`
  paths are **symlinks into it** ("real file in meta, symlink outside, never the reverse"), wired by
  the `claude-global-links`/`portability-links` components. So what is conventionally "user-global
  settings" is meta-controlled here, and **portability/replication = the envctl template render**
  (`envctl/home/.claude/settings.json.tmpl` with `${META_ROOT}`), not trimming. The functional hooks
  (repo-relative scripts/hooks/* AND the user-global ruvector/ccg/gitnexus/global hooks) are **kept** —
  removing them is a real downgrade.
- **L9.2** *(answers Q9.1)* Hardcoded `/home/drdave/.claude/...` hook command paths were portabilized
  to **`~/.claude/...`** (shell-executed → tilde expands to the envctl-symlinked home; already
  allowlisted) — an upgrade, zero behavior change. The 5 plugin-marketplace `source.path` values are
  **meta's plugin system**, left as-is: their hardcoded `/home/...` form is recorded **portability
  residue** whose sanctioned fix is the envctl template pass (ADR-0006), **never a drop**.
- **L9.3** **ICM architecture injection wired** (this session): `scripts/hooks/icm-architecture-inject.sh`
  on `SessionStart` + `PreCompact` injects a **bounded** (~2KB) compact pack of the
  `system-architecture` memoir — live via `icm --no-embeddings recall-context` when present, else the
  committed `architecture/icm/INDEX.md` (graceful no-op when `icm` is absent → portable to any machine).
- **L9.4** *(answers Q9.1; owner correction 2026-06-13)* The `.github_org` settings-doctor tooling was
  **wrong**, not the settings: it forbade `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` (which must NEVER
  be dropped) and framed meta's plugin marketplaces as "drift." **Fixed:** `claude-settings-doctor.js`
  `FORBIDDEN_KEYS` is now `[]` (the `env` block + `enabledPlugins`/`extraKnownMarketplaces` are
  meta/envctl-owned and not policed), and `settings.canonical.json` was rewritten to the ADR-0006
  model. The doctor now reports only the genuine portability residue (5 marketplace `/home/...` paths),
  framed as "apply the template pass," not "trim."
- **L9.5** *(answers Q9.2)* Claude Code reads marketplace `source.path` **directly** (no `~`/`$VAR`
  expansion) — so portability there is achieved by a **render step** (the envctl template pass), which
  must emit a real per-host path. The 5 `.github_org` marketplaces currently point at
  `/home/drdave/_work|repos/...` directories that **don't exist on this box** → stale/incomplete work
  to carry forward (per "never downgrade"), distinct from meta's live plugin system (global
  `~/.claude/settings.json` enables `gitkb`/`harness-marketplace`/`meta` from inside `meta/`).
- **L9.6** ADR-0006 layering (from `envctl/home/README.md`): **envctl** = OS/toolchain/box layer, owns
  the home tree + symlink wiring; **kasetto** = agent layer (skills/MCP into `.claude`/`.codex`),
  global manifest at `.config/kasetto/kasetto.yaml`; **meta** = repo/workspace layer, `bootstrap.sh`
  sequences `rustup → clone → build → envctl install → kasetto sync --locked → envctl doctor`. Rules:
  no secrets, no state, archive-first, every file reviewed individually — because `envctl/home/` is PUBLIC.

---

## Addendum — resolutions & new questions from the meta-root docs + `meta*` repo walk (2026-06-13)

After ingesting ICM, the map was expanded with the authoritative meta-root planning docs
(maps [09](map/09-meta-root-ruvector.md)–[11](map/11-meta-root-org-hardware.md)) and a walk of the
11 `meta*` repos (map [12](map/12-meta-repos.md)). Several answers were verified against **live
code** (envctl HEAD, the mounted `COGNITUM` drive, the `meta*` Cargo.toml graph) — those are the
strongest. This addendum is the authoritative status update for the Section-1 questions.

### A. Resolutions — Section-1 questions answered/refined

| Q | New status | Answer (short) | Source |
|---|---|---|---|
| Q1.3 | **ANSWERED** | `develop`-mirrors-`master` IS fleet canon (create-if-missing, repo-owned tooling); "no develop but weave" retiring; rollout mid-flight | META-ORG-AUDIT Phase-4 · map 11 |
| Q1.4 | **ANSWERED** | Reclassified, not rolled back. **Current (06-13):** `allow_auto_merge` on **63** repos; protection only on `icm/main` + `envctl/develop` (strict=false, no required reviews → PRs self-land). Supersedes the 06-12 "24 protected + 26 auto-merge". | META-ORG-AUDIT · map 11 |
| Q2.2 | **PARTIAL** | ADR-0004 makes single-ledger a **fleet** rule: members keep NO local `ledger.db` (events → `meta/.handoff`). But **HFTASK-0007** (the `hf` session start/end verb owning session-ledger location) is **unbuilt** — heads the readiness queue. | SESSION-HANDOFF · GAP-REGISTER 2/13 |
| Q2.3 | OPEN-confirmed | The `SwarmBundle→handoff.task.v1` seam is a **gap on both sides** (zero MCP server + zero outbound dispatch); HFTASK-0019/0003 carded, unbuilt; the spike is a design proof only. | GAP-REGISTER 10 |
| Q3.1 | **ANSWERED** | The "inject seam" is **TWO** seams. **(a)** USB-possession/vault-unlock = **MERGED** (PR #50, envctl `master@42b21f9`: `RealUsbProbe`, `SeedPresenceGate` Profile S, seed enroll/unlock). **(b)** auto-injection/data-plane (`injection_template`, `run_child`, `MintResp.injection`, `LocalCa`) = **still `todo!()` on master**; branches `secrets-inject-pr2/pr2b/seam` exist only on origin, NOT merged. | live envctl HEAD · map 11 |
| Q3.4 | **ANSWERED** | seed-factor strand **live-verified** ("vault unlocked (factor: usb)"/"(factor: passphrase)"); the **data-plane `Run`/inject strand** the "~30%" referred to is **still stubbed** (`injection:None // not wired in Phase 6`). | PLAN-cognitum §5 · live `secretd/grpc.rs:337` |
| Q3.5 | OPEN-confirmed | No `env-ctl` rename chosen, no socket/systemd/XDG migration scheduled; residue still live (`env-ctl.service`, `~/.config/env-ctl/`, `$XDG_DATA_HOME/env-ctl/`). | META-ORG-AUDIT residual #8 · PORTABILITY-AUDIT B2/B4 |
| Q4.4 / Q8.6 | **PARTIAL** | Retired weave-repowire refs neutered + settings repointed off `weave-mcp-daemon-tools`; a crash-looping repowire unit disabled (reversible). **But** the FIX-6 lifecycle hooks remain **owner-gated/not-activated** (NEEDS-HUMAN D), and the standing workaround is still "**no subagents in RuVector/ruflo/envctl**". Not fully closed. | SESSION-HANDOFF s5/s6 · NEEDS-HUMAN D |
| Q4.6 | OPEN-confirmed | rvAgent⇄weave bridge (open-q #3) + N-reviewers→one-verdict reducer (open-q #4) both **open**; ADR-0002 keeps **hf** the sole junction. | GAP-REGISTER W8 scoreboard |
| Q5.1 | **ANSWERED** | **pass-6b is final** (pass-6 recanted same-day as "too narrow"). Production Rust RVF (`rvf-runtime` napi **and** `rvf-wasm`) IS wired into ruflo via the `ruvector` intelligence facade (6 plugins) + `ruflo-core` witness; `@claude-flow/memory` KV is the **sole** TS-only (dead-napi) exception — matches ADR-125. | RUVECTOR-RESEARCH §PASS 6b |
| Q5.2 | **ANSWERED** | Yes — the `ruvector` facade **defaults `implementationType='wasm'`** (`rvf-wasm`, no_std), so the **shipped default path is the wasm microkernel**; napi `rvf-runtime` is the interchangeable alternative. ICM map under-stated this. | RUVECTOR-RESEARCH §PASS 6b |
| Q5.3 | **ANSWERED** | Confirmed: `rvf-crypto` = **ed25519-dalek + sha3 only**; the ML-DSA-65 claim is **false marketing** (PQ lives in `ruvector-dag`/QuDAG: dilithium/kyber). S1 adopts `rvf-crypto::WitnessChain` as SHAKE-256/ed25519. | RUVECTOR-RUNBOOK §doc-contradictions |
| Q5.4 | **ANSWERED** (hardware) | Cognitum Seed is authoritatively **armv7l** (32-bit Pi-class, kernel `6.12.47+rpt-rpi-v7`, 474 MB) running `cognitum-agent` — **NOT** Pi5/aarch64, **NOT** the `ruvix` microkernel. The Pi5/bcm2711 labels are RuVector crate **compile targets**, not this device. Verified from live `COGNITUM/STATUS.txt`. | COGNITUM-SEED · live STATUS.txt |
| Q5.5 | **ANSWERED** | Intentional tiers — **THREE**, not two: RVF SHAKE-256/73B (canonical, adopted by the handoff ledger) · RVM FNV-1a/64B (light, in-hypervisor) · ruvix Merkle/attested-boot. Amend L5.8 to three tiers. | RUVECTOR-RUNBOOK §T5 |
| Q6.1 | OPEN-confirmed | `exo-ai-2025` prototypes (incl. `conscious-language-interface`, `federated-collective-phi`) are **incubating, not wired** (zero internal deps; reimplement own primitives); the "13.78 quadrillion spikes/sec" claim is unverified at code level. | RUVECTOR-RUNBOOK §B17f |
| Q6.4 | **ANSWERED** | Canonical truth (code beats blurb): `ruvector-dag` = QuDAG post-quantum **governance DAG** (not query-planner); `ruvector-coherence` = lightweight **HNSW health monitor** (not sheaf-Laplacian); `prime-radiant` = wgpu **GPU convergence runtime** (not dashboard); `router-core` = embeddable **vector DB** (not a request router). | RUVECTOR-RUNBOOK §doc-contradictions |
| Q7.1 | OPEN-confirmed | Transport (prompt_hub MCP server vs HTTP+bridge) **undecided/unbuilt** — HFTASK-0019, the transport ADR still owed. | GAP-REGISTER 10 |
| Q7.2 | OPEN-confirmed | `/vibe` Intent → real `path_scope`/`acceptance_criteria`/`test_commands` synthesis (HFTASK-0003) is **"THE crux", unbuilt**; nothing in the 3 prompt_hub crates does it. | GAP-REGISTER 10 |
| Q8.3 | **PARTIAL** | The work-order envelope (WOE) schema **is authored** (STACK-INTEGRATION Plan A; the spike's `handoff.task.v1` is its validated form carrying `correlation_id`); but it is **not built** — owned by HFTASK-0003/0019 (W7). | STACK-INTEGRATION Plan A |
| Q8.4 | **PARTIAL** | Three connectors **designed + sequenced, unbuilt**: prompt_hub `export_to_weave` + the work-order contract = HFTASK-0003/0019 (W7); weave autonomous `JobRunner` = **deferred** ("the loop is the runner") — the file-based session-relay loop stays the dispatcher and is integrated with, not replaced. | STACK-INTEGRATION · GAP-REGISTER |
| Q8.5 | **PARTIAL** (hardware) | `lane` unchanged (its remit). USB secret key = **the Cognitum Seed itself** (owner controls via SSH + Ed25519 custody/sign; seed-factor backend implemented + live-verified). Boot-mount **still needs a human**: the USB-Ethernet gadget only enumerates if plugged into a **data-capable** USB-C port **at boot**. | PLAN-cognitum §0/§4/§5 |
| Q8.7 | OPEN-confirmed | No fix recorded for the duplicate `run:` key in `promote-verify.yml`. | GAP-REGISTER 9 |

### B. New lessons (added to Section 2)

- **L5.8 (amended)** *(Q5.5)* There are **THREE** witness tiers, not two: **RVF** (SHAKE-256, 73-byte
  records — canonical, adopted by the meta handoff ledger) · **RVM** (FNV-1a, 64-byte — light,
  in-hypervisor) · **ruvix** (Merkle proof + attested-boot log). Same tamper-evident pattern, different tiers.
- **L9.4** *(Q5.1)* The RVF-wiring verdict is **FINAL at pass-6b** — read `map/05 §8.4` with pass-6b
  as the terminus; pass-6 ("TS is the active path") was recanted.
- **L9.5** *(Q5.2)* The `ruvector` npm facade **defaults to `wasm`** (`rvf-wasm` = `rvf-types` +
  `rvf-crypto`, no_std); napi `rvf-runtime` is the interchangeable sibling, bridged at the **format**
  level (via `rvf-types`, the #1 dep hub, 26 dependents), not the code-dependency level.
- **L9.6** Authoritative crate count is **314 (196 clusters)** = 216 `crates/` + 93 `examples/` +
  roots; the `RUVECTOR-CRATE-LEDGER.md` is the inventory of record (the export's "91" is a stale scaffold).
- **L9.7** **S1 "adopt-don't-rebuild" is load-bearing:** ~8 of 12 Ark Handoff Ledger crates already
  exist production-grade in RuVector/meta; only thin `hf` CLI/daemon/test glue is new. **Law: RuVector
  is the FOUNDATION the meta stack adds to, not a peer.**
- **L10.1** The meta-root planning docs are **NEWER** than the ICM export the maps 01–08 were rendered
  from (STACK 06-09 → GAP-REGISTER 06-12 → NORTH-STAR v2 + SESSION-HANDOFF 06-13) — they **update**,
  not merely confirm (e.g. `.handoff` fleet rollout 1/58 → 21/21 A/B seeded; prompt_hub's construction
  loop finished, PRs #94–#106).
- **L10.2** The chosen autonomy path is explicit: **"B's spine using A's envelope, and C falls out"** —
  ship the tiny work-order envelope, carry it as a weave Job synced by `correlation_id` (a VIEW, not
  crowned truth), build `prompt_hub → WOE → weave Job` + teach the session-relay loop, and **defer**
  weave's `JobRunner`.
- **L10.3** **NORTH-STAR v2** reframes every NEEDS-HUMAN wall as a **temporary scaffold with a named
  demolition plan** (account/scope/irreversible/physical → a model carrying that skillset); progress =
  the shrinking of `NEEDS-HUMAN.md`. Only change-of-intent is reserved to the human forever.
- **L11.1** *(Q3.1)* **envctl has TWO independent USB/seam strands the map conflates:** the
  USB-possession/vault-unlock seam is **MERGED + seed-anchored**; the auto-injection/data-plane seam
  is **still `todo!()` on master**. Always separate "does the vault unlock" from "does it inject keys
  into a child process".
- **L11.2** *(Q5.4)* Read the Cognitum Seed board class from the **live `STATUS.txt`**, not crate target
  triples: it is **armv7l/32-bit** running `cognitum-agent`, not a Pi5/aarch64 ruvix host.
- **L11.3** The Seed **is** the envctl USB possession factor via deterministic **Ed25519 custody/sign**
  (possession ≡ a valid signature from device `0e34a5e5…`), consumed over SSH + one REST call; MCP was
  deliberately **rejected** as token-suck (114 tools). A passphrase keyslot is always enrolled as
  recovery, so a lost/dead Seed is never a permanent lockout.
- **L11.4** **Org branch-protection ownership moved** (06-13) from ad-hoc `meta/scripts` to the
  designated GitHub-management repos (`flexnetos_github_app`/`github_org`/`meta_git_cli`/
  `flexnetos_runner`). Per-repo default branch varies (`envctl=develop`, hubs=`master`, others=`main`)
  — read `.default_branch`.
- **L12.1** *(confirms L1.1)* Every `meta*` dir is an **independent git repo**; the root `Cargo.toml`
  is dev-convenience only — proven by `meta_dashboard_cli` carrying an empty `[workspace]` to build
  standalone and `meta_plugin_api` self-pinning `0.1.0`. **Workspace version is now 0.2.24** (canon said 0.2.22).
- **L12.2** `meta_cli` (pkg `meta`) is a **host** that discovers subprocess-plugin binaries
  (`meta-git`/`meta-project`/`meta-rust`/`meta-dashboard`), talks JSON over **`meta_plugin_protocol`**,
  and runs the returned `ExecutionPlan` via `loop_lib`. `meta_core` owns `.meta.yaml` + `~/.meta`;
  `meta_mcp` re-exports the `meta_cli` **library** to AI tools over MCP (it links the lib, it is **not**
  a subprocess plugin); `meta_plugin_api` is the **superseded** in-process trait; `meta-plugins` is the
  GitHub plugin **registry data** repo the host installs from. `run_plugin()` calls `env_logger::init()`
  — which is why **crate-name == `RUST_LOG` target**.

### C. New questions (carried OPEN)

- **Q-N1** *(rusty-idd path)* STACK-INTEGRATION names the rusty-idd "real repo" as `~/Desktop/idd-merge-idd`
  while canon names `FlexNetOS/rusty-idd` at `~/Desktop/meta/rusty-idd` — stale local checkout, separate
  merge-target, or renamed path?
- **Q-N2** *(prompt_hub HEAD)* SESSION-HANDOFF says prompt_hub's construction loop finished (PRs #94–#106);
  does the production HEAD now contain **any** outbound-dispatch/MCP code, or is GAP-REGISTER 10's
  "zero MCP + zero dispatch" still literally true? (re-validate `models.rs:528+547` / `server.rs:38-95`).
- **Q-N3** *(meta release spine)* NEEDS-HUMAN wall #2: `PARENT_REPO_PAT` resolves **empty** inside meta's
  own workflows, so release PRs can't pass required checks / auto-merge — still un-actioned? does it block
  the whole release-please/auto-merge spine for `meta` itself?
- **Q-N4** *(envctl data-plane disposition)* The auto-injection/data-plane seam is parked on un-merged
  `secrets-inject-pr2/pr2b/seam` branches — still pursued, deprioritized behind the merged seed-factor
  path, or abandoned? (Per "never downgrade", treat as incomplete work to carry forward, not drift.)
- **Q-N5** *(dev vault hygiene)* The PLAN's test daemon wrote to the **real** dev libSQL store
  (127.0.0.1:8080) leaving `testkey`/`testrelay`/bearers — was cleanup performed; is the live dev vault
  in a known-clean state?
- **Q-N6** *(Seed vs separate USB)* Now that the Seed IS the envctl possession factor, is the earlier
  "separate envctl secret-key USB stick" retired/never-existed, or a still-distinct second physical factor?
- **Q-N7** *(cross-arch anchor)* The Seed is armv7l running its own RVF/witness stack; does it interop with
  the x86 SHAKE-256/73-byte handoff-ledger `WitnessChain` (`hf anchor`), or is it a cross-arch REST bridge only?
- **Q-N8** *(meta layering)* `meta_git_lib` depends on `meta_cli` (pkg `meta`) — a lib←host layering;
  confirm the `meta_cli` library is deliberately split from its bin (no real cargo cycle, since `meta_cli`
  does not dep `meta_git_lib`), and that `meta_plugin_api` archival ("archive preferred") has been actioned.
- **Q-N9** *(plan-B reconciliation)* Which ADR formally reconciles STACK-INTEGRATION Plan-B's "crown weave
  Jobs as authoritative store" against the locked source-of-truth hierarchy (weave Jobs = view only)?
- **Q-N10** *(in-kernel witness tier)* With three witness tiers (L5.8 amended), which tier governs
  in-kernel Cognitum-Seed events, and does `hf anchor` bridge it to the canonical RVF chain? (relates Q-N7).

### D. Final verification pass — answers from live repos (2026-06-13)

- **L-N1** *(answers Q-N1)* The canonical rusty-idd repo is **`FlexNetOS/rusty-idd` at
  `~/Desktop/meta/rusty-idd`** (remote confirmed). The STACK-INTEGRATION reference to
  `~/Desktop/idd-merge-idd` is a **stale path — that directory does not exist**. Use `meta/rusty-idd`.
- **L-N2** *(answers Q-N8)* **No cargo cycle.** `meta_cli` depends only on `meta_core` +
  `meta_plugin_protocol`; it does **not** depend on `meta_git_lib`. `meta_git_lib` depends on
  `meta_cli` (`package = "meta"`) — a deliberate **lib←consumer** layering (the `meta` *library* is
  linked by `meta_git_lib`/`meta_mcp`, separate from the `meta` *binary*). It resolves cleanly.
- **L-N3** *(answers Q-N2)* At prompt_hub HEAD (`main@e986a5a`): **zero `mcp` in Rust source, zero
  outbound dispatch** (no `export_to_weave`/`weave_send`/`work_orders_from_bundle`/`handoff.task`).
  GAP-REGISTER item 10 ("zero MCP server + zero outbound dispatch") is **still literally true at HEAD**.
  The recent loop (#88–#92) was budget-ungating / NO-DOWNGRADE recasts / CI, and #89 exposed **4 hub
  methods as HTTP routes** (tokens/cost/render/input) — i.e. the live front-door surface is **HTTP, not
  MCP** (a data point for Q7.1's still-owed transport ADR, HFTASK-0019).
- **L-N4** *(partial Q-N3)* meta's own `.github/workflows/` (`ci.yml`, `on-push-main.yml`,
  `on-child-update.yml`) **do reference `PARENT_REPO_PAT`** — confirming the dependency. Whether the
  org secret is granted to `FlexNetOS/meta` itself is a secret-state fact not visible from the
  filesystem; it remains **NEEDS-HUMAN wall #2** (Release-Please "token not supplied" on meta). Carry
  forward as incomplete, not drift.

### E. Operating model + upgrade-PR landing (2026-06-14)

- **L-E1** *(answers "how to get elevated GitHub creds without blocking", incl. Q-N3)* The owner
  designates **envctl as the secrets source, reachable via the weave mesh**: when a default `gh`
  token lacks scope (org-level, app-only APIs, higher rate limits, fine-grained PAT), request the
  credential from envctl rather than blocking or escalating to the owner. envctl holds the
  `PARENT_REPO_PAT` and the GitHub App. (Mechanism = the envctl secrets-engine inject seam +
  broker over weave; the data-plane inject is still being completed — see map/03.)
- **L-E2** *(cross-repo question protocol)* Self-serve first; if something is needed that can't be
  found locally, **ask the owning repo's session over the weave mesh** before escalating to the owner.
- **L-E3** *(gitleaks false-positive — resolved)* The verbatim ICM dump under `architecture/icm/`
  contains memory **prose** that names tokens/keys/hosts (e.g. `cognitum-578b`, the Seed SSH host) —
  flagged by gitleaks `generic-api-key`. These are descriptions, **not credentials**;
  `architecture/icm/` is allowlisted in `.gitleaks.toml` (same rationale as `data/brain-data/research/`).
  Lesson: ingested-memory dirs are non-credential by construction; allowlist the path, never redact
  the faithful dump.
- **L-E4** *(separation-of-privilege held)* The upgrade PRs (`meta_git_lib#3`, `meta_git_cli#3`,
  `tool_hub#2`, `.github#102`) were landed via the standing push→PR→auto-merge pipeline. The org's
  protected `.github` `main` (1 required review) is **not** self-admin-bypassed by the PR author —
  the review/merge authority stays with a separate trusted principal (owner or the GitHub App via
  envctl), per ADR-0001 §5 (gh-aw separation-of-privilege) and the L8.x doctrine.

### F. Git-workflow definition pass — contradictions + the canon (2026-06-14, ADR-0003)

The owner halted a brute-force attempt to land `.github#102` and named the real issue: **the
dev/PR workflow was never written down.** Defining it (ADR-0003 + `WORKFLOW.md`) surfaced these:

- **C-F1** *(docs vs code)* `CONTRIBUTING.md`/`CLAUDE.md`/`AGENTS.md` said *"branch off `main`"*,
  but the live workflows (`promote-develop-to-main.yml`, `auto-review-merge.yml`) already implement
  a **`develop`-trunk** model. **Resolved (ADR-0003):** `develop` is the trunk; `main` is the
  protected mirror advanced *only* by promotion; feature branches/PRs target `develop`. Docs fixed.
- **C-F2** *(divergence)* `origin/main...origin/develop` measured **`4/15`** — the trunk and the
  protected mirror had drifted (main carries 4 commits develop lacks; develop carries 15 unpromoted).
  **Action:** reconcile to a one-way flow (promote develop→main; replay main's 4 orphan commits onto
  develop) so the model holds going forward. *(Follow-up, not yet executed.)*
- **C-F3** *(review-gate — CORRECTED against live `gh api`)* The fleet profile in `map/01` claimed
  `develop` had **"NO required reviews (autonomous-loop compatible)."** **Live protection
  (2026-06-14) proves that FALSE for this repo:** *both* `develop` **and** `main` require **1
  approval**, with the *same* 6 required checks (`lint`, `actionlint`, `markdownlint`, `Validate
  manifests`, `Hermetic dependency audit`, `security / Gitleaks secret scan`) and
  `enforce_admins:false`; `main` adds linear-history. **Resolved:** the deadlock is dissolved **not**
  by a review-free trunk but by **who approves** — the approval/merge is always supplied by a
  *separate* trusted principal (`PROMOTE_TOKEN` for `develop→main`; GitHub App via envctl / owner
  for `feature→develop`), never by the PR author; `enforce_admins:false` is the admin seam that
  principal uses. An agent must never approve or admin-merge its **own** PR on either branch.
  *(Fixes the earlier draft of this entry, which wrongly called `develop` review-free.)*
- **C-F4** *(delete-on-merge gap)* The canon is delete-branch-on-merge for feature branches, but
  `auto-review-merge.yml` explicitly **does not** delete (`no --delete-branch; branches stay`).
  **Action:** enable delete-branch-on-merge and reconcile that workflow. *(Follow-up.)*
- **C-F5** *(#102 real state — measured)* The pre-compact capsule said *"#102 — all required checks
  green, blocked only on the protected-`main` review."* **That is correct:** the **6 required
  checks ARE green** on #102; the lone merge blocker is the **missing 1 approval** (`BLOCKED` /
  `REVIEW_REQUIRED`). The failures visible in the rollup — `.claude/settings.json hygiene`,
  `security / Trivy filesystem + IaC` (×2), `review`/`claude-review` — are **NOT required checks**
  (they are advisory) and do **not** block merge. *(An earlier draft of this entry wrongly called
  #102 "RED/blocking" — corrected.)* What the capsule **missed**: (a) `develop` is *also*
  review-protected (see C-F3), so re-targeting doesn't escape the approval gate — it just routes it
  to the separate principal correctly; (b) the branch was cut from `main` and is **15 commits behind
  `develop`** with overlapping `architecture/`, so re-targeting needs a `develop`→branch
  merge-resolve before a clean squash. **Resolution (owner-chosen):** fix the advisory failures
  separately (the settings-doctor finding = 5 hardcoded `/home/drdave/_work/...` marketplace paths
  in `.claude/settings.json` → env-manager/envctl territory, ADR-0006, **do not** casually rewrite);
  merge `develop` into the branch to resolve the lag; re-target base `main → develop`; squash-merge
  to `develop` with a separate-principal approval; promotion carries it to `main`. Never merge to
  `main` directly.

- **L-F1** *(the canon — answers the owner's 10 questions)* See **ADR-0003** + **`WORKFLOW.md`**.
  Summary: trunk=`develop`, mirror=`main` (promotion-only); feature branch off `develop` → PR into
  `develop` → CI green → squash (1 commit/task) → auto-promote `develop→main` (rebase, separate
  identity) → release-please. **≤1 task/commit; 1 task/PR; 1 task : 1 worktree; feature branches +
  worktrees ephemeral (deleted on merge); no `staging` branch; never clone repos not on disk.**
- **L-F2** *(failure flowback)* The signal exists today: `ci-failure-tracker.yml` files a
  `needs-autofix` issue on failure and auto-closes it on recovery. **Open automation gap (Q5):** the
  `needs-autofix` issue → handoff-loop-intake routing is currently manual/handoff-mediated, not
  auto-wired. Carry forward as a follow-up, not as drift.

### G. Cross-verification of the meta framework: "the separate principal is an AGENT, not a human" (2026-06-14, via `handoff-loop-run`)

Owner directive: the GitHub App (at envctl) + the self-hosted runner = a *local agent* that
manages GitHub issues and applies upgrades/fixes — taking the meta framework and **replacing the
human reviewer with an agent**. Ran the `handoff-loop-run` harness (`hf resume` → empty kernel,
North Star = "NO HUMAN IN THE LOOP") and cross-verified the structure against source.

- **L-G1** *(CONFIRMED — verdict model)* A **bot APPROVE is forbidden by design** (it bypasses
  branch protection). Source: `meta/handoff/hf/src/main.rs::cmd_review_verdict` — *"verdicts ride
  OUT-OF-BAND … Never a native GitHub APPROVE (bot-approval bypasses branch protection)"*; and
  `meta/flexnetos_github_app/crates/app-core/src/merge_gate.rs` — the App posts the gatekeeper
  verdict as a **GitHub check-run wired as a required status check** and arms native auto-merge
  only when green; *"never a native …[bot] APPROVE"*. So the autonomous separate principal's
  contribution is a **verdict-check-run + auto-merge arming**, NOT a review. The witnessed judgment
  is `hf review verdict <id> <pr> approve|deny --by <principal>` in the fleet ledger. **This
  corrected ADR-0003's shorthand "approval via the App."**
- **L-G2** *(verified state — DESIGNED + partially live; enforcement is SCAFFOLD)* The App is
  created/installed/sealed and its webhook→dispatch chain is proven live (`flexnetos_github_app`
  app_id 4044997, installation 140063898; key sealed in envctl). But the enforcement layer is
  **unbuilt**: `UnwiredMergeGate` fails closed (App P3 check-run executor not wired); envctl
  credential data-plane is `todo!()` (`inject.rs`/`run_child`); the code-omniscient gatekeeper is
  skill-only (HFTASK-0014); there is no `needs-autofix`→session router. Net: the App-agent **cannot
  yet** post the verdict-check-run or auto-merge — so it cannot autonomously approve agent PRs
  today. PROMOTE_TOKEN (separate-actor PAT) is the *working* separate principal, but only for
  `develop→main` promotion.
- **L-G3** *(DISCONFIRMED claim)* A sub-agent claimed `meta/handoff/NEEDS-HUMAN.md` carves out
  `.github_org` as a permanent human-review wall ("bot approval forbidden by design"). **`grep`
  found no such reference** — the claim is unverified and is **not** treated as canon. The owner's
  current directive is explicitly to extend the agent-as-reviewer automation to this repo too.
- **L-G4** *(GAP REGISTER — the path to no-human-in-loop, minted to the FLEET ledger)* In priority
  order: **G1** App merge-gate executor — wire `app-server` → `merge_gate.rs::GithubMergeGate` to
  POST the verdict check-run + arm auto-merge (`flexnetos_github_app` P3) — *the load-bearing gap*;
  **G2** envctl credential data-plane (`inject.rs`/`run_child` `todo!()`, Phase 8) so the App/agents
  get scoped tokens; **G3** build the code-omniscient gatekeeper (HFTASK-0014, gitkb/RuVector blast
  -radius judgment); **G4** `needs-autofix`→session dispatcher (consume `ci-failure` issues → mint
  fix task → open fix PR); **G5** switch `develop`/`main` branch protection to require the App
  verdict-check-run in place of the human review; **G6/G7** named tunnel + runner real `KernelInvoker`.
- **L-G5** *(#102 reality under this model)* Because G1/G2 are scaffold (and envctl/App/runner peers
  are offline/stale), the App-agent **cannot** approve #102 now. #102 stays correctly parked:
  base=develop, 6/6 required green, auto-merge armed, queued via `weave_review_add` + msgs to
  `flexnetos_github_app`/`handoff`. Its review today is a genuine wall (owner) **or** a
  separate-principal PAT — until G1+G2+G5 land and the App becomes the autonomous reviewer.
