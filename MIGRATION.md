# MIGRATION — FlexNetOS/.github → meta workspace

Authoritative map for refactoring this 6-role umbrella into the `meta` framework.
Tracked in the meta workspace KB as `tasks/github-meta-refactor`.

**Principle:** this repo keeps only the two roles that *require* the magic `.github`
repo name — **(1) org community-health fallback** and **(6) reusable CI templates**.
Everything else becomes its own FlexNetOS repo registered as a **meta peer** (not a
submodule, not a child — meta treats repos as peers).

**Safety:** `main` stays fully intact until each destination repo exists. Removals
happen *atomically with extraction* in Phase 2 (extract-then-remove), so no content
ever lives only in a deleted state — especially `secrets/`.

---

## ⚠️ Reality vs. MANIFEST drift (discovered 2026-06-03)

`.gitmodules` and `repos/MANIFEST.yaml` are **out of sync with the actual repo**.
The manifest lists ~28 owned/forked/external repos, but the **actually-committed
submodules** are:

| Location | Real gitlinks present |
| --- | --- |
| `tools/` | actionlint, bun, cpython, gitleaks, node, trivy, uv (7) |
| `repos/` | **ai-top-utility, fabro, n8n, paperclip** (4 — NOT the manifest list) |
| `network/` | slim (1) |
| `data/brain-data/` | DeepTutor, deepwiki-rs, obsidian-second-brain, obsidian-skills, obsidian-mind (5 nested) |

`data/brain-data/DeepTutor` has **no `.gitmodules` mapping** → `git submodule status`
errors. **Decision needed (Phase 3):** migrate the *aspirational manifest* (~28 repos)
or only the *actually-present* submodules (17)? Plus ruvector + weftos are discarded.

---

## KEEP — slim `.github` (roles 1 + 6)

| Path | Note |
| --- | --- |
| `LICENSE`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md`, `FUNDING.yml`, `MAINTAINERS.md` | Role 1 community-health |
| `profile/README.md` | Org landing page |
| `README.md`, `VISION.md` | **Rewrite**: 6-role → 2-role (slim) |
| `RELEASING.md`, `CHANGELOG.md` | This repo's own release machinery |
| `.github/CODEOWNERS`, `PULL_REQUEST_TEMPLATE.md`, `ISSUE_TEMPLATE/`, `dependabot.yml`, `actionlint.yaml`, `AGENTS.md` | Role 1 templates + repo config |
| `.github/workflows/reusable-*.yml` (8) | **Role 6** — the reason this repo exists |
| `.github/workflows/{ci,dependency-review,release}.yml` | This repo's own generic CI (slim) |
| `docs/{README,fork-workflow,directory-layout,org-setup,hermetic-toolchain,github-automation-roadmap}.md`, `docs/templates/` | Cross-org operational docs |
| `Makefile`, `.markdownlint.json`, `.gitleaks.toml`, `.mcp.json` | Repo tooling (slim) |
| `scripts/{verify-markdown.py,claude-settings-doctor.js,open-questions-lint.js,github-doctor.py,org-bootstrap.sh,bootstrap.sh}`, `scripts/hooks/actionlint-on-workflow-edit.sh` | Generic org tooling |

## MOVE → new `flexnetos_*` peer repos

| New repo | Sources |
| --- | --- |
| **flexnetos_secrets** (role 4) | `secrets/`, `scripts/secrets-*.sh` (4), `scripts/hooks/protect-secrets-store.sh`, `.github/workflows/secrets-rotate.yml`, `.envrc` (secret-injection bits) |
| **flexnetos_runner** (role 5) | `runner/`, `scripts/runner-doctor.sh`, `docs/self-hosted-runner.md`, `network/` (service-map, scripts, docs) |
| **flexnetos_wiki** (role 3) | `wiki/`, `.github/workflows/wiki-lint.yml`, `architecture/` (org architecture docs) |
| **flexnetos_brain** (data) | `data/brain-data/` (76M, 5 nested gitlinks), `SESSIONS.md`, `TODO.md`, `USER.TODO.md` (umbrella session/working logs — archive) |
| **flexnetos_github_app** | `github-app/`, `scripts/github-app-token-smoke.py` |
| **flexnetos_claude_config** | `.claude/`, `CLAUDE.md` |
| **flexnetos_codex_config** | `.codex/` |
| **flexnetos_agents_config** | `.agents/` |
| **flexnetos_omc** | `.omc/` (regenerable caches dropped) — OR fold into the forked `oh-my-claudecode` peer |

## MIGRATE → `.meta.yaml` peers + RETIRE submodule machinery (role 2)

| Action | Items |
| --- | --- |
| **Become meta peers** | `tools/*` (7), `repos/*` real submodules (4), `network/slim` → `.meta.yaml` with `tags:` mirroring groups |
| **Source for .meta entries** | `repos/MANIFEST.yaml`, `tools/MANIFEST.yaml`, `network/MANIFEST.yaml` → translate, then retire |
| **DELETE** | `.gitmodules` |
| **RETIRE** (meta replaces) | `scripts/submodule-*.sh` (3), `verify-manifest.py`, `manifest-query.py`, `reconcile-stray-clones.sh`, `clone-and-pack.sh`, `toolchain.py`, `scripts/hooks/gitmodules-drift-guard.sh` |
| **RETIRE / replace meta-native** | `.github/workflows/{submodule-bump,manifest-drift}.yml`, `reusable-submodule-bump.yml` |

## DROP / archive (one-off bootstrap & obsolete)

| Path | Reason |
| --- | --- |
| `scripts/{install-v5-architecture.sh,check-user-todo-step5.sh,g3a-can-convert.sh,g3b-backup-branch.sh,g3c-stash-and-move.sh,hermetic-audit.py}` | One-off migration/bootstrap scripts |
| `docs/{submodule-vision,linked-submodule-workflows}.md` | Describe the obsolete submodule model |
| `.omc/` plugin caches | Regenerable |

## Open destination questions (flagged, default in italics)

1. `architecture/` → *flexnetos_wiki* or keep in `.github`?
2. `.omc/` → *own peer `flexnetos_omc`* or fold into `oh-my-claudecode` peer?
3. `network/` (non-slim parts) → *flexnetos_runner* or own peer?
4. `SESSIONS.md`/`USER.TODO.md` → *archive to flexnetos_brain* or drop?
5. Phase 3 migration list: *aspirational manifest (~28)* vs actually-present submodules (17)?
