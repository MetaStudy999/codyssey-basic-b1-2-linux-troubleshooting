#!/usr/bin/env bash
# B1-2 diagnostic monitor for OOM / CPU Spike / Deadlock evidence collection.
# Usage: ./monitor.sh <PID> <output-file> [interval-seconds]
# This script observes a target process only; it does not change target limits.

set -u

PID="${1:-}"
OUT="${2:-}"
INTERVAL="${3:-2}"

usage() {
    echo "Usage: $0 <PID> <output-file> [interval-seconds]" >&2
}

if [ -z "$PID" ] || [ -z "$OUT" ]; then
    usage
    exit 2
fi

if ! [[ "$PID" =~ ^[0-9]+$ ]] || [ "$PID" -le 0 ]; then
    echo "[FAIL] PID must be a positive integer" >&2
    exit 2
fi

if ! [[ "$INTERVAL" =~ ^[0-9]+([.][0-9]+)?$ ]] \
   || ! awk -v value="$INTERVAL" 'BEGIN { exit !(value > 0) }'; then
    echo "[FAIL] interval must be a number greater than 0" >&2
    exit 2
fi

for cmd in ps awk date sleep tee kill dirname mkdir wc tr; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "[FAIL] required command missing: $cmd" >&2
        exit 2
    }
done

OUT_DIR=$(dirname -- "$OUT")
mkdir -p -- "$OUT_DIR" || {
    echo "[FAIL] cannot create output directory: $OUT_DIR" >&2
    exit 2
}

# Refuse to monitor a PID that was already absent at startup. This catches
# accidental reuse of an old PID before a misleading evidence file is created.
if ! kill -0 "$PID" 2>/dev/null; then
    echo "[FAIL] target PID does not exist at monitor start: $PID" >&2
    exit 1
fi

stop_requested=0
trap 'stop_requested=1' INT TERM

STARTED_AT=$(date '+%Y-%m-%d %H:%M:%S')
printf '# B1-2 diagnostic monitor\n' >> "$OUT"
printf '# started_at=%s pid=%s interval=%ss\n' "$STARTED_AT" "$PID" "$INTERVAL" >> "$OUT"
printf '# TIMESTAMP PID STAT CPU%% MEM%% RSS_KB THREADS ELAPSED\n' >> "$OUT"

SAMPLES=0
while [ "$stop_requested" -eq 0 ]; do
    if ! kill -0 "$PID" 2>/dev/null; then
        printf '[%s] PID:%s STATUS:EXITED SAMPLES:%s\n' \
            "$(date '+%Y-%m-%d %H:%M:%S')" "$PID" "$SAMPLES" | tee -a "$OUT"
        exit 0
    fi

    SAMPLE=$(ps -p "$PID" -o pid=,stat=,%cpu=,%mem=,rss=,etime= 2>/dev/null || true)
    if [ -z "$SAMPLE" ]; then
        printf '[%s] PID:%s STATUS:PS_UNAVAILABLE\n' \
            "$(date '+%Y-%m-%d %H:%M:%S')" "$PID" | tee -a "$OUT"
        sleep "$INTERVAL"
        continue
    fi

    read -r SAMPLE_PID STAT CPU MEM RSS ELAPSED <<< "$SAMPLE"
    THREADS=$(ps -L -p "$PID" --no-headers 2>/dev/null | wc -l | tr -d ' ')
    TS=$(date '+%Y-%m-%d %H:%M:%S')
    SAMPLES=$((SAMPLES + 1))

    printf '[%s] PID:%s STAT:%s CPU:%s%% MEM:%s%% RSS_KB:%s THREADS:%s ELAPSED:%s\n' \
        "$TS" "$SAMPLE_PID" "$STAT" "$CPU" "$MEM" "$RSS" "$THREADS" "$ELAPSED" | tee -a "$OUT"

    sleep "$INTERVAL"
done

printf '[%s] PID:%s STATUS:MONITOR_STOPPED_BY_USER SAMPLES:%s\n' \
    "$(date '+%Y-%m-%d %H:%M:%S')" "$PID" "$SAMPLES" | tee -a "$OUT"
exit 0
