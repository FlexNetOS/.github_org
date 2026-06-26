# Runner group policy

> Applies to the FlexNetOS organization-level self-hosted runner. The runner is
> org-scoped, not repo-scoped; repo access is controlled by the org runner group.

## Group: `Default`

GitHub's default organization runner group currently contains the local Linux runner:

- runner: `fxrun-drdave-TRX50-AI-TOP-org`
- install path: `/home/drdave/_work/repos/actions-runner-org`
- labels: `self-hosted`, `Linux`, `X64`, `local`, `flexnetos`

The group name is intentionally documented as the live GitHub name. Do not create a
repo-scoped envctl runner to work around group policy; fix the org runner group instead.

## Repo access

**Restricted selected-repository access.** The group must not be open-ended for all public
repositories. Public repository execution is allowed only because the selected-repository
allowlist is explicit.

Live policy:

- `visibility=selected`
- `allows_public_repositories=true`
- `restricted_to_workflows=false`

Selected repositories:

- `FlexNetOS/.github` — reusable org workflows and secret bootstrap checks
- `FlexNetOS/envctl` — envctl CI `test` context and trusted `sync-master`
- `FlexNetOS/flexnetos_runner` — runner operations and maintenance

Adding a repo to the allowlist requires:

1. A PR against this file documenting the addition and the reason.
2. Maintainer review.
3. The Settings/API change in the GitHub org runner group.

Do not solve queueing by widening this group to all public repositories. If a repository only
needs generic build capacity, route it to GitHub-hosted runners.

## Workflow access

Workflow access is not separately restricted (`restricted_to_workflows=false`) because the
repository allowlist is the security boundary. Untrusted fork PRs in allowlisted public repos
must still route to GitHub-hosted runners, not this local runner.

## Label discipline

Workflows that want this runner MUST request the full label set:

```yaml
jobs:
  build:
    runs-on: [self-hosted, linux, x64, local, flexnetos]
```

Specifying only `self-hosted` is rejected — be explicit. This protects against accidentally
routing a job to the wrong runner once we have more than one.

## Routing and concurrency

The runner serves jobs **serially** (one at a time). For parallel workloads, prefer
GitHub-hosted runners.

Required branch-protection contexts should fan out on GitHub-hosted runners unless they truly
need local host state. If a workflow needs the self-hosted runner and matrix parallelism, split
the matrix legs so only one leg runs here and the rest run on GitHub-hosted.

## Audit

- Every job's start/end is logged by the systemd journal — view with:
  `journalctl -u 'actions.runner.*'`
- `runner/audit.log` (gitignored) gets a weekly summary appended by a
  scheduled workflow (`runner-audit.yml`).
- Any allowlist or group-membership change emits a GitHub audit-log
  event in the org settings.

## Disabling fast

If the runner needs to be taken offline immediately (e.g. suspected
compromise):

```bash
# On the runner host
sudo systemctl stop 'actions.runner.*'
# In GitHub UI: Org Settings → Actions → Runners → remove the runner
```

Removing the runner from GitHub *and* stopping it locally is the only
fully-effective shutdown. Either alone leaves a window.
