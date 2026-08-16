# B1-2 Round 01 — CLEAR

## 현재 상태

- Runtime Mission: **⬜ NOT STARTED**
- Phase A Reference Build: **CORE READY**
- Runtime/Evidence: **미실행**
- CLEAR: **아님**

B1-2 Runtime은 B1-1 실제 `✅ CLEAR` 이후 시작합니다.

## 시작 순서

1. `REFERENCE-STATUS.md` — 자체감사 결과
2. `REFERENCE-BUILD.md` — 기준 경로
3. `environment/RUNTIME-SAFETY.md` — 장애 실험 전 안전 Gate
4. `docs/experiment-matrix.md` — Before/After 통제
5. `BEGINNER-GUIDE.md` — 실제 Runtime Step
6. `CHECKLIST.md` — Evaluation/CLEAR Gate

## 핵심 구조

```text
격리 환경
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
