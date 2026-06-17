# Repo onboarding templates

Copy these starter workflows into a new FlexNetOS/meta* child repo's
`.github/workflows/` directory and adjust the repo-specific values.

All templates assume the child repo uses `main` as the default branch and
consumes reusable workflows from `FlexNetOS/.github`.

## Files

| File | Purpose |
| --- | --- |
| `ci.yml` | Call the full-clone reusable Rust/meta CI |
| `auto-format.yml` | Auto-format Rust code on PR/push and push fixes back |
| `notify-parent.yml` | Tell `FlexNetOS/meta` when this repo's `main` changes |
| `notify-downstream.yml` | Wait for CI, then notify downstream consumers |
| `renovate.json` | Extend the shared FlexNetOS Rust Renovate preset |
| `release.yml` | Cut a release and upload Rust binary artifacts |

## Required secrets

- `PARENT_REPO_PAT` — PAT with `repo` scope on `FlexNetOS/meta` and any
  downstream repos. Only needed for cross-repo dispatch.
- `RELEASE_TOKEN` — PAT with `contents:write` for cutting releases and uploading
  binary artifacts. Only needed for `release.yml`.

## Notes

- `ci.yml` and `auto-format.yml` use the `meta-rust-workspace` composite action,
  which performs full clones (no `--depth 1`) per ADR-0002.
- Replace `workspace-path` with the current repo's directory name in the
  synthetic workspace (usually the repo name).
