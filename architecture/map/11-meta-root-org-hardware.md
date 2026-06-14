# 11 — Meta-root Org Policy, Portability, Architecture-truth & Hardware

This document expands the ICM-derived map (`map/01`, `03`, `05`, `08`) with the **authoritative
meta-root planning docs** — the artifacts the ICM memoir was synthesized *from* and, in several
cases, the live code/hardware that **post-dates** the memoir. Where the ICM map left questions
PARTIAL or OPEN (org-protection inventory, the envctl inject seam, secretd's phase, the Cognitum
board class, the hardware walls), these docs plus a direct check of the `envctl` repo and the live
COGNITUM drive **answer or sharpen** them. Method is the meta-root rule: **code is truth; docs are
untrusted prose** — contradictions between the planning docs and the current repo state are flagged
inline. Every repo name, count, board class, crate path, PR number, and date is preserved verbatim.

> **Currency note.** The seven source docs are dated **2026-06-12 / 2026-06-13**; the ICM memoir
> behind `map/01..08` is mostly **2026-06-09 / 2026-06-12**. Where they disagree, the **newer doc +
> the live repo win** (and the discrepancy is recorded). Two facts were checked against the live
> `~/Desktop/meta/envctl` HEAD (`master` @ `42b21f9`) and the mounted `/run/media/drdave/COGNITUM`
> drive on 2026-06-13; those checks override the prose where noted.

---

## ME-ORG-AUDIT.md — full-fleet compliance audit vs POLICY v2

`META-ORG-AUDIT.md` (2026-06-12) is the **executed Phase 2 + verification + Phase 4** of the
org-audit mission. Method: mechanical sweep of every `.meta.yaml` member (git state, markers,
workflows) + live `gh api` + targeted code verification. **Fleet = 60 registered projects** (was 64;
4 stale `weave-*` second-checkout entries deregistered) + 1 nested member (`mcp_hub → n8n-mcp`) +
parent.

**Verdict snapshot (verbatim):** Identity ✅ 100% after fixes (ruflo was the last violation); sync
✅ clean; CI present on Tier A canon (3-workflow template), gaps at `meta_dashboard_cli` (zero CI),
`meta_plugin_api` (zero, stub), `handoff` (zero — owned by HFTASK-0012), `claude-plugins`, `lifeos`,
`envctl`/`teri` (no wf dir); CI green fleet-wide after fixes; **Protection ❌ only `.github/main`,
`lane/main`, `weave/master` (3/58)**; Auto-merge ❌ disabled everywhere — both flagged "Phase 4 work".

**Fixes landed by this audit:** `meta_cli#1` (red Format gate from `29770d1` ollama-init, MERGED
17:48Z); `teri#1` (fmt ×12 + clippy `into_iter`, MERGED); `shimmy#1` (clippy ×5 + `publish=false` +
workspace-aware test binary paths, MERGED); parent `meta#11` (multiple-workspace-roots clone-forks
fix); **semantic-pr-title propagation across 11 repos + Renovate on the 5 canon gaps**
(`loop_lib`/`loop_cli`/`meta_core`/`meta_plugin_protocol`/`meta_git_lib`), all opened to merge on
green. **`ruflo` homed** (genuine org fork `FlexNetOS/ruflo`, fork=true, pin branch
`pin-meta-2026-06-12` @ local `dfe1b9cf9`). **kasetto source located + adopted:** org fork
`FlexNetOS/env_manager_agent` (parent `pivoshenko/kasetto`) registered as `kasetto` — resolves
open-questions #5 (fork 3.0.0 < installed 3.1.0, FF candidate).

**Phase 4 — org-level GitHub policy applied 2026-06-12 ~18:20Z:**

| Group | Repos | Required checks |
|---|---|---|
| parent | `meta/main` | Clippy, Format, Test×3, Integration Tests×2, Semantic PR Title (8) |
| canon+A2+agent | `loop_lib`,`loop_cli`,`meta_cli`,`meta_core`,`meta_plugin_protocol`,`meta_git_lib`,`meta_git_cli`,`meta_project_cli`,`meta_rust_cli`,`meta_mcp` (main) | Clippy, Format, Test×3 (+ Semantic PR Title where rolled) |
| `meta-plugins` | main | Semantic PR Title |
| `prompt_hub` | main | Check, Clippy, Format, Test(stable)×3, Cargo Audit, Cargo Deny |
| `rusty-idd` | develop | rust, msrv |
| `atc` | main | CI |
| anti-force-push only (no PR-running CI yet) | `meta_plugin_api`,`meta_dashboard_cli`,`obscura`,`handoff`,`envctl`,`vox`,`icm`,`rtk-tokenkill` | — |
| pre-existing (untouched) | `weave/master`(6),`lane/main`(3),`.github/main`(6 + 1 review) | — |

Profile: `required_status_checks{strict:true, checks: per-repo REAL PR-running checks}`,
`enforce_admins:false`, **no required reviews** (autonomous-loop compatible), `allow_force_pushes:false`,
`allow_deletions:false`. **`allow_auto_merge:true` + `delete_branch_on_merge:true` on all 24 + weave +
lane.** Check lists derived from **workflow trigger verification** (PR-running jobs only — push-only
checks like `notify(...)`, Release Please, CodeQL-dynamic excluded, else merges brick forever).

**Phase 5 — one full no-human cycle ran in production on `FlexNetOS/handoff`** (zero mocks): `hf ship`
**bootstrapped itself** (PR#3 merged `1894a7c` by GitHub-native auto-merge); HFTASK-0012 slice (PR#2
`00fdf85`, born green); verdict channel via weave ask `ask_66…` → `review_verdict` ledger event
(never a GitHub APPROVE); 16-event witness chain verified.

**Org deltas (disposition = human):** auto-suffix artifacts `shimmy-1`/`teri-1` (recommend delete);
unregistered org repos `harness`(fork revfactory/harness), `slim`(fork nilbuild/slim),
`global_projects_config`(private), `demo-repository`; **14 private workspace members**, of which
`meta_dashboard_cli` + `meta-plugins` are A2 code repos inconsistent with public canon peers (child CI
clones run **anonymous**, so cross-clones of private members break). CodeQL default-setup enabled
**org-wide ~04:18Z 2026-06-12** by `drdave-flexnetos`.

> **Flag (supersedes `map/01 §2.1`'s "only weave protected"):** this audit's **3 protected repos**
> (`.github/main`, `lane/main`, `weave/master`) is the corrected snapshot — but is itself superseded
> by the 2026-06-13 repo-owned rollout (see [Reconciliation](#reconciliation-with-the-icm-map), Q1.4).

---

## META-ORG-POLICY.md — POLICY v2 (the tiered contract)

`META-ORG-POLICY.md` (active, synthesized 2026-06-12, supersedes implicit canon-v1) is the policy the
audit scores against. **Method:** code-verified against the 10 canon repos + parent + live `gh api`;
**no prose trusted without a file/symbol/API check.** The parent repo `FlexNetOS/meta` is the **policy
exemplar** — the rusty-idd-alignment items are already landed there and are propagated outward.

**Tier model:**

| Tier | Definition | Policy subset |
|---|---|---|
| **A** | the 10 canon repos (`loop_lib`,`loop_cli`,`meta_cli`,`meta_core`,`meta_plugin_protocol`,`meta_plugin_api`(stub),`meta_git_lib`,`meta_git_cli`,`meta_project_cli`,`meta_rust_cli`) + parent exemplar; `meta_mcp`,`meta_dashboard_cli`,`meta-plugins` are post-canon A-track | Full P1–P6 |
| **B** | FlexNetOS-owned tools (`weave`,`envctl`,`prompt_hub`,`handoff`,`lane`,`icm`,`rtk-tokenkill`,`atc`,`agent`,`obscura`, dashboards, mcp/meta plugins, hubs-with-code) | Full P1–P6, version = standalone |
| **C** | forked upstream (`ruvector`,`ruflo`,`claude-code`,`codex`,`n8n`,`Archon`,`ECC`,`oh-my-claudecode`,`oh-my-pi`,`shimmy`,`teri`,`grit`,`hermes-agent`,`weave-*` forks) | P1 only + pin/drift. **Do NOT force FlexNetOS CI onto forks.** |
| **D** | hubs/docs/assets (`template_hub`,`*_hub`,`my-wiki`,`flexnetos_*`,`assets`,`commands`) | P1 + docs-accuracy (P5.22) |

**Policy clauses worth carrying:**
- **P2.6 version strategy:** Tier A members are *workspace-inherited* (`version.workspace = true`; the
  **parent** `VERSION` + release-please manifest = single version of the meta distribution, **0.2.22**
  today). Member repos carry **no** VERSION file and **no** release-please — **intentional, not a gap.**
  Standalone Tier B repos self-version (`weave 0.2.0`, `envctl 0.1.0`).
- **P4 canonical workflow set:** `ci.yml` (3-OS matrix + `clippy -D warnings` + fmt-check +
  synthesized-workspace-wrapper trick), `auto-format.yml`, `notify-downstream.yml`/`notify-parent.yml`,
  Release at parent only (release-please v4 manifest mode → `workspace.package.version` extra-file).
  `semantic-pr-title.yml` on every A/B repo. **Renovate, not Dependabot.**
- **P4.19 secrets are org-level only:** `PARENT_REPO_PAT`, `REPO_WRITE_PACKAGES_PAT`; never repo-level
  copies; never bake PATs into clones.
- **P6 handoff addition (autonomy layer):** fresh worktree per session; `hf claim/checkpoint/handoff`
  with the `.handoff` witnessed ledger; weave path-lease on claim; `kasetto sync --locked` preflight
  where `kasetto.yaml`; **AI gatekeeper as a REQUIRED STATUS CHECK** with **out-of-band** verdicts
  (weave permission-ask + `review_verdict` event — weave `ReviewItem` has NO verdict field by design);
  **never bot-approve a PR.**
- **P7 the `.handoff` continuity layer (ALL tiers, tiered depth, ADR-0003/0004):** every member hosts
  `.handoff/` at root; Tier A/B full layout (`context/capsule.json` REQUIRED, `tasks/`, `packets/`,
  `README.md`), Tier C/D stub. **One witnessed fleet ledger** at `handoff/.handoff/ledger.db`;
  worktree/session ledgers are ephemeral and checkpoint back (ADR-0004 §3). Cards are **minted, derived
  views** (`hf task mint --from-kb`); precedence **Git > ledger > cards** unchanged.

> **Scope discrepancy flag:** the policy header says **"every member of `.meta.yaml` (64 projects)"**
> while the companion audit deregistered 4 stale entries to **60**. The 64 is the policy-authoring
> snapshot; 60 is the post-audit live count. Both are correct at their timestamp — `map/01 §1.1`'s
> "~60 independent repos" tracks the audit count.

---

## PORTABILITY-AUDIT.md — total internalization & the ADR-0006/0007/0008 contract

`PORTABILITY-AUDIT.md` (mission `PORTABILITY-SESSION-PROMPT.md`, phase 1 read-only inventory + the
applied waves) executes the **total-internalization mission**. **Principle (verbatim):** *scope is
TOTAL — real file in meta, symlink outside, never the reverse; sole exemption = IDE applications +
their app-managed state.* This is the source detail behind `map/01 §4` and `L1.10`.

**The classification contract** (the internalization vocabulary): `link-invert` (source already a meta
member → symlink into meta, the **lane pattern**), `internalize` (real config → move into a meta repo +
symlink at old path), `vendor/fork` (external software → genuine `FlexNetOS` fork in `.meta.yaml`),
`bootstrap-step` (nix store / root-owned / installers → declarative bootstrap step), `state-stays`
(dbs/caches/histories → recreated, never in git), `secret-never` (credentials → never any repo;
bootstrap prompts or **envctl relay mints them**), `exempt-IDE`, `exempt-system`, `relocate`.

**Decision record = ADR-0006** (handoff/docs, merged `d748e45`): **`envctl` is the single box
materializer** (adopt-then-extend; GNU stow + a new `meta env link` were **REJECTED** — envctl already
owned the component/wiring/lock model and the whole yazelix stack). `envctl/home/` = canonical home
tree for user-global non-secret configs, wired by **archive-first symlink components**
(`manifest/components.d/portability-links.toml`). **Binary canon = symlinks to `target/release`** (the
lane pattern). **Secrets and state NEVER internalize.** The one-line contract: **"real file in meta,
symlink outside."**

**ADR family (from the wave-2 corroboration):** ADR-0006 accepted 2026-06-12 (envctl = single source of
truth for secrets, binaries, user-global configs); **ADR-0007** = retire `flexnetos_secrets` → envctl;
**ADR-0008** = `flexnetos_github_app` + `flexnetos_runner`. `NORTH-STAR.md` is the durable owner-approved
steward compass.

**Applied state (live on-box):** **40 symlinks now point into meta (was 3)** — 18 config links + 6
claude-global links + 15 binary links (`meta`/`meta-git`/`meta-project`/`loop`/`lane`/`grit`/`envctl`/
`envctl-gui`/`meta-dashboard`/`icm 0.10.50`/`vox 0.14.0` + cargo-bin `weave`/`grit`/`secretctl`/`secretd`).
**The never-downgrade guard fired correctly:** `rtk` SKIPPED in wave 1 (installed 0.42.2 > checkout
0.42.0), then **DONE in wave 2** (0.42.4 == repo); **`kasetto`/`kst` HELD — would DOWNGRADE** (checkout
builds 3.0.0 < installed 3.1.0; blocked on FF'ing the `FlexNetOS/kasetto` fork to 3.1.x). `settings.json`
absolute paths are **BY DESIGN** (rendered from `settings.json.tmpl` + `${META_ROOT}`, TASK-0005).
**Forgotten-directive CLEARED:** `~/Downloads/tmp/handoff` is the *original* Ark Handoff Ledger PRD (24
files, not git); `meta/handoff` is the *realized superset* (90 files, the `hf` Rust kernel) — **meta is
NOT a lite/downgrade**; the PRD is preserved as `handoff/docs/Continuity_Ledger_Kernel_PRD.md`.

> **Honest gap (verbatim):** Phase-4 proof is **PARTIAL** — branch clone carries the kit, bootstrap
> `--dry-run` runs, zero dangling links; **NOT proven: virgin-`$HOME` `envctl install` end-to-end.**

---

## ARCHITECTURE-TRUTH.md — the 62-unit estate census

`ARCHITECTURE-TRUTH.md` (2026-06-12, upgrade-mission Phases 2-3) is the **code-derived census** behind
`map/05`, `map/08`, and the whole five-planes model. **Method:** read-only census of all workspace repos
(**58 by fan-out workflow `wf_a40b236a`**, one agent per repo; RuVector/ruflo/envctl walked **directly**
per the no-subagent rule); roles derived from manifests/src/commits, **NOT READMEs**.

**Verdict snapshot (verbatim counts):** **62 units censused — 40 active, 12 empty-or-stub (husks),
5 in-development, 1 stale.** **`.handoff/` exists in exactly 1 of 58 repos** (handoff itself) —
vision item 2's fleet rollout is a total-greenfield gap. Loop harnesses in **8 repos**, none broken
mid-flight; only **`lifeos`** is genuinely broken (`HANDOFF.md` → dead `~/repos/ubuntu-lifeos`).

**The five planes (verified against code):**
1. **Foundation** — the 11 originals + parent + `meta_dashboard_cli` (A2 mission-control surface,
   runtime-coupled to envctl on PATH, deliberately Cargo-standalone). Lineage: harmony-labs → gitkb →
   FlexNetOS (Matt Walters); the gitkb org is dead. **No canon member has a README** (P5 gap).
2. **Agentic OS** — `RuVector` (`FlexNetOS/meta-ruvector`, dir `RuVector/`, **314 crates**, fully
   walked) + `ruflo` (`FlexNetOS/ruflo`). **Only live meta→RuVector code edge: `handoff/ledger →
   rvf-crypto` (witness chain).** Everything else mapped-not-adopted (W8 scoreboard 1/12 families).
3. **rtk tooling** — `rtk-tokenkill`, `icm`, `vox`, and **`grit` = AST/function-level lock coordinator
   for many parallel AI agents on one codebase** (re-tag `[tools, ai, concurrency]`, not "untriaged").
4. **Continuity** — `handoff` (the kernel; **all 22 task cards stale at `backlog` with dead `spike/**`
   path_scopes** — Defect D3), `weave` (interim 4-crate, ADR-0002), `atc` (gitkb-era dispatcher,
   overlaps handoff/weave, seam decision needed), `rusty-idd` (fail-closed merge model source).
5. **Features** — `teri` = **MiroFish rewrite confirmed independently**; `shimmy` = inference slot;
   `prompt_hub` = 3-crate workspace, **1085 tests**, **zero MCP + zero outbound dispatch** (both sides
   of the front-door seam unbuilt: HFTASK-0003/0019); `obscura` = Rust headless browser (V8/CDP), lane's
   web-access upgrade; **12 hubs** (Hub Standard, half empty); **5 unborn `flexnetos_*` husks**.

**Defects D1–D12** (feed `GAP-REGISTER.md`): D1 `claude-plugins` sources → dead gitkb org; D2 `vault_hub`
vendors a no-`.git` kasetto copy (catalogs **1,508 skills**); D3 handoff's 22 stale cards; D6 kasetto
fork 3.0.0 vs installed 3.1.0; D8 `.github_org` MANIFEST lists **~28 components, 4 present** (its own
MIGRATION.md admits it); D10 teri `TODO.md` stale (**241 unchecked**, Mar-2026); D11 `harness_hub`
misattributes vendored `harness` (claims FlexNetOS/harness; real upstream `revfactory/harness`).

> **KB ↔ handoff seam ANSWERED:** `git-kb` = knowledge/planning plane; `.handoff` = execution/witness
> plane; link today one-way + thin; **ADR-0003** freezes minting/write-back/single-registry rules.
> (This is the `map/05`/`L7.x` source.)

---

## COGNITUM-SEED.md — the hardware root of trust (W1)

`COGNITUM-SEED.md` (W1 analysis, 2026-06-12) is the **direct read of the mounted Cognitum Seed** — the
authoritative source for `map/05 §3` (the cognitum hardware tier) and the hardware wall in `map/08 §A.5`.

**What it is (corrects "key-stick"):** the Seed is a **hardware root-of-trust device for AI** —
"identity, memory, and provenance in a device that fits in your pocket" — by **rUv and Roger**
(`github.com/ruvnet/optimizer`, the **same ruvnet lineage as RuVector**; the cognitum coherence-gate
concept in silicon). The USB *drive* is only a **read-only window**; the canonical device is a computer
exposing itself over **USB Ethernet**.

| Identity | Value |
|---|---|
| Device ID | `0e34a5e5-a7b6-4c68-ad04-e437e22f326a` |
| Hostname | `cognitum-578b.local` |
| Provisioned | 2026-05-01 06:38:23 UTC |
| TLS fingerprint (pin) | `FF:B6:CF:0F:B7:81:A8:A9:6B:1A:71:A0:48:EF:3E:11:44:A8:C0:83:14:F5:EE:48:93:28:94:55:BF:E3:E1:67` |
| Endpoints | `https://169.254.42.1:8443` (TLS) · `http://169.254.42.1` (USB-only) · `ssh genesis@169.254.42.1` |

**Authoritative board class (live `STATUS.txt`, checked 2026-06-13):** **CPU = ARMv7 Processor rev 4
(v7l); Architecture = `armv7l`; Memory = 474 MB; Storage = 3.8G of 14G; Kernel = `6.12.47+rpt-rpi-v7`;
CPU Serial `000000004192578b`.** This is a **32-bit Raspberry Pi OS userland** running a `cognitum-agent`
service — **not** a Pi5/aarch64 board and **not** the bare-metal ruvix kernel (see
[Reconciliation](#reconciliation-with-the-icm-map), Q5.4).

**Capability map (all guide sections read):** on-device **RVF binary vector store** + k-NN graph +
epochs; **witness chain** (every write appends a SHA-256-linked entry; `POST /api/v1/witness/verify`;
**manual witness entries accept custom event strings** ← the integration hook); **custody (Ed25519)**
device-unique keypair, **private key never leaves** (`custody/sign|verify|attestation`); **MCP proxy
(ADR-047): 114 tools / 21 groups / 3 scopes** (minimal 18, default 24, full 114) with policy-engine +
**witness binding**; sensors+drift (ADR-041), thermal governor (ADR-043), temporal coherence (ADR-042),
delta sync + swarm (ADR-040); security — OTA signed firmware, boot attestation, mTLS, **USB implicitly
trusted (ADR-057)**, bearer-token over WiFi (ADR-048).

**Live state (probed 2026-06-12):** **mass storage READABLE** (wall half-cleared); **USB Ethernet NOT
enumerating** — `curl https://169.254.42.1:8443/api/v1/status` times out; the guide's own fix is *"use
the USB **data** port (not power-only)"* → **NEEDS-HUMAN: replug to a data-capable USB-C port.**
**CRITICAL RECONCILIATION (verbatim):** the seed needs **NO secret key**, so the **envctl secret-key USB
is a DIFFERENT device — do not conflate.**

---

## PLAN-cognitum-seed-envctl-vault-factor.md — the USB-factor integration

`PLAN-cognitum-seed-envctl-vault-factor.md` (2026-06-13, "Option 3: full envctl vault-factor") wires the
Seed in as **envctl's USB possession factor** — and is the **single most map-updating doc** here, because
its Steps 3–6 are now **IMPLEMENTED and MERGED**, retiring several `todo!()` stubs that `map/03 §3.4`
recorded as open. **Hard constraint (owner):** *"a refactor is out of the question and results in
automatic break"* — the Seed is consumed only via **documented** endpoints; **MCP is rejected (token suck
— 114 tools)**; access plane = **SSH + a single REST `custody/sign` call**.

**The keystone finding:** envctl's USB-possession factor is **a seam deliberately left unimplemented**,
waiting for a backend. Wiring the Seed = *providing the missing `UsbProbe` backend + its `PresenceGate`
Profile* — the dual-KEK math, slot format, possession-gating, and daemon plumbing **already exist and
stay untouched.** "Possession of the Seed" ≡ "ability to obtain a valid Ed25519 signature from device
`0e34a5e5…`" — Ed25519 is **deterministic** (same message + same device key ⇒ same 64-byte sig), so the
signature is reproducible KEK material that `kek_from_usb` (HKDF-SHA256) already expects.

**Implementation state (✅ all verified MERGED to `envctl` `master` @ `42b21f9` this read):**

| Step | What landed | Commit / PR |
|---|---|---|
| 2 — deterministic-sign SPIKE | byte-identical 64-byte sig across calls **and** a real `cognitum-agent` restart (`uptime_secs:1`) → KEK material confirmed | spike 2026-06-13 |
| 3 — `RealUsbProbe::keyfile_for` | `seam.rs` shells the documented SSH `custody/sign` path via `std::process` (**no linked dep → no-C gate stays green**); `#[cfg(feature="seed-factor")]`; old `todo!()` panic replaced with fail-closed `None` | `595f357` |
| 4 — `SeedPresenceGate` (Profile **S**) | **first concrete `PresenceGate` impl** (A/B were comment-only): fresh 32-byte challenge → Seed signs → **`ring` Ed25519 verify against the pinned device pubkey** → `Present`, else `Unproven` (fail-closed) | `373f383` |
| 5 — vault init w/ Seed factor | `secretd read_usb_keyfile` forwards to `RealUsbProbe`; `Vault.Init --enroll-usb` enrolls a Seed-backed USB keyslot **alongside** the passphrase recovery keyslot; **live daemon round-trip: `vault unlocked (factor: usb)`** and `(factor: passphrase)` both proven | `bfc44c7` |
| 6 — docs + ADR | `envctl/docs/adr-seed-usb-possession-factor.md` (RFC 8032 Ed25519 determinism, RFC 5869 HKDF, Seed ADR-048/057/058) | `47142fb` |
| Follow-up A — relay gate | egress/mint sites route through one `presence_proven()`: Profile A (on-box keyfile, uncached, no grace) / **Profile S** behind a **5s presence cache** (the one deviation from REQ-SEC-13 no-grace, only when Profile S active) | `068491e` |

**Bootstrap DONE:** SSH key enrolled (`~/.ssh/id_ed25519.pub` `SHA256:wU27yvDRHUJgPMk…` → `genesis`
`authorized_keys`); passwordless key-auth verified → host `cognitum-578b`, `armv7l`. The `genesis`
password (`cognitum`) is in the **live device-served `/guide`** (line ~2111), **NOT** the static
`guide.html` on the read-only drive. **SSH key possession = the candidate envctl possession factor.**

> **Wire-format confirmed against primary data:** the real spike triple (pubkey `86e6121e…`, msg
> `b"envctl/usb-kek/v1/spike"`, sig `90017fcc…`) verifies under `ring` ED25519 — the Seed signs **raw
> UTF-8 `data` bytes** with standard (non-prehashed) Ed25519. **Operational hazard (verbatim):** a test
> daemon wrote to the real dev libSQL store (`127.0.0.1:8080`) — cleanup owed; isolate with
> `SECRETD_STORE_BACKEND=inmem` + `XDG_CONFIG_HOME` override.

---

## MIROFISH-PORT-PLAN.md — teri IS the vehicle (W4)

`MIROFISH-PORT-PLAN.md` (W4, 2026-06-12) is the full plan behind `map/08 §B.3` (`mirofish-port-decision`).
**Method:** three parallel deep-reads (upstream `666ghj/MiroFish` + offline forks + CLI fork; `teri` full
source walk with `cargo test` run live; `shimmy` API-surface matched field-by-field against `teri/src/llm.rs`),
workflow `wf_5cdc9018`.

**Verdicts:** (1) **`teri` IS the vehicle — extend it; do not port fresh.** teri = honest **~6.7k-LOC
Rust skeleton, 140 passing tests** (133 unit + 7 integration, 0 failures), module map mirrors MiroFish's
5 stages 1:1. (2) **`shimmy` is the inference slot** — its `/v1/chat/completions` shapes match teri's
`OpenAiAdapter` exactly, **with four named gaps.** (3) **Do NOT port Flask/Vue** — meta already owns the
front-door plane (prompt_hub + RuVocal) and the visualization plane (n8n; D3 = a JSON endpoint).
(4) **License: upstream MiroFish is AGPL-3.0, teri is MIT** — **parity by spec, never code copy.**

**teri reality (parity matrix highlights):** **REAL** — `seed/` (pdf via pdfium + md/txt/json/url,
*exceeds* upstream), `agent/` (minijinja personas), `sim/` (two-phase ticks, futures-buffered LLM
concurrency, God-events), `report/` (generate + stream), `llm.rs` (OpenAI/Ollama/vLLM/Anthropic/Gemini
adapters + retry). **PARTIAL** — `graph/` (`KnowledgeGraph::build` is an **explicit placeholder
`graph/mod.rs:223`** = the **P1 keystone**), `memory/` (redb `MemoryStore` works, **zero callers — wire
it**). **STUB** — `main.rs` both verbs bail, `api/` = DTOs + a ready SSE `TickStream` but **NO axum
server** despite README claims.

**shimmy fit — four gaps:** serialized inference (one `Arc<Mutex<GpuRuntime>>`, no batching); no
`/v1/embeddings`; `response_format json` ignored; **default `max_tokens=256` when omitted** (P1
one-liner: teri must send it). **DANGER (GGUF-only guard):** the SafeTensors engine returns **canned
text** and the HF engine has a **hardcoded Windows python path** — teri must verify the model is
GGUF-served or the swarm silently simulates on fake text.

**Phases:** **P1** wire-the-spine (e2e run vs shimmy GGUF + `verdict.json` + hygiene); **P2** parity-core
(ontology, OASIS-grade personas/config, platform presets, ReACT tools); **P3** serve+estate (axum on
existing DTOs, interview/chat, **prompt_hub dispatch composing HFTASK-0003/0021**, n8n map); **P4**
scale+provenance (embeddings, shimmy throughput, **RVF/Seed witness on sim runs** — hardware anchoring
once the Seed's data port is live, a provenance upstream lacks). Keep **petgraph+redb embedded** (no
Neo4j); secrets flow through the **envctl injection seam** (FIX-1, PR#4 merged), **NOT `export LLM_API_KEY`**.

> **Live-code flag:** `teri/src/main.rs` still bails — `"Pipeline not yet implemented"` (`main.rs:91`)
> and `"API server not yet implemented"` (`main.rs:107`). **FIX-1 landed** (keyless arg-parse,
> envctl-injection seam, GGUF guard, hygiene), but **P1 spine-wiring is NOT done** — `map/08 §B.3` is
> current as of this read.

---

## Reconciliation with the ICM map

These seven docs are the **authoritative substrate** the ICM `map/01..08` was synthesized from. The
reconciliation, per open question, with `CONFIRM` / `UPDATE` / `CONTRADICT`:

- **`map/01 §2.1` "only weave protected" → UPDATE (twice).** First corrected to **3 protected**
  (`.github/main`, `lane/main`, `weave/master`) by `META-ORG-AUDIT.md`; then **superseded** by the
  2026-06-13 repo-owned rollout (`allow_auto_merge` on **63 repos**; protection on **`icm/main` +
  `envctl/develop`**). See **Q1.4** below — the current map's `map/01 §3.3` note already carries this.

- **`map/01 §2.2 / §3 / §5.1` (policy-v2, audit, census) → CONFIRM.** Every count, tier, repo name,
  PR number, and verdict in `map/01` is reproduced verbatim from `META-ORG-POLICY.md`,
  `META-ORG-AUDIT.md`, and `ARCHITECTURE-TRUTH.md`. No contradiction.

- **`map/01 §4` portability / ADR-0006/0007/0008 → CONFIRM + sharpen.** `PORTABILITY-AUDIT.md` is the
  primary source; `map/01`'s "real file in meta, symlink outside" + never-downgrade-guard examples
  (`rtk` 0.42.2/0.42.4, `kasetto` 3.0.0/3.1.0) are exact. **Sharpen:** the 40-symlink applied state and
  the **virgin-`$HOME` proof still owed** are the live residue.

- **`map/03 §3.4` inject-seam → UPDATE + sharp CONTRADICTION resolved.** The map (and Q3.1) **conflate
  two distinct seams**. The live `envctl` HEAD shows: **(a) the USB-possession / vault-unlock seam is
  MERGED** (`RealUsbProbe::keyfile_for` → `seed_factor`, `SeedPresenceGate`, dual-KEK unlock; PR #50);
  **(b) the auto-injection / data-plane seam is STILL `todo!()`** — `inject.rs:39 injection_template →
  todo!()`, `lib.rs:1630 run_child → todo!()`, `ca.rs:10 LocalCa → todo!()`, `secretd grpc.rs:337
  MintResp{injection: None, // not wired in Phase 6}`; the `secrets-inject-pr2`/`pr2b`/`seam` branches
  exist **only on `origin`, NOT merged**. **The PLAN doc's "IMPLEMENTED" claims are about (a), not (b).**

- **`map/03 §5` envctl git workflow → CONFIRM.** `develop` = working + GitHub default; `master` =
  protected ff-mirror; `required_linear_history` FALSE / reviews NULL. The 2026-06-13 rollout's
  `protection on envctl/develop` matches the develop-as-default model.

- **`map/05 §3` cognitum hardware tier → UPDATE (board class).** `COGNITUM-SEED.md` + the live
  `STATUS.txt` settle the internally-inconsistent board claims (Pi Zero / Pi5 / bcm2711) to a single
  authoritative fact: **`armv7l`, ARMv7 rev4, 474MB, kernel 6.12.47+rpt-rpi-v7** — a 32-bit Pi-class
  device running a `cognitum-agent` userland. The `cognitum-gate-tilezero`-targets-Pi5 and
  ruvix-targets-bcm2711 claims describe the **RuVector source crates' *targets***, not this physical
  Seed. See **Q5.4**.

- **`map/05 §3.1` "seed needs no secret key, distinct from envctl USB" → CONTRADICT (nuance).** Both
  `COGNITUM-SEED.md` and `map/05` say the Seed needs no key and is a *different* device from the envctl
  secret-key USB. **The PLAN doc reconciles this WITHOUT conflating them:** the Seed is not a passive
  key-stick, but its **Ed25519 `custody/sign` becomes the envctl USB-possession *factor*** — the Seed
  *replaces* the never-located "envctl secret-key USB stick" as the possession backend. The two are
  still distinct *concepts* (Seed = hardware RoT; envctl USB = a possession factor), but the **same
  physical Seed now satisfies the envctl factor.** This is newer than `map/05`/`map/08 §A.5`.

- **`map/08 §A.5` hardware walls → UPDATE.** Wall #2/#3 (envctl blocked by the USB secret key; the USB
  is the entry point to ruvector/ruflo) is **partially cleared**: the vault-unlock factor is
  implemented + live-verified, with a **passphrase recovery keyslot** so a lost/dead Seed is never a
  permanent lockout. Wall #4 (Seed mounts/activates) is **half-cleared** — mass storage readable, but
  **USB-Ethernet still needs a data-capable port + plugged-in-at-boot** (genuine NEEDS-HUMAN). See **Q8.5**.

- **`map/08 §B.3` MiroFish/teri → CONFIRM.** `MIROFISH-PORT-PLAN.md` is the exact source; `map/08`'s
  evidence, phases, GGUF-guard, and "extend teri, parity-by-spec" are verbatim. **Sharpen:** teri's P1
  spine-wiring is **not yet done** (`main.rs` still bails) — the doctrine landed, the port did not.

---

## Cross-references

- [`00-overview`](00-overview.md) — the one-screen planes model; this doc backs the CONTROL PLANE
  (org policy v2, portability) and COMPUTE SUBSTRATE (cognitum hardware) rows.
- [`01-meta-control-plane`](01-meta-control-plane.md) — the primary consumer: policy-v2, the org
  audit/protection rollout, the portability mission, the architecture-truth census all live there as
  ICM concepts; this doc is their authoritative source + the protection-inventory reconciliation (Q1.3/Q1.4).
- [`03-envctl-kasetto`](03-envctl-kasetto.md) — the inject-seam (the **two distinct seams** clarified
  here, Q3.1/Q3.4), the `env-ctl` naming-retirement debt (Q3.5), and the USB-possession factor the
  PLAN doc implements.
- [`05-ruvector-substrate`](05-ruvector-substrate.md) — the cognitum hardware tier + the `armv7l` board
  resolution (Q5.4); the RVF witness chain the Seed mirrors on-device.
- [`08-gaps-seams-merge`](08-gaps-seams-merge.md) — the hardware walls (Q8.5), the MiroFish→teri port
  doctrine, and the envctl-injection-seam gap.
