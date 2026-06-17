#!/usr/bin/env bash
# Contract test: Trivy filesystem secret scan must not report CRITICAL
# stripe-secret-token findings in data/brain-data/research repomix archives.
# Those matches are upstream test fixtures / example values, not real secrets.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

# Triple-verify contract:
# 1. trivy-secret.yaml is loaded (default path).
# 2. No CRITICAL stripe-secret-token findings are emitted.
# 3. No CRITICAL findings of any kind remain in the research repomix paths.

echo "Running Trivy secret scan with default trivy-secret.yaml..."
output=$(tools/bin/trivy fs \
  --scanners secret \
  --severity CRITICAL \
  --exit-code 0 \
  --format table \
  . 2>&1) || true

# Verify 1: config loaded
if ! printf '%s\n' "$output" | grep -q 'config_path="trivy-secret.yaml"'; then
  echo "FAIL: trivy-secret.yaml was not loaded; check path and Trivy defaults"
  printf '%s\n' "$output"
  exit 1
fi

# Verify 2: no stripe-secret-token CRITICAL findings
if printf '%s\n' "$output" | grep -E 'CRITICAL:.*stripe-secret-token' >/dev/null; then
  echo "FAIL: Trivy still reports CRITICAL stripe-secret-token findings"
  printf '%s\n' "$output"
  exit 1
fi

# Verify 3: no CRITICAL findings in research repomix archives
if printf '%s\n' "$output" | grep -E 'data/brain-data/research/.*/repomix-pack.*\.xml.*CRITICAL' >/dev/null; then
  echo "FAIL: Trivy still reports CRITICAL findings in research repomix archives"
  printf '%s\n' "$output"
  exit 1
fi

echo "PASS: Trivy secret scan has no CRITICAL false positives in research repomix archives"
