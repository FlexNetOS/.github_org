# D4 — MOVE/EXTRACT readiness (roles 3,4,5 + config dirs → flexnetos_* peers)

**Question:** For each MOVE target, how coupled is its content to the rest of the repo, what are the
extraction blockers, and is extract-then-remove safe?

**Method:** grepped cross-references (scripts, Makefile, `.github/workflows/*.yml`, `.envrc`,
`.claude/settings.json`), enumerated committed gitlinks (`git ls-tree -r HEAD | grep 160000`),
checked destination-peer population state in the parent meta workspace, and fetched the governing
ADRs from `handoff/docs/` (they are NOT on disk in this repo — see CLAIM D4.9).

---

### CLAIM D4.1 — All four "new repo" MOVE destinations are already declared as meta peers; secrets is deliberately NOT among them.
`flexnetos_runner`, `flexnetos_github_app`, `flexnetos_wiki`, `flexnetos_brain` are declared in the
parent `.meta.yaml`. `flexnetos_secrets` is explicitly **retired** in the same file, not declared as
an active peer.
**Evidence:** `/home/drdave/Desktop/meta/.meta.yaml:127-138` (the four `flexnetos_*` blocks);
`/home/drdave/Desktop/meta/.meta.yaml:123-125` — verbatim:
> `# flexnetos_secrets RETIRED → envctl (ADR-0007): envctl already owns the vault /`
> `# secretd / broker / relay + the ProviderMint GitHub-token seam, so a second store`
> `# would be split-brain. Empty-repo archival is a NEEDS-HUMAN owner decision.`
**Confidence:** high.

### CLAIM D4.2 — secrets/ does NOT move to a peer: it migrates INTO envctl's vault (ADR-0007), and the destination peer is empty/to-be-archived.
MIGRATION.md:55 still lists a `flexnetos_secrets` peer; that row is **stale**. The authoritative
decision (ADR-0007 §Decision) is: de-register `flexnetos_secrets` from `.meta.yaml`; route the
GitHub-token concern to `envctl ProviderMint::mint_scoped`; migrate `.github_org/secrets/**` +
`scripts/secrets-{inject,rotate,mirror-to-bws,sync-github-from-bitwarden}.sh` into envctl's vault via
`secretctl import`; the `secrets-rotate.yml` / `reusable-secrets.yml` glue is **absorbed by envctl's
rotation surface, not re-homed to a peer**. The empty `FlexNetOS/flexnetos_secrets` GitHub repo is to
be **archived** (org action, NEEDS-HUMAN).
**Evidence:** `/home/drdave/Desktop/meta/handoff/docs/adr-0007-flexnetos-secrets-retirement.md:32-47`;
local peer dir is empty (`flexnetos_secrets/` = 0 tracked files);
`/home/drdave/Desktop/meta/NEEDS-HUMAN.md:115-119` ("Archive the now-empty `flexnetos_secrets` repo").
**Confidence:** high.

### CLAIM D4.3 — secrets/ has a HARD data-loss blocker: secrets/store/ holds real GPG ciphertext, not just a scaffold.
The codemap calls `secrets/` a "scaffold," but `secrets/store/` contains real `.gpg` encrypted
payloads (`openai/personal.gpg`, `n8n/api-key.gpg`, `github/personal/cli.gpg`, `n8n/mcp/token.gpg`).
Extraction is therefore **not** a copy-then-delete of scaffold files — the ciphertext must be
`secretctl import`-ed into envctl and verified decryptable there BEFORE removal. A naïve `rm -rf
secrets/` after a peer-archive is data loss of live (encrypted) credentials.
**Evidence:** `secrets/store/openai/personal.gpg`, `secrets/store/n8n/api-key.gpg`,
`secrets/store/github/personal/cli.gpg`, `secrets/store/n8n/mcp/token.gpg` (via `find secrets/ -type f`);
guard hook `scripts/hooks/protect-secrets-store.sh:17-18` (blocks edits inside `secrets/store/`).
**Confidence:** high.

### CLAIM D4.4 — secrets/ coupling is broad: .envrc, Makefile (3 verbs), bootstrap, github-doctor, and a CI template all hard-reference secrets/store.
`.envrc:18` sets `PASSWORD_STORE_DIR="${PWD}/secrets/store"` for direnv-time injection;
`Makefile:130,135,141,146` (`secrets.pull/rotate/mirror/sync` verbs) all `cd`/point at
`secrets/store`; `scripts/bootstrap.sh:92-101,129` checks `secrets/store/` + `secrets/.gpg-id`;
`scripts/github-doctor.py:125-126` audits `secrets/`; `.github/workflows/reusable-secrets.yml:16,55-95`
checks out the umbrella to read `secrets/store/`; `secrets-rotate.yml:25` uses `secrets/store`. So
removing `secrets/` requires retiring/redirecting all of these in lockstep (or they break the verify
gate + direnv load).
**Evidence:** `.envrc:18`; `Makefile:130,135,141,146`; `scripts/bootstrap.sh:92-101`;
`scripts/github-doctor.py:125-126`; `.github/workflows/reusable-secrets.yml:16,55-95`;
`.github/workflows/secrets-rotate.yml:25`.
**Confidence:** high.

### CLAIM D4.5 — runner/ and github-app/ are ALREADY extracted, but as Rust REIMPLEMENTATIONS, not file copies — and the .github_org originals still exist (remove half not done).
The peers are populated and building (`flexnetos_runner` ≈1104 files, `flexnetos_github_app` ≈1952
files), but they are Rust crates (`Cargo.toml`, `crates/`), **not** verbatim copies of the shell
scripts / manifest scaffold in `.github_org`. ADR-0008 §2 states the runner "**productizes**
`.github_org/runner/{ephemeral-spawn.sh,register.sh,remove.sh,install.sh,systemd/*}` into Rust" —
i.e. the `.github_org` originals are the **design source**, superseded by the P0 reimplementation, not
moved. `.github_org/runner/` and `.github_org/github-app/` still exist on disk → the extract step is
effectively done (in reimplemented form) but the **remove** step is pending, gated on parity.
**Evidence:** `/home/drdave/Desktop/meta/handoff/docs/adr-0008-flexnetos-app-runner.md:29-31,53-62`
(shell→Rust productization; "delegate-only" router); peer dirs `flexnetos_runner/{Cargo.toml,crates}`,
`flexnetos_github_app/{Cargo.toml,crates,HANDOFF.md}`; originals still present
(`.github_org/runner/`, `.github_org/github-app/`).
**Confidence:** high.

### CLAIM D4.6 — runner/ coupling: bootstrap auto-installs it, Makefile drives it, github-doctor audits it, docs/org-setup cross-links it.
`scripts/bootstrap.sh:116-119` runs `runner/install.sh` on bootstrap; `Makefile:189,197,205` drive
`runner/{install,register,remove}.sh`; `scripts/github-doctor.py:110-118` audits 8 `runner/*` paths;
`docs/org-setup.md:242,256,404` and `docs/self-hosted-runner.md` cross-reference `runner/policies/`.
None of these are blockers (they follow runner to its peer or get retired with bootstrap), but they
must move/retire in lockstep. `network/` (with the `network/slim` gitlink) is provisionally bundled
with runner (MIGRATION.md:56) but its split is an open question (MIGRATION.md:87) — minor blocker.
**Evidence:** `scripts/bootstrap.sh:116-119`; `Makefile:189,197,205`;
`scripts/github-doctor.py:110-118`; `docs/org-setup.md:242,256,404`; gitlink `network/slim`
(`git ls-tree -r HEAD`).
**Confidence:** high.

### CLAIM D4.7 — wiki/ is LOW-coupling and the cleanest MOVE: only wiki-lint.yml + markdown-exclude prefixes + help text reference it.
`wiki/` is self-contained. References are: `.github/workflows/wiki-lint.yml` (a `schedule`-only nightly
job that only ever reads `wiki/*` — moves WITH wiki); `scripts/verify-markdown.py:14,17` and
`reusable-lint.yml:100,112` exclude `wiki/raw/**` from markdown lint (a one-line exclusion that simply
becomes a no-op once wiki leaves); `Makefile:99-123` wiki-lint help text (cosmetic). No script writes
into `wiki/`, no CI gate hard-depends on it. `architecture/` is provisionally bundled with wiki
(MIGRATION.md:57) and has **zero** Makefile/CI coupling (grep clean) → also clean, but its destination
(wiki vs keep-in-.github) is an open question (MIGRATION.md:85).
**Evidence:** `.github/workflows/wiki-lint.yml:24-48` (reads only `wiki/`; `on: schedule` only);
`scripts/verify-markdown.py:14,17`; `.github/workflows/reusable-lint.yml:100,112`; `Makefile:99-123`;
no hits for `architecture/` in Makefile/workflows.
**Confidence:** high.

### CLAIM D4.8 — github-app/ is the lowest-content, lowest-coupling target (2 files): only github-doctor references it.
`github-app/` holds just `manifest.example.json` + `permissions.md`. Sole coupling is
`scripts/github-doctor.py:131-134` (audit). `scripts/github-app-token-smoke.py` is the companion
mover. Since `flexnetos_github_app` already exists as a full Rust control-plane (CLAIM D4.5), the
`.github_org/github-app/` scaffold is purely the **design seed**; removing it is safe once the peer's
manifest/permissions docs subsume it.
**Evidence:** `github-app/{manifest.example.json,permissions.md}` (`ls github-app/`);
`scripts/github-doctor.py:131-134`; companion `scripts/github-app-token-smoke.py`.
**Confidence:** high.

### CLAIM D4.9 — data/brain-data is the heaviest target (76M) and its 5 nested gitlinks are UNMAPPED in .gitmodules — a structural extraction blocker.
`data/brain-data/` is 76M and contains 5 committed gitlinks (mode 160000): `DeepTutor`, `deepwiki-rs`,
`obsidian-mind`, and `my-wiki-knowledge/.claude/obsidian-second-brain` + `.../obsidian-skills`. **None**
of them have a `.gitmodules` entry (`.gitmodules` maps only the 7 `tools/*`). A naïve `git mv` /
subtree-extract of `data/brain-data/` into `flexnetos_brain` will **break** because git has gitlink
pointers with no submodule URL to resolve — they must be re-registered (or dereferenced) at the
destination. The session logs (`SESSIONS.md` 93.6K, `USER.TODO.md` 34.1K, `TODO.md`) are provisionally
bundled here (MIGRATION.md:58,88) but are referenced by `manifest-drift.yml`, `bootstrap.sh`,
`check-user-todo-step5.sh` → those references must be cut. `flexnetos_brain` peer is currently empty.
**Evidence:** `du -sh data/brain-data` = 76M; 5 gitlinks via `git ls-tree -r HEAD | grep 160000`
(none under `data/brain-data` appear in `.gitmodules`); `scripts/verify-markdown.py:19-23` (third-party
vault excludes); session-log refs `manifest-drift.yml`, `scripts/bootstrap.sh`,
`scripts/check-user-todo-step5.sh`; `flexnetos_brain/` = 0 tracked files.
**Confidence:** high.

### CLAIM D4.10 — config dirs (.claude/.codex/.agents/.omc) are MEDIUM-coupling: .claude/ is reverse-coupled to repo-relative scripts/hooks AND to secrets/ + .gitmodules.
`.claude/settings.json:93,202,207` register PreToolUse/PostToolUse hooks invoking
`bash scripts/hooks/{actionlint-on-workflow-edit,protect-secrets-store,gitmodules-drift-guard}.sh` —
**repo-relative paths**. If `.claude/` moves to a `flexnetos_claude_config` peer, those hooks point at
`scripts/hooks/*` that live in `.github_org`, not the peer → the hooks silently no-op or break unless
the hook scripts move too or the paths are absolutized. Two of those hooks are themselves coupled to
MOVE targets: `protect-secrets-store.sh` guards `secrets/store/` (which is leaving to envctl) and
`gitmodules-drift-guard.sh` guards `.gitmodules` (which is being DELETED in role-2 migration). So
`.claude/` extraction is entangled with the secrets + role-2 work, not independent.
`.codex/.agents/.omc` are lighter: `Makefile:169-182` + `manifest-drift.yml:25-99` reference
`.claude/.doctor-allowlist`, `.codex/.doctor-allowlist`, `.omc/plans/open-questions.md` (doctors /
report-only checks that retire with the config). `.omc/` is regenerable cache (MIGRATION.md:81) → drop,
not move.
**Evidence:** `.claude/settings.json:93,202,207`; `scripts/hooks/protect-secrets-store.sh:17-18`;
`scripts/hooks/gitmodules-drift-guard.sh` (referenced); `Makefile:169-182`;
`.github/workflows/manifest-drift.yml:25-99`; MIGRATION.md:60-63,81.
**Confidence:** high.

### CLAIM D4.11 — ADR-0007 and ADR-0008 ARE reachable — in handoff/docs/, not in this repo's architecture/adr/ (only ADR-0001 on disk here).
The codemap/ledger flagged ADR-0007/0008 as "absent from disk." Correction: they are absent from
**`.github_org/architecture/adr/`** (which holds only `ADR-0001-architecture-artifact-homes.md`), but
their full authoritative text lives at `handoff/docs/adr-0007-flexnetos-secrets-retirement.md` and
`handoff/docs/adr-0008-flexnetos-app-runner.md` in the meta workspace. This is a **traceability gap, not
a missing decision** — the governing ADRs exist and were read for this analysis.
**Evidence:** `ls .github_org/architecture/adr/` → only `ADR-0001-…`; the ADRs found at
`/home/drdave/Desktop/meta/handoff/docs/adr-0007-…md`, `…adr-0008-…md`.
**Confidence:** high.

---

## Summary table

| MOVE target | dest peer declared? | coupling | blocker | safety note |
| --- | --- | --- | --- | --- |
| `wiki/` (+wiki-lint.yml, architecture/?) → **flexnetos_wiki** | yes (`.meta.yaml:133`); peer empty | **LOW** — wiki-lint (schedule-only, reads only wiki/), `wiki/raw/**` markdown-excludes, Makefile help text | none structural; `architecture/` destination open (MIGRATION.md:85) | Cleanest MOVE. wiki-lint.yml + exclude lines follow/no-op. |
| `runner/` (+runner-doctor, self-hosted-runner.md, network/?) → **flexnetos_runner** | yes (`.meta.yaml:127`); peer **populated** (~1104 files, Rust) | MED — bootstrap auto-installs, Makefile drives, github-doctor audits 8 paths, docs cross-link | network/ split open (MIGRATION.md:87) | Peer is a Rust **reimplementation** (productizes the shell, ADR-0008 §2), not a copy. Remove originals only after parity. |
| `github-app/` (+token-smoke.py) → **flexnetos_github_app** | yes (`.meta.yaml:130`); peer **populated** (~1952 files, Rust) | LOW — only github-doctor:131-134 | none | 2-file scaffold = design seed; peer (P0 Rust app) already subsumes it. |
| `data/brain-data/` (76M, 5 gitlinks) + session logs → **flexnetos_brain** | yes (`.meta.yaml:136`); peer empty | MED-HIGH — verify-markdown excludes; session logs ref'd by manifest-drift, bootstrap, check-user-todo-step5 | **5 nested gitlinks UNMAPPED in .gitmodules** → subtree/move breaks | Heaviest dir. Re-register or dereference gitlinks at destination before move. |
| `secrets/` + scripts/secrets-*.sh → **envctl (NOT a peer)** | **NO — RETIRED → envctl per ADR-0007** (`.meta.yaml:123-125`); `flexnetos_secrets` peer empty, to be archived | HIGH — .envrc, 3 Makefile verbs, bootstrap, github-doctor, reusable-secrets.yml, secrets-rotate.yml | **Live GPG ciphertext in secrets/store/** (4 real `.gpg` files) + envctl `secretctl import` is the only sanctioned sink | **NOT a file move.** `secretctl import` into envctl, verify decryptable, THEN remove. Archiving GitHub repo = NEEDS-HUMAN org action. |
| `.claude/`, `.codex/`, `.agents/`, `.omc/` → config peers | not yet (config peers un-declared in the read range) | MED — `.claude/` hooks call repo-relative `scripts/hooks/*`; doctors ref `.codex/.omc` allowlists | `.claude/` hooks coupled to secrets/ + .gitmodules (both leaving/deleted) | `.omc/` is regenerable → DROP not move. `.claude/` move entangled with secrets + role-2 retirement. |

---

## Extraction readiness verdict

The MOVE work is **registration-complete but content-incomplete, and unevenly so**. Destinations are
grounded (four `flexnetos_*` peers declared in `.meta.yaml`; secrets correctly *de-scoped* to envctl per
ADR-0007 rather than given a peer). Two targets are effectively already extracted — `flexnetos_runner`
and `flexnetos_github_app` are populated, building Rust **reimplementations** (ADR-0008 P0), so their
`.github_org` originals are now design-seeds awaiting a parity-gated *remove*, not a *move*. The two
cleanest remaining literal moves are `wiki/` (low coupling; its only CI consumer is a schedule-only
nightly that reads only `wiki/`) and `github-app/` (2 files). The two genuine blockers are: (1) **secrets/**,
which carries live GPG ciphertext and a wide coupling fan-out (`.envrc`, three Makefile verbs, bootstrap,
two workflows) and must go through `secretctl import` into envctl with verify-before-delete — extract-
then-remove here is a *data-migration*, not a file move, and naïve removal is data loss; and (2)
**data/brain-data/**, whose five nested gitlinks are unmapped in `.gitmodules`, so any subtree extraction
breaks until they are re-registered or dereferenced at `flexnetos_brain`. Config dirs are a softer blocker:
`.claude/` is reverse-coupled to repo-relative `scripts/hooks/*` (two of which guard `secrets/store/` and
`.gitmodules` — both themselves leaving), so its extraction is entangled with the secrets + role-2 work and
cannot be sequenced independently; `.omc/` should be dropped (regenerable), not moved. Net: safe extract-
then-remove ordering is **wiki/github-app (clean) → runner (parity-gate the remove) → brain-data (fix
gitlinks first) → secrets (data-migrate to envctl, verify, then remove) → config dirs (after secrets +
role-2)**. MIGRATION.md is partially stale (its `flexnetos_secrets` row); `.meta.yaml` + ADR-0007/0008
(in `handoff/docs/`) are the ground truth.
