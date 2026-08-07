#!/usr/bin/env python3
"""Sample per-process CPU from /proc over short intervals for B1-2 evidence.

Usage: cpu_interval_sampler.py <process-group-id> <seconds> [interval]
No process memory is modified; this is Linux /proc observation only.
"""
from __future__ import annotations

import os
import sys
import time
from pathlib import Path

pgid = int(sys.argv[1])
duration = float(sys.argv[2])
interval = float(sys.argv[3]) if len(sys.argv) > 3 else 0.25
hz = os.sysconf(os.sysconf_names["SC_CLK_TCK"])


def read_stat(pid: int):
    try:
        text = Path(f"/proc/{pid}/stat").read_text()
        close = text.rfind(")")
        comm = text[text.find("(") + 1 : close]
        rest = text[close + 2 :].split()
        # rest[0] is field 3 (state), so pgrp field 5 -> rest[2],
        # utime field 14 -> rest[11], stime field 15 -> rest[12].
        pgrp = int(rest[2])
        ticks = int(rest[11]) + int(rest[12])
        state = rest[0]
        rss_pages = int(rest[21])  # field 24
        return comm, pgrp, ticks, state, rss_pages
    except (FileNotFoundError, ProcessLookupError, PermissionError, ValueError, IndexError):
        return None


def group_snapshot():
    result = {}
    for entry in Path("/proc").iterdir():
        if not entry.name.isdigit():
            continue
        pid = int(entry.name)
        stat = read_stat(pid)
        if stat and stat[1] == pgid:
            result[pid] = stat
    return result

start = time.monotonic()
previous_time = start
previous = group_snapshot()
print("timestamp_s,pid,comm,state,cpu_percent,rss_kib", flush=True)
while True:
    time.sleep(interval)
    now = time.monotonic()
    current = group_snapshot()
    dt = now - previous_time
    for pid, stat in sorted(current.items()):
        comm, _, ticks, state, rss_pages = stat
        if pid in previous:
            delta_ticks = ticks - previous[pid][2]
            cpu = (delta_ticks / hz) / dt * 100.0 if dt > 0 else 0.0
        else:
            cpu = 0.0
        rss_kib = rss_pages * (os.sysconf("SC_PAGE_SIZE") // 1024)
        print(f"{now-start:.3f},{pid},{comm},{state},{cpu:.2f},{rss_kib}", flush=True)
    if not current or now - start >= duration:
        break
    previous = current
    previous_time = now
