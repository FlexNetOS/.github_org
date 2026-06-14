# 01 — Meta Control-Plane, Org Policy, CI/CD, Portability & Architecture Canon

This document is the faithful, human-navigable map of the ICM `system-architecture` memoir concepts that govern the FlexNetOS **org/repo control plane**: the `meta` meta-repo and its CLI, the verified architecture canon other tools must follow, the branch/CI-CD model, the v2 org policy and its full-fleet audit/verification/protection rollout, the total-internalization portability mission, and the architecture-truth census. It also carries the cluster of 2026-06-11 ADRs that re-grounded the system overview before build-out. Every concept below is reproduced from the ICM graph (`architecture/icm/memoirs/system-architecture.graph.json`) and corroborated against the memory topic dumps; ICM specifics (paths, crate names, PR numbers, HFTASK/ADR ids, dates, verdicts) are kept verbatim where they carry meaning.

> **Confidence note:** ALL concepts in this cluster except two carry ICM `confidence: 0.5` — i.e. below the 0.7 flag threshold. The exceptions are `decision-log-2026-06-09` (0.6) and `adr-2026-06-11-open-questions` (0.8). Per the export convention this is the memoir-extraction confidence, not a statement that the underlying facts are uncertain; several of these concepts are themselves labelled `status:verified` / `status:accepted`. The flag is recorded here once and not repeated per-section.

---

## 1. The control plane

### 1.1 meta-repo-control-plane
*Labels: `type:layer`, `role:repo-control`, `status:verified` — confidence 0.5.*

**ORG/REPO CONTROL PLANE.** `~/Desktop/meta` is a **META-REPO (NOT a monorepo)**: ~60 independent git repos listed in `.meta.yaml`, each its own remote under `FlexNetOS/`. The `meta` CLI clones all of them, runs commands across them in parallel (`meta exec`), manages cross-repo git worktrees (`meta worktree`), and takes snapshots. It is powered by:

- **`loop_lib`** — a pure-Rust rayon cross-dir command-execution library: `LoopConfig{directories, parallel, max_parallel, spawn_stagger_ms, dry_run}`, `DirCommand`.
- **`loop_cli`** — the binary `loop`.

**Safety:** `agent guard` blocks force-push / `reset --hard` / `rm -rf` on repo roots; snapshot-first discipline. The root `Cargo.toml` is a dev-convenience workspace; **each member builds/publishes independently**.

> Relationships: `meta-repo-control-plane` is `part_of` `stack-topology-reality`, `depends_on` `envctl-os-foundation` (see [03-envctl-kasetto](03-envctl-kasetto.md)), and `meta-architecture-canon` is `part_of` it. `kasetto-agent-provisioner` and `adr-2026-06-11-meta-loop-lib-status` are `related_to` it.

### 1.2 meta-architecture-canon
*Labels: `type:canon`, `status:verified`, `tag:critical` — confidence 0.5.*

**THE META ARCHITECTURE CANON (verified 2026-06-09)** — the yardstick other tools must follow.

**10 original core repos:**

| Repo | Role / state |
|---|---|
| `loop_lib` | rayon cross-dir exec engine |
| `meta_plugin_protocol` | JSON IPC: `PluginInfo` / `PluginRequest` / `ExecutionPlan` / `run_plugin` harness — **SOLID** |
| `meta_plugin_api` | legacy trait API — **STUB / superseded** |
| `meta_core` | `~/.meta` lockfile + state — **SPARSE** |
| `meta_git_lib` | git primitives |
| `loop_cli` | CLI over `loop_lib` |
| `meta_cli` | host orchestrator — **MATURE** (3-layer plugin discovery `.meta/plugins` → `~/.meta/plugins` → `PATH`) |
| `meta_git_cli` / `meta_project_cli` / `meta_rust_cli` | subprocess plugins — **MATURE / FUNCTIONAL** |

**Conventions a compliant member follows:**
1. separate git repo under `FlexNetOS/`, NOT monorepo;
2. registered in `.meta.yaml` with `provides` / `depends_on` / `tags`;
3. if exposing commands, be a subprocess plugin (binary `meta-*`, `PluginRequest` → `ExecutionPlan`, support `--json` / `--dry-run` / `--parallel` / `--include` / `--exclude`);
4. `RUST_LOG` target = crate name;
5. `.kb/` FlexNetOS knowledge base (optional but expected);
6. cross-repo work via `loop_lib` resource-aware parallelism (`max_parallel`, `spawn_stagger_ms`).

`meta_dashboard_cli`, `meta_mcp`, and `meta-plugins` are **newer, not part of the 10**.

> Relationships: `meta-architecture-canon` is `part_of` `meta-repo-control-plane` and is `refine`d by `policy-v2-meta-org`. `envctl-drift-and-merge-state` is `related_to` it; `handoff-kernel-relocated-to-meta` is an `instance_of` it (see [02-handoff-continuity](02-handoff-continuity.md), [03-envctl-kasetto](03-envctl-kasetto.md)).

### 1.3 stack-topology-reality
*Labels: `type:overview`, `status:verified`, `tag:critical` — confidence 0.5.*

**CORE TRUTH (verified 2026-06-09):** the FlexNetOS agentic dev stack is **NOT a wired pipeline.** It is a set of independent, dependency-light tools (mostly Rust) that integrate only loosely through **TWO shared substrates**:

1. the **weave mesh** for cross-agent coordination, and
2. **committed files on disk** (`HANDOFF.md`, lock files, markdown artifacts, `_workspace` backlogs) as sources of truth.

**No tool calls `prompt_hub` / `rusty-idd` / `kasetto` / `weave` directly in code;** the "pipeline" from intent to PR is currently composed by **convention and harness skills, not by code-level integration contracts.** This is the central design fact and the main gap to close.

> `stack-topology-reality` is the hub concept: `meta-repo-control-plane`, `weave-coordination-substrate`, `prompt_hub-front-door`, `kasetto-agent-provisioner`, `envctl-os-foundation`, `n8n-external-glue`, `ruflo-is-claude-flow-v3`, `ruvector-pass1-shape`, `rusty-idd-merge-planner`, `rtk-token-optimization`, and `icm-persistent-memory` are all `part_of` / `related_to` it, and `projects-all-incomplete` is `related_to` it. The "main gap to close" is the seam work tracked in [08-gaps-seams-merge](08-gaps-seams-merge.md).

---

## 2. Branch & CI/CD model and the org-policy canon

### 2.1 FlexNetOS branch/CI-CD model
*Labels: `domain:devops`, `type:reference`, `project:handoff`, `adr:0001` — confidence 0.5.*

Observed reality (ADR-0001 §3/§9, Research R8, live `gh`-api):

- **BRANCHES:** `master` = protected trunk + PR target (never pushed directly, CI-gated PR merges only); `develop` = long-lived integration base kept fast-forwarded `== trunk` (its only job: the ref worktrees branch from, so a stale local checkout never seeds a session). **`main` and `master` are two names for the one trunk role;** GitHub default = `main`, weave/handoff use `master`. **Only weave actually has a `develop` branch + live branch protection** (6 required checks: `rustfmt`, `clippy`, `test`, `build(libsql)`, `sign`, `libsql+sign`; `strict=true`; `enforce_admins=false`; **NO required reviews**). All other FlexNetOS repos = `main`, no `develop`, no protection.
- **REMOTES:** single `origin = git@github.com:FlexNetOS/<repo>.git` (SSH), **clone model everywhere (no forks).** Fork model = `origin`(your fork) + `upstream`(truth), **deferred**.
- **AUTOMATIONS:** `repository_dispatch` mesh (peter-evans, SHA-pinned) gated by `wait-on-check`; events `child-repo-updated` / `dependency-updated` / `release-tagged`.
- **SECRETS:** all org-level (`PARENT_REPO_PAT`, `CARGO_REGISTRY_TOKEN`, etc.); **ZERO GitHub Environments anywhere = the key hardening gap** (merge-gate Environment is HFTASK-0012).
- **Least-priv permissions:** blocks are disciplined (`{}`, `contents:read`, scoped write).

> Relationship: `FlexNetOS branch/CI-CD model` and `gh-aw separation-of-privilege gate` are both `part_of` **Handoff Loop v2 (ADR-0001)** — see [02-handoff-continuity](02-handoff-continuity.md). `rusty-idd merge model + meta conventions` is `related_to` this model — see [08-gaps-seams-merge](08-gaps-seams-merge.md).

> **Note — later evolution of the branch model.** The memory dump `decisions-meta` records a 2026-06-13 owner general principle that **supersedes the "clone model everywhere / only weave protected" snapshot above**: *"every repo needs `develop` (trunk) + `master`/`main` (protected mirror), create-if-missing — roll out AFTER the envctl protection mechanism is proven."* This is the develop-mirrors-master model already running on envctl (`develop` is the superset trunk, `master`/`main` the protected mirror fast-forwarded by a sync workflow). See [03-envctl-kasetto](03-envctl-kasetto.md) for the envctl-specific protection saga.

### 2.2 policy-v2-meta-org
*Labels: `type:adr`, `status:active`, `session:2026-06-12`, `domain:org-policy`, `tag:critical` — confidence 0.5.*

**STATUS: active.** POLICY v2 synthesized + written to `~/Desktop/meta/META-ORG-POLICY.md` (2026-06-12). Context: org-audit mission Phase 1; **code-verified against all 10 canon repos + parent + live `gh` api (no prose trusted).**

**Finding — the policy = canon conventions ⊕ rusty-idd alignment ⊕ handoff addition,** tiered:

| Tier | Scope |
|---|---|
| **A** | canon — **full policy** |
| **B** | FlexNetOS tools — **full policy** |
| **C** | forks — registration / remote / pin / drift ONLY (**no CI forcing**) |
| **D** | hubs / docs — registration + docs-accuracy |

**KEY ENGINEERING TRUTH discovered:** the PARENT meta repo **IS the rusty-idd-alignment exemplar** (VERSION 0.2.22 + release-please manifest mode w/ `workspace.package.version` extra-file + renovate `config:recommended` + rust-toolchain `stable` + Makefile + `.githooks{commit-msg=commitlint npx w/ offline fallback, pre-commit, pre-push}` + `semantic-pr-title.yml` + agent-guard hook + `.claude/rules`) — alignment items already **LANDED at parent**; policy propagates them outward. Canon members use `version.workspace=true` → per-repo release-please/VERSION is **WRONG for Tier A** (parent versions the distribution); standalone Tier B (weave 0.2.0, envctl 0.1.0) self-version and replicate the pattern in-repo when releasing.

**Canonical child workflow set verified:** `ci.yml` (3-OS matrix + `clippy -D warnings` + fmt-check + synthesized-workspace-wrapper trick; consumers add `repository_dispatch dependency-updated` + clone-deps), `auto-format.yml`, `notify-downstream.yml` (libs; matrix mirrors `.meta.yaml` dependents) / `notify-parent.yml` (leaves → `child-repo-updated` → meta `on-child-update.yml` auto-sync-PR). Dispatch graph verified = `.meta.yaml` dependency edges + `meta_cli → meta_mcp`. **Secrets org-level only:** `PARENT_REPO_PAT` (×18 uses), `REPO_WRITE_PACKAGES_PAT` (parent release dispatch).

**LIVE GAPS (audit feed):** protection 404 on ALL 10 canon (only weave/master protected fleet-wide), `auto_merge` + `delete_branch_on_merge` false everywhere, semantic-pr-title parent-only, renovate missing on 5 (`loop_lib`, `loop_cli`, `meta_core`, `meta_plugin_protocol`, `meta_git_lib`), `.kb` absent in all canon children, canon `.meta.yaml` entries untagged, `meta_plugin_api` = 109-line stub no workflows (disposition pending).

**P6 handoff addition:** fresh worktree/session, `hf claim`/`checkpoint`/`handoff` + `.handoff` ledger truth, weave path-lease on claim (`Leaser`/`WeaveCli`), `kasetto sync --locked` preflight where `kasetto.yaml`, AI gatekeeper as **REQUIRED STATUS CHECK** w/ out-of-band verdicts (never bot-approve), protection w/ real CI checks.

**Consequences:** `META-ORG-AUDIT.md` (Phase 2) scores every member against tier subset; Phase 4 applies protection. References: `META-ORG-POLICY.md`, `meta-architecture-canon`, `ship-loop-proof-2026-06-12`, `adr-2026-06-11-repo-docs-accuracy`.

> Relationships: `policy-v2-meta-org` `refines` `meta-architecture-canon`; `org-audit-results-2026-06-12` is an `instance_of` it.

### 2.3 gh-aw separation-of-privilege gate
*Labels: `domain:security`, `type:pattern`, `project:handoff`, `source:gh-aw` — confidence 0.5.*

PR-automation guardrail model adopted from **GitHub Agentic Workflows (`github/gh-aw`)** into **Handoff Loop v2 §5a**:

- Worker/reviewer agents run **read-only** and emit structured intents/verdicts **as DATA**; a separate **trusted, narrowly-scoped, non-agent job** performs `gh pr create`/`merge` — **agents never hold the merge token** (even in the Phase-2 swarm).
- The reviewer verdict stays **OUT-OF-BAND in weave state, never a native GitHub APPROVE** (a bot APPROVE silently satisfies branch-protection required-reviews and defeats the gate; `gh-aw` issue #25439).
- Merge is an **Environment-gated job**, so human → swarm is a **change of approver, not of agent capability.**
- Plus: detection pass + protected-files denylist (`.github/`, `.handoff/policy.toml`, ADRs, manifests), draft PRs, least-privilege per-action tokens, egress allowlist.
- **`gh-aw` deliberately ships NO merge safe-output.**

> Relationship: `part_of` **Handoff Loop v2 (ADR-0001)** — see [02-handoff-continuity](02-handoff-continuity.md). The "AI gatekeeper as REQUIRED STATUS CHECK" and "merge-gate Environment" referenced in [policy-v2](#22-policy-v2-meta-org) and the protection rollout below are the org-side realization of this gate (HFTASK-0010, HFTASK-0012, HFTASK-0014).

---

## 3. The org-audit mission (2026-06-12): audit → verify → protect

These three concepts are the executed Phases 2 / verification / 4 of the org-audit mission against [policy-v2-meta-org](#22-policy-v2-meta-org). They are linked in a chain: `org-audit-results` is an `instance_of` `policy-v2-meta-org`; `org-audit-verification` is an `instance_of` `org-audit-results`.

### 3.1 org-audit-results-2026-06-12
*Labels: `type:audit`, `status:verified`, `session:2026-06-12`, `domain:org-policy`, `tag:critical` — confidence 0.5.*

**STATUS: verified** — full-fleet audit complete, fixes landed; written to `~/Desktop/meta/META-ORG-AUDIT.md`. Context: org-audit mission Phase 2 against `policy-v2-meta-org`.

- **FINDINGS:** fleet 60 registered projects (4 stale `weave-*` second-checkout entries **DEREGISTERED** — extra checkouts of `FlexNetOS/weave` for completed epics, not forks); all genuine org repos; everything clean + synced.
- **FIXED THIS AUDIT** (all PRs merged green, user granted session merge authority): `meta_cli#1` rustfmt ollama consts (red Format on main from `29770d1`); `teri#1` fmt×12 + clippy; `shimmy#1` clippy×5 + `publish=false` (upstream 2.2.0 ships `publish=true` contradicting its own regression test — **sided with test, fork is binary-only**) + workspace-aware test binary paths (`./target` vs `../target` — cargo workspace membership moves the target dir); **conventions wave = 11 PRs** adding `semantic-pr-title.yml` everywhere + `renovate.json` on the 5 canon gaps, **ALL MERGED.**
- **RUFLO HOMED:** `FlexNetOS/ruflo` created via `gh repo fork` (**SILENT SUCCESS again** — stdout empty, verified by org re-query; correct name, no suffix); origin/upstream rewired; pin branch `pin-meta-2026-06-12` (`dfe1b9cf9`; local main intentionally behind fork main — push of pinned older main would be non-FF, so **pin-branch pattern records the drift point** instead).
- **KASETTO FOUND:** org repo `env_manager_agent` = fork of `pivoshenko/kasetto` (created 06-03) — **open-questions #5 RESOLVED**; registered in `.meta.yaml` as `kasetto`, cloned, upstream added (fork 3.0.0 < installed binary 3.1.0, FF candidate).
- **ORG DELTAS:** `shimmy-1`/`teri-1` auto-suffix artifacts → recommend delete (NEEDS-HUMAN); unregistered org repos `harness` (fork revfactory/harness), `slim` (nilbuild/slim), `global_projects_config` (private), `demo-repository` (API timeout) → user disposition; **14 private repos** incl A2 code repos `meta_dashboard_cli` + `meta-plugins` (inconsistent w/ public canon; **child CI clones are ANONYMOUS so cross-clones of private break**) — visibility = human-only.
- **CodeQL** default setup enabled **org-wide ~04:18Z 2026-06-12** by `drdave-flexnetos` (the "Push on main" dynamic workflows).
- **PROTECTION REALITY:** 3 protected (`.github/main` w/ 1 review + lint suite, `lane/main`, `weave/master` 6 checks) — **corrects "only weave" memory.**
- **RESIDUALS:** `meta_dashboard_cli` zero-CI + private + master; `meta_plugin_api` stub disposition (archive preferred, zero reverse deps verified); handoff CI = HFTASK-0012; atc `action_required` gating; untriaged tags.
- **GOTCHAS LEARNED:** `gh pr checks` has **no `--json`** on this gh version (use `pr view --json statusCheckRollup`); awk parsing of check names with spaces is a trap; **clippy errors can MASK later ones** (lib-test failure hid 9 `assert_cmd` deprecations in `cli_integration_tests` — LSP had them right).
- **PR #11** (parent CI workspace-roots fix): Clippy + Format now PASS after the three fork fixes; **Tests pending at audit close.**

References: `META-ORG-AUDIT.md`, `policy-v2-meta-org`, `/tmp/fleet.json`, `/tmp/org-repos.jsonl`, worktree `org-audit-ci-fixes`.

### 3.2 org-audit-verification-2026-06-12
*Labels: `domain:org`, `type:verification`, `project:meta`, `date:2026-06-12` — confidence 0.5.*

**Adversarial verification (session 4, 2026-06-12 evening)** of every load-bearing claim from `org-audit-results-2026-06-12`, **treating the prior session as an untrusted agent;** live code/API/ledger state = truth.

**VERDICT: all clusters PASS** —
- **A:** all 19 merged PRs individually re-queried + conventions files verified on 10 repos.
- **B:** fork homing genuine (`ruflo`/`kasetto`/`vox`/`rusty-idd`).
- **C:** stray sweep **PASS WITH DELTA** — the personal weave remote was mutated post-session (6 `feat/*` branches deleted server-side, master moved `e6175e4 → ccc1ce30`) but the archive `~/Desktop/_archives/weave-desktop-pruned-2026-06-12` holds all 6 SHAs (`git cat-file` verified) so **prune safety holds.**
- **D:** protection matrix exact (sampled 8/24), visibility freeze intact (14 private = audit list).
- **E:** witness chain independently recomputed from `.handoff/ledger.db` — 16 events, `prev_hash ↔ action_hash` 0 breaks, zeroed genesis, `seq14 = review_verdict ask_66 approve`, `seq15 = pr_opened checkpoint`.
- **F:** full workspace battery via rtk-bypass script — fmt/clippy/test all exit 0, **52 suites / 3527 tests / 0 failed.**
- **G:** intentional states preserved untouched.

**CHAIN COMPLETED:** `teri#2` (already merged `561ab31`) → **NEW DEFECT** shimmy `INVARIANT_LOG` global-state test race diagnosed (PR#11 attempt5 ubuntu, 358 passed/2 failed) → reproduced 198/600 stress, fixed with `#[serial_test::serial]` on all 12 clearing tests → `shimmy#4` merged `4ba612d`, 0/600 post-fix → `meta PR#11` attempt6 all green, auto-merged `b12f3c7ab` → `docs PR#12` merged `f48ad885` (POLICY/AUDIT/NEEDS-HUMAN/SESSION-HANDOFF/VERIFICATION-REPORT on main) → **meta main CI workflow GREEN for the first time since 2026-06-04,** confirmed on two consecutive main commits.

**SECOND NEW DEFECT exposed by green main:** Release Please job **red on every main push** — *"Input required and not supplied: token"* because **org secret `PARENT_REPO_PAT` is NOT granted to `FlexNetOS/meta` itself** (only child repos); fixed forward via PR#14 token fallback `PARENT_REPO_PAT || GITHUB_TOKEN` with documented caveat (GITHUB_TOKEN-created PRs trigger no CI → release PRs cannot auto-merge until human grants the org secret — **NEEDS-HUMAN item 2** sharpened with exact `gh api PUT` command).

**HONEST DELTAS recorded in `VERIFICATION-REPORT.md`:** weave remote mutation, parent-main unpushed `39423c3` (absorbed by #12 squash, dropped on pull via patch-id), session-3 "expected green" overclaim, NEEDS-HUMAN 0/7 actioned by human, handoff `active.md` residue (fixed via handoff#4). **GitHub-native auto-merge observed completing 3× in production this session** (handoff#4, meta#11, meta#12; #14 armed).

**METHOD LESSONS:** rtk hook silently filters cargo/grep output (bypass via script files; exit codes = truth); a passing battery does **not** disprove a scheduling race — stress-loop suspicious tests ×600; **gh mutations can succeed silently — always re-query;** agent-guard blocks `git branch -D` even for squash-merged branches (tree-identical branch left as residue rather than dodging the guard).

### 3.3 org-protection-rollout-2026-06-12
*Labels: `type:rollout`, `status:verified`, `session:2026-06-12`, `domain:org-policy`, `tag:critical` — confidence 0.5.*

**STATUS: verified (GET-after-PUT)** — Phase 4 of the org-audit mission applied **branch protection to 24 FlexNetOS repos** + **auto-merge / delete-branch-on-merge to 26** (2026-06-12 ~18:20Z).

**PROFILE:** `required_status_checks{strict:true, checks:per-repo REAL PR-running checks}`, `enforce_admins:false`, **NO required reviews** (autonomous-loop compatible), `allow_force_pushes:false`, `allow_deletions:false`.

**CRITICAL DESIGN RULES learned/applied:**
1. **only require checks that run on `pull_request` events** — push-only checks (`notify-*`, Release Please, Trigger Release Build) or variable CodeQL dynamic names as required = **merges bricked forever;** trigger lists verified from each repo's workflow files before applying.
2. required-status-checks gate **PR MERGES not direct pushes** → `auto-format.yml` main-pushes keep working; **force-push/deletion blocking is the real safety win.**
3. AI-gatekeeper required check is added **only WHEN the check exists** (Phase 5 HFTASK-0010) — **never pre-emptively.**
4. merge-gate Environment (ADR-0001) created **together with its consumer, not before.**

**CHECK SETS:**
- `meta/main` = `Clippy, Format, Test×3, Integration×2, SemanticPRTitle`
- canon + `meta_mcp` + agent = `Clippy, Format, Test×3 (+Semantic where rolled)`
- `prompt_hub` = `Check, Clippy, Format, Test-stable×3, CargoAudit, CargoDeny`
- `rusty-idd/develop` = `rust, msrv`
- `atc` = `CI`
- empty-checks anti-force-push on `meta_plugin_api`, `meta_dashboard_cli`, `obscura`, `handoff`, `envctl`, `vox`, `icm`, `rtk-tokenkill`.
- Pre-existing `weave`/`lane`/`.github` untouched.

**`NEEDS-HUMAN.md`** created at meta root: shimmy-1/teri-1 deletion, org-secrets listing (classifier-blocked), `meta_dashboard_cli` + `meta-plugins` visibility, `meta_plugin_api` archive, unregistered repos (`harness`/`slim`/`global_projects_config`/`demo-repository`), `env_manager_agent → kasetto` rename, atc `action_required` gating.

References: `META-ORG-AUDIT.md` Phase-4 section, `org-audit-results-2026-06-12`, `/tmp/check-map.json`.

> **Note — later evolution of protection ownership.** The memory dump `decisions-meta` (2026-06-13) records an owner decision that **fleet branch-protection + auto-merge enablement is OWNED by the designated GitHub-management repos (`flexnetos_github_app` / `github_org` / `meta_git_cli` / `flexnetos_runner`), NOT an ad-hoc `meta/scripts/` script** (`meta/scripts/enable-auto-merge.sh`, PR #29, is a **reference only**). Hard-won facts the implementation must honor: per-repo default branch varies (envctl=develop, hubs=master, others=main; read `.default_branch`); required-check contexts must come from a recent **pull_request's** check-runs, not the default-branch push; **`.fork=true` covers BOTH true upstream mirrors (don't protect, breaks sync) AND intentionally-diverged FlexNetOS forks (icm/grit/obscura/teri/vox/shimmy/rtk — drift intentional, SHOULD be protected)**; `no required_pull_request_reviews` so PRs self-land, `strict=false`. As of that session: `allow_auto_merge` on 63 repos; protection on `icm/main` + `envctl/develop`. This refines (and partially supersedes the exact counts of) the 2026-06-12 rollout above.

---

## 4. Portability mission — total internalization (ADR-0006)

### 4.1 meta-portability-2026-06-12 (wave 1)
*Labels: `domain:portability`, `type:mission`, `project:meta`, `date:2026-06-12`, `tag:critical` — confidence 0.5.*

**PORTABILITY MISSION wave 1** (session 5, 2026-06-12 late evening; spec = `PORTABILITY-SESSION-PROMPT.md`). **Scope TOTAL per user:** *"all work on this system is now meta work; nothing outside meta",* sole exemption = IDE apps.

**DECISION RECORD = ADR-0006** (handoff/docs, merged `d748e45`):
- **`envctl` is the single box materializer** (adopt-then-extend; GNU stow and a new `meta env link` **REJECTED** — envctl already had the component/wiring/lock model and owned the whole yazelix stack).
- `envctl/home/` = canonical home tree for user-global non-secret configs, wired by **archive-first symlink components** (`manifest/components.d/portability-links.toml`: `home-config-links`, `home-bin-links`, `meta-tool-links` version-guarded, `claude-global-links` last, `group-portability`).
- **binary canon = symlinks to `target/release`** (lane pattern, fixed lane debug→release).
- **kasetto stays the agent layer** (its own yaml says "the OS/toolchain layer is envctl").
- **secrets** (gh `hosts.yml`, `.credentials.json`, keyrings, vault) **and state** (histories, caches, `vox.db`, voices, models, `~/.local/share`) **NEVER internalize.**

**SHIPPED:**
- `envctl#34` merged `f7ec378` (home/ 24 reviewed files — repo is PUBLIC, **per-file secret review mandatory**; fixes baked in: claude settings weave hooks debug→release ×4, `speak.md` `vox -b say`→`piper`, `env-ctl.service` doc path, repowire incident header).
- **yazelix homed** (genuine fork `FlexNetOS/yazelix` verified `parent=luccahuguet/yazelix` via REST after GraphQL showed `parent:null` — **silent-success lesson**; clone at `meta/yazelix`; pin branch `pin-meta-2026-06-12` = installed nix rev `e60d15e`; envctl `nix-yazelix.toml` URL flipped to fork; `~/.config/yazelix` is USER CONFIG ONLY, software = nix profile, `~/.local/share/yazelix` = upstream-sanctioned state).
- `meta PR#17` (`.meta.yaml` +yazelix +agent-skills, `.gitignore`, root `Cargo.toml` exclude kasetto — cargo workspace-inference error fixed; `scripts/bootstrap.sh` 6-phase sequencer `rustup → meta git update → release builds → envctl install → kasetto sync --locked dry-run-first → doctor + lock --check`; `PORTABILITY-AUDIT.md` + PROMPT tracked, session-5 SESSION-HANDOFF).

**APPLIED ON-BOX:** 40 symlinks into meta (was 3); 18 config links + 6 claude-global links (smoke: JSON parses, weave Stop hook resolves release, `claude --version` OK) + 15 binary links (`meta`/`meta-git`/`meta-project`/`loop`/`lane`/`grit`/`envctl`/`envctl-gui`/`meta-dashboard`/`icm 0.10.50`/`vox 0.14.0` + cargo-bin `weave`/`grit`/`secretctl`/`secretd`). **STALE CARGO-BIN WEAVE IS DEAD** (lease verbs verified at `~/.cargo/bin/weave` → `HF_WEAVE_BIN` workaround obsolete); **rtk SKIPPED by the never-downgrade version guard** (installed 0.42.2 > checkout build 0.42.0 — `rtk-tokenkill` checkout behind installed binary; sync+rebuild to converge); kasetto/kst skipped pending #17 exclude; repowire unit disabled (crash-loop on missing binary, 268MB log → `incidents/repowire-unit-crash-loop`, reversible).

**Phase-4 proof PARTIAL (honest):** branch clone carries kit, bootstrap `--dry-run` phase 0 runs, ZERO dangling links; **NOT proven: virgin-`$HOME` envctl install end-to-end.**

**GOTCHAS:** `systemctl --user disable` DELETES symlinked unit files (disable first, link after); **GitHub auto-merge cannot arm on branches with zero required checks** (envctl → local gates + direct merge); `gh pr update-branch` doesn't exist in this gh (use `gh api -X PUT .../update-branch`) and the API merge commit DIVERGES the local branch (`git pull --no-rebase` before pushing); **CONCURRENT WRITER reality:** a parallel session merged meta#13/#15/#16 + handoff#5/#6 (ADR-0005 steward, NEEDS-HUMAN restructured to owner-decisions/genuine-walls; SESSION-HANDOFF got DUAL session-5 packets — resolved by keeping both in full).

**RESIDUE (wave 2):** rtk sync+relink, meta-mcp + kasetto builds, `/usr/local/bin` sudo phase (archon/vox root copies, yazelix-* scripts), absolute-path substitution pass, work-dir relocations (`~/Downloads/tmp` — handoff dir BLOCKED on the forgotten-directive cross-ref, now also ADR-0004's design source), bashrc legacy dedupe, native `wiring.symlink` engine kind via Feature Forge, full virgin-home proof.

> Relationship: `meta-portability-2026-06-12` `refines` `adr-2026-06-11-open-questions` (it resolves open-question #16). See [03-envctl-kasetto](03-envctl-kasetto.md) for the envctl materializer and secrets engine.

### 4.2 portability-wave2-2026-06-13
*Labels: `domain:arch`, `type:decision`, `mission:portability`, `date:2026-06-13` — confidence 0.5.*

**PORTABILITY mission wave 2 (resumed 2026-06-13).** Two architectural learnings worth keeping:

1. **ENVCTL `meta-tool-links` DETECT must check the FULL set of always-buildable meta tools, not a single sentinel.** The original detect `[ -L ~/.local/bin/meta ]` short-circuited the whole component once `meta` was linked, so any tool added LATER (here: `meta-mcp`) never re-converged and stayed a stale copy. Fixed to check `meta meta-mcp loop lane grit`; **version-guarded externals (`rtk`/`kasetto`/`kst`) are deliberately EXCLUDED from detect** because a repo build behind the installed binary must be allowed to skip without wedging detect false forever. **Idempotency lesson: a component's detect must encode the FULL desired end-state, not a proxy.**
2. **NEVER-DOWNGRADE guard fired correctly for kasetto/kst:** meta/kasetto checkout builds 3.0.0 while the installed binary is 3.1.0 — **link-inversion HELD,** blocked on FF'ing the `FlexNetOS/kasetto` fork to 3.1.x.

`settings.json` absolute paths are **BY DESIGN** (rendered from `settings.json.tmpl` + `${META_ROOT}`, TASK-0005) — the `.tmpl` is the portable source, not a defect.

**Cross-ref `forgotten-directive` CLEARED:** `~/Downloads/tmp/handoff` is the **original Ark Handoff Ledger PRD package** (24 files, not git); `meta/handoff` is the **realized superset** (90 files, `hf` Rust kernel); the PRD is preserved in meta as `handoff/docs/Continuity_Ledger_Kernel_PRD.md` — **meta is NOT a lite/downgrade.**

**PRs:** `envctl#42` (de-hardcode home tree + detect fix), `meta#22` (audit). Both squash-auto-merge armed.

> Corroboration (`context-adr-0006-portability` memory dump): ADR-0006 accepted 2026-06-12; envctl = single source of truth for secrets, binaries, and user-global configs. **ADR-0007** (retire `flexnetos_secrets` → envctl) and **ADR-0008** (`flexnetos_github_app` + `flexnetos_runner`) created and pushed 2026-06-12. `NORTH-STAR.md` is the durable owner-approved steward compass (changes only by owner intent). The portability contract in one line (`context-meta` memory): **"real file in meta, symlink outside."**

---

## 5. Architecture-truth census & estate state

### 5.1 architecture-truth-census-2026-06-12
*Labels: `type:adr`, `status:accepted`, `session:2026-06-12`, `domain:org-architecture`, `tag:critical` — confidence 0.5.*

**STATUS: accepted** — full-estate census delivered as `ARCHITECTURE-TRUTH.md` + `GAP-REGISTER.md` (meta root, 2026-06-12, upgrade mission Phases 2-3).

**METHOD:** **58-repo read-only Workflow fan-out** (`wf_a40b236a`, one agent/repo, roles from **code not READMEs**) + direct walks for RuVector/ruflo/envctl (**no-subagent rule**) + hand spot-verification of load-bearing claims (obscura, claude-plugins, vault_hub, handoff cards).

**FINDINGS: 62 units — 40 active, 12 husks, 5 in-dev, 1 stale.** FIVE PLANES verified:
1. **Foundation** = 11 originals + parent + `meta_dashboard_cli` A2 (lineage harmony-labs → gitkb → FlexNetOS, Matt Walters; no canon READMEs).
2. **AgenticOS** = RuVector 314-crate pinned fork + ruflo (only live code edge = `handoff → rvf-crypto`).
3. **rtk-tooling** = `rtk`/`icm`/`vox` active daily + **`grit` = AST function-level LOCK COORDINATOR for parallel agents** (NOT github-workflows per se — vision nuance recorded).
4. **Continuity** = handoff kernel (**ONLY `.handoff` in fleet, 1/58!**), weave (ADR-0002 proven), atc (gitkb-era dispatcher, seam decision needed), rusty-idd (fail-closed merge model source).
5. **Features:** `teri` = MiroFish rewrite **CONFIRMED independently** (petgraph KG + persona agents) + `shimmy` = inference slot; `prompt_hub` healthy core but **ZERO MCP/dispatch**; `obscura` = Rust headless browser (V8/CDP) = lane's web-access upgrade (**census misplane corrected**); 12 hubs (Hub Standard, half empty); 5 unborn `flexnetos_*` husks.

**KB ↔ HANDOFF SEAM ANSWERED:** `git-kb` = knowledge/planning plane (`/kb-board` `/kb-tasks` `/kb-commit` `/kb-status`), `.handoff` = execution/witness plane (Git > ledger > cards); link today one-way + thin; **ADR-0003 to freeze minting/write-back/single-registry rules.**

**DEFECTS D1-D12:** claude-plugins sources point at DEAD gitkb org; vault_hub vendors kasetto copy; handoff 22 cards all backlog w/ dead `spike/**` scopes; prompt_hub identity drift (nonexistent `prompthub` org); kasetto fork 3.0.0 vs installed 3.1.0; harness_hub misattributes `revfactory/harness`.

**LOOP-HARNESS TRUTH:** 8 repos have loop residue, **only lifeos genuinely broken** (dead paths); weave/lane/rusty-idd/n8n closed legitimately — **the "broken harnesses" vision premise largely corrected.**

**GAP-REGISTER verdicts:** items 1,8 done; 3,4,5,6,9,15 partial; 2,7,10,11,12 gap; 13,14 design-open. **COGNITUM USB MOUNTED + READABLE (standing wall cleared)** — item 15 unblocked.

**SEQUENCING:** P4 fleet `.handoff` → W1 env+COGNITUM ‖ W4 MiroFish matrix → W7 front door (HFTASK-0003/0019 cruxes) → P6 steward → rest; RuVocal LAST. References: `ARCHITECTURE-TRUTH.md`, `GAP-REGISTER.md`, census raw rows in session task `w281dz1m5` output, `VERIFICATION-REPORT.md`, `UPGRADE-MISSION-PROMPT.md`.

> Corroboration (`workspace-census` memory dump): census 2026-06-12 (session `d5d1e86e`, arch-census workflow), **58 repos: Tier A=12 (canon `meta_*`/`loop_*`), B=10 (FlexNetOS tools), C=20 (third-party forks), D=16 (hubs/docs)**; 40 active / 5 in-dev / 12 empty-or-stub / 1 stale. `my-wiki` & `network_hub` = pure stubs; `vault_hub` catalogs 1508 skills + vendored kasetto 3.0.0; prompt_hub at cycle 82 (P1 13/13); handoff 22 task cards, only A1 resolved; weave on develop-mirrors-master with loop residue; n8n loop in stand-down (D-1 blocked on docker); `rtk-tokenkill` fork with rusqlite 0.40 patch for meta-workspace sqlite-links conflict. **Stale repo: `agent-skills` (DELETED from GitHub, not in workspace).** Row data in `.kb/docs/census-workspace-arch.json` + `.handoff/census-workspace-arch.json`.

> Relationships: `architecture-truth-census-2026-06-12` `refines` `org-audit-results-2026-06-12`; `upgrade-mission-results-2026-06-12` is `part_of` it; `mirofish-port-decision` is `part_of` the upgrade-mission. The five-planes detail (RuVector, weave, handoff, prompt_hub, gaps) maps to sibling docs — see [Cross-references](#cross-references).

### 5.2 upgrade-mission-results-2026-06-12
*Labels: `type:session-result`, `status:active`, `session:2026-06-12`, `domain:upgrade-mission`, `tag:critical` — confidence 0.5.*

**STATUS: session 5 complete (2026-06-12 evening).** The **VERIFY → UNDERSTAND → UPGRADE** mission over the whole estate.

- **Phase 0/1:** verified session-4 results + **closed the LITE-downgrade directive** (design bundle ≠ fuller impl; absorption items: `session.schema.json` → HFTASK-0007, hooks/policies/skills templates → fleet layer, `backlog.yaml` cross-check) + PR#11/#12 merged natively.
- **Phase 2:** `ARCHITECTURE-TRUTH.md` (58-agent census workflow + direct walks; 62 units, 5 planes; corrections: obscura = headless browser → network, grit = AST lock coordinator; teri = MiroFish rewrite confirmed independently; defects D1-D12; **only 1/58 repos had `.handoff`**).
- **Phase 3:** `GAP-REGISTER.md` (15 items: 2 done, 6 partial, 5 gap, 2 design-open; W8 scoreboard 1/12 ruvector families integrated).
- **Phase 4 LANDED:** ADR-0003 kb↔handoff seam + ADR-0004 fleet rollout (handoff#5), policy P7.31-36 (meta#13), **21/21 A/B repos seeded** (17 auto + 4 direct; snapshot `pre-p7-rollout`), 20 fork capsules central at `handoff/.handoff/fleet/` (handoff#6).
- **Phase 6:** `NORTH-STAR.md` + ADR-0005 steward + witnessed verdict (`review_verdict approve fleet-handoff-rollout (13)` by steward) + **SCOPE LAW** from two classifier denials (verdicts sequence within scope, never expand; hub + fork stub batches escalated to owner).
- **Phase 5:** W1 `COGNITUM-SEED.md` (hardware root of trust: HW witness chains, Ed25519 custody+attestation, 114-tool MCP w/ witness binding; mass storage readable, **USB-Ethernet needs data port**; envctl secrets-engine surface verified `inject.rs`/`ca.rs`/`vault`); W3 ADR-0002 re-verified PASS all 5 surfaces (`ReviewItem` verdict-free — 5 hits all doc comments); W4 `mirofish-port-decision`; W7 prompthub-server BOOTS (libsql + migrations, **auth-key wall, dispatch seam = the real gap**); W8 scoreboard.
- **Phase 7:** docs PR `meta#16` (9 files, NEEDS-HUMAN refresh w/ owner decisions A-C, SESSION-HANDOFF session-5).
- **INCIDENTS:** `kb-workspace-sync-silent-drop` (kb body edits dropped; creation works — **blocks ADR-0003 write-back**).
- **OWNER QUEUE:** hub/fork stub batches (exact commands), Seed data-port replug, dependabot high, + the 7 audit walls.
- **NEXT TRANCHE:** kernel verbs (`task mint --from-kb`, `checkpoint --sync-cards` fixing 22 stale cards, `fleet status`), HFTASK-0007 session verb, HFTASK-0003/0019 front door, MiroFish P1.

References: all root docs; `tasks/fleet-handoff-rollout` (kb); meta#13/#15/#16, handoff#5/#6.

### 5.3 completion-state-2026-06-09 & projects-all-incomplete
*`completion-state-2026-06-09` labels: `type:completion-audit`, `status:verified`, `tag:critical` — confidence 0.5.*
*`projects-all-incomplete` labels: `type:root-cause`, `status:user-stated`, `tag:critical` — confidence 0.5.*

These two are paired: `completion-state-2026-06-09` `refines` `projects-all-incomplete`.

**completion-state-2026-06-09 — VERIFIED COMPLETION STATE (evidence-based audit 2026-06-09):**

| SOLID foundations (build contracts against) | State |
|---|---|
| `kasetto` | ~95% (v3.0.0, production, **the most-done tool**) |
| `weave` v0.2 CORE | ~done + tested (**38 tests:** messages/jobs/peers/asks/presence-daemon/cross-store all REAL) |
| `prompt_hub` CORE | ~85% (**724 tests;** vibe/get/SwarmBundle/search/HTTP all real) |
| `obscura` | COMPLETE (Rust headless browser, production) |
| `envctl` ENV-MANAGER phases 0-5 | ~90% |
| `rusty-idd` | ~85% (real repo at `~/Desktop/idd-merge-idd` **NOT Downloads**) |

| NOT READY / do not depend on | Reason |
|---|---|
| weave AUTONOMOUS DISPATCH | **does not exist** — poll-only, `JobRunner` deferred to future epic |
| prompt_hub SwarmBundle DISPATCH | struct exists, **zero outbound wiring** |
| envctl SECRETS daemon `secretd` phases 6-8 | ~30% (15+ `todo!()`, server-mode CRITICAL gaps) |
| n8n-loop harness | ~60% (no proven end-to-end cycle yet) |

**projects-all-incomplete — ROOT-CAUSE FACT (user-authoritative, 2026-06-09):** **NONE of the stack projects are finished.** They were built **SIMULTANEOUSLY, in parallel,** which is exactly WHY there are multiple front doors and competing task stores — **the overlap is an artifact of concurrent unfinished construction, not a deliberate federation.** prompt_hub is incomplete; weave is incomplete. **Design implication: you cannot specify seams against current code alone — you must design against each tool's INTENDED-but-unbuilt shape,** and the contract work must account for half-built endpoints. **Confusion in the stack = direct symptom of incompleteness.**

> Relationships: `completion-state-2026-06-09` is `depend`ed-`on` by `critical-missing-seams`; `projects-all-incomplete` is `caused_by` `gap-front-door-ambiguity` and `gap-multiple-task-truths`, and is `related_to` `stack-topology-reality`. These gaps live in [08-gaps-seams-merge](08-gaps-seams-merge.md).

---

## 6. Decision log (2026-06-09)

### 6.1 decision-log-2026-06-09
*Labels: `type:decision`, `status:provisional` — **confidence 0.6** (below 0.7 flag threshold).*

**DECISIONS (LOCKED 2026-06-09 after full 314-crate RuVector walk + S1).** *(Definition says "Supersedes the provisional version" yet `status:provisional` is still the label — see QUESTIONS.)*

1. **SOURCE-OF-TRUTH = the `.handoff` STATE-PRECEDENCE hierarchy** (Git HEAD/worktree = physical truth > event ledger [rusqlite + rvf-crypto witness] = operational truth > `tasks/*.task.yaml` > ADRs > `active.md` > packets). **weave Jobs = the COORDINATION VIEW** (synced by `correlation_id`), NOT the crowned SoT. *Closes `gap-multiple-task-truths`.*
2. **WORK-ORDER ENVELOPE = the `handoff.task.v1` schema** (`id`/`title`/`status`/`priority`/`objective`/`path_scope`/`acceptance_criteria`/`test_commands`/`dependencies`/`blocked_by`/`allows_network`/`allows_dependency_addition`), carried end-to-end, made **PROVABLE** by `ruvector-verified` (intent/scope/acceptance blake3 hashes → Lean-checkable `AgentContract`). *Closes `gap-missing-integration-contract`.*
3. **FRONT DOOR = `prompt_hub`** (canonical vibe intake `/vibe` → `SwarmBundle`) + **RuVocal** (chat UI on pgvector = `ruvector-postgres`); other doors = shims. *Closes `gap-front-door-ambiguity`.*
4. **LEDGER v1 = rusqlite + `rvf-crypto::WitnessChain`;** RVF vector-native ledger = scheduled V2 (next-priority).
5. **v1 SCOPE** = the `hf` resume → claim → start → checkpoint → drift → handoff loop on rusqlite + witness + weave leases + rvAgent + cognitum-gate policy + MCP seam; **session-relay loop stays the runner;** `hf` replaces narrative `HANDOFF.md`.
6. **NAMING = `handoff`/`.handoff` kernel (drop Ark/V2).**

**LAW = adopt-what's-built then extend; RuVector = the FOUNDATION.** SPIKE AUTHORIZED: stand up rusqlite + rvf-crypto witness ledger skeleton + `handoff.task.v1` `work_order` crate + validate the `SwarmBundle → handoff.task.v1` seam before committing. **Supersedes the provisional version.**

> Relationships: `decision-log-2026-06-09` is `related_to` `critical-missing-seams`, and is `refine`d by `s1-ruvector-meta-mapping`, `session-handoff-2026-06-09`, `adr-2026-06-11-open-questions`, and `adr-2026-06-11-rust-native-system-overview`. The front-door, ledger, work-order and seam detail map to siblings — see [Cross-references](#cross-references).

---

## 7. The 2026-06-11 ADR cluster (re-grounding before build-out)

Four ADRs from session 2026-06-11 that re-checked premises directly against code (standing method: **code is truth**) before the implementation phase. All carry domain labels and `type:adr`.

### 7.1 adr-2026-06-11-meta-loop-lib-status
*Labels: `type:adr`, `status:verified`, `session:2026-06-11`, `domain:loop-lib` — confidence 0.5.*

**STATUS: decided — premise corrected; NO divergence exists.** The task brief asked to compare "the Meta loop lib present in the peer repo" against the agent's version, flagging divergence.

**FINDING (code-verified 2026-06-11):** `loop_lib` exists **ONLY in the meta workspace** (`~/Desktop/meta/loop_lib`), version = **workspace-inherited 0.2.22** (meta root `Cargo.toml [workspace.package]`). It is the rayon-based cross-directory command engine; public API (`src/lib.rs`): `LoopConfig` (directories, parallel, max_parallel, spawn_stagger_ms, dry_run…), `DirCommand`, `CommandResult`, `run()`, `run_commands()`, `execute_command_in_directory[_capturing]()`, `expand_directories()`, `should_ignore()`, `parse_config()`, `JsonOutput`/`JsonCommandResult`/`JsonSummary`, alias helpers.

**CONSUMERS (Cargo-verified):** `loop_cli`, `meta_cli`, `meta_git_cli` — all via `path = ../loop_lib`, so **exactly ONE version exists machine-wide; no crates.io duality.**

**PEER-REPO CHECK:** RuVector contains **NO copy/fork/vendored snapshot/reference** to `loop_lib` (fulltext + Cargo.toml grep = zero); same for `ruflo`; `handoff/hf` does NOT depend on it either (deps = `work-order`, `ledger`, `serde` only).

**VERDICT:** the "loop lib present in the peer repo" premise is **FALSE** — there is no second loop lib, hence no version skew and no shim/compatibility layer warranted. RuVector's internal parallelism (rayon/tokio per crate) is unrelated to `loop_lib`'s role (repo-fan-out execution).

**CONSEQUENCES:** if `hf` later adds parallel fan-out (cycle batching per ADR-0001), it should path-dep THE single `loop_lib` rather than reimplementing; **no porting work exists.** Open questions: none for this seam. References: `loop_lib/Cargo.toml`, `loop_lib/src/lib.rs:38-944`, meta `Cargo.toml:40-41`, grep evidence 2026-06-11, memoir `meta-repo-control-plane`.

> Relationship: `related_to` `meta-repo-control-plane`.

### 7.2 adr-2026-06-11-repo-docs-accuracy
*Labels: `type:adr`, `status:verified`, `session:2026-06-11`, `domain:docs-trust`, `tag:critical` — confidence 0.5.*

**STATUS: decided — trust map for documentation, re-confirmed.** Standing method rule: **code is truth.**

**UNTRUSTED (walk-proven misdirection):** **ALL RuVector prose** — `README.md` (271KB marketing), `CLAUDE.md` (it is the **upstream claude-flow/RuFlo V3 swarm config:** npm-first build commands, swarm/npx directives — NOT operating instructions for meta work), Cargo `description` fields, `//!`/`///` doc-comments, ADR prose, the knowledge-export JSON (claims 91 crates vs real 314).

**Catalogued traps** (runbook "Doc-contradictions caught"): `ruvector-dag` claims query-plan DAG = actually **QuDAG post-quantum governance/consensus**; `ruvector-coherence` claims sheaf-Laplacian = actually **lightweight HNSW health monitor** (the REAL sheaf engine is `crates/prime-radiant`, whose own doc claims "dashboard component" = actually a second GPU/wgpu convergence runtime); `ruvector-fpga-transformer` = coherence/policy-gated accelerator, **no FPGA backend**; `rvf-crypto` claims ML-DSA-65 post-quantum = **ships `ed25519-dalek` + `sha3` only** (PQ crypto lives in `ruvector-dag`/QuDAG); `thermorust` = Ising/Hopfield spin-glass engine, **not thermal mgmt**; `ruvector-crv` "Controlled Remote Viewing" = embedding-consensus / hallucination-bias detection; `ruvector-domain-expansion` = contextual-bandit Thompson router (the Rust-native MoE routing); `ruQu` (QEC decoder for the coherence gate) vs `ruqu-core` (quantum simulator) **name collision**; `ruvector-router-core` = full embeddable vector DB, **not request routing**; exo research crates carry unverified perf/"Nobel-level" marketing prose.

**TRUSTED ARTIFACTS:** the meta-root reports (`RUVECTOR-RUNBOOK.md`, `RUVECTOR-CRATE-LEDGER.md`, `RUVECTOR-META-MAPPING-S1.md`, `RUVECTOR-RESEARCH.md`, `STACK-INTEGRATION-PLANS.md`, `SESSION-HANDOFF.md`), the ICM memoir `system-architecture`, real Cargo `[dependencies]` edges, pub type/trait/fn signatures, tests.

**MOSTLY-TRUSTWORTHY repo docs** (recently human-synced, each carrying its own code-wins rule): `weave/CLAUDE.md` + `ARCHITECTURE.md` (synced to multi-crate reality via PR#60 2026-06-11), `envctl/CLAUDE.md` (kasetto-managed agent env; explicit drift-reversal discipline), `prompt_hub/CLAUDE.md` (declares prose-may-lie + Rust-native invariant; its `AGENTS.md`/`.agent.md`/`GEMINI.md` harness files = advisory only, authored for other runtimes).

**RISK FLAGGED:** the trusted meta-root reports are **UNTRACKED in the meta parent repo** (git status `??`) — single-copy artifacts on one disk; **they should be committed.**

**CONSEQUENCES:** code-truth method remains mandatory for RuVector/ruflo work; when prose contradicts code, code wins AND the contradiction gets flagged to this memoir.

> Relationship: `related_to` `ruvector-pass1-shape` (see [05-ruvector-substrate](05-ruvector-substrate.md)).

### 7.3 adr-2026-06-11-rust-native-system-overview
*Labels: `type:adr`, `status:verified`, `session:2026-06-11`, `domain:arch`, `tag:critical` — confidence 0.5.*

**STATUS: decided (re-verified 2026-06-11 for implementation phase).** Discovery session re-grounding the 314-crate walk before build-out; code-truth re-checked directly (no subagents, per standing method rule).

**FINDING:** RuVector lives at `~/Desktop/meta/RuVector` (registered in `.meta.yaml` as `ruvector`, path `RuVector`, **remote = UPSTREAM `https://github.com/ruvnet/RuVector.git` — not a FlexNetOS fork remote**), branch main **pinned [behind 12]** (intentional drift; last local commit `a083bd77` 2026-06-08; only `crates/rvf/Cargo.lock` locally modified). Root `Cargo.toml` = explicit member list + excludes for nested sub-workspaces (`crates/rvf/*`, `ruvix`, `rvm`, `ruvector-postgres/pgrx`, `esp32`, `mcp-brain-server`, `examples/*`) — **314 crates / 196 clusters total per ledger, all `[x]` walked.**

**RUST-NATIVE PRODUCTION ANCHOR:** the Rust crates are canonical; npm/packages (~30+ dirs: pi-brain, ruvbot, cognitum-gate-wasm, router-*, agentic-*) = **TS bridge/tooling artifacts over the Rust core** (B16 three classes); `ruflo` = claude-flow v3 TS runtime, **a PARALLEL FRONT-END over the same substrate** (T3), main [behind 10], clean.

**INTEGRATION TRUTH (plain-grep verified):** **ZERO Cargo or fulltext edges** RuVector ↔ {`loop_lib`, `kasetto`, `envctl`, `prompt_hub`, `meta_plugin`}; the **ONLY live code edge** from meta stack into RuVector = `handoff/ledger` Cargo path-dep on `RuVector/crates/rvf/rvf-crypto` (`features=[standalone]`) for the witness chain.

**THE AGENTIC PIPELINE (runbook synthesis, code-proven):** `data-*` feeders → boundary/consciousness `discovery-agent` families (mincut + coherence + IIT-Phi) → `train-discoveries` + mcp-brain aggregation → a2a-swarm (rvAgent) orchestration + verified-applications AgentContracts (Lean) → edge fleet (ruvector-edge P2P, edge-net wasm, esp32, ios) — governed by `cognitum-gate`, witnessed via RVF; **MCP = the universal control seam (T11).**

**CONSEQUENCES:** law **adopt-then-extend** holds — integration work is **thin glue at MCP/CLI seams** (`hf` CLI, `work_order` crate, dispatch wiring), never rebuilds; theses T1-T15 remain the navigation map. References: `RUVECTOR-RUNBOOK.md` (theses + batch log B0-B17j), `RUVECTOR-CRATE-LEDGER.md` (314/314), `RUVECTOR-META-MAPPING-S1.md` sections 5b-5d, `STACK-INTEGRATION-PLANS.md`, `decision-log-2026-06-09`, `handoff/ledger/Cargo.toml:14`.

> Relationships: `refines` `ruvector-pass1-shape` (see [05-ruvector-substrate](05-ruvector-substrate.md)); `related_to` `decision-log-2026-06-09`.

### 7.4 adr-2026-06-11-open-questions
*Labels: `type:adr`, `status:open`, `session:2026-06-11`, `domain:open-questions`, `tag:critical` — **confidence 0.8.***

**STATUS: open** — consolidated unresolved architectural questions, **REFRESHED 2026-06-12 evening** after the verification session (`org-audit-verification-2026-06-12`).

1. **TRANSPORT (HFTASK-0019):** MCP server vs HTTP+bridge for `prompt_hub ↔ hf` — **still open;** write the ADR with research before coding.
2. **ENVELOPE SYNTHESIS (HFTASK-0003 crux):** NL Intent → REAL `path_scope`/`acceptance_criteria`/`test_commands` — **still open, still the crux.**
3. **A2A PROTOCOL BRIDGE weave ↔ rvAgent:** still open; `hf` remains the junction (ADR-0002 formalized the weave side's 5-surface contract 2026-06-12).
4. **VERDICT REDUCER (R5):** N-reviewers → one-verdict still **homeless** (~50-100 LOC); single-verdict channel PROVEN in production (`ask_66`, handoff PR#3).
5. **KASETTO SOURCE:** ✅ **RESOLVED 2026-06-12** — org fork registered as `kasetto`; residue: fork at 3.0.0 vs installed 3.1.0 (FF candidate) + optional rename (NEEDS-HUMAN #6).
6. **SECRETS MINTING (envctl `ProviderMint`/`inject`/`run_child`):** unchanged posture, but **HARD EVIDENCE landed 2026-06-12:** `PARENT_REPO_PAT` resolves EMPTY inside `FlexNetOS/meta`'s own workflows (Release Please run `27439121673` "token not supplied") — the org secret's repository-access policy covers child repos but **not the parent;** grant command queued in NEEDS-HUMAN #2.
7. **UPSTREAM PIN POLICY:** PARTIALLY RESOLVED — `ruflo` pin branch `pin-meta-2026-06-12` = the per-cluster template; RuVector pin unchanged. Workspace-member forks (teri/shimmy/rtk) are parent-CI-gated; the **shimmy `INVARIANT_LOG` test race** (`incidents/shimmy-invariant-ppt-test-race`, fixed via `shimmy#4` with `#[serial_test::serial]` ×12, repro 198/600 → 0/600) is the cautionary instance: **upstream-inherited test hygiene can break parent gates timing-dependently — stress-loop suspicious tests ×600.**
8. **RUVOCAL RUNTIME:** unchanged (LAST per readiness order).
9. **COGNITUM SEED:** unchanged (hardware wall).
10. **HANDOFF PUBLISH:** resolved (CI + protected master + ship/review-verdict verbs).
11. **META-ROOT REPORTS:** ✅ **FULLY RESOLVED 2026-06-12** — docs PR #12 MERGED to main (`f48ad885`): `META-ORG-POLICY.md`, `META-ORG-AUDIT.md`, `NEEDS-HUMAN.md`, `SESSION-HANDOFF.md`, `VERIFICATION-REPORT.md` all tracked on main; **meta main CI green for the first time since 2026-06-04,** confirmed on two consecutive main commits (`b12f3c7ab`, `f48ad885`).
12. **MANIFEST DRIFT NIT:** unchanged.
13. **SESSION LEDGER LOCATION:** open — `hf ship` from a worktree writes `pr_opened` into the worktree's ephemeral ledger; **HFTASK-0007 must define the session-ledger model.**
14. **SEPARATE-ROLE REVIEWER:** open — cloud_ultra phase or swarm reviewer + gatekeeper-as-required-check (HFTASK-0010/0014).
15. **(NEW 2026-06-12 evening) RELEASE PLEASE TOKEN:** On Push to Main's Release Please job was red on every main push once quality went green (masked since 2026-06-04); workflow fallback `PARENT_REPO_PAT || GITHUB_TOKEN` shipped via meta PR #14 — but **GITHUB_TOKEN-created release PRs trigger no CI so they cannot pass required checks/auto-merge;** durable fix = human grants the org secret to the meta repo (NEEDS-HUMAN #2 has the exact `gh api PUT`).
16. **(NEW) META PORTABILITY (user directive 2026-06-12, next mission):** **SCOPE IS TOTAL** per user same evening: *"all work on this system is now meta work; nothing should be outside meta"*; sole exemption = IDE applications (RustRover/VSCode + their app-managed state). Every project, workspace, config, and tool must live INSIDE meta as a `.meta.yaml` project, with user-global locations holding **only symlinks INTO meta (never meta linking out)** — the build-anywhere goal. Live violations (recon 2026-06-12): yazelix at `~/.config/yazelix` (real dir, nix-store toolbin, NOT in `.meta.yaml`, yet `meta dashboard` renders its layout + in-flight `yazelix-dashboard` worktree `1d6c33f`); `meta`/`rtk`/`icm`/`vox`/`git-kb`/`loop`/`envctl`/`kasetto` = real binary COPIES in `~/.local/bin` though sources are meta members; stale weave in `~/.cargo/bin`; `~/.claude/CLAUDE.md`+`RTK.md`+`settings.json` real global files; out-of-meta work dirs `~/Desktop/workspaces/`, `~/Desktop/meta.worktrees/`, `~/Downloads/tmp`. Correct pattern exists ×3 (lane, n8n-up/down, statusline-command.sh). **Third-party agent CLIs NOT exempt** (classify; self-mutation hazard for claude/rtk/icm — last, with rollback). Mission prompt: `PORTABILITY-SESSION-PROMPT.md` at meta root.

**RESOLUTION PATH:** 1+2 inside HFTASK-0003/0019; 13 inside HFTASK-0007; 14 inside HFTASK-0010; 15+6 in NEEDS-HUMAN #2; 16 = next session mission (audit → ADR → internalize → fresh-clone proof); 3+4 need small ADRs; 8/9/12 scheduled. References: `org-audit-verification-2026-06-12`, `loop-e2e-proof-2026-06-12`, `org-audit-results-2026-06-12`, `policy-v2-meta-org`, `NEEDS-HUMAN.md`, `VERIFICATION-REPORT.md`.

> Relationships: `related_to` `decision-log-2026-06-09`; `refine`d by `meta-portability-2026-06-12` and `ship-loop-proof-2026-06-12`.

---

## Cross-references

ICM `.links` that cross this document's boundary into sibling map docs:

- **[02-handoff-continuity](02-handoff-continuity.md)** — `FlexNetOS branch/CI-CD model` and `gh-aw separation-of-privilege gate` are both `part_of` **Handoff Loop v2 (ADR-0001)**; the `.handoff` ledger / `hf` resume→claim→checkpoint→handoff loop, work-order envelope (`handoff.task.v1`), witness chain (rvf-crypto), and `handoff-kernel-relocated-to-meta` (an `instance_of` `meta-architecture-canon`) all live there. ADR-0002 (weave 5-surface contract), ADR-0003 (kb↔handoff seam), ADR-0004 (fleet rollout), ADR-0005 (steward), HFTASK-0007/0010/0012/0014/0019 are handoff-plane items.
- **[03-envctl-kasetto](03-envctl-kasetto.md)** — `meta-repo-control-plane` `depends_on` `envctl-os-foundation`; `envctl-drift-and-merge-state` is `related_to` `meta-architecture-canon`; `kasetto-agent-provisioner` is `related_to` `meta-repo-control-plane`. The portability materializer (`envctl/home/`, symlink components, secrets engine `inject.rs`/`ca.rs`/`vault`, never-downgrade guard, ADR-0006/0007/0008) and the envctl master-mirror protection saga are detailed there.
- **[04-weave-coordination](04-weave-coordination.md)** — `weave-coordination-substrate` is `part_of` `stack-topology-reality`; weave = one of the two shared substrates, the coordination view (not the crowned SoT), path-leases (`Leaser`/`WeaveCli`), out-of-band review verdicts. weave is the only repo with `develop` + 6-check protection.
- **[05-ruvector-substrate](05-ruvector-substrate.md)** — `adr-2026-06-11-rust-native-system-overview` `refines`, and `adr-2026-06-11-repo-docs-accuracy` is `related_to`, `ruvector-pass1-shape` (which is `part_of` `stack-topology-reality`). The 314-crate walk, RVF/`rvf-crypto` witness, cognitum-gate, MCP control seam, doc-contradiction catalogue, and `ruflo-is-claude-flow-v3` belong there.
- **[06-cognitive-codewalk](06-cognitive-codewalk.md)** — the agentic pipeline (discovery-agent families, mincut/coherence/IIT-Phi, train-discoveries, mcp-brain), `grit` AST lock coordinator, and the cognitive/consciousness-discovery planes from the architecture-truth census.
- **[07-frontdoor-integration](07-frontdoor-integration.md)** — `prompt_hub-front-door` is `part_of` `stack-topology-reality`; `decision-log-2026-06-09` decision #3 names prompt_hub + RuVocal as the front door; the `SwarmBundle → handoff.task.v1` seam, HFTASK-0003/0019 envelope-synthesis/transport cruxes, prompthub-server boot + dispatch gap.
- **[08-gaps-seams-merge](08-gaps-seams-merge.md)** — `projects-all-incomplete` is `caused_by` `gap-front-door-ambiguity` and `gap-multiple-task-truths`; `completion-state-2026-06-09` is `depend`ed-`on` by `critical-missing-seams`; `decision-log-2026-06-09` is `related_to` `critical-missing-seams`; `rusty-idd merge model + meta conventions` is `related_to` `FlexNetOS branch/CI-CD model`; `rusty-idd-merge-planner`, `n8n-external-glue`, `rtk-token-optimization`, `icm-persistent-memory` are all `part_of`/`related_to` `stack-topology-reality`. The seam catalogue, missing integration contracts, and merge model live there.

---

## Flags

### QUESTIONS

1. **`decision-log-2026-06-09` status contradiction.** Its label is `status:provisional` yet its definition ends "Supersedes the provisional version" and is headed "DECISIONS (LOCKED 2026-06-09)". Is the decision log locked/superseding or still provisional — which field is authoritative, the label or the body?
2. **"Only weave protected" vs the protection reality.** `FlexNetOS branch/CI-CD model` and `policy-v2-meta-org` both state branch protection exists fleet-wide only on `weave/master`; `org-audit-results-2026-06-12` explicitly "corrects 'only weave' memory" by finding **3** protected repos (`.github/main`, `lane/main`, `weave/master`) before the Phase-4 rollout. Which baseline is correct for any reader who lands on the earlier concepts first — should the branch/CI-CD-model and policy-v2 concepts be annotated as superseded on this point?
3. **Branch-model supersession (clone vs develop-mirror).** `FlexNetOS branch/CI-CD model` records "clone model everywhere (no forks)" and "all other repos = main, no develop, no protection," but the `decisions-meta` memory (2026-06-13) sets a general owner principle that **every** repo needs `develop` + protected `main`/`master` mirror (create-if-missing). Is the develop-mirrors-master model now the canon for the whole fleet, and is the "no develop anywhere but weave" statement retired?
4. **Protection counts: 24/26 (rollout) vs 63 (auto-merge) vs piecemeal (2026-06-13).** `org-protection-rollout-2026-06-12` reports protection on 24 + auto-merge on 26; the `decisions-meta` memory reports `allow_auto_merge` on **63** repos and protection landed only on `icm/main` + `envctl/develop` under new repo-owned tooling. Did the 2026-06-12 fleet rollout get rolled back / reclassified, or are these two different layers (the 06-12 mass apply vs a 06-13 per-repo re-do)? Which is the current protection inventory?
5. **`fastembed`/`ort` unsafe-code note in `decisions-architecture`.** That memory states `fastembed-rs` is unsafe-free in its own source but pulls unsafe via `ort` (ONNX C++ FFI), so it is NOT safe-only for a `#![forbid(unsafe_code)]` crate. This is a material constraint for prompt_hub's embedding backend but does not appear as a graph concept in this cluster — is it captured in the front-door / embedding map doc, or is it an un-mapped fact?
6. **Confidence 0.5 across nearly the whole cluster.** Eighteen of twenty concepts carry memoir-extraction `confidence: 0.5` despite several being `status:verified`/`status:accepted`. Is 0.5 the default emitted by the export for human-authored memory regardless of the underlying verification state (so it should be read as "extraction confidence, not fact confidence"), or does it genuinely flag these as low-confidence claims?

### LESSONS (confirmed facts / resolved decisions / verified verdicts — ground truth to carry forward)

1. **`~/Desktop/meta` is a meta-repo of ~60 independent `FlexNetOS/` git repos, NOT a monorepo;** each member builds/publishes independently; the root `Cargo.toml` is dev-convenience only. (`meta-repo-control-plane`, `meta-architecture-canon`)
2. **The 10 canon repos and their conventions are verified (2026-06-09):** `loop_lib`, `meta_plugin_protocol` (SOLID), `meta_plugin_api` (stub/superseded), `meta_core` (sparse), `meta_git_lib`, `loop_cli`, `meta_cli` (mature host orchestrator, 3-layer plugin discovery), `meta_git_cli`/`meta_project_cli`/`meta_rust_cli`. `meta_dashboard_cli`/`meta_mcp`/`meta-plugins` are newer, not part of the 10. (`meta-architecture-canon`)
3. **The stack is NOT a wired pipeline** — independent tools integrating loosely via two substrates (weave mesh + committed files on disk); no tool calls prompt_hub/rusty-idd/kasetto/weave directly in code. (`stack-topology-reality`)
4. **No second `loop_lib` exists** — it lives only in meta (v0.2.22), consumed by path-dep by `loop_cli`/`meta_cli`/`meta_git_cli`; RuVector/ruflo/handoff do not depend on it. No version skew, no shim warranted. (`adr-2026-06-11-meta-loop-lib-status`)
5. **Code is truth; RuVector prose is UNTRUSTED** (README is marketing, `CLAUDE.md` is upstream claude-flow swarm config, export JSON claims 91 crates vs real **314**). Trusted: meta-root reports, the ICM memoir, real Cargo edges, pub signatures, tests. (`adr-2026-06-11-repo-docs-accuracy`, `adr-2026-06-11-rust-native-system-overview`)
6. **The ONLY live code edge from the meta stack into RuVector is `handoff/ledger` → `rvf-crypto` (witness chain).** Zero Cargo/fulltext edges between RuVector and loop_lib/kasetto/envctl/prompt_hub/meta_plugin. Integration is thin glue at MCP/CLI seams; law = adopt-then-extend. (`adr-2026-06-11-rust-native-system-overview`)
7. **POLICY v2 is code-verified against all 10 canon + parent + live `gh` api;** it is tiered A/B/C/D and the **parent meta repo IS the rusty-idd-alignment exemplar** (alignment items already landed at parent; policy propagates outward). (`policy-v2-meta-org`)
8. **The org-audit findings were adversarially re-verified (all clusters PASS):** 19 PRs re-queried, fork homing genuine, witness chain recomputed (16 events, 0 hash breaks), full battery 52 suites / 3527 tests / 0 failed. (`org-audit-verification-2026-06-12`)
9. **Branch protection applied to 24 repos + auto-merge to 26 (GET-after-PUT verified, 2026-06-12),** with the hard rule: **only require checks that run on `pull_request` events** (push-only or dynamic CodeQL names as required = merges bricked forever); required checks gate PR merges, not direct pushes. (`org-protection-rollout-2026-06-12`)
10. **`PARENT_REPO_PAT` is granted to child repos but NOT to `FlexNetOS/meta` itself** — Release Please fails "token not supplied" inside the parent's own workflows; durable fix needs the human to grant the org secret to the meta repo. (`org-audit-verification-2026-06-12`, `adr-2026-06-11-open-questions` #15/#6, NEEDS-HUMAN #2)
11. **GitHub-native auto-merge works in production (observed completing 3×)** but **cannot arm on branches with zero required checks,** and **GITHUB_TOKEN-created PRs trigger no CI** (so they cannot auto-merge). (`org-audit-verification-2026-06-12`, `meta-portability-2026-06-12`)
12. **The separation-of-privilege gate (from `gh-aw`):** agents emit verdicts as DATA and never hold the merge token; reviewer verdicts stay out-of-band in weave state (a bot APPROVE silently satisfies required-reviews and defeats the gate); merge is an Environment-gated non-agent job. (`gh-aw separation-of-privilege gate`)
13. **Portability is total internalization, with `envctl` as the single box materializer** (GNU stow + `meta env link` rejected as redundant). Contract: **real file in meta, symlink INTO meta — never meta linking out;** secrets and state never internalize. ADR-0006 accepted (+ADR-0007/0008). (`meta-portability-2026-06-12`, `portability-wave2-2026-06-13`)
14. **The never-downgrade guard is real and fired correctly** (rtk 0.42.2-installed > 0.42.0-checkout skipped; kasetto 3.1.0-installed > 3.0.0-checkout link-inversion held). A component's idempotency detect must encode the FULL desired end-state, not a single sentinel. (`meta-portability-2026-06-12`, `portability-wave2-2026-06-13`)
15. **Full-estate census (2026-06-12) is accepted:** 58-62 units, 5 planes, 40 active / 12 husks / 5 in-dev / 1 stale; **only 1/58 repos had `.handoff`** (the handoff kernel); `teri` = MiroFish rewrite confirmed; `grit` = AST function-level lock coordinator; `obscura` = Rust headless browser. The "broken harnesses" premise was largely corrected. (`architecture-truth-census-2026-06-12`, `upgrade-mission-results-2026-06-12`, `workspace-census`)
16. **NONE of the stack projects are finished** — built simultaneously in parallel; the multiple front doors and competing task stores are an artifact of concurrent unfinished construction, not deliberate federation. You must design seams against each tool's INTENDED-but-unbuilt shape. (`projects-all-incomplete`, `completion-state-2026-06-09`)
17. **Verified completion baselines (2026-06-09):** kasetto ~95% (most-done), weave v0.2 core done+tested (38 tests), prompt_hub core ~85% (724 tests), obscura complete, envctl phases 0-5 ~90%, rusty-idd ~85%; **do NOT depend on** weave autonomous dispatch (does not exist), prompt_hub SwarmBundle dispatch (zero wiring), envctl `secretd` phases 6-8 (~30%, 15+ `todo!()`), n8n-loop (~60%, no e2e). (`completion-state-2026-06-09`)
18. **Source-of-truth hierarchy (locked 2026-06-09):** Git HEAD/worktree > event ledger (rusqlite + rvf-crypto witness) > `tasks/*.task.yaml` > ADRs > `active.md` > packets; weave Jobs = coordination view, not crowned SoT. Naming = `handoff`/`.handoff` kernel (Ark/V2 dropped). (`decision-log-2026-06-09`)
19. **The kasetto source question is resolved:** org repo `env_manager_agent` is a fork of `pivoshenko/kasetto`, registered in `.meta.yaml` as `kasetto` (open-questions #5 closed); residual = FF the fork 3.0.0 → installed 3.1.0 + optional rename. (`org-audit-results-2026-06-12`, `adr-2026-06-11-open-questions` #5)
20. **Method lessons that are ground truth:** `gh` mutations can succeed silently — always re-query; a passing test battery does not disprove a scheduling race (stress-loop suspicious tests ×600 — the shimmy `INVARIANT_LOG` race was 198/600 → 0/600 after `#[serial_test::serial]`); rtk silently filters cargo/grep output (bypass via script files; exit codes = truth); `systemctl --user disable` deletes symlinked unit files (disable first, link after). (`org-audit-results-2026-06-12`, `org-audit-verification-2026-06-12`, `meta-portability-2026-06-12`)
