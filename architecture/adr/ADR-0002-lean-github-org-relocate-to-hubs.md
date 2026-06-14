# ADR-0002: Lean `.github_org` — relocate submodules, repos & marketplaces to hubs-by-type

**Date**: 2026-06-13
**Status**: accepted
**Deciders**: FlexNetOS (owner)
**Related**: [ADR-0001](ADR-0001-architecture-artifact-homes.md) · [VISION.md](../../VISION.md) · ADR-0006 (envctl env manager, `envctl/home/README.md`) · [migration plan](../plan/2026-06-13-github-org-strip-and-relocate-plan.md) · [QUESTIONS_LESSONS L9.5](../QUESTIONS_LESSONS.md)

## Context

`VISION.md` casts `.github_org` (the `FlexNetOS/.github` repo) as a **mega-umbrella** playing six
roles at once, one of which is "mount point for ~24 git submodules." The **actual** state (verified
2026-06-13) is far smaller and partly stale:

- **7 real git submodules, all under `tools/`** — the hermetic toolchain pins: `cpython`,
  `actionlint`, `gitleaks`, `trivy`, `node`, `bun`, `uv`.
- **`repos/` holds 4 *plain directories*** (`fabro`, `n8n`, `paperclip`, `ai-top-utility`) — not git
  repos, not submodules; `repos/MANIFEST.yaml` is effectively empty.
- **4 plugin marketplaces** wired into `.claude/settings.json`: `ecc` (real home already exists at the
  `meta/ECC` peer = `FlexNetOS/ECC`), and `karpathy-skills` / `understand-anything` /
  `claude-stack-local` whose `source.path` values point at `/home/drdave/_work/...` directories that
  **do not exist on this box** (surfaced as portability residue in `QUESTIONS_LESSONS.md` L9.5).

Meanwhile the workspace already has the right homes: **meta/envctl is the user-global env manager**
(ADR-0006), and a **typed hub family** exists and is Hub-Standard-validated —
`tool_hub`, `plugin_hub`, `mcp_hub`, `harness_hub`, `database_hub`, `flow_hub`, `hooks_hub`,
`network_hub`, `template_hub`, `vault_hub` (each `FlexNetOS/*_hub` with
`registry.json` + `registry.schema.json` + `entries/`). Overloading `.github_org` with toolchain
mounts, research dirs, and plugin marketplaces conflates the **org `.github` role** (community-health
fallback + reusable CI) with **inventory hosting**, and has accumulated stale, broken references.

## Decision

`.github_org` is reduced to the **org `.github` role only**: root + `.github/` community-health files,
the reusable CI templates (`reusable-*.yml`), and its own `scripts/`/`docs/`/`architecture/`. Everything
else **relocates to dedicated hubs by type**:

| Currently in `.github_org` | New home | How |
|---|---|---|
| `tools/{cpython,actionlint,gitleaks,trivy,node,bun,uv}` (7 submodules) | **`tool_hub`** | register as hub entries; pinned sources move under `tool_hub`; `.github_org` consumes the relocated tool binaries |
| plugin marketplace `ecc` | **`plugin_hub`** (entry → existing `meta/ECC`) | register; repoint settings via the envctl template |
| `karpathy-skills`, `understand-anything`, `claude-stack-local` | **`plugin_hub`** | source via research-before-fork, then register |
| `repos/{n8n,fabro,paperclip,ai-top-utility}` | **classified hubs** (e.g. `n8n`→`flow_hub`) | classify per type; make proper repos where needed |

Binding rules:

1. **Never-downgrade ordering** — *relocate-IN and verify in the destination hub BEFORE stripping from
   `.github_org`.* Stale/orphaned items are treated as **incomplete work to carry forward**, never
   deleted as "drift."
2. **Research-before-fork** — new upstreams (`karpathy-skills`, `understand-anything`,
   `claude-stack-local`) follow `.github_org`'s mandated clone→research→setup→fork-to-FlexNetOS→register
   ritual.
3. **Hub Standard** — every landing is registered in the destination hub's `registry.json` + `entries/`
   + README, conformant to `registry.schema.json` (Rust-native validator), so the catalog stays truthful.
4. **Portability via the envctl template** — settings/marketplace paths are repointed through the envctl
   render pass (ADR-0006), not hardcoded `/home/<user>/...`.

## Alternatives Considered

### Alternative 1: Flat meta peers (relocate everything to `meta/<repo>` + `.meta.yaml`)
- **Pros**: simplest mental model; one list.
- **Cons**: loses typed organization; a 65+-peer flat list is hard to navigate; no per-type registry/validator.
- **Why not**: the owner chose **hubs-by-type**; the hub family already provides validated, typed catalogs.

### Alternative 2: Keep `.github_org` as the mega-umbrella mount point
- **Pros**: no movement; VISION.md unchanged.
- **Cons**: keeps the org `.github` role conflated with inventory hosting; the stale `/home/...`
  marketplace + empty `repos/MANIFEST.yaml` rot persists; submodule mounts duplicate what hubs own.
- **Why not**: the overload is the problem this ADR exists to remove.

### Alternative 3: Relocate only the marketplaces now, defer `tools/*` + `repos/*`
- **Pros**: smallest first step; fixes the visible stale paths.
- **Cons**: leaves `.github_org` still overloaded; two restructurings instead of one coherent move.
- **Why not**: the owner scoped **everything → lean `.github`**.

## Consequences

### Positive
- `.github_org` regains a single, clear identity (the org `.github` repo); easier for humans + agents.
- Typed hubs give each relocated artifact a validated, discoverable home (registry ↔ entries ↔ README).
- Removes stale/broken references (non-existent `_work/repos` marketplace paths; empty `repos/MANIFEST`).
- Aligns the env/plugin story with ADR-0006 (envctl owns user-global config; hubs own typed inventory).

### Negative
- Multi-repo coordination (hubs + `.github_org` + `.meta.yaml` + settings) per relocation.
- `.github_org`'s `Makefile`/`make verify` toolchain wiring (`tools/bin/*` wrappers) must be repointed to
  the `tool_hub`-relocated tools before the `tools/*` submodules are removed.
- `VISION.md` (six roles) and `CLAUDE.md` ("mount point for ~24 submodules") must be rewritten to the lean role.

### Risks
- **Stripping before the relocation is verified** → data/function loss. *Mitigated* by the
  relocate-in-first ordering (rule 1), a `meta git snapshot` before any strip, and a per-item verify gate.
- **Tool wrappers break `make verify`** → CI red. *Mitigated* by repointing + running `make verify` green
  in `.github_org` before removing any `tools/*` submodule.
- **Losing the research dirs** (`fabro`/`paperclip`/`ai-top-utility` may be unique content) → *Mitigated*
  by classify-and-carry-forward (never delete), archive-first if a true home is unclear.
