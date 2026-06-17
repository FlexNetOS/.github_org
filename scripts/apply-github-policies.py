#!/usr/bin/env python3
"""Dry-run-first applier for FlexNetOS/.github branch protection, rulesets,
and repository settings stored as JSON policy under .github/policies/.

Usage:
    python3 scripts/apply-github-policies.py --dry-run
    python3 scripts/apply-github-policies.py --apply
    python3 scripts/apply-github-policies.py --check   # exit non-zero on drift
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


def normalize_branch_protection(spec: dict) -> dict:
    """Return a payload suitable for the GitHub branch protection API."""
    payload: dict = {
        "required_status_checks": spec.get("required_status_checks") or None,
        "enforce_admins": spec.get("enforce_admins", False),
        "required_pull_request_reviews": spec.get("required_pull_request_reviews") or None,
        "restrictions": spec.get("restrictions"),
        "required_linear_history": spec.get("required_linear_history", False),
        "allow_force_pushes": spec.get("allow_force_pushes", False),
        "allow_deletions": spec.get("allow_deletions", False),
        "required_conversation_resolution": spec.get("required_conversation_resolution", False),
        "required_signatures": spec.get("required_signatures", False),
        "block_creations": spec.get("block_creations", False),
        "allow_fork_syncing": spec.get("allow_fork_syncing", False),
        "lock_branch": spec.get("lock_branch", False),
    }
    # Drop None values so the API doesn't complain.
    return {k: v for k, v in payload.items() if v is not None}


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
    code, out, err = run(["gh", "api", f"/repos/{owner}/{repo}/rulesets", "--jq", r".[] | \"\(.name)\t\(.id)\""])
    if code != 0:
        print(f"WARNING: could not list rulesets: {err}", file=sys.stderr)
        return {}
    result: dict[str, int] = {}
    for line in out.strip().splitlines():
        if "\t" in line:
            name, rid = line.split("\t", 1)
            result[name] = int(rid)
    return result


def apply_rulesets(owner: str, repo: str, spec: list[dict], *, dry_run: bool) -> bool:
    existing = list_rulesets(owner, repo) if not dry_run else {}
    ok = True
    for ruleset in spec:
        name = ruleset["name"]
        payload = {k: v for k, v in ruleset.items() if k != "name"}
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
    flags = []
    for key, value in settings.items():
        flags.extend(["-f", f"{key}={value}"])
    cmd = ["gh", "api", f"/repos/{owner}/{repo}", "--method", "PATCH", *flags]
    if dry_run:
        print("[dry-run] PATCH /repos/{owner}/{repo} settings")
        print("  " + "\n  ".join(f"{k}={v}" for k, v in settings.items()))
        return True
    code, out, err = run(cmd)
    if code != 0:
        print(f"ERROR applying repo settings: {err}", file=sys.stderr)
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


def check_drift(owner: str, repo: str) -> bool:
    """Return True if current GitHub state matches committed policy."""
    bp_spec = load_json("branch-protection.json")
    rs_spec = load_json("rulesets.json")
    rs_names = {r["name"] for r in rs_spec.get("rulesets", [])}
    existing = list_rulesets(owner, repo)
    drift = False

    for branch, desired in bp_spec.get("branches", {}).items():
        code, out, err = run(["gh", "api", f"/repos/{owner}/{repo}/branches/{branch}/protection"])
        if code != 0:
            print(f"DRIFT: branch protection for {branch} is missing or unreadable")
            drift = True
            continue
        current = json.loads(out)
        current_contexts = set(
            c.get("context", c) if isinstance(c, dict) else c
            for c in (current.get("required_status_checks", {}) or {}).get("contexts", [])
        )
        desired_contexts = set(desired.get("required_status_checks", {}).get("contexts", []))
        missing = desired_contexts - current_contexts
        extra = current_contexts - desired_contexts
        if missing:
            print(f"DRIFT {branch}: missing required checks {sorted(missing)}")
            drift = True
        if extra:
            print(f"DRIFT {branch}: extra required checks {sorted(extra)}")
            drift = True

    for name in rs_names:
        if name not in existing:
            print(f"DRIFT: ruleset '{name}' does not exist")
            drift = True
    for name in existing:
        if name not in rs_names:
            print(f"DRIFT: unexpected ruleset '{name}' exists")
            drift = True

    if not drift:
        print("No drift detected between committed policy and live GitHub state.")
    return not drift


def main() -> int:
    parser = argparse.ArgumentParser(description="Apply or check .github_org GitHub policies")
    parser.add_argument("--dry-run", action="store_true", help="Print actions without applying")
    parser.add_argument("--apply", action="store_true", help="Apply policies to GitHub")
    parser.add_argument("--check", action="store_true", help="Exit non-zero if live state drifts from policy")
    args = parser.parse_args()

    if sum([args.dry_run, args.apply, args.check]) != 1:
        parser.error("Specify exactly one of --dry-run, --apply, --check")

    owner, repo = repo_slug()

    if args.check:
        return 0 if check_drift(owner, repo) else 1

    dry_run = not args.apply
    bp_spec = load_json("branch-protection.json")
    rs_spec = load_json("rulesets.json")
    settings_spec = load_json("repo-settings.json")

    ok = True
    for branch, spec in bp_spec.get("branches", {}).items():
        ok &= apply_branch_protection(owner, repo, branch, spec, dry_run=dry_run)
    ok &= apply_rulesets(owner, repo, rs_spec.get("rulesets", []), dry_run=dry_run)
    ok &= apply_repo_settings(owner, repo, settings_spec, dry_run=dry_run)
    ok &= apply_environments(owner, repo, settings_spec.get("environments", []), dry_run=dry_run)

    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
