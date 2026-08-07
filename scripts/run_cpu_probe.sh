#!/usr/bin/env bash
set -euo pipefail

# Focused B1-2 CPU comparison. Captures the process family so OS-level evidence
# can identify which supplied-app process actually consumes CPU. No binary
# introspection or reverse engineering is performed.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHIVE="$ROOT/agent-app-leak.zip"
WORK=/tmp/b1-2-cpu-probe
OUT="$ROOT/cpu-probe-evidence"
PORT=15034
DURATION="${B1_2_CPU_SECONDS:-42}"

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

snapshot_family() {
  local leader="$1" listener="$2" out="$3" second="$4"
  {
    echo "===== second=$second utc=$(date -u '+%Y-%m-%dT%H:%M:%SZ') leader=$leader listener=$listener ====="
    echo '--- all supplied-app related processes ---'
    ps -eo pid=,ppid=,pgid=,stat=,ni=,%cpu=,%mem=,rss=,etime=,wchan=,comm=,args= --sort=-%cpu \
      | awk -v leader="$leader" -v listener="$listener" \
        '$1==leader || $2==leader || $1==listener || $2==listener || $0 ~ /agent-leak-app-x86/ {print}' || true
    echo '--- listener threads ---'
    if [[ -n "$listener" ]]; then
      ps -L -p "$listener" -o pid=,lwp=,ppid=,stat=,ni=,%cpu=,%mem=,rss=,wchan=,comm= || true
    fi
    echo '--- recent app log ---'
    tail -n 12 "$out/app.stdout.log" || true
  } >> "$out/process-snapshots.log" 2>&1
}

run_one() {
  local label cpu_limit dir home leader pid i rc started ended termination
  label="$1"
  cpu_limit="$2"
  dir="$OUT/$label"
  home="$WORK/$label/home"
  termination='bounded-timeout'
  mkdir -p "$dir" "$home/upload_files" "$home/api_keys"
  printf 'agent_api_key_test\n' > "$home/api_keys/secret.key"

  {
    echo "case=$label"
    echo "runtime_user=$(id -un) uid=$(id -u)"
    echo 'MEMORY_LIMIT=512'
    echo "CPU_MAX_OCCUPY=$cpu_limit"
    echo 'MULTI_THREAD_ENABLE=false'
    date -u '+started_at=%Y-%m-%dT%H:%M:%SZ'
  } | tee "$dir/summary.log"

  started="$(date +%s)"
  setsid env \
    AGENT_HOME="$home" AGENT_PORT="$PORT" \
    AGENT_UPLOAD_DIR="$home/upload_files" AGENT_KEY_PATH="$home/api_keys" \
    AGENT_LOG_DIR="$dir" MEMORY_LIMIT=512 CPU_MAX_OCCUPY="$cpu_limit" \
    MULTI_THREAD_ENABLE=false \
    "$BIN" >"$dir/app.stdout.log" 2>&1 &
  leader=$!
  echo "launcher_pid=$leader" | tee -a "$dir/summary.log"

  for _ in $(seq 1 20); do
    pid="$(listener_pid || true)"; [[ -n "$pid" ]] && break
    kill -0 "$leader" 2>/dev/null || break
    sleep .25
  done
  pid="$(listener_pid || true)"
  echo "listener_pid=$pid" | tee -a "$dir/summary.log"

  for i in $(seq 1 "$DURATION"); do
    pid="$(listener_pid || true)"
    if [[ -z "$pid" ]] && ! kill -0 "$leader" 2>/dev/null; then
      termination='process-exited'
      echo "process_exited_at_second=$i" | tee -a "$dir/summary.log"
      break
    fi
    snapshot_family "$leader" "$pid" "$dir" "$i"
    sleep 1
  done

  if kill -0 "$leader" 2>/dev/null || [[ -n "$(listener_pid || true)" ]]; then
    cleanup "$leader"
  fi
  set +e
  wait "$leader" 2>/dev/null
  rc=$?
  set -e
  ended="$(date +%s)"

  {
    date -u '+ended_at=%Y-%m-%dT%H:%M:%SZ'
    echo "elapsed_seconds=$((ended-started))"
    echo "termination=$termination"
    echo "launcher_exit_code=$rc"
    echo '--- key CPU application log lines ---'
    grep -Ei 'CpuWorker|CPU Threshold|WATCHDOG|SIGTERM|Agent READY' "$dir/app.stdout.log" "$dir/agent_app.log" 2>/dev/null || true
    echo '--- max observed OS CPU rows ---'
    grep -E 'agent-leak-app-x86' "$dir/process-snapshots.log" \
      | awk '{for(i=1;i<=NF;i++) if($i ~ /^[0-9]+(\.[0-9]+)?$/){}; print}' \
      | head -n 40 || true
  } | tee -a "$dir/summary.log"
  sleep 1
}

run_one cpu-limit-10 10
run_one cpu-limit-90 90

echo "cpu probe complete: $OUT"
