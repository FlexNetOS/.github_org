# Verdicts — D2 (Target meta-peer-architecture conformance)

**Verifier pass:** 2026-06-13 · adversarial, default-skeptical, fail-closed
**Source:** `.handoff/loop/findings/D2-meta-conformance.md`
**Target (read-only):** `/home/drdave/Desktop/meta/.github_org` in meta `/home/drdave/Desktop/meta/`

All claims re-checked with live commands against actual repo state (not the analyst's summaries).

---

## Per-claim verdicts

### D2.1 — Independent repo with own remote/history distinct from parent — **CONFIRMED**
Live: child `git remote -v` → `git@github.com:FlexNetOS/.github.git`; parent → `git@github.com:FlexNetOS/meta.git`. Child `git rev-parse --show-toplevel` = `/home/drdave/Desktop/meta/.github_org`. Child HEAD `4fefb0ecf965…` (matches claim). Parent HEAD is now `5a7d5da42f87…` (the parent has moved since the analyst's snapshot, but the load-bearing fact — HEADs differ, separate histories/worktrees — holds). Refutation failed.

### D2.2 — Already a registered meta peer with `path:` + `tags:` — **CONFIRMED**
Read `../.meta.yaml:111-114`: `github_org:` / `repo: git@github.com:FlexNetOS/.github.git` / `path: .github_org` / `tags: [org, ci]`. The documenting comment block at `:107-110` (GitHub-mandated `.github` name; cloned to `.github_org/` to avoid colliding with meta root's `.github/`; refactor to roles 1+6 in progress) is present verbatim. Exactly as claimed.

### D2.3 — Parent gitignores this repo — **CONFIRMED**
Live: `grep -n github_org ../.gitignore` → `77:.github_org/`. Exact line, exact content.

### D2.4 — Leaf peer, no nested `.meta.yaml` — **CONFIRMED**
Live: `ls .github_org/.meta.yaml .github_org/.meta` → both "No such file or directory". Absence verified; leaf corollary holds.

### D2.5 — All four MOVE-target peers already declared in `../.meta.yaml` — **CONFIRMED (registry side)**
Read `../.meta.yaml:127-138`: `flexnetos_runner` `tags: [ops, runner]`, `flexnetos_github_app` `tags: [ops, github-app]`, `flexnetos_wiki` `tags: [docs]`, `flexnetos_brain` `tags: [docs, data]` — all present. Registry declaration is real.
**Caveat carried to D2.8:** the claim's parenthetical characterization "They are empty/unpopulated targets" is only true for 2 of 4 (see D2.8) — but the *registration* assertion this claim actually makes is sound.

### D2.6 — `flexnetos_secrets` RETIRED → `envctl` (ADR-0007); secrets has a valid peer home — **QUALIFIED**
Read `../.meta.yaml:122-126`: the RETIRED→envctl note is present verbatim (split-brain rationale, empty-repo archival = NEEDS-HUMAN). `envctl:` is a declared peer at `:83-86` `tags: [tools, env]`. **Routing decision CONFIRMED.** But: (a) ADR-0007 is **NOT on disk** in this repo — `architecture/adr/` contains only `ADR-0001-architecture-artifact-homes.md`; the full ADR-0007 rationale is unverified here (matches the analyst's own Low-confidence flag). (b) Counter-observation: `flexnetos_secrets` *does* exist as a cloned peer dir under meta root (bare `.git` only, 0 commits) — so a `flexnetos_secrets` repo was grounded despite the "RETIRED, do not make a peer" decision. This is a mild tension (the registry says retire-to-envctl, yet an empty repo was cloned), not a refutation of the routing claim. Qualified on the ADR-text gap + the stray empty repo.

### D2.7 — Residual non-conformance #1: still hosts `.gitmodules` + 17 gitlinks — **CONFIRMED**
Live: `.gitmodules` present (837B, `Jun 3 12:04`). `git config --file .gitmodules --get-regexp path` → exactly **7** entries (`tools/{cpython,actionlint,gitleaks,trivy,node,bun,uv}`). `git ls-tree -r HEAD | grep -c ^160000` → **17**. All 17 paths match the analyst's enumeration exactly (7 `tools/*`, 4 `repos/*` = ai-top-utility/fabro/n8n/paperclip, `network/slim`, 5 under `data/brain-data/*`). Requirement (d) genuinely FAILS. Refutation failed — numbers are exact.

### D2.8 — Residual non-conformance #2: content belongs to declared peers; "destinations empty" — **QUALIFIED (REFUTED in part)**
Content-dirs-present-in-child: **CONFIRMED** — live `ls` shows `wiki/` (AGENTS.md, README.md, assets), `runner/` (.env.example, ephemeral-spawn.sh, install.sh, systemd), `github-app/` (manifest.example.json, permissions.md), `data/brain-data/` (DeepTutor, deepwiki-rs, memory), `secrets/` (.gpg-id, README.md) all physically present.

**"Destinations are empty" — REFUTED for 2 of 4 peers:**
- `flexnetos_wiki`: only `.git`, HEAD invalid (0 commits) → **EMPTY** (claim holds).
- `flexnetos_brain`: only `.git`, 0 commits → **EMPTY** (claim holds).
- `flexnetos_runner`: **25 tracked files** — a full Rust workspace (`crates/runner-{core,cli,actions,dispatch}`, Cargo.toml, .handoff/) → **NOT EMPTY**.
- `flexnetos_github_app`: **32 tracked files** → **NOT EMPTY**.

Moreover the populated peers are NOT a move of the child's dirs: child `runner/` is shell/systemd config; `flexnetos_runner` is freshly-built Rust crates (consistent with `../.meta.yaml:126` "flexnetos_github_app + flexnetos_runner are built at P0 per ADR-0008"). So for runner/github_app the model is **build-fresh-then-retire-the-old-dir**, not **extract-the-existing-content**. The analyst's own confidence was Medium and explicitly flagged this as not re-verified against remote contents — now re-verified: the blanket "destinations empty / awaiting content extraction" framing is **wrong for half the targets**. Qualified: directory presence CONFIRMED; uniform-emptiness REFUTED (true only for wiki+brain).

### D2.9 — Residual non-conformance #3: submodule machinery still wired/gated — **INCONCLUSIVE**
Not independently re-verified in this pass (the analyst flagged it as D5's dimension, Medium confidence inherited from codemap). The load-bearing precondition — `.gitmodules`+gitlinks still exist — is CONFIRMED (D2.7), so the machinery is plausibly still load-bearing, but the specific inventory (`scripts/submodule-*.sh`, Makefile `submodules.*`, `verify.manifest`/`verify.tools` gate, the two workflows) was not checked here. Stays unconfirmed; route to D5.

---

## Scorecard verdict (verifier-adjusted)

| # | Requirement | Analyst | Verifier |
|---|---|---|---|
| a | Independent repo + remote/history | Y | **CONFIRMED** |
| b | Registered with `path:` + `tags:` | Y | **CONFIRMED** |
| c | Gitignored by parent | Y | **CONFIRMED** |
| d | No submodules-as-children | N | **CONFIRMED (genuinely fails: 7 mapped + 17 gitlinks)** |
| e | Peer content is itself a peer | Partial | **QUALIFIED** — registered Y (D2.5); but runner+github_app already *populated* (built fresh per ADR-0008), only wiki+brain empty; secrets routed to envctl |
| f | Leaf peer (no nested `.meta.yaml`) | Y | **CONFIRMED** |

---

## Tally

- **CONFIRMED:** D2.1, D2.2, D2.3, D2.4, D2.7 (5)
- **QUALIFIED:** D2.5 (registry-side only), D2.6 (ADR-0007 not on disk; stray empty secrets repo), D2.8 (dirs present yes; "destinations empty" refuted for runner+github_app) (3)
- **REFUTED:** none outright, but the **"all destinations empty / content awaiting extraction"** sub-assertion inside D2.8 is **REFUTED for runner+github_app**.
- **INCONCLUSIVE:** D2.9 (deferred to D5) (1)

**Net for synthesis:** the registration verdict (a/b/c/f pass, d fails) is fully CONFIRMED and decision-grade. The one correction synthesis MUST carry: requirement (e) is more advanced than "registered-not-populated" — `flexnetos_runner` and `flexnetos_github_app` are already built (fresh, per ADR-0008), so the residual move is wiki+brain content + secrets→envctl + retiring the old in-tree dirs/machinery, NOT a uniform extract-into-empty-peers.
