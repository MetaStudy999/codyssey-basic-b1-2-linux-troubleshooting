# B1-2 Mission Work Packet — Linux Troubleshooting

> Final execution contract immediately before G8 merge. Control Tower is READ ONLY; this Workcell writes only the B1-2 Mission repository.

## 1. Identity

- Mission ID: `B1-2`
- Title: 컴퓨터가 갑자기 느려지거나 멈췄을 때 원인 찾아 고치기
- Repository: `MetaStudy999/codyssey-basic-b1-2-linux-troubleshooting`
- Workcell: `Chat 02 / B1-2`
- Official classification: `required`
- Work branch: `mission/B1-2`
- Mission PR: `#1`

## 2. Control Tower Baseline

- Control Tower: `MetaStudy999/codyssey-basic`
- Active Wave: `20260808-01`
- Frozen baseline: `0d1581b3e82366988f57e1d76da311c028b8e15e`
- launcher main checked: `f6192ad701bd1d2c317f908d210e7049f6b32310`
- Starter Packet: `docs/00-governance/work-packets/b1-2.md`
- Workcell Prompt: `docs/00-governance/workcell-prompts/b1-2.md`
- `CONTROL_TOWER_DRIFT = NONE`

Frozen governance read: `AGENTS.md`, Multi-Agent Playbook, Source Discovery Protocol, Parallel Mission Execution, `config/missions.yaml`, B1-2 packet/index.

## 3. Read / Write Boundary

- READ: frozen Control Tower baseline, B1-2 repo, B1-2 official Source
- WRITE: B1-2 repo only
- DO NOT WRITE: Control Tower or any other Mission repo
- Result: `PASS`

## 4. Source Inventory

| Source | State | Decision |
|---|---|---|
| `b1-2-mission.pdf` | `VALID` | authoritative Mission Source |
| `b1-2-mission.md` | `CONFLICT` | prerequisite table conversion is misaligned; PDF wins |
| `b1-2-evaluation.md` | `UNVERIFIED` | provisional rubric only; official provenance not proven |
| official Evaluation PDF/TXT | `MISSING` | retained Source Gap |
| `agent-app-leak.zip` | `VALID` | official supplied runtime artifact; actually executed |
| B1-2 `monitor.sh` | `IMPLEMENTED/TESTED` | process-specific observation tool |

- Source Mode: `MISSION-LED`
- Mission confidence: `HIGH`
- Evaluation confidence: `LOW / UNVERIFIED`
- G1: `PASS`

Confirmed PDF prerequisites: non-root, `AGENT_HOME`, `AGENT_PORT=15034`, upload/key/log paths, `MEMORY_LIMIT=50~512`, `CPU_MAX_OCCUPY=10~100`, `MULTI_THREAD_ENABLE`, `secret.key=agent_api_key_test`, bindable `0.0.0.0:15034`.

## 5. Mission Contract

Goal: diagnose three failure modes using Linux process/resource telemetry plus application logs, then produce evidence-based GitHub Issue-style reports.

Required cases:

1. OOM / Memory Leak
2. CPU Spike / protection termination
3. Deadlock / alive-but-stalled process

Each report must contain Description, Evidence & Logs, Root Cause Analysis, Workaround & Verification, and Before & After.

Constraints:

- non-root Linux execution
- no decompilation/reverse engineering
- standard Linux observation tools allowed
- Mission examples never count as actual Evidence

Non-scope: scheduling-algorithm inference and enterprise observability hardening.

## 6. Requirement Traceability

| ID | Official Requirement | Evidence / Validation | Status |
|---|---|---|---|
| REQ-001 | 3 Issue-style reports | `reports/{oom,cpu,deadlock}.md` | `PASS` |
| REQ-002 | all mandatory report sections | final validator | `PASS` |
| REQ-003 | OOM memory growth | `evidence/oom/*` | `PASS` |
| REQ-004 | OOM MemoryGuard termination | actual MemoryGuard log | `PASS` |
| REQ-005 | `MEMORY_LIMIT` Before/After | 64MB/8s vs 128MB/18s | `PASS` |
| REQ-006 | process-specific CPU rise | process family + `/proc` interval telemetry | `PASS` |
| REQ-007 | CPU protection termination | `CPU Threshold Violated!` + exit 143 | `PASS` |
| REQ-008 | `CPU_MAX_OCCUPY` Before/After | 10: cooldown/no violation; 90: rise/violation/exit | `PASS` |
| REQ-009 | Deadlock PID alive | PID 2201 + tcp/15034 alive | `PASS` |
| REQ-010 | Deadlock CPU/MEM/thread stall | RSS 18184 KiB stable, CPU ~0, futex wait | `PASS` |
| REQ-011 | WAITING/BLOCKED + circular wait | actual Worker lock logs | `PASS` |
| REQ-012 | `MULTI_THREAD_ENABLE` Before/After | true deadlocks; false progresses | `PASS` |
| REQ-013 | runtime prerequisites | actual boot/preflight | `PASS` |
| REQ-014 | no reverse engineering | review of committed artifacts/process | `PASS` |
| REQ-015 | standard Linux diagnostic tools | `ss`, `ps`, `top`, `/proc`, monitor, tail/grep | `PASS` |
| REQ-016 | learning/explanation material | `docs/LEARNING-GUIDE.md` | `PASS` |

## 7. Evaluation Mapping

`b1-2-evaluation.md` remains `UNVERIFIED`; it is not promoted to official Source. Its provisional checks are nevertheless covered by the actual reports/evidence: OOM, CPU and Deadlock reproduction, Before/After comparisons, PID/timestamps, diagnostic procedure, OS concepts and improvement discussion.

Build-specific CPU note: the supplied executable did **not** emit literal `[WATCHDOG]` or `SIGTERM` application strings. Actual protection evidence is `CPU Threshold Violated!` followed by exit 143. No nonexistent log was fabricated.

## 8. Repository Baseline

- original main baseline: `b3f22eed3e14bda831f5afd2c745c8a8c53d906d`
- runtime artifact main commit: `fcbe03b25fd7f478f27a08cd9364f8e0e5590819`
- artifact sync merge into mission branch: `8fbc9199288c9e0b4bc1cff9dc1ee8280dc7c443`
- current branch: `mission/B1-2`

Core structure:

```text
AGENTS.md
MISSION-WORK-PACKET.md
README.md
reports/{oom,cpu,deadlock}.md
evidence/{oom,cpu,deadlock}/
scripts/{monitor,validate_reports,run_runtime_cases,run_deadlock_probe,run_cpu_probe,cpu_interval_sampler}.*
docs/{RUNTIME-GUIDE,LEARNING-GUIDE,SELF-REVIEW}.md
.github/workflows/
```

## 9. Mission-specific TOC

```text
Source/Contract
Runtime Prerequisites
Observability Baseline
OOM -> growth -> MemoryGuard -> MEMORY_LIMIT Before/After
CPU -> process telemetry -> threshold protection -> CPU_MAX_OCCUPY Before/After
Deadlock -> PID alive -> futex/circular wait -> MULTI_THREAD_ENABLE Before/After
Reports
Evidence
Learning
Handoff
```

## 10. Scope / Engineering Plan

- Prompt Engineering: one B1-2 mission, evidence-first STOP condition
- Context Engineering: only directly relevant Source/code/tests/runtime
- Harness Engineering: one work branch, bounded non-root Linux runs, curated permanent Evidence
- Loop Engineering: self-review, runtime-driven fixes, final deterministic validation; no endless review loop
- Fusion Engineering: `Mission Source -> Test -> Runtime -> Evidence`

## 11. Agent Routing

- Orchestrator / Integrator: ChatGPT
- Builder: ChatGPT through repository tools + deterministic GitHub Actions harness
- Independent Reviewer: separate independent-model reviewer tool is not exposed in this Workcell; no false independent-review claim is made
- Compensating verification: deterministic workflows + actual Runtime Evidence + final self-review + PR diff inspection
- Runtime Authority: actual non-root GitHub-hosted Ubuntu execution for automatable Linux checks
- Additional Human Runtime: not required because the official x86 binary successfully ran and produced objective Mission Evidence

## 12. Dependency / Drift Check

- B1-1 relation: `RECOMMENDED`, not official prerequisite
- B1-1 repo inspected read-only; B1-2 uses a mission-local process monitor because process-specific evidence is required
- Control Tower drift: `NONE`
- Source drift: runtime artifact was supplied later by user and safely integrated; requirements did not change
- Action: `G8 MERGE`

## 13. Test Plan / Actual Results

| Test | Actual Result |
|---|---|
| source discovery/conflict handling | `PASS` |
| shell syntax | `PASS` |
| Python compile | `PASS` |
| report contract validator | `PASS` for OOM/CPU/Deadlock |
| monitor missing/positive behavior | `PASS` |
| archive safe inspect | `PASS` |
| boot/preflight | `PASS` |
| OOM runtime | `PASS` |
| focused CPU runtime | `PASS` |
| CPU `/proc` interval telemetry | `PASS` |
| focused Deadlock runtime | `PASS` |
| final repository validation | run `31217849075` `PASS`; post-README rerun `31217903709` `PASS` |

Final validation checked all final report/evidence files, no `TODO`/`NEEDS-RUNTIME` in reports, case evidence markers, G5/G6/G7 markers, and BLOCKER/MAJOR counts.

## 14. Runtime Plan / Actual Results

| Purpose | Workflow Run | Result |
|---|---:|---|
| archive inspection | `31216239334` | `PASS` |
| boot/preflight | `31216306554` | `PASS` |
| core runtime | `31216511416` | `PASS` |
| focused Deadlock | `31216931577` | `PASS` |
| focused CPU | `31217119811` | `PASS` |
| CPU interval | `31217376403` | `PASS` |
| final validation | `31217849075`, `31217903709` | `PASS` |

G5 decision: `PASS`.

## 15. Evidence Plan / Actual Evidence

- OOM: `evidence/oom/before.log`, `after.log`
- CPU: `evidence/cpu/before.log`, `after.log`, `interval.log`
- Deadlock: `evidence/deadlock/enabled.log`, `disabled.log`
- Reports: `reports/oom.md`, `reports/cpu.md`, `reports/deadlock.md`

All are actual-runtime-derived curated evidence. G6 decision: `PASS`.

## 16. Completion Gates

| Gate | Status |
|---|---|
| G1 SOURCE | `PASS` |
| G2 BUILD | `PASS` |
| G3 TEST | `PASS` |
| G4 REVIEW | `PASS` — BLOCKER 0 / MAJOR 0 |
| G5 RUNTIME | `PASS` |
| G6 EVIDENCE | `PASS` |
| G7 LEARN | `PASS` |
| G8 MERGE | `READY / PENDING` |

Artifact completion does not imply personal `MASTERED`; personal learning state remains separate.

## 17. STOP Rule

After G8 merge, stop Mission work because official required deliverables, tests, Runtime, Evidence and learning material are complete with BLOCKER=0 and MAJOR=0. Further observability/hardening/scheduling analysis is backlog.

## 18. Handoff Contract

After Mission PR merge:

- create/finalize `HANDOFF.md`
- create/finalize `mission-result.yaml`
- record final merge commit and G1~G8 status
- do not modify the Control Tower from this Workcell
- Serial Control-Tower integration occurs separately
