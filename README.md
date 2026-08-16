# Codyssey Basic B1-2

## 구분

- 필수 미션 (REQUIRED)
- 훈련 체계: **Round 01 — CLEAR**
- Mission 상태: **⬜ NOT STARTED**
- 현재 운영 모드: **Phase A — REFERENCE BUILD**

B1-2의 Runtime은 B1-1이 실제 `✅ CLEAR`된 뒤 시작합니다. 현재는 공식 Mission/Evaluation을 기준으로 기준 구현·학습자료·검증계획을 선제 준비합니다.

## 공식 원본

- `b1-2-mission.pdf`
- `b1-2-mission.md`
- `b1-2-evaluation.md`
- `agent-app-leak.zip`

공식 원본은 수정하지 않습니다.

## 시작 위치

- `training/round-01-clear/REFERENCE-BUILD.md`
- `training/round-01-clear/BEGINNER-GUIDE.md`
- `training/round-01-clear/CHECKLIST.md`

## Reference 구현/문서

- `training/round-01-clear/monitor.sh` — PID 기반 CPU/MEM/RSS/THREADS 진단 기록
- `training/round-01-clear/environment/README.md` — 격리 Runtime/Secret 정책
- `training/round-01-clear/environment/verify.sh` — Reference/Runtime 검증
- `training/round-01-clear/docs/issue-template.md`
- `training/round-01-clear/docs/oom-report.md`
- `training/round-01-clear/docs/cpu-report.md`
- `training/round-01-clear/docs/deadlock-report.md`
- `training/round-01-clear/docs/requirements-mapping.md`
- `training/round-01-clear/docs/evaluation-qa.md`
- `training/round-01-clear/evidence/README.md`

## 핵심 원칙

1. 실제 장애를 재현하지 않은 상태에서 PID/수치/로그를 만들어내지 않습니다.
2. OOM, CPU, Deadlock을 각각 Before & After로 비교합니다.
3. 장애가 발생하면 재부팅보다 증거 수집을 먼저 합니다.
4. 환경변수 변경은 Workaround와 근본 해결을 구분합니다.
5. 실제 Secret 값은 GitHub·채팅·로그·Evidence에 저장하지 않습니다.
6. 바이너리 디컴파일/리버스 엔지니어링을 하지 않습니다.

## 상태

**Reference Build 기준본 준비 중 / Runtime 미시작 / CLEAR 아님**
