#!/usr/bin/env bash
# rotate-policy-drift-token.sh — the envctl-relay "virtual credit card" rotation for the
# POLICY_DRIFT_TOKEN repo secret that the `github-policy-drift` CI job consumes.
#
# WHAT: mint a fresh, scoped GitHub App installation token via the envctl relay
# (`secretctl mint-github`, App key sealed in the vault) and inject it as the
# `POLICY_DRIFT_TOKEN` Actions secret on FlexNetOS/.github. Run on a 24h timer
# (see install-policy-drift-rotation.sh) so the secret is continuously rotated —
# any leak is short-lived and a rotation gap is detectable.
#
# WHY administration:WRITE: GitHub redacts ruleset `bypass_actors` and the repo
# object's admin merge-settings from *App* tokens unless the token carries
# `administration: write` (empirically verified — `administration: read` returns
# those fields ABSENT/empty). The flexnetos-github-app installation already holds
# `administration: write`; the 24h rotation bounds that token's blast radius. With
# this token the policy-drift check verifies the FULL admin surface (no UNVERIFIED).
#
# FAIL-OPEN BY DESIGN: if the vault is locked (USB absent) or the mint fails, this
# script leaves the existing secret untouched and exits 0. The scope-aware
# `apply-github-policies.py --check` then falls back to partial verification (the
# default GITHUB_TOKEN path) — UNVERIFIED, never a false failure. A missing rotation
# degrades gracefully; it never breaks CI.
#
# REQUIREMENTS on the host: `secretctl` + a running, UNLOCKED env-ctl.service vault;
# `gh` authenticated as a principal that can set repo secrets (org/repo admin).
set -euo pipefail

REPO="FlexNetOS/.github"
INSTALLATION_ID="${POLICY_DRIFT_INSTALLATION_ID:-140063898}"  # flexnetos-github-app (app_id 4044997)
TTL_SECS="${POLICY_DRIFT_TTL_SECS:-86400}"                    # 24h advisory; GitHub caps the raw token, the relay re-mints
PERMS="administration:write,metadata:read"

log() { printf '[rotate-policy-drift-token] %s %s\n' "$(date -u +%FT%TZ)" "$*"; }

# Pre-flight: tools present.
for bin in secretctl gh python3; do
  command -v "$bin" >/dev/null 2>&1 || { log "MISSING $bin on PATH — skipping rotation (CI keeps partial verification)"; exit 0; }
done

# Vault must be unlocked for the broker to open the sealed App key. Fail-open if not.
if ! secretctl status 2>/dev/null | grep -q 'unlocked'; then
  log "vault is LOCKED (USB absent?) — skipping rotation; existing POLICY_DRIFT_TOKEN/GITHUB_TOKEN fallback stays in effect"
  exit 0
fi

repo_id="$(gh api "/repos/${REPO}" --jq '.id' 2>/dev/null || true)"
if [ -z "${repo_id}" ]; then
  log "could not resolve ${REPO} numeric id via gh (auth/network?) — skipping rotation"
  exit 0
fi

# 1. Mint the scoped, short-lived token. Token text NEVER printed; errors are redacted.
mint_err="$(mktemp)"
trap 'rm -f "${mint_err}"' EXIT
if ! mint_json="$(secretctl mint-github \
      --installation-id "${INSTALLATION_ID}" \
      --repository-ids "${repo_id}" \
      --permissions "${PERMS}" \
      --ttl-secs "${TTL_SECS}" \
      --output json 2>"${mint_err}")"; then
  log "mint FAILED — leaving existing secret in place (CI falls back to partial verification):"
  sed -E 's/gh[pousr]_[A-Za-z0-9]+/<redacted>/g' "${mint_err}" >&2 || true
  exit 0
fi

token="$(printf '%s' "${mint_json}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["token"])')"
if [ -z "${token}" ]; then
  log "mint returned no token field — skipping injection"
  exit 0
fi

# 2. Inject via stdin (gh reads the value from stdin when --body is omitted) so the token never
# lands in argv / ps / shell history.
if printf '%s' "${token}" | gh secret set POLICY_DRIFT_TOKEN --repo "${REPO}" 2>/dev/null; then
  log "rotated POLICY_DRIFT_TOKEN (perms=${PERMS}, ttl=${TTL_SECS}s) — github-policy-drift now verifies the full admin surface"
else
  log "gh secret set FAILED (auth lacks secrets:write?) — token minted but not injected; existing secret unchanged"
  exit 0
fi

# Scrub the token from the shell as early as possible.
unset token mint_json
