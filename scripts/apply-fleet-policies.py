#!/usr/bin/env python3
"""Fleet policy applier for FlexNetOS meta repos.

Reads policy templates from .github/policies/templates/ and applies them to one
or more repos. This is intentionally standalone from scripts/apply-github-policies.py
(which governs FlexNetOS/.github itself) until both can be merged.

Usage:
    python3 scripts/apply-fleet-policies.py --owner FlexNetOS --repo meta_core --template rust-canon --dry-run
    python3 scripts/apply-fleet-policies.py --owner FlexNetOS --repo meta_core --template rust-canon --apply
    python3 scripts/apply-fleet-policies.py --fleet --dry-run
    python3 scripts/apply-fleet-policies.py --fleet --apply
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TEMPLATES_DIR = ROOT / ".github" / "policies" / "templates"
FLEET_REGISTRY = ROOT / ".github" / "policies" / "fleet.json"


def run(cmd: list[str], *, dry_run: bool = False) -> tuple[int, str, str]:
    if dry_run:
        print("[dry-run] " + " ".join(cmd))
        return 0, "", ""
    proc = subprocess.run(cmd, text=True, capture_output=True, check=False)
    return proc.returncode, proc.stdout, proc.stderr


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def normalize_branch_protection(spec: dict) -> dict:
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
    if payload["required_status_checks"] is None:
        del payload["required_status_checks"]
    if payload["required_pull_request_reviews"] is None:
        del payload["required_pull_request_reviews"]
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
    print(f"Applied branch protection for {owner}/{repo}@{branch}")
    return True


def list_rulesets(owner: str, repo: str) -> dict[str, int]:
    code, out, err = run(["gh", "api", f"/repos/{owner}/{repo}/rulesets"])
    if code != 0:
        print(f"WARNING: could not list rulesets for {owner}/{repo}: {err}", file=sys.stderr)
        return {}
    try:
        return {r["name"]: r["id"] for r in json.loads(out) if "name" in r and "id" in r}
    except (json.JSONDecodeError, KeyError, TypeError) as exc:
        print(f"WARNING: could not parse rulesets for {owner}/{repo}: {exc}", file=sys.stderr)
        return {}


def apply_rulesets(owner: str, repo: str, spec: list[dict], *, dry_run: bool) -> bool:
    existing = list_rulesets(owner, repo) if not dry_run else {}
    ok = True
    for ruleset in spec:
        name = ruleset["name"]
        payload = dict(ruleset)
        if dry_run:
            print(f"[dry-run] CREATE/UPDATE ruleset '{name}' for {owner}/{repo}:")
            print(json.dumps(payload, indent=2))
            continue
        if name in existing:
            cmd = ["gh", "api", f"/repos/{owner}/{repo}/rulesets/{existing[name]}", "--method", "PUT", "--input", "-"]
            proc = subprocess.run(cmd, input=json.dumps(payload), text=True, capture_output=True, check=False)
            if proc.returncode != 0:
                print(f"ERROR updating ruleset {name} for {owner}/{repo}: {proc.stderr}", file=sys.stderr)
                ok = False
            else:
                print(f"Updated ruleset {name} for {owner}/{repo}")
        else:
            cmd = ["gh", "api", f"/repos/{owner}/{repo}/rulesets", "--method", "POST", "--input", "-"]
            proc = subprocess.run(cmd, input=json.dumps(payload), text=True, capture_output=True, check=False)
            if proc.returncode != 0:
                print(f"ERROR creating ruleset {name} for {owner}/{repo}: {proc.stderr}", file=sys.stderr)
                ok = False
            else:
                print(f"Created ruleset {name} for {owner}/{repo}")
    return ok


def apply_repo_settings(owner: str, repo: str, spec: dict, *, dry_run: bool) -> bool:
    settings = spec.get("settings", {})
    cmd = ["gh", "api", f"/repos/{owner}/{repo}", "--method", "PATCH", "--input", "-"]
    if dry_run:
        print(f"[dry-run] PATCH /repos/{owner}/{repo} settings")
        print(json.dumps(settings, indent=2))
        return True
    proc = subprocess.run(cmd, input=json.dumps(settings), text=True, capture_output=True, check=False)
    if proc.returncode != 0:
        print(f"ERROR applying repo settings for {owner}/{repo}: {proc.stderr}", file=sys.stderr)
        return False
    print(f"Applied repository settings for {owner}/{repo}")
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
            print(f"ERROR applying environment {name} for {owner}/{repo}: {proc.stderr}", file=sys.stderr)
            ok = False
        else:
            print(f"Applied environment {name} for {owner}/{repo}")
    return ok


def apply_template(owner: str, repo: str, template_dir: Path, *, dry_run: bool) -> bool:
    print(f"\n>>> Applying template '{template_dir.name}' to {owner}/{repo}")
    ok = True
    bp_path = template_dir / "branch-protection.json"
    rs_path = template_dir / "rulesets.json"
    settings_path = template_dir / "repo-settings.json"

    if bp_path.exists():
        bp_spec = load_json(bp_path)
        for branch, spec in bp_spec.get("branches", {}).items():
            ok &= apply_branch_protection(owner, repo, branch, spec, dry_run=dry_run)

    if rs_path.exists():
        rs_spec = load_json(rs_path)
        ok &= apply_rulesets(owner, repo, rs_spec.get("rulesets", []), dry_run=dry_run)

    if settings_path.exists():
        settings_spec = load_json(settings_path)
        ok &= apply_repo_settings(owner, repo, settings_spec, dry_run=dry_run)
        ok &= apply_environments(owner, repo, settings_spec.get("environments", []), dry_run=dry_run)

    return ok


def template_dir(name: str) -> Path:
    path = TEMPLATES_DIR / name
    if not path.is_dir():
        raise SystemExit(f"Template not found: {path}")
    return path


def main() -> int:
    parser = argparse.ArgumentParser(description="Apply fleet policy templates to FlexNetOS repos")
    parser.add_argument("--owner", default="FlexNetOS", help="GitHub owner")
    parser.add_argument("--repo", help="Target repo name")
    parser.add_argument("--template", help="Template directory name under .github/policies/templates/")
    parser.add_argument("--fleet", action="store_true", help="Apply to all repos in .github/policies/fleet.json")
    parser.add_argument("--dry-run", action="store_true", help="Print actions without applying")
    parser.add_argument("--apply", action="store_true", help="Apply policies to GitHub")
    args = parser.parse_args()

    if sum([args.dry_run, args.apply]) != 1:
        parser.error("Specify exactly one of --dry-run, --apply")

    if args.fleet:
        fleet = load_json(FLEET_REGISTRY)
        template_dirs = fleet.get("template_dirs", {})
        ok = True
        for entry in fleet.get("repos", []):
            owner = entry["owner"]
            repo = entry["repo"]
            for template_name in entry.get("templates", []):
                tdir = TEMPLATES_DIR / template_name
                if not tdir.is_dir():
                    print(f"WARNING: template '{template_name}' not found for {owner}/{repo}", file=sys.stderr)
                    continue
                ok &= apply_template(owner, repo, tdir, dry_run=args.dry_run)
        return 0 if ok else 1

    if not args.repo or not args.template:
        parser.error("--repo and --template are required unless --fleet is used")

    ok = apply_template(args.owner, args.repo, template_dir(args.template), dry_run=args.dry_run)
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
