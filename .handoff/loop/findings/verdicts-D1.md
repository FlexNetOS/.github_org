# Verdicts — D1 (current-state inventory & role realization)

**Verifier pass:** 2026-06-13 · adversarial, fail-closed · target read-only at HEAD (`4fefb0e`).
**Method:** opened each cited artifact, re-ran the cited counts, attacked the maturity verdicts (esp. Role-6 REAL vs `VISION.md:107` "scaffolds"). Reasoning from bytes on disk.

---

## CLAIM D1.1 — Role 1 community-health is REAL — **CONFIRMED**

Re-ran the file census. All seven root files present with the exact sizes claimed:
`CODE_OF_CONDUCT.md` 28 ln/1073 B, `CONTRIBUTING.md` 120 ln/5701 B, `SECURITY.md` 89 ln/3690 B,
`SUPPORT.md` 41 ln, `FUNDING.yml` 21 ln, `MAINTAINERS.md` 36 ln, `LICENSE` 21 ln. The `.github/`
surface (`CODEOWNERS`, `PULL_REQUEST_TEMPLATE.md`, `dependabot.yml`, four `ISSUE_TEMPLATE/*`) and
`profile/README.md` (2297 B) all present and non-trivial. Could not refute: these are content files,
presence+size is the operational test, GitHub renders by name. **CONFIRMED.**

## CLAIM D1.2 — Role 2 submodule mount is three-way-drifted, half-wired — **CONFIRMED (verdict); QUALIFIED (one sub-count)**

Role verdict holds and is, if anything, understated:
- 17 committed gitlinks in HEAD — exact match (`git ls-tree -r HEAD | awk '$2=="commit"'`).
- `.gitmodules` maps exactly **7**, all `tools/*` — confirmed. The other 10 gitlinks have no
  `.gitmodules` entry. Confirmed.
- MANIFEST: `repo:` keys = 0 (confirmed); the entry-count claim said "29 name:/url:-style lines" —
  actual is **30 `url:` lines, 0 `name:` lines** (`grep -cE 'url:'` → 30). Off by one and the
  field is `url:` not `name:`; immaterial to the thesis.

**QUALIFIED sub-detail (drift is WORSE than stated):** D1.2/D1.7 assert "only 4 of [~28 manifest
repos] (ai-top-utility, fabro, n8n, paperclip) are actually committed gitlinks." Counter-evidence:
grepping MANIFEST.yaml, only **n8n** (`repos/MANIFEST.yaml:75`) and **slim** (`:258`) of the
committed gitlinks actually appear in the manifest. `ai-top-utility`, `fabro`, `paperclip` are
**absent** from MANIFEST (only a commented `# - ai-top/` note at `:283`). So the manifest↔gitlink
overlap is ~2, not 4 — the three-way inconsistency the claim describes is real and slightly larger
than written. Role verdict **CONFIRMED**; the "4 manifest repos gitlinked" enumeration is
**REFUTED** in favor of "~2", which strengthens (does not weaken) the drift conclusion.

## CLAIM D1.3 — Role 3 wiki is SCAFFOLD (zero pages) — **CONFIRMED**

`find wiki/pages -type f ! -name '.gitkeep'` → **0 files** (re-run, confirmed). Governance/schema
docs (`purpose.md`, `schema.md`, `index.md`, `AGENTS.md`, `README.md`) are real; the knowledge tree
is empty. Frame-real, memory-empty. Could not refute. **CONFIRMED.**

## CLAIM D1.4 — Role 4 secrets vault is PARTIAL→REAL (4 live PGP blobs) — **CONFIRMED**

`file` on all four blobs returns `PGP RSA encrypted session key - keyid: 5B50D66F E264FD21 RSA
(Encrypt or Sign) 4096b` — `secrets/store/{openai/personal,github/personal/cli,n8n/api-key,
n8n/mcp/token}.gpg`. These are genuine 4096-bit PGP ciphertexts, not `.example`/templates. The
codemap's flat "scaffold" label is under-stated, as the claim asserts. Could not refute the
encrypted-blob reality (`file` is dispositive). The "fully operational / non-stale plaintext"
sub-point stays **QUALIFIED** (cannot decrypt without the private key — already correctly
hedged to medium confidence in the claim). Role verdict **CONFIRMED.**

## CLAIM D1.5 — Role 5 runner host config is REAL — **CONFIRMED**

424 lines of bash across `install.sh` (104), `register.sh` (139), `ephemeral-spawn.sh` (73),
`remove.sh` (108) — exact match. `install.sh` is real, dry-run-default-safe logic, not an echo
stub: `DRY_RUN="${DRY_RUN:-1}"` (`runner/install.sh:14`), mutation refused without `CONFIRM=1`
(`:55-57`), `--execute` flips `DRY_RUN=0` (`:36`). Policies + systemd units present as claimed.
Could not refute. **CONFIRMED.**

## CLAIM D1.6 — Role 6 reusable-CI is REAL/operational + DOGFOODED; `VISION.md:107` is stale — **CONFIRMED** (priority claim)

This is the verdict-changing claim and it survives a direct refutation attempt:
- **8 files / 1030 lines** — exact match.
- **Zero scaffold markers**: `grep -nEi 'TODO|FIXME|scaffold|placeholder|stub|not implemented'`
  across all `reusable-*.yml` → 0 hits (re-run, exit 1). A second targeted grep for
  `echo "(TODO|stub|placeholder|not implemented)"` → 0 hits. No echo-stub jobs.
- **Real job logic** (opened the files, read the bytes):
  - `reusable-lint.yml`: `ruff check` + `black --check` (`:162-163`), `cargo fmt --all --check` +
    `cargo clippy --all-targets --all-features` with `-D warnings` gated on `fail-on-warning`
    (`:169-174`), `bun run lint`/`npm run lint` guarded by `jq -e '.scripts.lint'` (`:139-154`),
    real toolchain setup steps conditional on language+lockfile hashFiles (`:52-81`).
  - `reusable-build.yml`: `cargo build --release --all-features` (debug/release branch `:117-121`),
    `uv build` (`:109`), `npm ci && npm run build` guarded by jq (`:92-101`),
    `actions/upload-artifact@v4` (`:124-127`).
- **Typed `workflow_call` inputs + least-priv permissions**: `reusable-build.yml:11-35` (typed
  inputs w/ descriptions) + `permissions: contents: read` (`:37-38`); `reusable-lint.yml:15-34` +
  `permissions: contents: read` (`:36-37`). Matches the `VISION.md:89-95` contract.
- **Dogfooded NOW**: `.github/workflows/ci.yml:23` `uses: ./.github/workflows/reusable-lint.yml`,
  `ci.yml:62` `uses: ./.github/workflows/reusable-security.yml` — exact line matches, confirmed.
- **Kernel of truth in VISION:107**: `git tag -l` → **0 tags** (confirmed). No `@v1` to pin.

**`VISION.md:107` "Today the workflows are scaffolds" is REFUTED by the source** — the YAML is
production-shaped, marker-free, and in active use; only the moving release tag is absent. The claim
correctly localizes "scaffold" to the missing tag, not the workflow logic. **CONFIRMED.** (Minor:
the claim's line cites were ~2 lines off in places, e.g. ruff/black at `:162-163` not `:160-163`;
immaterial — the code is exactly as described.)

## CLAIM D1.7 — Cross-role DRIFT summary — **CONFIRMED** (with the D1.2 sub-count QUALIFIED as above)

Each delta traces to a confirmed D1.x claim: Role-6 doc-behind-code (confirmed via D1.6), Role-4
codemap-behind-code (confirmed via D1.4), Role-2 under-built (confirmed, drift larger than stated),
Role-3 frame-only (confirmed via D1.3), Roles 1 & 5 match (confirmed). The one correction: the
"4 manifest repos gitlinked" figure in the Role-2 bullet should read ~2 (n8n, slim) — does not
change the "half-wired / three-way drift" conclusion.

---

## Current-state verdict (D1) — **CONFIRMED**

The dimension's bottom line survives adversarial verification: 3 real/operational (Roles 1, 5, 6),
1 partial-but-real (Role 4), 2 scaffold/drifted (Roles 2, 3). The headline correction —
**`VISION.md:107` is factually wrong at HEAD; the reusable workflows are real and dogfooded, only
the `@v1` tag is missing** — is CONFIRMED from the YAML, the in-repo `uses:` callers, and
`git tag -l`. The secondary correction (secrets vault more real than codemap's "scaffold") is
CONFIRMED via dispositive `file` output. Only one sub-detail was refuted (Role-2's "4 manifest
repos gitlinked" → ~2), and it strengthens rather than weakens the verdict.

**Flow to synthesis:** all six role verdicts + the two corrections (CONFIRMED). The D1.7 Role-2
bullet's "4" should be rendered as "~2 (n8n, slim)" in the report.
