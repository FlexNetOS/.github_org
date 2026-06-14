# Research Ledger — `.github_org` meta-refactor gap analysis

**Question:** Assess the current state of `FlexNetOS/.github` (`.github_org`) against the mission —
a major refactor to match the **meta peer-repo architecture** and the meta peer-repo vision.
Monorepo is OUT; meta `.meta.yaml` peer model is the target; the repo's enduring responsibility is
**GitHub workflows + org GitHub policy** (roles 1 + 6, which require the magic `.github` name).
Deliverable: decision-grade gap analysis — done / drifted / blocking / recommended sequencing.

**Map index:** structural map in `reports/codemap.md`. Authoritative inputs: `VISION.md` (6 roles),
`MIGRATION.md` (KEEP/MOVE/MIGRATE/DROP + drift flag), parent `../CLAUDE.md` + `../.meta.yaml`
(peer model + already-declared peers), this repo `CLAUDE.md`.

Status legend: `[ ]` open · `[~]` in progress · `[x]` done · `[!]` blocked/gap.
Dependency order: map → current-state → target-shape → KEEP-readiness → MOVE/MIGRATE → sequencing.

---

- [x] **MAP** · structural map + dimensions seeded · `reports/codemap.md` (this phase)

- [x] **D1 — Current-state inventory & role realization.** For each of the 6 VISION roles, is it
  real/operational or scaffold/aspirational, and where exactly does it live? Verify the codemap's
  maturity verdicts (esp. Role 6 reusable workflows = "real, not scaffold" vs VISION.md:107's
  "Today the workflows are scaffolds"). Evidence: `VISION.md`, `.github/workflows/reusable-*.yml`,
  `secrets/`, `runner/`, `wiki/`, `repos/`, dir sizes.

- [x] **D2 — Target meta-peer-architecture conformance.** What does "match meta" concretely require
  (independent repo + `.meta.yaml` registration + tags + no submodules-as-children)? How far is this
  repo already there vs gap? Key finding to verify: it is ALREADY a peer (`../.meta.yaml:111`) with
  its own remote and is gitignored by parent (`../.gitignore:77`). Evidence: `../.meta.yaml`,
  `../CLAUDE.md` (meta model def), `git remote`/`rev-parse` reality.

- [x] **D3 — KEEP-set readiness (the enduring roles 1 + 6).** Are community-health (role 1) and
  reusable-CI (role 6) production-ready and properly "slim"? Audit each `reusable-*.yml` input
  contract + least-priv `permissions:`; confirm community-health completeness; assess `@v1` tagging
  gap (`RELEASING.md`). What does the slimmed 2-role repo look like? Evidence: all 8 `reusable-*.yml`,
  `.github/{CODEOWNERS,ISSUE_TEMPLATE,dependabot.yml,actionlint.yaml}`, `profile/README.md`, root
  community-health files, `RELEASING.md`.

- [x] **D4 — MOVE/EXTRACT readiness (roles 3,4,5 + config dirs → flexnetos_* peers).** For each MOVE
  target (wiki→flexnetos_wiki, runner→flexnetos_runner, github-app→flexnetos_github_app,
  brain-data→flexnetos_brain, secrets→**envctl per ADR-0007**, .claude/.codex/.agents/.omc→config
  peers): coupling to the rest of the repo, extraction blockers, extract-then-remove safety. Confirm
  the secrets-supersession (MIGRATION.md says flexnetos_secrets; `../.meta.yaml:122` says RETIRED →
  envctl). Evidence: `MIGRATION.md` MOVE table, `../.meta.yaml:122-136`, the dir contents, ADR-0007/0008
  (fetch from meta KB — not on disk here).

- [x] **D5 — Role-2 submodule→meta-peer migration & manifest drift.** Quantify + resolve the three-way
  drift: 17 committed gitlinks vs 7 `.gitmodules`-mapped vs ~28 manifest entries. Which gitlinks
  become `.meta.yaml` peers, which are discarded (ruvector/weftos)? What breaks when `.gitmodules` +
  `scripts/submodule-*.sh` + `submodule-bump.yml`/`manifest-drift.yml` are retired? The "aspirational
  ~28 vs actual 17" decision (MIGRATION.md open-question 5). Evidence: `git ls-tree -r HEAD` gitlinks,
  `.gitmodules`, `repos/MANIFEST.yaml`, `tools/MANIFEST.yaml`, `network/MANIFEST.yaml`,
  `scripts/submodule-*.sh`, the two manifest workflows.

- [x] **D6 — Migration sequencing & risk.** Given destinations are already registered as peers but
  content isn't extracted, what is the safe order? Validate extract-then-remove atomicity
  (MIGRATION.md:11), the data-loss guard on `secrets/`, the open destination questions
  (MIGRATION.md:83-89), and recommend the single next action. Surface blockers: ADRs not on disk,
  reusable-secrets fate, network/ split. Evidence: `MIGRATION.md` Safety + open-questions, `Makefile`
  verify gate (shrinks as role 2 leaves), `TODO.md`/`USER.TODO.md`.

---

## Notes / gaps flagged at MAP
- [!] ADR-0007 (secrets→envctl) and ADR-0008 (runner+app P0) are **referenced in `../.meta.yaml`
  but absent from `architecture/adr/` on disk** (only ADR-0001 present). Governing decisions live in
  the meta workspace KB. D4/D6 must fetch them from there, not assume MIGRATION.md is current.
- [!] MIGRATION.md is partially **stale**: its `flexnetos_secrets` row is superseded by the
  envctl decision. Treat MIGRATION.md as intent-to-verify, not ground truth, where `../.meta.yaml`
  comments contradict it.
