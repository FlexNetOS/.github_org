# Fork-and-track workflow

How to carry local patches on a third-party repository while staying
current with upstream releases.

## The pattern

When FlexNetOS forks an upstream project (e.g. `ruvnet/RuVector` →
`FlexNetOS/ruvector`), two properties must hold simultaneously:

1. **Track upstream** — pick up bug fixes and features as they ship.
2. **Carry local diffs** — maintain integrations, CI, and customizations that don't make sense upstream (or that upstream isn't ready to accept).

The pattern below keeps both clean.

## One-time setup

```bash
git clone https://github.com/FlexNetOS/<repo>.git
cd <repo>

# Add the upstream remote
git remote add upstream https://github.com/<upstream-owner>/<repo>.git
git fetch upstream --tags

# Verify
git remote -v
# origin    https://github.com/FlexNetOS/<repo>.git (fetch + push)
# upstream  https://github.com/<upstream-owner>/<repo>.git (fetch + push)
```

## Branch model

| Branch | Tracks | Purpose |
| --- | --- | --- |
| `main` | `upstream/main` (or upstream default) | Mirror of upstream — never commit local changes here directly. |
| `develop` | `origin/develop` | Integration branch for our local changes; PRs target here. |
| `feat/<slug>` | branched from `develop` | Per-change feature branches. |

PRs in FlexNetOS forks target `develop`, not `main`. `main` is reserved
for upstream mirror state.

## Routine syncing

```bash
# Update both remotes
git fetch --all --tags --prune

# Fast-forward main to upstream
git checkout main
git merge --ff-only upstream/main
git push origin main

# Rebase develop on top of the new main
git checkout develop
git rebase main
# Only force-push if the rebase moved commits:
git push origin develop --force-with-lease
```

## Release-tag syncing

When upstream cuts a tagged release we want to mirror:

```bash
git fetch upstream --tags
git tag -l 'v*' | head -5     # find the new tag(s)
git push origin <tag-name>    # push the chosen tag to our fork
```

If we ship our own release with local diffs, prefix the tag with `flex-`
to avoid collisions with upstream:

```text
flex-v1.2.3+local.1
```

## Carrying patches across upstream history rewrites

When upstream rewrites history (force-pushes, drops commits, squash-
merges), replay our commits cleanly:

```bash
git rebase --onto upstream/main <old-base> develop
```

## When upstream accepts our patch

Once upstream merges a PR we have been carrying locally, drop the local
commit from `develop` on the next sync — the rebase will succeed
automatically if the patch is now identical to upstream's accepted
version. If it doesn't, that's a useful signal: upstream changed the
patch in review, and we should adopt the upstream variant rather than
re-applying ours.

## See also

- [`directory-layout.md`](directory-layout.md) — where forks vs upstream
  vs first-party live on disk.
- [`../CONTRIBUTING.md`](../CONTRIBUTING.md) — commit conventions and
  branch policy.
