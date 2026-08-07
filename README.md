# codyssey-basic-b1-2-linux-troubleshooting

컴퓨터가 갑자기 느려지거나 멈췄을 때 원인 찾아 고치기

## Workcell status

- Control Tower frozen baseline: `0d1581b3e82366988f57e1d76da311c028b8e15e`
- Mission PR: `#1` — `MERGED`
- Mission merge commit: `6d0fabdaa220461ffe6981c69c7bd1ff5df92ad9`
- G1 SOURCE: `PASS`
- G2 BUILD: `PASS`
- G3 TEST: `PASS`
- G4 REVIEW: `PASS` — BLOCKER 0, MAJOR 0
- G5 RUNTIME: `PASS`
- G6 EVIDENCE: `PASS`
- G7 LEARN: `PASS` (learning artifact; personal mastery is separate)
- G8 MERGE: `PASS`
- Execution status: `PASS`
- Source Mode: `MISSION-LED`
- Mission PDF: `VALID`
- Evaluation Markdown: official provenance `UNVERIFIED`

실제 `agent-leak-app-x86`를 non-root Ubuntu 24.04 환경에서 실행해 OOM, CPU, Deadlock을 검증했다. Mission PDF의 예시 출력은 실제 Evidence로 사용하지 않았다.

## Verified results

| Case | Before / After | Actual result |
|---|---|---|
| OOM | `MEMORY_LIMIT 64 → 128` | RSS/Heap 증가 + MemoryGuard self-termination; 생존 `8초 → 18초` |
| CPU | `CPU_MAX_OCCUPY 10 → 90` | 낮은 값에서는 cooldown/보호 위반 없음, 높은 값에서는 부하 상승 후 `CPU Threshold Violated!` + exit 143 |
| Deadlock | `MULTI_THREAD_ENABLE true → false` | true: PID 생존 + RSS/로그 정체 + futex wait + mutual circular wait; false: 작업 진행 지속 |

CPU build note: 공식 제공 바이너리는 literal `[WATCHDOG]`/`SIGTERM` 앱 로그를 출력하지 않았다. 실제 보호 signature인 `CPU Threshold Violated!`와 process exit 143을 그대로 기록했으며, 존재하지 않은 로그를 만들지 않았다.

## Completion / Handoff

- [Mission Work Packet](./MISSION-WORK-PACKET.md)
- [Mission Handoff](./HANDOFF.md)
- [Machine-readable mission result](./mission-result.yaml)
- [Final Self Review](./docs/SELF-REVIEW.md)

대표 Repository는 이 Workcell에서 수정하지 않았다. B1-2 결과는 `HANDOFF.md`와 `mission-result.yaml`을 통해 Serial Integration 단계로 전달한다.

## Source documents

- [B1-2 미션 원본 PDF](./b1-2-mission.pdf) — 최상위 Source of Truth
- [B1-2 미션 Markdown](./b1-2-mission.md) — PDF 변환본; 사전 조건 표 변환 충돌은 PDF 우선
- [B1-2 평가문항 후보](./b1-2-evaluation.md) — official provenance 확인 전까지 provisional review criteria

## Reports

- [OOM report](./reports/oom.md) — `PASS`
- [CPU report](./reports/cpu.md) — `PASS`
- [Deadlock report](./reports/deadlock.md) — `PASS`

## Permanent Evidence

```text
evidence/
├── oom/
│   ├── before.log
│   └── after.log
├── cpu/
│   ├── before.log
│   ├── after.log
│   └── interval.log
└── deadlock/
    ├── enabled.log
    └── disabled.log
```

Key actual workflow runs:

- archive inspect: `31216239334`
- boot/preflight: `31216306554`
- core runtime: `31216511416`
- focused deadlock: `31216931577`
- focused CPU: `31217119811`
- CPU interval telemetry: `31217376403`
- final repository validation: `31218028653` — `PASS`

## Implementation / test harness

```text
scripts/
├── monitor.sh
├── validate_reports.py
├── run_runtime_cases.sh
├── run_deadlock_probe.sh
├── run_cpu_probe.sh
└── cpu_interval_sampler.py
```

`monitor.sh`는 단순 command-line pattern보다 tcp/15034의 실제 listener PID를 우선해 관제한다. CPU short spike는 `/proc/<pid>/stat` tick delta를 이용한 interval sampler로 보완했다.

## Final validation

최종 Mission head에서 GitHub Actions run `31218028653`가 성공했다.

```text
shell syntax
Python compile
3 report static contract
all permanent evidence files
no TODO / no NEEDS-RUNTIME in final reports
OOM MemoryGuard evidence markers
CPU threshold + interval evidence markers
Deadlock circular-wait evidence markers
G5/G6/G7 PASS markers
BLOCKER=0 / MAJOR=0
```

Result: `Final B1-2 repository validation PASS.`

## Learning

- [B1-2 Learning Guide](./docs/LEARNING-GUIDE.md)
- [Runtime Guide](./docs/RUNTIME-GUIDE.md)

저장소가 완성됐다고 학습 상태를 자동으로 `MASTERED`로 올리지 않는다. 학습자는 실제 Evidence를 기준으로 각 장애의 판단 과정을 자기 말로 설명하는 단계가 별도다.
