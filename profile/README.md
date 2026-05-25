# FlexNetOS

Open infrastructure for distributed, edge-resident AI systems — built on
the principle that intelligence should live where data lives, not behind
someone else's API.

## What we build

| Layer | Project | What it does |
| --- | --- | --- |
| **Brain** | [`ruvector`](https://github.com/FlexNetOS/ruvector) | Vector database, graph neural networks, embeddings, attractor dynamics, and the shared knowledge graph that powers the rest. |
| **Runtime** | [`weftos`](https://github.com/FlexNetOS/weftos) | Agent runtime and orchestration layer that consumes capabilities from the brain. |
| **Commons** | [`.github`](https://github.com/FlexNetOS/.github) | Shared community defaults, reusable CI workflows, and engineering best-practices docs that apply across every FlexNetOS repository. |

## Picking up a contribution

A single set of community defaults applies across every FlexNetOS
repository:

- [Code of Conduct](https://github.com/FlexNetOS/.github/blob/main/CODE_OF_CONDUCT.md)
- [Contributing guide](https://github.com/FlexNetOS/.github/blob/main/CONTRIBUTING.md) — commit conventions, branch policy, PR expectations
- [Security policy](https://github.com/FlexNetOS/.github/blob/main/SECURITY.md) — how to report vulnerabilities privately
- [Support guide](https://github.com/FlexNetOS/.github/blob/main/SUPPORT.md) — Issues vs Discussions vs email

Each repository's own `README.md` is the source of truth for how to
build and test that repository. Start there.

## Where things live

Documentation that applies across repositories lives in [`FlexNetOS/.github/docs/`](https://github.com/FlexNetOS/.github/tree/main/docs):

- [Fork-and-track workflow](https://github.com/FlexNetOS/.github/blob/main/docs/fork-workflow.md) — carrying local patches on third-party repos.
- [Directory layout for local checkouts](https://github.com/FlexNetOS/.github/blob/main/docs/directory-layout.md) — on-disk convention for forks vs first-party vs read-only clones.
- [Self-hosted runner safety](https://github.com/FlexNetOS/.github/blob/main/docs/self-hosted-runner.md) — untrusted-PR risk and the ephemeral-runner migration path.

## Contact

- **Security**: <https://github.com/FlexNetOS/.github/blob/main/SECURITY.md>
- **General**: open an issue on the relevant repository.
