# D2 — Target meta-peer-architecture conformance

**Dimension question:** What does "match meta / the meta peer-repo vision" concretely require, and how far is this repo already there vs. the gap?

**Verdict (1 line):** Registry-level conformance is **DONE** (independent repo + remote, registered peer with tags, gitignored by parent, no nested `.meta.yaml`); the **entire residual gap is the in-tree submodule/Role-2 machinery** — this repo still carries its own `.gitmodules` (7 mapped) + 17 committed gitlinks + the destinations' content, which the peer model says must not live here.

---

## The target model (established from `../CLAUDE.md` + `../.meta.yaml`)

A meta-repo is a **workspace of independent git repos registered as peers** in `.meta.yaml` — NOT a monorepo, NOT submodules-as-children. The defining rules (`../CLAUDE.md`):
- Each member is its own git repo with its own remote, commits, history.
- The root `.gitignore` ignores every child repo (children are NOT part of parent history).
- The root `Cargo.toml`/`.meta.yaml` reference members for convenience, but each builds/publishes independently.
- A child that *itself* contains a `.meta.yaml` is a **nested** meta (`meta: true`); a leaf peer has none.

Concrete conformance requirements for THIS repo:
- (a) independent git repo with its own remote;
- (b) registered in `../.meta.yaml` with `path:` + appropriate `tags:`;
- (c) gitignored by the parent;
- (d) does NOT host foreign code as submodules-as-children (Role 2 must retire);
- (e) the things it currently *contains* that should be peers are themselves registered peers.

---

### CLAIM D2.1 — This repo IS an independent git repo with its own remote and its own history (distinct from the parent).
Its remote is `git@github.com:FlexNetOS/.github.git`; the parent's is `git@github.com:FlexNetOS/meta.git`. Their HEADs are different commits (`4fefb0e…` here vs `5a7d5da…` parent), and `git rev-parse --show-toplevel` resolves to `.github_org` (not the meta root) — i.e. separate working trees / separate histories, exactly the peer model.
**Evidence:** `git -C .github_org remote -v` → `FlexNetOS/.github.git`; `git -C . remote -v` (parent) → `FlexNetOS/meta.git`; child HEAD `4fefb0ecf965…` vs parent HEAD `5a7d5da42f87…`; `git rev-parse --show-toplevel` = `/home/drdave/Desktop/meta/.github_org`.
**Confidence:** High.

### CLAIM D2.2 — This repo is ALREADY a registered meta peer with `path:` and `tags:`.
`../.meta.yaml:111-114` declares `github_org:` with `repo: git@github.com:FlexNetOS/.github.git`, `path: .github_org`, `tags: [org, ci]`. The comment block `../.meta.yaml:107-110` documents *why* (.github name is GitHub-mandated; cloned to `.github_org/` to avoid colliding with the meta root's own `.github/` dir) and that the refactor is in progress (`tasks/github-meta-refactor`, slim to roles 1+6). Registration requirement (b) is satisfied; the `tags: [org, ci]` are appropriate to the enduring roles 1+6.
**Evidence:** `../.meta.yaml:111` (`github_org:`), `:112` (`repo:`), `:113` (`path: .github_org`), `:114` (`tags: [org, ci]`).
**Confidence:** High.

### CLAIM D2.3 — The parent gitignores this repo, satisfying meta-repo discipline.
`../.gitignore:77` contains `.github_org/`, so the child repo's contents are excluded from the parent's tracked tree — correct discipline (a peer is referenced by registry, never absorbed into parent history).
**Evidence:** `../.gitignore:77` → `.github_org/`.
**Confidence:** High.

### CLAIM D2.4 — This repo is a LEAF peer (no nested `.meta.yaml`), which is correct for its role.
No `.meta.yaml` and no `.meta` exist at this repo's root. It is not (and should not be) a nested meta — it has no child peers of its own to register. Requirement satisfied by absence.
**Evidence:** `ls .meta.yaml .meta` → both "No such file or directory" at `.github_org/`.
**Confidence:** High.

### CLAIM D2.5 — All four MOVE-target peers are ALREADY declared in `../.meta.yaml`, so the extraction destinations are grounded registry entries (registration is not the blocker; population is).
`flexnetos_runner` (`../.meta.yaml:127-129`, `tags: [ops, runner]`), `flexnetos_github_app` (`:130-132`, `tags: [ops, github-app]`), `flexnetos_wiki` (`:133-135`, `tags: [docs]`), `flexnetos_brain` (`:136-138`, `tags: [docs, data]`). They are empty/unpopulated targets but exist as peers — so the registry side of requirement (e) is partially done for the operational-role moves.
**Evidence:** `../.meta.yaml:127` `flexnetos_runner:`, `:130` `flexnetos_github_app:`, `:133` `flexnetos_wiki:`, `:136` `flexnetos_brain:`.
**Confidence:** High.

### CLAIM D2.6 — The `flexnetos_secrets` MOVE target is intentionally NOT a peer — it is RETIRED into `envctl` per ADR-0007.
`../.meta.yaml:122-126` documents that `flexnetos_secrets` is RETIRED → `envctl` (which already owns vault/secretd/broker + the ProviderMint GitHub-token seam; a second store would be split-brain), and that empty-repo archival is a NEEDS-HUMAN owner decision. `envctl` is itself a declared peer (`../.meta.yaml:83-86`, `tags: [tools, env]`). So secrets has a valid peer home; the `secrets/` dir here is content awaiting extraction-to-envctl, not awaiting a new peer.
**Evidence:** `../.meta.yaml:123-125` (RETIRED note), `:83` `envctl:`.
**Confidence:** High (the routing decision); **Low** on the *full ADR-0007 rationale* — ADR-0007 is referenced but NOT on disk here (only ADR-0001 under `architecture/adr/`); to confirm the decision text a verifier must fetch it from the meta-workspace KB.

### CLAIM D2.7 — RESIDUAL NON-CONFORMANCE #1: this repo still hosts a submodules-as-children mount (`.gitmodules` + 17 committed gitlinks) — a direct violation of requirement (d).
A `.gitmodules` file exists at this repo's root (837B) mapping **7** tool submodules (`tools/{cpython,actionlint,gitleaks,trivy,node,bun,uv}`). Separately, `git ls-tree -r HEAD` shows **17** mode-`160000` gitlinks committed into the tree: the 7 `tools/*`, 4 `repos/*` (`ai-top-utility`, `fabro`, `n8n`, `paperclip`), `network/slim`, and 5 under `data/brain-data/*` (`DeepTutor`, `deepwiki-rs`, `obsidian-mind`, `my-wiki-knowledge/.claude/obsidian-second-brain`, `.../obsidian-skills`). The peer model says foreign repos are peers in `../.meta.yaml`, never gitlinks inside a child — so the entire `.gitmodules`-plus-gitlinks apparatus is non-conformant machinery that must retire.
**Evidence:** `.gitmodules` present (837B, 7 `submodule.*.path` entries via `git config --file .gitmodules --get-regexp path`); `git ls-tree -r HEAD | grep ^160000` → 17 gitlinks (paths enumerated above).
**Confidence:** High.

### CLAIM D2.8 — RESIDUAL NON-CONFORMANCE #2: this repo still physically contains the content that belongs to the (already-declared) peers — content extraction is the unfinished work, not registration.
The declared-but-unpopulated peers' content still lives here: `wiki/` (→ `flexnetos_wiki`), `runner/` (→ `flexnetos_runner`), `github-app/` (→ `flexnetos_github_app`), `data/brain-data/` (→ `flexnetos_brain`), `secrets/` (→ `envctl`). Because the destination peers exist (CLAIM D2.5) but are empty, requirement (e) is only *half* met: registered, not populated. This is the gap that D4/D6 sequence.
**Evidence:** codemap §1 dir table (`reports/codemap.md:18-22`) + §5 (`reports/codemap.md:116`, destinations declared but not populated); destination peers `../.meta.yaml:127-138`.
**Confidence:** High (directory presence); destinations-empty is **Medium** here (asserted from codemap §5, not re-verified against the remote repos' contents in this dimension — a verifier could `git ls-remote`/clone to confirm emptiness).

### CLAIM D2.9 — RESIDUAL NON-CONFORMANCE #3: the submodule *machinery* (verify/CI/scripts) is still wired and gated-on, so retiring Role 2 also shrinks the verify surface.
The repo still carries `scripts/submodule-*.sh`, `Makefile` `submodules.*` verbs, `verify.manifest`/`verify.tools` in the `make verify` gate, and the `submodule-bump.yml` + `manifest-drift.yml` workflows — all Role-2 machinery slated for RETIRE. As long as `.gitmodules`/gitlinks exist, this machinery is load-bearing; it can only be removed atomically with the gitlinks.
**Evidence:** codemap §6 (`reports/codemap.md:135,139`); `repos/MANIFEST.yaml` three-way drift (codemap §4, `reports/codemap.md:97-107`).
**Confidence:** Medium (inherited from codemap; the exact script/workflow inventory is D5's dimension — flagged as a cross-dimension hook, not independently re-verified here).

---

## Conformance scorecard

| # | Conformance requirement | Current state | Conformant? |
|---|---|---|---|
| a | Independent git repo with its own remote/history | Own remote `FlexNetOS/.github.git`; HEAD `4fefb0e` distinct from parent `5a7d5da`; toplevel = `.github_org` | **Y** (D2.1) |
| b | Registered in `../.meta.yaml` with `path:` + appropriate `tags:` | `github_org:` @ `:111`, `path: .github_org`, `tags: [org, ci]` | **Y** (D2.2) |
| c | Gitignored by the parent | `../.gitignore:77` `.github_org/` | **Y** (D2.3) |
| d | Does NOT host foreign code as submodules-as-children | `.gitmodules` (7 mapped) + **17 committed gitlinks** still in HEAD | **N** (D2.7) |
| e | Content that should be peers is itself a registered peer | Destinations declared (`flexnetos_runner/github_app/wiki/brain` + envctl) but content still physically here; population unfinished | **Partial** (D2.5 + D2.8) |
| f (corollary) | Leaf peer — no nested `.meta.yaml` | No `.meta.yaml`/`.meta` at this root | **Y** (D2.4) |

---

## Net gap (one paragraph)

The peer-**registration** side of "matching meta" is fully done: this is an independent git repo with its own remote and history, registered in `../.meta.yaml` as `github_org` with `path: .github_org` and `tags: [org, ci]`, gitignored by the parent, and correctly a leaf (no nested `.meta.yaml`) — requirements (a), (b), (c), and the leaf corollary all pass on verified evidence. The peer **content** side is the entire residual gap and it is structural, not registry: requirement (d) **fails** because the repo still carries its own `.gitmodules` (7 tool submodules) and **17 committed gitlinks** under `tools/`, `repos/`, `network/`, and `data/brain-data/` — a submodules-as-children mount the peer model forbids; and requirement (e) is only **partial** because, although the four MOVE-target peers (`flexnetos_runner`, `flexnetos_github_app`, `flexnetos_wiki`, `flexnetos_brain`) and the secrets→`envctl` home are already declared peers, their content (`runner/`, `github-app/`, `wiki/`, `data/brain-data/`, `secrets/`) still lives physically in this repo and the destinations are empty. So the unfinished work is **content extraction into the already-grounded peers + retirement of the in-tree submodule machinery** (`.gitmodules`, gitlinks, `scripts/submodule-*.sh`, the two manifest workflows, and the `verify.manifest`/`verify.tools` gate that depends on them) — i.e. shrinking the repo to roles 1+6, not registering anything new.
