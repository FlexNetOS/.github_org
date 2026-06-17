#!/usr/bin/env python3
"""Validate that the secrets declared in secrets/github-secrets.tsv exist on GitHub.

Reads the local mapping file (defaults to secrets/github-secrets.tsv, falls back to
secrets/github-secrets.tsv.example) and checks each declared secret via `gh secret
list`. Live checks are skipped when `gh` is unavailable or not authenticated.

Exit 0 if all declared secrets are present (or no live check is possible), 1 if any
are missing.
"""
from __future__ import annotations

import csv
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAPPING_FILES = [ROOT / "secrets" / "github-secrets.tsv", ROOT / "secrets" / "github-secrets.tsv.example"]


def find_mapping() -> Path | None:
    for path in MAPPING_FILES:
        if path.exists():
            return path
    return None


def gh_available() -> bool:
    return shutil.which("gh") is not None


def list_secrets(scope: str, target: str) -> set[str]:
    if scope == "repo":
        cmd = ["gh", "secret", "list", "--repo", target]
    elif scope == "org":
        cmd = ["gh", "secret", "list", "--org", target]
    elif scope == "env":
        repo, env = target.split(":", 1)
        cmd = ["gh", "secret", "list", "--repo", repo, "--env", env]
    else:
        return set()
    proc = subprocess.run(cmd, text=True, capture_output=True, check=False)
    if proc.returncode != 0:
        print(f"WARNING: could not list secrets for {scope} {target}: {proc.stderr.strip()}", file=sys.stderr)
        return set()
    names: set[str] = set()
    for line in proc.stdout.splitlines()[1:]:
        parts = line.split()
        if parts:
            names.add(parts[0])
    return names


def main() -> int:
    mapping = find_mapping()
    if mapping is None:
        print("No secrets mapping file found; skipping")
        return 0

    if not gh_available():
        print("gh CLI not available; skipping live secret checks")
        return 0

    missing: list[tuple[str, str, str]] = []
    checked: set[tuple[str, str]] = set()
    cache: dict[tuple[str, str], set[str]] = {}

    with mapping.open(newline="", encoding="utf-8") as fh:
        reader = csv.DictReader(fh, delimiter="\t")
        for row in reader:
            scope = (row.get("scope") or "").strip()
            target = (row.get("target") or "").strip()
            name = (row.get("secret_name") or "").strip()
            if not scope or not target or not name or scope.startswith("#"):
                continue
            key = (scope, target)
            if key not in cache:
                cache[key] = list_secrets(scope, target)
                checked.add(key)
            if name not in cache[key]:
                missing.append((scope, target, name))

    if not missing:
        print(f"secrets-doctor: OK ({len(checked)} scope(s) checked)")
        return 0

    print("secrets-doctor: missing secrets")
    for scope, target, name in missing:
        print(f"  {scope} {target}: {name}")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
