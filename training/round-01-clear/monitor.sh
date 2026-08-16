#!/usr/bin/env bash
# B1-2 diagnostic monitor for OOM / CPU Spike / Deadlock evidence collection.
# Usage: ./monitor.sh <PID> <output-file> [interval-seconds]

set -u

PID="${1:-}"
OUT="${2:-}"
INTERVAL="${3:-2}"

if [ -z "$PID" ] || [ -z "$OUT" ]; then
    echo "Usage: $0 <PID> <output-file> [interval-seconds]" >&2
    exit 2
fi

if ! [[ "$PID" =~ ^[0-9]+$ ]]; then
    echo "[FAIL] PID must be numeric" >&2
    exit 2
fi

if ! [[ "$INTERVAL" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "[FAIL] interval must be numeric" >&2
    exit 2
fi

mkdir -p "$(dirname "$OUT")"

stop_requested=0
trap 'stop_requested=1' INT TERM

printf '# B1-2 diagnostic monitor\n' >> "$OUT"
printf '# started_at=%s pid=%s interval=%ss\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$PID" "$INTERVAL" >> "$OUT"
printf '# TIMESTAMP PID STAT CPU%% MEM%% RSS_KB THREADS ELAPSED\n' >> "$OUT"

while [ "$stop_requested" -eq 0 ]; do
    if ! kill -0 "$PID" 2>/dev/null; then
        printf '[%s] PID:%s STATUS:EXITED\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$PID" | tee -a "$OUT"
        exit 0
    fi

    SAMPLE=$(ps -p "$PID" -o pid=,stat=,%cpu=,%mem=,rss=,etime= 2>/dev/null || true)
    if [ -z "$SAMPLE" ]; then
        printf '[%s] PID:%s STATUS:PS_UNAVAILABLE\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$PID" | tee -a "$OUT"
        sleep "$INTERVAL"
        continue
    fi

    read -r _PID STAT CPU MEM RSS ELAPSED <<< "$SAMPLE"
    THREADS=$(ps -L -p "$PID" --no-headers 2>/dev/null | wc -l | tr -d ' ')
    TS=$(date '+%Y-%m-%d %H:%M:%S')

    printf '[%s] PID:%s STAT:%s CPU:%s%% MEM:%s%% RSS_KB:%s THREADS:%s ELAPSED:%s\n' \
        "$TS" "$_PID" "$STAT" "$CPU" "$MEM" "$RSS" "$THREADS" "$ELAPSED" | tee -a "$OUT"

    sleep "$INTERVAL"
done

printf '[%s] PID:%s STATUS:MONITOR_STOPPED_BY_USER\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$PID" | tee -a "$OUT"
exit 0
