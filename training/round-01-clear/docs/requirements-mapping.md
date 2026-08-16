# B1-2 R01 — Requirement / Verification / Evidence Mapping

| ID | Requirement | Reference | Runtime Verification | Evidence |
|---|---|---|---|---|
| R01 | 일반 사용자 실행 + 필수 환경 | `environment/README.md`, Beginner Guide | env/path/owner 확인 | 사전조건 출력 |
| R02 | MEMORY_LIMIT 50~512 | OOM 절차 | Before/After 2회 이상 | 환경값+실행 로그 |
| R03 | CPU_MAX_OCCUPY 10~100 | CPU 절차 | Before/After | 환경값+CPU 로그 |
| R04 | MULTI_THREAD_ENABLE true/false | Deadlock 절차 | 재현/회피 비교 | thread/log evidence |
| R05 | secret.key 존재 | Runtime local-only 입력 | `test -s`, `stat`, 내용 출력 금지 | 존재/권한만 |
| R06 | OOM 메모리 증가 | `monitor.sh` | RSS/MEM 시간 추세 | `evidence/oom/monitor.log` |
| R07 | OOM 보호 종료 로그 | OOM report skeleton | MemoryGuard/SELF-TERMINATED 실제 로그 식별 | app log 발췌 |
| R08 | OOM Before/After | OOM report | MEMORY_LIMIT 변경 전후 생존시간 비교 | 비교표 |
| R09 | CPU 특정 프로세스 급상승 | `monitor.sh`, top/ps | CPU peak 확인 | `evidence/cpu/*` |
| R10 | Watchdog 종료 | CPU report | Watchdog/SIGTERM 실제 로그 식별 | app log 발췌 |
| R11 | CPU Before/After | CPU report | CPU_MAX_OCCUPY 변경 전후 | 비교표 |
| R12 | Deadlock PID 유지 | monitor/ps | `kill -0`, `ps` | PID 출력 |
| R13 | Deadlock CPU/MEM/로그 정체 | monitor + `top -H`/`ps -L` | 일정 구간 변화 정체 | thread/monitor log |
| R14 | WAITING/BLOCKED 및 순환 대기 추론 | deadlock report | 마지막 로그 + thread 관계 분석 | log 발췌/분석 |
| R15 | Deadlock Before/After | deadlock report | MULTI_THREAD_ENABLE 전후 | 비교표 |
| R16 | Issue 형식 3건 | report skeleton 3개 | TODO_RUNTIME 제거 + 실제 데이터 | 3개 리포트 |
| R17 | 평가 설명형 문항 | `evaluation-qa.md` | 사용자 자기말 설명 | 평가 확인 |
| R18 | Secret 미노출 | `.gitignore`, verify | tracked secret-pattern 확인 + Evidence 검토 | 0 노출 |

실제 Runtime을 하지 않은 항목은 Evidence 완료로 표시하지 않습니다.
