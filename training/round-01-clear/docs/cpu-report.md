# [Bug] CPU Spike / Watchdog — TODO_RUNTIME

> 실제 CPU Runtime 결과로 교체합니다. 아래 `TODO_RUNTIME`은 실제 증거가 확보되기 전까지 제거하지 않습니다.

## 1. Description (현상 설명)

- 발생 시각: TODO_RUNTIME
- 실행 조건: TODO_RUNTIME
- 현상: 특정 프로세스 CPU 급상승과 Watchdog 보호 종료 여부를 실제로 기록

## 2. Evidence & Logs (증거 자료)

- PID: TODO_RUNTIME
- `monitor.sh` CPU 변화 수치: TODO_RUNTIME
- `top` 또는 `ps` 캡처/출력: TODO_RUNTIME
- Watchdog/SIGTERM 관련 실제 로그: TODO_RUNTIME

## 3. Root Cause Analysis (원인 분석)

- 시스템 전체가 아니라 특정 Agent 프로세스가 CPU를 과점유했다는 근거: TODO_RUNTIME
- 보호정책 임계치와 실제 종료의 연결: TODO_RUNTIME

## 4. Workaround & Verification (조치 및 검증)

| 항목 | Before | After |
|---|---|---|
| `CPU_MAX_OCCUPY` | TODO_RUNTIME | TODO_RUNTIME |
| 실행 조건 | TODO_RUNTIME | TODO_RUNTIME |
| 최대 CPU | TODO_RUNTIME | TODO_RUNTIME |
| 생존 시간 | TODO_RUNTIME | TODO_RUNTIME |
| 종료 여부 | TODO_RUNTIME | TODO_RUNTIME |

### 결론

TODO_RUNTIME

## 5. 근본 해결 제안

환경변수 조정은 임시 조치입니다. 소스 수정이 가능하다면 busy loop, 과도한 polling, 비효율적 알고리즘, 불필요한 재시도·스레드 수 등을 프로파일링하고 작업량 제한·sleep/backoff·알고리즘 개선 등을 검토합니다.
