# B1-2 Mission Work Packet — Linux Troubleshooting

> This file is the execution contract for the B1-2 Workcell. The Control Tower is READ ONLY. All writes are limited to this repository.

## 1. Identity

- Mission ID: `B1-2`
- Mission Title: 컴퓨터가 갑자기 느려지거나 멈췄을 때 원인 찾아 고치기
- Mission Repository: `MetaStudy999/codyssey-basic-b1-2-linux-troubleshooting`
- Workcell: `Chat 02 / B1-2`
- Started At: `2026-08-08 (+09:00)`
- Official classification: `required`

## 2. Control Tower Baseline

- Control Tower Repository: `MetaStudy999/codyssey-basic`
- Current launcher main SHA checked: `f6192ad701bd1d2c317f908d210e7049f6b32310`
- Active Wave: `20260808-01`
- Frozen Baseline SHA: `0d1581b3e82366988f57e1d76da311c028b8e15e`
- Starter Packet: `docs/00-governance/work-packets/b1-2.md`
- Workcell Prompt: `docs/00-governance/workcell-prompts/b1-2.md`
- Baseline Rule: this Workcell does not change the frozen baseline.

### Required Control Tower Context read from the frozen baseline

- `AGENTS.md`
- `docs/00-governance/multi-agent-mission-engineering.md`
- `docs/00-governance/source-discovery-fallback-protocol.md`
- `docs/00-governance/parallel-mission-execution.md`
- `config/missions.yaml`
- `docs/00-governance/work-packets/b1-2.md`
- `docs/02-domains/01-linux-os/b1-2-linux-troubleshooting.md`

### Baseline consistency result

Active Wave, Workcell prompt, Starter Packet and frozen `config/missions.yaml` all point to the same B1-2 repository and mission identity. `CONTROL_TOWER_DRIFT = NONE`.

## 3. Read / Write Boundary

### READ

- Frozen Control Tower baseline
- Current B1-2 repository
- B1-2 official Mission source and directly related official metadata

### WRITE

- `MetaStudy999/codyssey-basic-b1-2-linux-troubleshooting` only

### DO NOT WRITE

- `MetaStudy999/codyssey-basic`
- any other Mission repository

## 4. G1 Source Inventory

| Source Candidate | Type | State | Location | Notes |
|---|---|---|---|---|
| Mission original | PDF | `VALID` | `b1-2-mission.pdf` | 9 pages. Local supplied PDF Git blob SHA exactly matches repository blob `2930ee6980094f739e5f7cf95108f55ea561714b`. Authoritative mission source. |
| Mission converted copy | Markdown | `CONFLICT` | `b1-2-mission.md` | Substantive content exists, but the prerequisites table is misaligned during PDF→Markdown conversion (for example AGENT_HOME/AGENT_PORT/UPLOAD/KEY/LOG/MEMORY rows). Use PDF on conflict. |
| Evaluation candidate | Markdown | `UNVERIFIED` | `b1-2-evaluation.md` | Non-empty 20-item rubric, but no direct official evaluation artifact/provenance was found that proves this Markdown is the official evaluation source. Use as provisional review criteria only. |
| Official evaluation PDF/TXT | PDF/TXT | `MISSING` | repository / provided File Library search | No official evaluation PDF/TXT found. |
| Official LMS mission metadata snapshot | TXT/JSON-like | `PARTIAL` | File Library: historical LMS payload | Confirms mission identity, `evlYn=Y`, `pjtEvlGuideFileSn=4`, and provided data file `agent-app-leak.zip`; the visible `evlGuideCn` is null and no official evaluation content is recoverable from the snapshot. |
| Provided runtime artifact metadata | ZIP metadata | `VALID` metadata / artifact `UNREADABLE` in current tools | LMS metadata: `agent-app-leak.zip`, x86 + arm64 | Download URL is present in the official metadata snapshot, but the actual ZIP is not present in this repository/File Library and could not be fetched by the current runtime. |
| `monitor.sh` | runtime tool | `MISSING` in this repo | repository tree | Mission requires using `monitor.sh`; B1-1 reuse is operationally recommended, not an explicit official prerequisite. |
| Reconstructed/decompiled Python candidates | Python | `HISTORICAL` / `EXCLUDED` | File Library | Not used. Mission explicitly prohibits binary decompilation/reverse engineering; these files are outside the official source path. |

### Source conflict record

`b1-2-mission.pdf` page 3-4 contains the authoritative prerequisites table. The Markdown conversion shifts values to the wrong row. Examples from the PDF:

- `AGENT_HOME`: required environment variable
- `AGENT_PORT`: `15034` fixed
- `AGENT_UPLOAD_DIR`: `$AGENT_HOME/upload_files` directory must exist
- `AGENT_KEY_PATH`: `$AGENT_HOME/api_keys` path must exist
- `AGENT_LOG_DIR`: log directory exists and writable
- `MEMORY_LIMIT`: integer `50~512` MB
- `CPU_MAX_OCCUPY`: integer `10~100` percent
- `MULTI_THREAD_ENABLE`: `true/false` (`1/0`, `yes/no` accepted)
- `$AGENT_HOME/api_keys/secret.key`: content `agent_api_key_test`
- network: bindable on `0.0.0.0:15034`

Resolution: Source-of-Truth priority applies: Mission PDF > Mission Markdown. The Markdown discrepancy does not change the official requirements.

### Source Mode / Confidence / Gaps

- Source Mode: `MISSION-LED`
- Source Confidence: `HIGH` for the Mission; `LOW/UNVERIFIED` for Evaluation provenance
- Source Gaps:
  - official Evaluation content is not directly accessible/verified
  - provided `agent-app-leak.zip` is not currently present in this repository and could not be fetched by the current tool runtime
  - `monitor.sh` is not present in this repository
- G1 decision: `PASS` — Mission is authoritative and complete enough to define the required work; Evaluation uncertainty is explicitly retained as a gap and is not promoted to official requirements.

## 5. Mission Contract

### Goal

Reproduce/observe and diagnose three Linux/OS failure modes using process/resource telemetry and application logs, then produce evidence-based GitHub Issue-style technical reports:

1. OOM / memory leak crash
2. CPU spike / watchdog termination
3. deadlock / alive-but-stalled process

Analysis order: `symptom -> observation -> evidence -> root-cause reasoning -> workaround -> Before/After verification`.

### Required Deliverables

- [ ] OOM report 1
- [ ] CPU report 1
- [ ] Deadlock report 1
- [ ] each report includes actual evidence and Before/After verification
- [ ] final submission can be a PDF or GitHub Repository link as stated by the Mission

### Required Report Structure

Each of the three reports must contain:

1. Description / observed symptom
2. Evidence & Logs / reproduction path and objective evidence
3. Root Cause Analysis / evidence-based technical explanation + related OS principle
4. Workaround & Verification / environment-variable adjustment + result
5. Before & After comparison

### Runtime prerequisites from the Mission PDF

- non-root execution
- `AGENT_HOME` set
- `AGENT_PORT=15034`
- `AGENT_UPLOAD_DIR=$AGENT_HOME/upload_files`, directory exists
- `AGENT_KEY_PATH=$AGENT_HOME/api_keys`, path exists
- writable `AGENT_LOG_DIR`
- `MEMORY_LIMIT` integer 50-512 MB
- `CPU_MAX_OCCUPY` integer 10-100 percent
- `MULTI_THREAD_ENABLE` true/false family
- `$AGENT_HOME/api_keys/secret.key` with one line `agent_api_key_test`
- bind `0.0.0.0:15034`

### Constraints

- Linux environment capable of running the provided Python-based binary
- local or isolated environment is recommended
- take care with firewall settings on shared networks
- binary decompilation/reverse engineering is prohibited
- standard Linux tooling such as `monitor.sh`, `ps`, `top`, `htop`, `pstree`, `kill` is allowed
- actual observed evidence must be separated from examples in the Mission PDF

### Explicit Non-scope / Backlog

- optional scheduling-algorithm inference (Round-Robin/FCFS/Priority) is `BONUS/BACKLOG`
- enterprise observability stack, container orchestration, permanent production hardening are not required for mission completion
- reverse engineering or rebuilding the supplied binary is prohibited and excluded

## 6. Requirement Traceability

| ID | Requirement | Source | Location | Confidence | Implementation | Test | Evidence | Status |
|---|---|---|---|---|---|---|---|---|
| REQ-B1-2-001 | Produce 3 issue-style reports: OOM, CPU, Deadlock | Mission PDF | p.1-2 | HIGH | `reports/` | structure validator/manual | 3 report files | TODO |
| REQ-B1-2-002 | Each report includes symptom, evidence, root cause, workaround, Before/After | Mission PDF | p.2 | HIGH | report template | validator | report sections | TODO |
| REQ-B1-2-003 | OOM: monitor memory usage rising over time | Mission PDF | p.2, p.4 | HIGH | runtime procedure | runtime | monitor values | NEEDS-RUNTIME |
| REQ-B1-2-004 | OOM: identify MemoryGuard termination log such as limit exceeded/self-terminated | Mission PDF | p.2, p.4 | HIGH | runtime procedure | runtime/log inspection | raw log excerpt | NEEDS-RUNTIME |
| REQ-B1-2-005 | OOM: `MEMORY_LIMIT` Before/After, minimum two runs | Mission PDF | p.2, p.4 | HIGH | runtime procedure | two runs | comparison table/logs | NEEDS-RUNTIME |
| REQ-B1-2-006 | CPU: capture process-specific CPU spike using top/ps/monitoring | Mission PDF | p.2, p.4 | HIGH | runtime procedure | runtime | CPU capture | NEEDS-RUNTIME |
| REQ-B1-2-007 | CPU: identify Watchdog/system protection termination evidence | Mission PDF | p.2, p.4 | HIGH | runtime procedure | runtime/log inspection | raw log excerpt | NEEDS-RUNTIME |
| REQ-B1-2-008 | CPU: `CPU_MAX_OCCUPY` Before/After comparison | Mission PDF | p.2, p.4 | HIGH | runtime procedure | two configurations | comparison | NEEDS-RUNTIME |
| REQ-B1-2-009 | Deadlock: show PID remains alive | Mission PDF | p.3-4 | HIGH | runtime procedure | `ps`/`pgrep` | PID evidence | NEEDS-RUNTIME |
| REQ-B1-2-010 | Deadlock: show CPU/MEM stagnation and thread state | Mission PDF | p.3-4 | HIGH | runtime procedure | `top -H` or `ps -L` | capture/log | NEEDS-RUNTIME |
| REQ-B1-2-011 | Deadlock: last WAITING/BLOCKED point + thread/lock wait reasoning | Mission PDF | p.3-4 | HIGH | report reasoning | log inspection | raw last log + reasoning | NEEDS-RUNTIME |
| REQ-B1-2-012 | Deadlock: `MULTI_THREAD_ENABLE` reproduce/avoid Before/After | Mission PDF | p.4 | HIGH | runtime procedure | two configurations | comparison | NEEDS-RUNTIME |
| REQ-B1-2-013 | Satisfy non-root/env/key/port runtime prerequisites | Mission PDF | p.3-4 | HIGH | runtime setup | preflight | command outputs | NEEDS-RUNTIME |
| REQ-B1-2-014 | Do not decompile/reverse engineer supplied binary | Mission PDF | p.6 | HIGH | policy | review | no prohibited artifacts committed | TODO |
| REQ-B1-2-015 | Use Linux standard observation tools | Mission PDF | p.6 | HIGH | runtime guide | manual | command outputs | NEEDS-RUNTIME |
| REQ-B1-2-016 | Explain memory leak, CPU overuse, deadlock and evidence-based incident communication | Mission PDF | p.3 | HIGH | learning notes | oral/self-check | learning checklist | TODO |

## 7. Evaluation Mapping

The repository contains `b1-2-evaluation.md`, but its official provenance is not verified. The criteria below are therefore **provisional review criteria**, not promoted to official requirements.

| Evaluation ID | Provisional Criterion | Related Requirement | Validation | Evidence | Status |
|---|---|---|---|---|---|
| EVA-01 | OOM growth then termination | 003-005 | runtime/log review | OOM evidence | UNVERIFIED |
| EVA-02 | OOM `MEMORY_LIMIT` Before/After | 005 | two runs | comparison | UNVERIFIED |
| EVA-03 | CPU threshold/termination pattern | 006-008 | runtime/log review | CPU evidence | UNVERIFIED |
| EVA-04 | CPU `CPU_MAX_OCCUPY` Before/After | 008 | two runs | comparison | UNVERIFIED |
| EVA-05 | Deadlock PID alive + CPU/MEM/log stall | 009-011 | runtime | deadlock evidence | UNVERIFIED |
| EVA-06 | Deadlock `MULTI_THREAD_ENABLE` Before/After | 012 | two configs | comparison | UNVERIFIED |
| EVA-07 | all 3 reports use issue structure | 001-002 | static/manual | report files | UNVERIFIED |
| EVA-08 | PID/timestamp/key log evidence present | 002-012 | validator/manual | raw evidence | UNVERIFIED |
| EVA-09~11 | explain monitor/CPU/deadlock diagnostic tool sequence | 003,006,009-011 | learning review | learning notes | UNVERIFIED |
| EVA-12~15 | explain OS mechanisms and circular wait reasoning | 003-012,016 | learning review | learning notes | UNVERIFIED |
| EVA-16~20 | propose monitoring/root fixes/triage/process improvements | 016 | learning review | learning notes/backlog | UNVERIFIED |

## 8. Repository Baseline

- Default Branch: `main`
- Baseline Commit: `b3f22eed3e14bda831f5afd2c745c8a8c53d906d`
- Work Branch: `mission/B1-2`
- Runtime / Language: Linux; supplied Python-based executable/binary
- Dependency Manager: none required by official Mission
- Existing Tests: `NO`

### Repository Inventory at G1

```text
.
├── README.md
├── b1-2-evaluation.md
├── b1-2-mission.md
└── b1-2-mission.pdf
```

### Existing Implementation

- already present: Mission PDF, converted Mission Markdown, evaluation candidate, minimal README
- partial: source documentation only
- missing: `MISSION-WORK-PACKET.md`, report set, runtime/evidence layout, automated report validation, learning notes, handoff files
- runtime artifact missing from repo: `agent-app-leak.zip`
- `monitor.sh` missing from repo

## 9. Mission-specific TOC

```text
B1-2
├── 00 Source & Contract
├── 01 Runtime prerequisites
├── 02 Observability baseline
├── 03 OOM / Memory Leak
│   ├── Reproduce
│   ├── Monitor evidence
│   ├── Termination log
│   ├── Root cause
│   └── MEMORY_LIMIT Before/After
├── 04 CPU Spike / Watchdog
│   ├── Reproduce
│   ├── Process CPU evidence
│   ├── Watchdog log
│   └── CPU_MAX_OCCUPY Before/After
├── 05 Deadlock
│   ├── PID alive
│   ├── CPU/MEM/thread stall
│   ├── last WAITING/BLOCKED log
│   ├── circular wait reasoning
│   └── MULTI_THREAD_ENABLE Before/After
├── 06 Reports
├── 07 Runtime Evidence
├── 08 Learning Notes
└── 09 Handoff
```

## 10. Scope / Engineering Plan

### Prompt Engineering

- ROLE: B1-2 Orchestrator/Integrator
- GOAL: finish the Mission with evidence-based three-case reports without inventing runtime results
- SCOPE: this B1-2 repository only
- OUTPUT CONTRACT: source traceability, minimal support artifacts, tests, actual evidence, learning notes, handoff
- STOP CONDITION: mandatory Mission requirements met + required runtime/evidence completed + BLOCKER 0/MAJOR 0

### Context Engineering

Only B1-2 Mission/Evaluation candidate, current repository state, related frozen governance and current Gate context are used.

### Harness Engineering

- Git boundary: `mission/B1-2`
- Test commands: static report/source validation to be added in G2/G3
- Secret boundary: no API keys/tokens; the Mission's fixed test string is not treated as a secret credential but should only be used as the required fixture
- Evidence boundary: Mission PDF examples are never recorded as actual evidence
- Runtime boundary: no runtime PASS without the supplied app and actual Linux observation

### Loop Engineering

- Self review: 1
- Independent review: 1 by default when useful/available
- Revalidation: only findings that affect BLOCKER/MAJOR or requirements

### Fusion Engineering

`Mission PDF -> verified evaluation if recovered -> tests -> runtime -> evidence`.

## 11. Agent Routing

- Orchestrator / Integrator: `ChatGPT`
- Primary Builder: `ChatGPT` for minimal repository preparation; external builder optional
- Independent Reviewer: optional/default one pass after G3
- Claude: `OFF / CONDITIONAL`
- Gemini: `OFF / CONDITIONAL` (PDF already readable and visually verified)
- Grok: `OFF / CONDITIONAL`
- Runtime Authority: `Human`

## 12. Dependency / Drift Check

- Upstream Dependency: `RECOMMENDED`, not official mandatory dependency
- Related Mission: `B1-1` for `monitor.sh` / observability environment knowledge
- Control Tower Drift: `NONE`
- Source Drift: `FOUND` only in the converted Markdown prerequisites table; resolved by PDF precedence
- Action: `CONTINUE`

The B1-2 Mission requires use of `monitor.sh` but does not explicitly state that B1-1 must be completed first. Therefore B1-1 is not promoted to a formal prerequisite. A compatible monitor tool must nevertheless exist at runtime.

## 13. Test Plan

| Test | Requirement | Command / Method | Expected | Actual | Status |
|---|---|---|---|---|---|
| Source consistency | G1 | compare PDF prerequisite table against MD | conflicts documented, PDF authoritative | documented | PASS |
| Report structure | 001-002 | static validator | 3 reports, required headings | pending G2 | TODO |
| No fabricated evidence | all runtime reqs | scan report placeholders/status | no example marked actual | pending G2 | TODO |
| OOM runtime | 003-005 | actual app + monitor/logs + two configs | growth/termination + comparison | not run | NEEDS-RUNTIME |
| CPU runtime | 006-008 | actual app + process tools + two configs | spike/watchdog + comparison | not run | NEEDS-RUNTIME |
| Deadlock runtime | 009-012 | actual app + PID/thread/log inspection + two configs | stall + wait evidence + comparison | not run | NEEDS-RUNTIME |
| Runtime prereq | 013 | preflight commands | all required conditions pass | not run | NEEDS-RUNTIME |
| Prohibited artifact check | 014 | repository inventory/review | no reverse-engineered binary/source committed | current baseline clean | TESTED |

## 14. Runtime Plan

| Runtime Check | AI possible now | Human needed | Evidence | Status |
|---|---|---|---|---|
| obtain official `agent-app-leak.zip` | no, current tool fetch unavailable | yes or user upload | file + `file` output | NEEDS-RUNTIME |
| choose x86/arm64 executable | no without ZIP | yes | `uname -m`, `file` | NEEDS-RUNTIME |
| configure prerequisites | partially documentable | yes | env/path/key/port outputs | NEEDS-RUNTIME |
| OOM two-run observation | no | yes | monitor/logs/timestamps | NEEDS-RUNTIME |
| CPU two-run observation | no | yes | top/ps/logs/timestamps | NEEDS-RUNTIME |
| Deadlock two-config observation | no | yes | PID/thread/log evidence | NEEDS-RUNTIME |

Human Runtime must be requested as a short sequence, not as a large unstructured command dump.

## 15. Evidence Plan

| Evidence | Requirement | Capture Method | Planned Location | Status |
|---|---|---|---|---|
| runtime preflight | 013 | terminal text/screenshot | `evidence/runtime/preflight/` | TODO |
| OOM monitor series | 003 | raw log/text | `evidence/oom/` | TODO |
| OOM termination log | 004 | raw log/text | `evidence/oom/` | TODO |
| OOM before/after | 005 | comparison table + raw runs | `evidence/oom/` | TODO |
| CPU process capture | 006 | top/ps/monitor output | `evidence/cpu/` | TODO |
| CPU watchdog log | 007 | raw log | `evidence/cpu/` | TODO |
| CPU before/after | 008 | comparison | `evidence/cpu/` | TODO |
| Deadlock PID/thread/stall | 009-011 | ps/top/log outputs | `evidence/deadlock/` | TODO |
| Deadlock before/after | 012 | comparison | `evidence/deadlock/` | TODO |
| final issue-style reports | 001-002 | Markdown/GitHub Issues | `reports/` | TODO |

## 16. Completion Gates

| Gate | Exit Condition | Status |
|---|---|---|
| G1 SOURCE | Source states, Mode, gaps and requirement provenance confirmed | `PASS` |
| G2 BUILD | minimal report/runtime/test/learning structure exists | TODO |
| G3 TEST | static checks pass; runtime checks accurately remain NEEDS-RUNTIME until run | TODO |
| G4 REVIEW | BLOCKER=0, MAJOR=0 for implemented/static scope | TODO |
| G5 RUNTIME | supplied app is actually executed for all required cases | NEEDS-RUNTIME |
| G6 EVIDENCE | all required actual evidence stored/linked | TODO |
| G7 LEARN | mission concepts and own-command explanations documented | TODO |
| G8 MERGE | final Mission PR merged after all required gates | TODO |

## 17. STOP Rule

Stop mission-completion work when all of the following are true:

- official mandatory Mission requirements are met
- Evaluation is satisfied if an official source is recovered, or the Evaluation gap remains explicitly documented
- BLOCKER=0
- MAJOR=0
- required tests pass
- actual runtime requirements are complete
- required evidence is complete
- G8 merge is complete

Do not delay completion for bonus scheduling inference, extra observability infrastructure, architecture rewrites or unrelated hardening.

## 18. Handoff Contract

At Mission completion create:

- `HANDOFF.md`
- `mission-result.yaml`

They must record Mission ID, frozen baseline SHA, final commit/PR, Source Mode/Confidence/Gaps, requirement result, G1-G8 state, tests, BLOCKER/MAJOR count, actual runtime, evidence locations, learning state and remaining backlog. The Control Tower remains unchanged by this Workcell.
