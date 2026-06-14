# architecture/ — FlexNetOS umbrella design framework

Single common root for the umbrella's design-time artifacts: **plans, PRDs, ADRs,
and specs**. Artifacts are produced by existing skills (no bespoke templates) and
routed here by the **Architecture artifacts** block in `CLAUDE.md` / `AGENTS.md`.

## Lifecycle

```text
 PRD ──forces──▶ ADR(s) ──informs──▶ OpenSpec change ──feeds──▶ plan ──▶ implement ──▶ archive
 why / what      decisions           the how + tasks            steps               spec = truth
```

Early stages are skippable for small changes. For OpenSpec-driven work the change's
own `tasks.md` is the plan; `plan/` is for cross-cutting or non-OpenSpec plans.

## Layout

| Path | Holds | Produced by |
|---|---|---|
| `prd/` | `PRD-NNNN-<slug>.md` | `ecc:plan-prd`, `ecc:prp-prd` |
| `adr/` | `ADR-NNNN-<slug>.md` (Nygard/MADR) | `ecc:architecture-decision-records` |
| `plan/` | `YYYY-MM-DD-<slug>-plan.md` | `writing-plans`, `oh-my-claudecode:plan` |
| `openspec/` | the "spec" stage — OpenSpec OPSX engine (`specs/`, `changes/`) | `ccg:spec-research` → `spec-plan` → `spec-impl` |
| `icm/` | **Verbatim ICM ingestion** — `system-architecture` memoir exports + 69 memory topics | `icm memoir export` / `icm list` (see [`icm/README.md`](icm/README.md)) |
| `map/` | **The system map** synthesized from `icm/` (00–10, one subsystem each) | ingestion synthesis (see [`map/README.md`](map/README.md)) |
| `QUESTIONS_LESSONS.md` | **Reconciliation ledger** — contradictions found during ingestion + their answers | this ingestion + the `meta*` repo walk |

> `architecture/spec` -> `openspec/`. The spec stage is the OpenSpec engine; the
> folder is named `openspec/` because the OpenSpec CLI resolves that literal name.
> Run `openspec`/`opsx` from `architecture/`.

## Routing (the override)

These skills default elsewhere; in this repo they route into `architecture/`:

| Stage | Skill built-in default | Routed to |
|---|---|---|
| PRD | `.claude/prds/` or `.claude/PRPs/prds/` | `architecture/prd/` |
| ADR | `docs/adr/` | `architecture/adr/` |
| Plan | `docs/superpowers/plans/` | `architecture/plan/` |
| Spec | OpenSpec `openspec/` at CWD | `architecture/openspec/` (run from `architecture/`) |

## Conventions

- PRD/ADR numbering is 4-digit sequential; **this README registry is the source of
  truth** for the next number (avoids collisions across concurrent sessions).
- ADRs are immutable once `accepted`; supersede via a new ADR, never rewrite.
- Cross-link related artifacts with relative markdown links.
- Every fenced code block in tracked `architecture/**/*.md` must be language-tagged
  and closed (`make verify.markdown`).
- `architecture/.claude/` (OpenSpec init tooling) is git-ignored — not committed.

## PRD registry

| PRD | Title | Status | Date |
|---|---|---|---|
| [PRD-0001](prd/PRD-0001-architecture-framework.md) | Architecture & Planning Artifact Framework | Active | 2026-05-29 |

## ADR registry

| ADR | Title | Status | Date |
|---|---|---|---|
| [ADR-0001](adr/ADR-0001-architecture-artifact-homes.md) | Single `architecture/` root for design artifacts | accepted | 2026-05-29 |
| [ADR-0002](adr/ADR-0002-lean-github-org-relocate-to-hubs.md) | Lean `.github_org` — relocate submodules, repos & marketplaces to hubs-by-type | accepted | 2026-06-13 |
| [ADR-0003](adr/ADR-0003-dev-git-workflow-policy.md) | Development & Git Workflow Policy (trunk `develop`, protected mirror `main`) | accepted | 2026-06-14 |

## Submodule adoption (documented; rollout deferred)

| Lane | Convention |
|---|---|
| Umbrella (this repo) | `architecture/` holds cross-cutting / org-level artifacts. |
| `repos/owned/<x>` | Same `architecture/` shape at the submodule root. `lifeos/openspec/` is the local precedent. |
| `repos/forked/<x>` | FlexNetOS artifacts on the `develop` branch under `architecture/`; never on upstream-tracking `main`/`master`. |
| `repos/external/<x>` | None — read-only references carry no artifacts. |

## ICM-ingested system map (`icm/` → `map/` → `QUESTIONS_LESSONS.md`)

Alongside the PRD/ADR/spec/plan lifecycle, this root carries a **descriptive map of the system as
it actually is**, ingested from ICM (Infinite Context Memory) on 2026-06-13:

- [`icm/`](icm/) is the **verbatim** ICM dump (the `system-architecture` memoir in ai/json/dot +
  69 memory-topic files). Machine-faithful; regenerated, never hand-edited.
- [`map/`](map/README.md) is the **human-navigable synthesis** — start at
  [`map/00-overview.md`](map/00-overview.md), then eight subsystem maps (01–08) + the meta-root /
  `meta*` walk (09–10).
- [`QUESTIONS_LESSONS.md`](QUESTIONS_LESSONS.md) is the **reconciliation ledger**: §1 every
  contradiction/ambiguity found, §2 the confirmed truths + the answers (resolved by searching the
  code, never by asking the owner).

A bounded compact pack of the memoir is injected into every session via
`scripts/hooks/icm-architecture-inject.sh` (wired into `.claude/settings.json` `SessionStart` +
`PreCompact`; live `icm` with a committed `icm/INDEX.md` fallback).

## Related existing docs

- [`../docs/directory-layout.md`](../docs/directory-layout.md) — repo-wide layout (Model B submodules).
- [`../docs/lifeos-system-architecture.md`](../docs/lifeos-system-architecture.md) — lifeos subsystem architecture.
- [`../docs/submodule-vision.md`](../docs/submodule-vision.md) — why the submodule structure.
- [`../VISION.md`](../VISION.md) — the six roles of this umbrella.
