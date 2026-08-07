#!/usr/bin/env bash
set -euo pipefail

# B1-2 bounded Linux runtime harness.
# Runs the official supplied x86 binary as the current non-root user and stores
# actual logs/telemetry for the six Before/After configurations required by the
# mission. It does not infer PASS; reports must be updated from the evidence.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHIVE="${B1_2_ARCHIVE:-$ROOT/agent-app-leak.zip}"
OUT_ROOT="${B1_2_OUT_ROOT:-$ROOT/runtime-case-evidence}"
WORK_ROOT="${B1_2_WORK_ROOT:-/tmp/b1-2-runtime}"
PORT="${AGENT_PORT:-15034}"

if [[ "$(id -u)" -eq 0 ]]; then
  echo "[ERROR] Mission requires non-root execution." >&2
  exit 2
fi

for cmd in unzip file setsid ps ss awk sed date bash; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "[ERROR] required command not found: $cmd" >&2
    exit 2
  }
done

rm -rf "$WORK_ROOT" "$OUT_ROOT"
mkdir -p "$WORK_ROOT/bin" "$OUT_ROOT"
unzip -q "$ARCHIVE" -d "$WORK_ROOT/bin"
BIN="$WORK_ROOT/bin/agent-leak-app-x86"
chmod +x "$BIN"

listener_pid() {
  ss -lntpH 2>/dev/null \
    | awk -v port="$PORT" '$4 ~ (":" port "$") {print; exit}' \
    | sed -n 's/.*pid=\([0-9][0-9]*\).*/\1/p'
}

port_is_free() {
  ! ss -lntH 2>/dev/null | awk -v port="$PORT" '$4 ~ (":" port "$") {found=1} END {exit !found}'
}

cleanup_processes() {
  local launcher_pid="$1" pid
  if [[ -n "$launcher_pid" ]]; then
    kill -TERM -- "-$launcher_pid" 2>/dev/null || true
  fi
  pid="$(listener_pid || true)"
  if [[ -n "$pid" ]]; then
    kill -TERM "$pid" 2>/dev/null || true
  fi
  sleep 1
  if [[ -n "$launcher_pid" ]]; then
    kill -KILL -- "-$launcher_pid" 2>/dev/null || true
  fi
  pid="$(listener_pid || true)"
  if [[ -n "$pid" ]]; then
    kill -KILL "$pid" 2>/dev/null || true
  fi
}

run_case() {
  local name="$1" memory_limit="$2" cpu_limit="$3" multi_thread="$4" max_seconds="$5"
  local case_dir="$OUT_ROOT/$name"
  local home="$WORK_ROOT/$name/home"
  local upload="$home/upload_files"
  local keys="$home/api_keys"
  local launcher_pid="" pid="" started_epoch ended_epoch sample rc=0 termination="bounded-timeout"

  mkdir -p "$case_dir" "$upload" "$keys"
  printf 'agent_api_key_test\n' > "$keys/secret.key"

  if ! port_is_free; then
    echo "[ERROR] tcp/$PORT is occupied before case $name" >&2
    return 2
  fi

  {
    echo "case=$name"
    echo "runtime_user=$(id -un) uid=$(id -u)"
    echo "MEMORY_LIMIT=$memory_limit"
    echo "CPU_MAX_OCCUPY=$cpu_limit"
    echo "MULTI_THREAD_ENABLE=$multi_thread"
    echo "AGENT_PORT=$PORT"
    echo "max_seconds=$max_seconds"
    echo "binary=$(file "$BIN")"
  } | tee "$case_dir/case-summary.log"

  started_epoch="$(date +%s)"
  date -u '+started_at=%Y-%m-%dT%H:%M:%SZ' | tee -a "$case_dir/case-summary.log"

  setsid env \
    AGENT_HOME="$home" \
    AGENT_PORT="$PORT" \
    AGENT_UPLOAD_DIR="$upload" \
    AGENT_KEY_PATH="$keys" \
    AGENT_LOG_DIR="$case_dir" \
    MEMORY_LIMIT="$memory_limit" \
    CPU_MAX_OCCUPY="$cpu_limit" \
    MULTI_THREAD_ENABLE="$multi_thread" \
    "$BIN" >"$case_dir/app.stdout.log" 2>&1 &
  launcher_pid=$!
  echo "launcher_pid=$launcher_pid" | tee -a "$case_dir/case-summary.log"

  # Give the boot sequence a short bounded opportunity to open the mission port.
  for _ in $(seq 1 20); do
    pid="$(listener_pid || true)"
    [[ -n "$pid" ]] && break
    kill -0 "$launcher_pid" 2>/dev/null || break
    sleep 0.25
  done
  pid="$(listener_pid || true)"
  [[ -n "$pid" ]] && echo "initial_listener_pid=$pid" | tee -a "$case_dir/case-summary.log"

  for sample in $(seq 1 "$max_seconds"); do
    pid="$(listener_pid || true)"
    if [[ -z "$pid" ]] && ! kill -0 "$launcher_pid" 2>/dev/null; then
      termination="process-exited"
      echo "process_exited_at_sample=$sample" | tee -a "$case_dir/case-summary.log"
      break
    fi

    AGENT_PROCESS_PATTERN='agent-leak-app-x86' \
      AGENT_PORT="$PORT" \
      AGENT_LOG_DIR="$case_dir" \
      B1_2_MONITOR_LOG="$case_dir/monitor.log" \
      bash "$ROOT/scripts/monitor.sh" >>"$case_dir/monitor.stdout.log" 2>&1 || true

    pid="$(listener_pid || true)"
    if [[ -n "$pid" ]] && (( sample == 1 || sample % 5 == 0 )); then
      {
        echo "=== sample=$sample utc=$(date -u '+%Y-%m-%dT%H:%M:%SZ') pid=$pid ==="
        ps -p "$pid" -o pid=,ppid=,%cpu=,%mem=,rss=,etime=,stat=,comm= || true
        ps -L -p "$pid" -o pid=,lwp=,psr=,stat=,%cpu=,%mem=,comm= || true
        if command -v top >/dev/null 2>&1; then
          top -H -b -n 1 -p "$pid" | head -n 25 || true
        fi
      } >>"$case_dir/thread-snapshots.log" 2>&1
    fi

    sleep 1
  done

  if kill -0 "$launcher_pid" 2>/dev/null || [[ -n "$(listener_pid || true)" ]]; then
    cleanup_processes "$launcher_pid"
  fi

  set +e
  wait "$launcher_pid" 2>/dev/null
  rc=$?
  set -e
  ended_epoch="$(date +%s)"

  {
    date -u '+ended_at=%Y-%m-%dT%H:%M:%SZ'
    echo "elapsed_seconds=$((ended_epoch - started_epoch))"
    echo "termination=$termination"
    echo "launcher_exit_code=$rc"
    echo "final_port_listener=$(listener_pid || true)"
    echo "--- key application log lines ---"
    grep -E -i 'MemoryWorker|MemoryGuard|CPU|WATCHDOG|SIGTERM|WAITING|BLOCKED|deadlock|lock|Agent READY|SafetyGuard' "$case_dir/app.stdout.log" "$case_dir/agent_app.log" 2>/dev/null || true
    echo "--- evidence files ---"
    find "$case_dir" -maxdepth 1 -type f -printf '%f %s bytes\n' | sort
  } | tee -a "$case_dir/case-summary.log"

  # Ensure the next case starts with a clean port.
  for _ in $(seq 1 20); do
    port_is_free && break
    sleep 0.25
  done
}

# Before/After pairs selected from the official allowed ranges.
# OOM pair: lower vs higher MEMORY_LIMIT.
run_case oom-before 64 100 false 20
run_case oom-after 128 100 false 30

# CPU pair: low watchdog threshold vs relaxed threshold. Memory is kept high and
# multithreading disabled so CPU evidence is not pre-empted by OOM/deadlock.
run_case cpu-before 512 10 false 45
run_case cpu-after 512 90 false 45

# Deadlock pair: concurrency enabled vs disabled. Other guards are relaxed.
run_case deadlock-before 512 100 true 45
run_case deadlock-after 512 100 false 45

echo "Runtime cases completed. Evidence root: $OUT_ROOT"
