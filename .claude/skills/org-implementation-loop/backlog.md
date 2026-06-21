# Org Implementation Loop — Backlog

Durable queue for the `org-implementation-loop` skill. Status values: `todo` · `in-progress` ·
`blocked: <reason>` · `done (PR #n)` · `needs-owner: <reason>`. The loop reads this every Phase 0;
edit here to add / reorder / retire targets. Evidence source for the HUTs:
`data/brain-data/research/harness-upgrade-and-claude-cleanup-targets.md` (PR #209).

> One task : one branch : one PR into `develop`. Never stack on a red trunk. Never self-approve.

## Targets

### HUT-1 — Purge/guard dead-feature hook wiring in tracked settings.json
- **Status:** done (PR #210)
- Effort M · Impact HIGH. Removed ~13 ruvector + gitnexus/ccg/global/omc-hud hook entries;
  reconciled `settings.canonical.json`. Seed/reference cycle for the loop.

### HUT-2 — Fix wrap-up/SKILL.md `--base main` bug (ADR-0003 violation)
- **Status:** todo
- Effort S · Impact HIGH.
- Evidence: `.claude/skills/wrap-up/SKILL.md:387` emits `--base main`; ADR-0003 / `CLAUDE.md:96`
  require `--base develop`. Also de-duplicate the overlapping push/PR steps (`:353-357` vs `:397-414`)
  and make the `wrap-up-verifier` invocation (`:238-246`, currently `Agent(...)` pseudocode) concrete.
- Acceptance: no `--base main` in the skill; the documented PR base is `develop`; push/PR steps are
  single-sourced; `make verify.markdown` green.

### HUT-3 — Runtime config-health doctor + CI job (close the doctor gap)
- **Status:** todo
- Effort M · Impact HIGH.
- Evidence: `scripts/claude-settings-doctor.js` only lints home-path residue; it cannot catch
  referenced-but-absent binaries/files or quoted-tilde non-expansion (the gap that hid the HUT-1 dead
  wiring). Add `make verify.config-health` + a report-only CI job that, for each hook command in
  `settings.json`/`settings.local.json`, resolves the leading binary (`command -v`), checks referenced
  file paths exist (expanding `~`/`$HOME`/`${META_ROOT}`), and flags quoted-tilde literals.
- Acceptance: new script + `make` target exist and pass on the cleaned config; CI job added
  `continue-on-error: true` with the promote-after-one-green-cycle comment; `make verify` + actionlint
  green.

### HUT-4 — Promote overdue trivy-secret-suppressions; reconcile advisory flags
- **Status:** todo
- Effort S · Impact MED-HIGH.
- Evidence: `.github/workflows/manifest-drift.yml:118` `trivy-secret-suppressions` is still
  `continue-on-error: true` with no promotion entry in CHANGELOG (overdue). `hermetic-audit` carries a
  step-level `continue-on-error` (`:172`) inconsistent with the job-level pattern. `github-policy-drift`
  is intentionally fail-open — codify that in a one-line comment.
- Acceptance: trivy job promoted to strict (flag removed) IFF its green-cycle history is confirmed;
  hermetic flag normalized to job level OR documented; policy-drift fail-open codified; actionlint green.

### HUT-5 — Close local↔CI drift (verify.tool-assets ∉ CI)
- **Status:** todo
- Effort S · Impact MED.
- Evidence: `make verify.tool-assets` (`scripts/toolchain.py validate`) has no CI counterpart in
  `ci.yml`. Add a `tool-assets-validate` job so the local gate is a strict subset of CI; audit other
  `verify.*` targets for the same drift.
- Acceptance: CI job added that runs the same command as the make target; `make verify.tool-assets`
  green; actionlint green.

### HUT-6 — Deliver ADR-0004 D4: reusable-rust-ci.yml portability canaries
- **Status:** todo
- Effort M · Impact MED.
- Evidence: `architecture/adr/ADR-0004-*.md` lists `reusable-rust-ci.yml` (D4) — absent. Author a
  reusable workflow with inputs (`os` default `ubuntu-latest`, `targets`, `portability-targets`
  default `wasm32-unknown-unknown`,`riscv32imc-unknown-none-elf`), Linux-default, least-priv
  `permissions`, SHA-pinned actions. Land report-only-first per the promotion rule.
- Acceptance: workflow file exists, `actionlint` green, all `uses:` SHA-pinned, `permissions` block
  present; an ADR/README note records the deliverable as landed.

### HUT-7 — Wire the 3 review subagents into PR/CI; retire stale add-submodule skill
- **Status:** todo
- Effort M · Impact MED.
- Evidence: no workflow invokes `workflow-security-reviewer` / `manifest-drift-auditor` /
  `wrap-up-verifier`. (Supply-chain is already covered by `zizmor.yml`+`scorecard.yml`+
  `reusable-security.yml`, so this is complementary depth.) Trigger `workflow-security-reviewer` +
  `manifest-drift-auditor` from `claude-code-review.yml` (or a scheduled job) on the paths they own.
  Separately, `add-submodule/SKILL.md` is `disable-model-invocation: true` but still teaches the
  ADR-0002-retired submodule-mount flow — convert to a short "DEPRECATED → hub registration" redirect.
- Acceptance: review agents wired on their path globs; `add-submodule` SKILL converted to a redirect;
  actionlint + `make verify.markdown` green.

## Pre-existing carry-overs (not loop targets — context for the green baseline)
- `CHANGELOG.md` tags `(SESSION-2026-06-17-001)` with no matching `SESSIONS.md` heading (known broken
  cross-ref; doc-integrity, tracked in `TODO.md`). Does not fail `make verify`.
- `data/brain-data/research/fork-remediation/**` markdown has pre-existing fenced-code-language errors;
  excluded by the root `make verify.markdown` invocation.
