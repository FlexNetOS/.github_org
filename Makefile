# =============================================================================
# FlexNetOS/.github  —  Makefile (one-command verbs)
# =============================================================================
# All real work lives in scripts/. This file is the discoverable, typo-tolerant
# surface humans (and CI) talk to. `make help` lists everything.
# =============================================================================

SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
.DEFAULT_GOAL := help

# ---------- Discoverable targets ----------

.PHONY: help
help: ## List all targets with their one-liner description
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n\nTargets:\n"} \
	      /^[a-zA-Z0-9_.-]+:.*##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 }' \
	      $(MAKEFILE_LIST) | sort

# ---------- Bootstrap & verify ----------

.PHONY: bootstrap
bootstrap: ## Idempotent setup: tools check, submodules init, secrets unlock
	@scripts/bootstrap.sh

.PHONY: verify
verify: verify.tool-assets verify.actionlint verify.markdown verify.manifest verify.tools verify.hermetic verify.github-policies ## Run every local verification

.PHONY: verify.fast
verify.fast: verify.actionlint verify.markdown verify.manifest verify.tools ## Fast verification (no live API calls)

.PHONY: install-hooks
install-hooks: ## Configure Git to use the local hooks in .githooks/
	@git config core.hooksPath .githooks
	@echo "Local hooks configured from .githooks/"

.PHONY: verify.actionlint
verify.actionlint: ## Lint .github/workflows/*.yml
	@tools/bin/actionlint .github/workflows/*.yml

.PHONY: verify.tool-assets
verify.tool-assets: ## Validate pinned repo-local tool asset manifest
	@python3 scripts/toolchain.py validate

.PHONY: verify.markdown
verify.markdown: ## Lint all markdown except submodules/raw
	@python3 scripts/verify-markdown.py .

.PHONY: verify.manifest
verify.manifest: ## Validate repos/MANIFEST.yaml structure
	@python3 scripts/verify-manifest.py repos/MANIFEST.yaml

.PHONY: verify.tools
verify.tools: ## Validate tools/MANIFEST.yaml structure
	@python3 scripts/verify-manifest.py tools/MANIFEST.yaml

.PHONY: verify.hermetic
verify.hermetic: ## Report non-hermetic workflow/script dependencies (advisory)
	@python3 scripts/hermetic-audit.py .

.PHONY: verify.github-policies
verify.github-policies: ## Validate .github/policies/ JSON and live drift check (skipped if not authenticated)
	@bash scripts/tests/test-github-policies.sh

# ---------- Submodules (data/brain-data only) ----------
# ADR-0002 retired repo/tool submodules in .github_org. The only remaining
# gitlinks are the data/brain-data wiki/brain submodules.

.PHONY: submodules.init
submodules.init: ## Initialize and update data/brain-data submodules (full clone)
	git submodule update --init --recursive

.PHONY: submodules.bump
submodules.bump: ## Fast-forward data/brain-data submodules to tracking-branch HEAD
	@scripts/submodule-bump.sh

.PHONY: submodules.sync-upstream
submodules.sync-upstream: ## For forked data/brain-data submodules, fetch upstream and merge
	@scripts/submodule-sync-upstream.sh

.PHONY: submodules.status
submodules.status: ## Report dirty / ahead-of-tracking / detached data/brain-data submodules
	@git submodule foreach --quiet 'echo "--- $$name ---"; git -C "$$toplevel/$$path" status --short --branch | head -5'

# ---------- Research (Step 0 of the clone-and-research-before-fork ritual) ----------

.PHONY: research.pack
research.pack: ## Clone an upstream and pack it with repomix: URL=<github-url-or-owner/repo> [BRANCH=<branch>]
	@if [ -z "$$URL" ]; then echo "Usage: make research.pack URL=https://github.com/<owner>/<repo> [BRANCH=<branch>]"; exit 2; fi
	@args="$$URL"; if [ -n "$${BRANCH:-}" ]; then args="$$args $${BRANCH}"; fi; \
	scripts/clone-and-pack.sh $$args

# ---------- Wiki ----------

.PHONY: wiki.ingest
wiki.ingest: ## Ingest a source into the wiki: SRC=path/to/file
	@if [ -z "$$SRC" ]; then echo "Usage: make wiki.ingest SRC=path/to/source"; exit 2; fi
	@if [ ! -f "$$SRC" ]; then echo "ERROR: $$SRC not found"; exit 1; fi
	@echo "→ Invoke an LLM agent (Claude Code / Codex / Gemini) with this prompt:"
	@echo
	@echo "    Read wiki/AGENTS.md, wiki/schema.md, wiki/purpose.md, wiki/index.md,"
	@echo "    then perform an ingest of: $$SRC"
	@echo "    Two-step CoT: analyze then generate per the schema."
	@echo "    Update index.md and append a [YYYY-MM-DD] entry to log.md."
	@echo
	@echo "(This Makefile target stops at the prompt — actual LLM invocation is the agent's job.)"

.PHONY: wiki.query
wiki.query: ## Query the wiki: Q="your question"
	@if [ -z "$$Q" ]; then echo "Usage: make wiki.query Q=\"your question\""; exit 2; fi
	@echo "→ Invoke an LLM agent with this prompt:"
	@echo
	@echo "    Read wiki/AGENTS.md, wiki/schema.md, wiki/purpose.md, wiki/index.md."
	@echo "    Query: $$Q"
	@echo "    Synthesize an answer with [[wikilink]] citations on every claim."
	@echo "    If substantial, file as pages/synthesis/<slug>.md and update index.md."

.PHONY: wiki.lint
wiki.lint: ## Run the wiki health check (delegates to the LLM agent)
	@echo "→ Invoke an LLM agent with this prompt:"
	@echo
	@echo "    Read wiki/AGENTS.md and wiki/schema.md."
	@echo "    Run a lint pass per the schema's lint workflow."
	@echo "    Write the report to wiki/.lint-report.md (gitignored)."
	@echo "    Append a [YYYY-MM-DD] lint entry to wiki/log.md."

# ---------- Secrets ----------

.PHONY: secrets.unlock
secrets.unlock: ## direnv allow + ensure pass store is current
	@direnv allow .
	@PASSWORD_STORE_DIR="$$PWD/secrets/store" pass git pull --rebase 2>/dev/null || true
	@echo "OK: shell secrets reloaded — try \`echo \$$OPENAI_API_KEY\`"

.PHONY: secrets.rotate
secrets.rotate: ## List secrets older than 90 days
	@PASSWORD_STORE_DIR="$$PWD/secrets/store" scripts/secrets-rotate.sh

.PHONY: secrets.mirror-bws
secrets.mirror-bws: ## Mirror pass store to Bitwarden Secrets Manager (needs BWS_ACCESS_TOKEN + PROJECT_ID env vars)
	@if [ -z "$$BWS_ACCESS_TOKEN" ] || [ -z "$$PROJECT_ID" ]; then \
	    echo "Usage: BWS_ACCESS_TOKEN=… PROJECT_ID=… make secrets.mirror-bws"; exit 2; fi
	@PASSWORD_STORE_DIR="$$PWD/secrets/store" \
	  scripts/secrets-mirror-to-bws.sh --project-id "$$PROJECT_ID"

.PHONY: secrets.sync-github-bw
secrets.sync-github-bw: ## Sync Bitwarden/Vaultwarden vault items to GitHub Actions secrets (MAP=, DRY_RUN=1)
	@args="--map $${MAP:-secrets/github-secrets.tsv}"; \
	if [ "$${DRY_RUN:-0}" = "1" ]; then args="$$args --dry-run"; fi; \
	scripts/secrets-sync-github-from-bitwarden.sh $$args

# ---------- GitHub control plane ----------
.PHONY: github.doctor
github.doctor: ## Read-only audit of runner/workflows/app/submodules/secrets/policy state
	@args=""; \
	if [ "$${OFFLINE:-0}" = "1" ]; then args="$$args --offline"; fi; \
	if [ "$${JSON:-0}" = "1" ]; then args="$$args --json"; fi; \
	if [ "$${STRICT:-0}" = "1" ]; then args="$$args --strict"; fi; \
	python3 scripts/github-doctor.py $$args

.PHONY: github-app.smoke
github-app.smoke: ## Smoke-test GitHub App installation token exchange (DRY_RUN=1 skips API)
	@args=""; \
	if [ "$${DRY_RUN:-0}" = "1" ]; then args="$$args --dry-run"; fi; \
	if [ "$${JSON:-0}" = "1" ]; then args="$$args --json"; fi; \
	python3 scripts/github-app-token-smoke.py $$args

.PHONY: github.policy.dry-run
github.policy.dry-run: ## Dry-run the GitHub policy applier
	@python3 scripts/apply-github-policies.py --dry-run

.PHONY: github.policy.apply
github.policy.apply: ## Apply .github/policies/ to live GitHub state
	@python3 scripts/apply-github-policies.py --apply

.PHONY: github.policy.check
github.policy.check: ## Check committed policy against live GitHub state
	@python3 scripts/apply-github-policies.py --check

# ---------- Reconciliation tooling (additive; see data/brain-data/research/my-github-reconciliation.md) ----------
.PHONY: claude.doctor
claude.doctor: ## Report hardcoded user-home paths / aspirational keys in .claude/settings.json (read-only)
	node scripts/claude-settings-doctor.js --check --allowlist .claude/.doctor-allowlist

.PHONY: config.doctor
config.doctor: ## claude.doctor plus a note on the .codex allowlist (read-only)
	@node scripts/claude-settings-doctor.js --check --allowlist .claude/.doctor-allowlist; \
	echo "config.doctor: .codex user-global references governed by .codex/.doctor-allowlist"

.PHONY: verify.config-health
verify.config-health: ## Runtime config-health: missing repo-relative hooks + quoted-tilde bugs = ERROR; absent user-global hooks/binaries = WARN (advisory). NOT in blocking `verify` yet (gated on HUT-1 #210; develop's settings.json still has the quoted-tilde ERROR until it merges).
	node scripts/config-health-doctor.js --config .claude/settings.json

.PHONY: check.user-todo-5
check.user-todo-5: ## List MANIFEST entries tagged / untagged for USER.TODO#5 (read-only)
	@bash scripts/check-user-todo-step5.sh --list-untagged

.PHONY: open-questions.lint
open-questions.lint: ## Validate .omc/plans/open-questions.md schema
	node scripts/open-questions-lint.js .omc/plans/open-questions.md

# ---------- Runner ----------
.PHONY: runner.install
runner.install: ## Dry-run install/upgrade self-hosted runner binary (CONFIRM=1 DRY_RUN=0 to apply)
	@args=""; \
	if [ "$${DRY_RUN:-1}" = "0" ]; then args="$$args --execute"; else args="$$args --dry-run"; fi; \
	runner/install.sh $$args

.PHONY: runner.register
runner.register: ## Dry-run register runner: MODE=org|repo NAME=<reponame> (CONFIRM=1 DRY_RUN=0 to apply)
	@if [ -z "$$MODE" ]; then echo "Usage: make runner.register MODE=org  (or MODE=repo NAME=<reponame>)"; exit 2; fi
	@args="--$$MODE"; \
	if [ "$$MODE" = "repo" ] && [ -n "$$NAME" ]; then args="$$args $$NAME"; fi; \
	if [ "$${DRY_RUN:-1}" = "0" ]; then args="$$args --execute"; else args="$$args --dry-run"; fi; \
	runner/register.sh $$args

.PHONY: runner.remove
runner.remove: ## Dry-run remove runner registration/service (CONFIRM=1 DRY_RUN=0 to apply)
	@if [ -z "$$MODE" ]; then echo "Usage: make runner.remove MODE=org  (or MODE=repo NAME=<reponame>)"; exit 2; fi
	@args="--$$MODE"; \
	if [ "$$MODE" = "repo" ] && [ -n "$$NAME" ]; then args="$$args $$NAME"; fi; \
	if [ "$${DRY_RUN:-1}" = "0" ]; then args="$$args --execute"; else args="$$args --dry-run"; fi; \
	runner/remove.sh $$args

.PHONY: runner.doctor
runner.doctor: ## Read-only local runner readiness checks
	@args=""; \
	if [ "$${JSON:-0}" = "1" ]; then args="$$args --json"; fi; \
	if [ "$${STRICT:-0}" = "1" ]; then args="$$args --strict"; fi; \
	scripts/runner-doctor.sh $$args

.PHONY: runner.status
runner.status: ## Show systemd status of the runner service(s)
	@systemctl list-units --all 'actions.runner.*' --no-pager 2>/dev/null || true
	@systemctl list-units --all 'runner-spawn@*' --no-pager 2>/dev/null || true

# ---------- CI local ----------

.PHONY: ci.local
ci.local: ## Run a workflow locally with act: WORKFLOW=ci.yml
	@command -v act >/dev/null 2>&1 || { echo "act not installed — see github.com/nektos/act"; exit 1; }
	@if [ -z "$$WORKFLOW" ]; then echo "Usage: make ci.local WORKFLOW=ci.yml"; exit 2; fi
	act -W .github/workflows/$$WORKFLOW

# ---------- Cleanup ----------

.PHONY: clean
clean: ## Remove caches and ignored cruft (DOES NOT touch submodules or .gitignored secrets dirs)
	@find . -type d -name '__pycache__' -prune -exec rm -rf {} +
	@find . -type d -name '.pytest_cache' -prune -exec rm -rf {} +
	@find . -type d -name '.ruff_cache' -prune -exec rm -rf {} +
	@rm -rf .markdownlint-cli2.cache/
