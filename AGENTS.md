# AGENTS.md — B1-2 Linux Troubleshooting

## Mission boundary

This repository is the only writable workspace for the B1-2 Workcell.

- Mission: `B1-2` — 컴퓨터가 갑자기 느려지거나 멈췄을 때 원인 찾아 고치기
- Work branch: `mission/B1-2`
- Control Tower baseline: `0d1581b3e82366988f57e1d76da311c028b8e15e`
- Control Tower and every other Mission repository are READ ONLY.

## Source of Truth

Use this order when sources disagree:

1. `b1-2-mission.pdf`
2. `b1-2-mission.md`
3. verified official Evaluation, if recovered
4. directly related official operation material
5. `MISSION-WORK-PACKET.md`
6. README / learning docs / code / tests / reports / evidence

Known G1 result:

- Mission PDF: `VALID`
- Mission Markdown: substantive but `CONFLICT` in the prerequisites table because of conversion misalignment; PDF wins
- `b1-2-evaluation.md`: `UNVERIFIED` official provenance; use only as provisional review criteria
- Source Mode: `MISSION-LED`

Do not invent missing Evaluation requirements.

## Required mission scope

The mandatory output is three evidence-based GitHub Issue-style reports:

- OOM / memory leak
- CPU spike / watchdog termination
- deadlock / alive-but-stalled process

Each report must contain:

1. Description / symptom
2. Evidence & Logs
3. Root Cause Analysis
4. Workaround & Verification
5. Before & After comparison

Actual runtime evidence is mandatory. Mission PDF examples are reference examples only and must never be copied as if observed.

## Runtime constraints

- execute the supplied app as a non-root user
- `AGENT_PORT=15034`
- obey the Mission PDF prerequisite table and environment-variable ranges
- use the supplied binary; do not decompile or reverse engineer it
- use standard Linux observation tools
- preserve raw logs before terminating/restarting a failed process

## Allowed changes before Human Runtime

- report templates
- runtime/evidence instructions
- monitoring/support scripts using standard Linux tools
- static validation scripts
- learning notes that do not claim unobserved results

## Forbidden

- fabricated PID/timestamps/logs/CPU/MEM numbers
- marking runtime requirements PASS without executing the supplied app
- treating Mission PDF example outputs as evidence
- reverse engineering/decompiling/reconstructing the supplied binary
- changing the Control Tower or other Mission repositories
- adding bonus scheduling inference before mandatory scope is complete

## Status vocabulary

- `TODO`: not implemented/run
- `IMPLEMENTED`: artifact exists, runtime not verified
- `TESTED`: actual static/automated test completed
- `PASS`: requirement + actual verification + required evidence complete
- `NEEDS-RUNTIME`: real Linux/supplied-app execution required
- `BLOCKED`: external condition prevents progress

## Verification commands

```bash
bash -n scripts/monitor.sh
python3 scripts/validate_reports.py
```

If `shellcheck` is installed, it may be used as an additional non-blocking check:

```bash
shellcheck scripts/monitor.sh
```

## Review contract

Review only for BLOCKER, MAJOR, explicit requirement omissions, false PASS, test failure, source contradiction, secret exposure, or prohibited reverse-engineering artifacts.

Default review budget:

- Self Review: 1
- Independent Review: 1
- targeted recheck only after BLOCKER/MAJOR fixes

## STOP condition

Stop mandatory work when official requirements, required tests, Human Runtime, evidence, BLOCKER=0, MAJOR=0, learning material, and Mission PR/merge are complete. Put optional scheduling inference and other enhancements in backlog.
