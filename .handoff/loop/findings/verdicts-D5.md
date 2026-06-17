# Verdicts — D5 (submodule-drift), adversarial verification

Verifier run: 2026-06-13. Target (read-only): `/home/drdave/Desktop/meta/.github_org`.
Method: re-ran each claim's cited command live, attempted refutation per claim. Default-skeptical.

| Claim | Verdict | Notes |
| --- | --- | --- |
| D5.1 — 17 committed gitlinks | **CONFIRMED** | `git ls-tree -r HEAD \| grep -c ^160000` → 17. Full inventory matches (7 tools, 4 bare repos/, network/slim, 5 data/brain-data/). |
| D5.2 — 7 `.gitmodules` maps, all tools/* | **CONFIRMED** | `grep -c '^\[submodule'` → 7; all `[submodule "tools/…"]`. No repos/, network, data block. |
| D5.3 — `submodule status` FATALLY ABORTS exit 128 (not "returns empty") | **CONFIRMED** | Reproduced: `fatal: no submodule mapping found in .gitmodules for path 'data/brain-data/DeepTutor'`, `exit=128`. This **corrects** the codemap/MIGRATION "returns empty/errors" framing — it is a hard abort. |
| D5.4 — 28 manifest repos/ entries, ZERO path overlap with 4 real repos/ gitlinks | **CONFIRMED** | `grep -c 'path: repos/'` → 28; all under owned/forked/external. `comm -12` (repos/ gitlinks ∩ repos/MANIFEST repos/ paths) = empty. Manifest n8n = `repos/forked/n8n` (line 74) vs committed `repos/n8n` — different path. |
| D5.5 — Only overlap is 7 tools/* + network/slim (=8 migration-ready) | **CONFIRMED (qualified wording)** | `comm -12` against `repos/MANIFEST.yaml` ALONE yields only `network/slim`. The 7 tools/* live in `tools/MANIFEST.yaml` + `.gitmodules`, not repos/MANIFEST. The claim's own evidence says "all manifest paths" / "tools also have `.gitmodules`" — comm across the UNION (repos+tools+network) yields exactly the 8. Claim is correct **as written** (union of all manifests); a reader scanning only repos/MANIFEST would see 1, not 8. |
| D5.6 — `verify-manifest.py` schema-only, never stats FS / reads `.gitmodules` / git | **CONFIRMED** | Read `validate()` (lines 125-168): checks REQUIRED=(path,url,branch) presence, duplicate paths, list-type groups/toolchain, non-GitHub-URL warning. No `.exists()`/`isdir`/`.gitmodules`/`ls-tree`/`subprocess`. The lone `Path` import (line 18) is used only to open the manifest arg (lines 55,125,172), never to stat a gitlink. |
| D5.7 — `manifest-drift.yml` has no real drift job (placeholder + community-health only) | **CONFIRMED** | Jobs: claude-dir-check, claude-settings-doctor, check-user-todo-step5 (informational), open-questions-lint, submodules-materialize-noop (`continue-on-error`, "REPORT_ONLY placeholder" that only echoes a deferred note). `grep -i 'ls-tree\|gitmodules\|submodule status\|160000'` finds no real comparison logic. |
| D5.8 — every retire-list item exists on disk + Makefile-wired | **CONFIRMED** | All 12 spot-checked paths EXIST (3 submodule-*.sh, verify-manifest.py, manifest-query.py, reconcile-stray-clones.sh, clone-and-pack.sh, toolchain.py, gitmodules-drift-guard.sh, submodule-bump.yml, reusable-submodule-bump.yml, .gitmodules). Makefile wiring confirmed at lines 36, 44, 48, 62, 69, 74/76, 89. |
| D5.9 — retiring Role-2 shrinks `make verify` by exactly tool-assets+manifest+tools | **CONFIRMED (structural)** | `Makefile:28` verify = tool-assets actionlint markdown manifest tools hermetic. The 3 removed all call verify-manifest.py / toolchain.py; remaining enduring gate = actionlint+markdown+hermetic. (Medium-confidence meta-covers-manifest-query claim left as the analyst rated it — not independently disproven, not a hard fact.) |
| D5.10 — migration partition (12 peers / 5 brain / 2 discard) | **CONFIRMED (data)** | ruvector (repos/MANIFEST:24, owned/ruvector) + weftos (forked/weftos) are manifest rows with no committed gitlink — "discard = delete a row." Inventory + n8n-path-mismatch consistent. Partition arithmetic (7+4+1=12) holds. |
| D5.11 — open-question framing "migrate 12 / backlog the rest", not "28 vs 17" | **CONFIRMED (data); recommendation = owner's call** | The zero-overlap fact (D5.4) is verified, so "17 ⊄ 28" is sound. The recommendation itself is a judgement, not a code-fact — correctly flagged Medium by the analyst. |

## Minor numeric correction (does not change any verdict)

- D5.4 evidence text says manifest has **"29 `url:` lines"**. Live `grep -c 'url:' repos/MANIFEST.yaml` → **30** (one is the header comment line 6 `#     url:           clone URL`; the rest are 29 real entry URLs — but the raw `url:` count is 30, not 29). Cosmetic; the 28-entry path count (the load-bearing number) is exact. Flag for cleanup, not a refutation.

## Net

10 of 11 claims CONFIRMED outright; D5.5 CONFIRMED but with a wording caveat (overlap is across the UNION of all three MANIFEST files, not repos/MANIFEST alone). No claim REFUTED. The codemap-correcting claim (D5.3: hard abort exit 128, not "returns empty") is independently reproduced and stands. Only CONFIRMED/QUALIFIED claims flow to synthesis; nothing here is INCONCLUSIVE.
