# Harness-Upgrade & `.claude` Cleanup Targets — Deep Research (this repo only)

- **Date:** 2026-06-21
- **Scope:** `FlexNetOS/.github` umbrella ONLY (disk `/home/drdave/Desktop/meta/.github_org`). No other repo inspected, no host changes.
- **Base:** `develop` @ `2a56477`
- **Method:** 3 parallel read-only research sweeps (config-health, harness-machinery, CI/workflow) + direct verification of every contested claim before recording. Each claim below is file:line-cited and was re-checked against the live tree (agent claims that failed verification are called out in §5).
- **Deliverables:** (1) 7 ranked harness-upgrade targets (§2); (2) `.claude`/`.codex` cleanup target list (§3); (3) the supporting deep-research inventory (§4).

---

## 1. Executive summary

The repo's automation harness (skills, subagents, hooks, doctors, CI, continuity bookkeeping) is **structurally sound but has accumulated dead wiring and one actively-wrong instruction**. The two highest-value findings:

1. **`.claude/settings.json` wires ~23 hook invocations to tooling that is not installed / does not exist** — `ruvector` (NOT on PATH; ~13 entries across 7 hook events), plus `gitnexus`/`ccg`/`global` hook scripts under `~/.claude/hooks/…` that are all MISSING on disk, plus an `omc-hud` statusline whose target is absent. Two of these (`settings.json:69`, `:169`) also carry a **quoted-tilde bug** (`node "~/.claude/…"` — the `~` never expands). None of this is caught by the existing `claude.doctor`, which only lints for hard-coded home paths, not for *referenced-but-absent* commands/files.
2. **The `wrap-up` skill instructs agents to open their session PR against `--base main`** (`.claude/skills/wrap-up/SKILL.md:387`), which is protected and forbidden by ADR-0003 (base must be `develop`). The core continuity harness contradicts the canonical git workflow.

The literal failed feature the owner named — **"csj" — does not exist anywhere in the repo** (confirmed absent, case-insensitive, full tree). It was an *example* of the class of problem; the actual dead feature is **`ruvector`** (and the orphaned `~/.claude/hooks/*` integrations).

Everything else is incremental hardening (overdue CI promotions, local↔CI gate drift, an unenforced ADR-0004 deliverable, and review-subagents that are never invoked).

---

## 2. The 7 harness-upgrade targets (ranked)

| # | Target | Effort | Impact | Why now |
|---|--------|--------|--------|---------|
| **HUT-1** | Purge / guard dead-feature hook wiring in tracked `.claude/settings.json` | M | **HIGH** | ~23 hook invocations fail every session; pollutes every PreCompact/Stop/SessionStart |
| **HUT-2** | Fix `--base main` bug (+ step duplication) in the `wrap-up` skill | S | **HIGH** | Core continuity skill contradicts ADR-0003; will mis-target a PR the moment an agent follows it literally |
| **HUT-3** | Add a runtime config-health doctor + CI job (`verify.config-health`) | M | **HIGH** | Systemic guard so HUT-1-class rot cannot recur; closes the documented doctor gap |
| **HUT-4** | Promote overdue report-only CI checks; reconcile advisory flags | S | MED-HIGH | `trivy-secret-suppressions` is past its green cycle; `hermetic-audit` flag is step-level/inconsistent |
| **HUT-5** | Close local↔CI gate drift (`verify.tool-assets` ∉ CI) | S | MED | Local `make verify` is not a true subset of CI; a tool-asset manifest break passes preflight, fails CI |
| **HUT-6** | Deliver ADR-0004 D4: `reusable-rust-ci.yml` portability-canary workflow | M | MED | ADR-0004 intent (wasm32/riscv32 canaries, Linux-default) is documented but unenforced |
| **HUT-7** | Wire the 3 review subagents into PR/CI; retire ADR-0002-stale `add-submodule` skill | M | MED | `workflow-security-reviewer`/`manifest-drift-auditor`/`wrap-up-verifier` are never invoked by any workflow; `add-submodule` still teaches a wound-down flow |

### HUT-1 — Dead-feature hook wiring (the centerpiece)
**Evidence (`.claude/settings.json`):**
- `ruvector` — `command -v ruvector` → **MISSING**. Invoked at lines 17, 29, 39, 49, 59, 102, 112, 134, 144, 154, 159, 226, 267, 287 across **Notification, PostToolUse(Edit/Bash/LSP/Task), PreCompact(auto/manual), PreToolUse(Edit/Bash/Task), SessionStart(startup/resume), Stop, UserPromptSubmit**. (This session's own PreCompact log shows `ruvector: not found`.)
- `gitnexus` — lines 69 & 169 call `node "~/.claude/hooks/gitnexus/gitnexus-hook.cjs"`; file MISSING **and** the `~` is inside double quotes so it would not expand even if present.
- `ccg` — lines 189, 246, 296, 301 call `node ~/.claude/hooks/ccg/{subagent-context,session-start,workflow-state,skill-router}.js`; all MISSING.
- `global` — lines 80, 199, 276 call `bash ~/.claude/hooks/global/{auto-format,bash-log,stop-notify}.sh`; all MISSING.
- `omc-hud` — line 311 statusLine `node …/hud/omc-hud.mjs`; `omc-hud` MISSING.

**Repo-local hooks that DO exist and should stay:** `scripts/hooks/{actionlint-on-workflow-edit,protect-secrets-store,gitmodules-drift-guard,icm-architecture-inject}.sh` (all present, all wired) and `rtk hook claude` (`rtk` is on PATH).

**Proposal:** For each external integration, either (a) remove the hook entry from the tracked config (if it is purely user-global tooling that leaked into the committed file), or (b) wrap it so it self-skips when absent (`command -v ruvector >/dev/null && ruvector … || true`). Decide per-integration; the quoted-tilde entries must change to unquoted `~` or `$HOME` regardless. **Do not** silently keep wiring that fails on every clone.

> **Open decision for the owner (see §6):** is the tracked `settings.json` meant to carry your *personal* global hook stack (ruvector/gitnexus/ccg/global), or only repo-portable hooks? That determines remove-vs-guard.

### HUT-2 — `wrap-up` skill targets `main`
`.claude/skills/wrap-up/SKILL.md:387` → `--base main`. ADR-0003 / `CLAUDE.md:96` mandate `--base develop`. Also: step 7c (push) and step 8 (push/PR) overlap (`SKILL.md:353-357` vs `:397-414`). **Proposal:** change base to `develop`, de-duplicate the push/PR steps into one, and make the `wrap-up-verifier` invocation (currently `Agent(...)` pseudocode at `:238-246`) a concrete, documented call. Low effort, removes a latent protected-branch violation.

### HUT-3 — Runtime config-health doctor
`scripts/claude-settings-doctor.js` (wired via `manifest-drift.yml:43-61`) only flags hard-coded home paths + aspirational keys. It does **not** verify that referenced commands exist on PATH, that `~/.claude/hooks/*` files exist, or that quoting is sound — which is exactly why HUT-1 went unnoticed. **Proposal:** new `make verify.config-health` + report-only CI job that, for each hook command in `settings.json`/`settings.local.json`: resolves the leading binary (`command -v`), checks referenced file paths exist (expanding `~`/`$HOME`/`${META_ROOT}`), and flags quoted-tilde literals. Promote to STRICT after one green cycle per the standing CI-invariant pattern.

### HUT-4 — Overdue promotions / flag reconciliation
- `trivy-secret-suppressions` (`manifest-drift.yml:118`) is `continue-on-error: true` "for its first green cycle, then promote to STRICT" — `CHANGELOG.md:85,93` records its landing but there is **no promotion entry**; it is overdue. Promote (1-line removal) after confirming green history.
- `hermetic-audit` carries a **step-level** `continue-on-error: true` (`manifest-drift.yml:172`) — inconsistent with the job-level pattern used elsewhere; lift to job level or document why.
- `github-policy-drift` has **no** `continue-on-error` and is **not** in the required-checks ruleset — it is intentionally fail-open advisory (the script classifies unreadable state as UNVERIFIED). This is *correct by design*; just codify it in a one-line comment so it is not "fixed" by mistake.

### HUT-5 — Local↔CI gate drift
`make verify.tool-assets` (`Makefile`, runs `scripts/toolchain.py validate`) has **no** CI counterpart in `ci.yml`. Add a `tool-assets-validate` job so the local gate is a strict subset of CI (matches the repo's stated preflight philosophy). Audit the other `verify.*` targets for the same drift while there.

### HUT-6 — ADR-0004 D4 reusable workflow
`reusable-rust-ci.yml` is **absent** (confirmed); `architecture/adr/ADR-0004-*.md` lists it as deliverable D4 (portability canaries `wasm32`/`riscv32`, Linux-default matrix). Author it report-only first. Unenforced ADR intent is the gap.

### HUT-7 — Wire review subagents; retire stale skill
`grep` across `.github/workflows/*.yml` shows **no** workflow invokes `workflow-security-reviewer`, `manifest-drift-auditor`, or `wrap-up-verifier`. (Workflow supply-chain risk *is* already covered by `zizmor.yml` + `scorecard.yml` + `reusable-security.yml` + `dependency-review.yml`, so this is complementary depth, not a hole.) **Proposal:** trigger `workflow-security-reviewer` + `manifest-drift-auditor` from `claude-code-review.yml` (or a scheduled job) on the paths they own. Separately, `add-submodule/SKILL.md` is `disable-model-invocation: true` but still documents the wound-down submodule-mount flow (ADR-0002) — convert it to a short "DEPRECATED → use hub registration" redirect.

---

## 3. `.claude` / `.codex` cleanup targets (the "additionally identify" ask)

| ID | Target | Location | Status / note |
|----|--------|----------|---------------|
| C1 | Remove/guard `ruvector` wiring (~13 entries, 7 events) | `.claude/settings.json` | **DEAD** — not on PATH (overlaps HUT-1) |
| C2 | Fix `gitnexus` quoted-tilde + missing file | `settings.json:69,169` | **DEAD + bug** |
| C3 | Remove/guard `ccg` hooks (4) | `settings.json:189,246,296,301` | **DEAD** — `~/.claude/hooks/ccg/*` missing |
| C4 | Remove/guard `global` hooks (3) | `settings.json:80,199,276` | **DEAD** — `~/.claude/hooks/global/*` missing |
| C5 | Remove/guard `omc-hud` statusline | `settings.json:311` | **DEAD** — `omc-hud` target missing |
| C6 | Reconcile `settings.json` ↔ `settings.canonical.json` drift | both files | canonical has `env` block (line 3) live lacks it; live adds `statusLine` canonical lacks. Decide authoritative shape |
| C7 | Verify 5 `extraKnownMarketplaces` + 4 cross-marketplace `enabledPlugins` resolve under real `${META_ROOT}` | `settings.json:313-363` | **VERIFY, not assert-dead** — paths resolve to `${META_ROOT}/_work/...`; agents saw them "missing" because `_work/` wasn't populated in their context. If not repo-portable, move to user-global `~/.claude/settings.json` |
| C8 | Verify `model = "gpt-5.4"` is valid for the installed Codex CLI | `.codex/agents/{explorer,reviewer,docs-researcher}.toml:1` | **VERIFY** — flagged by a sweep as nonexistent; not independently confirmed here. Correct only if the installed Codex rejects it |
| C9 | Decide on tracked vendored plugin-cache bloat | `.claude/plugins/cache/*` (10 tracked files) | Plugin caches (package-lock, bridge code) are committed; likely belong in `.gitignore` unless intentionally pinned |
| C10 | "csj" failed feature | (whole tree) | **CONFIRMED ABSENT** — no occurrence anywhere; ruvector is the real dead feature |

**Doctor gap (root cause of C1–C5):** `claude.doctor` is a *portability linter*, not a *runtime verifier* — it green-lights `"command": "ruvector …"` because the string contains no home path. HUT-3 closes this.

---

## 4. Supporting inventory (deep research)

### 4.1 Skills (`.claude/skills/`)
- `wrap-up` — core continuity harness; **HUT-2** bug (base `main`) + step duplication.
- `add-submodule` — `disable-model-invocation: true` but teaches ADR-0002-retired submodule flow → **HUT-7** redirect.
- `clone-setup` — detailed research-before-fork; accurate, no end-to-end CI validation of its setup phase.
- `install-github-app` — healthy, automated smoke test (`make github-app.smoke`).
- `new-reusable-workflow` — healthy; `reusable-template.yml` ships alongside it; auto-validated by the actionlint edit hook.
- `.github` — auto-generated (2026-05-27) conventions doc; likely stale vs the repo's actual shell/Python/YAML stack.

### 4.2 Subagents (`.claude/agents/`)
`manifest-drift-auditor`, `workflow-security-reviewer`, `wrap-up-verifier` — all well-specified, **none invoked by any workflow** (HUT-7). `wrap-up-verifier` is invoked manually from the `wrap-up` skill.

### 4.3 Hooks
Repo-local (`scripts/hooks/`): all 4 present and wired (healthy). External (`ruvector`/`gitnexus`/`ccg`/`global`/`omc-hud`): dead (HUT-1).

### 4.4 Doctors / verification
Active & wired: `claude-settings-doctor.js`, `mcp-doctor.py`, `verify-manifest.py`, `verify-markdown.py`, `hermetic-audit.py`, `toolchain.py`, `apply-github-policies.py`, `github-doctor.py` (`make github.doctor`), `runner-doctor.sh` (`make runner.doctor`), `secrets-rotate.sh` (`make secrets.rotate`). `secrets-doctor.py` (3.0K) has **no** Makefile target found — candidate for wire-in-or-remove (minor; lower than the 7).

### 4.5 CI / workflows
- Action pinning: **all `uses:` are SHA-pinned** (supply-chain clean).
- `ci.yml` (7 required jobs) + `manifest-drift.yml` (advisory umbrella) + reusable-`*` library + promotion/release automation.
- Report-only still open: `trivy-secret-suppressions` (overdue, HUT-4), `check-user-todo-step5` (intentionally informational).
- Missing: `reusable-rust-ci.yml` (HUT-6).
- Local↔CI drift: `verify.tool-assets` (HUT-5).

### 4.6 Continuity
`.handoff/` **is present and tracked here** (24 files: `README.md`, `active.md`, `context/capsule.json`, ledger, …). Root bookkeeping (`TODO.md`/`USER.TODO.md`/`CHANGELOG.md`/`SESSIONS.md`) maintained by the `wrap-up` skill. Known carry-over: `CHANGELOG.md` tags `(SESSION-2026-06-17-001)` with no matching `SESSIONS.md` heading (pre-existing broken cross-ref; tracked in `TODO.md`).

---

## 5. Claims that FAILED verification (recorded so they don't propagate)
A research sweep asserted each of these; direct inspection **refuted** them:
- "`scripts/rotate-policy-drift-token.sh` / `install-policy-drift-rotation.sh` not found" — **FALSE**, both present (merged #206/#207).
- "`.handoff/` is meta-root-only / absent here" — **FALSE**, 24 tracked files in this repo.
- "`runner-doctor.sh` is never called" — **FALSE**, wired via `make runner.doctor` (`Makefile:222-227`).
- "`github-policy-drift` is incorrectly marked required" — **FALSE**, it is intentionally fail-open and excluded from the required ruleset (by design).
- C7/C8 ("marketplaces missing", "gpt-5.4 invalid") — **NOT CONFIRMED**; downgraded to VERIFY items because the sweeps judged them from a context lacking `${META_ROOT}/_work` and without the installed Codex model catalog.

---

## 6. Open decisions for the owner
1. **HUT-1 remove-vs-guard:** should the tracked `.claude/settings.json` carry your personal global hook stack (`ruvector`/`gitnexus`/`ccg`/`global`/`omc-hud`), or only repo-portable hooks? Remove if they belong in `~/.claude/`; guard-with-`command -v` if they should stay but degrade gracefully.
2. **C6 authoritative shape:** is `settings.canonical.json` the source of truth (regenerate live from it), or has the live config legitimately moved ahead (then update canonical)?
3. **C9:** keep or `.gitignore` the vendored plugin caches.

## 7. Suggested execution order (if/when these are implemented)
`HUT-2` (S, removes a live foot-gun) → `HUT-1` (M, after the §6.1 decision) → `HUT-3` (M, prevents recurrence) → `HUT-4`+`HUT-5` (S each, CI hygiene) → `HUT-6` (M) → `HUT-7` (M). Each as its own `<type>/<slug>` branch → PR into `develop` → one task : one branch : one PR (CLAUDE.md).
