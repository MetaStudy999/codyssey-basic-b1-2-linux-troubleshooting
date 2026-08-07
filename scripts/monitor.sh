#!/usr/bin/env bash
set -u

# B1-2 one-shot process monitor.
#
# Purpose:
# - collect objective process-level CPU/MEM/RSS/state data for the supplied
#   agent-leak-app without modifying or introspecting the binary;
# - append timestamped observations that can later be cited in OOM/CPU/deadlock
#   reports.
#
# This script does not decide the root cause. Evidence must be interpreted with
# the supplied application's own logs and additional ps/top thread observations.

umask 0027

AGENT_PROCESS_PATTERN="${AGENT_PROCESS_PATTERN:-agent-leak-app}"
AGENT_PORT="${AGENT_PORT:-15034}"
AGENT_LOG_DIR="${AGENT_LOG_DIR:-${PWD}/evidence/runtime}"
MONITOR_LOG="${B1_2_MONITOR_LOG:-${AGENT_LOG_DIR}/monitor.log}"

error() {
  printf '[ERROR] %s\n' "$*" >&2
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "required command not found: $1"
    exit 2
  fi
}

require_command pgrep
require_command ps
require_command awk
require_command date

if [[ ! -d "$AGENT_LOG_DIR" ]]; then
  error "log directory does not exist: $AGENT_LOG_DIR"
  exit 2
fi

if [[ ! -w "$AGENT_LOG_DIR" ]]; then
  error "log directory is not writable: $AGENT_LOG_DIR"
  exit 2
fi

TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S%z')"
PID="$(pgrep -f -- "$AGENT_PROCESS_PATTERN" | head -n 1 || true)"

if [[ -z "$PID" ]]; then
  LINE="[$TIMESTAMP] PROCESS_STATE:missing PATTERN:${AGENT_PROCESS_PATTERN} PORT:${AGENT_PORT}"
  printf '%s\n' "$LINE" | tee -a "$MONITOR_LOG"
  exit 1
fi

# ps fields:
# %cpu = process CPU percentage
# %mem = process resident-memory percentage
# rss  = resident set size in KiB
# etime = elapsed wall time
# stat = process state flags
# comm = executable name
read -r CPU MEM RSS_KB ETIME STAT COMM < <(
  ps -p "$PID" -o %cpu=,%mem=,rss=,etime=,stat=,comm= | awk 'NR == 1 {print $1, $2, $3, $4, $5, $6}'
)

if [[ -z "${CPU:-}" || -z "${MEM:-}" || -z "${RSS_KB:-}" ]]; then
  error "failed to collect process metrics for PID=$PID"
  exit 2
fi

THREADS="$(ps -T -p "$PID" --no-headers 2>/dev/null | awk 'END {print NR+0}')"

PORT_STATE="unknown"
if command -v ss >/dev/null 2>&1; then
  if ss -lntH 2>/dev/null | awk -v port="$AGENT_PORT" '$4 ~ (":" port "$") {found=1} END {exit !found}'; then
    PORT_STATE="listen"
  else
    PORT_STATE="not-listen"
  fi
fi

LINE="[$TIMESTAMP] PID:${PID} CPU:${CPU}% MEM:${MEM}% RSS_KB:${RSS_KB} THREADS:${THREADS} STAT:${STAT} ETIME:${ETIME} COMM:${COMM} PORT:${AGENT_PORT}/${PORT_STATE}"
printf '%s\n' "$LINE" | tee -a "$MONITOR_LOG"

exit 0
