# ADR-0004 — Cross-Platform CI Strategy (phase-tiered, target-triple-aware, not desktop-OS-matrix)

- **Status:** accepted
- **Date:** 2026-06-18
- **Deciders:** owner (FlexNetOS), `.github_org` session
- **Relates to:** [ADR-0002](ADR-0002-lean-github-org-relocate-to-hubs.md) (lean `.github_org`,
  typed hubs), [ADR-0003](ADR-0003-dev-git-workflow-policy.md) (trunk `develop` / protected
  `main`, the reusable-CI promotion model), the fleet-wide Rust-port harness (ADR-0001 in the
  meta-fleet namespace)
- **Namespace note:** this is the **`.github_org`-local** ADR series
  (`architecture/adr/ADR-000N`), distinct from the meta-fleet ADR series. Numbers collide across
  namespaces by design (there is also a meta-fleet `ADR-0004` for the single fleet ledger); cite
  the repo when in doubt.

## Context

### The trigger

A `windows-latest`-only test failure in `FlexNetOS/handoff` red-lit the `develop` trunk and
blocked the `develop→master` promotion gate. The failure was **not a real defect**: the test
hard-coded `".handoff/ledger.db"` while production code builds the path with `Path::join`, which
yields `.handoff\ledger.db` on Windows — a perfectly valid path. A desktop-OS matrix manufactured
a trunk-blocking failure for a platform the artifact may never actually run on, while the
authoring agents were repeatedly override-merging past it. That is the worst CI failure mode:
**red that everyone is trained to ignore.**

This forced the real question: *should every repo run a `windows` + `macos` + `ubuntu` test
matrix?*

### Ground truth at decision time (owner-stated, not aspirational)

1. **The fleet is not close to release.** Repos are still fragmented pre-consolidation building
   blocks.
2. **The end goal is a single application.** Repos will be consolidated over time.
3. **That single app must run cross-platform — and "cross-platform" includes the hard targets:**
   desktop (Linux/macOS/Windows), **mobile** (iOS/Android), and **ESP32** (embedded, `no_std`).
4. **Every repo the project touches is heavy Rust / crates.** The few non-Rust repos are
   **temporary** — port candidates slated for rewrite to Rust, not maintained targets.

### Why the desktop-OS matrix is the wrong investment for this north star

A `windows`/`macos`/`ubuntu` **test** matrix gives **zero** signal about the two hardest targets,
because they are not "just another OS":

- **ESP32 is `no_std`, C-dependency-hostile, and cross-compiled** — never *run* in CI. The signal
  that matters is `cargo check --no-default-features --target <embedded-triple>`, which a desktop
  matrix never exercises.
- **Mobile is cross-compiled target triples** (`aarch64-apple-ios`, `aarch64-linux-android`) —
  also *built*, not *run* in ordinary CI.

So a per-repo desktop matrix is simultaneously **too much** (three desktop OSes, paid N× across
fragments that don't ship yet) and **too little** (no embedded/mobile/wasm target coverage at
all). It pays for the easy 80% and ignores the hard 20% that actually decides whether
one-app-everywhere is feasible.

### The expensive thing is architecture, not CI config

To reach ESP32 + mobile + desktop from one codebase, the **core logic must be portable** —
`no_std`-compatible (or `std`-optional), with platform/IO behind `cfg`/traits, and **no C
dependencies in the core**. That discipline is cheap to keep and brutal to retrofit. A desktop
matrix happily goes green on code that can never reach an ESP32. Concrete live example: handoff
issue **#71** ("port ledger off C-SQLite / rusqlite") — `rusqlite` is a C library writing a
`std` file DB; it **cannot** target ESP32 or wasm. #71 is therefore not cleanup, it is a
**north-star prerequisite**. The same caution applies to any C/asm-backed dependency in a core
crate (e.g. `ring`-backed TLS): fine on desktop, a hard blocker on `no_std`/wasm.

## Decision

**CI coverage is tiered by project phase, not guessed per-repo, and is expressed in
target-triples — not in runner OSes. Architectural portability is enforced cheaply now so that
turning on full coverage at consolidation is a config change, not a rewrite.**

### D1 — Phase A (now, pre-consolidation): Linux-only test + portability check

For every Rust repo in the fleet:

1. **Test on `ubuntu-latest` only**, on every PR and on trunk pushes. Fast, cheap, the single
   source of "does it work" feedback. **Do not** run `windows`/`macos` test legs per-repo in
   Phase A.
2. **Portability check** for any crate destined for the on-device core: a non-blocking-first,
   then-STRICT (per ADR-0003 report-only→strict promotion) job running
   `cargo check --no-default-features --target <portability canary>`. The canaries are the cheap,
   upstream-toolchain targets:
   - `wasm32-unknown-unknown` — the best `std`/alloc-leak and C-dependency canary; pure upstream.
   - `riscv32imc-unknown-none-elf` — upstream `no_std` ESP32-class (RISC-V) canary.
   These catch `std`/C-dependency leakage early **without** needing the Espressif toolchain.

### D2 — Phase B (at consolidation): full matrix, in the one repo that ships

When the single application repo exists, it — and only it — runs:

- **Desktop test matrix:** `ubuntu-latest`, `macos-latest`, `windows-latest` (genuine
  cross-platform *run* coverage, paid once).
- **Mobile build matrix:** `aarch64-apple-ios`, `aarch64-linux-android` (`cargo check`/`build`,
  not run).
- **ESP32 build matrix:** RISC-V on upstream (`riscv32imc-unknown-none-elf`, `esp32c3/c6/h2`);
  Xtensa (`xtensa-esp32-none-elf`, `esp32/s2/s3`) via the Espressif rustc fork (`espup`), which is
  **not** on upstream stable — kept as a clearly-labelled separate job.

Component repos that have not yet been consolidated stay on Phase A. Coverage is paid **once, in
the shipping repo**, never N× across fragments.

### D3 — Architectural portability rules (enforced from now)

These make D1/D2 meaningful; they are reviewable rules, not just CI:

- **Core crates are `no_std` + `alloc`**, with `std` behind an (often default-on) feature. Phase-A
  default builds stay `std`/Linux-green; the portability canary builds `--no-default-features`.
- **No C dependencies and no host-FFI in core crates** (the rusqlite/#71 and C/asm-crypto lesson).
  Platform-specific and `std`-only dependencies live behind `cfg`/feature gates or in leaf
  platform crates, never in portable cores.
- **No `std`-file-backed databases in core** — embeddable, pure-Rust, storage-abstracted
  alternatives only (directly: handoff #71).

### D4 — Mechanism: one reusable workflow, Linux-default

CI policy is centralized in this repo's reusable-CI templates (ADR-0003, role #5), **not**
copy-pasted per repo. A `reusable-rust-ci.yml` exposes inputs (e.g. `os` / `targets` /
`portability-targets`) that **default to Linux-only**. Phase A repos consume it with defaults;
the Phase B single-app repo flips on the full matrix via inputs — **one config line, not a
rewrite**. This also closes the drift class that caused the trigger (handoff's `ci.yml` and
`promote-verify.yml` had diverged checkout layouts).

### D5 — Temporary / non-Rust repos

Repos that are not Rust are **temporary port candidates** (ADR-0001 rust-port harness territory),
not maintained targets. They get **minimal or no** CI investment — no matrix, no portability
gate. Effort goes into porting them to Rust, after which they fall under D1.

## Consequences

**Positive**

- Phase-A CI cost drops ~3× (one OS instead of three) across the whole fleet, with **faster**
  trunk feedback and far fewer false-red trunk blocks.
- The *real* cross-platform risk (portability / `no_std` / C-dependency leakage) gets a cheap,
  early, upstream-toolchain signal that the desktop matrix never provided.
- Consolidation is de-risked: portable-core discipline + a one-line matrix flip, instead of a
  late, expensive cross-platform retrofit.
- One reusable workflow ends per-repo CI drift.

**Negative / costs**

- Phase A loses desktop-OS *run* coverage on macOS/Windows for component repos. Accepted: those
  repos do not ship to end users yet, and genuine portability regressions are caught by the
  target-triple canary (compile) and, later, the Phase B matrix (run).
- The portability canary will surface latent non-portable dependencies (rusqlite, C/asm crypto)
  as real work — that is the point; they are north-star blockers regardless.
- The Espressif (Xtensa) toolchain is off-upstream and will need its own maintained CI lane in
  Phase B.

**Follow-up work (not part of accepting this ADR)**

1. Author `reusable-rust-ci.yml` (Linux-default; `os`/`targets`/`portability-targets` inputs) per
   the `new-reusable-workflow` skill + ADR-0003 report-only→STRICT promotion.
2. Migrate `handoff` (drop the per-repo `windows`/`macos` test legs to Phase A; keep the
   `promote-verify` layout fix from PR #87) and `prompt_hub` as the first consumers.
3. Track core-crate portability blockers explicitly (handoff #71 rusqlite; audit `ring`-backed
   TLS and other C/asm deps in core crates).
