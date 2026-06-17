# Verdicts — D4 (MOVE/EXTRACT readiness)

**Verifier run:** 2026-06-13 · adversarial, default-skeptical, fail-closed.
**Target (read-only):** `/home/drdave/Desktop/meta/.github_org` inside meta workspace `/home/drdave/Desktop/meta/`.
**Source under verdict:** `.handoff/loop/findings/D4-move-readiness.md`.

Method: opened every cited `path:line`, ran `ls`/`find`/`git ls-tree`/`git ls-files`/`grep -n`
to attack each material claim. Counter-evidence cited where a refutation attempt landed.

---

## Per-claim verdicts

### D4.1 — four MOVE peers declared; secrets RETIRED (not a peer) → **CONFIRMED**
- `.meta.yaml:123-125` carries the verbatim RETIRED block, exact text match:
  `# flexnetos_secrets RETIRED → envctl (ADR-0007): … so a second store / would be split-brain. Empty-repo archival is a NEEDS-HUMAN owner decision.`
- Peer blocks confirmed at `.meta.yaml:127` (flexnetos_runner), `:130` (flexnetos_github_app),
  `:133` (flexnetos_wiki), `:136` (flexnetos_brain). No `flexnetos_secrets:` key exists.
- Refutation failed: text and line numbers match exactly.

### D4.2 — secrets migrates INTO envctl, not to a peer; dest archived → **CONFIRMED**
- `handoff/docs/adr-0007-…md:32-47` §Decision enumerates: (1) de-register from `.meta.yaml`;
  (2) GitHub-token concern → `ProviderMint::mint_scoped`; (3) migrate `secrets/**` +
  `scripts/secrets-{inject,rotate,mirror-to-bws,sync-github-from-bitwarden}.sh` via
  `secretctl import`, glue "absorbed by envctl's rotation surface, not re-homed to a peer";
  (4) archive empty GitHub repo = user-authorized org action.
- "MIGRATION.md:55 still lists a flexnetos_secrets peer (stale row)": my first grep hit the
  ROOT `meta/MIGRATION.md` (does not exist) and returned 0 — false alarm. The analyst means
  `.github_org/MIGRATION.md:55`, which DOES carry `| **flexnetos_secrets** (role 4) | secrets/, …`.
  Refutation **withdrawn** — claim holds.
- NEEDS-HUMAN corroboration confirmed: `NEEDS-HUMAN.md:115` "Archive the now-empty
  flexnetos_secrets repo (retired per ADR-0007)".

### D4.3 — secrets/store/ holds 4 real .gpg ciphertext (data-loss blocker) → **CONFIRMED**
- `find secrets/store -name '*.gpg'` = **exactly 4**: `github/personal/cli.gpg`,
  `n8n/api-key.gpg`, `n8n/mcp/token.gpg`, `openai/personal.gpg`. All four cited files exist.
- Guard hook present: `scripts/hooks/protect-secrets-store.sh:17-18` blocks edits inside
  `secrets/store/` (`case … */secrets/store/*) … exit 2`). The data-loss-blocker framing stands.

### D4.4 — secrets coupling is broad (.envrc, 3 Makefile verbs, bootstrap, doctor, 2 workflows) → **CONFIRMED (one citation off by one line)**
- `PASSWORD_STORE_DIR="${PWD}/secrets/store"` is at **`.envrc:17`**, NOT `:18` as cited. The
  fact is correct; the line number is off by one. QUALIFIED on citation precision only.
- `Makefile:130,135,141` confirmed pointing at `secrets/store` (secrets.pull/rotate/mirror).
- `scripts/bootstrap.sh:92-101,129` checks `secrets/store/` + `secrets/.gpg-id` — confirmed.
- `scripts/github-doctor.py:125-126` audits `secrets/…` — confirmed.
- `reusable-secrets.yml` + `secrets-rotate.yml` both exist. Coupling fan-out holds.

### D4.5 — runner/ + github-app/ already extracted as Rust REIMPLEMENTATIONS; remove pending → **CONFIRMED**
- Peer dirs exist with Cargo crates: `flexnetos_runner/Cargo.toml`,
  `flexnetos_github_app/Cargo.toml`. File counts (full clones): runner **1213**, github_app
  **2237** (analyst said ~1104 / ~1952 — same order of magnitude; both UNDERSTATED, not
  overstated, so the "populated, building Rust" thrust is sound — not marked INCONCLUSIVE).
- ADR-0008:53-62 confirms `runner-actions` "**productizes** `.github_org/runner/{ephemeral-spawn.sh,
  register.sh,remove.sh,install.sh,systemd/*}` into Rust" and the router is "**delegate-only**".
- Originals still on disk: `.github_org/runner/`, `.github_org/github-app/` present → remove step
  pending. Claim holds.

### D4.6 — runner/ coupling: bootstrap installs, Makefile drives, doctor audits, docs cross-link → **CONFIRMED**
- `scripts/bootstrap.sh:116-119` runs `bash runner/install.sh` (and `:20` documents
  `--with-runner`). Confirmed.
- `scripts/github-doctor.py:110-118` audits 8 `runner/*` paths (README, install/register/remove,
  .env.example, ephemeral-spawn, systemd service+timer) — exact count verified.
- network/slim gitlink present (see D4.9 ls-tree). Holds.

### D4.7 — wiki/ is LOW-coupling, cleanest MOVE → **CONFIRMED**
- `wiki-lint.yml:7-9` is `on: schedule` (cron `0 11 * * *`) only — no push/PR trigger; reads
  only `wiki/index.md`,`wiki/log.md` (`:24-29`). Moves with wiki / becomes no-op. Confirmed.
- `verify-markdown.py:14,17` excludes `wiki/raw/` — confirmed. Low-coupling thrust holds.

### D4.8 — github-app/ is 2 files; only github-doctor references it → **CONFIRMED**
- `ls github-app/` = exactly `manifest.example.json` + `permissions.md`.
- `scripts/github-doctor.py:131-132` audits both; `:134` references the token-smoke template.
  Sole-coupling claim holds.

### D4.9 — data/brain-data 5 nested gitlinks UNMAPPED in .gitmodules → **CONFIRMED**
- `git ls-tree -r HEAD | grep 160000` shows the 5 brain-data gitlinks: `DeepTutor`,
  `deepwiki-rs`, `my-wiki-knowledge/.claude/obsidian-second-brain`,
  `my-wiki-knowledge/.claude/obsidian-skills`, `obsidian-mind`.
- `.gitmodules` maps ONLY 7 `tools/*` paths (`:2,7,12,17,22,27,32`) — none under
  `data/brain-data`. Confirmed unmapped → subtree/move would break.
- (Side note: `network/slim` and `repos/{ai-top-utility,fabro,n8n,paperclip}` are ALSO unmapped
  gitlinks, but the claim is correctly scoped to brain-data's 5 — not overstated.)
- `verify-markdown.py:19-23` third-party-vault excludes confirmed (obsidian-mind, DeepTutor,
  deepwiki-rs, my-wiki-knowledge). `flexnetos_brain` peer = 0 tracked files (confirmed).

### D4.10 — .claude/ reverse-coupled to scripts/hooks/* that guard secrets/ + .gitmodules → **CONFIRMED**
- `.claude/settings.json:93` → `bash scripts/hooks/actionlint-on-workflow-edit.sh`;
  `:202` → `protect-secrets-store.sh`; `:207` → `gitmodules-drift-guard.sh`. All repo-relative.
- `protect-secrets-store.sh:17-18` guards `secrets/store/` (leaving to envctl);
  `gitmodules-drift-guard.sh` exists (979B) and guards `.gitmodules` (role-2 deletion target).
  Entanglement claim holds.

### D4.11 — ADR-0007/0008 reachable in handoff/docs/, not in repo's architecture/adr/ → **CONFIRMED**
- `architecture/adr/` holds only `ADR-0001-architecture-artifact-homes.md` (verified `ls`).
- `handoff/docs/adr-0007-flexnetos-secrets-retirement.md` (5.9K) and
  `handoff/docs/adr-0008-flexnetos-app-runner.md` (15.9K) both exist and were read.
  Traceability-gap framing is accurate.

---

## Tally
- CONFIRMED: 11 of 11 material claims (D4.1–D4.11).
- QUALIFIED: 1 (D4.4 — fact correct, `.envrc` cite is `:17` not `:18`; off-by-one only).
- REFUTED: 0.
- INCONCLUSIVE: 0 (every priority target — peer dirs, ADR files, .gpg count, gitlinks — was
  locally present and verifiable; nothing had to be left unconfirmed).

## Verifier notes (non-blocking corrections for synthesis)
1. **Peer file counts UNDERSTATED, not overstated** — actual runner=1213 / github_app=2237 vs
   the analyst's ~1104 / ~1952. Direction is safe (peers are *more* populated, not less), so the
   "already extracted, building Rust reimplementation" verdict is reinforced, not weakened.
2. **D4.4 line cite:** `PASSWORD_STORE_DIR` is `.envrc:17`. Correct to `:17` in the report.
3. **D4.2 MIGRATION.md path is repo-local** (`.github_org/MIGRATION.md:55`), not the root
   meta `MIGRATION.md` (which does not exist). The stale-row claim is real and confirmed.
4. All ADR §Decision text (0007:32-47) and §2 productization text (0008:53-62) directly back
   D4.2 and D4.5 verbatim — these are the load-bearing decisions and they are real.
