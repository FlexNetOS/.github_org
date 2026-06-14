# 00 — FlexNetOS architecture: the one-screen model

This is the mental model the eight subsystem maps hang off of. It is the **ICM-stored** view of
the estate as of **2026-06-13**. Faithful source: [`../icm/`](../icm/). Contradictions + answers:
[`../QUESTIONS_LESSONS.md`](../QUESTIONS_LESSONS.md).

## The single most important fact

**FlexNetOS is NOT a wired pipeline.** It is ~60 independent `FlexNetOS/` git repos (a *meta-repo*,
not a monorepo) being built **simultaneously, in parallel, none yet finished**. Nothing calls
`prompt_hub` / `rusty-idd` / `kasetto` / `weave` directly in code. Integration happens through
exactly **two substrates**:

1. **the weave mesh** — the only live cross-agent coordination channel (SQLite-as-broker), and
2. **committed files on disk** — the witnessed `.handoff` ledger + rendered packets.

The one live *code* edge between major subsystems is `handoff/ledger → rvf-crypto` (the witness
chain). Everything else integrates by becoming a weave peer or by reading committed state. Multiple
"front doors" and competing task stores are **artifacts of unfinished concurrent construction**, not
a designed federation — design seams against the intended-but-unbuilt shapes.

## The planes (top to bottom)

```text
        ┌─────────────────────────────────────────────────────────────────┐
 FRONT  │  RuVocal (human UI, HF Chat-UI fork on pgvector=ruvector-postgres)│  map 07
 DOOR   │  prompt_hub (canonical intent-minting intake, /vibe)   [not yet  │
        │  CLI / n8n / meta doors = thin shims to prompt_hub      live]    │
        ├─────────────────────────────────────────────────────────────────┤
 CONTROL│  meta-repo control plane: meta CLI + loop_lib, org policy v2,    │  map 01
 PLANE  │  ADR-0001 branch/CI-CD, portability (envctl as box-materializer) │
        ├─────────────────────────────────────────────────────────────────┤
 CONTI- │  hf Continuity Ledger Kernel (FlexNetOS/handoff): witnessed      │  map 02
 NUITY  │  ledger, claim leases, fail-closed GitHub-native auto-merge      │
        │  ── coordinated over ──▶  weave A2A mesh (mcp-broker/repowire    │  map 04
        │                           retired; obscura ready-but-unwired)    │
        ├─────────────────────────────────────────────────────────────────┤
 SECRETS│  envctl (deepest layer): pure-Rust 8-crate secrets engine +     │  map 03
 / OS    │  default-deny broker (the token gate) + kasetto agent-env       │
        │  provisioner (config-time, lock-file interface)                  │
        ├─────────────────────────────────────────────────────────────────┤
 COMPUTE│  RuVector substrate: cognitum (hardware) / ruvix (vector OS) /   │  map 05/06
 SUBSTR. │  rvf (self-bootstrapping container) / rvm (hypervisor) /        │
        │  rvagent + ruflo (parallel agent front-ends), ~314 crates       │
        └─────────────────────────────────────────────────────────────────┘
```

## The five subsystems you must not conflate

- **envctl ≠ kasetto.** envctl is the *runtime* secrets engine + broker (holds the key, the token
  gate); kasetto is a *config-time* agent-env provisioner (writes `.claude`/`.codex` from a lock
  file). Decision ADR-0001 unifies kasetto **into** envctl as `crates/agent-env`, no downgrade.
- **weave ≠ rvAgent A2A.** weave is the meta-local coordination mesh; `rvagent-a2a` is a parallel
  A2A substrate on the RuVector side. They are not bridged — `hf` is the only junction.
- **cognitum (RuVector hardware) ≠ the envctl USB secret key.** The Cognitum Seed needs no secret
  key; the envctl key-on-USB is a different physical factor. Do not conflate.
- **prompt_hub ≠ hf.** prompt_hub mints intent at the front door; `hf` runs the witnessed loop.
  Neither exposes an MCP server yet; the `SwarmBundle → handoff.task.v1` seam is validated-in-spike,
  not in production.
- **Rust is truth, TS is legacy.** Every TS unit (claude-flow lineage) has a Rust-native
  replacement crate; prefer the Rust crate when mapping into meta.

## The autonomy loop (how work actually moves)

```text
intent ─▶ prompt_hub (mint handoff.task.v1)        [seam HFTASK-0003/0019: NOT yet built]
       ─▶ hf claim (weave lease handoff:claim:<id>) ─▶ work in a fresh worktree
       ─▶ hf checkpoint (witnessed ledger events)
       ─▶ ONE squash PR into trunk ─▶ GitHub-native fail-closed auto-merge on required checks
       ─▶ envctl broker::decide releases the token (default-deny; the AI gatekeeper only advises)
       ─▶ post-merge ff develop + recycle worktree + hf handoff (renders the next packet)
```

The agent **never holds the merge token** (gh-aw separation-of-privilege); the branch-protected
required check is the sole merge authority; a RED check is a hard wall → NEEDS-HUMAN.

## Source-of-truth hierarchy (locked 2026-06-09)

```text
Git HEAD / worktree / diffs
  > .handoff/ledger.db  (rusqlite + rvf-crypto witness chain)
    > tasks/*.task.yaml
      > decisions/adr.md
        > active.md
          > packets/latest.md   (rendered, non-authoritative)
```

weave Jobs are a **coordination view**, never the crowned source of truth.

## Where to go next

- The detail lives in the eight subsystem maps ([01](01-meta-control-plane.md)–[08](08-gaps-seams-merge.md)).
- Everything uncertain or contradictory is logged in
  [`../QUESTIONS_LESSONS.md`](../QUESTIONS_LESSONS.md) with its answer (when found).
