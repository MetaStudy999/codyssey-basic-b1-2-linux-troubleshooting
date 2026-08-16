# B1-2 R01 — Reference Build

## 목적

B1-2의 공식 Mission/Evaluation을 기준으로 **OOM Crash, CPU Spike, Deadlock 3개 장애를 재현·분석·비교·리포팅하는 기준 경로**를 먼저 준비합니다.

Reference Build는 실제 장애를 재현했다고 주장하는 단계가 아닙니다. 실제 앱 실행, 장애 발생, PID/자원 수치, 핵심 로그, Before & After, 스크린샷/Evidence는 Phase C Runtime에서만 채웁니다.

## Source of Truth

1. `b1-2-mission.pdf`
2. `b1-2-mission.md`
3. `b1-2-evaluation.md`
4. `agent-app-leak.zip`

## 공식 최종 결과

- OOM Crash GitHub Issue 형식 리포트 1건
- CPU Latency/Spike GitHub Issue 형식 리포트 1건
- Deadlock GitHub Issue 형식 리포트 1건
- 각 리포트: 현상 → 증거 → 근본 원인 → 조치 및 Before/After 검증

## Reference Complete Path

1. Source/Evaluation 분석
2. 격리된 Linux Runtime 준비
3. `agent-app-leak.zip` 아키텍처 확인
4. 공통 환경변수/Secret을 로컬에만 구성
5. B1-2 진단용 `monitor.sh` 준비
6. OOM Baseline 실행·메모리 증가 관측
7. OOM 종료 로그 식별
8. `MEMORY_LIMIT` 변경 후 재실행·비교
9. CPU Baseline 실행·CPU 급상승 관측
10. Watchdog 종료 로그 식별
11. `CPU_MAX_OCCUPY` 변경 후 재실행·비교
12. Deadlock 재현: PID 유지 + CPU/MEM 정체 + 로그 중단 확인
13. `top -H`/`ps -L`와 WAITING/BLOCKED 로그 분석
14. `MULTI_THREAD_ENABLE` 변경 후 회피 비교
15. 3개 Issue 리포트 완성
16. Evaluation Q&A 학습
17. Secret 검사
18. Runtime Evidence 확인 후 `✅ CLEAR`

## Reference Build 준비 결과

- [x] Source/Evaluation 분석
- [x] `BEGINNER-GUIDE.md` Step 01~10
- [x] `CHECKLIST.md` Reference/Runtime 분리
- [x] 진단용 `monitor.sh`
- [x] `environment/README.md`
- [x] Reference/Runtime `environment/verify.sh`
- [x] Issue 공통 템플릿
- [x] OOM/CPU/Deadlock report skeleton 3종
- [x] Requirement/Evidence Mapping
- [x] Evaluation Q&A
- [x] Evidence Guide
- [x] 실제 Secret 값 미저장
- [x] 실제 Runtime 수치/로그를 만들어내지 않음

## Phase C Runtime에서만 완료할 것

- [ ] ZIP 내부/CPU 아키텍처 실제 확인
- [ ] 필수 환경변수/Secret 실제 설정
- [ ] OOM 실제 재현 + 최소 2회 Before/After
- [ ] CPU Spike 실제 재현 + Before/After
- [ ] Deadlock 실제 재현 + 회피 비교
- [ ] PID/타임스탬프/핵심 로그 확보
- [ ] 3개 report의 `TODO_RUNTIME`을 실제 Evidence로 교체
- [ ] `verify.sh --runtime` 0 FAIL
- [ ] Evaluation 자기 말 설명
- [ ] Secret 노출 없음 최종 확인
- [ ] `✅ B1-2 CLEAR`

## 자체 검토

- Mission의 3개 장애 유형과 3개 report를 1:1 연결
- Evaluation 20문항을 Checklist/Q&A에 반영
- OOM은 메모리 추세 + 보호 종료 + MEMORY_LIMIT 비교를 요구
- CPU는 특정 프로세스 CPU + Watchdog + CPU_MAX_OCCUPY 비교를 요구
- Deadlock은 PID 유지 + 자원/로그 정체 + thread/lock 추론 + MULTI_THREAD_ENABLE 비교를 요구
- 환경변수 변경을 임시 조치로, 코드 개선을 근본 해결로 분리
- 바이너리 디컴파일/리버스 엔지니어링 없음

## 현재 판정

**Reference Build: 기준본 준비 완료**

**Mission 상태: ⬜ NOT STARTED 유지 / Runtime 미시작 / CLEAR 아님**

다음 Phase A 작업은 B2-1 Reference Build입니다.
