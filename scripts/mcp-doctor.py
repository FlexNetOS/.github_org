#!/usr/bin/env python3
"""Validate MCP server configuration for security and hermeticity.

Checks .mcp.json for:
- valid JSON and required top-level shape
- no hardcoded secrets in command args or env values
- Docker-based servers use digest-pinned images
- HTTP servers use localhost or HTTPS URLs

Exit 0 if all checks pass, 1 otherwise.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

MCP_PATH = Path(".mcp.json")
SECRET_RE = re.compile(r"\b(gh[pousr]_[A-Za-z0-9_]{36}|sk-[A-Za-z0-9]{48}|\b[0-9a-f]{40}\b)\b")
DIGEST_RE = re.compile(r"@sha256:[a-fA-F0-9]{64}$")


def fail(msgs: list[str]) -> int:
    print("MCP doctor: configuration issues found")
    for m in msgs:
        print(f"  - {m}")
    return 1


def check_value(name: str, value: str, errors: list[str]) -> None:
    if not isinstance(value, str):
        return
    if SECRET_RE.search(value):
        errors.append(f"{name} looks like a hardcoded secret/token")
    if "latest" in value and "@sha256:" not in value:
        errors.append(f"{name} uses an unpinned 'latest' container reference")


def main() -> int:
    if not MCP_PATH.exists():
        print("MCP doctor: no .mcp.json found (skipping)")
        return 0

    try:
        cfg = json.loads(MCP_PATH.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        return fail([f".mcp.json is not valid JSON: {exc}"])

    if not isinstance(cfg, dict):
        return fail([".mcp.json must be a JSON object"])

    servers = cfg.get("mcpServers")
    if not isinstance(servers, dict):
        return fail([".mcp.json must contain an 'mcpServers' object"])

    errors: list[str] = []
    for name, server in servers.items():
        if not isinstance(server, dict):
            errors.append(f"server '{name}' must be an object")
            continue

        server_type = server.get("type", "stdio" if "command" in server else None)

        # Validate command-based (stdio) servers
        if "command" in server:
            cmd = server["command"]
            args = server.get("args", [])
            if not isinstance(args, list):
                errors.append(f"server '{name}' args must be an array")
            else:
                for i, arg in enumerate(args):
                    check_value(f"server '{name}' arg[{i}]", arg, errors)
                    if isinstance(arg, str) and arg.startswith(("ghcr.io/", "docker.io/", "registry.hub.docker.com/")):
                        if not DIGEST_RE.search(arg):
                            errors.append(
                                f"server '{name}' container image is not digest-pinned: {arg}"
                            )

            # Warn about common mutable tags even when not a full image ref
            for val in [cmd, *args]:
                check_value(f"server '{name}' command/arg", val, errors)

        # Validate HTTP/SSE servers
        if server_type in ("http", "sse"):
            url = server.get("url", "")
            check_value(f"server '{name}' url", url, errors)
            if isinstance(url, str) and not (
                url.startswith("https://") or "localhost" in url or "127.0.0.1" in url
            ):
                errors.append(
                    f"server '{name}' HTTP URL is not HTTPS or localhost: {url}"
                )

        # Environment values must reference env vars, never literals
        env = server.get("env", {})
        if isinstance(env, dict):
            for key, val in env.items():
                check_value(f"server '{name}' env.{key}", val, errors)
                if isinstance(val, str) and "${" not in val:
                    errors.append(
                        f"server '{name}' env.{key} should reference an env var (${{VAR}}); got literal: {val}"
                    )

    if errors:
        return fail(errors)

    print("MCP doctor: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
