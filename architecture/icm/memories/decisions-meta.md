--- 01KV0G9RVN293PVDAMGQ47TW00 ---
  topic:      decisions-meta
  importance: medium
  weight:     1.000
  created:    2026-06-13 07:46
  accessed:   2026-06-13 07:46 (x0)
  summary:    [consolidated] OWNER ARCHITECTURE CLARIFICATIONS (2026-06-12): (1) gitkb is the ORIGINAL FOUNDATION meta was built from — git-kb is NOT an 'external vendor to leave'; if GitKB has resources meta didn't properly adopt, ADOPT them into meta. git-kb is an adoption/relocation target (bring latest GitKB into meta, symlink). (2) ALWAYS use the LATEST version; we do NOT migrate. Swap the original ~/.local/bin install location with a SYMLINK to the upgraded (latest) version located IN meta. So for tools where installe...

--- 01KV0JBMAGDAQ4ZSX84DJVQFJ6 ---
  topic:      decisions-meta
  importance: critical
  weight:     1.000
  created:    2026-06-13 08:22
  accessed:   2026-06-13 16:20 (x1)
  summary:    ENVCTL master-mirror protection — KEY CONSTRAINT (verified 2026-06-13): you CANNOT have both (a) a master ruleset that blocks human pushes/PRs AND (b) the existing GITHUB_TOKEN-based sync-master.yml, because GITHUB_TOKEN (github-actions[bot]) cannot be placed in a ruleset bypass (it's not an org-admin, not a repo-role collaborator, not a listable GitHub App). The forge-loop's sync-master.yml comment claiming 'GITHUB_TOKEN granted a branch-protection bypass' was ASPIRATIONAL — never configured; the sync only worked because master was UNPROTECTED. I applied a ruleset (block update/deletion/non_fast_forward, bypass OrganizationAdmin) then REVERTED it (no-downgrade: would block the bot and break the working sync; couldn't validly verify due to no workflow_dispatch on the existing workflow + a -F payload bug in my test). CURRENT STATE: master==develop==15defcad, autosync WORKING, master UNPROTECTED. TASK-1 divergence itself RESOLVED (#57 reconcile merged, develop superset, sync FF works). REMAINING owner decision for protection: the sync must push as a bypass identity — option B1: fine-grained PAT (contents:write on envctl) stored as a secret, sync uses it, ruleset bypasses that org-admin user; option B2: flexnetos_github_app token (actions/create-github-app-token) + ruleset bypasses that App. Both need owner to provision the credential. I am org-admin (drdave-flexnetos role=admin). GENERAL PRINCIPLE owner set: every repo needs develop(trunk)+master/main(protected mirror), create-if-missing — roll out AFTER the envctl protection mechanism is proven.
  keywords:   envctl, master-protection, github-token, bypass, autosync, ruleset
  embedding:  yes

--- 01KV0KXYP36W3REZSXCZHN1YZ6 ---
  topic:      decisions-meta
  importance: high
  weight:     1.000
  created:    2026-06-13 08:49
  accessed:   2026-06-13 14:31 (x2)
  summary:    OWNER DECISION (2026-06-13): fleet branch-protection + auto-merge enablement is OWNED by the designated GitHub-management repos (flexnetos_github_app / github_org / meta_git_cli / flexnetos_runner), NOT an ad-hoc meta/scripts/ script. Handle per-repo, one by one. meta/scripts/enable-auto-merge.sh (PR #29) is a REFERENCE only; the owned implementation should live in a designated repo. Hard-won facts that impl MUST honor: (1) per-repo default branch varies — envctl=develop, hubs=master, others=main; read .default_branch. (2) Required-check contexts MUST come from a recent PULL_REQUEST's check-runs, NOT the default-branch push — push-only jobs (envctl 'ff-master' = sync-master.yml on push:[develop]; hub 'Adjust Configuration'/'Upload Results') would stall PRs if required. (3) Fork classification: GitHub .fork=true covers BOTH true upstream mirrors (codex/n8n/Archon/claude-code/oh-my-*/ECC/hermes-agent/obsidian-mind/meta-ruvector/ruflo/yazelix/env_manager_agent — DON'T protect, breaks sync) AND intentionally-diverged FlexNetOS forks (icm←rtk-ai/icm, grit←rtk-ai/grit, obscura, teri←SHA888, vox←rtk-ai/vox, shimmy, rtk-tokenkill←rtk-ai/rtk — these ARE developed independently, drift intentional, SHOULD be protected). (4) no required_pull_request_reviews so PRs self-land; strict=false. DONE so far this session: allow_auto_merge on 63 repos; protection on icm/main + envctl/develop (Analyze actions+rust).
  keywords:   auto-merge, branch-protection, flexnetos_github_app, github_org, forks, default-branch, envctl, ownership
  embedding:  yes

--- 01KV0TNTKD2YNA97T92JJBDEME ---
  topic:      decisions-meta
  importance: high
  weight:     1.000
  created:    2026-06-13 10:47
  accessed:   2026-06-13 10:47 (x0)
  summary:    FOUND the app creds (2026-06-13): org GitHub secrets APP_ID + APP_PRIVATE_KEY for flexnetos-github-app (app_id 4044997, contents:write+administration:write, org installation 140063898). Proven pattern: icm (cd.yml/next-release.yml, uses APP_CLIENT_ID+APP_PRIVATE_KEY) + hermes-agent (uses APP_ID+APP_PRIVATE_KEY) mint tokens via actions/create-github-app-token. envctl vault was empty (secret_count=0) — creds live as GitHub org secrets, not the local vault. flexnetos_github_app repo (bootstrap-github-app branch) is the Rust control-plane that seals app key into envctl vault + mints per-repo installation tokens (ADR-0007/0008); the least-privilege merge-gate app is named flexnetos-trusted-writer (contents:READ) but the installed broad app is flexnetos-github-app (contents:WRITE) — used for pushes. IMPLEMENTED Option B2: envctl PR#66 (master-mirror-app) rewires sync-master.yml GITHUB_TOKEN->App token + workflow_dispatch, armed auto-merge into develop. Then orchestrator applies master ruleset {deletion,non_fast_forward,update} bypass=[Integration 4044997, OrganizationAdmin] + verifies App FFs master through protection. GITHUB_TOKEN cannot be a ruleset bypass actor — that's why the App identity is required. Repo admin (me) is NOT enough for OrganizationAdmin bypass earlier — but I AM org role=admin so should bypass; earlier force-move failure was a -F payload bug not the ruleset.
  keywords:   envctl, master-mirror, flexnetos-github-app, APP_ID, bypass, ruleset, creds-found
  embedding:  yes

