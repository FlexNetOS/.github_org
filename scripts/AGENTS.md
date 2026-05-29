<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-05-28 -->

# scripts/

## Purpose
Python and shell scripts implementing the real logic behind `make` targets. The Makefile is a typo-tolerant surface; these scripts are the authoritative implementation.

## Key Files

| File | Description |
|------|-------------|
| `clone-and-pack.sh` | Step 0 of the fork ritual — clones upstream to `.attic/research-work/` and runs repomix to produce packs in `data/brain-data/research/<name>/` |
| `bootstrap.sh` | Org bootstrap script for new FlexNetOS setups |
| `github-doctor.py` | Read-only audit of runner/workflows/app/submodules/secrets state |
| `claude-settings-doctor.js` | Validates `.claude/settings.json` for hardcoded paths and bad patterns |
| `manifest-query.py` | Query helper for `repos/MANIFEST.yaml` |
| `verify-markdown.py` | Markdown linter (called by `make verify.markdown`) |
| `verify-manifest.py` | MANIFEST.yaml schema validator (called by `make verify.manifest`) |
| `hermetic-audit.py` | Advisory report of non-hermetic CI dependencies |
| `open-questions-lint.js` | Validates `.omc/plans/open-questions.md` schema |
| `check-user-todo-step5.sh` | Lists MANIFEST entries tagged/untagged for USER.TODO#5 |
| `g3a-can-convert.sh` | G3a safety check before plain-clone → submodule conversion |
| `g3b-backup-branch.sh` | G3b: backup branch before submodule conversion |
| `g3c-stash-and-move.sh` | G3c: stash local changes and move to submodule path |
| `install-v5-architecture.sh` | V5 architecture installation script |
| `org-bootstrap.sh` | GitHub org bootstrap (sets up teams, branch protection, etc.) |
| `github-app-token-smoke.py` | Smoke-tests GitHub App token generation |
| `submodule-add-all.sh` | Appends MANIFEST entries missing from `.gitmodules` |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `hooks/` | Git hook scripts |

## For AI Agents

### Working In This Directory
- Scripts are stdlib-only Python or POSIX shell — no external package installs
- Scripts call `python3` (system 3.14) — do NOT `pip install` against it
- All scripts must be runnable from the repo root (`scripts/<name>.sh` or `python3 scripts/<name>.py`)
- The Makefile always calls scripts from the repo root; use `git rev-parse --show-toplevel` for portability

### Testing Requirements
- Python scripts: test with `python3 scripts/<name>.py --help` (all support `--help`)
- Shell scripts: `bash -n scripts/<name>.sh` for syntax check
- The real integration test is running the corresponding `make` target

### Common Patterns
- Shell scripts begin with `#!/usr/bin/env bash` and `set -euo pipefail`
- Python scripts use `argparse` for CLI and stdlib modules only
