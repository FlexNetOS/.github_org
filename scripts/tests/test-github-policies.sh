#!/usr/bin/env bash
# Triple-verify contract test for .github/policies/ and scripts/apply-github-policies.py
#
# Stages:
#   0. Policy JSON files pass the applier's schema validation.
#   1. Policy JSON files are syntactically valid and contain expected top-level keys.
#   2. Policy applier --dry-run exits 0 and emits no ERROR lines.
#   3. If GH CLI is authenticated and has repo access, --check reports no drift.
#   5. Scope-aware classification: unreadable admin state => UNVERIFIED (never
#      false DRIFT, exit 0); genuine readable differences still => DRIFT.
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
echo "=== Stage 5: scope-aware drift classification (unit, no network) ==="
# Regression guard: a token that cannot READ admin-only state (the default
# Actions GITHUB_TOKEN) must NOT produce false DRIFT — unreadable state is
# classified UNVERIFIED and exits 0. Genuine, readable differences still DRIFT.
python3 - <<'PY'
import importlib.util, json, sys

spec = importlib.util.spec_from_file_location("policy", "scripts/apply-github-policies.py")
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)

OWNER, REPO = "FlexNetOS", ".github"
failures = []

# --- Case A: limited token. Simulates the default Actions GITHUB_TOKEN, which
# can READ rulesets/environments but NOT branch protection, ruleset bypass_actors,
# or the repo object's admin-only merge fields. The synthetic "live" state is
# built from the committed policy so everything that IS readable matches — the
# only differences are the parts the token cannot read, which must be UNVERIFIED.
_pol_rs = json.load(open(".github/policies/rulesets.json"))["rulesets"]
_pol_settings = json.load(open(".github/policies/repo-settings.json"))
_rs_ids = {rs["name"]: 100 + i for i, rs in enumerate(_pol_rs)}

def limited_run(cmd, *, dry_run=False):
    url = cmd[2] if len(cmd) > 2 and cmd[:2] == ["gh", "api"] else ""
    tail = url.rstrip("/")
    if "/protection" in url:
        return 1, "", "gh: Resource not accessible by integration (HTTP 403)"
    if tail.endswith("/environments"):
        envs = [{"name": e["name"]} for e in _pol_settings.get("environments", [])]
        envs += [{"name": n} for n in _pol_settings.get("external_environments", [])]
        return 0, json.dumps({"environments": envs}), ""
    if "/environments/" in url:
        name = tail.rsplit("/", 1)[-1]
        match = next((e for e in _pol_settings.get("environments", []) if e["name"] == name), {})
        return 0, json.dumps({"deployment_branch_policy": match.get("deployment_branch_policy")}), ""
    if "/rulesets/" in url:
        rid = int(tail.rsplit("/", 1)[-1])
        rs = next((r for r in _pol_rs if _rs_ids[r["name"]] == rid), {})
        live = dict(rs); live["bypass_actors"] = []  # bypass hidden from non-admin token
        return 0, json.dumps(live), ""
    if tail.endswith("/rulesets"):
        return 0, json.dumps([{"name": n, "id": i} for n, i in _rs_ids.items()]), ""
    if tail.endswith("/" + REPO) or tail.endswith("/.github"):
        return 0, json.dumps({"name": REPO}), ""  # admin-only merge fields absent
    return 0, json.dumps({}), ""

m.run = limited_run
drift, unver = m.check_drift(OWNER, REPO)
if drift:
    failures.append(f"Case A: limited token produced false DRIFT: {drift}")
if not unver:
    failures.append("Case A: limited token should report UNVERIFIED items, got none")

# --- Case B: an un-allowlisted environment is genuine, readable drift ---
def rogue_env_run(cmd, *, dry_run=False):
    url = cmd[2] if len(cmd) > 2 and cmd[:2] == ["gh", "api"] else ""
    if url.rstrip("/").endswith("/environments"):
        return 0, json.dumps({"environments": [{"name": "release"}, {"name": "copilot"}, {"name": "ROGUE"}]}), ""
    return 0, json.dumps({}), ""

m.run = rogue_env_run
d2, _ = m.check_environments(OWNER, REPO, [{"name": "release"}], ["copilot"])
if not any("ROGUE" in x for x in d2):
    failures.append(f"Case B: genuine drift (ROGUE env) not detected: {d2}")
if any("copilot" in x for x in d2):
    failures.append(f"Case B: allowlisted 'copilot' env was falsely flagged: {d2}")

# --- Case C: policy declares copilot as external ---
settings = json.load(open(".github/policies/repo-settings.json"))
if "copilot" not in settings.get("external_environments", []):
    failures.append("Case C: 'copilot' not declared in repo-settings.json external_environments")

if failures:
    for f in failures:
        print(f"FAIL: {f}")
    sys.exit(1)
print("PASS: unreadable->UNVERIFIED (no false drift), genuine drift still caught, copilot allowlisted")
PY

echo ""
echo "All triple-verify stages passed."
