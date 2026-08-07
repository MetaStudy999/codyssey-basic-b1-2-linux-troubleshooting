# codyssey-basic-b1-2-linux-troubleshooting

컴퓨터가 갑자기 느려지거나 멈췄을 때 원인 찾아 고치기

## Workcell status

- Control Tower frozen baseline: `0d1581b3e82366988f57e1d76da311c028b8e15e`
- Work branch: `mission/B1-2`
- G1 SOURCE: `PASS`
- Source Mode: `MISSION-LED`
- Mission PDF: `VALID`
- Evaluation Markdown: official provenance `UNVERIFIED`
- G2 BUILD: `PASS`
- G3 TEST: `PASS` for static/support scope
- G4 REVIEW: `PASS` — BLOCKER 0, MAJOR 0
- G5 RUNTIME: `NEEDS-RUNTIME`
- G6 EVIDENCE: `TODO`
- G7 LEARN: `TODO` (guide prepared)
- G8 MERGE: `TODO`

실제 `agent-app-leak` 실행 전에는 OOM/CPU/Deadlock 결과를 PASS로 표시하지 않는다.

## Source documents

- [B1-2 미션 원본 PDF](./b1-2-mission.pdf) — 최상위 Source of Truth
- [B1-2 미션 Markdown](./b1-2-mission.md) — PDF 변환본; 사전 조건 표 변환 충돌은 PDF 우선
- [B1-2 평가문항 후보](./b1-2-evaluation.md) — 내용은 존재하지만 공식 provenance 확인 전까지 provisional review criteria
- [Mission Work Packet](./MISSION-WORK-PACKET.md) — 현재 Workcell 실행 계약과 Requirement Traceability
- [Self Review](./docs/SELF-REVIEW.md) — G4 BLOCKER/MAJOR 검토 및 수정 기록

## Implementation / support artifacts

```text
.
├── AGENTS.md
├── MISSION-WORK-PACKET.md
├── docs/
│   ├── LEARNING-GUIDE.md
│   ├── RUNTIME-GUIDE.md
│   └── SELF-REVIEW.md
├── evidence/
│   └── README.md
├── reports/
│   ├── oom.md
│   ├── cpu.md
│   └── deadlock.md
└── scripts/
    ├── monitor.sh
    └── validate_reports.py
```

## Static validation

```bash
bash -n scripts/monitor.sh
python3 -m py_compile scripts/validate_reports.py
python3 scripts/validate_reports.py
```

지원 코드에 대해 shell syntax, Python compile, report contract, monitor positive/missing-process fixture를 검증했다. 정적/fixture 검증은 **실제 Linux + 공식 제공 앱 Runtime 증빙을 대신하지 않는다.**

## Runtime entry point

공식 제공 `agent-app-leak.zip`을 확보한 뒤 [Human Runtime Guide](./docs/RUNTIME-GUIDE.md)를 따른다.

최소 실제 증빙:

1. OOM — 메모리 증가 + MemoryGuard/종료 로그 + `MEMORY_LIMIT` 변경 전·후
2. CPU — 대상 PID CPU 급상승 + Watchdog/종료 로그 + `CPU_MAX_OCCUPY` 변경 전·후
3. Deadlock — PID 생존 + CPU/MEM/로그 정체 + thread/lock 대기 근거 + `MULTI_THREAD_ENABLE` 변경 전·후

## Reports

- [OOM report](./reports/oom.md)
- [CPU report](./reports/cpu.md)
- [Deadlock report](./reports/deadlock.md)

현재 3개 보고서는 `NEEDS-RUNTIME` 템플릿이다. 실제 로그/PID/타임스탬프/Before & After가 확보된 뒤에만 최종 리포트로 전환한다.

## Learning

- [B1-2 Learning Guide](./docs/LEARNING-GUIDE.md)

명령 복사보다 `왜 그 명령을 사용했고 어떤 출력으로 장애를 판정했는지`를 설명할 수 있어야 한다.
