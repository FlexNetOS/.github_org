# Plan — finish remaining upgrades before the `.github_org → .github` switch

**Date**: 2026-06-17 · **Owner**: FlexNetOS · **Decision**: §0-A of the deep-review
plan — final name restores the lean `.github` (ADR-0002 end state).
**Invariant**: never-downgrade; verify before claiming.

This plan supersedes the open tail of `2026-06-17-deep-review-upgrade-plan.md` for the
specific question "what must be true before we rename `.github_org` back to `.github`."

---

## Grounded state (verified this session)

- `main == develop` (0 files differ); fleet wrapper + hardening landed.
- Refs that *would* break at rename are **already name-agnostic**:
  `reusable-secrets.yml` and `reusable-meta-rust-ci.yml` checkout
  `${{ vars.UMBRELLA_REPO || 'FlexNetOS/.github_org' }}` → resolve correctly post-rename.
- `manifest-drift.yml` perms already `pull-requests: read` (§4 done).
- `Validate manifests` **still runs** (ci.yml validates `repos/MANIFEST.yaml` +
  `tools/MANIFEST.yaml`) — not orphaned.
- **Required-check list is correctly wired — no self-block.** All 13 required contexts
  fire on `pull_request` (ci.yml + manifest-drift.yml use no path filters;
  `Guard main branch target` is main-only and required only on main). The apparent
  "missing" checks were an artifact of inspecting a push event, not a PR.
- Fleet templates: only the 4 canonical files remain; `rust-canon/rulesets.json` is
  canonical (§2.3 effectively done).

**Net: there is no non-gated code blocker to the rename.** Remaining work is
owner/envctl-gated enforcement hardening, not correctness.

---

## Phase 1 — Non-gated (agent) — mostly verification + bookkeeping

- [x] §2.3 — fleet templates confirmed canonical (no loose duplicates).
- [x] Required-check ↔ run reconciliation — confirmed every required context fires on PRs.
- [x] §2.4 — applier dedup satisfied by the thin fleet wrapper (#162).
- [ ] §4.9 — paginate `list_rulesets` / `check_environments`. **Deferred to Phase 2**
      (live verification needs `POLICY_DRIFT_TOKEN`; default `GITHUB_TOKEN` cannot read
      rulesets/environments, so the change cannot be behaviourally verified standalone).

## Phase 2 — Owner / envctl-gated (tee up, owner actions)

1. **Provision tokens from `meta/envctl`** (vault locked → owner unlock):
   - `RELEASE_TOKEN` / `PROMOTE_TOKEN` — release + promote pipeline (TODO 5.5).
   - `POLICY_DRIFT_TOKEN` — re-promote `github-policy-drift` from REPORT_ONLY → **strict**
     (default token cannot read protection/rulesets/settings). Land §4.9 pagination with
     this so it is verified against live, multi-page reads.
2. **Set org variable `UMBRELLA_REPO = FlexNetOS/.github`** (org-admin; default token 403).
   Optional pre-rename — the interim fallback already works; needed only to drop it.
3. **`.claude/settings.json` trim** — remove 4 hardcoded `/home/` marketplace paths + the
   experimental key; relocate to `~/.claude`. Clears 2 non-required red checks.
   (user-environment change — could disable plugin marketplaces.)

## Phase 3 — The switch + activation (owner triggers; agent follows through)

1. Owner renames `FlexNetOS/.github_org → FlexNetOS/.github`.
2. Agent flips meta **PR #39** (`ci/semantic-pr-title-org-reusable`) draft → merge.
3. Agent drops the "Refactor in progress" note in meta `.meta.yaml`
   (local `path: .github_org` stays — decoupled from the GitHub name).
4. Post-rename smoke: throwaway PR in one canon repo → confirm reusable CI +
   semantic-pr-title + secrets-store checkout resolve against `FlexNetOS/.github`, and
   org community-health inheritance (profile README, default workflows) is live.

## Deferred — NOT rename blockers

- CI-failure autofix loop (large feature).
- Adoption/fork dossiers (ai-top-utility, n8n, fabro, paperclip) — unrelated to the org repo.
- Ruleset `bypass_actors` for the release bot/app (TODO 3.4 — until bot actor ID is known).

## Queue gate

Queue the owner for Phase 3 once Phase 1 is merged and the required-check reconciliation
holds (done), with Phase 2 items either completed or explicitly accepted as post-rename.
Because no non-gated blocker remains, Phase 3 can proceed as soon as the owner is ready;
Phase 2 strict-enforcement items can land before or after the rename without breaking it.
