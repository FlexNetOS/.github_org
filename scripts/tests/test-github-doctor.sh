#!/usr/bin/env bash
# Triple-verify contract test for scripts/github-doctor.py
#
# Stages:
#   1. doctor check output contains "Renovate config" OK
#   2. doctor check output does NOT contain "Dependabot config" MISSING
#   3. offline `make github.doctor` exits 0 and reports Renovate OK
#
# Usage: bash scripts/tests/test-github-doctor.sh

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

doctor_output=$(python3 scripts/github-doctor.py --offline 2>&1)

echo "=== Stage 1: Renovate config must be present and OK ==="
if ! printf '%s\n' "$doctor_output" | grep -E 'Renovate config' | grep -q 'OK'; then
  echo "FAIL: Renovate config not reported OK"
  printf '%s\n' "$doctor_output"
  exit 1
fi
echo "PASS"

echo "=== Stage 2: Dependabot config must NOT be reported MISSING ==="
if printf '%s\n' "$doctor_output" | grep -qE 'Dependabot config.*MISSING'; then
  echo "FAIL: Dependabot config still reported MISSING"
  printf '%s\n' "$doctor_output"
  exit 1
fi
echo "PASS"

echo "=== Stage 3: offline make github.doctor exits 0 ==="
make github.doctor OFFLINE=1 2>&1 | tee /tmp/github-doctor-offline.log | tail -20
if ! grep 'Renovate config' /tmp/github-doctor-offline.log | grep -q 'OK'; then
  echo "FAIL: make github.doctor OFFLINE=1 does not report Renovate OK"
  exit 1
fi
echo "PASS"

echo ""
echo "All triple-verify stages passed."
