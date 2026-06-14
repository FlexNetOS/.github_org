# Verdicts — D6 (Migration sequencing & risk)

**Verifier pass — 2026-06-13.** Adversarial verification of `.handoff/loop/findings/D6-sequencing.md`.
Each material claim was attacked against the actual repo state. Default-skeptical, fail-closed.

## Priority-claim verdicts

### D6.4 — ci.yml hard-calls `scripts/verify-manifest.py` at ci.yml:34,36 → CONFIRMED
Read `.github/workflows/ci.yml` directly. Line 34 = `run: python3 scripts/verify-manifest.py repos/MANIFEST.yaml`; line 36 = `run: python3 scripts/verify-manifest.py tools/MANIFEST.yaml` (job `manifest-validate`, `ci.yml:28-36`). The reference is a literal, unconditional `run:` step — not behind a conditional or a wrapper. Removing the script (or either manifest) before this job is removed turns `main` CI red. The companion Makefile evidence also holds: `Makefile:28` `verify:` target lists `verify.manifest verify.tools`, whose recipes (`Makefile:44`, `Makefile:48`) call the same script. **Ordering rule (consumers-first removal in the same PR) is sound.**

### D6.2 — secrets/store/ holds real GPG-encrypted secrets → CONFIRMED (strengthened)
`find secrets/store -type f` returns all five claimed paths: `openai/personal.gpg`, `n8n/api-key.gpg`, `n8n/mcp/token.gpg`, `github/personal/cli.gpg`, `runner/.gpg-id` (plus `secrets/store/.gpg-id`, `.gitkeep`). `file` + `xxd` prove the `.gpg` blobs are **real PGP RSA-encrypted content**, not scaffold: PGP magic byte `0x85`, "PGP RSA encrypted session key", RSA 4096b, keyid `5B50D66F E264FD21`, sizes 619–848 bytes. They are encrypted to the real fingerprint `6EC33743AA0CB75126F63F8765A937C4164F966F` in `secrets/store/.gpg-id`. The `.meta.yaml:122-126` supersession block is confirmed verbatim (flexnetos_secrets RETIRED → envctl, ADR-0007, "split-brain", "Empty-repo archival is a NEEDS-HUMAN owner decision"). **The "real-encrypted content routed to envctl, not a new repo" risk is real and high-stakes.**

### D6.9 — ADR-0007/0008 absent; only ADR-0001 on disk → CONFIRMED
`ls architecture/adr/` returns exactly one file: `ADR-0001-architecture-artifact-homes.md`. ADR-0007 and ADR-0008 are referenced only in `.meta.yaml` comments (`:123`, `:126`) and this loop's own files — they are not on disk in this repo. Phase-gating logic (secrets + runner/app phases must fetch the ADRs first) holds.

### git tag -l is empty / @v1 does not exist yet → CONFIRMED
`git tag -l` returns nothing; `git ls-remote --tags origin` returns nothing. The `@v1` tag truly does not exist locally or on the remote. So the recommended action targets a genuine, un-created tag.

### Recommended next action "@v1 has zero extraction/ADR/content dependency" → QUALIFIED (material correction)
The *extraction/ADR/content-independence* half is CONFIRMED: none of the five core reusable workflows (`reusable-build/lint/test/security/release.yml`) reference RETIRE-slated machinery (`verify-manifest`, `submodule-*`, `MANIFEST.yaml`, `secrets/store`) — grep returns clean. They have **real bodies** (real `uses:`/`run:` steps, toolchain setup, artifact upload — no `TODO`/`placeholder`/`stub`/`scaffold` markers), satisfying RELEASING.md path-to-v1 step 1.

**But the claim omits two real preconditions that `RELEASING.md` states explicitly:**
1. **`RELEASING.md` ("The first release — v1.0.0"):** *"Until the reusable workflows ship real bodies (not scaffolds), there is no v1."* — satisfied now, but the finding never names this gate, and `reusable-secrets.yml` is explicitly **excluded** until the `pass` vault is initialized (USER.TODO §4), which ties the secrets-template release to the same human-gated GPG work as D6.3.
2. **`RELEASING.md` step 2:** v1 requires **"green CI on `main` for at least one cycle"** *and* the cut is a **release-please PR merge** (`release.yml` tags `v1.0.0` + `v1`), **not a manual `git tag` cut.** The finding's phrasing "cut the `@v1` release/tag" / "release v1 against the current green main" is directionally consistent but understates that v1 emerges from merging the release-please "chore(main): release X.Y.Z" PR, gated on a green-main cycle — not an arbitrary on-demand tag.

Verdict: the recommended action (do @v1 first; lowest-risk, highest-unblock) **survives** — it remains extraction-/ADR-/content-independent. But "zero dependency" is too strong: it depends on (a) a green-main cycle and (b) the release-please flow, and `reusable-secrets.yml`'s inclusion is gated on the same vault work as the secrets phase. Synthesis should state the precondition, not "zero dependency."

### Phase ordering soundness — "retire role-2 machinery only after tools/repos/network are meta peers" → CONFIRMED (with a scope refinement)
Stress-tested the dependency. `.gitmodules` maps **only** `tools/*` (7 entries); `repos/*`, `network/slim`, and `data/brain-data/*` are **not** in `.gitmodules` (grep confirms none present). So:
- For the **7 `tools/*` gitlinks**, `.gitmodules` + the submodule scripts are the *only* live materialization path — deleting them before those tools exist as `.meta.yaml` peers genuinely orphans materialization. **The "peers-first, then retire" dependency is required, but narrowly: it binds the `tools/*` set specifically.**
- The **CI/script retirement** (D6.4) is a *separable* concern from gitlink materialization: the `manifest-validate` CI job and `verify-manifest.py` could in principle be removed independently of `.gitmodules`, but doing so still requires co-removing the manifests they read — so the consumers-first rule still governs. The two sub-dependencies (peers-before-`.gitmodules` and consumers-before-script) are both real and do not conflict.
Counter-example sought (could machinery be retired first?): no — removing `.gitmodules` first would leave the 7 tools/* with no clone path under `meta`, and removing `verify-manifest.py` first reddens `main` CI (D6.4). Both refutation attempts fail. Ordering stands.

## Secondary-claim verdicts (cross-checked in passing)

- **D6.1** (extract-then-remove atomicity; peers already declared) — CONFIRMED. `MIGRATION.md:11-13` safety principle verbatim ("especially `secrets/`"); destination peers present in `.meta.yaml`.
- **D6.3** (secrets handling is human-gated, GPG-mediated, import-then-verify-then-remove) — CONFIRMED on the human-gating/ordering; bootstrap placeholder warning confirmed at `scripts/bootstrap.sh:100-101`; USER.TODO §4 GPG-key step at `USER.TODO.md:115+`. **Refinement:** `secrets/.gpg-id` (vault root) is a literal placeholder (`<40-CHAR-FINGERPRINT>`) and `secrets/store/runner/.gpg-id` is the runner placeholder, BUT the actual blobs are encrypted to the **real** key in `secrets/store/.gpg-id` — so the blobs decrypt with the owner's real key regardless of the root placeholder. Does not weaken the claim; the envctl-import-path / vault command surface remains INCONCLUSIVE here (envctl lives outside this repo — not verifiable in `.github`), matching the finding's own Medium caveat.
- **D6.6** (peers-first then `.gitmodules` delete) — CONFIRMED (see ordering stress-test above). `.gitmodules` tools/*-only mapping confirmed; `MIGRATION.md:65-73` MIGRATE/RETIRE table confirmed verbatim (DELETE `.gitmodules`; RETIRE `verify-manifest.py` + `submodule-*.sh` + `manifest-drift.yml`/`submodule-bump.yml`).

## Tally
- CONFIRMED: D6.1, D6.2, D6.3 (human-gating), D6.4, D6.6, D6.9, and the @v1-does-not-exist precondition.
- QUALIFIED: Recommended next action — sound but **not "zero dependency"**: depends on a green-main cycle + the release-please flow per RELEASING.md; `reusable-secrets.yml` inclusion is vault-gated. Synthesis must carry this caveat.
- INCONCLUSIVE: envctl's vault-import command surface (out-of-repo); exact KB home of ADR-0007/0008 (finding's own Medium caveat — unchanged).
- REFUTED: none.
