# B1-2 Mission Work Packet — Linux Troubleshooting

> Final execution contract before G8 merge. Control Tower is READ ONLY. All writes are limited to this Mission repository.

## 1. Identity

- Mission ID: `B1-2`
- Mission Title: 컴퓨터가 갑자기 느려지거나 멈췄을 때 원인 찾아 고치기
- Mission Repository: `MetaStudy999/codyssey-basic-b1-2-linux-troubleshooting`
- Workcell: `Chat 02 / B1-2`
- Started At: `2026-08-08 (+09:00)`
- Official classification: `required`
- Current work branch: `mission/B1-2`
- Mission PR: `#1`

## 2. Control Tower Baseline

- Control Tower: `MetaStudy999/codyssey-basic`
- Launcher main SHA checked: `f6192ad701bd1d2c317f908d210e7049f6b32310`
- Active Wave: `20260808-01`
- Frozen Baseline SHA: `0d1581b3e82366988f57e1d76da311c028b8e15e`
- Starter Packet: `docs/00-governance/work-packets/b1-2.md`
- Workcell Prompt: `docs/00-governance/workcell-prompts/b1-2.md`
- `CONTROL_TOWER_DRIFT = NONE`

Required frozen context read:

- `AGENTS.md`
- `docs/00-governance/multi-agent-mission-engineering.md`
- `docs/00-governance/source-discovery-fallback-protocol.md`
- `docs/00-governance/parallel-mission-execution.md`
- `config/missions.yaml`
- B1-2 Starter Packet / mission index

## 3. Read / Write Boundary

### READ

- frozen Control Tower baseline
- B1-2 repository
- B1-2 official Mission source and directly related metadata

### WRITE

- `MetaStudy999/codyssey-basic-b1-2-linux-troubleshooting` only

### DO NOT WRITE

- `MetaStudy999/codyssey-basic`
- any other Mission repository

Boundary result: `PASS`.

## 4. Source Inventory

| Source | Type | State | Result |
|---|---|---|---|
| `b1-2-mission.pdf` | PDF | `VALID` | authoritative 9-page Mission source |
| `b1-2-mission.md` | Markdown | `CONFLICT` | prerequisite table conversion is misaligned; PDF wins |
| `b1-2-evaluation.md` | Markdown | `UNVERIFIED` | useful provisional rubric, official provenance not proven |
| official Evaluation PDF/TXT | PDF/TXT | `MISSING` | no authoritative evaluation content recovered |
| `agent-app-leak.zip` | supplied runtime artifact | `VALID` | user supplied to repo; safely inspected and actually executed |
| `monitor.sh` | mission observation tool | `IMPLEMENTED` | B1-2 process-specific monitor created and tested |

### Source Mode / Confidence

- Source Mode: `MISSION-LED`
- Mission Confidence: `HIGH`
- Evaluation Confidence: `LOW / UNVERIFIED`

### Source conflict resolution

Mission PDF takes precedence over the Markdown conversion. Confirmed runtime prerequisites from the PDF:

- non-root execution
- `AGENT_HOME` set
- `AGENT_PORT=15034`
- `AGENT_UPLOAD_DIR=$AGENT_HOME/upload_files`
- `AGENT_KEY_PATH=$AGENT_HOME/api_keys`
- writable `AGENT_LOG_DIR`
- `MEMORY_LIMIT=50~512`
- `CPU_MAX_OCCUPY=10~100`
- `MULTI_THREAD_ENABLE` boolean family
- `$AGENT_HOME/api_keys/secret.key` contains `agent_api_key_test`
- bindable `0.0.0.0:15034`

### Remaining Source Gap

Only official Evaluation provenance remains unresolved. It is retained as a gap and is not used to invent Mission requirements.

G1 decision: `PASS`.

## 5. Mission Contract

### Goal

Use Linux process/resource telemetry plus application logs to reproduce/diagnose three failure modes and communicate them as evidence-based GitHub Issue-style technical reports:

1. OOM / memory leak
2. CPU spike / protection termination
3. deadlock / alive-but-stalled process

Required reasoning flow:

`symptom -> observation -> evidence -> root-cause reasoning -> workaround -> Before/After verification`

### Required Deliverables

- [x] OOM report
- [x] CPU report
- [x] Deadlock report
- [x] actual Runtime evidence for every report
- [x] Before/After comparison for every case
- [x] repository-link submission-ready structure

### Required Report Structure

Each report contains:

1. Description
2. Evidence & Logs
3. Root Cause Analysis
4. Workaround & Verification
5. Before & After

### Constraints

- non-root Linux execution
- supplied binary only; no decompilation/reverse engineering
- standard Linux observation tools are allowed
- examples from the Mission PDF must never be represented as actual Runtime Evidence

### Explicit Non-scope

- scheduling algorithm inference is bonus/backlog
- enterprise observability stack is not required
- binary reverse engineering is prohibited

## 6. Requirement Traceability

| ID | Requirement | Implementation / Evidence | Status |
|---|---|---|---|
| REQ-001 | 3 issue-style reports | `reports/oom.md`, `reports/cpu.md`, `reports/deadlock.md` | `PASS` |
| REQ-002 | symptom/evidence/root cause/workaround/Before-After in all reports | static validator + manual review | `PASS` |
| REQ-003 | OOM memory growth | `evidence/oom/before.log`, `after.log` | `PASS` |
| REQ-004 | OOM protection termination evidence | actual `MemoryGuard` logs | `PASS` |
| REQ-005 | `MEMORY_LIMIT` two-run comparison | 64MB/8s vs 128MB/18s | `PASS` |
| REQ-006 | target-process CPU rise | process-family `ps` + `/proc` interval telemetry | `PASS` |
| REQ-007 | CPU protection termination evidence | actual `CPU Threshold Violated!` + exit 143 | `PASS` |
| REQ-008 | `CPU_MAX_OCCUPY` Before/After | 10: cooldown/no violation; 90: rise/violation/exit | `PASS` |
| REQ-009 | Deadlock PID alive | PID 2201 + tcp/15034 alive through observation | `PASS` |
| REQ-010 | Deadlock resource/thread stall | RSS 18184 KiB stable, CPU ~0, futex wait | `PASS` |
| REQ-011 | Deadlock WAITING/BLOCKED + circular wait | actual Worker-Thread lock logs | `PASS` |
| REQ-012 | `MULTI_THREAD_ENABLE` Before/After | true deadlocks; false progresses | `PASS` |
| REQ-013 | runtime prerequisites | actual boot sequence / environment setup | `PASS` |
| REQ-014 | no reverse engineering | only archive/file metadata + normal execution/OS tools | `PASS` |
| REQ-015 | standard Linux observation tools | `ss`, `ps`, `top`, `/proc`, monitor, tail/grep | `PASS` |
| REQ-016 | learning/explanation material | `docs/LEARNING-GUIDE.md` | `PASS` |

## 7. Evaluation Mapping

`b1-2-evaluation.md` remains `UNVERIFIED`; the following are provisional review checks only.

| Provisional Criterion | Evidence | Result |
|---|---|---|
| OOM growth then termination | OOM report/evidence | satisfied |
| OOM `MEMORY_LIMIT` Before/After | 64 vs 128 | satisfied |
| CPU rise/protection result | CPU report/evidence | satisfied with supplied-build terminology |
| CPU `CPU_MAX_OCCUPY` comparison | 10 vs 90 | satisfied |
| Deadlock PID alive + stall | deadlock report/evidence | satisfied |
| Deadlock setting comparison | true vs false | satisfied |
| all three Issue-style structures | validator | satisfied |
| PID/timestamp/key logs | committed evidence | satisfied |
| OS mechanism explanations | learning guide/reports | prepared |
| improvement/triage explanations | learning guide | prepared |

Important build-specific note: the supplied binary did **not** emit literal `[WATCHDOG]` or `SIGTERM` application strings. The actual CPU protection signature was `CPU Threshold Violated!` followed by process exit code 143. No nonexistent log was fabricated.

## 8. Repository Baseline / Current Structure

- Original default branch baseline: `main @ b3f22eed3e14bda831f5afd2c745c8a8c53d906d`
- User runtime artifact main commit: `fcbe03b25fd7f478f27a08cd9364f8e0e5590819`
- Runtime artifact sync merge into mission branch: `8fbc9199288c9e0b4bc1cff9dc1ee8280dc7c443`
- Work branch: `mission/B1-2`
- Mission PR: `#1`

Current mission structure includes:

```text
.
├── AGENTS.md
├── MISSION-WORK-PACKET.md
├── README.md
├── agent-app-leak.zip
├── b1-2-mission.pdf
├── b1-2-mission.md
├── b1-2-evaluation.md
├── reports/
│   ├── oom.md
│   ├── cpu.md
│   └── deadlock.md
├── evidence/
│   ├── oom/
│   ├── cpu/
│   └── deadlock/
├── scripts/
│   ├── monitor.sh
│   ├── validate_reports.py
│   ├── run_runtime_cases.sh
│   ├── run_deadlock_probe.sh
│   ├── run_cpu_probe.sh
│   └── cpu_interval_sampler.py
├── docs/
│   ├── RUNTIME-GUIDE.md
│   ├── LEARNING-GUIDE.md
│   └── SELF-REVIEW.md
└── .github/workflows/
```

## 9. Mission-specific TOC

```text
B1-2
├── Source & Mission Contract
├── Runtime Prerequisites
├── Observability Baseline
├── OOM / Memory Leak
│   ├── RSS/Heap growth
│   ├── MemoryGuard termination
│   └── MEMORY_LIMIT Before/After
├── CPU Spike / Protection
│   ├── process-family identification
│   ├── /proc interval telemetry
│   ├── CPU Threshold violation
│   └── CPU_MAX_OCCUPY Before/After
├── Deadlock
│   ├── PID alive
│   ├── RSS/CPU/log stall
│   ├── futex/thread wait
│   ├── circular wait
│   └── MULTI_THREAD_ENABLE Before/After
├── Reports
├── Evidence
├── Learning
└── Handoff
```

## 10. Scope / Engineering Plan

### Prompt Engineering

- ROLE: B1-2 Orchestrator/Integrator
- GOAL: satisfy official Mission requirements without inventing runtime results
- SCOPE: B1-2 repo only
- STOP: mandatory requirements + tests + Runtime + Evidence + BLOCKER 0 / MAJOR 0 + merge

### Context Engineering

Only B1-2 Source, frozen governance, current repo state, tests and actual Runtime Evidence are used.

### Harness Engineering

- one Mission branch
- read-only Control Tower
- bounded non-root GitHub-hosted Linux runs
- artifacts retained temporarily; curated actual evidence committed permanently
- expected/sample output separated from actual output

### Loop Engineering

- initial self-review: complete
- runtime-driven fixes: process PID selection corrected; focused CPU/deadlock probes added
- final self-review: required before G8
- no endless review/refactor loop

### Fusion Engineering

Verdict priority: `Mission Source -> Test -> Runtime -> Evidence`.

## 11. Agent Routing

- Orchestrator / Integrator: `ChatGPT`
- Builder role: ChatGPT using repository tools and deterministic GitHub Actions harness
- Independent Reviewer: no separate independent-model reviewer tool is available in this workcell environment; no false independent-review claim is made
- Compensating verification: deterministic workflows + final self-review + PR diff inspection
- Runtime Authority: actual non-root GitHub-hosted Ubuntu runtime for automatable Linux checks
- Human Runtime: not additionally required because the supplied Linux x86 binary executed successfully in the controlled runtime and produced the required objective evidence

## 12. Dependency / Drift Check

- B1-1 dependency: `RECOMMENDED`, not official prerequisite
- B1-1 monitor was inspected read-only; B1-2 needed process-specific metrics so a mission-local monitor was used
- Control Tower drift: `NONE`
- Source drift: runtime artifact was later supplied by user and integrated; this resolved the prior artifact gap without changing official requirements
- Action: `CONTINUE TO FINAL VALIDATION / G8`

## 13. Test Plan / Actual Results

| Test | Actual | Status |
|---|---|---|
| Mission source discovery | PDF valid; MD conflict documented; Evaluation unverified | `PASS` |
| shell syntax | monitor/runtime scripts parse | `PASS` |
| report validator | all required report structure markers | `PASS` before runtime; final rerun pending after final report edits |
| monitor missing process | records missing + exit 1 | `PASS` |
| monitor real process | listener PID metrics + port | `PASS` |
| runtime archive inspect | x86_64 + aarch64 ELF confirmed without executing inspect-time binary | `PASS` |
| boot/preflight | non-root, env/key/dirs, Agent READY, tcp/15034 | `PASS` |
| OOM two-run | actual MemoryGuard + 8s/18s comparison | `PASS` |
| CPU focused | process telemetry + setting comparison + threshold termination | `PASS` |
| CPU interval | `/proc` PID-specific interval samples | `PASS` |
| Deadlock focused | lock cycle + PID/RSS/thread wait + setting comparison | `PASS` |
| final repository validation | deterministic workflow | `TODO` immediately before G8 |

## 14. Runtime Plan / Actual Results

### Safe artifact inspection

- run `31216239334`: `PASS`
- archive SHA256: `249c9c2841718cb29ef2ed680668f328f5ee253354090225347e130a2e456641`
- x86 / arm64 executables identified

### Boot probe

- run `31216306554`: `PASS`
- non-root `runner` uid 1001
- actual app Boot checks passed and `Agent READY`
- tcp/15034 LISTEN confirmed

### Core case run

- run `31216511416`: `PASS`
- artifact `9008779652`
- OOM evidence obtained
- CPU behavior discovered
- deadlock isolation required focused follow-up because CPU protection could preempt it

### Focused deadlock

- run `31216931577`: `PASS`
- artifact `9008913750`
- actual mutual lock cycle, futex waits, PID/RSS stall, true/false comparison

### Focused CPU

- run `31217119811`: `PASS`
- artifact `9008964542`
- actual low-cap cooldown vs high-cap threshold violation/process exit

### CPU interval telemetry

- run `31217376403`: `PASS`
- artifact `9009041836`
- worker PID short-interval CPU rise observed with `/proc` tick delta

G5 decision: `PASS`.

## 15. Evidence Plan / Actual Evidence

| Evidence | Location | Status |
|---|---|---|
| OOM Before | `evidence/oom/before.log` | `PASS` |
| OOM After | `evidence/oom/after.log` | `PASS` |
| CPU Before | `evidence/cpu/before.log` | `PASS` |
| CPU After | `evidence/cpu/after.log` | `PASS` |
| CPU interval | `evidence/cpu/interval.log` | `PASS` |
| Deadlock enabled | `evidence/deadlock/enabled.log` | `PASS` |
| Deadlock disabled | `evidence/deadlock/disabled.log` | `PASS` |
| OOM report | `reports/oom.md` | `PASS` |
| CPU report | `reports/cpu.md` | `PASS` |
| Deadlock report | `reports/deadlock.md` | `PASS` |

G6 decision: `PASS`.

## 16. Completion Gates

| Gate | Exit Condition | Status |
|---|---|---|
| G1 SOURCE | Source state/mode/gap/provenance defined | `PASS` |
| G2 BUILD | required support/report implementation exists | `PASS` |
| G3 TEST | static/deterministic tests pass | `PASS` |
| G4 REVIEW | BLOCKER=0 / MAJOR=0 | `PASS`, final confirmation before merge |
| G5 RUNTIME | actual non-root Linux runtime verification | `PASS` |
| G6 EVIDENCE | required actual evidence captured and mapped | `PASS` |
| G7 LEARN | beginner learning material matches actual implementation/evidence | `PASS` |
| G8 MERGE | PR merged into mission repo main | `READY / PENDING` |

Personal learning state remains separate from artifact completion and is not automatically marked `MASTERED`.

## 17. STOP Rule

Stop additional implementation/review when:

- official required deliverables are complete
- official Mission requirements are met
- Evaluation provenance gap is explicitly retained
- actual tests/runtime/evidence are complete
- BLOCKER=0
- MAJOR=0
- PR is merged

Optional scheduling analysis, enterprise observability and further hardening are backlog only.

## 18. Handoff Contract

After final validation and Mission PR merge:

- leave `HANDOFF.md`
- leave `mission-result.yaml`
- record final Mission commit/PR/merge status
- do not modify the Control Tower from this Workcell
- Control Tower serial integration remains a separate step
