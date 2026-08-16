# Codyssey Basic B1-2

## 구분

- 필수 미션 (REQUIRED)
- 훈련 체계: **Round 01 — CLEAR**
- Runtime Mission 상태: **⬜ NOT STARTED**
- Phase A Reference 상태: **CORE READY**

B1-2 Runtime은 B1-1이 실제 `✅ CLEAR`된 뒤 시작합니다. 현재는 공식 Mission/Evaluation을 기준으로 장애 재현·진단·리포트·검증 경로를 선제 준비한 상태입니다.

## 공식 원본

- `b1-2-mission.pdf`
- `b1-2-mission.md`
- `b1-2-evaluation.md`
- `agent-app-leak.zip`

공식 원본은 수정하지 않습니다.

## 시작 위치

- `training/round-01-clear/REFERENCE-STATUS.md` — Phase A 자체감사 결과
- `training/round-01-clear/REFERENCE-BUILD.md` — 기준 설계
- `training/round-01-clear/BEGINNER-GUIDE.md` — Phase C 실제 따라하기
- `training/round-01-clear/CHECKLIST.md` — Mission/Evaluation/CLEAR Gate

## Reference 구현/문서

- `training/round-01-clear/monitor.sh` — PID 기반 CPU/MEM/RSS/THREADS/ELAPSED 시계열 진단
- `training/round-01-clear/environment/README.md` — 격리 Runtime/Secret/실험 정책
- `training/round-01-clear/environment/RUNTIME-SAFETY.md` — OOM/CPU/Deadlock 안전 Gate
- `training/round-01-clear/environment/verify.sh` — Reference/Runtime 검증
- `training/round-01-clear/docs/experiment-matrix.md` — Before/After 비교 통제
- `training/round-01-clear/docs/issue-template.md`
- `training/round-01-clear/docs/oom-report.md`
- `training/round-01-clear/docs/cpu-report.md`
- `training/round-01-clear/docs/deadlock-report.md`
- `training/round-01-clear/docs/requirements-mapping.md`
- `training/round-01-clear/docs/evaluation-qa.md`
- `training/round-01-clear/evidence/README.md`

## 핵심 원칙

1. 실제 장애를 재현하지 않은 상태에서 PID/수치/로그를 만들어내지 않습니다.
2. OOM, CPU, Deadlock은 같은 host/binary에서 Before & After로 비교합니다.
3. 핵심 환경변수 조정은 Workaround이며 실제 관측 변화로 효과를 확인합니다.
4. 장애가 발생하면 재부팅/광범위 kill보다 증거 수집을 먼저 합니다.
5. Deadlock은 PID 존재만으로 단정하지 않습니다.
6. 실제 Secret 값은 GitHub·채팅·로그·Evidence에 저장하지 않습니다.
7. 바이너리 디컴파일/리버스 엔지니어링을 하지 않습니다.

## 상태

**Phase A: CORE READY**

**Runtime: ⬜ NOT STARTED / CLEAR 아님**
