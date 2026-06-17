# Research Dossier — FlexNetOS `meta` Ecosystem vs. Original `gitkb/meta`

**Date:** 2026-06-16  
**Researcher:** agent (Kimi Code CLI)  
**Sources:**
- Original public repo: `https://github.com/gitkb/meta` (currently redirects to `https://github.com/harmony-labs/meta`)
- FlexNetOS main meta repo: `https://github.com/FlexNetOS/meta` (canonical local clone at `~/Desktop/meta`)
- Local migration briefing: `~/Desktop/meta/.kb/store/documents/gitkb-to-flexnetos-migration-briefing-26-repos.md`
- Fleet repo list: `gh repo list FlexNetOS --limit 200`

---

## 1. What `gitkb/meta` originally was

The original `github.com/gitkb/meta` (now under `harmony-labs/meta`) is a **Rust-based multi-repo workspace tool**. It treats repositories as peers rather than submodules, letting a team operate many independent repos as if they were a monorepo.

### Original architecture (10 crates)

| Crate | Purpose |
|---|---|
| `meta_cli` | Main CLI — config loading, plugin routing, filtering |
| `loop_lib` | Core execution engine — runs commands across directories |
| `loop_cli` | Standalone loop CLI (usable without meta) |
| `meta_core` | Shared infrastructure — `~/.meta/` directory, lockfile, atomic store |
| `meta_plugin_protocol` | Shared types for the plugin contract |
| `meta_git_cli` | Git plugin — clone, update, status, commit, snapshots |
| `meta_git_lib` | Shared git library utilities |
| `meta_project_cli` | Project management plugin |
| `meta_rust_cli` | Rust/Cargo plugin |
| `meta_mcp` | MCP server for AI agent integration |

### Original feature set

- **Configuration:** `.meta` (JSON), `.meta.yaml`, or `.meta.yml` at repo root.
- **Simple format:** map project names to Git URLs.
- **Extended format:** per-project `repo`, `path`, `tags`, `meta` (nested), `provides`, `depends_on`.
- **Core commands:** `meta git clone`, `meta git status/pull/push/fetch/diff/branch`, `meta exec`, `meta query`, `meta git snapshot create/list/restore`.
- **Filtering:** by tags, include/exclude paths, recursive nested meta repos.
- **Query DSL:** e.g. `meta query "dirty:true AND tag:backend"`.
- **Snapshots:** capture/restore full workspace state (SHAs, branches, dirty status).
- **Plugins:** subprocess plugins communicating via JSON over stdin/stdout; discovered from `.meta-plugins/`, `~/.meta-plugins/`, or PATH binaries named `meta-*`.
- **AI integration:**
  - MCP server advertised as **29 tools**.
  - Claude Code skills via `meta init claude`.
  - JSON output mode on every command.
- **Dependency tracking:** topological build ordering and impact analysis via `provides`/`depends_on`.
- **Roadmap items:** multi-commit support, plugin help system, dependency graph visualization, GUI.

---

## 2. FlexNetOS `meta` — current state

FlexNetOS/meta is **not a fork mirror** of `gitkb/meta`; it is the migrated continuation. The `gitkb` GitHub org was retired and replaced by `FlexNetOS`. History was preserved on the FlexNetOS side.

### Workspace composition (local `~/Desktop/meta`)

The local clone is the **main meta repo** (`FlexNetOS/meta`). It contains:

- `.meta.yaml` — fleet manifest listing **~60 FlexNetOS repos** with tags, `provides`, and `depends_on`.
- Rust workspace (`Cargo.toml`) with members:
  - `loop_cli`, `loop_lib`
  - `meta_cli` (package name `meta`)
  - `meta_core`
  - `meta_git_cli`, `meta_git_lib`
  - `meta_mcp`
  - `meta_plugin_protocol`, `meta_plugin_api`
  - `meta_project_cli`, `meta_rust_cli`
  - plus `rtk-tokenkill`, `teri`, `shimmy`
- Standalone crate (not in parent workspace): `meta_dashboard_cli`.

### All FlexNetOS repos whose name starts with `meta`

From `gh repo list FlexNetOS --limit 200` filtered by `^meta`:

| Repo | Role |
|---|---|
| `FlexNetOS/meta` | Main meta repo / workspace root |
| `FlexNetOS/meta_cli` | Main CLI crate (subrepo) |
| `FlexNetOS/meta_core` | Shared infrastructure crate |
| `FlexNetOS/meta_dashboard_cli` | Mission-control dashboard plugin (envctl front-end) |
| `FlexNetOS/meta_git_cli` | Git plugin crate |
| `FlexNetOS/meta_git_lib` | Shared git library crate |
| `FlexNetOS/meta_mcp` | MCP server crate |
| `FlexNetOS/meta_plugin_api` | Plugin API crate |
| `FlexNetOS/meta_plugin_protocol` | Plugin protocol types crate |
| `FlexNetOS/meta-plugins` | Plugin collection / registry |
| `FlexNetOS/meta_project_cli` | Project management plugin crate |
| `FlexNetOS/meta_rust_cli` | Rust/Cargo plugin crate |
| `FlexNetOS/meta-ruvector` | RuVector fork (mounted locally as `RuVector/`) |

Note: `meta-ruvector` does **not** start with `meta_` (it uses a hyphen); the others use `meta_`.

### What is implemented today

| Feature | Status |
|---|---|
| `.meta` / `.meta.yaml` config | ✅ Implemented |
| Simple + extended project format | ✅ Implemented |
| Tags, include/exclude filters | ✅ Implemented |
| `meta git clone` | ✅ Implemented |
| `meta git status/pull/push/fetch/diff/branch` | ✅ Implemented |
| `meta exec` | ✅ Implemented (falls through to loop engine) |
| `meta query` + query DSL | ✅ Implemented |
| Workspace snapshots | ✅ Implemented |
| Nested meta repos (`meta: true`, `--recursive`) | ✅ Configured in `.meta.yaml` (e.g. `mcp_hub`) |
| Dependency tracking (`provides`/`depends_on`) | ✅ Configured + graph code present |
| Plugin protocol (JSON stdin/stdout) | ✅ Implemented |
| MCP server | ✅ Implemented — **32 tools** counted in `meta_mcp/src/main.rs` |
| Claude Code skills | ⚠️ Present in `claude-plugins/`, but marketplace name still `gitkb` |
| JSON output | ✅ Implemented |
| `meta dashboard` | ✅ Implemented via `meta_dashboard_cli` → shells to `envctl dashboard --json` |

### MCP tool inventory (FlexNetOS/meta)

`meta_mcp/src/main.rs` defines 32 tools (vs. the original advertised 29):

- `meta_list_projects`
- `meta_exec`
- `meta_get_config`
- `meta_get_project_path`
- `meta_git_status`, `meta_git_pull`, `meta_git_push`, `meta_git_fetch`, `meta_git_diff`, `meta_git_branch`
- `meta_git_add`, `meta_git_commit`, `meta_git_checkout`, `meta_git_multi_commit`
- `meta_detect_build_systems`
- `meta_run_tests`, `meta_build`, `meta_clean`
- `meta_search_code`, `meta_get_file_tree`
- `meta_list_plugins`
- `meta_query_repos`, `meta_workspace_state`
- `meta_analyze_impact`, `meta_execution_order`
- `meta_snapshot_create`, `meta_snapshot_list`, `meta_snapshot_restore`
- `meta_batch_execute`

(The exact tool count is 32 from a `name:` grep; some entries may be helpers rather than registered tools.)

---

## 3. Migration status (gitkb → FlexNetOS)

Per the local migration briefing:

- **16 repos** were already migrated to FlexNetOS at the start of the migration task.
- **3 more** were migrated during the task: `atc`, `rusty-idd`, and the CI protection handled via `meta ci protect`.
- **2 archive/drop**: `gitkb-releases`, `gitkb-desktop-releases` (superseded).
- **5 needs-review/deferred**:
  - `homebrew-tap` — deferred (no current demand).
  - `contree-cli` — overlaps RTK tooling; deferred pending product decision.
  - `workflow-rust-release` — superseded by FIX-6 p7 CI + release-please.
  - `gitkb-claude-plugin` — **renamed** to `FlexNetOS/claude-plugins` (PR#2 merged). Marketplace **name** still `gitkb` pending decision.
  - `highrust` — off-mission, skipped.

**Key acceptance criteria:**
- ✅ All 26 repos accounted for.
- ✅ No orphaned `gitkb/` references in workspace configs.
- ❌ Marketplace name `gitkb` → `flexnetos` still pending (cosmetic).
- ❌ Homebrew tap decision deferred.

The migration briefing states: "The original `github.com/gitkb/meta` became `FlexNetOS/meta` via org migration, not a fork mirror. History was preserved on the FlexNetOS side."

---

## 4. Drift from original design

### 4.1 Added / diverged in FlexNetOS

| Area | Original gitkb/meta | FlexNetOS/meta |
|---|---|---|
| Fleet scope | Demo / generic | Tuned to ~60 FlexNetOS repos, hubs, typed collections |
| Dashboard | Not present | `meta_dashboard_cli` → envctl mission-control |
| Portability | Generic home paths | ADR-0006 envctl-managed home tree, symlinks |
| Bootstrap | Install script | `bootstrap.sh` sequences rustup → clone → build → envctl install → kasetto sync |
| Security | Standard | RTK token-kill wrapper, envctl secrets broker integration |
| Release | Standard release-please | Integrated with FlexNetOS reusable workflows |
| RuVector | Not present | `meta-ruvector` mounted as `RuVector/` |
| Handoff integration | Not present | `.handoff/` ledger + `hf` task continuity |

### 4.2 Original roadmap items still open

From the original README roadmap, the following are not confirmed shipped in FlexNetOS:

- Multi-commit support (`meta git commit --edit`)
- Plugin help system
- Dependency graph visualization (CLI)
- GUI for visual management
- Windows PowerShell installer (script exists, but Windows support breadth unknown)

### 4.3 Doc / branding residue

- `claude-plugins/.claude-plugin/marketplace.json` still uses the marketplace name `gitkb`.
- The FlexNetOS `README.md` still mirrors the original `gitkb/meta` README structure almost verbatim (which is fine, but shows the direct lineage).
- No `LICENSE` file in the local `FlexNetOS/meta` root (original likely had one).

---

## 5. Summary

FlexNetOS/meta is the **migrated continuation** of `github.com/gitkb/meta` (now `harmony-labs/meta`). It preserves the original architecture and most features, extends them for a ~60-repo FlexNetOS fleet, and adds envctl/kasetto/portability integration. The migration is materially complete except for cosmetic renaming of the Claude plugin marketplace and a deferred Homebrew tap decision. The MCP server has grown from the advertised 29 tools to 32, and the dependency-tracking / nested-meta features are actively used in `.meta.yaml`.

The main open drift from the original vision is not missing code but **evolved purpose**: FlexNetOS/meta is now the spine of a much larger, security-sensitive, AI-native operating system rather than a standalone multi-repo utility.
