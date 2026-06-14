# 12 — The `meta*` repos: the control-plane crate family

This document walks the eleven `meta*` repositories that **implement** the control plane mapped in
[`01-meta-control-plane.md`](01-meta-control-plane.md). Together they realize one architecture: a
**host CLI** (`meta`, crate `meta_cli`) that discovers and dispatches to **subprocess plugins**
(`meta-git`, `meta-project`, `meta-rust`, `meta-dashboard`) over the JSON IPC defined by
`meta_plugin_protocol`. The host owns `.meta.yaml` parsing + cross-repo state (via `meta_core`),
each plugin is a standalone binary that returns an `ExecutionPlan` the host runs with `loop_lib`,
and `meta_mcp` re-exports the same host library surface to AI tools over MCP. The legacy in-process
`meta_plugin_api` trait is superseded by the subprocess protocol but still ships, and `meta-plugins`
is the GitHub registry the host installs third-party plugins from. Crate-name = `RUST_LOG` target
throughout (see the umbrella `CLAUDE.md`).

> Versioning note: every workspace member inherits `version.workspace = true` from the meta root
> `Cargo.toml` (currently **`0.2.24`**). The two repos that pin their own version
> (`meta_plugin_api 0.1.0`, `meta_dashboard_cli 0.1.0`) build as standalone workspaces and version
> independently — both are outside the original canon (see [§ Confirmations](#confirmations--challenges)).

## Summary table

| Repo | Crate name(s) | Version | Role | bin/lib | Key internal deps (other `meta*` / `loop_*`) |
|---|---|---|---|---|---|
| `meta_cli` | pkg `meta`, lib `meta_cli` | `0.2.24` (ws) | **Host CLI** — discovery + dispatch + registry + worktree + context | bin `meta` + lib | `meta_core`, `meta_plugin_protocol`, `loop_lib` |
| `meta_core` | `meta_core` | `0.2.24` (ws) | `~/.meta/` data dir, file lock, atomic JSON store, **`.meta.yaml` config types** | lib | *(none — base layer)* |
| `meta_plugin_protocol` | `meta_plugin_protocol` | `0.2.24` (ws) | **Host↔plugin JSON contract** + `run_plugin()` harness | lib | *(none — base layer)* |
| `meta_plugin_api` | `meta_plugin_api` | `0.1.0` | **Legacy** in-process `Plugin` trait (`dlopen` model) — superseded/stub | lib | *(none)* |
| `meta_git_lib` | `meta_git_lib` | `0.2.24` (ws) | Reusable git primitives: clone queue, snapshot, SSH multiplexing, worktree | lib | `meta_core`, `meta_cli`, `loop_lib` |
| `meta_git_cli` | pkg+lib `meta_git_cli`, bin `meta-git` | `0.2.24` (ws) | **Git plugin** | bin `meta-git` + lib | `meta_plugin_protocol`, `meta_core`, `meta_git_lib`, `meta_cli`, `loop_lib` |
| `meta_project_cli` | pkg+lib `meta_project_cli`, bin `meta-project` | `0.2.24` (ws) | **Project plugin** (inspect `.meta.yaml`, dep graph) | bin `meta-project` + lib | `meta_plugin_protocol`, `meta_git_lib`, `meta_cli` |
| `meta_rust_cli` | pkg+lib `meta_rust_cli`, bin `meta-rust` | `0.2.24` (ws) | **Rust/cargo plugin** | bin `meta-rust` + lib | `meta_plugin_protocol`, `meta_core` |
| `meta_mcp` | `meta-mcp` | `0.2.24` (ws) | **MCP server** — exposes host ops to AI tools | bin `meta-mcp` | `meta_core`, `meta_cli` (lib) |
| `meta_dashboard_cli` | pkg+lib `meta_dashboard_cli`, bin `meta-dashboard` | `0.1.0` | **Dashboard plugin** — shells to `envctl dashboard --json` | bin `meta-dashboard` + lib | `meta_plugin_protocol` |
| `meta-plugins` | *(no crate — registry data)* | n/a | **Plugin registry** (name → `owner/repo` map) | data repo | *(consumed by `meta_cli::registry`)* |

## meta_cli — the host CLI (`meta`)

The mature orchestrator. Package `meta` (binary `meta`) plus library `meta_cli`; modules
`config`, `context`, `dependency_graph`, `git_utils`, `query`, `subprocess_plugins`, `worktree`
(re-exported from `lib.rs`), with `main.rs`, `registry.rs`, `init.rs` private to the binary.
Built-in host verbs are `meta context`, `meta exec`, `meta init` (`claude` / `ollama` skill
installers), and `meta plugin` (`search` / `install` / …); everything else is an
**external subcommand** dispatched to a plugin. Plugin discovery is the documented 3-layer,
first-match-wins order in `subprocess_plugins.rs`: `.meta/plugins/` walking up from cwd →
`~/.meta/plugins/` → `PATH`. It invokes a plugin with `--meta-plugin-exec`, feeds it a
`PluginRequest` JSON on stdin, receives a `PlanResponse`/`ExecutionPlan`, and executes the planned
commands through `loop_lib`'s rayon engine (honoring `parallel` / `max_parallel` /
`spawn_stagger_ms`). `registry.rs` points at `DEFAULT_REGISTRY =
https://raw.githubusercontent.com/FlexNetOS/meta-plugins/main` with `PLUGIN_PREFIX = "meta-"`,
wiring the host to the `meta-plugins` registry repo.

## meta_core — base infrastructure + `.meta.yaml` config

The dependency-free base layer (`anyhow`, `dirs`, `serde`, on unix `libc`). Three duties documented
in `lib.rs`: `data_dir` (locate/create `~/.meta/`, overridable via `META_DATA_DIR`), `lock`
(PID-aware file lock with staleness detection + retry), and `store` (atomic lock-protected JSON
read/write). Critically, **`config.rs` owns `.meta` config parsing** — the `ProjectInfo` /
`MetaConfig` / `MetaDefaults` types and the `.meta` → `.meta.json` → `.meta.yaml` → `.meta.yml`
discovery order, including the `tags` / `provides` / `depends_on` / `meta` (nested) fields that the
project plugin's dependency graph reads. `meta_cli`, `meta_git_lib`, `meta_rust_cli`, and
`meta_mcp` all depend on it; it depends on nothing in the family. Git log shows recent CI work
(semantic-PR-title gate, Renovate, re-pointing the dead gitkb org to FlexNetOS).

## meta_plugin_protocol — the host↔plugin contract (SOLID)

The single source of truth for the IPC, and the most load-bearing crate after the host. Defines
`PluginInfo` (name / version / `commands` / `description` / `PluginHelp`), `PluginRequest` +
`PluginRequestOptions` (`json_output`, `verbose`, `parallel`, `dry_run`, `silent`, `recursive`,
`depth`, `include_filters`, `exclude_filters`, `strict`), and the response side `ExecutionPlan` /
`PlannedCommand` / `PlanResponse` (with `pre_commands` / `post_commands`, and the
`parallel` / `max_parallel` / `spawn_stagger_ms` tuning that maps straight onto `loop_lib`'s
`LoopConfig`). The protocol header documents the 3-step flow: discover via `--meta-plugin-info`,
invoke via `--meta-plugin-exec` (request on stdin), respond with a plan or direct output. It also
ships the **`run_plugin(PluginDefinition)` harness** that eliminates each plugin's `main()`
boilerplate, dispatches `--meta-plugin-info` / `--meta-plugin-exec` / `--help`, and calls
`env_logger::init()` so a plugin inherits `RUST_LOG` from the host (the crate-name=target rule).
Every plugin binary depends on it.

## meta_plugin_api — legacy in-process trait (superseded)

A tiny crate (`src/lib.rs`, ~109 lines, deps just `thiserror` + `anyhow`) defining the **old**
dynamic-library plugin model: a `Plugin` trait (`name` / `commands` / `execute` / `get_help_output`
with a `HelpMode` of `Override`/`Prepend`/`None`), a `PluginError`, and an unsafe
`PluginCreate = unsafe fn() -> *mut dyn Plugin` `dlopen`-style constructor. It is **not** referenced
by any other `meta*` crate (no reverse deps) — the subprocess `meta_plugin_protocol` replaced it. It
pins its own `0.1.0`, has no CI workflows, and the canon marks it **STUB / superseded** with archive
as the preferred disposition.

## meta_git_lib — reusable git primitives

A library (no binary) of the heavy git mechanics the git plugin orchestrates: `clone_queue`
(batched clone with progress), `snapshot`, `ssh_multiplexing` (ControlMaster socket dir, URL
normalization/matching, rate-limit detection — re-exported from `lib.rs`), `missing`, and a
`worktree/` submodule. Notably it depends **on `meta_cli` itself** (`package = "meta"`) plus
`meta_core` and `loop_lib`, so it sits *above* the host library — it is consumed by the git and
project plugins, not by the host binary's dispatch path.

## meta_git_cli — the git plugin (`meta-git`)

The richest plugin. Binary `meta-git` + library `meta_git_cli`; modules `clone`, `clone_worker`,
`commit`, `git_env`, `snapshot`, `ssh`, `ssh_setup`, `status`, `update`, plus a `commands/`
subtree. Its `PluginInfo` declares `name: "git"` and a large verb set — verbatim:
**`git clone`, `git status`, `git update`, `git commit`, `git snapshot` (+ `create`/`list`/`show`/
`restore`/`delete`), `git worktree` (+ `create`/`add`/`remove`/`destroy`/`list`/`status`/`diff`/
`exec`/`prune`)**. Help splits these into *Adapted Commands* (meta-specific: `clone`, `commit`,
`update`, `snapshot`, `worktree`) vs *Pass-through Commands* (`status` and any unlisted git verb via
`meta exec -- git <cmd>`). It depends on the full chain — `meta_plugin_protocol`, `meta_core`,
`meta_git_lib`, `meta_cli`, `loop_lib` — and emits `ExecutionPlan`s with `pre_commands` to set up
SSH ControlMaster before parallel clones.

## meta_project_cli — the project plugin (`meta-project`)

Binary `meta-project` + library `meta_project_cli` (logic concentrated in a ~51K `lib.rs`). Reads
`.meta.yaml` (via `meta_core::config` types) and reports on the workspace. `PluginInfo`
`name: "project"`, verbs verbatim: **`project list`, `project ls`, `project check`,
`project dependents`** — list all configured projects (`ls` alias), verify they are cloned/consistent
(`check`), and walk the `depends_on` graph to find dependents. A recent commit exposed linked
worktree context in `project list`. Depends on `meta_plugin_protocol`, `meta_git_lib`, and
`meta_cli`.

## meta_rust_cli — the rust plugin (`meta-rust`)

The smallest functional plugin. Binary `meta-rust` + library `meta_rust_cli`. `PluginInfo`
`name: "rust"`, verbs verbatim: **`cargo build`, `cargo test`, `rust build`, `rust test`** (so the
host accepts both `meta cargo …` and `meta rust …`). It plans a `cargo` invocation across detected
Rust dirs and notes that raw cargo runs go through `meta exec -- cargo <cmd>`. Depends only on
`meta_plugin_protocol` + `meta_core`.

## meta_mcp — the MCP server (`meta-mcp`)

A binary-only crate (`meta-mcp`) exposing the host's operations to AI tools over the Model Context
Protocol (`PROTOCOL_VERSION = "2024-11-05"`, JSON-RPC over stdio). Rather than re-implement logic,
its `main.rs` **imports the `meta_cli` library directly** (`meta_cli::dependency_graph`,
`::git_utils`, `::query::{Query, RepoState, WorkspaceState}`) plus `meta_core::config`, and wraps
them as ~30 MCP tools: `meta_list_projects`, `meta_exec`, `meta_get_config`,
`meta_get_project_path`, the `meta_git_*` family (`status`/`pull`/`push`/`fetch`/`diff`/`branch`/
`add`/`commit`/`checkout`/`multi_commit`), `meta_detect_build_systems`, `meta_run_tests`,
`meta_build`, `meta_clean`, `meta_search_code`, `meta_get_file_tree`, `meta_list_plugins`,
`meta_query_repos`, `meta_workspace_state`, `meta_analyze_impact`, `meta_execution_order`, and the
`meta_snapshot_*` + `meta_batch_execute` set. It is the AI-facing front of the same control plane
the CLI fronts for humans; canon marks it **newer, not part of the original 10**.

## meta_dashboard_cli — the dashboard plugin (`meta-dashboard`)

A standalone-workspace crate (empty `[workspace]` table so it builds outside the meta tree), binary
`meta-dashboard` + library `meta_dashboard_cli`, pinned `0.1.0`. `PluginInfo` `name: "dashboard"`,
single verb **`dashboard`** (flags `--deploy` / `--apply` / `--force` / `--meta-file <path>`). It
**owns no dashboard logic**: it resolves `envctl` on PATH and shells to `envctl dashboard --json`,
relaying output back to the host (fail-closed if `envctl` is absent). This is loose coupling over a
CLI contract — `meta dashboard` and `envctl dashboard` hit the identical `envctl-engine` code path
and cannot diverge. Its only family dep is `meta_plugin_protocol`. Newest of the family (single
commit). See [`03-envctl-kasetto.md`](03-envctl-kasetto.md) for `envctl`.

## meta-plugins — the plugin registry

Not a crate — a thin **registry data repo** consumed by `meta_cli::registry` (its
`DEFAULT_REGISTRY` URL). `plugins/` holds one file per plugin short-name, each containing a GitHub
shorthand (`owner/repo` or `owner/repo@vX.Y.Z`); `meta plugin install <name>` resolves the name
here and downloads the release asset (`meta-{name}-{platform}.tar.gz`), which must answer
`--meta-plugin-info`. A `validate-plugin.yml` CI workflow checks submitted PRs (repo exists,
asset naming, binary responds to `--meta-plugin-info`, no name conflict). Newer, not part of the
original 10.

## Dependency & plugin wiring

The host never links the plugins; it discovers their binaries and talks JSON to them. Plugins link
the *libraries* (`meta_plugin_protocol`, `meta_core`, `meta_git_lib`, and even the `meta_cli`
library) but reach the host only through the protocol.

```text
                                  ┌────────────────────────────────────────┐
   human ── meta <cmd> ──▶        │            meta_cli  (bin: meta)        │
   AI ── MCP/JSON-RPC ──▶ meta-mcp│  HOST: discover ▸ dispatch ▸ run plan  │
        (links meta_cli lib)      │  built-ins: context · exec · init ·    │
                                  │            plugin {search,install}     │
                                  └───────────────┬────────────────────────┘
                                                  │ uses
                       ┌──────────────────────────┼───────────────────────────┐
                       ▼                          ▼                            ▼
              meta_core (.meta.yaml,      loop_lib (rayon exec      registry.rs ─▶ meta-plugins
              ~/.meta, lock, store)       of ExecutionPlan)            (GitHub registry repo)
                                                  ▲
                                                  │ ExecutionPlan / PlannedCommand
                                                  │
                        ════════ meta_plugin_protocol (JSON IPC) ════════
                         --meta-plugin-info ▸ --meta-plugin-exec (stdin) ▸ PlanResponse
                                                  │
        ┌──────────────────┬──────────────────────┼──────────────────────┐
        ▼                  ▼                       ▼                       ▼
   meta-git           meta-project            meta-rust              meta-dashboard
  (meta_git_cli)    (meta_project_cli)      (meta_rust_cli)        (meta_dashboard_cli)
   git clone/status   project list/ls         cargo build/test       dashboard
   commit/update      check/dependents        rust build/test         │ shells to
   snapshot* /                                                        ▼ envctl dashboard --json
   worktree*          (uses meta_git_lib)                            envctl (map 03)

   superseded path:  meta_plugin_api  (in-process Plugin trait, dlopen) — no reverse deps
```

**Plugins `meta_cli` dispatches to** (external-subcommand → discovered binary `meta-<name>`):
`git` → `meta-git`, `project` → `meta-project`, `rust`/`cargo` → `meta-rust`,
`dashboard` → `meta-dashboard`. Any other name is resolved against installed plugins
(`.meta/plugins` → `~/.meta/plugins` → `PATH`) or installed from the `meta-plugins` registry.
`meta-mcp` is *not* a subprocess plugin — it is a separate AI-facing front door that links the
`meta_cli` **library** and re-exposes the same operations over MCP.

## Confirmations & challenges

- **L1.1 — CONFIRMED.** Each `meta*` directory is its own git repo (independent `git log`, own CI
  history). The root `Cargo.toml` is a dev-convenience workspace supplying
  `version.workspace = true` (`0.2.24`); `meta_dashboard_cli` proves the independence by carrying an
  **empty `[workspace]` table** so it builds standalone, and `meta_plugin_api` self-pins `0.1.0`.
- **"No second `loop_lib`; path-dep'd by `meta_cli`/`meta_git_cli`" — CONFIRMED for the meta family.**
  `meta_cli`, `meta_git_lib`, and `meta_git_cli` all `loop_lib = { path = "../loop_lib" }`; no
  `meta*` repo vendors its own copy. (`loop_lib`/`loop_cli` were out of scope for this walk — the
  canon's "v0.2.22 / consumed by `loop_cli`" claim was not re-verified here.)
- **"`meta_dashboard_cli` / `meta_mcp` / `meta-plugins` are NEWER, outside the original 10" —
  CONFIRMED.** All three show shallow/recent history (`meta_dashboard_cli` = a single commit;
  `meta-plugins` is a data repo, not a crate; `meta_mcp` boots an MCP server). They follow the
  family conventions but are not in the canon-10. `meta_plugin_api` is confirmed the superseded
  legacy stub with zero reverse deps.

## Cross-references

- [`01-meta-control-plane.md`](01-meta-control-plane.md) — the canon these crates implement: the
  meta-architecture-canon (the original 10), the 3-layer plugin discovery, `loop_lib` parallelism,
  and the compliant-member conventions.
- [`00-overview.md`](00-overview.md) — the one-screen estate model and where the control plane sits
  among the five planes.
- [`03-envctl-kasetto.md`](03-envctl-kasetto.md) — `envctl`, which `meta-dashboard` shells to.
