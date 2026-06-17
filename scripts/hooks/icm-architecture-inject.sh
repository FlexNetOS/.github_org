#!/usr/bin/env bash
# icm-architecture-inject.sh
# SessionStart + PreCompact hook: inject a BOUNDED pack of the ICM
# `system-architecture` memoir (the org's architecture knowledge graph) into the
# session context, so every agent starts with the architecture map in view.
#
# Design goals — portable + graceful + bounded:
#   - Uses the `icm` CLI when it is on PATH (live, COMPACT recall-context — never
#     the full ~226KB memoir export, which would flood context every session).
#   - Falls back to the committed architecture/icm/INDEX.md when `icm` is absent,
#     so the hook is safe on machines without ICM installed (never errors).
#   - Output is byte-bounded ($BUDGET) so it can never overflow the context window.
#
# Repo-relative invocation (no hardcoded home paths):
#   bash scripts/hooks/icm-architecture-inject.sh
# Stdout from a SessionStart / PreCompact hook is added to the model's context.
set -u

BUDGET="${ICM_ARCH_INJECT_BUDGET:-4000}"   # max bytes injected
MEMOIR="system-architecture"

# Resolve repo root so the committed fallback is found regardless of CWD.
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

if command -v icm >/dev/null 2>&1; then
  {
    echo "# ICM architecture memoir: ${MEMOIR}"
    icm memoir list 2>/dev/null | sed -n '1,3p'
    echo
    echo "## Critical architecture facts (compact ICM recall):"
    icm --no-embeddings recall-context \
      "system architecture meta-repo control plane handoff ruvector envctl weave prompt_hub" \
      --limit 6 2>/dev/null
    echo
    echo "Synthesized map: architecture/map/  •  raw ICM export: architecture/icm/  •  concept index: architecture/icm/INDEX.md"
  } | head -c "$BUDGET"
elif [ -f "${ROOT}/architecture/icm/INDEX.md" ]; then
  {
    echo "# ICM architecture memoir (committed fallback — icm CLI not found on PATH)"
    cat "${ROOT}/architecture/icm/INDEX.md"
  } | head -c "$BUDGET"
fi
exit 0
