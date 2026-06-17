# D3 — KEEP-set readiness: roles 1 (community-health) + 6 (reusable-CI) + org policy

**Question:** Are community-health (role 1) and reusable-CI templates (role 6), plus org GitHub
policy artifacts, production-ready and properly "slim"? What does the slimmed 2-role repo look like,
and what is the gap to production?

**Verdict (1 line):** The KEEP-set is **content-complete and production-shaped** (8 reusable
workflows with documented inputs + least-privilege permissions + real logic; full community-health
fallback set), but **not yet production-consumable** — there is **no `@v1` tag** (zero git tags),
RELEASING.md still self-describes the workflows as "scaffolds", and 2 of the 8 reusables belong to
the role-2/role-4 sets being removed.

---

## Role 6 — reusable workflows

### Reusable workflow audit table

| Reusable workflow | `workflow_call`? | inputs documented? | permissions least-priv? | real job logic? | notes |
| --- | --- | --- | --- | --- | --- |
| `reusable-build.yml` | yes (`:11`) | yes — 5 inputs each w/ `description` (`:12-36`) | yes — `contents: read` (`:38-39`) | yes — bun/node/python/rust dispatch + artifact upload (`:80-128`) | KEEP. Clean. |
| `reusable-lint.yml` | yes (`:14`) | yes — 4 inputs (`:15-34`) | yes — `contents: read` (`:36-37`) | yes — md+actionlint+per-lang lint (`:83-173`) | KEEP. Dogfooded by `ci.yml`. |
| `reusable-test.yml` | yes (`:12`) | yes — 5 inputs (`:13-37`) | yes — `contents: read` (`:39-40`) | yes — per-lang test + coverage artifact (`:81-136`) | KEEP. |
| `reusable-typecheck.yml` | yes (`:21`) | yes — 4 inputs (`:22-41`) | yes — `contents: read` (`:43-44`) | yes — tsc/typecheck script (`:81-104`) | KEEP. **Only reusable with `continue-on-error`** (`:52`, report-only on PR) — the explicit "report-only → STRICT" convention is wired here and nowhere else. |
| `reusable-security.yml` | yes (`:14`) | yes — 4 inputs (`:15-35`) | yes — scoped: `contents: read`, `security-events: write`, `actions: read` w/ inline rationale (`:37-40`) | yes — CodeQL + Trivy fs/IaC + Gitleaks, 3 isolated jobs (`:42-152`) | KEEP. Best-documented; references `@v1`/RELEASING.md (`:11`). |
| `reusable-release.yml` | yes (`:12`) | yes — 5 inputs + typed `secrets:` + `outputs:` (`:13-53`) | yes — `contents: write`, `pull-requests: write`, `issues: write` (broad but minimal-for-release) (`:55-58`) | yes — release-please/semantic-release + moving-major-tag push (`:60-118`) | KEEP. This is the workflow that itself cuts downstream `@v1` tags. |
| `reusable-secrets.yml` | yes (`:23`) | yes — 3 inputs (`:24-39`) | yes — `contents: read` (`:41-42`) | yes — `pass`/gpg injection on `[self-hosted,...,local]` (`:44-114`) | **NOT clean KEEP.** Tied to role 4 (secrets vault). Runs only on the self-hosted runner; secrets home is moving to **envctl per ADR-0007**. Fate open: follow secrets to envctl, or drop. |
| `reusable-submodule-bump.yml` | yes (`:25`) | yes — 4 inputs (`:26-46`) | yes — `contents: write`, `pull-requests: write` (`:48-50`) | yes — submodule-bump.sh + create-PR (`:52-102`) | **RETIRE.** Pure role-2 machinery (the meta peer model replaces submodules). Does not belong in a slim 1+6 repo. |

### CLAIM D3.1 — All 8 reusable workflows are `workflow_call`-shaped with documented input contracts.
Every `reusable-*.yml` opens with `on: workflow_call:` and every declared input carries a
`description:`. None contain TODO/stub/placeholder markers in job bodies.
**Evidence:** `reusable-build.yml:10-36`, `reusable-lint.yml:14-34`, `reusable-test.yml:12-37`,
`reusable-typecheck.yml:21-41`, `reusable-security.yml:14-35`, `reusable-release.yml:12-53`,
`reusable-secrets.yml:23-39`, `reusable-submodule-bump.yml:25-46`.
**Confidence:** high.

### CLAIM D3.2 — Every reusable workflow declares a top-level least-privilege `permissions:` block.
6 of 8 are `contents: read`. `reusable-security.yml` adds only `security-events: write` + `actions:
read` (required for SARIF upload, commented inline). `reusable-release.yml` and
`reusable-submodule-bump.yml` use write scopes that are the minimum a release / PR-opening job needs.
No workflow uses the default-broad token.
**Evidence:** `reusable-build.yml:38-39`, `reusable-lint.yml:36-37`, `reusable-test.yml:39-40`,
`reusable-typecheck.yml:43-44`, `reusable-security.yml:37-40`, `reusable-release.yml:55-58`,
`reusable-secrets.yml:41-42`, `reusable-submodule-bump.yml:48-50`.
**Confidence:** high.

### CLAIM D3.3 — The reusable workflows have REAL job logic, contradicting RELEASING.md's "scaffolds" claim.
The bodies dispatch real toolchains (setup-bun/node/uv/rust), run real commands (cargo/npm/uv/pytest/
clippy/tsc), run real scanners (CodeQL/Trivy/Gitleaks), and cut real releases (release-please + moving
major tag). Yet `RELEASING.md:60-66` states "Until the reusable workflows ship real bodies (not
scaffolds), there is no v1" and lists "Fill the bodies" as step 1 to v1. **This is a stale
doc-vs-code mismatch:** the bodies are already filled; the only remaining v1 blocker is the smoke-test
+ release-please merge (RELEASING.md steps 2-4), not body-filling (step 1).
**Evidence:** logic — `reusable-build.yml:80-128`, `reusable-security.yml:42-152`,
`reusable-release.yml:60-118`; stale claim — `RELEASING.md:60-66`. Codemap §2 role-6 row makes the
same correction ("real, not scaffold").
**Confidence:** high.

### CLAIM D3.4 — `@v1` does NOT exist — the repo has zero git tags. This is the headline production gap.
`git tag -l` returns empty. RELEASING.md prescribes the moving-major-tag model
(`@v1` advances per non-breaking release; `release.yml` moves it) and downstream callers are told to
pin `@v1` (`RELEASING.md:13`, `reusable-security.yml:11`, `reusable-secrets.yml:8`,
`reusable-submodule-bump.yml:17`). But no tag has been cut, so **every "@v1" pin in the docs is
currently a dangling reference** — downstream repos cannot actually consume these workflows by the
documented tag. `reusable-typecheck.yml:15`'s own example correctly uses `@main` (the only honest pin
today).
**Evidence:** `git tag -l` empty; `RELEASING.md:3-17,44-71`; `release.yml:1-25` (the self-release
that would mint v1, gated `workflow_dispatch`-only because the org doesn't yet let Actions open PRs —
`release.yml:3-6`).
**Confidence:** high.

### CLAIM D3.5 — The repo dogfoods its own reusables (ci.yml), but self-CI is mixed report-only/strict.
`ci.yml` calls `reusable-lint.yml` and `reusable-security.yml` locally (`ci.yml:21-26,60-66`) plus
inline manifest/actionlint/markdown/hermetic jobs. It is **strict** (no `continue-on-error`).
The only report-only surface is `reusable-typecheck.yml:51-52` (PR-only `continue-on-error`) and
`manifest-drift.yml` (per codemap §3/§6). So the "report-only first → STRICT" convention is applied
**unevenly**: typecheck + manifest-drift are report-only; the rest are already strict.
**Evidence:** `ci.yml:21-70`; `reusable-typecheck.yml:51-52`; codemap §6.
**Confidence:** high.

---

## Org policy surface — codified vs documented

### CLAIM D3.6 — Most org policy is codified as real artifacts; branch-protection / org-ruleset is the one gap.
Codified in-repo: `.github/CODEOWNERS` (review routing incl. security-sensitive paths,
`CODEOWNERS:8-14`), `.github/dependabot.yml` (weekly github-actions bumps, grouped,
`dependabot.yml:1-24`), `.github/actionlint.yaml` (registers `local` self-hosted label,
`actionlint.yaml:5-7`), `.github/ISSUE_TEMPLATE/{bug_report,feature_request,documentation,config}.yml`,
`.github/PULL_REQUEST_TEMPLATE.md`. Runner policy is documented prose in `runner/policies/{
runner-group.md, pr-from-fork.md}` (MOVE with role 5).
**Not codified:** branch protection / org ruleset — described only as prose in `CLAUDE.md`
(`main` protected, PR + 1 approval, linear history, squash/rebase only). There is **no
ruleset/branch-protection JSON artifact** in-repo. For a meta-native, GitOps org-policy story this is
the one missing codified surface.
**Evidence:** `.github/CODEOWNERS:8-14`, `.github/dependabot.yml:1-24`, `.github/actionlint.yaml:5-7`,
`.github/ISSUE_TEMPLATE/` (4 files), `.github/PULL_REQUEST_TEMPLATE.md`, `runner/policies/` (prose);
absence confirmed by no `*ruleset*`/branch-protection file in `.github/`.
**Confidence:** high.

---

## Role 1 — community-health fallback completeness

### CLAIM D3.7 — The community-health fallback set is COMPLETE.
All GitHub-recognized special files are present: root `CODE_OF_CONDUCT.md` (28L), `CONTRIBUTING.md`
(120L), `SECURITY.md` (89L), `SUPPORT.md` (41L), `FUNDING.yml`, `LICENSE`, `MAINTAINERS.md`, and
`profile/README.md` (2.2K org landing page with 8 cross-org community links). None are empty stubs.
**Evidence:** `wc -l` on the four md files (28/120/89/41); `FUNDING.yml`, `LICENSE`,
`MAINTAINERS.md`, `profile/README.md` all present; `profile/README.md` has 8 `blob/main` community
links (grep count 8).
**Confidence:** high.

### CLAIM D3.8 — Two role-1 artifacts carry stale/placeholder content that must be fixed before slim-production.
(a) `FUNDING.yml` is entirely commented-out placeholders ("All entries below are commented-out
PLACEHOLDERS … uncomment … when sponsorship accounts are live", `FUNDING.yml:5-10`) — functional but
inert. (b) `profile/README.md` headlines the org around `ruvector` (Brain) and `weftos` (Runtime) as
the flagship projects (`profile/README.md:9-15`), yet the migration ledger marks **ruvector + weftos
as the discard set** (codemap §4, research-ledger D5). So the public org landing page advertises two
projects scheduled for removal — a content-accuracy gap, not a structural one.
**Evidence:** `FUNDING.yml:5-10`; `profile/README.md:9-15`; codemap §4 / research-ledger D5
(ruvector/weftos discard).
**Confidence:** high (mismatch is on-disk text); medium on the "must fix" framing (depends on whether
the discard decision is final — fetch from meta KB per ledger note).

---

## This-repo's-own CI vs reusable vs role-2 machinery

### CLAIM D3.9 — The own-CI trio is clean and small; role-2 CI is what bloats the workflow dir.
Own-CI: `ci.yml` (self-dogfood, strict), `dependency-review.yml` (PR CVE/license gate, `contents:
read` + `pull-requests: write`, `dependency-review.yml:10-24`), `release.yml` (self-release,
dispatch-only, `release.yml:8-25`). These are the role-1+6 CI and are production-ready. The workflow
dir's excess is role-2/role-4: `manifest-drift.yml`, `submodule-bump.yml`, `wiki-lint.yml`,
`secrets-rotate.yml` (codemap §3-C) + the two reusables `reusable-submodule-bump.yml` /
`reusable-secrets.yml`. A slim repo drops/moves these 6.
**Evidence:** `ci.yml:1-70`, `dependency-review.yml:1-24`, `release.yml:1-25`; codemap §3 classes
B/C; this-finding table rows for the two reusables.
**Confidence:** high.

---

## Slim-repo target shape + gap (one paragraph)

The slimmed 2-role repo is: **role 1** = the community-health fallback (`CODE_OF_CONDUCT`,
`CONTRIBUTING`, `SECURITY`, `SUPPORT`, `FUNDING.yml`, `LICENSE`, `MAINTAINERS`, `profile/README.md`,
`.github/ISSUE_TEMPLATE/`, `PULL_REQUEST_TEMPLATE.md`) — already complete; plus **role 6** = the six
language-agnostic reusables that stand alone (`reusable-build/lint/test/typecheck/security/release`),
each already `workflow_call`-shaped with documented inputs + least-privilege permissions + real logic;
plus org policy artifacts (`CODEOWNERS`, `dependabot.yml`, `actionlint.yaml`) and this repo's own
strict self-CI (`ci.yml`, `dependency-review.yml`, `release.yml`). **The gap to production is four
items, none of them "write more YAML":** (1) **cut `@v1`** — there are zero tags today, so every
documented `@v1` pin is dangling and no downstream repo can actually consume these workflows by tag
(blocked behind the org letting Actions open PRs / a release-token, per `release.yml:3-6`); (2)
**rewrite RELEASING.md** to drop the false "workflows are scaffolds / fill the bodies" v1 precondition
(`RELEASING.md:60-66`) — the bodies are filled; (3) **remove the two non-slim reusables**
(`reusable-submodule-bump.yml` = role-2 RETIRE; `reusable-secrets.yml` = role-4, follow secrets to
envctl per ADR-0007 or drop) and the four role-2/4 own-workflows (`manifest-drift`, `submodule-bump`,
`wiki-lint`, `secrets-rotate`); (4) **refresh the two stale role-1 contents** — uncomment a real
`FUNDING.yml` and rewrite `profile/README.md` so the public landing page stops headlining the
ruvector/weftos discard set. A nice-to-have beyond slim: codify branch-protection/org-ruleset as an
in-repo artifact (today it is prose in `CLAUDE.md` only).
