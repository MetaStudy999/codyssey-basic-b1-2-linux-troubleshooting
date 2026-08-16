# [Bug] Deadlock — TODO_RUNTIME

> 실제 Deadlock Runtime 결과로 교체합니다. 아래 `TODO_RUNTIME`은 실제 증거가 확보되기 전까지 제거하지 않습니다.

## 1. Description (현상 설명)

- 발생 시각: TODO_RUNTIME
- 실행 조건: TODO_RUNTIME
- 현상: PID는 유지되지만 CPU/MEM 변화와 로그 출력이 정체되는지 실제로 기록

## 2. Evidence & Logs (증거 자료)

- PID 존재 증거: TODO_RUNTIME
- `top -H` 또는 `ps -L` 스레드 상태: TODO_RUNTIME
- CPU/MEM 정체 구간: TODO_RUNTIME
- 마지막 WAITING/BLOCKED 관련 로그: TODO_RUNTIME
- 스레드 A → B / B → A 또는 순환 대기 추론 근거: TODO_RUNTIME

## 3. Root Cause Analysis (원인 분석)

- 상호 배제(Mutual Exclusion): TODO_RUNTIME
- 점유 대기(Hold and Wait): TODO_RUNTIME
- 비선점(No Preemption): TODO_RUNTIME
- 순환 대기(Circular Wait): TODO_RUNTIME
- 실제 로그와 위 조건의 연결: TODO_RUNTIME

## 4. Workaround & Verification (조치 및 검증)

| 항목 | Before | After |
|---|---|---|
| `MULTI_THREAD_ENABLE` | TODO_RUNTIME | TODO_RUNTIME |
| PID | TODO_RUNTIME | TODO_RUNTIME |
| 로그 진행 여부 | TODO_RUNTIME | TODO_RUNTIME |
| CPU/MEM 변화 | TODO_RUNTIME | TODO_RUNTIME |
| Deadlock 발생 여부 | TODO_RUNTIME | TODO_RUNTIME |

### 결론

TODO_RUNTIME

## 5. 근본 해결 제안

환경변수로 멀티스레드를 끄는 것은 회피책입니다. 소스 수정이 가능하다면 락 획득 순서를 일관되게 정하고, 중첩 락을 줄이며, timeout/try-lock, 더 작은 critical section, 상태 공유 최소화 등을 검토합니다.
