# Contributing

Thanks for helping improve the FlexNetOS commons. This file describes the
defaults that apply to **every [@FlexNetOS](https://github.com/FlexNetOS)
repository** that inherits it — i.e. any repo that does not ship its own
`CONTRIBUTING.md`. A repo-local copy always overrides this one.

## Before you start

- For **non-trivial changes**, open an issue first so we can agree on scope before you invest time.
- For **questions or design discussion**, prefer GitHub Discussions over Issues.
- All contributors and maintainers agree to the [Code of Conduct](CODE_OF_CONDUCT.md).
- For **security problems**, do not open a public issue — follow [SECURITY.md](SECURITY.md).

## Branch policy

> **Repos that have adopted the trunk model** (`develop` present — e.g. the `.github` repo
> itself) follow [`WORKFLOW.md`](WORKFLOW.md) / ADR-0003: `develop` is the trunk, `main` is the
> protected mirror advanced only by automated promotion, and **PRs target `develop`, not `main`**.
> The defaults below are the org-wide baseline for repos that have not yet adopted `develop`.

- `main` is protected: PR with one approval, linear history, no force-push, no deletion.
- Branch off the trunk (`develop` where present, else `main`) using `<type>/<short-slug>` — e.g. `feat/issue-template`, `fix/runner-label`, `docs/fork-workflow`.
- Keep PRs focused: **one task per PR**. Split large changes into a stacked series rather than one mega-PR.
- Rebase on the trunk before requesting review; do not merge the trunk into your branch.

## Commit messages

We use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
so the reusable release workflow can compute version bumps and changelogs
automatically.

```text
<type>(<optional scope>): <imperative summary, <= 72 chars>

<optional body explaining *why*, wrapped at 72 cols>

<optional footers: Refs #123, Closes #456, BREAKING CHANGE: ...>
```

Common types: `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
Mark breaking changes with `!` after the type/scope (e.g. `feat(api)!: drop v1`)
or with a `BREAKING CHANGE:` footer — either triggers a major version bump.

## Pull-request expectations

- CI must be green before review: lint, test, and the reusable security scan (CodeQL + Trivy + Gitleaks).
- **Squash-merge or rebase-merge only** — no merge commits. The squash message must itself be a valid Conventional Commit.
- At least one maintainer approval; self-approval is not permitted.
- Update relevant docs in the same PR as the code change.
- Update or add tests in the same PR as the code change.
- Link the PR to the issue it closes (`Closes #N`) in the description.

## Reviewing

- If the change touches a **reusable workflow** under `.github/workflows/`, run it locally with [`act`](https://github.com/nektos/act) or in a scratch fork before approving.
- Block on correctness, security, and CI green. Style preferences are comments, not blockers.
- Approve only when you would be comfortable owning the change after the author moves on.

## Releasing (maintainer notes)

Releases are cut by the reusable release workflow on merge to `main`, driven
by the Conventional Commit history. Callers of the reusable workflows in
this repo should pin to a moving major tag (`@v1`) once the scaffolds carry
real bodies — see the README for the calling pattern.

## Local development for this repo

```bash
git clone https://github.com/FlexNetOS/.github.git
cd .github

# Lint workflows
tools/bin/actionlint .github/workflows/*.yml

# Lint markdown
python3 scripts/verify-markdown.py .
```

## Licence of contributions

By submitting a contribution, you agree to license it under the [MIT License](LICENSE)
that covers this repository.

## Directory conventions for AI tooling

Claude Code on Linux uses **`.claude/`** (lowercase, leading dot) **only** — both
user-global (`~/.claude/`) and project-local (`<repo>/.claude/`). **Never create a
PascalCase `Claude/` directory.** It is not a Claude Code convention; tooling does
not look there. The capitalized `Claude/` you may have seen belongs to **Claude
Desktop** on macOS (`~/Library/Application Support/Claude/`) or Windows
(`%APPDATA%\Claude\`) — a different product on a different OS. There is no
"two-submodule" (`.claude` + `Claude`) scheme.

`AGENTS.md` is the shared, cross-CLI instruction file and lives at the repo root.
Per-tool config lives in that tool's hidden directory (`.claude/`, `.codex/`).
CI enforces the no-`Claude/` rule via the `claude-dir-check` job in
[`manifest-drift.yml`](.github/workflows/manifest-drift.yml).

## CI invariant promotion pattern

New CI invariants land **report-only first**: the job sets `continue-on-error: true`
on pull requests so it annotates without blocking. After one full green cycle on
`main`, the job is promoted to **STRICT** (remove `continue-on-error`, or gate the
merge). The canonical reference is the upgrade-auto-review workflow. The
`manifest-drift.yml` jobs are currently report-only and follow this pattern.

## Doctor allowlist policy

Tracked `.claude` / `.codex` configuration must not contain hardcoded absolute
user-home paths (`/home/<user>/…`, `/Users/<user>/…`, `C:\Users\<user>\…`) — those
are CI errors and can never be allowlisted. Portable references under `$HOME`,
`${HOME}`, `~/`, or `%APPDATA%` are permitted **only** when listed in the relevant
allowlist (`.claude/.doctor-allowlist`, `.codex/.doctor-allowlist`) with a one-line
rationale. The `make claude.doctor` / `make config.doctor` targets enforce this
read-only.

## Submodules in this repo

> **ADR-0002 update:** `.github_org` is **no longer the submodule mount point**
> for FlexNetOS repos. Repo organization moved to typed hubs (`tool_hub`,
> `plugin_hub`, `vault_hub`, …) and unclassified work parks in
> `~/Desktop/pending_relocate`. `repos/MANIFEST.yaml` is now an **offload stub**.
>
> The only remaining gitlinks in this repo are the `data/brain-data/*` wiki/brain
> submodules. They are managed directly with `git submodule` commands if needed;
> there is no hand-maintained `.gitmodules` merge workflow here.
