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
13. `top -H`/`ps -L`와 마지막 WAITING/BLOCKED 로그 분석
14. `MULTI_THREAD_ENABLE` 변경 후 회피 비교
15. 3개 Issue 리포트 완성
16. Evaluation Q&A 학습
17. Secret 검사
18. Runtime Evidence 확인 후 `✅ CLEAR`

## Reference Build 준비물

- `BEGINNER-GUIDE.md`
- `CHECKLIST.md`
- `monitor.sh`
- `environment/README.md`
- `environment/verify.sh`
- `docs/issue-template.md`
- `docs/oom-report.md`
- `docs/cpu-report.md`
- `docs/deadlock-report.md`
- `docs/requirements-mapping.md`
- `docs/evaluation-qa.md`
- `evidence/README.md`

## 상태

**Reference Build 진행 중 / B1-2 Runtime은 아직 시작하지 않음 / Mission 상태는 ⬜ NOT STARTED 유지**

B1-2 Runtime은 B1-1이 실제 `✅ CLEAR`된 뒤 시작합니다.
