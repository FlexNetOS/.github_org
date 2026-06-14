# Plan — strip `.github_org` to lean, relocate everything to hubs-by-type

**Date**: 2026-06-13 · **Owner**: FlexNetOS · **Decision**: [ADR-0002](../adr/ADR-0002-lean-github-org-relocate-to-hubs.md)
**Invariant**: never-downgrade — **relocate-IN + verify BEFORE strip**; carry stale work forward, never delete as drift.

## End state

`.github_org` = the org `.github` repo only: community-health files (`CODE_OF_CONDUCT`, `CONTRIBUTING`,
`SECURITY`, `SUPPORT`, `FUNDING`, issue/PR templates), the reusable CI templates
(`.github/workflows/reusable-*.yml`), and its own `scripts/`/`docs/`/`architecture/`. No `tools/*`
submodules, no `repos/*` dirs, no plugin marketplaces mounted here.

Everything else lands in typed hubs: **`tool_hub`** (toolchain pins), **`plugin_hub`** (marketplaces),
**classified hubs** (the `repos/*` dirs), each registered per the Hub Standard.

## Relocation map (verified inventory, 2026-06-13)

| Item | Kind | Current | Destination | Status |
|---|---|---|---|---|
| `cpython` `actionlint` `gitleaks` `trivy` `node` `bun` `uv` | 7 git submodules | `.github_org/tools/*` | `tool_hub` | to relocate |
| `ecc` | marketplace | settings → `/home/drdave/_work/...` (missing) | `plugin_hub` (**already registered**: `entries/ecc.md`) → `meta/ECC` | **repoint settings only** |
| `karpathy-skills` | marketplace (upstream) | settings → missing | `plugin_hub` (after research-before-fork) | to source |
| `understand-anything` | marketplace (upstream) | settings → missing | `plugin_hub` (after research-before-fork) | to source |
| `claude-stack-local` | marketplace (local) | settings → missing | `plugin_hub` (or retire if defunct) | to investigate |
| `n8n` `fabro` `paperclip` `ai-top-utility` | **empty stub dirs** | `.github_org/repos/*` | n/a — nothing to move | **remove stubs** (Phase 3 trivial) |

> **De-risking findings (2026-06-13 reads):** `plugin_hub/registry.json` already lists `ecc` +
> `oh-my-claudecode` + `claude-plugins` (`entries/*.md`), so the marketplace home largely exists —
> only `karpathy-skills` / `understand-anything` / `claude-stack-local` are genuinely new. The four
> `repos/*` dirs are **empty** (4 KB each) → no content to carry forward; Phase 3 collapses to removing
> empty stubs. `tool_hub` registers each tool as a **catalog entry** (`tools[]` with `repo`/`hosting`/
> `workspaceMember`/`forked`, e.g. `entries/envctl.md`) pointing at a peer/pinned source — **not** as a
> submodule-of-hub; the 7 `tools/*` pins relocate as `hosting: "pinned"` (or "vendored") entries.

## FULL submodule inventory — discovered 2026-06-13 (supersedes the partial view above)

`.github_org` has **two disjoint submodule worlds that have drifted apart**:

**(1) The authoritative intent — `repos/MANIFEST.yaml` (29 entries + `network/slim`),** at
`repos/{owned,forked,external}/<name>` paths, each with `url` + `branch` + `groups:` + `toolchain:`
metadata (good for hub classification). These are **intended** submodules, **not materialized** (no
gitlinks in the index). Examples: `repos/owned/ruvector`, `repos/owned/ruOS`,
`repos/owned/understand-anything`, `repos/forked/n8n`, `repos/forked/everything-claude-code`
(NEW—fork required), `repos/external/vaultwarden`, `repos/external/andrej-karpathy-skills`, …

**(2) The actual index — 10 gitlinks, 9 of them ORPHANED** (in the git index but **not** in
`MANIFEST.yaml`, often at stale flat paths). Strip would lose these pinned SHAs, so they are recorded
here (never-downgrade):

| Orphan gitlink (index path) | Pinned SHA | In MANIFEST? | Likely hub |
|---|---|---|---|
| `data/brain-data/DeepTutor` | `6153d8c0` | no | (research/wiki) |
| `data/brain-data/deepwiki-rs` | `6bd83afa` | no | (research/wiki) |
| `data/brain-data/my-wiki-knowledge/.claude/obsidian-second-brain` | `23a0ed29` | no | (research/wiki) |
| `data/brain-data/my-wiki-knowledge/.claude/obsidian-skills` | `553ef99a` | no | (research/wiki) |
| `data/brain-data/obsidian-mind` | `92ce75d0` | no | (research/wiki) |
| `network/slim` | `c4ffbea1` | **yes** (`FlexNetOS/slim`) | `network_hub` |
| `repos/ai-top-utility` | `1d19b98e` | no | ? (classify) |
| `repos/fabro` | `3634048a` | no | ? (classify) |
| `repos/n8n` | `25a836df` | no (MANIFEST has `repos/forked/n8n`) | `flow_hub` |
| `repos/paperclip` | `be034716` | no | ? (classify) |

**Implication:** the move is not a clean lift — it is a **reconciliation** of (intended MANIFEST) vs
(stale orphan gitlinks) vs (the new hubs-by-type model). The `tools/*` slice (7 pins → `tool_hub`,
DONE + verified) was the clean part. The remaining ~10 gitlinks + 29 MANIFEST repos need
classification, the orphans need their SHAs preserved on relocation, and the `NEW — fork required`
entries need the research-before-fork ritual (outward).

### Decisions needed before the bulk strip
- **Classification** of `repos/{fabro,paperclip,ai-top-utility}` (unknown) and the `data/brain-data/*`
  wiki/research submodules → which hubs?
- **Drift reconciliation**: are the stale flat orphans (`repos/n8n`, …) superseded by the MANIFEST
  `repos/forked/*` intent, or independent? (likely superseded — relocate the MANIFEST version, drop the stale path).
- **Scope of "all submodules"**: just the 10 materialized orphan gitlinks now, or also materialize +
  relocate the 29 MANIFEST-intended repos?

## Phases (each phase ends green; strip only after verify)

### Phase 0 — Safety net
- `meta git snapshot create pre-github-org-strip` (workspace-wide rollback point).
- Confirm `make verify` is green in `.github_org` **before** touching anything (baseline).

### Phase 1 — Marketplaces → `plugin_hub` (additive, lowest risk) — task #7
1. `ecc`: add a `plugin_hub` entry pointing at `meta/ECC` (`FlexNetOS/ECC`); validate the hub.
2. `karpathy-skills`, `understand-anything`: run the clone-setup ritual (`make research.pack`, dossier),
   fork to `FlexNetOS/`, register in `plugin_hub`.
3. `claude-stack-local`: locate the source; if it exists, register; if truly defunct, record the decision
   (carry-forward note) before removing the dead settings entry.
4. Repoint `.claude/settings.json` marketplaces through the **envctl template** (ADR-0006) to the new
   homes — no hardcoded `/home/<user>/...`.
5. **Verify**: plugins load from the new homes; `plugin_hub` validator green. THEN remove the stale
   `.github_org` settings marketplace entries.

### Phase 2 — `tools/*` → `tool_hub` (repoint CI before strip) — task #8
1. Relocate/register the 7 pinned tool submodules under `tool_hub` (entries + pinned commits preserved).
2. Repoint `.github_org`'s `Makefile` / `tools/bin/*` wrappers / `make verify.*` to the `tool_hub` tools.
3. **Verify**: `make verify` (actionlint, markdown, manifest, tool-assets) green in `.github_org` against
   the relocated tools. THEN `git submodule deinit` + remove the 7 `tools/*` from `.gitmodules`.

### Phase 3 — `repos/*` dirs → classified hubs — task #9
1. Classify each (`n8n`→`flow_hub`; `fabro`/`paperclip`/`ai-top-utility`→inspect contents, pick hub).
2. Make each a proper repo where it should be one (research-before-fork); else carry content into the
   target hub's `entries/`/docs. **Archive-first** if a home is genuinely unclear.
3. **Verify** content present in the new home. THEN remove `.github_org/repos/*` (+ the empty
   `repos/MANIFEST.yaml` / `repos/README.md` once nothing references them).

### Phase 4 — Make `.github_org` lean + update docs — task #10 (DESTRUCTIVE, gated)
1. Only after Phases 1–3 verified: confirm no dangling refs (`manifest-drift`, `make verify`).
2. Rewrite `VISION.md` (drop the "mount point for ~24 submodules" role) and `CLAUDE.md` (remove submodule
   workflows; describe the lean org-`.github` role + pointers to the hubs).
3. Update `.meta.yaml` / `.gitignore` / `repos/MANIFEST.yaml` references as needed.
4. **Verify**: `make verify` green; `manifest-drift` clean; commit + PR.

## Rollback

`meta git snapshot restore pre-github-org-strip`. Because every phase relocates-in before stripping, a
failure mid-phase leaves the source intact in `.github_org` until its destination is proven.

## Open items

- ~~Classification of `fabro` / `paperclip` / `ai-top-utility`~~ → **resolved: empty stubs, no
  classification needed; remove in Phase 3.**
- ~~`tool_hub` model (submodule vs entry)~~ → **resolved: entry-pointing-at-source** (`tools[]` catalog).
- `claude-stack-local` provenance (live local marketplace, or defunct?) — investigate in Phase 1.
- `karpathy-skills` / `understand-anything` upstream identities to fork (research-before-fork dossiers).

## Status / gate

Planning (Phase −1) complete and committed. **Phases 1–4 are NOT yet executed.** Phase 1+ involves
outward actions (forking `karpathy-skills` / `understand-anything` into `FlexNetOS/`) and edits across
`plugin_hub` / `tool_hub` / `.meta.yaml` / settings — awaiting the go-ahead to begin. Phase 0 (snapshot
+ baseline `make verify`) can run immediately as the safety net.
