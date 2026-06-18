# Active

## Remaining work from the control-plane / deep-review phase plans

Source plans:
- `architecture/plan/2026-06-17-github-control-plane-upgrades-plan.md`
- `architecture/plan/2026-06-17-deep-review-upgrade-plan.md`

### Must do / gated

1. **Provision `POLICY_DRIFT_TOKEN` from `meta/envctl`** and promote `github-policy-drift` from REPORT_ONLY to STRICT (update `promote-strict.md`).
   - Source: Phase 1.7
2. **Provision `RELEASE_TOKEN` and `PROMOTE_TOKEN` from `meta/envctl`** and confirm they are wired into `.github/workflows/release.yml` / `promote-develop-to-main.yml`.
   - Source: Phase 5.5
3. **Add release bot/app `bypass_actors` to rulesets** with `bypass_mode: pull_request`.
   - Blocked: need actor ID/slug of the release bot/app.
   - Source: Phase 3.4
4. **Decide final repo name** (restore `.github` vs keep `.github_org`).
   - This gates the entire rename-reference cluster (~80 `FlexNetOS/.github` references and self-CI gates).
   - Source: Deep review §0

### Code / tooling still open

5. **Add `timeout-minutes` to the `lint` and `security` reusable-workflow caller jobs** in `.github/workflows/ci.yml`.
   - Source: Phase 1.3
6. **Fully deduplicate the policy appliers** — extract a shared applier module and add a `--check`/drift mode to `apply-fleet-policies.py`. The current wrapper restores capability but does not dedupe or drift-check.
   - Source: Deep review §2.4
7. **Require or assert target repo slug before mutating** in `apply-github-policies.py`. `--expect-repo` exists but is optional; the default still mutates whatever `gh repo view` resolves.
   - Source: Deep review §2.5
8. **Paginate GitHub reads** in `apply-github-policies.py` / `apply-fleet-policies.py` (`list_rulesets`, `check_environments`, etc.).
   - Source: Deep review §4
9. **Plan retirement of legacy `branch-protection.json`** once rulesets are proven for a release cycle, and consider consolidating dual governance (rulesets + legacy branch protection).
   - Source: Phase 3.6 / Deep review §4

### Optional cleanup (P3)

10. **Hygiene cluster** from Deep review §5 — non-blocking:
    - Hooks: derive root with `git rev-parse --show-toplevel`; fix `commit-msg` POSIX test.
    - Runner: verify tarball checksum before extract.
    - `install-v5-architecture.sh`: pin/verify the `curl|sh` installs.
    - Docs: README badge links, roadmap `renovate.json5` vs `renovate.json`, README role count, `.claude/settings.canonical.json` naming.
    - `semantic-pr-title.yml`: literal `\n` fallback on `workflow_call` path.
    - Dangling manifest/submodule machinery for the retired submodule role.

---

Last updated: 2026-06-18
