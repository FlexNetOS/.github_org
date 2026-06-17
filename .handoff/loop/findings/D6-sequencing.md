# D6 — Migration sequencing & risk

**Question:** Destinations are already registered as meta peers but content isn't extracted.
What is the SAFE order of operations, what are the risks/blockers, and what is the single
recommended next action?

**One-line verdict:** The registry layer is done; the unfinished work is content extraction +
machinery retirement. The plan's extract-then-remove atomicity is sound *in principle* but has
two concrete violation risks (a CI job that hard-calls a RETIRE-slated script, and a secrets path
that is now real-encrypted content routed to envctl, not a new repo). Sequencing is gated by two
governing ADRs that are **not on disk**. The lowest-risk, highest-unblock next action is the
`@v1` reusable-workflow tag (the one fully-independent, zero-extraction phase).

---

### CLAIM D6.1 — Extract-then-remove atomicity is the stated plan and is structurally sound, because destinations already exist as registry entries.
The Safety principle is explicit: `main` stays fully intact until each destination repo exists;
removals happen atomically with extraction (extract-then-remove) so no content ever lives only in
a deleted state. The precondition for atomicity — that the destination exists — is **already met
at the registry level**: `flexnetos_runner`, `flexnetos_github_app`, `flexnetos_wiki`,
`flexnetos_brain` are declared peers. So per-role extraction can be done as "push content to peer
→ verify peer has it → remove from `.github` in the same PR" without ever leaving a gap.
- **Evidence:** `MIGRATION.md:11-13` (Safety principle); destination peers at
  `/home/drdave/Desktop/meta/.meta.yaml:127-138`; codemap §5 "registry-level integration is DONE"
  at `.handoff/loop/reports/codemap.md:120`.
- **Confidence:** High.

### CLAIM D6.2 — Atomicity has a concrete VIOLATION risk: removing `secrets/` is NOT a repo-to-repo move; the destination is envctl (ADR-0007), and the content is real GPG-encrypted secrets, not scaffold.
`secrets/store/` holds **actual encrypted secret material** — `openai/personal.gpg`,
`n8n/api-key.gpg`, `n8n/mcp/token.gpg`, `github/personal/cli.gpg`, `runner/.gpg-id` — not an empty
scaffold. MIGRATION.md still names a `flexnetos_secrets` destination repo, but `.meta.yaml` says
that repo is RETIRED and secrets route to **envctl** (a different existing system with its own
vault/secretd/broker). So the naive "create flexnetos_secrets, push, delete" path is wrong: there
is no destination repo, and the encrypted blobs must be re-homed into envctl's vault before the
`secrets/` tree is removed. The data-loss guard (MIGRATION.md:13 "especially secrets/") is
therefore the single highest-stakes step and the one most exposed to the stale plan.
- **Evidence:** real `.gpg` files via `find secrets/store -type f` →
  `secrets/store/openai/personal.gpg`, `secrets/store/n8n/api-key.gpg`,
  `secrets/store/n8n/mcp/token.gpg`, `secrets/store/github/personal/cli.gpg`,
  `secrets/store/runner/.gpg-id`; supersession at `/home/drdave/Desktop/meta/.meta.yaml:122-126`
  (RETIRED → envctl, "a second store would be split-brain"); stale row at `MIGRATION.md:55`
  (`flexnetos_secrets`); guard at `MIGRATION.md:13`.
- **Confidence:** High.

### CLAIM D6.3 — The CORRECT safe handling of secrets given the envctl supersession is: import-into-envctl-vault-then-verify-then-remove, mediated by the owner's GPG key — never a repo move, and never an automated delete.
Because the destination is envctl (not a git repo) and the blobs are encrypted under the owner's
GPG identity (`secrets/.gpg-id`, which USER.TODO still flags may be a placeholder fingerprint for
the *runner* identity), extraction cannot be a `git`/agent operation: it requires the human's GPG
private key to decrypt and re-encrypt into envctl's vault. The safe sequence is
(a) owner imports each `secrets/store/**/*.gpg` value into envctl's vault/secretd,
(b) verify envctl returns each secret (broker/ProviderMint path proven for the GitHub-token seam),
(c) only then remove `secrets/` from `.github` in the same atomic PR.
This makes secrets extraction a **NEEDS-HUMAN, manually-gated** step — the agent must not delete
`secrets/` on its own, and the "empty-repo archival is a NEEDS-HUMAN owner decision" note confirms
the owner-gating posture.
- **Evidence:** owner-decision posture at `/home/drdave/Desktop/meta/.meta.yaml:125`
  ("Empty-repo archival is a NEEDS-HUMAN owner decision"); ProviderMint GitHub-token seam at
  `/home/drdave/Desktop/meta/.meta.yaml:123-124`; GPG-id setup is a human step in
  `USER.TODO.md:115-156`; placeholder-fingerprint warning surfaced by
  `scripts/bootstrap.sh:98-101`.
- **Confidence:** High (that it is human-gated and must precede removal). Medium on envctl's exact
  import command surface — not verified in this repo (envctl lives in the meta workspace); the
  verifier should confirm envctl has a vault-import path before this phase is scheduled.

### CLAIM D6.4 — There is a SECOND concrete atomicity-violation risk: `ci.yml` hard-calls `scripts/verify-manifest.py`, which is RETIRE-slated, so retiring the script before deleting the CI job breaks `main` CI.
The default `make verify` gate includes `verify.manifest` + `verify.tools`
(`Makefile:28`), and CI's `manifest-validate` job invokes `python3 scripts/verify-manifest.py`
directly on both manifests. That script, plus `scripts/submodule-*.sh` and the
`submodule-bump.yml` / `manifest-drift.yml` workflows, are exactly the Role-2 machinery slated for
RETIRE. If extraction removes `verify-manifest.py` (or `repos/MANIFEST.yaml`) before the CI job and
Makefile targets that reference it are removed, `main` CI goes red — a self-inflicted block that
also stops auto-merge (per the umbrella's auto-merge gate). **Ordering rule: remove the
*consumers* (ci.yml job, Makefile targets, the two workflows) in the SAME PR that removes the
script/manifest — never the producer first.**
- **Evidence:** CI hard-call at `.github/workflows/ci.yml:34` + `:36`
  (`python3 scripts/verify-manifest.py repos/MANIFEST.yaml` / `tools/MANIFEST.yaml`); default gate
  at `Makefile:28`; RETIRE set at `MIGRATION.md:72-73`; gate-shrink note at
  `.handoff/loop/reports/codemap.md:139`.
- **Confidence:** High.

### CLAIM D6.5 — The `@v1` reusable-workflow tag is fully independent of all extraction and can proceed at any time — it is the only phase with zero cross-dependencies.
The Role-6 reusable workflows are production-shaped (documented inputs, least-priv `permissions:`,
no scaffold markers) and stay in `.github` permanently. Tagging them `@v1` so downstream repos can
pin `uses: FlexNetOS/.github/.github/workflows/reusable-build.yml@v1` touches none of the
MOVE/MIGRATE/DROP content and has no ADR dependency. It also *unblocks the entire point* of the
slim repo (a tagged, consumable CI surface), making it the highest unblock-per-risk action.
- **Evidence:** "production-shaped … only missing the `@v1` moving tag" at
  `.handoff/loop/reports/codemap.md:46` + `:66`; KEEP-set at `MIGRATION.md:45`; tag is the named
  gap in D3 (`.handoff/loop/research-ledger.md:33-37`).
- **Confidence:** High.

### CLAIM D6.6 — Role-2 (submodule machinery) retirement must come AFTER tools/repos/network are stood up as meta peers, because retiring `.gitmodules` + the submodule scripts removes the only thing currently materializing those gitlinks.
Only the 7 `tools/*` gitlinks have `.gitmodules` mappings; `repos/*` (4), `network/slim` (1), and
`data/brain-data/*` (5) are unmapped. Deleting `.gitmodules` and the `submodules.*` machinery
before those repos exist as `.meta.yaml` peers would orphan the content's materialization path.
So the dependency is: **(a) translate `repos/MANIFEST.yaml` + `tools/MANIFEST.yaml` +
`network/MANIFEST.yaml` into `.meta.yaml` peer entries → (b) confirm meta can clone them → (c)
THEN delete `.gitmodules` + retire scripts (co-removing the CI consumers per D6.4).**
- **Evidence:** `.gitmodules` maps only `tools/*` (7 entries via `cat .gitmodules`); three-way
  drift quantified at `.handoff/loop/reports/codemap.md:97-107`; MIGRATE plan at
  `MIGRATION.md:65-73` ("Source for .meta entries" → translate, then retire; DELETE `.gitmodules`).
- **Confidence:** High.

### CLAIM D6.7 — VISION/README 6→2 rewrite must come LAST (after content moved), and runner/wiki/brain/github-app extraction is the gating predecessor work; the rewrite is documentation-of-fact, not a driver.
The KEEP table marks `README.md`/`VISION.md` as "**Rewrite**: 6-role → 2-role (slim)". Rewriting
to claim only roles 1+6 while roles 3/4/5 content still physically lives in `.github` would make
the docs lie about the repo's state. So the rewrite is the *closing* step of the migration, gated
on the four MOVE extractions actually landing.
- **Evidence:** rewrite flagged at `MIGRATION.md:42`; MOVE table (sources still in-repo) at
  `MIGRATION.md:51-63`.
- **Confidence:** High.

### CLAIM D6.8 — Of the five open destination questions (MIGRATION.md:83-89), only #3 (network/ split) and #5 (aspirational-28-vs-17) are sequencing-BLOCKING; #1, #2, #4 are deferrable.
- **#3 network/ split** (→ flexnetos_runner or own peer) **BLOCKS** the runner-extraction phase:
  you cannot atomically move `runner/` + `network/` without first deciding whether `network/`
  goes with the runner or to its own peer (and `network/slim` is also an unmapped gitlink feeding
  D6.6). **Blocking → Phase C.**
- **#5 aspirational-28 vs actual-17** **BLOCKS** the Role-2 peer translation (D6.6): you must
  decide which gitlinks become `.meta.yaml` peers before writing the entries. **Blocking →
  Phase D.**
- **#1 architecture/ destination** (flexnetos_wiki vs keep): deferrable — `architecture/` is a
  scaffold (only ADR-0001 on disk) and can ride with the wiki move or stay; low stakes, low
  coupling.
- **#2 .omc/ destination** (own peer vs fold into oh-my-claudecode): deferrable — `.omc/` is
  regenerable caches; can be dropped/rebuilt, no data-loss risk.
- **#4 SESSIONS.md/USER.TODO.md fate** (archive vs drop): deferrable — these are this repo's own
  working logs; they can stay until the very end (the migration itself needs USER.TODO live).
- **Evidence:** open questions at `MIGRATION.md:83-89`; `architecture/` scaffold-only at
  `.handoff/loop/reports/codemap.md:25`; `.omc/` "regenerable caches" at
  `.handoff/loop/reports/codemap.md:30` + `MIGRATION.md:81`; SESSIONS/USER.TODO are active
  migration tracking files (`TODO.md` header refs them).
- **Confidence:** High on which block; Medium on #1 (depends on whether org-architecture docs are
  treated as wiki content).

### CLAIM D6.9 — The two missing ADRs (0007 secrets→envctl, 0008 runner+app P0) are a real sequencing blocker for the secrets and runner/app phases, but NOT for the tag, role-2, or wiki phases.
ADR-0007 and ADR-0008 are referenced in `.meta.yaml` but are **absent from disk** here (only
ADR-0001 present; the only in-repo references to 0007/0008 are this loop's own files). Their full
rationale lives in the meta workspace KB and could not be located on disk in this session. They
govern exactly the secrets-extraction (D6.3) and runner/app-P0 phases — so those phases must
fetch/confirm the ADRs before executing (the "envctl import path" and "P0 priority" claims rest on
text not present here). The `@v1` tag (D6.5), Role-2 peer translation (D6.6), and wiki move are
ADR-independent and can proceed without resolving this gap.
- **Evidence:** only `ADR-0001-architecture-artifact-homes.md` in `architecture/adr/` (via `ls`);
  0007/0008 referenced at `/home/drdave/Desktop/meta/.meta.yaml:123,126`; absence-flag at
  `.handoff/loop/reports/codemap.md:117` + `:144` and `.handoff/loop/research-ledger.md:65-67`.
  A `find` over `/home/drdave/Desktop/meta/.kb` for ADR 0007/0008 returned nothing — exact KB
  location unconfirmed this session.
- **Confidence:** High (absence on disk; phase-gating). Medium on where the ADRs actually live
  (KB search was empty — verifier should locate them before scheduling the secrets/runner phases).

### CLAIM D6.10 — `reusable-secrets.yml` + `secrets-rotate.yml` fate is an OPEN sub-question that rides with the secrets phase, not an independent blocker.
`reusable-secrets.yml` is a Role-6-shaped template tied to Role-4 secrets, and `secrets-rotate.yml`
operates the vault. With secrets → envctl, these either follow to envctl, stay as generic Role-6
templates, or get dropped. This is undecided but **does not block** earlier phases — it resolves
inside the secrets/envctl phase (Phase C/E), alongside D6.3.
- **Evidence:** open fate flagged at `.handoff/loop/reports/codemap.md:63` + `:83` + `:145`;
  `secrets-rotate.yml` references the secrets machinery (grep hit in `.github/workflows/`).
- **Confidence:** Medium (it is genuinely open; the routing decision is the owner's).

---

## Ordered phase plan (with dependency rationale + which open question gates which phase)

**Phase A — `@v1` reusable-workflow tag (independent; do first).**
Cut the `@v1` release/tag on the Role-6 reusable workflows. No extraction, no ADR dependency,
zero coupling (D6.5). Unblocks downstream consumers immediately. *Gated by: nothing.*

**Phase B — Role-2 peer translation (no removals yet).**
Translate `repos/MANIFEST.yaml` + `tools/MANIFEST.yaml` + `network/MANIFEST.yaml` into `.meta.yaml`
peer entries; confirm `meta` can clone them. Additive only — touch nothing destructive (D6.6).
*Gated by: open-question #5 (aspirational-28 vs actual-17) — must decide the migration set first.*

**Phase C — Runner + github-app extraction (extract-then-remove, atomic PRs).**
Move `runner/` (+ `network/` per the #3 decision) → `flexnetos_runner`; `github-app/` →
`flexnetos_github_app`. Verify peer has content, then remove in the same PR.
*Gated by: open-question #3 (network/ split) and ADR-0008 (P0 priority + scope) — fetch ADR-0008
from meta KB first (D6.9).*

**Phase D — Role-2 machinery retirement (CONSUMERS-FIRST removal).**
After Phase B peers are cloneable: in one atomic PR remove `.gitmodules`, `scripts/submodule-*.sh`,
`verify-manifest.py`, the `manifest-drift.yml` + `submodule-bump.yml` workflows — **and in the SAME
PR** delete the `ci.yml` `manifest-validate` job and the `verify.manifest`/`verify.tools` Makefile
targets so CI never references a removed script (D6.4). *Gated by: Phase B complete.*

**Phase E — Secrets → envctl (human-gated, highest-stakes).**
Owner imports each `secrets/store/**/*.gpg` into envctl's vault (GPG-mediated), verifies envctl
returns each value, then removes `secrets/` atomically. Resolve `reusable-secrets.yml` /
`secrets-rotate.yml` fate here (D6.10). *Gated by: ADR-0007 confirmation (D6.9) + human GPG action
(D6.3) — NEEDS-HUMAN; agent must not auto-delete `secrets/`.*

**Phase F — Wiki + brain extraction.**
`wiki/` (+ `architecture/` per #1) → `flexnetos_wiki`; `data/brain-data/` (76M, 5 nested gitlinks)
+ session logs → `flexnetos_brain`. *Gated by: open-question #1 (architecture/ destination) —
deferrable, low stakes.*

**Phase G — Config-dir extraction (.claude/.codex/.agents/.omc).**
Move config peers; `.omc/` is regenerable (#2). *Gated by: open-question #2 — deferrable.*

**Phase H — VISION/README 6→2 rewrite (LAST).**
Rewrite docs to describe the now-true 2-role repo. *Gated by: Phases C–G landed (D6.7); #4
(SESSIONS/USER.TODO fate) resolves here since the migration logs are no longer needed.*

---

## Recommended next action

Cut the **`@v1` reusable-workflow release tag** (Phase A). It is the single lowest-risk,
highest-unblock move on the board: it is the *only* phase with zero extraction, zero ADR
dependency, and zero coupling to any content that must move (D6.5), so it cannot violate the
extract-then-remove safety invariant or be blocked by the two missing ADRs (D6.9). It also
directly delivers the slim repo's reason-to-exist — a stable, downstream-pinnable CI surface
(`...reusable-build.yml@v1`) — turning the already-production-shaped Role-6 workflows into a
consumable contract while the riskier, human-gated phases (secrets→envctl, runner P0) wait on
ADR-0007/0008 retrieval from the meta KB. Concretely: confirm `RELEASING.md`'s tag process, then
release `v1` against the current green `main`.
