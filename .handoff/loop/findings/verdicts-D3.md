# Verdicts — D3 (KEEP-set readiness)

**Verifier pass:** 2026-06-13. Adversarial verification of `D3-keep-readiness.md` against the
target at `/home/drdave/Desktop/meta/.github_org`. Default-skeptical, fail-closed.

## Per-claim verdicts

### CLAIM D3.1 — 8 reusables, `workflow_call`-shaped, documented inputs, no stubs — **CONFIRMED**
- Count is exactly 8: `ls .github/workflows/reusable-*.yml` → build, lint, release, secrets,
  security, submodule-bump, test, typecheck.
- Refutation attempt (look for echo/stub bodies): all 8 opened. `reusable-build.yml:10-36` —
  5 inputs each with `description:`; bodies dispatch real toolchains (`build.yml:53-78`) and run
  real commands (`build.yml:84-117` — `bun install`, `npm ci`, `uv build`, `cargo build --release`).
  `reusable-security.yml:14-35` — 4 inputs documented; bodies run real CodeQL/Trivy/Gitleaks
  (`security.yml:72-154`). No TODO/placeholder/`echo "stub"` markers in any job body.
- Counter-example search FAILED. Claim holds.

### CLAIM D3.2 — every reusable has a top-level least-priv `permissions:` block — **CONFIRMED**
- `reusable-build.yml:38-39` `contents: read`; `reusable-security.yml:37-40` `contents: read` +
  `security-events: write` (inline rationale `:39`) + `actions: read`; `reusable-submodule-bump.yml:48-50`
  `contents: write` + `pull-requests: write` (minimum for a PR-opening bump); `reusable-secrets.yml:41-42`
  `contents: read`. All blocks are top-level (workflow scope), not the implicit broad default.
- Refutation attempt (find a workflow relying on default token): none found. Claim holds.

### CLAIM D3.3 — real job logic contradicts RELEASING.md "scaffolds" — **CONFIRMED**
- Logic side: verified real (D3.1 evidence; `reusable-build.yml:84-117`, `reusable-security.yml:72-154`).
- Stale-doc side: read `RELEASING.md:60-66` directly. Line 60-61 literally states *"Until the reusable
  workflows ship real bodies (not scaffolds), there is no v1."* Line 63-64 lists *"Fill the bodies of
  reusable-lint.yml, reusable-test.yml, reusable-build.yml, reusable-security.yml, reusable-release.yml"*
  as step 1. The bodies are demonstrably already filled (D3.1). The contradiction is real, on-disk,
  and exactly as quoted. Claim holds.

### CLAIM D3.4 — zero git tags → no `@v1`, the headline gap — **CONFIRMED**
- `git -C /home/drdave/Desktop/meta/.github_org tag -l` → empty output; `| wc -l` → 0.
- `@v1` pins exist in docs/comments: `RELEASING.md:13` (`reusable-lint.yml@v1`),
  `reusable-security.yml:11`, `reusable-secrets.yml:8`, `reusable-submodule-bump.yml:17`. With zero
  tags, every `@v1` pin is a dangling ref — downstream cannot consume by the documented tag.
- The one honest pin: `reusable-typecheck.yml:15` uses `@main`. Confirmed.
- Refutation attempt (maybe a tag exists upstream / lightweight tag missed): `tag -l` lists ALL local
  tags (annotated + lightweight); zero. Claim holds. NOTE/QUALIFY: "zero tags **locally**" is proven;
  whether a `v1` exists on the GitHub remote was not checked (no network read performed). The dangling-
  pin conclusion is correct for this working tree; a remote tag, if any, is not reflected here.

### CLAIM D3.5 — repo dogfoods reusables; self-CI mixed report-only/strict — **CONFIRMED (spot-checked)**
- `reusable-typecheck.yml:51-52` confirmed: `continue-on-error: ${{ github.event_name == 'pull_request' }}`
  with the report-only-first comment at `:51`. It is the only reusable with `continue-on-error`.
- ci.yml's call sites and manifest-drift report-only status were taken from the analyst's cited lines
  (not independently re-opened this pass) — the load-bearing piece (typecheck is the lone report-only
  reusable) is independently confirmed. Claim holds.

### CLAIM D3.6 — branch-protection / org-ruleset is the one un-codified policy surface — **CONFIRMED**
- Searched for any ruleset/branch-protection artifact: `find` for `*ruleset*`/`*branch-protection*`
  (excluding `repos/`) → none. `grep -rli 'ruleset\|branch.protection' .github/` → 2 hits, both FALSE
  positives: `reusable-release.yml:45` (the word "branch protection" inside an input *description*
  string) and `reusable-security.yml:27` ("default ruleset" referring to gitleaks). Neither is a
  policy artifact.
- No `.github/rulesets/`, no branch-protection JSON/YAML. Absence confirmed. Claim holds.

### CLAIM D3.7 — community-health fallback set is complete — **CONFIRMED (carried)**
- `profile/README.md` read directly: present, real org landing page with cross-org community links
  (CODE_OF_CONDUCT/CONTRIBUTING/SECURITY/SUPPORT at `:20-23`). The four root md files' line counts were
  taken from the analyst's `wc -l` (not re-counted this pass) but the no-empty-stub assertion is
  consistent with the files read. No refutation found. Claim holds.

### CLAIM D3.8 — two role-1 artifacts carry stale/placeholder content — **CONFIRMED (content) / QUALIFIED (must-fix framing)**
- (a) `FUNDING.yml` read directly: lines 10-21 are ALL commented-out (`# github:`, `# patreon:` …);
  header `:5-8` self-describes them as "commented-out PLACEHOLDERS". Functional but inert. Confirmed.
- (b) `profile/README.md:9-13` read directly: the "What we build" table headlines `ruvector` (Brain,
  `:11`) and `weftos` (Runtime, `:12`) as the two flagship projects. The claim that these are the
  discard set relies on codemap §4 / research-ledger D5 (not re-derived this pass) — so the on-disk
  text is CONFIRMED, but the "must fix because discarded" framing is QUALIFIED: true only if the
  ruvector/weftos discard decision is final (cross-dimension dependency, matches analyst's own
  medium-confidence caveat at D3.8).

### CLAIM D3.9 — own-CI trio clean; role-2/4 CI bloats the dir — **CONFIRMED (the load-bearing half)**
- The two reusables that "don't belong in a slim repo" both exist and are role-2/role-4 by their own
  headers: `reusable-submodule-bump.yml:1-23` (submodule machinery, replaced by the meta-peer model)
  and `reusable-secrets.yml:1-21` (pass/gpg on `[self-hosted,...,local]`, role-4 vault). Confirmed
  present and correctly classified. The full own-CI line-by-line audit was carried from the analyst;
  the slim-vs-non-slim classification of the two reusables is independently confirmed. Claim holds.

## Tally
- CONFIRMED: D3.1, D3.2, D3.3, D3.4 (with remote-tag note), D3.5, D3.6, D3.7, D3.9 — 8
- QUALIFIED: D3.8 (content confirmed; "must-fix" framing depends on the cross-dimension discard
  decision) — 1
- REFUTED: 0
- INCONCLUSIVE: 0

All priority claims survived refutation. The headline gap (zero tags → dangling `@v1`) and the
stale-doc contradiction (`RELEASING.md:60-66` vs filled bodies) are both confirmed on-disk.
