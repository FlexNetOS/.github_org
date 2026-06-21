#!/usr/bin/env bash
# rotate-policy-drift-token.sh — the envctl-relay "virtual credit card" rotation for the
# POLICY_DRIFT_TOKEN repo secret that the `github-policy-drift` CI job consumes.
#
# WHAT: mint a fresh, scoped GitHub App installation token via the envctl relay
# (`secretctl mint-github`, App key sealed in the vault) and inject it as the
# `POLICY_DRIFT_TOKEN` Actions secret on FlexNetOS/.github. GitHub fixes the
# installation-token lifetime at ~60 min (the requested ttl is advisory), so the timer
# re-mints every ~45 min (see install-policy-drift-rotation.sh) to keep a VALID token
# present continuously — comfortably inside the ~60 min expiry. (The relay's "24h" is
# the credential-rotation policy; the GitHub WIRE token must itself re-mint at ≤1h.)
# Any leak is short-lived and a rotation gap is detectable.
#
# WHY administration:WRITE: GitHub redacts ruleset `bypass_actors` and the repo
# object's admin merge-settings from *App* tokens unless the token carries
# `administration: write` (empirically verified — `administration: read` returns
# those fields ABSENT/empty). The flexnetos-github-app installation already holds
# `administration: write`; the 24h rotation bounds that token's blast radius. With
# this token the policy-drift check verifies the FULL admin surface (no UNVERIFIED).
#
# FAIL-OPEN + EXPIRY PRE-CHECK: if the vault is locked (USB absent) or the mint/inject
# fails, the script cannot refresh the token. It then runs an EXPIRY PRE-CHECK against
# the locally-recorded expiry of the currently-injected token (written at inject time):
#   - still valid (the normal ≤45-min-rotation case) ⇒ leave POLICY_DRIFT_TOKEN as-is.
#   - past expiry (box locked longer than ~60 min) ⇒ DELETE POLICY_DRIFT_TOKEN so the
#     workflow's `secrets.POLICY_DRIFT_TOKEN || secrets.GITHUB_TOKEN` selector drops
#     cleanly to the default GITHUB_TOKEN (partial scope-aware verification) instead of
#     presenting an EXPIRED token to CI.
# Every path exits 0 — never a false failure. The scope-aware `apply-github-policies.py
# --check` degrades gracefully; a missing/expired rotation never breaks CI.
#
# REQUIREMENTS on the host: `secretctl` + a running, UNLOCKED env-ctl.service vault;
# `gh` authenticated as a principal that can set repo secrets (org/repo admin).
set -euo pipefail

REPO="FlexNetOS/.github"
INSTALLATION_ID="${POLICY_DRIFT_INSTALLATION_ID:-140063898}"  # flexnetos-github-app (app_id 4044997)
TTL_SECS="${POLICY_DRIFT_TTL_SECS:-3600}"                     # advisory; GitHub caps the installation token at ~60 min
PERMS="administration:write,metadata:read"
EXPIRY_SKEW_SECS="${POLICY_DRIFT_EXPIRY_SKEW_SECS:-120}"      # treat a token within this window of expiry as already expired
STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/policy-drift-token"
EXPIRY_FILE="${STATE_DIR}/expires_at_unix"                    # epoch expiry of the currently-injected token (written at inject)

log() { printf '[rotate-policy-drift-token] %s %s\n' "$(date -u +%FT%TZ)" "$*"; }

# Expiry pre-check — invoked ONLY on a path where we could not mint/inject a fresh token
# (vault locked, mint failure, inject failure). If the currently-injected token is already
# past (or within EXPIRY_SKEW_SECS of) its recorded expiry, delete POLICY_DRIFT_TOKEN so CI
# drops to the GITHUB_TOKEN fallback rather than presenting an expired token. If still valid,
# leave it. No tracked expiry (state file absent) ⇒ leave any existing secret untouched.
drop_secret_if_expired() {
  if [ ! -f "${EXPIRY_FILE}" ]; then
    log "expiry pre-check: no tracked token (state file absent) — leaving any existing secret as-is"
    return 0
  fi
  local exp now
  exp="$(cat "${EXPIRY_FILE}" 2>/dev/null || echo 0)"
  now="$(date +%s)"
  if [ "${exp}" -gt 0 ] && [ "$(( now + EXPIRY_SKEW_SECS ))" -lt "${exp}" ]; then
    log "expiry pre-check: injected token still valid (expires_at_unix=${exp}, ~$(( (exp - now) / 60 )) min left) — leaving POLICY_DRIFT_TOKEN in place"
    return 0
  fi
  log "expiry pre-check: injected token expired/expiring (expires_at_unix=${exp}, now=${now}) and cannot be refreshed — removing POLICY_DRIFT_TOKEN so CI uses GITHUB_TOKEN partial verification"
  gh secret delete POLICY_DRIFT_TOKEN --repo "${REPO}" 2>/dev/null \
    || log "  (POLICY_DRIFT_TOKEN already absent or delete failed — CI fallback unaffected)"
  rm -f "${EXPIRY_FILE}"
}

# Pre-flight: tools present.
for bin in secretctl gh python3; do
  command -v "$bin" >/dev/null 2>&1 || { log "MISSING $bin on PATH — skipping rotation (CI keeps partial verification)"; exit 0; }
done

# Vault must be unlocked for the broker to open the sealed App key. Fail-open if not.
if ! secretctl status 2>/dev/null | grep -q 'unlocked'; then
  log "vault is LOCKED (USB absent?) — cannot mint; running expiry pre-check on the injected token"
  drop_secret_if_expired
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
  log "mint FAILED — cannot refresh; running expiry pre-check on the injected token:"
  sed -E 's/gh[pousr]_[A-Za-z0-9]+/<redacted>/g' "${mint_err}" >&2 || true
  drop_secret_if_expired
  exit 0
fi

token="$(printf '%s' "${mint_json}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["token"])')"
if [ -z "${token}" ]; then
  log "mint returned no token field — running expiry pre-check on the injected token"
  drop_secret_if_expired
  exit 0
fi

# 2. Inject via stdin (gh reads the value from stdin when --body is omitted) so the token never
# lands in argv / ps / shell history.
if printf '%s' "${token}" | gh secret set POLICY_DRIFT_TOKEN --repo "${REPO}" 2>/dev/null; then
  # Record the injected token's expiry so the expiry pre-check can reason about it on a
  # later run where we cannot mint (vault locked / mint failure).
  exp="$(printf '%s' "${mint_json}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["expires_at_unix"])' 2>/dev/null || true)"
  mkdir -p "${STATE_DIR}"; printf '%s\n' "${exp:-0}" > "${EXPIRY_FILE}"
  log "rotated POLICY_DRIFT_TOKEN (perms=${PERMS}; token expires_at_unix=${exp:-unknown}) — github-policy-drift now verifies the full admin surface"
else
  log "gh secret set FAILED (auth lacks secrets:write?) — token minted but not injected; running expiry pre-check on the previously-injected token"
  drop_secret_if_expired
  exit 0
fi

# Scrub the token from the shell as early as possible.
unset token mint_json exp
