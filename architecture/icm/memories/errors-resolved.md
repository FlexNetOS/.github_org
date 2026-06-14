--- 01KV1B21DQDTCF3TFXSQKVE5CG ---
  topic:      errors-resolved
  importance: medium
  weight:     1.000
  created:    2026-06-13 15:34
  accessed:   2026-06-13 15:34 (x0)
  summary:    [consolidated] [consolidated] [consolidated] PROCESS LESSON + RECOVERY (2026-06-12) — I MISREAD PR #11 as MERGED from 'gh pr view 11 --json state' (returned MERGED transiently), deleted my local branch, pulled master, and started building 2b-ii on a base that LACKED #11. ROOT CAUSE: trusted a gh status STRING without verifying the merge COMMIT was actually on origin/master. REALITY (verified): #11 was OPEN the whole time, green on all checks but mergeState=BEHIND — strict branch protection requires up-to-date-...

--- 01KV1DQDXJ7T4JKNZ99HX9587J ---
  topic:      errors-resolved
  importance: high
  weight:     1.000
  created:    2026-06-13 16:20
  accessed:   2026-06-13 16:20 (x0)
  summary:    weave WL-049 obscura: THIRD /verify-found gap (after kill false-success #76 and SSRF bypass #78). obscura_allow_ops honored '*' wildcard but obscura_allow_domains did NOT — '*' matched as a literal domain, so WEAVE_OBSCURA_ALLOW_DOMAINS='*' (the natural allow-all incantation, advertised by the op deny-message) silently DENIED every host (footgun, opposite of intent). Fix (PR #80): domain_allowed treats '*' as wildcard = any PUBLIC host; SSRF guard runs BEFORE domain check so internal/loopback stay blocked under '*'. Verified live at the weave web CLI. Lesson: when one allowlist supports '*', mirror it across sibling allowlists or it's an inconsistent footgun.
  keywords:   weave, obscura, webpolicy, wildcard, verify
  embedding:  yes

--- 01KV1HABHXGWTE5C2MTNHGZ0PZ ---
  topic:      errors-resolved
  importance: medium
  weight:     1.000
  created:    2026-06-13 17:23
  accessed:   2026-06-13 17:23 (x0)
  summary:    weave CI/test gotchas (2026-06-13): (1) Adding a test AFTER running cargo fmt leaves it unformatted -> CI rustfmt fails while tests pass (the classic Format-gate block). Always re-run fmt after late test additions. RTK's 'cargo fmt --all --check' MASKS the non-zero exit (prints 'Diff in' but exit 0) — grep for 'Diff in', don't trust exit code. (2) Timing-sensitive integration tests (dashboard_unknown_path_is_404 server-readiness, cli_lease_sweep_removes_expired, peers federation) flake under the DUPLICATE-RUN CI load (push + pull_request both trigger, no concurrency group — standing debt). Fix: gh run rerun <id> --failed. (3) peers_json_surfaces_remote_host_peer_alive_remote_additive_keys does a blanket substring check for 'token' over output containing the cwd path -> FALSE-fails when the worktree dir name contains 'token' (e.g. weave-wl051-token-budget). Worktree-name artifact, green on CI's clean path. Pre-existing test brittleness worth hardening.
  keywords:   fmt, ci, flaky, worktree, token
  embedding:  yes

--- 01KV1VXH1RZZ7BR6XREQFAAAZX ---
  topic:      errors-resolved
  importance: high
  weight:     1.000
  created:    2026-06-13 20:28
  accessed:   2026-06-13 20:28 (x0)
  summary:    MISTAKE+RECOVERY (handoff loop, 2026-06-13): ran 'cargo run -p hf -- ship HFTASK-0008' as a 'runtime test' — but hf ship is a MUTATING verb: it committed my uncommitted 0008 main.rs onto the WRONG branch (handoff-HFTASK-0035-gitignore-guard, PR#46) and pushed it, contaminating #46 with an incomplete 0008 (branch.rs was untracked so not committed -> would break #46 CI). This is exactly the L4 lesson (verifiers/tests driving mutating verbs MUST use isolated temp meta-roots, never the real repo). RECOVERY (carry-forward, no discard per owner directive): git reset --soft HEAD~1 (kept changes), git push --force-with-lease to restore #46 to clean 0035, git stash -u, checkout master, new branch handoff-HFTASK-0008-branch-policy off origin/master, stash pop, committed full 0008 (branch.rs+main.rs), PR#47. RULE GOING FORWARD: NEVER run hf ship/claim/done/sync/checkpoint as a 'test' against the real repo. To runtime-test a read-only verb (hf fleet status, hf resume) it's fine; for mutating verbs use a temp meta-root or just unit tests. hf ship has NO --dry-run.
  keywords:   hf-ship, mutating-verb, verifier-isolation, L4, runtime-test, git-recovery
  embedding:  yes

