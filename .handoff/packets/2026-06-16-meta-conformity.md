---
schema: handoff.packet.v1
id: PACKET-2026-06-16-006
session: SESSION-2026-06-16-006
branch: feat/handoff-meta-conformity
plane: org-ops
tier: D
status: in-flight
---

# `.github_org` meta-conformity + develop-CI unblock

## Mission
Finish the transformation of `FlexNetOS/.github` (checked out as `.github_org`)
so it conforms to the meta-workspace conventions:

1. `.handoff` continuity layer is present and correctly configured.
2. The repo is registered in the meta workspace registry.
3. Legacy loop state (`TODO.md` / `SESSIONS.md`) is migrated into a handoff packet
   and the stale `docs/meta-foundation-confirmation` loop is closed.
4. The `develop` CI blocker (`security / Trivy filesystem + IaC`) is fixed.

## What was already true before this packet

- `github_org` is already registered in `/home/drdave/Desktop/meta/.meta.yaml`
  (lines 111–114) with `path: .github_org` and `tags: [org, ci]`. **P1.2 satisfied.**
- PR #108 (meta-foundation confirmation P1–P7) was squash-merged to `develop`
  at `62a7876`. Remote branch `docs/meta-foundation-confirmation` was deleted.
- `.handoff/context/capsule.json` and `.handoff/README.md` were created on
  `feat/handoff-meta-conformity`.

## What this packet adds

### `.handoff` hygiene
- `.gitignore` updated so that `.handoff/packets/` is **no longer ignored**;
  only the local render surface `.handoff/active.md` and auto-generated
  `.handoff/packets/latest.md` / `ledger.db` stay ignored.

### Trivy false-positive suppression (CI unblock)
- `trivy-secret.yaml` — global `allow-rules` entry that skips secret findings
  in `data/brain-data/research/.*/repomix-pack.*\.xml$`. These repomix archives
  are upstream research packs; their example/test credential strings are not
  real secrets (mirrors the existing `.gitleaks.toml` exemption).
- `scripts/tests/test-trivy-secret-suppressions.sh` — triple-verify contract
  test:
  1. `trivy-secret.yaml` is loaded (`config_path="trivy-secret.yaml"`).
  2. No `CRITICAL: stripe-secret-token` findings remain.
  3. No CRITICAL findings remain in research repomix paths.
- `.github/workflows/reusable-security.yml` — passes
  `--secret-config trivy-secret.yaml` explicitly to the `trivy fs` invocation.
- `.github/workflows/manifest-drift.yml` — runs the contract test as a
  report-only job for its first green cycle.

### Legacy loop-state migration
- This packet captures the carry-forward state from `TODO.md` and `SESSIONS.md`
  as of `SESSION-2026-06-16-006`.
- `TODO.md` header is refreshed to reflect the current branch and mission.
- `SESSIONS.md` gets a new `SESSION-2026-06-16-006` entry that closes the stale
  `docs/meta-foundation-confirmation` loop and hands off to `.handoff`.

## Why this unblocks `develop`

The latest `develop` push failed because `security / Trivy filesystem + IaC`
reported 3 CRITICAL `stripe-secret-token` findings in
`data/brain-data/research/n8n-mcp/repomix-pack.xml`:

```text
'ValidApiKey123',
'VALID_API_KEY_456',
'sk_test_...',
```

These are upstream n8n test fixtures. With the allow-rule in place, Trivy
reports zero secret findings and the job exits clean, which allows
`promote-develop-to-main.yml` to open the perpetual `develop → main` promotion
PR and lets release-please propose `v1.0.0`.

## Open backlog (remains in `TODO.md`)

Only the deferred/human-gated items are carried forward; the meta-conformity
items in this packet are the current active mission.

- CI-failure autofix loop (build after tracker has one green cycle).
- `.claude/settings.json` G8 trim (human-env change: relocate marketplace paths).
- Adoption dossier reviews (`ai-top-utility.md`, `n8n.md`, `fabro.md`, `paperclip.md`).
- Fork/adoption execution (gated on human go/no-go).
- n8n + n8n-mcp service persistence.
- MANIFEST ↔ `.gitmodules` materialize/lockfile refactor (G4/G5 open question).

## Reservations / risks

- `trivy-secret.yaml` uses an `allow-rules` path regex; if the research archive
  layout changes, the rule must be updated. The contract test catches regressions.
- The new `manifest-drift.yml` job is report-only for one cycle; promote it to
  STRICT after it goes green on `develop`.
- No submodule mutations, no host installs, no secrets committed.

## Next commands

1. ✅ `make verify` on `feat/handoff-meta-conformity`.
2. ✅ Push and open PR #111 to `develop`.
3. After merge, watch `security / Trivy filesystem + IaC` on `develop`; once
   green, confirm `promote-develop-to-main.yml` creates the promotion PR.
