# B1-2 Self Review — G4

- Review type: ChatGPT Self Review, one pass
- Branch: `mission/B1-2`
- Base: `main` @ `b3f22eed3e14bda831f5afd2c745c8a8c53d906d`
- Control Tower frozen baseline: `0d1581b3e82366988f57e1d76da311c028b8e15e`
- Review scope: Source contract, report templates, runtime/evidence guide, process monitor, static validator, README

## Result

- BLOCKER: `0`
- MAJOR: `0`
- Runtime status: `NEEDS-RUNTIME`
- Merge readiness: `NOT READY` until G5/G6/G7 are complete

## Checks

| Check | Result | Note |
|---|---|---|
| Control Tower write boundary | PASS | Only B1-2 repository was modified. |
| Mission PDF precedence | PASS | PDF/Markdown prerequisites conflict is documented; PDF is authoritative. |
| Evaluation provenance | PASS-with-gap | `b1-2-evaluation.md` remains `UNVERIFIED`; no missing evaluation criterion was promoted to official requirement. |
| Required 3 cases | PASS | OOM, CPU, Deadlock report templates exist. |
| Required report sections | PASS | Description, Evidence & Logs, Root Cause Analysis, Workaround & Verification, Before & After. |
| Evidence integrity | PASS | All reports are `NEEDS-RUNTIME`; no Mission example is represented as actual output. |
| OOM evidence plan | PASS | memory time series, termination log, `MEMORY_LIMIT` two-run comparison. |
| CPU evidence plan | PASS | target PID CPU, Watchdog log, `CPU_MAX_OCCUPY` comparison. |
| Deadlock evidence plan | PASS | PID alive, CPU/MEM/log stall, thread evidence, wait reasoning, `MULTI_THREAD_ENABLE` comparison. |
| Reverse engineering prohibition | PASS | No reconstructed/decompiled artifact was used or committed. |
| Secret/credential exposure | PASS | No real credential. Mission-required fixed test fixture is not copied into Evidence by default. |
| Binary handling | PASS | Official runtime ZIP/binaries are gitignored. |
| Static report validator | TESTED | Python compile + contract run passed in local mirror; it explicitly does not certify runtime. |
| Monitor syntax | TESTED | `bash -n` passed. |
| Monitor positive path | TESTED | Fixture process PID/CPU/MEM/RSS/thread/state collection passed. |
| Monitor missing process | TESTED | Missing process records `PROCESS_STATE:missing` and exits 1. |
| Actual supplied app | NEEDS-RUNTIME | `agent-app-leak.zip` is not accessible in current AI runtime. |

## Finding resolved during review

### SR-001 — `pgrep -f` could select an ancestor runner

- Severity before fix: `MAJOR` for evidence reliability
- Symptom found by fixture test: a noninteractive runner command line containing the pattern was selected instead of the fixture process.
- Fix: prefer `pgrep -x` and make the fallback `pgrep -f` exclude the monitor process and all ancestor PIDs.
- Verification after fix: fixture returned the correct `agent-leak-app` PID; missing-process case returned exit code 1.
- Final status: `RESOLVED`

## B1-1 monitor reuse decision

The B1-1 repository was inspected read-only. Its existing monitor is optimized for B1-1 health checks and records system-wide CPU/MEM plus an Agent PID. B1-2 requires process-specific CPU and memory evidence for the target PID. Therefore B1-2 keeps the same standard-Linux observation philosophy but adds a small mission-local process monitor rather than copying an insufficient health-check script unchanged.

## Remaining non-code dependency

The next mandatory gate is Human Runtime with the official `agent-app-leak.zip`. Until the supplied app is actually executed, G5/G6 and final report PASS are prohibited.
