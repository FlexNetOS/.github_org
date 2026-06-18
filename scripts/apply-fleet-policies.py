#!/usr/bin/env python3
"""Fleet policy applier for FlexNetOS meta repos.

Reads policy templates from .github/policies/templates/ and applies them to one
or more repos. The core GitHub API calls are reused from
scripts/apply-github-policies.py so the fleet and single-repo appliers stay in
sync.

Usage:
    python3 scripts/apply-fleet-policies.py --owner FlexNetOS --repo meta_core --template rust-canon --dry-run
    python3 scripts/apply-fleet-policies.py --owner FlexNetOS --repo meta_core --template rust-canon --apply
    python3 scripts/apply-fleet-policies.py --fleet --dry-run
    python3 scripts/apply-fleet-policies.py --fleet --apply
"""
from __future__ import annotations

import argparse
import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TEMPLATES_DIR = ROOT / ".github" / "policies" / "templates"
FLEET_REGISTRY = ROOT / ".github" / "policies" / "fleet.json"


def _applier_module():
    """Load scripts/apply-github-policies.py as a module without running its CLI."""
    spec = importlib.util.spec_from_file_location(
        "github_policies", str(ROOT / "scripts" / "apply-github-policies.py")
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)  # type: ignore[union-attr]
    return module


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def validate_template(
    bp_spec: dict | None, rs_spec: dict | None, settings_spec: dict | None
) -> list[str]:
    """Validate template specs using the shared applier validator."""
    applier = _applier_module()
    errors: list[str] = []
    if bp_spec:
        errors.extend(applier.validate_policy(bp_spec, "branch-protection"))
    if rs_spec:
        errors.extend(applier.validate_policy(rs_spec, "rulesets"))
    if settings_spec:
        errors.extend(applier.validate_policy(settings_spec, "repo-settings"))
    return errors


def _load_template_parts(template_dir: Path) -> tuple[dict | None, dict | None, dict | None]:
    bp_path = template_dir / "branch-protection.json"
    rs_path = template_dir / "rulesets.json"
    settings_path = template_dir / "repo-settings.json"
    bp_spec = load_json(bp_path) if bp_path.exists() else None
    rs_spec = load_json(rs_path) if rs_path.exists() else None
    settings_spec = load_json(settings_path) if settings_path.exists() else None
    return bp_spec, rs_spec, settings_spec


def apply_template(
    owner: str, repo: str, template_dir: Path, *, dry_run: bool
) -> bool:
    """Apply one template directory to a single repository."""
    applier = _applier_module()
    bp_spec, rs_spec, settings_spec = _load_template_parts(template_dir)

    errors = validate_template(bp_spec, rs_spec, settings_spec)
    if errors:
        for err in errors:
            print(f"VALIDATION ERROR ({owner}/{repo}, {template_dir.name}): {err}", file=sys.stderr)
        return False

    ok = True
    print(f"\n>>> Applying template '{template_dir.name}' to {owner}/{repo}")

    if bp_spec:
        for branch, spec in bp_spec.get("branches", {}).items():
            ok &= applier.apply_branch_protection(owner, repo, branch, spec, dry_run=dry_run)

    if rs_spec:
        ok &= applier.apply_rulesets(owner, repo, rs_spec.get("rulesets", []), dry_run=dry_run)

    if settings_spec:
        ok &= applier.apply_repo_settings(owner, repo, settings_spec, dry_run=dry_run)
        ok &= applier.apply_environments(
            owner, repo, settings_spec.get("environments", []), dry_run=dry_run
        )

    return ok


def template_dir(name: str) -> Path:
    path = TEMPLATES_DIR / name
    if not path.is_dir():
        raise SystemExit(f"Template not found: {path}")
    return path


def apply_fleet(*, dry_run: bool) -> bool:
    """Apply all registered templates to all repos in fleet.json."""
    fleet = load_json(FLEET_REGISTRY)
    ok = True
    for entry in fleet.get("repos", []):
        owner = entry.get("owner")
        repo = entry.get("repo")
        if not owner or not repo:
            print(f"WARNING: fleet entry missing owner/repo: {entry}", file=sys.stderr)
            continue
        for template_name in entry.get("templates", []):
            tdir = TEMPLATES_DIR / template_name
            if not tdir.is_dir():
                print(
                    f"WARNING: template '{template_name}' not found for {owner}/{repo}",
                    file=sys.stderr,
                )
                continue
            ok &= apply_template(owner, repo, tdir, dry_run=dry_run)
    return ok


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Apply fleet policy templates to FlexNetOS repos"
    )
    parser.add_argument("--owner", default="FlexNetOS", help="GitHub owner")
    parser.add_argument("--repo", help="Target repo name")
    parser.add_argument(
        "--template",
        help="Template directory name under .github/policies/templates/",
    )
    parser.add_argument(
        "--fleet", action="store_true", help="Apply to all repos in .github/policies/fleet.json"
    )
    parser.add_argument("--dry-run", action="store_true", help="Print actions without applying")
    parser.add_argument("--apply", action="store_true", help="Apply policies to GitHub")
    args = parser.parse_args()

    if sum([args.dry_run, args.apply]) != 1:
        parser.error("Specify exactly one of --dry-run, --apply")

    if args.fleet:
        ok = apply_fleet(dry_run=args.dry_run)
        return 0 if ok else 1

    if not args.repo or not args.template:
        parser.error("--repo and --template are required unless --fleet is used")

    ok = apply_template(args.owner, args.repo, template_dir(args.template), dry_run=args.dry_run)
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
