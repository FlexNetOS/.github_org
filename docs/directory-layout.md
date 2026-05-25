# Directory layout for local checkouts

The on-disk convention for FlexNetOS contributors who keep many
repositories cloned at once.

## The layout

```text
$HOME/_work/repos/
├── _forks/             # FlexNetOS-owned forks of third-party projects
│   ├── ruvector/       # fork of ruvnet/RuVector
│   ├── chroma/         # fork of chroma-core/chroma
│   └── ...
├── _firstparty/        # FlexNetOS-owned original projects (no upstream)
│   ├── weftos/
│   └── ...
├── _readonly/          # third-party projects we clone but never modify
│   ├── cpython/
│   └── ...
└── my-github/          # the FlexNetOS/.github community defaults repo
```

## Why three lanes

| Lane | Why it exists |
| --- | --- |
| `_forks/` | Needs upstream-tracking discipline (see [fork-workflow.md](fork-workflow.md)). Grouping them makes it obvious which directories require `git fetch upstream` in routine work. |
| `_firstparty/` | No upstream to track — no second remote, no rebase dance. Distinct directory makes that obvious at a glance. |
| `_readonly/` | Cloned for reference (reading source, running examples) but not for modification. Distinct directory prevents accidental commits and keeps `git status` quiet during global scans. |

## Per-project conventions

Inside each project, prefer per-project virtual environments and
toolchain files rather than relying on host state:

| Stack | Convention |
| --- | --- |
| Python | `.venv/` inside the project, created with `uv venv` or `python3 -m venv .venv`. |
| Node | `node_modules/` inside the project; toolchain via [`mise`](https://mise.jdx.dev) per `~/.config/mise/config.toml`. |
| Rust | per-project `target/` directory (the cargo default). |

Per-project files **must not** leak into `$HOME` or `~/.local/bin`.

## What does NOT go in `$HOME/_work/repos/`

- Generated artifacts you would `rm -rf` without thinking — those go in a per-project `target/`, `dist/`, `build/`, or `.cache/`.
- Scratch experiments unrelated to any tracked repo — those go in `$HOME/_work/scratch/` or `$HOME/_work/personal/`.
- Anything you would not commit. Lockfiles, package manifests, and CI configs are tracked; one-off `.env.local` is not.

## Devcontainer interaction

The base devcontainer at `$HOME/.devcontainer/devcontainer.json` mounts
the project directory, not all of `$HOME`. Files written outside the
project tree are invisible inside the container — keep work inside the
project root.

## See also

- [`fork-workflow.md`](fork-workflow.md) — what `_forks/` requires.
- [`self-hosted-runner.md`](self-hosted-runner.md) — where runner state
  lives and why it isn't in `_work/`.
