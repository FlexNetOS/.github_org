# `FlexNetOS/.github` (`.github_org`) vs the meta peer-repo target — state & sequencing

**Synthesis pass:** 2026-06-13 · built only from CONFIRMED/QUALIFIED verdicts (`verdicts-D1…D6.md`),
adversarially verified at HEAD `4fefb0e`. Refuted/inconclusive sub-claims excluded (and reported as findings).

---

## 1. Verdict (first)

The refactor is **registry-complete but content-extraction-incomplete**, and the *keep-set is already
production-shaped*. `.github_org` is already a fully registered, independent meta peer — its own remote
(`FlexNetOS/.github.git`), distinct history, gitignored by the parent, a leaf with no nested `.meta.yaml`
(`../.meta.yaml:111-114`, `../.gitignore:77`) — so the structural "become a peer" half of the mission is
**done**. The two enduring roles that justify the magic `.github` name are **real as source, but unproven /
currently failing in operation** (see §2a liveness correction): Role-1 community-health is complete, and
the Role-6 reusable workflows ship real ruff/black/cargo/clippy/uv bodies with typed `workflow_call`
inputs and least-privilege permissions (`reusable-build.yml`, `reusable-lint.yml`, `ci.yml:23`) — but the
`ci.yml` that "dogfoods" them is **RED** (last 5 runs `[FAIL]`), no `@v1` tag exists (`git tag -l` → 0),
and there are **zero downstream consumers and zero releases**. The keep-set gap is therefore larger than a
missing tag: **get CI green → prove one real consumer → then cut `@v1`.** What remains is the *unfinished other half*: extracting roles 3/4/5
+ the submodule machinery out to their declared peers, then retiring the in-tree role-2 apparatus and
rewriting the docs from 6 roles to 2. That remaining work is gated by **live data** (4 real GPG ciphertext
files), **parity** (runner/app already rebuilt fresh in Rust — a remove, not a move), and a **consumers-first
CI coupling** (`ci.yml` hard-calls a retire-slated script). **The recommended single next action is the
`@v1` tag** — the one phase with zero extraction/ADR/content dependency — taken via the release-please flow
on a green `main`, not a manual tag cut.

---

## 2a. Liveness correction (added 2026-06-13, post-review)

Static verification confirmed the workflow **source** is real; it did NOT establish operational liveness.
Empirical check (`gh run list`, `git tag -l`, `gh pr list`) shows the repo is **published and ticking but
not in service and not green**:

| Liveness signal | Evidence | Reading |
|---|---|---|
| Real CI (`ci.yml`) | last 5 runs all `[FAIL]` (`gh run list --workflow=ci.yml`) | **RED** — the "dogfood" is failing |
| Releases / tags | `git tag -l` → 0; `gh release list` → empty | reusable templates **never consumable** |
| Downstream consumers | 0 (no `@v1` to pin) | Role-6's purpose **unrealized** |
| Maintenance | 6 dependabot PRs open, oldest 2026-06-03 (10 days) unmerged | **not actively operated**; auto-merge rule not running here |
| Last code activity on `main` | 2026-05-29 | ~2 weeks idle before this research |
| What *is* green | only `wiki-lint` + `ci-failure-tracker` (scheduled) | peripheral jobs, not the CI surface |

**Consequence for the verdict:** "production-shaped" overstated it. The keep-set is production-shaped *in
source* but **dormant and red in operation**. The next action is not merely "cut `@v1`" — a dormant red
repo cannot merge a release-please PR — it is **(1) make `ci.yml` green, (2) prove one real downstream
consumer, (3) then tag `@v1`.**

---

## 2. Conformance scorecard (vs the meta peer-repo target)

| # | Requirement | Current state (cited) | Status |
|---|---|---|---|
| a | Independent repo + own remote/history | child remote `FlexNetOS/.github.git`; HEADs differ from parent; separate worktree (`verdicts-D2:14`) | **DONE** |
| b | Registered meta peer with `path:` + `tags:` | `github_org:` block `../.meta.yaml:111-114` (`path: .github_org`, `tags: [org, ci]`) | **DONE** |
| c | Gitignored by parent | `../.gitignore:77` `.github_org/` | **DONE** |
| d | No submodules-as-children | FAILS: 7 `.gitmodules` maps (all `tools/*`) + **17 committed gitlinks** (`verdicts-D2:32-33`, `verdicts-D5:8-9`) | **GAP** |
| e | Move-targets extracted to their own peers | Peers all *declared* (`../.meta.yaml:127-138`); `flexnetos_runner`/`flexnetos_github_app` already **populated** (1213 / 2237 files, built fresh per ADR-0008); `flexnetos_wiki`/`flexnetos_brain` still empty; secrets routed to envctl not a peer (`verdicts-D2:38-44`, `verdicts-D4:48-52`) | **PARTIAL** |
| f | Keep-set (roles 1+6) production-ready | Role-1 complete (`verdicts-D1:8-15`); 8 reusables real + typed inputs + least-priv perms + dogfooded (`verdicts-D3:8-24`); only `@v1` tag missing | **DONE bar `@v1`** |
| g | Role-2 machinery retired | Still fully wired: `.gitmodules`, `scripts/submodule-*.sh`, `verify-manifest.py`, `manifest-drift.yml`/`submodule-bump.yml`, Makefile `verify.manifest`/`verify.tools` (`verdicts-D5:15-16`) | **GAP** |
| h | Leaf peer (no nested `.meta.yaml`) | `.github_org/.meta.yaml` absent (`verdicts-D2:22`) | **DONE** |
| i | Docs reflect the 2-role reality | `VISION.md`/`README.md` still describe 6 roles; rewrite is the closing step (`D6-sequencing:104-111`) | **GAP** |

**Tally:** 5 done (a,b,c,f¹,h), 1 partial (e), 3 gap (d,g,i). ¹f done modulo the `@v1` tag.

---

## 3. What's DONE (confirmed)

- **Peer registration — complete.** Independent repo with own remote and history, registered at
  `../.meta.yaml:111-114` with `path:`+`tags:`, gitignored at `../.gitignore:77`, a leaf with no nested
  `.meta.yaml` (`verdicts-D2:14-22`). The structural "match the peer model" requirement is satisfied; the
  residual is content extraction, **not** registration.
- **Role-1 community-health — real.** All seven root files + the `.github/` surface (CODEOWNERS,
  PR/issue templates, dependabot) + `profile/README.md` present and non-trivial (`verdicts-D1:8-15`,
  `verdicts-D3:59-63`).
- **Role-6 reusable CI — real, operational, dogfooded.** 8 `reusable-*.yml` / 1030 lines, **zero scaffold
  markers**, real bodies (`ruff check`+`black --check`, `cargo fmt`+`clippy -D warnings`, `uv build`,
  `cargo build --release`, CodeQL/Trivy/Gitleaks), typed `workflow_call` inputs with descriptions,
  top-level least-priv `permissions:` on every file, and consumed *now* by `ci.yml:23,62`
  (`verdicts-D1:60-86`, `verdicts-D3:8-24`). **`VISION.md:107`'s "Today the workflows are scaffolds" is
  refuted by the source** — only the moving `@v1` tag is absent.
- **The four MOVE-target peers are declared** (`../.meta.yaml:127-138`), and **two are already built
  fresh** in Rust per ADR-0008: `flexnetos_runner` (~1213 files) and `flexnetos_github_app` (~2237 files)
  (`verdicts-D2:41-44`, `verdicts-D4:48-52`). So those two are a **parity-gated remove of the old in-tree
  design-seed dirs**, not a content move.
- **The retire-list is fully enumerated and Makefile-wired**, and the migration intent
  (extract-then-remove atomicity, MIGRATE/RETIRE table) is documented (`verdicts-D5:15-16`,
  `D6-sequencing:16-26`).

---

## 4. What's DRIFTED / mis-stated

- **`VISION.md` over-claims 6 live roles.** Reality at HEAD: 3 real/operational (roles 1, 5, 6), 1
  partial-but-real (role 4 — 4 live GPG blobs), 2 scaffold (role 2 drifted/half-wired, role 3 wiki has
  **0 pages**) (`verdicts-D1:98-106`). The enduring mission is roles **1+6 only**; the doc has not caught up.
- **`VISION.md:107` is factually wrong** — calls the reusables "scaffolds" while they are production-shaped
  and dogfooded (`verdicts-D1:82-86`). **`RELEASING.md:60-66` is the same staleness**: it says "Until the
  reusable workflows ship real bodies (not scaffolds), there is no v1" and lists "fill the bodies" as
  step 1 — bodies are already filled (`verdicts-D3:25-31`).
- **`MIGRATION.md` carries a stale `flexnetos_secrets` peer row** (`MIGRATION.md:55`) that is superseded by
  the RETIRE→envctl decision (`../.meta.yaml:122-126`); treat MIGRATION.md as intent-to-verify, not ground
  truth (`verdicts-D4:27-30`).
- **The submodule drift went silently undetected** — a three-way inconsistency that no detector ever
  caught: **17 committed gitlinks** vs **7 `.gitmodules` maps (all `tools/*`)** vs **28 aspirational
  `repos/MANIFEST.yaml` entries with ZERO path overlap** to the 4 bare `repos/<name>` gitlinks; real
  manifest↔gitlink overlap is **~2 (n8n, slim)**. `git submodule status` **fatally aborts (exit 128)** on
  `data/brain-data/DeepTutor` (`verdicts-D5:8-11`, `verdicts-D1:27-34`). It went undetected because
  `verify-manifest.py` is **schema-only** (never stats the filesystem or reads `.gitmodules`) and
  `manifest-drift.yml` has **no real drift job** — only a `continue-on-error` REPORT_ONLY placeholder
  (`verdicts-D5:13-14`). No working drift detector has ever existed.
- **A stray empty `flexnetos_secrets` repo exists** (bare `.git`, 0 commits) under meta root despite the
  RETIRE→envctl decision — a repo was grounded that the registry says should not exist; flagged for archival
  (`verdicts-D2:30`).

---

## 5. What BLOCKS the refactor (the real blockers)

1. **Live GPG ciphertext = data-loss risk (highest stakes).** `secrets/store/` holds **4 real PGP RSA-4096
   ciphertext files** (`openai/personal.gpg`, `n8n/api-key.gpg`, `n8n/mcp/token.gpg`,
   `github/personal/cli.gpg`), encrypted to a real fingerprint — not scaffold (`verdicts-D4:34-38`,
   `verdicts-D6:11-12`). Secrets are **RETIRED → envctl (ADR-0007)**, so the destination is *not a repo*:
   extraction is a human-gated `secretctl import` vault migration (decrypt with owner's GPG key →
   re-encrypt into envctl → verify → only then remove `secrets/`). The agent must **never** auto-delete
   `secrets/`; a guard hook blocks edits (`scripts/hooks/protect-secrets-store.sh`).
2. **Parity-gated runner/app removal.** `flexnetos_runner`/`flexnetos_github_app` are *already populated*
   with fresh Rust reimplementations (ADR-0008 "productizes" the shell scripts), so the in-tree `runner/`
   and `github-app/` dirs are **design-seeds awaiting a parity-gated remove**, not a move — removal must be
   gated on confirming the Rust peers reach behavioral parity (`verdicts-D4:48-56`, `verdicts-D2:41-44`).
3. **`ci.yml` ↔ `verify-manifest.py` same-PR coupling.** `ci.yml:34,36` *hard-call*
   `python3 scripts/verify-manifest.py` on both manifests (`verdicts-D6:8-9`). Removing the script (or
   either manifest) before the CI job + Makefile targets are removed **reds `main`** — which also kills
   auto-merge. Consumers (ci.yml job, Makefile `verify.manifest`/`verify.tools`, the two workflows) MUST be
   removed in the **same PR** as the script.
4. **Governing ADRs off-disk in this repo.** ADR-0007 (secrets→envctl) and ADR-0008 (runner+app P0) are
   referenced in `../.meta.yaml` but **absent from this repo's `architecture/adr/`** (only ADR-0001
   present). They exist at `handoff/docs/adr-0007-*.md` / `adr-0008-*.md` but must be fetched/confirmed
   before the secrets and runner/app phases execute (`verdicts-D4:93-97`, `verdicts-D6:14-15`).
5. **Brain-data unmapped gitlinks.** `data/brain-data/` has **5 nested gitlinks unmapped in `.gitmodules`**
   (DeepTutor, deepwiki-rs, two obsidian-* under my-wiki-knowledge, obsidian-mind); a subtree/move would
   break, and these are what make `git submodule status` abort (`verdicts-D4:75-84`).
6. **Role-2 peers must precede `.gitmodules` deletion.** Only the 7 `tools/*` gitlinks have `.gitmodules`
   mappings; deleting the machinery before those tools exist as `.meta.yaml` peers orphans their only
   materialization path (`verdicts-D6:29-33`).

---

## 6. Recommended sequencing (ordered phase plan)

> **Single next action — Phase A: cut the `@v1` reusable-workflow tag.** It is the only phase with zero
> extraction, zero ADR, and zero content coupling, and it delivers the slim repo's entire reason to exist:
> a downstream-pinnable CI contract (`…reusable-build.yml@v1`). **Caveat (do not call it "zero dependency"):**
> per `RELEASING.md`, v1 requires **green CI on `main` for ≥1 cycle** and is cut by **merging the
> release-please `chore(main): release` PR** (which tags `v1.0.0`+`v1`), *not* a manual `git tag`. And
> `reusable-secrets.yml` is held out of v1 until the `pass` vault is initialized (`verdicts-D6:20-27`).

| Phase | Work | Gated by |
|---|---|---|
| **A** | `@v1` tag on Role-6 reusables (do first) | green-`main` cycle + release-please flow (not a manual tag); `reusable-secrets.yml` vault-gated |
| **B** | Role-2 peer translation — write `repos/`/`tools/`/`network/` MANIFEST entries into `.meta.yaml`; confirm `meta` can clone. Additive only. | open-question #5 (aspirational-28 vs actual-17 — decide the migration set) |
| **C** | Runner + github-app extraction — parity-gated **remove** of in-tree `runner/`(+`network/`)/`github-app/`, atomic PRs | open-question #3 (network/ split) + ADR-0008 confirmation + Rust-peer parity |
| **D** | Role-2 machinery retirement — **consumers-first, same PR**: delete `.gitmodules`, `submodule-*.sh`, `verify-manifest.py`, the two workflows **and** the `ci.yml manifest-validate` job + `verify.manifest`/`verify.tools` Makefile targets | Phase B peers cloneable (blocker #3, #6) |
| **E** | Secrets → envctl — **human-gated**: owner `secretctl import` each `.gpg` → verify → only then remove `secrets/`; resolve `reusable-secrets.yml`/`secrets-rotate.yml` fate | ADR-0007 confirmation + human GPG action (blocker #1, #4); NEEDS-HUMAN |
| **F** | Wiki + brain extraction — `wiki/`(+`architecture/` per #1) → `flexnetos_wiki`; `data/brain-data/` (5 nested gitlinks) → `flexnetos_brain` | open-question #1 (architecture/ destination); blocker #5 (unmapped gitlinks) |
| **G** | Config-dir extraction (`.claude`/`.codex`/`.agents`/`.omc`) — `.omc/` regenerable | open-question #2 (.omc destination) — deferrable |
| **H** | VISION/README 6→2 rewrite (**last**) — documentation-of-fact after content lands | Phases C–G landed; open-question #4 (SESSIONS/USER.TODO fate) resolves here |

`make verify` shrinks by exactly `verify.manifest`+`verify.tools`+`verify.tool-assets` once Phase D lands;
the enduring gate is `actionlint`+`markdown`+`hermetic` (`verdicts-D5:16`).

---

## 7. Confidence + named gaps

**Overall confidence: HIGH.** Every load-bearing fact survived adversarial refutation with on-disk
evidence — peer registration (live `git remote`/`rev-parse`), Role-6 reality (read the YAML bytes,
`grep` for markers returned clean), the 4 GPG blobs (`file`/`xxd` dispositive), the 17/7/28 drift counts
(re-run live), the `ci.yml` hard-call, and the empty `git tag -l`. Across 6 dimensions: ~40 claims
CONFIRMED, ~6 QUALIFIED, **0 refuted that change the verdict** (the only refutations — "destinations all
empty" and "4 manifest repos gitlinked" — *strengthen* the conclusion).

**Named gaps (what a deeper pass should target):**
- **ADRs not in this repo's `architecture/adr/`.** ADR-0007/0008 read from `handoff/docs/`, not the repo's
  own ADR home — their authority for phase-gating is real but the in-repo traceability gap stands; confirm
  before scheduling Phases C/E.
- **No remote-tag read performed** beyond `git ls-remote --tags origin` (empty). The `@v1` absence is proven
  for this working tree + that remote query; a fuller GitHub-side check was not done.
- **The aspirational-28-vs-actual-17 decision is the owner's call**, not a code-fact — which gitlinks
  become peers vs which are discarded (ruvector/weftos are manifest rows with no gitlink = delete-a-row)
  is a judgement that gates Phase B.
- **network/ split is undecided** (own peer vs ride with `flexnetos_runner`) — gates Phase C.
- **architecture/ + .omc destinations undecided** — gate Phases F/G; low stakes (scaffold / regenerable).
- **envctl's vault-import command surface is out-of-repo / unverified** — confirm envctl has a working
  `secretctl import` path before scheduling Phase E.
- **Stray empty `flexnetos_secrets` repo** needs an explicit archival decision (NEEDS-HUMAN).

**Recommendation (flagged as recommendation, not fact):** Run the refactor in the phase order above, lead
with `@v1` now (it is safe, unblocking, and proves the slim-repo contract), and **do not let an agent
touch Phases C/E autonomously** — both are gated on human/parity decisions where a wrong move is
irreversible (data-loss on secrets, parity-loss on runner/app). Treat `MIGRATION.md` and `VISION.md` as
**stale until Phase H** and rely on `../.meta.yaml` comments + the on-disk ADRs where they conflict.
