#!/usr/bin/env bash
# Read-only local runner doctor for FlexNetOS.
# Prints readiness signals and never mutates GitHub, systemd, or the host.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER_ORG="${RUNNER_ORG:-FlexNetOS}"
RUNNER_REPO="${RUNNER_REPO:-}"
RUNNER_HOME="${RUNNER_HOME:-$HOME/_work/repos/actions-runner}"
RUNNER_WORK_DIR="${RUNNER_WORK_DIR:-$HOME/_work/actions-runner-work}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted,linux,x64,local,flexnetos}"
STRICT=0
JSON=0

usage() {
  cat <<'EOF'
Usage: scripts/runner-doctor.sh [--strict] [--json]

Read-only checks for the local/self-hosted GitHub Actions runner path.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict) STRICT=1; shift ;;
    --json) JSON=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

tmp_base="${TMPDIR:-/tmp}"
if [[ ! -d "$tmp_base" || ! -w "$tmp_base" ]]; then
  tmp_base="/tmp"
fi
checks_file="$(TMPDIR="$tmp_base" mktemp)"
trap 'rm -f "$checks_file"' EXIT

add_check() {
  local area="$1" status="$2" name="$3" detail="$4"
  printf '%s\t%s\t%s\t%s\n' "$area" "$status" "$name" "$detail" >>"$checks_file"
}

have() { command -v "$1" >/dev/null 2>&1; }

add_check host OK "repo root" "$ROOT"

if [[ -r /etc/os-release ]]; then
  os="$(. /etc/os-release && printf '%s %s' "${NAME:-unknown}" "${VERSION_ID:-}")"
  add_check host OK "os" "$os"
else
  add_check host WARN "os" "/etc/os-release not readable"
fi

arch="$(uname -m 2>/dev/null || echo unknown)"
case "$arch" in
  x86_64|amd64|aarch64|arm64) add_check host OK "architecture" "$arch" ;;
  *) add_check host WARN "architecture" "$arch may not match runner assets" ;;
esac

for cmd in bash git curl tar python3; do
  if have "$cmd"; then add_check tools OK "$cmd" "$(command -v "$cmd")"; else add_check tools FAIL "$cmd" "missing"; fi
done
for cmd in gh docker systemctl; do
  if have "$cmd"; then add_check tools OK "$cmd" "$(command -v "$cmd")"; else add_check tools WARN "$cmd" "missing or not on PATH"; fi
done

if have gh && gh auth status >/dev/null 2>&1; then
  add_check github OK "gh auth" "authenticated"
  if gh api "/orgs/$RUNNER_ORG" --jq '.login' >/dev/null 2>&1; then
    add_check github OK "org access" "$RUNNER_ORG visible"
  else
    add_check github WARN "org access" "cannot read org $RUNNER_ORG"
  fi
  if [[ -n "$RUNNER_REPO" ]]; then
    if gh repo view "$RUNNER_ORG/$RUNNER_REPO" --json nameWithOwner >/dev/null 2>&1; then
      add_check github OK "repo access" "$RUNNER_ORG/$RUNNER_REPO visible"
    else
      add_check github WARN "repo access" "cannot read $RUNNER_ORG/$RUNNER_REPO"
    fi
  fi
  if gh api "/orgs/$RUNNER_ORG/actions/runners" --jq '.total_count' >/tmp/flexnetos-runner-count.$$ 2>/dev/null; then
    add_check github OK "org runners" "visible count $(tr -d '\n' </tmp/flexnetos-runner-count.$$)"
    rm -f /tmp/flexnetos-runner-count.$$
  else
    add_check github WARN "org runners" "cannot list org runners; admin/actions visibility may be required"
  fi
else
  add_check github WARN "gh auth" "gh missing or unauthenticated; live GitHub checks skipped"
fi

if have docker; then
  if docker info >/dev/null 2>&1; then
    add_check host OK "docker" "daemon reachable"
  else
    add_check host WARN "docker" "daemon unavailable or user lacks access"
  fi
fi

if have systemctl; then
  if systemctl list-units --all 'actions.runner.*' --no-pager >/tmp/flexnetos-runner-units.$$ 2>/dev/null; then
    count="$(grep -c 'actions.runner' /tmp/flexnetos-runner-units.$$ || true)"
    add_check host OK "systemd runner units" "$count actions.runner.* unit(s) visible"
  else
    add_check host WARN "systemd runner units" "systemd not reachable or no permission"
  fi
  rm -f /tmp/flexnetos-runner-units.$$
fi

if [[ -d "$RUNNER_HOME" ]]; then
  add_check runner OK "runner home" "$RUNNER_HOME exists"
else
  add_check runner WARN "runner home" "$RUNNER_HOME missing; install step not run on this host"
fi
if [[ -x "$RUNNER_HOME/config.sh" ]]; then
  add_check runner OK "config.sh" "$RUNNER_HOME/config.sh executable"
else
  add_check runner WARN "config.sh" "runner not installed/configurable yet"
fi
if [[ -d "$RUNNER_WORK_DIR" ]]; then
  add_check runner OK "work dir" "$RUNNER_WORK_DIR exists"
else
  add_check runner WARN "work dir" "$RUNNER_WORK_DIR missing; will be created by activation"
fi

disk_target="$RUNNER_HOME"
[[ -d "$disk_target" ]] || disk_target="$HOME"
if df -Pk "$disk_target" >/tmp/flexnetos-runner-df.$$ 2>/dev/null; then
  avail_kb="$(awk 'NR==2 {print $4}' /tmp/flexnetos-runner-df.$$)"
  avail_gb=$((avail_kb / 1024 / 1024))
  if [[ "$avail_gb" -ge 5 ]]; then
    add_check host OK "disk free" "${avail_gb} GiB available near $disk_target"
  else
    add_check host WARN "disk free" "${avail_gb} GiB available near $disk_target; runner jobs may need more"
  fi
fi
rm -f /tmp/flexnetos-runner-df.$$

if [[ "$RUNNER_LABELS" == "self-hosted" ]]; then
  add_check runner FAIL "label discipline" "RUNNER_LABELS must not be only self-hosted"
elif [[ "$RUNNER_LABELS" == *self-hosted* && "$RUNNER_LABELS" == *local* ]]; then
  add_check runner OK "label discipline" "$RUNNER_LABELS"
else
  add_check runner WARN "label discipline" "expected self-hosted plus local-specific labels; got $RUNNER_LABELS"
fi

if [[ -f "$ROOT/runner/.env.example" ]]; then
  add_check runner OK "env template" "runner/.env.example present"
else
  add_check runner FAIL "env template" "runner/.env.example missing"
fi

if [[ "$JSON" -eq 1 ]]; then
  python3 - "$checks_file" <<'PY'
import json, sys
rows = []
for line in open(sys.argv[1], encoding='utf-8'):
    area, status, name, detail = line.rstrip('\n').split('\t', 3)
    rows.append({'area': area, 'status': status, 'name': name, 'detail': detail})
print(json.dumps(rows, indent=2, sort_keys=True))
PY
else
  printf 'FlexNetOS local runner doctor\nMode: read-only\n\n'
  printf '%-10s %-6s %-24s %s\n' Area Status Check Detail
  printf '%-10s %-6s %-24s %s\n' '----------' '------' '------------------------' '----------------------------------------'
  while IFS=$'\t' read -r area status name detail; do
    printf '%-10s %-6s %-24s %s\n' "$area" "$status" "$name" "$detail"
  done <"$checks_file"
  fails="$(awk -F '\t' '$2=="FAIL" {c++} END {print c+0}' "$checks_file")"
  warns="$(awk -F '\t' '$2=="WARN" {c++} END {print c+0}' "$checks_file")"
  oks="$(awk -F '\t' '$2=="OK" {c++} END {print c+0}' "$checks_file")"
  printf '\nSummary: %s ok, %s warnings, %s failures\n' "$oks" "$warns" "$fails"
fi

if [[ "$STRICT" -eq 1 ]] && awk -F '\t' '$2=="FAIL" {found=1} END {exit found ? 0 : 1}' "$checks_file"; then
  exit 1
fi
exit 0
