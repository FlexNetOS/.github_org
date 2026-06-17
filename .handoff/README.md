# .handoff — continuity layer

This directory is the per-repo continuity layer for the FlexNetOS `.github` umbrella
(META-ORG-POLICY.md **P7**).

- `context/capsule.json` — who this repo is, its tier/plane, north star, and next command.
  Keep it accurate; code wins over prose.
- `tasks/` — execution cards minted from kb planning tasks (`hf task mint --from-kb`).
  Empty until kb tasks are scoped for `.github_org`; the packet degrades to
  "(no open cards)".
- `packets/` — resume packets compiled by `hf fleet render .github` from the FLEET
  ledger + this repo's capsule/cards. Rendered, not hand-written.
- State precedence: **Git > FLEET ledger > task cards > ADRs > narrative docs**.
  The witnessed FLEET ledger lives at `meta/.handoff/ledger.db`. No binary state is
  committed inside this directory.

## Legacy state

`TODO.md`, `SESSIONS.md`, and `CHANGELOG.md` are the pre-handoff session-tracking
files. They remain accurate for now and will be migrated opportunistically (P7.36).
Do not bulk-delete them.
