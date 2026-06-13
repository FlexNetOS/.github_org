# D5 — Role-2 submodule→meta-peer migration & manifest drift

Target: `/home/drdave/Desktop/meta/.github_org` (FlexNetOS/.github). All evidence is read-only
ground truth from `git ls-tree -r HEAD`, the on-disk files, and the parent `.meta.yaml`.

---

### CLAIM D5.1 — There are exactly 17 committed gitlinks (mode 160000), confirming the codemap count.
`git ls-tree -r HEAD | grep -c ^160000` → **17**. Inventory (paths):
- `tools/` (7): actionlint, bun, cpython, gitleaks, node, trivy, uv
- `repos/` (4): ai-top-utility, fabro, n8n, paperclip — **at `repos/` ROOT, not under owned/forked/external**
- `network/slim` (1)
- `data/brain-data/` (5): DeepTutor, deepwiki-rs, obsidian-mind, my-wiki-knowledge/.claude/obsidian-second-brain, my-wiki-knowledge/.claude/obsidian-skills

**Evidence:** `git ls-tree -r HEAD | grep ^160000` (17 lines, full output captured). Codemap §4
(`codemap.md:97-102`) said "17" and is correct on the count.
**Confidence:** High.

### CLAIM D5.2 — `.gitmodules` maps exactly 7 paths, ALL under `tools/`. The other 10 gitlinks are unmapped.
`grep -c '^\[submodule' .gitmodules` → **7**: tools/cpython, tools/actionlint, tools/gitleaks,
tools/trivy, tools/node, tools/bun, tools/uv. No `repos/*`, no `network/slim`, no `data/brain-data/*`
block exists.
**Evidence:** full `.gitmodules` read (7 `[submodule "tools/…"]` blocks, nothing else).
**Confidence:** High.

### CLAIM D5.3 — `git submodule status` does NOT "return empty" — it FATALLY ABORTS (exit 128) on the first unmapped gitlink.
The codemap (`codemap.md:103`) and MIGRATION.md (`MIGRATION.md:30`) both say it "returns empty /
errors". Precise correction: it errors **hard** and prints nothing useful.
**Evidence:** `git submodule status` → `fatal: no submodule mapping found in .gitmodules for path
'data/brain-data/DeepTutor'`, exit code **128**. Git walks gitlinks alphabetically;
`data/brain-data/DeepTutor` is the first gitlink with no `.gitmodules` entry, so git aborts there and
never reaches the 7 tools/ entries that *are* mapped. The mechanism: a gitlink (tree entry mode
160000) is a committed commit-pointer that exists independent of `.gitmodules`; `.gitmodules` is just
the URL/branch map. You can commit a gitlink with no `.gitmodules` entry (e.g. via `git read-tree`/
`git update-index --cacheinfo`, or by committing a nested repo dir), and `git submodule` then can't
resolve it. That is exactly this repo's state for 10 of 17 gitlinks.
**Confidence:** High (reproduced live).

### CLAIM D5.4 — `repos/MANIFEST.yaml` lists ~28 entries (29 `url:` lines) and NONE of them match a committed gitlink path. The manifest is fully aspirational vs the 4 real `repos/` gitlinks.
This is a sharper correction than the codemap/MIGRATION framing. The codemap (`codemap.md:99`) and
MIGRATION (`MIGRATION.md:26`) imply the 4 real `repos/` gitlinks are a *subset* that differs from the
manifest list. Reality: there is **zero path overlap**. The manifest uses
`repos/owned/…`, `repos/forked/…`, `repos/external/…`; the 4 committed gitlinks are bare
`repos/ai-top-utility`, `repos/fabro`, `repos/n8n`, `repos/paperclip`. The manifest even has a
`repos/forked/n8n` entry, but the committed gitlink is `repos/n8n` — a different path. So the four
on-disk `repos/` submodules are **completely unrepresented** in the manifest, and **28 manifest
entries are unrepresented on disk**.
**Evidence:** `grep 'path: repos/' repos/MANIFEST.yaml` → 28 entries all under owned/forked/external;
`git ls-tree … | grep repos/` → 4 entries all at `repos/` root. `comm -12` of (committed gitlink paths)
∩ (all manifest paths) yields ONLY the 7 `tools/*` + `network/slim` = 8; the 4 `repos/*` and 5
`data/*` gitlinks are in the "no manifest path" set. `repos/MANIFEST.yaml:24-251`.
**Confidence:** High.

### CLAIM D5.5 — The only place the manifest and reality agree is `tools/*` (7) + `network/slim` (1). Those 8 are the migration-ready core.
`comm -12 gitlinks manifest_paths` → `network/slim`, `tools/{actionlint,bun,cpython,gitleaks,node,
trivy,uv}`. These 8 paths appear as both a committed gitlink AND a manifest/`.gitmodules` entry
(tools also have `.gitmodules`; network/slim is in `repos/MANIFEST.yaml:257` + `network/MANIFEST.yaml`
but NOT in `.gitmodules`).
**Evidence:** `comm -12` output; `repos/MANIFEST.yaml:257`, `network/MANIFEST.yaml:5`.
**Confidence:** High.

### CLAIM D5.6 — The three-way "drift" is real but the verify gate is BLIND to it: `verify-manifest.py` is a pure schema validator, never checks gitlink existence.
`make verify.manifest` / `make verify.tools` run `scripts/verify-manifest.py` which only checks: each
entry has `path`/`url`/`branch` (REQUIRED), paths are unique, `groups`/`toolchain` are lists, and
warns on non-GitHub URLs. It **never** stats the filesystem, never reads `.gitmodules`, never compares
to `git ls-tree`. So a manifest with 28 entries that match zero on-disk gitlinks prints
`OK: N manifest entries parse` and CI stays green.
**Evidence:** `scripts/verify-manifest.py:125-168` (REQUIRED tuple line 20; the validate loop does
schema-only checks; no `Path.exists`, no git call). `Makefile:43-48`.
**Implication:** the drift is invisible to local/CI gates → it has accumulated silently. This is *why*
the numbers diverged with nobody noticing.
**Confidence:** High.

### CLAIM D5.7 — The `manifest-drift.yml` workflow does NOT actually guard manifest/gitlink drift; its real jobs are community-health checks, and the only manifest-related job is a deferred no-op placeholder.
Despite the name, `manifest-drift.yml`'s jobs are: `claude-dir-check` (no PascalCase Claude/),
settings.json hygiene, USER.TODO#5 tag listing (informational), open-questions schema, and a
"MANIFEST/.gitmodules lockfile (deferred)" job that is a `continue-on-error` **placeholder that only
prints a note** (the materialize/lockfile pattern is deferred per G4/G5). So real drift-detection
between manifest↔gitmodules↔gitlinks **does not exist anywhere** — neither the verify gate nor CI
catches it.
**Evidence:** `.github/workflows/manifest-drift.yml:18-96` (jobs: claude-dir-check:18,
settings hygiene:38, USER.TODO#5:56, open-questions:72, lockfile-deferred:91 "REPORT_ONLY placeholder").
**Confidence:** High.

### CLAIM D5.8 — Every item on the retire-list physically exists on disk and is wired into the Makefile, so retirement is a real (not phantom) cleanup.
Retire-list machinery confirmed present:
- Scripts (3 submodule + helpers): `scripts/submodule-add-all.sh`, `submodule-bump.sh`,
  `submodule-sync-upstream.sh`, plus `verify-manifest.py`, `manifest-query.py`,
  `reconcile-stray-clones.sh`, `clone-and-pack.sh`, `toolchain.py`,
  `scripts/hooks/gitmodules-drift-guard.sh` — all EXIST.
- Workflows: `.github/workflows/{submodule-bump,manifest-drift,reusable-submodule-bump}.yml` — all EXIST.
- Makefile wiring: `toolchain.py validate` (`Makefile:36`), `submodule-add-all.sh` (`:62`),
  `submodule-bump.sh` (`:69`), `submodule-sync-upstream.sh` (`:74,:76`), `clone-and-pack.sh` (`:89`),
  `verify-manifest.py` (`:44,:48`).
**Evidence:** `ls scripts/submodule-*.sh` (3 files); existence loop over retire-list (all EXISTS);
`grep` of Makefile (line refs above).
**Confidence:** High.

### CLAIM D5.9 — When the submodule machinery retires, `make verify` shrinks: `verify.manifest` + `verify.tools` + `verify.tool-assets` go away, and meta replaces the catalog function — but NO real drift guard is lost (there wasn't one).
`make verify` (`Makefile:28`) = `verify.tool-assets verify.actionlint verify.markdown verify.manifest
verify.tools verify.hermetic`. Removing Role-2 deletes `verify.manifest`, `verify.tools` (both call
`verify-manifest.py`) and `verify.tool-assets` (`toolchain.py validate`, `Makefile:35-36`). What
remains is the genuinely-enduring gate: `verify.actionlint`, `verify.markdown`, `verify.hermetic`.
**What breaks / needs replacement:** the *catalog of repos* (today `repos/MANIFEST.yaml` +
`tools/MANIFEST.yaml` + `network/MANIFEST.yaml`) is replaced by **parent `.meta.yaml`** as the single
registry; `meta git update` / `meta project list` / `meta exec` replace `submodule-add-all.sh` /
`submodule-bump.sh` / `submodule-sync-upstream.sh`; `meta git snapshot` etc. replace the bespoke
helpers. Crucially, **no drift detector is lost** because (per D5.6/D5.7) none existed — meta's model
removes the *possibility* of three-way drift since there is one source of truth (`.meta.yaml`) and no
parallel `.gitmodules`/MANIFEST to drift against.
**Evidence:** `Makefile:28,35-36,43-48`; parent `.meta.yaml:111-113` (github_org peer) and the meta
verbs documented in the meta CLAUDE.md.
**Confidence:** High (for what's deleted/kept); Medium (that meta fully covers `manifest-query.py`'s
group-query use — meta has `--tag`/`--include` filters which map to the manifest `groups:`, but a
1:1 audit of `manifest-query.py` consumers wasn't done here).

### CLAIM D5.10 — The migration partition: 8 gitlinks become meta peers, the 5 `data/brain-data/*` move with flexnetos_brain, and ruvector/weftos are MANIFEST-only entries that are simply dropped (they were never committed gitlinks).
- **→ meta peers** (`.meta.yaml` with `tags:` mirroring manifest `groups:`): the 7 `tools/*` + the 4
  real `repos/*` (ai-top-utility, fabro, n8n, paperclip) + `network/slim` (slim path) =
  **12 real gitlinks**. (MIGRATION.md:69 says "tools/* (7), repos/* real (4), network/slim" = 12 —
  consistent.)
- **→ move with flexnetos_brain** (not `.github` peers): the 5 `data/brain-data/*` nested gitlinks
  (`MIGRATION.md:58`).
- **Discarded**: `ruvector` + `weftos` (`MIGRATION.md:32`) — but note these are **manifest entries
  that were never committed as gitlinks** (`repos/owned/ruvector`, `repos/forked/weftos` appear in
  `repos/MANIFEST.yaml:24,101` but not in `git ls-tree`). So "discard" = delete a manifest row, not
  remove a submodule.
**Evidence:** `MIGRATION.md:58,69; :32`; `repos/MANIFEST.yaml:24,101`; D5.1 inventory.
**Confidence:** High.

### CLAIM D5.11 — The open decision (MIGRATION.md open-question 5) is NOT "28 vs 17" — the honest choice is "migrate the 12 real gitlinks now" vs "treat the 28-entry aspirational manifest as a backlog of repos to clone+fork+register later."
Framing the decision as "aspirational ~28 vs actually-present 17" (`MIGRATION.md:89`) conflates two
sets that barely overlap (D5.4). The 17 gitlinks ≠ a subset of the 28 manifest entries. Concretely:
- 12 of the 17 gitlinks are migration-ready peers NOW (have a real committed pointer).
- The 28 manifest entries are mostly *future-intent* repos (15 of them tagged
  `depends-on: USER.TODO#5` / "PENDING FORK", `repos/MANIFEST.yaml:115,127,138,148`), several of which
  have no on-disk presence at all.
So the real decision is: **(a)** migrate only the 12 grounded gitlinks to `.meta.yaml` peers and
**(b)** convert the aspirational manifest into a tracked backlog (USER.TODO / a `tasks/` doc) rather
than `.meta.yaml` entries, since meta peers should point at repos that exist. Recommended verdict
below.
**Evidence:** `MIGRATION.md:89`; `repos/MANIFEST.yaml:110-153` (PENDING FORK block, depends-on USER.TODO#5).
**Confidence:** High (the data); the recommendation is Medium (a judgement the owner ratifies).

---

## Gitlink inventory table

| Gitlink path | `.gitmodules` entry? | In a MANIFEST? | Migration fate |
| --- | --- | --- | --- |
| `tools/actionlint` | ✅ yes | ✅ tools/MANIFEST | → meta peer |
| `tools/bun` | ✅ yes | ✅ tools/MANIFEST | → meta peer |
| `tools/cpython` | ✅ yes | ✅ tools/MANIFEST | → meta peer |
| `tools/gitleaks` | ✅ yes | ✅ tools/MANIFEST | → meta peer |
| `tools/node` | ✅ yes | ✅ tools/MANIFEST | → meta peer |
| `tools/trivy` | ✅ yes | ✅ tools/MANIFEST | → meta peer |
| `tools/uv` | ✅ yes | ✅ tools/MANIFEST | → meta peer |
| `network/slim` | ❌ no | ✅ repos/ + network/MANIFEST | → meta peer (slim) |
| `repos/ai-top-utility` | ❌ no | ❌ no (manifest has none of these) | → meta peer |
| `repos/fabro` | ❌ no | ❌ no | → meta peer |
| `repos/n8n` | ❌ no | ❌ no (manifest's n8n is `repos/forked/n8n`, diff path) | → meta peer |
| `repos/paperclip` | ❌ no | ❌ no | → meta peer |
| `data/brain-data/DeepTutor` | ❌ no (aborts `submodule status`) | ❌ no | → move w/ flexnetos_brain |
| `data/brain-data/deepwiki-rs` | ❌ no | ❌ no | → move w/ flexnetos_brain |
| `data/brain-data/obsidian-mind` | ❌ no | ❌ no | → move w/ flexnetos_brain |
| `data/brain-data/my-wiki-knowledge/.claude/obsidian-second-brain` | ❌ no | ❌ no | → move w/ flexnetos_brain |
| `data/brain-data/my-wiki-knowledge/.claude/obsidian-skills` | ❌ no | ❌ no | → move w/ flexnetos_brain |
| *(manifest-only)* `repos/owned/ruvector` | n/a | ✅ repos/MANIFEST:24 (no gitlink) | DISCARD (delete row) |
| *(manifest-only)* `repos/forked/weftos` | n/a | ✅ repos/MANIFEST:101 (no gitlink) | DISCARD (delete row) |
| *(manifest-only)* ~24 other entries | n/a | ✅ repos/MANIFEST (no gitlink) | → backlog, not peers (mostly PENDING FORK) |

---

## Drift resolution + retire-list verdict

The "three-way drift" is **17 committed gitlinks vs 7 `.gitmodules` maps vs ~28 aspirational MANIFEST
entries**, and the codemap's headline numbers are correct — but the framing under-states the damage:
the 28-entry manifest and the 4 real `repos/` gitlinks have **zero path overlap** (manifest uses
`owned/forked/external/` prefixes; the committed submodules are bare `repos/<name>`), so the manifest
is purely aspirational and `git submodule status` doesn't merely return empty — it **fatally aborts
(exit 128)** on the first of 10 unmapped gitlinks (`data/brain-data/DeepTutor`). This drift went
unnoticed because the only "guard," `verify-manifest.py`, is a schema-only validator that never checks
gitlink existence, and `manifest-drift.yml` despite its name carries no real manifest↔gitmodules drift
job (only a deferred placeholder + community-health checks). **Resolution = retire the whole Role-2
machinery and let parent `.meta.yaml` be the single registry**: migrate the 12 grounded gitlinks
(7 `tools/*` + 4 bare `repos/*` + `network/slim`) to `.meta.yaml` peers with `tags:` mirroring the
manifest `groups:`; move the 5 `data/brain-data/*` nested gitlinks out with `flexnetos_brain`; drop
`ruvector`/`weftos` and the other ~22 manifest-only rows (which are mostly `PENDING FORK`/USER.TODO#5
intents) into a tracked **backlog**, not into `.meta.yaml` (meta peers must point at repos that exist).
**Retire-list verdict (all confirmed present + Makefile-wired, safe to delete):** the 3
`scripts/submodule-*.sh`, `verify-manifest.py`, `manifest-query.py`, `reconcile-stray-clones.sh`,
`clone-and-pack.sh`, `toolchain.py`, `scripts/hooks/gitmodules-drift-guard.sh`, the
`submodule-bump.yml` / `manifest-drift.yml`(manifest parts) / `reusable-submodule-bump.yml` workflows,
and `.gitmodules` itself. The `make verify` gate shrinks by exactly `verify.manifest` +
`verify.tools` + `verify.tool-assets`, leaving the enduring `verify.actionlint` + `verify.markdown` +
`verify.hermetic`; **nothing real is lost** because no working drift detector ever existed — meta's
single-source-of-truth model removes the *possibility* of this drift rather than re-guarding it. On
open-question 5: the answer is **neither "28" nor "17" wholesale — migrate the 12 real gitlinks, brain
the 5, discard 2, backlog the rest.**
