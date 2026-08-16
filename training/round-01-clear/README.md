# B1-2 Round 01 — CLEAR

## 현재 상태

- Runtime Mission: **⬜ NOT STARTED**
- Phase A Reference Build: **CORE READY**
- Runtime/Evidence: **미실행**
- CLEAR: **아님**

## 선행 학습

- **필수 선행 미션:** 없음
- **권장 선행 미션:** B1-1
- **있으면 좋은 선행 지식:** 프로세스/PID, TCP Port, 로그, CPU·Memory 지표, OOM·Deadlock 기초

B1-1을 먼저 수행하면 `monitor.sh`, 프로세스, 포트, 로그, 자원 관제 사고방식을 그대로 재사용할 수 있어 B1-2가 훨씬 수월합니다. 다만 B1-1의 `✅ CLEAR` 자체가 B1-2의 공식 필수 입력은 아니므로 **권장 선행**으로 관리합니다.

R01 운영 순서는 B1-1 다음에 B1-2를 수행하지만, 이는 Control Tower의 기본 실행 순서이며 필수 선행 관계와는 구분합니다.

## 시작 순서

1. `START-CHECK.md` — 필수/권장 선행과 현재 지식 상태 자가진단
2. `REFERENCE-STATUS.md` — 자체감사 결과
3. `REFERENCE-BUILD.md` — 기준 경로
4. `environment/RUNTIME-SAFETY.md` — 장애 실험 전 안전 Gate
5. `docs/experiment-matrix.md` — Before/After 통제
6. `BEGINNER-GUIDE.md` — 실제 Runtime Step
7. `CHECKLIST.md` — Evaluation/CLEAR Gate

`START-CHECK.md`는 합격/불합격 시험이 아닙니다. 부족한 개념만 먼저 보충하고 `BEGINNER-GUIDE.md`로 진입하기 위한 안내입니다.

## 핵심 구조

```text
시작 전 지식 체크
→ 격리 환경
→ 제공 app/환경변수/Secret(local only)
→ diagnostic monitor
→ OOM Before/After
→ CPU Before/After
→ Deadlock 재현/회피
→ Issue Report 3건
→ Runtime verify
→ Evaluation + Evidence
→ CLEAR
```

Reference 문서가 존재하더라도 실제 PID, resource 수치, app 로그, Before/After, Evidence가 없으면 Runtime PASS/CLEAR가 아닙니다.
