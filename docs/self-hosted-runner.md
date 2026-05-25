# Self-hosted runner safety

Current inventory, untrusted-PR risk, label discipline, and the
migration path to ephemeral runners.

## Why this document exists

Self-hosted runners are convenient (free compute, access to local
hardware, no GitHub usage cap) and dangerous (a malicious PR can run
arbitrary code on the runner's host). Without discipline, a self-hosted
runner is a privilege-escalation vector from the public internet into
the maintainer's machine.

This document defines the discipline.

## Current inventory

| Runner label | Host | Used by | Status |
| --- | --- | --- | --- |
| _(none deployed yet)_ | — | — | Placeholder — fill in as runners come online. |

## The two risks

1. **Untrusted PR runs your code.** GitHub Actions defaults run `pull_request` workflows on the _base_ repo's secrets and runners. A PR that adds a malicious step to a workflow under `.github/workflows/` can read sensitive files on your runner.
2. **Compromised runner persists.** Default self-hosted runners are long-lived — a workflow that succeeds in leaving an SSH key, a cron job, or a modified PATH stays for every future job.

## Required mitigations

For any self-hosted runner attached to a FlexNetOS repository:

- **No `pull_request` triggers from forks.** Use `pull_request_target` only with explicit `permissions:` restrictions, or restrict the runner to `push` and `workflow_dispatch` triggers.
- **Require `runs-on:` labels that include `self-hosted` AND a workflow-specific label.** Never `runs-on: self-hosted` alone — that matches any registered runner.
- **`permissions:` defaults to `read` everywhere.** Grant write scopes per-job, not per-workflow.
- **Forbid secrets in untrusted-fork workflows.** Use `if: github.event.pull_request.head.repo.fork == false` on any step that touches a secret.

## The migration path: ephemeral runners

Long-lived runners are the root cause of "compromised runner persists."
Migrate to **ephemeral** runners — one runner process per job, then the
process exits and the host is destroyed.

| Option | When it's right |
| --- | --- |
| **GitHub-hosted larger runners** | Managed; no persistence by design; pay-per-minute. Right for most needs. |
| **Actions Runner Controller (ARC) on Kubernetes** | Open-source controller that spawns ephemeral runner pods. Right when we need GPU access, large memory, or local hardware. |
| **`runs-on.com` or `cirun.io`** | Third-party ephemeral hosts. Right when ARC is too much to operate. |

## What to do if a runner is compromised

1. Take the host offline (network drop, not just shutdown).
2. Rotate any secret the runner had access to: GitHub tokens, SSH keys, cloud credentials.
3. Audit all workflow runs on that runner since the last clean state.
4. Rebuild the host from a known-good image, then re-register a new runner.
5. File a post-mortem in the affected repo's `docs/security/` directory.

## See also

- [`fork-workflow.md`](fork-workflow.md) — branch policy for forks.
- [`../SECURITY.md`](../SECURITY.md) — vulnerability disclosure policy.
