# Plan — deep-review upgrade plan (SESSION-2026-06-17-009)

**Date**: 2026-06-17 · **Owner**: FlexNetOS · **Source**: 4-stream deep code review (Python tooling,
GitHub Actions workflows, shell/hooks, policy-as-code + structure) over `develop` @ promotion to `main`.
**Invariant**: never-downgrade — fix forward, do not delete work as "drift".

Every finding below was spot-verified against the actual source (file:line). Severity: **P0** blocker /
**P1** high / **P2** medium / **P3** low.

---

## 0. GATING DECISION (blocks the largest fix cluster) — owner only

**The repo is named `.github_org`, not `.github`.** A GitHub org's defaults-provider repo must be named
*exactly* `.github` to auto-apply the org profile README + community-health files + default workflows
org-wide. Per [ADR-0002](../adr/ADR-0002-lean-github-org-relocate-to-hubs.md) the rename is an
**intentional** strip-and-relocate migration whose end state restores the lean `.github` role.

**Decision needed:** what is the FINAL repo name?

- **(A) Restore lean `.github`** (ADR-0002 end state): complete the strip, then rename `.github_org` →
  `.github` (or split the lean community-health + reusable-CI surface into a real `.github` repo). In
  this case the ~80 `FlexNetOS/.github` references and the `github.repository == 'FlexNetOS/.github'`
  self-CI gates are **already correct for the end state** and must NOT be mass-rewritten — only the
  *interim* breakage matters.
- **(B) Keep `.github_org` permanently**: then role #1 (community-health inheritance) is dead and must
  be struck from README/VISION, AND all ~80 `FlexNetOS/.github` references must be rewritten to
  `.github_org`.

Everything in §3 (the rename-reference cluster) is **direction-dependent on this decision.** Until it is
made, those references are left as-is (rewriting them the wrong way is a downgrade).

---

## 1. DONE this session (protective fixes already landed)

- ✅ **Live merge-gate unblocked** — added `RepositoryRole` admin(id 5) `bypass_mode:always` to the
  `protect-develop` + `protect-main` rulesets (sole-admin can self-merge; rule still applies to others).
- ✅ **`rulesets.json` now declares those bypass_actors** (this PR) — was the #1 landmine: the committed
  policy had **no** `bypass_actors`, so the next `apply-github-policies.py --apply` would have silently
  **wiped the live admin bypass** and re-blocked all merges. Config-as-code now matches live.
- ✅ **`claude-review` fixed** — `claude-code-review.yml` synced to the default branch (#130); the Claude
  App's workflow-identity check now passes (verified live: "App token successfully obtained").
- ✅ **develop → main promoted** (#137); main tree is byte-identical to develop.

---

## 2. P0 / P1 — real bugs (verified), fix regardless of §0

| # | Sev | Location | Bug | Fix |
|---|-----|----------|-----|-----|
| 2.1 | P1 | `apply-github-policies.py` check_rulesets (≈372-414) | Drift check **never compares `bypass_actors`** → after §1 it reports "no drift" whether the live bypass is present or wiped. Also `_rule_params_match` is one-directional (misses surplus/removed live params). | Add a `bypass_actors` comparison; make param comparison symmetric. |
| 2.2 | P0 | `sync-labels.yml:58-65` | `gh()` does `return result` (a `CompletedProcess`) but caller does `code,out,err = gh(...)` → **`TypeError` on every run**; label sync is dead. | `return result.returncode, result.stdout, result.stderr` (or fix the call site). |
| 2.3 | P1 | fleet templates: `templates/rust-canon/` (dir) vs `templates/rust-canon-rulesets.json` (orphan) | `apply-fleet-policies.py` reads `<template>/rulesets.json` from the **dir**, which has only branch-protection + repo-settings → **fleet rulesets (Conventional Commits, required checks, branch-target) are silently never applied** to the 10 canon repos. | Move `rust-canon-rulesets.json` → `rust-canon/rulesets.json`; move `branch-target-develop.json` → `branch-target-develop/rulesets.json`; delete the loose duplicate `rust-canon-branch-protection.json` / `rust-canon-repo-settings.json`. Also: the two same-named `rust-canon-branch-protection.json` vs `rust-canon/branch-protection.json` **disagree** on `required_linear_history`/`required_conversation_resolution` — reconcile. |
| 2.4 | P1 | `apply-fleet-policies.py` (whole) | No `--check`/drift mode and **no spec validation** — the higher-blast-radius (10-repo) applier has the weaker safety; ~120 lines are byte-for-byte duplicated from `apply-github-policies.py`. | Extract a shared applier module both import; port `validate_*` + `--check` into the fleet path. |
| 2.5 | P1 | `apply-github-policies.py` repo_slug()/main (≈443,465) | `--apply` mutates whatever repo `gh repo view` resolves from CWD, with **no assertion** it equals the intended `FlexNetOS/<name>`. Wrong-clone/`gh` default → policies PUT to the wrong repo. | Require `--owner/--repo` or assert resolved slug before any mutating call. |
| 2.6 | P0 | `scripts/install-v5-architecture.sh:68` (+257,107,121,319) | `do_or_dry()` runs `eval "$@"` over strings that interpolate sourced secrets (`$VPROXY_PASS` from `~/vproxy/.env`); a secret with `'`/`$(...)` breaks out and is **eval'd as code**. | Drop `eval`; run argv arrays directly (`"$@"`); never interpolate secrets into command strings. |
| 2.7 | P1 | `scripts/install-v5-architecture.sh:234-240` | `sudo rm -f /etc/resolv.conf` + rewrite + `chattr +i` with no `trap` to restore on mid-`set -e` failure → can leave the host with **no DNS** + immutable bit. | Write+verify fallback first; install `ERR`/`EXIT` trap doing `chattr -i` + restore; atomic `mv` not `rm`+recreate. |
| 2.8 | P1 | `secrets-mirror-to-bws.sh:63` / `secrets-rotate.sh:7,19` | `pass show` failure can push an **empty secret** to BWS; default `STORE=./secrets/store` is CWD-relative so rotation run elsewhere reports "0 stale" (false all-clear). | Fail-closed on decrypt error + reject empty values; resolve store from `git rev-parse --show-toplevel` or require absolute `PASSWORD_STORE_DIR`. |
| 2.9 | P1 | `github-doctor.py:216` | `default_branch`/`repo` used unconditionally after a `gh repo view` that may have failed (only bound inside the success branch) → `NameError`/`AttributeError`. | Initialize defaults + early-return on failure. |

## 3. Rename-reference cluster — **direction depends on §0** (do not touch until decided)

| # | Sev | Location | Issue |
|---|-----|----------|-------|
| 3.1 | P0* | `reusable-secrets.yml:58` | `repository: FlexNetOS/.github` — *functional* checkout of the pass-store; in the interim it clones a nonexistent repo so CI secret injection fails. (Correct only once the repo is named `.github` again — see §0-A.) |
| 3.2 | P1* | `reusable-meta-rust-ci.yml` (54/57/63/71), `reusable-mcp-audit.yml` (26/29/34/38), `reusable-hermetic-audit.yml` (37/40/45/49), `reusable-auto-format.yml` (72/75/81/88) | 13 self-CI gates + 4 paired checkouts test/clone `FlexNetOS/.github`. Under §0-A (final name `.github`) they're correct; under §0-B (keep `.github_org`) the umbrella self-run clones a nonexistent repo and runs the wrong tree. |
| 3.3 | P1* | README badges (`:3-5`), reusable-workflow `uses:` examples in README/RELEASING/VISION/CONTRIBUTING/roadmap/CHANGELOG, `profile/README.md` links, clone instructions | ~80 files. Same direction-dependency. Under §0-A: leave. Under §0-B: bulk `FlexNetOS/.github` → `FlexNetOS/.github_org`, then re-run actionlint. |

\* Severity is for the **interim** state; resolution is gated on §0, not independently actionable.

## 4. P2 — security & consistency hardening

- **Unpinned actions** `claude-code-review.yml:38,44` — `actions/checkout@v4` + `anthropics/claude-code-action@v1` are tag-pinned on a job holding `id-token: write`; pin to full SHAs (mirror `claude.yml`).
- **Script-injection defense-in-depth** — `inputs.*` interpolated into `run:` shells in `reusable-meta-rust-ci.yml:93`, `reusable-auto-format.yml:124`, `reusable-secrets.yml:50/75/97`, `reusable-notify-downstream.yml:60-61`, `reusable-test.yml:103`, `reusable-lint.yml:177-178`. Move to `env:` + quoted `"$VAR"` (the pattern already used in `branch-target-guard.yml`).
- **Over-broad perms** `manifest-drift.yml:19` `pull-requests: write` (no job writes PRs) → `read`.
- **Double governance** — branch-protection.json AND rulesets.json both enforce reviews/checks on main+develop; consider consolidating on rulesets-only to avoid two-source drift. Confirm the "Guard main branch target" required check actually exists (else main self-blocks).
- **`mcp-doctor.py:20` SECRET_RE** — misses `github_pat_…`/`glpat-`/AWS keys and false-positives on 40-hex git SHAs (pinned action refs); tighten.
- **`apply-*-policies.py`** — `list_rulesets`/`check_environments` GitHub reads not paginated (`--paginate`); dry-run skips `list_rulesets` so it can't show create-vs-update.

## 5. P3 — hygiene / cleanup

- `github-doctor.py:239` dead tautological `writable_teams`; `verify-markdown.py:13-16` double-assigned `EXCLUDE_*`; `secrets-mirror-to-bws.sh:82` `skips` never incremented.
- Hooks: `.githooks/{post-merge,pre-commit,pre-push}` derive root from `BASH_SOURCE/..` → use `git rev-parse --show-toplevel`; `commit-msg:19` uses non-POSIX `[ -o ]`.
- `runner/install.sh:86` re-extracts a cached tarball with no checksum; `install-v5:126` `curl|sh` unpinned root install — verify SHA before extract/install.
- Docs: roadmap says `renovate.json5` (actual `renovate.json`); README "five vs six roles" incoherence; `.claude/settings.canonical.json` is a notes file, not a canonical shape (rename to avoid "fix the drift" confusion); dangling manifest/submodule machinery (`gitmodules-drift-guard.sh`, `verify-manifest.py`, "Validate manifests" required check) for the retired submodule role — remove or restore a real manifest.
- `semantic-pr-title.yml:39` literal-`\n` fallback never expands on the `workflow_call` path (use a block scalar).

## 6. Suggested sequencing

1. **§0 decision** (owner) — unblocks §3.
2. **§2 real bugs** in dependency order: 2.2 (sync-labels), 2.3 (fleet templates), 2.1 (drift bypass_actors), 2.6/2.7 (install-v5 safety), 2.8 (secrets store), 2.5/2.9 (applier/doctor guards), 2.4 (dedupe appliers).
3. **§3** per the §0 decision (single sweep + actionlint).
4. **§4** hardening, then **§5** cleanup.

Each item is small/independent → one focused PR per item (or per cluster), develop-first, admin-merge on green. None block day-to-day work; §2.1/2.6/2.7 are the highest-risk and should go first.
