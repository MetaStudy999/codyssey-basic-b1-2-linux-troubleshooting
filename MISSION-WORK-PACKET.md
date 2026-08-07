# B1-2 Mission Work Packet — Linux Troubleshooting

> B1-2 Workcell execution contract. Control Tower is READ ONLY. All writes are limited to this Mission repository.

## 1. Identity

- Mission ID: `B1-2`
- Mission Title: 컴퓨터가 갑자기 느려지거나 멈췄을 때 원인 찾아 고치기
- Mission Repository: `MetaStudy999/codyssey-basic-b1-2-linux-troubleshooting`
- Workcell: `Chat 02 / B1-2`
- Started At: `2026-08-08 (+09:00)`
- Official classification: `required`

## 2. Control Tower Baseline

- Control Tower: `MetaStudy999/codyssey-basic`
- Current launcher main SHA checked: `f6192ad701bd1d2c317f908d210e7049f6b32310`
- Active Wave: `20260808-01`
- Frozen Baseline SHA: `0d1581b3e82366988f57e1d76da311c028b8e15e`
- Starter Packet: `docs/00-governance/work-packets/b1-2.md`
- Workcell Prompt: `docs/00-governance/workcell-prompts/b1-2.md`

Frozen baseline context read:

- `AGENTS.md`
- `docs/00-governance/multi-agent-mission-engineering.md`
- `docs/00-governance/source-discovery-fallback-protocol.md`
- `docs/00-governance/parallel-mission-execution.md`
- `config/missions.yaml`
- `docs/00-governance/work-packets/b1-2.md`
- `docs/02-domains/01-linux-os/b1-2-linux-troubleshooting.md`

Result: Active Wave, Workcell prompt, Starter Packet and frozen `config/missions.yaml` agree on B1-2 identity/repository/baseline. `CONTROL_TOWER_DRIFT = NONE`.

## 3. Read / Write Boundary

### READ

- frozen Control Tower baseline
- current B1-2 repository
- B1-2 official Mission source and directly related official metadata
- B1-1 repository read-only only when evaluating reuse of its monitor design

### WRITE

- `MetaStudy999/codyssey-basic-b1-2-linux-troubleshooting` only

### DO NOT WRITE

- `MetaStudy999/codyssey-basic`
- any other Mission repository

Boundary review result: `PASS`.

## 4. G1 Source Inventory

| Source Candidate | State | Location | Decision |
|---|---|---|---|
| Mission original PDF | `VALID` | `b1-2-mission.pdf` | Authoritative. 9 pages. Supplied local PDF Git blob SHA matches repository blob `2930ee6980094f739e5f7cf95108f55ea561714b`. |
| Mission Markdown | `CONFLICT` | `b1-2-mission.md` | Substantive copy, but prerequisite table is misaligned by PDF→MD conversion. PDF wins on conflict. |
| Evaluation Markdown | `UNVERIFIED` | `b1-2-evaluation.md` | Non-empty 20-item rubric; official provenance not proved. Provisional review criteria only. |
| Official Evaluation PDF/TXT | `MISSING` | repo/File Library discovery | Not recovered. |
| Official LMS mission metadata snapshot | `PARTIAL` | File Library | Confirms mission identity, evaluation enabled flag/slot and `agent-app-leak.zip`; visible evaluation content is null. |
| Official runtime artifact metadata | metadata `VALID`; actual ZIP inaccessible in AI runtime | LMS snapshot | `agent-app-leak.zip`, with x86 and arm64 executables. Human Runtime must supply/access actual ZIP. |
| B1-1 `monitor.sh` | `VALID` as read-only related implementation | B1-1 repo | Reviewed for reuse; system-wide B1-1 metrics are insufficient for B1-2 process-specific evidence, so a minimal B1-2 process monitor was added. |
| Reconstructed/decompiled Python candidates | `HISTORICAL / EXCLUDED` | File Library | Not used. Mission prohibits decompilation/reverse engineering. |

### Source conflict resolution

Mission PDF page 3-4 is authoritative for prerequisites:

- non-root execution
- `AGENT_HOME` required
- `AGENT_PORT=15034`
- `AGENT_UPLOAD_DIR=$AGENT_HOME/upload_files`, directory exists
- `AGENT_KEY_PATH=$AGENT_HOME/api_keys`, path exists
- writable `AGENT_LOG_DIR`
- `MEMORY_LIMIT`: integer 50-512 MB
- `CPU_MAX_OCCUPY`: integer 10-100 %
- `MULTI_THREAD_ENABLE`: true/false family (`1/0`, `yes/no` accepted)
- `$AGENT_HOME/api_keys/secret.key`: `agent_api_key_test`
- bindable on `0.0.0.0:15034`

The Markdown conversion shifts values into wrong rows. Source-of-Truth order resolves this: Mission PDF > Mission Markdown.

### G1 decision

- Source Mode: `MISSION-LED`
- Mission Confidence: `HIGH`
- Evaluation Confidence: `LOW / UNVERIFIED`
- Source gaps:
  - official Evaluation content/provenance is not directly verified
  - actual `agent-app-leak.zip` is not available to the current AI runtime
- G1 SOURCE: `PASS`

The Mission is complete enough to define mandatory work. Evaluation uncertainty remains an explicit gap and is not converted into invented requirements.

## 5. Mission Contract

### Goal

Use process/resource telemetry and application logs to reproduce/observe and diagnose three failure modes, then write evidence-based GitHub Issue-style reports:

1. OOM / memory leak crash
2. CPU spike / Watchdog termination
3. Deadlock / alive-but-stalled process

Required reasoning order:

`symptom -> observation -> objective evidence -> root-cause reasoning -> workaround -> Before/After verification`.

### Required deliverables

- [ ] final OOM report with actual evidence
- [ ] final CPU report with actual evidence
- [ ] final Deadlock report with actual evidence
- [ ] each report includes Description, Evidence & Logs, Root Cause Analysis, Workaround & Verification and Before & After
- [ ] final submission via PDF or GitHub Repository link as allowed by Mission

### Case evidence minimum

**OOM**

- `monitor.sh` memory rise over time
- termination-adjacent MemoryGuard/memory-limit/self-termination log
- `MEMORY_LIMIT` change with at least two runs

**CPU**

- target-process CPU spike via `top`/`ps`/monitoring
- Watchdog/termination log
- `CPU_MAX_OCCUPY` Before/After

**Deadlock**

- PID remains alive
- CPU/MEM progress stalls
- `top -H` or `ps -L` thread evidence
- last WAITING/BLOCKED or equivalent wait evidence
- thread/lock circular-wait reasoning
- `MULTI_THREAD_ENABLE` Before/After

### Constraints

- Linux capable of running the provided Python-based binary
- non-root execution
- local/isolated environment recommended
- firewall awareness because port `15034` binds on `0.0.0.0`
- no binary decompilation/reverse engineering
- standard Linux observation tools are allowed
- Mission example output is never actual evidence

### Explicit non-scope

- optional scheduling-algorithm inference is `BONUS/BACKLOG`
- enterprise observability stacks, Kubernetes, permanent production hardening are not required
- binary reconstruction/decompilation is prohibited

## 6. Requirement Traceability

| ID | Requirement | Implementation / Validation | Evidence | Status |
|---|---|---|---|---|
| REQ-B1-2-001 | 3 issue-style reports | `reports/oom.md`, `cpu.md`, `deadlock.md`; static validator | final filled reports | `IMPLEMENTED` |
| REQ-B1-2-002 | required report sections + Before/After | report templates + validator | final filled reports | `TESTED` structure / runtime pending |
| REQ-B1-2-003 | OOM memory rises over time | runtime guide + process monitor | `evidence/oom/` | `NEEDS-RUNTIME` |
| REQ-B1-2-004 | OOM termination/MemoryGuard log | runtime guide | raw app log | `NEEDS-RUNTIME` |
| REQ-B1-2-005 | `MEMORY_LIMIT` min 2-run comparison | OOM template/runbook | before/after logs/table | `NEEDS-RUNTIME` |
| REQ-B1-2-006 | target-process CPU spike | process monitor + `top/ps` guide | `evidence/cpu/` | `NEEDS-RUNTIME` |
| REQ-B1-2-007 | Watchdog/system-protection termination evidence | runtime guide | raw app log | `NEEDS-RUNTIME` |
| REQ-B1-2-008 | `CPU_MAX_OCCUPY` Before/After | CPU template/runbook | comparison | `NEEDS-RUNTIME` |
| REQ-B1-2-009 | Deadlock PID alive | runtime guide | `ps/pgrep` | `NEEDS-RUNTIME` |
| REQ-B1-2-010 | Deadlock CPU/MEM stall + thread state | runtime guide | `top -H`/`ps -L` | `NEEDS-RUNTIME` |
| REQ-B1-2-011 | last wait log + lock-wait reasoning | deadlock report template | app/thread evidence | `NEEDS-RUNTIME` |
| REQ-B1-2-012 | `MULTI_THREAD_ENABLE` Before/After | deadlock runbook | comparison | `NEEDS-RUNTIME` |
| REQ-B1-2-013 | runtime prerequisites | preflight procedure | preflight output | `NEEDS-RUNTIME` |
| REQ-B1-2-014 | no decompilation/reverse engineering | AGENTS, gitignore, self review | repo inventory | `PASS` |
| REQ-B1-2-015 | use standard Linux observation tools | monitor/runbook | actual commands | `IMPLEMENTED`; actual use pending |
| REQ-B1-2-016 | explain OOM/CPU/Deadlock and evidence communication | `docs/LEARNING-GUIDE.md` | learner explanation | `IMPLEMENTED`; G7 pending |

No runtime row is marked PASS without actual supplied-app execution.

## 7. Evaluation Mapping

`b1-2-evaluation.md` remains `UNVERIFIED` as an official source. It is used only to catch omissions already compatible with the Mission.

| Provisional group | Criteria | Mission alignment | Status |
|---|---|---|---|
| EVA-01~08 | OOM/CPU/Deadlock evidence + report structure + PID/timestamp traceability | direct/compatible | `UNVERIFIED`, covered by templates/runtime plan |
| EVA-09~11 | diagnostic tool sequence explanations | compatible learning expectation | `UNVERIFIED`, learning guide prepared |
| EVA-12~15 | OS mechanism/circular-wait explanations | compatible with Mission goals | `UNVERIFIED`, learning guide prepared |
| EVA-16~20 | operational/root-fix improvements | useful but provenance unverified | `UNVERIFIED`; do not block official Mission unless verified |

## 8. Repository Baseline / Current Inventory

- Default branch: `main`
- Baseline commit: `b3f22eed3e14bda831f5afd2c745c8a8c53d906d`
- Work branch: `mission/B1-2`
- Runtime: Linux + supplied executable
- Dependency manager: none required by official Mission

G1 baseline inventory:

```text
README.md
b1-2-evaluation.md
b1-2-mission.md
b1-2-mission.pdf
```

G2 additions:

```text
.gitignore
AGENTS.md
MISSION-WORK-PACKET.md
docs/
  LEARNING-GUIDE.md
  RUNTIME-GUIDE.md
  SELF-REVIEW.md
evidence/
  README.md
reports/
  oom.md
  cpu.md
  deadlock.md
scripts/
  monitor.sh
  validate_reports.py
```

## 9. Mission-specific TOC

```text
00 Source & Contract
01 Runtime prerequisites / preflight
02 Process observability baseline
03 OOM: reproduce -> memory evidence -> termination log -> RCA -> MEMORY_LIMIT Before/After
04 CPU: reproduce -> target PID CPU -> Watchdog log -> RCA -> CPU_MAX_OCCUPY Before/After
05 Deadlock: PID alive -> resource/thread stall -> last wait log -> circular wait -> MULTI_THREAD_ENABLE Before/After
06 Final reports
07 Actual runtime evidence
08 Learning explanation
09 Handoff / mission-result
```

## 10. Engineering Plan / Current Build

### Prompt Engineering

- ROLE: B1-2 Orchestrator/Integrator
- GOAL: finish the three evidence-based incident cases without fabricating runtime
- SCOPE: B1-2 repo only
- OUTPUT: traceable requirements, minimal monitoring/support artifacts, actual evidence, final reports, learning, handoff
- STOP: mandatory Mission + test + runtime + evidence + BLOCKER/MAJOR zero

### Context Engineering

Only B1-2 Source, frozen governance, current repository state and directly related B1-1 monitor implementation were used.

### Harness Engineering

- Git boundary: `mission/B1-2`
- Static commands:
  - `bash -n scripts/monitor.sh`
  - `python3 -m py_compile scripts/validate_reports.py`
  - `python3 scripts/validate_reports.py`
- Runtime commands: defined in `docs/RUNTIME-GUIDE.md`
- Secret boundary: no real credential/token; runtime binary is gitignored
- Evidence boundary: actual vs Mission example strictly separated

### B1-1 monitor reuse decision

B1-1's existing `monitor.sh` was inspected read-only. It is a B1-1 health-check script and records system-wide CPU/MEM. B1-2 needs target-process CPU/MEM/RSS/thread-state evidence. A minimal mission-local `scripts/monitor.sh` therefore reuses the standard Linux observation approach but collects process-level values required by B1-2.

### Loop Engineering

- Self review: `1 completed`
- Independent review: optional/conditional; not available as a separate agent in current tool runtime
- Revalidation: only BLOCKER/MAJOR findings

## 11. Agent Routing

- Orchestrator / Integrator: `ChatGPT`
- Primary Builder: `ChatGPT` for minimal support artifacts
- Independent Reviewer: `CONDITIONAL / unavailable as separate current runtime agent`
- Claude/Gemini/Grok: `OFF / CONDITIONAL`
- Runtime Authority: `Human`

No external agent is allowed to fabricate or substitute Human Runtime.

## 12. Dependency / Drift Check

- Upstream B1-1 dependency: `RECOMMENDED`, not an explicit official prerequisite
- Related Mission: `B1-1`
- Control Tower Drift: `NONE`
- Source Drift: PDF↔Markdown prerequisite table conversion conflict, `RESOLVED BY PDF PRECEDENCE`
- Action: `CONTINUE TO HUMAN RUNTIME`

B1-2 requires `monitor.sh` use but does not state that B1-1 must be formally completed first.

## 13. Test Plan / Actual Results

| Test | Scope | Actual Result | Status |
|---|---|---|---|
| PDF↔MD source comparison | G1 | prerequisite-table conflict found and recorded; PDF selected | `PASS` |
| `bash -n scripts/monitor.sh` | shell syntax | no syntax error | `PASS` |
| `python3 -m py_compile scripts/validate_reports.py` | Python syntax | compiled successfully in local mirror | `PASS` |
| report contract validator | 3 report structures | OOM/CPU/Deadlock all PASS in local contract execution | `PASS` |
| monitor positive fixture | process collection | exact `agent-leak-app` fixture PID, CPU/MEM/RSS/thread/state collected | `PASS` |
| monitor missing process | failure behavior | `PROCESS_STATE:missing`, exit code 1 | `PASS` |
| monitor false-positive regression | evidence reliability | initial ancestor `pgrep -f` false match found; fixed with exact-name preference + ancestor exclusion; retest PASS | `PASS` |
| prohibited artifact review | reverse engineering constraint | no decompiled/reconstructed runtime artifact committed/used | `PASS` |
| official supplied app | real Mission behavior | not available to current AI shell | `NEEDS-RUNTIME` |

Environment note: direct `git clone` from the private analysis shell could not resolve `github.com`; exact branch file contents were read/written through the GitHub connector and the executable script/contract logic was tested in a local mirror. This does not affect or substitute the future supplied-app runtime test.

## 14. Runtime Plan

| Runtime Check | Human Needed | Evidence | Status |
|---|---|---|---|
| obtain official `agent-app-leak.zip` | yes | official file + `uname -m`/`file` | `NEEDS-RUNTIME` |
| non-root/env/path/key/port preflight | yes | `evidence/runtime/preflight/` | `NEEDS-RUNTIME` |
| OOM run 1/run 2 | yes | `evidence/oom/` | `NEEDS-RUNTIME` |
| CPU run 1/run 2 | yes | `evidence/cpu/` | `NEEDS-RUNTIME` |
| Deadlock true/false comparison | yes | `evidence/deadlock/` | `NEEDS-RUNTIME` |

Human Runtime must be requested in small ordered steps: goal -> reason -> command -> expected result -> pass criterion -> recovery.

## 15. Evidence Plan

| Evidence | Requirement | Location | Status |
|---|---|---|---|
| preflight | REQ-013 | `evidence/runtime/preflight/` | `TODO` |
| OOM memory series + termination logs + before/after | REQ-003~005 | `evidence/oom/` | `TODO` |
| CPU PID spike + Watchdog + before/after | REQ-006~008 | `evidence/cpu/` | `TODO` |
| Deadlock PID/thread/log wait + before/after | REQ-009~012 | `evidence/deadlock/` | `TODO` |
| final reports | REQ-001~002 | `reports/` | templates `IMPLEMENTED`, final evidence pending |
| learner explanation | REQ-016 | `docs/LEARNING-GUIDE.md` | preparation `IMPLEMENTED`, G7 pending |

## 16. G4 Self Review

Self Review record: `docs/SELF-REVIEW.md`.

Result:

- BLOCKER: `0`
- MAJOR: `0`
- one evidence-reliability defect was found during fixture testing (`pgrep -f` ancestor false match), fixed and retested
- no false Runtime PASS
- no secret exposure
- no Control Tower write
- no reverse-engineered artifact use

G4 status for implemented/static scope: `PASS`.

## 17. Completion Gates

| Gate | Exit Condition | Status |
|---|---|---|
| G1 SOURCE | Source state/mode/gaps/provenance fixed | `PASS` |
| G2 BUILD | minimal required support artifacts exist | `PASS` |
| G3 TEST | automated/static support tests pass; no fake runtime | `PASS` |
| G4 REVIEW | BLOCKER=0, MAJOR=0 for current scope | `PASS` |
| G5 RUNTIME | actual official app executed for all mandatory cases | `NEEDS-RUNTIME` |
| G6 EVIDENCE | actual required evidence complete | `TODO` |
| G7 LEARN | evidence-linked beginner explanation complete | `TODO` (guide prepared) |
| G8 MERGE | Mission PR merged after all gates | `TODO` |

Current stop point: `G5 HUMAN RUNTIME`.

## 18. STOP Rule

Mission completion occurs only when all are true:

- official mandatory requirements satisfied
- official Evaluation satisfied if recovered, otherwise gap retained explicitly
- BLOCKER=0
- MAJOR=0
- required tests pass
- actual Human Runtime complete
- actual Evidence complete
- G7 learning complete
- G8 merge complete

Do not delay completion for bonus scheduling inference, unrelated hardening, extra frameworks or architecture rewrites.

## 19. Handoff Contract

After G8 create:

- `HANDOFF.md`
- `mission-result.yaml`

They must record Mission ID, frozen baseline SHA, final commit/PR, Source Mode/Confidence/Gaps, requirement status, G1-G8 status, tests, BLOCKER/MAJOR counts, actual runtime, evidence locations, learning status and remaining backlog.

Do not create a completion handoff or report Mission COMPLETE before G5-G8 are actually done.
