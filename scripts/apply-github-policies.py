#!/usr/bin/env python3
"""Dry-run-first applier for FlexNetOS/.github branch protection, rulesets,
and repository settings stored as JSON policy under .github/policies/.

Usage:
    python3 scripts/apply-github-policies.py --dry-run
    python3 scripts/apply-github-policies.py --apply
    python3 scripts/apply-github-policies.py --check   # exit non-zero on drift
    python3 scripts/apply-github-policies.py --check --json
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
POLICIES_DIR = ROOT / ".github" / "policies"


def run(cmd: list[str], *, dry_run: bool = False) -> tuple[int, str, str]:
    if dry_run:
        print("[dry-run] " + " ".join(cmd))
        return 0, "", ""
    proc = subprocess.run(cmd, text=True, capture_output=True, check=False)
    return proc.returncode, proc.stdout, proc.stderr


def repo_slug() -> tuple[str, str]:
    code, out, err = run(["gh", "repo", "view", "--json", "owner,name"])
    if code != 0:
        raise RuntimeError(f"gh repo view failed: {err or out}")
    data = json.loads(out)
    return data["owner"]["login"], data["name"]


def load_json(name: str) -> dict:
    path = POLICIES_DIR / name
    return json.loads(path.read_text(encoding="utf-8"))


def validate_policy(spec: dict, kind: str) -> list[str]:
    """Return a list of validation errors for a policy spec."""
    errors: list[str] = []
    if kind == "branch-protection":
        if "branches" not in spec:
            errors.append("branch-protection.json: missing 'branches' key")
            return errors
        for branch, cfg in spec["branches"].items():
            rsc = cfg.get("required_status_checks")
            if rsc is not None:
                if not isinstance(rsc, dict):
                    errors.append(f"branch {branch}: required_status_checks must be an object")
                else:
                    if "strict" not in rsc:
                        errors.append(f"branch {branch}: required_status_checks missing 'strict'")
                    if "contexts" not in rsc or not isinstance(rsc.get("contexts"), list):
                        errors.append(f"branch {branch}: required_status_checks missing 'contexts' list")
            rpr = cfg.get("required_pull_request_reviews")
            if rpr is not None and not isinstance(rpr, dict):
                errors.append(f"branch {branch}: required_pull_request_reviews must be an object")
    elif kind == "rulesets":
        if "rulesets" not in spec:
            errors.append("rulesets.json: missing 'rulesets' key")
            return errors
        for idx, rs in enumerate(spec["rulesets"]):
            for key in ("name", "target", "enforcement", "conditions", "rules"):
                if key not in rs:
                    errors.append(f"rulesets[{idx}]: missing '{key}'")
            if "rules" in rs:
                for ridx, rule in enumerate(rs["rules"]):
                    if "type" not in rule:
                        errors.append(f"rulesets[{idx}].rules[{ridx}]: missing 'type'")
                    parameterized = {
                        "update",
                        "merge_queue",
                        "required_deployments",
                        "pull_request",
                        "required_status_checks",
                        "commit_message_pattern",
                        "commit_author_email_pattern",
                        "committer_email_pattern",
                        "branch_name_pattern",
                        "tag_name_pattern",
                        "workflows",
                        "code_scanning",
                        "copilot_code_review",
                        "file_path_restriction",
                        "max_file_path_length",
                        "file_extension_restriction",
                        "max_file_size",
                    }
                    if rule.get("type") in parameterized and "parameters" not in rule:
                        errors.append(f"rulesets[{idx}].rules[{ridx}]: rule '{rule['type']}' requires 'parameters'")
    elif kind == "repo-settings":
        if "settings" not in spec:
            errors.append("repo-settings.json: missing 'settings' key")
        if "environments" in spec and not isinstance(spec["environments"], list):
            errors.append("repo-settings.json: 'environments' must be a list")
    return errors


def validate_all_policies(bp_spec: dict, rs_spec: dict, settings_spec: dict) -> list[str]:
    errors: list[str] = []
    errors.extend(validate_policy(bp_spec, "branch-protection"))
    errors.extend(validate_policy(rs_spec, "rulesets"))
    errors.extend(validate_policy(settings_spec, "repo-settings"))
    return errors


def normalize_branch_protection(spec: dict) -> dict:
    """Return a payload suitable for the GitHub branch protection API."""
    payload: dict = {
        "required_status_checks": spec.get("required_status_checks") or None,
        "enforce_admins": spec.get("enforce_admins", False),
        "required_pull_request_reviews": spec.get("required_pull_request_reviews") or None,
        "restrictions": spec.get("restrictions") if spec.get("restrictions") is not None else None,
        "required_linear_history": spec.get("required_linear_history", False),
        "allow_force_pushes": spec.get("allow_force_pushes", False),
        "allow_deletions": spec.get("allow_deletions", False),
        "required_conversation_resolution": spec.get("required_conversation_resolution", False),
        "required_signatures": spec.get("required_signatures", False),
        "block_creations": spec.get("block_creations", False),
        "allow_fork_syncing": spec.get("allow_fork_syncing", False),
        "lock_branch": spec.get("lock_branch", False),
    }
    # The branch-protection API requires the keys "required_status_checks" and
    # "required_pull_request_reviews" to be present (null is accepted when the
    # rulesets handle those concerns). Keep "restrictions" as null as well.
    return payload


def apply_branch_protection(owner: str, repo: str, branch: str, spec: dict, *, dry_run: bool) -> bool:
    payload = normalize_branch_protection(spec)
    cmd = [
        "gh", "api",
        f"/repos/{owner}/{repo}/branches/{branch}/protection",
        "--method", "PUT",
        "--input", "-",
    ]
    if dry_run:
        print(f"[dry-run] PUT /repos/{owner}/{repo}/branches/{branch}/protection")
        print(json.dumps(payload, indent=2))
        return True
    proc = subprocess.run(cmd, input=json.dumps(payload), text=True, capture_output=True, check=False)
    if proc.returncode != 0:
        print(f"ERROR applying branch protection for {branch}: {proc.stderr}", file=sys.stderr)
        return False
    print(f"Applied branch protection for {branch}")
    return True


def list_rulesets(owner: str, repo: str) -> dict[str, int]:
    code, out, err = run(["gh", "api", f"/repos/{owner}/{repo}/rulesets"])
    if code != 0:
        print(f"WARNING: could not list rulesets: {err}", file=sys.stderr)
        return {}
    try:
        data = json.loads(out)
        return {r["name"]: r["id"] for r in data if "name" in r and "id" in r}
    except (json.JSONDecodeError, KeyError, TypeError) as exc:
        print(f"WARNING: could not parse rulesets: {exc}", file=sys.stderr)
        return {}


def apply_rulesets(owner: str, repo: str, spec: list[dict], *, dry_run: bool) -> bool:
    existing = list_rulesets(owner, repo) if not dry_run else {}
    ok = True
    for ruleset in spec:
        name = ruleset["name"]
        payload = dict(ruleset)  # include name; API requires it
        if dry_run:
            print(f"[dry-run] CREATE/UPDATE ruleset '{name}':")
            print(json.dumps(payload, indent=2))
            continue
        if name in existing:
            cmd = ["gh", "api", f"/repos/{owner}/{repo}/rulesets/{existing[name]}", "--method", "PUT", "--input", "-"]
            proc = subprocess.run(cmd, input=json.dumps(payload), text=True, capture_output=True, check=False)
            if proc.returncode != 0:
                print(f"ERROR updating ruleset {name}: {proc.stderr}", file=sys.stderr)
                ok = False
            else:
                print(f"Updated ruleset {name}")
        else:
            cmd = ["gh", "api", f"/repos/{owner}/{repo}/rulesets", "--method", "POST", "--input", "-"]
            proc = subprocess.run(cmd, input=json.dumps(payload), text=True, capture_output=True, check=False)
            if proc.returncode != 0:
                print(f"ERROR creating ruleset {name}: {proc.stderr}", file=sys.stderr)
                ok = False
            else:
                print(f"Created ruleset {name}")
    return ok


def apply_repo_settings(owner: str, repo: str, spec: dict, *, dry_run: bool) -> bool:
    settings = spec.get("settings", {})
    cmd = ["gh", "api", f"/repos/{owner}/{repo}", "--method", "PATCH", "--input", "-"]
    if dry_run:
        print("[dry-run] PATCH /repos/{owner}/{repo} settings")
        print(json.dumps(settings, indent=2))
        return True
    proc = subprocess.run(cmd, input=json.dumps(settings), text=True, capture_output=True, check=False)
    if proc.returncode != 0:
        print(f"ERROR applying repo settings: {proc.stderr}", file=sys.stderr)
        return False
    print("Applied repository settings")
    return True


def apply_environments(owner: str, repo: str, spec: list[dict], *, dry_run: bool) -> bool:
    ok = True
    for env in spec:
        name = env["name"]
        payload = {k: v for k, v in env.items() if k != "name"}
        cmd = ["gh", "api", f"/repos/{owner}/{repo}/environments/{name}", "--method", "PUT", "--input", "-"]
        if dry_run:
            print(f"[dry-run] PUT /repos/{owner}/{repo}/environments/{name}")
            print(json.dumps(payload, indent=2))
            continue
        proc = subprocess.run(cmd, input=json.dumps(payload), text=True, capture_output=True, check=False)
        if proc.returncode != 0:
            print(f"ERROR applying environment {name}: {proc.stderr}", file=sys.stderr)
            ok = False
        else:
            print(f"Applied environment {name}")
    return ok


def check_repo_settings(owner: str, repo: str, desired: dict) -> list[str]:
    drift: list[str] = []
    code, out, err = run(["gh", "api", f"/repos/{owner}/{repo}"])
    if code != 0:
        return [f"DRIFT: could not read repository settings: {err}"]
    current = json.loads(out)
    for key, value in desired.items():
        if current.get(key) != value:
            drift.append(f"DRIFT repo setting: {key} is {current.get(key)!r}, expected {value!r}")
    return drift


def check_environments(owner: str, repo: str, desired: list[dict]) -> list[str]:
    drift: list[str] = []
    desired_by_name = {e["name"]: e for e in desired}
    code, out, err = run(["gh", "api", f"/repos/{owner}/{repo}/environments"])
    existing_names = set()
    if code == 0:
        existing_names = {e["name"] for e in json.loads(out).get("environments", [])}
    else:
        return [f"DRIFT: could not list environments: {err}"]

    for name in desired_by_name:
        if name not in existing_names:
            drift.append(f"DRIFT: environment '{name}' does not exist")
            continue
        ecode, eout, eerr = run(["gh", "api", f"/repos/{owner}/{repo}/environments/{name}"])
        if ecode != 0:
            drift.append(f"DRIFT: could not read environment '{name}': {eerr}")
            continue
        current = json.loads(eout)
        desired_policy = desired_by_name[name].get("deployment_branch_policy")
        current_policy = current.get("deployment_branch_policy")
        if desired_policy and current_policy != desired_policy:
            drift.append(
                f"DRIFT environment '{name}': deployment_branch_policy is {current_policy!r}, "
                f"expected {desired_policy!r}"
            )

    for name in existing_names:
        if name not in desired_by_name:
            drift.append(f"DRIFT: unexpected environment '{name}' exists")
    return drift


def check_branch_protection(owner: str, repo: str, branch: str, desired: dict) -> list[str]:
    drift: list[str] = []
    code, out, err = run(["gh", "api", f"/repos/{owner}/{repo}/branches/{branch}/protection"])
    if code != 0:
        return [f"DRIFT: branch protection for {branch} is missing or unreadable"]
    current = json.loads(out)

    current_rsc = current.get("required_status_checks", {}) or {}
    desired_rsc = desired.get("required_status_checks")
    if desired_rsc is not None:
        current_contexts = set(
            c.get("context", c) if isinstance(c, dict) else c
            for c in current_rsc.get("contexts", [])
        )
        desired_contexts = set(desired_rsc.get("contexts", []))
        missing = desired_contexts - current_contexts
        extra = current_contexts - desired_contexts
        if missing:
            drift.append(f"DRIFT {branch}: missing required checks {sorted(missing)}")
        if extra:
            drift.append(f"DRIFT {branch}: extra required checks {sorted(extra)}")
        if current_rsc.get("strict") != desired_rsc.get("strict"):
            drift.append(
                f"DRIFT {branch}: strict is {current_rsc.get('strict')!r}, "
                f"expected {desired_rsc.get('strict')!r}"
            )

    current_rpr = current.get("required_pull_request_reviews", {}) or {}
    desired_rpr = desired.get("required_pull_request_reviews")
    if desired_rpr is not None:
        for key in ("required_approving_review_count", "dismiss_stale_reviews",
                    "require_code_owner_reviews", "require_last_push_approval"):
            if key not in desired_rpr:
                continue
            if current_rpr.get(key) != desired_rpr.get(key):
                drift.append(
                    f"DRIFT {branch}: required_pull_request_reviews.{key} is "
                    f"{current_rpr.get(key)!r}, expected {desired_rpr.get(key)!r}"
                )

    bool_fields = [
        "required_linear_history",
        "allow_force_pushes",
        "allow_deletions",
        "required_conversation_resolution",
        "required_signatures",
    ]
    for key in bool_fields:
        current_val = (current.get(key) or {}).get("enabled", False) if isinstance(current.get(key), dict) else current.get(key)
        desired_val = desired.get(key, False)
        if bool(current_val) != bool(desired_val):
            drift.append(f"DRIFT {branch}: {key} is {current_val!r}, expected {desired_val!r}")

    return drift


def fetch_ruleset(owner: str, repo: str, ruleset_id: int) -> dict | None:
    code, out, err = run(["gh", "api", f"/repos/{owner}/{repo}/rulesets/{ruleset_id}"])
    if code != 0:
        return None
    return json.loads(out)


def _ordered(obj: object) -> object:
    """Recursively sort dict keys for stable comparison."""
    if isinstance(obj, dict):
        return {k: _ordered(v) for k, v in sorted(obj.items())}
    if isinstance(obj, list):
        return [_ordered(v) for v in obj]
    return obj


def _find_rule(rules: list[dict], rule_type: str) -> dict | None:
    for rule in rules:
        if rule.get("type") == rule_type:
            return rule
    return None


def _rule_params_match(current_rule: dict, desired_rule: dict) -> bool:
    """Compare rule parameters, ignoring API-injected defaults not in desired."""
    desired_params = desired_rule.get("parameters", {})
    current_params = current_rule.get("parameters", {})
    for key, desired_value in desired_params.items():
        if key not in current_params:
            return False
        current_value = current_params[key]
        # Compare by stable JSON representation.
        if json.dumps(_ordered(current_value), sort_keys=True) != json.dumps(_ordered(desired_value), sort_keys=True):
            return False
    return True


def check_rulesets(owner: str, repo: str, desired_rulesets: list[dict]) -> list[str]:
    drift: list[str] = []
    desired_by_name = {rs["name"]: rs for rs in desired_rulesets}
    existing = list_rulesets(owner, repo)

    for name in desired_by_name:
        if name not in existing:
            drift.append(f"DRIFT: ruleset '{name}' does not exist")
            continue
        current = fetch_ruleset(owner, repo, existing[name])
        if current is None:
            drift.append(f"DRIFT: could not fetch ruleset '{name}'")
            continue
        desired = desired_by_name[name]

        for key in ("name", "target", "enforcement"):
            if current.get(key) != desired.get(key):
                drift.append(f"DRIFT: ruleset '{name}' {key} is {current.get(key)!r}, expected {desired.get(key)!r}")

        if json.dumps(_ordered(current.get("conditions")), sort_keys=True) != json.dumps(_ordered(desired.get("conditions")), sort_keys=True):
            drift.append(f"DRIFT: ruleset '{name}' conditions do not match")

        desired_rules = desired.get("rules", [])
        current_rules = current.get("rules", [])
        for desired_rule in desired_rules:
            rule_type = desired_rule["type"]
            current_rule = _find_rule(current_rules, rule_type)
            if current_rule is None:
                drift.append(f"DRIFT: ruleset '{name}' missing rule '{rule_type}'")
                continue
            if not _rule_params_match(current_rule, desired_rule):
                drift.append(f"DRIFT: ruleset '{name}' rule '{rule_type}' parameters do not match")

        desired_rule_types = {r["type"] for r in desired_rules}
        for current_rule in current_rules:
            if current_rule["type"] not in desired_rule_types:
                drift.append(f"DRIFT: ruleset '{name}' has unexpected rule '{current_rule['type']}'")

    for name in existing:
        if name not in desired_by_name:
            drift.append(f"DRIFT: unexpected ruleset '{name}' exists")

    return drift


def check_drift(owner: str, repo: str) -> list[str]:
    """Return a list of drift messages; empty list means no drift."""
    bp_spec = load_json("branch-protection.json")
    rs_spec = load_json("rulesets.json")
    settings_spec = load_json("repo-settings.json")

    drift: list[str] = []
    for branch, desired in bp_spec.get("branches", {}).items():
        drift.extend(check_branch_protection(owner, repo, branch, desired))
    drift.extend(check_rulesets(owner, repo, rs_spec.get("rulesets", [])))
    drift.extend(check_repo_settings(owner, repo, settings_spec.get("settings", {})))
    drift.extend(check_environments(owner, repo, settings_spec.get("environments", [])))
    return drift


class _Tee:
    """Capture writes while still emitting them to the original stream."""

    def __init__(self, stream):
        self.stream = stream
        self.lines: list[str] = []

    def write(self, s: str) -> int:
        self.lines.append(s)
        return self.stream.write(s)

    def flush(self) -> None:
        self.stream.flush()


def main() -> int:
    parser = argparse.ArgumentParser(description="Apply or check .github_org GitHub policies")
    parser.add_argument("--dry-run", action="store_true", help="Print actions without applying")
    parser.add_argument("--apply", action="store_true", help="Apply policies to GitHub")
    parser.add_argument("--check", action="store_true", help="Exit non-zero if live state drifts from policy")
    parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON output")
    args = parser.parse_args()

    if sum([args.dry_run, args.apply, args.check]) != 1:
        parser.error("Specify exactly one of --dry-run, --apply, --check")

    owner, repo = repo_slug()

    bp_spec = load_json("branch-protection.json")
    rs_spec = load_json("rulesets.json")
    settings_spec = load_json("repo-settings.json")
    errors = validate_all_policies(bp_spec, rs_spec, settings_spec)
    if errors:
        for err in errors:
            print(f"VALIDATION ERROR: {err}", file=sys.stderr)
        return 2

    if args.check:
        drift = check_drift(owner, repo)
        if args.json:
            print(json.dumps({"ok": not drift, "drift": drift}, indent=2))
        else:
            for msg in drift:
                print(msg)
            if not drift:
                print("No drift detected between committed policy and live GitHub state.")
        return 0 if not drift else 1

    dry_run = not args.apply
    mode = "dry-run" if dry_run else "apply"

    if args.json:
        tee = _Tee(sys.stdout)
        original_stdout = sys.stdout
        sys.stdout = tee
        try:
            ok = True
            for branch, spec in bp_spec.get("branches", {}).items():
                ok &= apply_branch_protection(owner, repo, branch, spec, dry_run=dry_run)
            ok &= apply_rulesets(owner, repo, rs_spec.get("rulesets", []), dry_run=dry_run)
            ok &= apply_repo_settings(owner, repo, settings_spec, dry_run=dry_run)
            ok &= apply_environments(owner, repo, settings_spec.get("environments", []), dry_run=dry_run)
        finally:
            sys.stdout = original_stdout
        print(json.dumps({"ok": ok, "mode": mode, "log": "".join(tee.lines).splitlines()}, indent=2))
        return 0 if ok else 1

    ok = True
    for branch, spec in bp_spec.get("branches", {}).items():
        ok &= apply_branch_protection(owner, repo, branch, spec, dry_run=dry_run)
    ok &= apply_rulesets(owner, repo, rs_spec.get("rulesets", []), dry_run=dry_run)
    ok &= apply_repo_settings(owner, repo, settings_spec, dry_run=dry_run)
    ok &= apply_environments(owner, repo, settings_spec.get("environments", []), dry_run=dry_run)

    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
