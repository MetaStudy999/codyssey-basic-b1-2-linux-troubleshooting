#!/usr/bin/env bash
set -euo pipefail

# Focused B1-2 deadlock comparison. Keeps CPU load in cooldown range so the
# fixed CPU protection does not terminate the process before lock behavior can
# be observed. No binary introspection or reverse engineering is performed.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHIVE="$ROOT/agent-app-leak.zip"
WORK=/tmp/b1-2-deadlock-probe
OUT="$ROOT/deadlock-probe-evidence"
PORT=15034
DURATION="${B1_2_DEADLOCK_SECONDS:-55}"

[[ "$(id -u)" -ne 0 ]] || { echo '[ERROR] non-root required' >&2; exit 2; }
rm -rf "$WORK" "$OUT"
mkdir -p "$WORK/bin" "$OUT"
unzip -q "$ARCHIVE" -d "$WORK/bin"
BIN="$WORK/bin/agent-leak-app-x86"
chmod +x "$BIN"

listener_pid() {
  ss -lntpH 2>/dev/null | awk -v port="$PORT" '$4 ~ (":" port "$") {print; exit}' | sed -n 's/.*pid=\([0-9][0-9]*\).*/\1/p'
}

cleanup() {
  local leader="${1:-}" p
  [[ -n "$leader" ]] && kill -TERM -- "-$leader" 2>/dev/null || true
  p="$(listener_pid || true)"; [[ -n "$p" ]] && kill -TERM "$p" 2>/dev/null || true
  sleep 1
  [[ -n "$leader" ]] && kill -KILL -- "-$leader" 2>/dev/null || true
  p="$(listener_pid || true)"; [[ -n "$p" ]] && kill -KILL "$p" 2>/dev/null || true
}

run_one() {
  local label mt dir home
  local leader pid i
  label="$1"
  mt="$2"
  dir="$OUT/$label"
  home="$WORK/$label/home"

  mkdir -p "$dir" "$home/upload_files" "$home/api_keys"
  printf 'agent_api_key_test\n' > "$home/api_keys/secret.key"

  {
    echo "case=$label"
    echo "runtime_user=$(id -un) uid=$(id -u)"
    echo 'MEMORY_LIMIT=512'
    echo 'CPU_MAX_OCCUPY=10'
    echo "MULTI_THREAD_ENABLE=$mt"
    date -u '+started_at=%Y-%m-%dT%H:%M:%SZ'
  } | tee "$dir/summary.log"

  setsid env \
    AGENT_HOME="$home" AGENT_PORT="$PORT" \
    AGENT_UPLOAD_DIR="$home/upload_files" AGENT_KEY_PATH="$home/api_keys" \
    AGENT_LOG_DIR="$dir" MEMORY_LIMIT=512 CPU_MAX_OCCUPY=10 \
    MULTI_THREAD_ENABLE="$mt" \
    "$BIN" >"$dir/app.stdout.log" 2>&1 &
  leader=$!
  echo "launcher_pid=$leader" | tee -a "$dir/summary.log"

  for _ in $(seq 1 20); do
    pid="$(listener_pid || true)"; [[ -n "$pid" ]] && break
    sleep .25
  done
  pid="$(listener_pid || true)"
  echo "listener_pid=$pid" | tee -a "$dir/summary.log"

  for i in $(seq 1 "$DURATION"); do
    pid="$(listener_pid || true)"
    if [[ -z "$pid" ]]; then
      echo "listener_missing_at_second=$i" | tee -a "$dir/summary.log"
      break
    fi

    AGENT_PROCESS_PATTERN=agent-leak-app-x86 AGENT_PORT="$PORT" AGENT_LOG_DIR="$dir" \
      B1_2_MONITOR_LOG="$dir/monitor.log" bash "$ROOT/scripts/monitor.sh" >/dev/null 2>&1 || true

    if (( i == 1 || i % 5 == 0 )); then
      {
        echo "===== second=$i utc=$(date -u '+%Y-%m-%dT%H:%M:%SZ') listener=$pid ====="
        echo '--- listener status ---'
        ps -p "$pid" -o pid=,ppid=,stat=,%cpu=,%mem=,rss=,etime=,wchan=,comm= || true
        echo '--- threads ---'
        ps -L -p "$pid" -o pid=,lwp=,ppid=,stat=,%cpu=,%mem=,rss=,wchan=,comm= || true
        echo '--- process family ---'
        ps -eo pid=,ppid=,stat=,%cpu=,%mem=,rss=,etime=,wchan=,comm=,args= --forest \
          | awk -v root="$leader" -v listen="$pid" '$1==root || $1==listen || $2==root || $2==listen {print}' || true
        echo '--- recent app log ---'
        tail -n 12 "$dir/app.stdout.log" || true
      } >> "$dir/process-snapshots.log" 2>&1
    fi
    sleep 1
  done

  pid="$(listener_pid || true)"
  echo "listener_alive_end=$([[ -n "$pid" ]] && echo yes || echo no)" | tee -a "$dir/summary.log"
  [[ -n "$pid" ]] && ps -p "$pid" -o pid=,ppid=,stat=,%cpu=,%mem=,rss=,etime=,wchan=,comm= | tee -a "$dir/summary.log" || true
  echo '--- final log tail ---' | tee -a "$dir/summary.log"
  tail -n 30 "$dir/app.stdout.log" | tee -a "$dir/summary.log" || true
  cleanup "$leader"
  sleep 1
}

run_one deadlock-enabled true
run_one deadlock-disabled false

echo "deadlock probe complete: $OUT"
