# architecture/icm/ — verbatim ICM ingestion

This directory is the **faithful, verbatim copy** of the FlexNetOS ICM (Infinite
Context Memory) store as ingested on **2026-06-13**. It is the raw source the
synthesized architecture map (`../map/`) is built from. Nothing here is edited by
hand — it is regenerated from ICM.

## What's here

| Path | Holds | Source command |
|---|---|---|
| `memoirs/system-architecture.ai.md` | The `system-architecture` memoir (123 concepts) in compact LLM markdown | `icm memoir export -m system-architecture -f ai` |
| `memoirs/system-architecture.graph.json` | Same memoir as a structured graph (`.concepts[]`, `.links[]`) | `icm memoir export -m system-architecture -f json` |
| `memoirs/system-architecture.dot` | Same memoir as Graphviz DOT | `icm memoir export -m system-architecture -f dot` |
| `memories/<topic>.md` | Per-topic dump of the ICM memory store (69 topics, ~312 memories) | `icm list -t <topic> -a` |
| `INDEX.md` | Lightweight concept index (names + type + preview) | derived from `graph.json` |

## Relationship to the rest of `architecture/`

```text
ICM store ──export──▶ architecture/icm/   (this dir: verbatim, machine-faithful)
                            │
                            ├─ synthesize ─▶ architecture/map/   (human-navigable subsystem maps)
                            └─ reconcile ──▶ architecture/QUESTIONS_LESSONS.md  (misalignments + answers)
```

## Refreshing

To re-ingest after ICM changes (regenerates every file here):

```bash
# from the repo root
icm memoir export -m system-architecture -f ai   > architecture/icm/memoirs/system-architecture.ai.md
icm memoir export -m system-architecture -f json > architecture/icm/memoirs/system-architecture.graph.json
icm memoir export -m system-architecture -f dot  > architecture/icm/memoirs/system-architecture.dot
icm topics | awk 'NR>2 && $1!="" {print $1}' | grep -v '^---' | while read -r t; do
  icm list -t "$t" -a > "architecture/icm/memories/$(echo "$t" | tr '/' '_').md"
done
```

## Runtime injection

`scripts/hooks/icm-architecture-inject.sh` (wired into `.claude/settings.json`
`SessionStart` + `PreCompact`) injects a **bounded** compact pack of this memoir
into every session — live via `icm` when present, else from `INDEX.md`.
