#!/usr/bin/env bash
# install-policy-drift-rotation.sh — install the 24h POLICY_DRIFT_TOKEN rotation as a
# systemd --user timer that runs rotate-policy-drift-token.sh on the host where the
# envctl vault + secretctl + gh live (the "self-hosted + secretctl runtime" path —
# there is no GitHub-hosted runner that can reach the vault).
#
# The systemd units are GENERATED here with the absolute path resolved at install time
# (via `git rev-parse`), so NO host-specific path is ever committed to the repo. Units
# land in ~/.config/systemd/user/ (per-user, no root). Idempotent + dry-run by default.
#
# Usage:
#   bash scripts/install-policy-drift-rotation.sh            # dry-run: print what it would do
#   bash scripts/install-policy-drift-rotation.sh --apply    # write units, enable + start the timer
#   bash scripts/install-policy-drift-rotation.sh --apply --run-now   # ...and rotate once immediately
set -euo pipefail

APPLY=0; RUN_NOW=0
for a in "$@"; do
  case "$a" in
    --apply) APPLY=1 ;;
    --run-now) RUN_NOW=1 ;;
    *) echo "unknown arg: $a" >&2; exit 2 ;;
  esac
done

REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
SCRIPT="${REPO_ROOT}/scripts/rotate-policy-drift-token.sh"
UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
SERVICE="${UNIT_DIR}/policy-drift-token-rotate.service"
TIMER="${UNIT_DIR}/policy-drift-token-rotate.timer"

[ -f "${SCRIPT}" ] || { echo "ERROR: ${SCRIPT} not found" >&2; exit 1; }

service_body() {
  cat <<EOF
[Unit]
Description=Rotate POLICY_DRIFT_TOKEN via the envctl relay (mint + inject)
Documentation=https://github.com/FlexNetOS/.github/blob/main/scripts/rotate-policy-drift-token.sh
# Best-effort ordering: the vault daemon should be up first. Not a hard Requires —
# the script is fail-open if the vault is locked/absent.
After=env-ctl.service

[Service]
Type=oneshot
ExecStart=/usr/bin/env bash ${SCRIPT}
EOF
}

timer_body() {
  cat <<'EOF'
[Unit]
Description=Daily POLICY_DRIFT_TOKEN rotation (envctl relay, virtual-credit-card model)

[Timer]
# Every 24h. Persistent=true catches up a missed window after the box was off/asleep.
OnCalendar=daily
Persistent=true
RandomizedDelaySec=300

[Install]
WantedBy=timers.target
EOF
}

if [ "${APPLY}" -eq 0 ]; then
  echo "DRY-RUN (no --apply). Would write:"
  echo "  ${SERVICE}  (ExecStart -> ${SCRIPT})"
  echo "  ${TIMER}    (OnCalendar=daily, Persistent=true)"
  echo "  then: systemctl --user daemon-reload && systemctl --user enable --now policy-drift-token-rotate.timer"
  echo "Re-run with --apply to install (add --run-now to rotate once immediately)."
  exit 0
fi

mkdir -p "${UNIT_DIR}"
service_body > "${SERVICE}"
timer_body   > "${TIMER}"
systemctl --user daemon-reload
systemctl --user enable --now policy-drift-token-rotate.timer
echo "installed + enabled policy-drift-token-rotate.timer:"
systemctl --user list-timers policy-drift-token-rotate.timer --no-pager 2>/dev/null | head -3 || true

if [ "${RUN_NOW}" -eq 1 ]; then
  echo "running one rotation now..."
  systemctl --user start policy-drift-token-rotate.service
  systemctl --user status policy-drift-token-rotate.service --no-pager -n 5 2>/dev/null | tail -6 || true
fi
