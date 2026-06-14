# Vision — what this repo is

`FlexNetOS/.github` is the org's **`.github` repo plus a small operational hub**. It plays **five**
roles at once, deliberately bundled so a single repo + a single self-hosted runner can serve every
other FlexNetOS repository.

> **2026-06-14 — leaned out (ADR-0002).** This repo used to play a *sixth* role: the **mount point
> for ~24 git submodules**. That role has been **retired**. Repos are now organized into typed
> **FlexNetOS hubs** (`tool_hub`, `plugin_hub`, `vault_hub`, `database_hub`, `flow_hub`,
> `network_hub`, …); anything not yet classified is parked in `~/Desktop/pending_relocate`. See
> [Repo organization moved to hubs](#repo-organization-moved-to-hubs-the-retired-sixth-role) below
> and [`architecture/adr/ADR-0002-lean-github-org-relocate-to-hubs.md`](architecture/adr/ADR-0002-lean-github-org-relocate-to-hubs.md).

A new contributor or a returning maintainer should read this page first. The rest of the repo makes
more sense once you understand the five jobs.

## The five roles

### 1. GitHub org community-health fallback

GitHub treats a repository named `.github` under a user or organization
as the source of **default community health files** for every other repo
in that account. Anything in this repo's root or `.github/` directory —
`CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md`,
`FUNDING.yml`, the issue/PR templates — is automatically displayed on
any FlexNetOS repo that does not ship its own copy. Overrides are local:
commit the file in the downstream repo and the local version wins for
that repo only.

This is the role most users notice. The other four sit underneath.

### 2. Karpathy LLM-wiki — cross-project memory layer

The [`wiki/`](wiki/) tree is a persistent, compiled knowledge base in
the Karpathy LLM-wiki style. It is the memory layer for everything that
happens under this umbrella: when a paper changes how we evaluate
agents, when a new vector-DB technique lands in `ruvector`, when a
recurring engineering decision is settled — the synthesis lives here
and stays. The compiled brain/research submodules under
[`data/brain-data/`](data/brain-data/) are part of this layer and are
intentionally **kept here** (they were not offloaded with the other repos).

Mission, scope, and out-of-scope are documented in
[`wiki/purpose.md`](wiki/purpose.md). Schema and conventions are in
[`wiki/schema.md`](wiki/schema.md). The wiki is meant to be query-able
and lint-able; [`wiki-lint.yml`](.github/workflows/wiki-lint.yml) runs
nightly to catch broken links and orphans.

### 3. `pass` + GPG secrets vault with paper recovery

[`secrets/`](secrets/) is a `pass`-managed store keyed by GPG. Two
keys: a personal key on the dev box and a separate runner key, never
reused. Recovery is paper-backed via age — see
[`secrets/recovery/README.md`](secrets/recovery/README.md) for the
generation and storage protocol.

Injection into running processes is handled by
[`scripts/secrets-inject.sh`](scripts/secrets-inject.sh) (via direnv),
rotation by [`scripts/secrets-rotate.sh`](scripts/secrets-rotate.sh)
and the scheduled [`secrets-rotate.yml`](.github/workflows/secrets-rotate.yml)
workflow, and a one-way mirror to Bitwarden Secrets Manager by
[`scripts/secrets-mirror-to-bws.sh`](scripts/secrets-mirror-to-bws.sh)
for cloud accessibility.

> Note: at the workspace level, **`meta/envctl` is the user-global env/secrets manager** (ADR-0006).
> This repo-local `pass` vault predates that and is being reconciled with the envctl secrets engine;
> treat envctl as the source of truth for new secret material.

### 4. Self-hosted GitHub Actions runner host config

[`runner/`](runner/) is the on-host configuration for the FlexNetOS
self-hosted runner: install script, registration helper, ephemeral-spawn
wrapper, and systemd units. Policy lives next to the code in
[`runner/policies/`](runner/policies/) — the runner-group allowlist and
the PR-from-fork policy that gates untrusted code from ever reaching the
runner.

Safety guidance and the migration path to ephemeral runners is in
[`docs/self-hosted-runner.md`](docs/self-hosted-runner.md). Read it
before changing anything in this directory.

### 5. Shared reusable-CI templates

[`.github/workflows/reusable-*.yml`](.github/workflows/) are
language-agnostic, `workflow_call`-shaped CI templates used by every
downstream FlexNetOS repo. They ship with documented inputs,
least-privilege `permissions:` blocks, and consistent matrix shapes so
adding a new repo is a three-line caller, not a hundred-line copy-paste.

```yaml
jobs:
  lint:
    uses: FlexNetOS/.github/.github/workflows/reusable-lint.yml@v1
    with:
      language: bun
    secrets: inherit
```

Downstream repos should pin to the moving major tag (`@v1`) once it
exists. Today the workflows are scaffolds; see [`RELEASING.md`](RELEASING.md)
for the path to v1.

## Repo organization moved to hubs (the retired sixth role)

This repo **no longer mounts the FlexNetOS codebase as submodules.** [`repos/MANIFEST.yaml`](repos/MANIFEST.yaml)
is now an **offload stub** and `repos/` holds no submodules. Where things went (ADR-0002):

- **Typed hubs** own the inventory by type — `tool_hub` (toolchain pins; the 7 `tools/*` pins moved
  here), `plugin_hub` (Claude plugins/marketplaces), `vault_hub` (secrets services), `database_hub`
  (vector/memory DBs), `flow_hub` (automation), `network_hub` (dev-net tooling), etc. Each hub keeps a
  `registry.json` + `entries/` (Hub Standard).
- **`~/Desktop/pending_relocate/`** (outside the meta workspace) is the holding pen for repos not yet
  classified to a hub — every `url`/`branch`/pinned-`SHA` is preserved there (never-downgrade).
- **`ruvector`** is **not** mounted here — it lives at `meta/ruvector`, and the rule is **crates only**.
- **`data/brain-data/*`** (the wiki/brain layer) stays in this repo (role 2 above).

The old submodule machinery (`scripts/submodule-*.sh`, `submodule-bump.yml`, `tools/` pins) is being
wound down as items finish relocating. The live relocation is tracked as handoff task
`KBTASK-GITHUB-ORG-LEAN-RELOCATION`. Adding a *new* repo no longer means a submodule here — it means
the research-before-fork ritual landing the repo in its **hub**, not in `.github_org`.

## Why this shape

Bundling the five roles here is a deliberate solo-operator choice:

- **One self-hosted runner** can serve the secrets vault, the wiki linter, and downstream callers —
  without cross-repository credential plumbing.
- **One operational view**: `git pull && git status` here tells you whether secrets need rotating or
  the wiki lost a link.
- **One CHANGELOG** for the operational machinery, not five.

The cost is surface area: a contributor landing on this repo sees more than a typical `.github` repo.
That is the trade-off this `VISION.md` exists to surface, not to hide.

## What this repo is *not*

- **Not a place for per-project code.** Source code for `ruvector`, `weftos`, or any other FlexNetOS
  project lives in those repos / their hubs.
- **Not the submodule mount point anymore.** Repo organization lives in the typed hubs (ADR-0002).
- **Not a documentation site.** The `docs/` tree documents *operational* conventions shared across
  repos. Per-project docs live in their own `docs/`.
- **Not a release artifact host.** Tagged releases of this repo only describe the umbrella's own
  changelog. Downstream repos cut their own releases through
  [`reusable-release.yml`](.github/workflows/reusable-release.yml).

## See also

- [`README.md`](README.md) — usage walkthrough and inheritance mechanics
- [`architecture/adr/ADR-0002-lean-github-org-relocate-to-hubs.md`](architecture/adr/ADR-0002-lean-github-org-relocate-to-hubs.md) — the lean/relocate decision
- [`MAINTAINERS.md`](MAINTAINERS.md) — who to ask, how to escalate
- [`RELEASING.md`](RELEASING.md) — tagging policy and the v1 path
- [`docs/README.md`](docs/README.md) — index of best-practices docs
- [`USER.TODO.md`](USER.TODO.md) — one-time human actions that unlock the rest of the automation
