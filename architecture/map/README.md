# architecture/map/ — the FlexNetOS system map (from ICM)

Human-navigable synthesis of the ICM `system-architecture` memoir (123 concepts, 218 links),
reorganized into eight subsystem maps. This is the **"identical map"** of ICM — faithful to the
stored knowledge, reorganized for reading. Raw verbatim source: [`../icm/`](../icm/). Open
contradictions + their answers: [`../QUESTIONS_LESSONS.md`](../QUESTIONS_LESSONS.md).

> **Read [`00-overview.md`](00-overview.md) first** — it gives the one-screen mental model the
> eight subsystem maps hang off of.

## The eight subsystem maps

| # | Map | Covers | Concepts |
|---|---|---|---|
| 00 | [overview](00-overview.md) | The one-screen model: planes, substrates, front door, the "not-a-pipeline" truth | — |
| 01 | [meta-control-plane](01-meta-control-plane.md) | Meta-repo, org policy, branch/CI-CD model, portability, architecture canon | 20 |
| 02 | [handoff-continuity](02-handoff-continuity.md) | `hf` Continuity Ledger Kernel, the autonomous loop, ADR-0001, session-relay | 14 |
| 03 | [envctl-kasetto](03-envctl-kasetto.md) | envctl secrets engine / OS foundation; kasetto agent provisioner; their seams | 10 |
| 04 | [weave-coordination](04-weave-coordination.md) | weave A2A mesh, lineage (mcp-broker/repowire retired), obscura | 7 |
| 05 | [ruvector-substrate](05-ruvector-substrate.md) | cognitum/ruvix/rvf/rvm/rvagent, the proven crate graph, the ruv ecosystem | 24 |
| 06 | [cognitive-codewalk](06-cognitive-codewalk.md) | The b17a–j cognitive/AI tiers + math/graph/LLM/markets/robotics stacks | 26 |
| 07 | [frontdoor-integration](07-frontdoor-integration.md) | prompt_hub/RuVocal front door; n8n, mcp-brain, rtk, icm glue | 9 |
| 08 | [gaps-seams-merge](08-gaps-seams-merge.md) | Known gaps & missing seams, hard walls, method-notes, rusty-idd merge/port model | 13 |

Plus, appended from the meta-root docs + `meta*` repo walk:

| # | Map | Covers |
|---|---|---|
| 09 | [meta-root-ruvector](09-meta-root-ruvector.md) | RUVECTOR-RUNBOOK / CRATE-LEDGER / RESEARCH / META-MAPPING-S1 → expands 05 + 06 |
| 10 | [meta-root-stack-gaps](10-meta-root-stack-gaps.md) | STACK-INTEGRATION-PLANS / GAP-REGISTER / NORTH-STAR / SESSION-HANDOFF / NEEDS-HUMAN → expands 02, 07, 08 |
| 11 | [meta-root-org-hardware](11-meta-root-org-hardware.md) | META-ORG-AUDIT/POLICY / PORTABILITY-AUDIT / ARCHITECTURE-TRUTH / COGNITUM-SEED / MIROFISH-PORT → expands 01, 03, 05, 08 |
| 12 | [meta-repos](12-meta-repos.md) | Every `meta*` repo (meta CLI, plugins, protocol, libs) walked into the architecture |

## How this was built

```text
ICM system-architecture memoir ──export──▶ architecture/icm/   (verbatim: ai.md, graph.json, dot, 69 memory topics)
        │
        ├─ 8 parallel synthesizers ─▶ map/01..08   (one subsystem each, faithful render + flag contradictions)
        ├─ meta-root docs + meta* walk ─▶ map/09..10
        └─ all contradictions + answers ─▶ ../QUESTIONS_LESSONS.md
```

## Reading rules (carried from ingestion)

- **Code is truth; prose is untrusted.** README/CLAUDE.md/ADR-narrative/knowledge-export claims are
  marketing or aspiration until proven by executable code (real dep edges, signatures, tests). When
  prose contradicts code, code wins — and it gets a Question in `QUESTIONS_LESSONS.md`.
- **The `status:` label beats the numeric confidence.** The graph's uniform `confidence: 0.5` is an
  export default; trust `status:verified`/`decided`, scrutinize `user-stated`/`provisional`.
- **The stack is not a wired pipeline.** It is loosely integrated through two substrates — the weave
  mesh and committed files on disk. Design seams against intended-but-unbuilt shapes.
