# B1-2 R01 — Requirement / Implementation / Verification / Evidence Mapping

실제 Runtime을 하지 않은 항목은 Evidence 완료로 표시하지 않습니다.

공통 실험 원칙은 `experiment-matrix.md`, 안전 기준은 `../environment/RUNTIME-SAFETY.md`를 사용합니다.

| ID | Requirement | Reference Implementation | Runtime Verification | Evidence |
|---|---|---|---|---|
| R01 | 일반 사용자 실행 + 필수 환경 | `BEGINNER-GUIDE.md`, `environment/README.md` | `id`, env 이름/경로, 디렉터리, 15034 확인 | 공통 사전조건 출력 |
| R02 | `MEMORY_LIMIT` 50~512 | OOM 절차 + experiment matrix | 범위 내 Before/After, 같은 host/binary | OOM 리포트 조건표 |
| R03 | `CPU_MAX_OCCUPY` 10~100 | CPU 절차 + experiment matrix | 범위 내 Before/After | CPU 리포트 조건표 |
| R04 | `MULTI_THREAD_ENABLE` true/false 계열 | Deadlock 절차 + experiment matrix | 재현/회피 비교 | Deadlock 리포트 조건표 |
| R05 | `secret.key` 존재 | Runtime local-only 입력 | `test -s`, `stat`; 내용 출력 금지 | 존재/권한만 |
| R06 | OOM 메모리 증가 패턴 | `monitor.sh` | `before-monitor.log`의 RSS/MEM 시간 추세 | `evidence/oom/before-monitor.log` |
| R07 | OOM 보호 종료 핵심 로그 | OOM report skeleton | MemoryGuard/Memory limit/SELF-TERMINATED 계열 **실제 출력** 식별 | `evidence/oom/before-app.log` 발췌 |
| R08 | OOM Before/After | OOM report + experiment matrix | `MEMORY_LIMIT` 변경 후 최소 2회 실행, 생존시간/수치 비교 | before/after app+monitor+PID + 비교표 |
| R09 | 특정 프로세스 CPU 급상승 | `monitor.sh`, `top`/`ps` | 대상 PID의 CPU peak/시간 패턴 | `evidence/cpu/before-monitor.log` + process snapshot |
| R10 | Watchdog 보호 종료 | CPU report | Watchdog/SIGTERM 계열 **실제 출력** 식별 | `evidence/cpu/before-app.log` 발췌 |
| R11 | CPU Before/After | CPU report + experiment matrix | `CPU_MAX_OCCUPY` 변경 후 종료 여부/생존시간/CPU 비교 | before/after app+monitor+PID + 비교표 |
| R12 | Deadlock에서 PID 유지 | monitor/ps | 동일 PID가 일정 관측 구간 살아 있음 | `before-pid.txt`, `before-process.txt` |
| R13 | CPU/MEM/로그 정체 + thread 증거 | monitor + `top -H`/`ps -L` | 여러 sample에서 진행 정체 + thread 상태 | `before-monitor.log`, `before-threads.txt`, app log |
| R14 | WAITING/BLOCKED 및 순환 대기 추론 | deadlock report | 마지막 실제 로그와 A→B/B→A 또는 동등 락 대기 관계 분석 | app log 발췌 + 논리적 분석 |
| R15 | Deadlock Before/After | deadlock report + experiment matrix | `MULTI_THREAD_ENABLE` 전후 진행/무응답 비교 | before/after evidence + 비교표 |
| R16 | Issue 형식 리포트 3건 | report skeleton 3개 + issue template | `TODO_RUNTIME` 제거 후 실제 데이터로 4개 필수 Section 완성 | `oom-report.md`, `cpu-report.md`, `deadlock-report.md` |
| R17 | PID/타임스탬프/핵심 로그 | monitor/report structure | 각 케이스 실제 PID·시간·로그 연결 | 3개 Evidence 디렉터리 |
| R18 | 평가 설명형 12문항 | `evaluation-qa.md` | 사용자가 실제 결과를 근거로 자기 말 설명 | 평가 확인 |
| R19 | 운영 대응/개선 5문항 | `evaluation-qa.md` | Workaround와 코드 수준 개선을 구분 | 평가 확인 |
| R20 | Secret 미노출 | `.gitignore`, Secret-safe guide/verify | tracked Secret-pattern + Evidence 파일명 검토 | 0 노출 |
| R21 | Reference/Runtime 자동 Gate | `environment/verify.sh` | Reference 0 FAIL, Runtime evidence 0 FAIL | `[PASS]/[FAIL]` 결과 |

## 케이스별 최소 Runtime 파일

`docs/experiment-matrix.md`의 이름을 canonical 기준으로 사용합니다. 최소한:

- OOM: before/after app log, monitor log, PID
- CPU: before/after app log, monitor log, PID + process/top/ps 증거
- Deadlock: before/after app log, monitor log, PID + before thread snapshot

## 해석 규칙

- `MEMORY_LIMIT`, `CPU_MAX_OCCUPY`, `MULTI_THREAD_ENABLE` 값을 바꾼 것만으로 성공 판정하지 않습니다.
- 실제 Before/After 관측 차이가 있어야 합니다.
- OOM/CPU 종료 원인은 앱의 실제 핵심 로그와 관제 시계열을 함께 연결합니다.
- Deadlock은 PID 존재만으로 단정하지 않고 자원/로그 정체와 스레드·락 대기 근거를 함께 제시합니다.
- 공식 예시 로그 문구가 실제 실행에서 정확히 동일하게 나오지 않으면 실제 앱 출력 표현을 사용합니다.

## Runtime 전용 Gate

Reference 파일이 있어도 다음은 Phase C 전에는 PASS가 아닙니다.

- 실제 제공 ZIP 내부/architecture
- 실제 3개 장애 재현
- 실제 PID/timestamp/resource values
- 실제 app 핵심 로그
- 실제 Before & After 변화
- 실제 3개 Issue 리포트
- `verify.sh --runtime` 0 FAIL
- 사용자 자기 말 Evaluation
