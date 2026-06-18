#!/usr/bin/env bash
# Triple-verify contract test for .github/policies/ and scripts/apply-github-policies.py
#
# Stages:
#   0. Policy JSON files pass the applier's schema validation.
#   1. Policy JSON files are syntactically valid and contain expected top-level keys.
#   2. Policy applier --dry-run exits 0 and emits no ERROR lines.
#   3. If GH CLI is authenticated and has repo access, --check reports no drift.
#
# Usage: bash scripts/tests/test-github-policies.sh

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

POLICIES=(
  ".github/policies/branch-protection.json"
  ".github/policies/rulesets.json"
  ".github/policies/repo-settings.json"
)

echo "=== Stage 0: Policy JSON files pass schema validation ==="
python3 - <<'PY'
import json, sys, importlib.util

spec = importlib.util.spec_from_file_location("policy", "scripts/apply-github-policies.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

with open(".github/policies/branch-protection.json") as f:
    bp = json.load(f)
with open(".github/policies/rulesets.json") as f:
    rs = json.load(f)
with open(".github/policies/repo-settings.json") as f:
    settings = json.load(f)

errors = module.validate_all_policies(bp, rs, settings)
if errors:
    for err in errors:
        print(f"FAIL: {err}")
    sys.exit(1)
PY
echo "PASS"

echo ""
echo "=== Stage 1: Policy JSON files parse and contain expected keys ==="
for f in "${POLICIES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "FAIL: $f not found"
    exit 1
  fi
  python3 - <<PY
import json, sys
with open("$f") as fh:
    data = json.load(fh)
if "$f".endswith("branch-protection.json"):
    assert "branches" in data, "missing branches key"
elif "$f".endswith("rulesets.json"):
    assert "rulesets" in data, "missing rulesets key"
elif "$f".endswith("repo-settings.json"):
    assert "settings" in data, "missing settings key"
PY
  echo "PASS: $f"
done

echo ""
echo "=== Stage 2: Policy applier --dry-run exits 0 with no ERROR lines ==="
dry_run_output=$(python3 scripts/apply-github-policies.py --dry-run 2>&1)
if printf '%s\n' "$dry_run_output" | grep -qE '^ERROR'; then
  echo "FAIL: dry-run emitted ERROR lines"
  printf '%s\n' "$dry_run_output"
  exit 1
fi
echo "PASS"

echo ""
echo "=== Stage 3: Fleet applier registry/templates are valid and --fleet --dry-run emits no ERROR ==="
python3 - <<'PY'
import json, sys

with open(".github/policies/fleet.json") as f:
    fleet = json.load(f)

for entry in fleet.get("repos", []):
    assert "owner" in entry and "repo" in entry, f"fleet entry missing owner/repo: {entry}"
    assert "templates" in entry and isinstance(entry["templates"], list), f"fleet entry missing templates list: {entry}"
    for t in entry["templates"]:
        p = f".github/policies/templates/{t}"
        import os
        assert os.path.isdir(p), f"template directory missing: {p}"
PY
fleet_dry_run_output=$(python3 scripts/apply-fleet-policies.py --fleet --dry-run 2>&1)
if printf '%s\n' "$fleet_dry_run_output" | grep -qE '^ERROR'; then
  echo "FAIL: fleet dry-run emitted ERROR lines"
  printf '%s\n' "$fleet_dry_run_output"
  exit 1
fi
echo "PASS"

echo ""
echo "=== Stage 4: Live drift check (skipped if GH CLI cannot access repo) ==="
if ! command -v gh >/dev/null 2>&1; then
  echo "SKIP: gh CLI not installed"
elif ! gh auth status >/dev/null 2>&1; then
  echo "SKIP: gh CLI not authenticated"
elif ! gh repo view >/dev/null 2>&1; then
  echo "SKIP: current gh token cannot read this repo"
else
  check_output=$(python3 scripts/apply-github-policies.py --check 2>&1)
  if ! printf '%s\n' "$check_output" | grep -q 'No drift detected'; then
    echo "FAIL: policy drift check did not report 'No drift detected'"
    printf '%s\n' "$check_output"
    exit 1
  fi
  echo "PASS"
fi

echo ""
echo "All triple-verify stages passed."
