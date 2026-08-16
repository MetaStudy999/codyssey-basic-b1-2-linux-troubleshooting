# [Bug] OOM / Memory Leak — TODO_RUNTIME

> 실제 OOM Runtime 결과로 교체합니다. 아래 `TODO_RUNTIME`은 실제 증거가 확보되기 전까지 제거하지 않습니다.

## 1. Description (현상 설명)

- 발생 시각: TODO_RUNTIME
- 실행 조건: TODO_RUNTIME
- 현상: 메모리 사용량 증가 후 보호정책에 따른 프로세스 종료 여부를 실제로 기록

## 2. Evidence & Logs (증거 자료)

- PID: TODO_RUNTIME
- `monitor.sh` 메모리 증가 수치: TODO_RUNTIME
- 종료 직전/직후 핵심 로그: TODO_RUNTIME
- MemoryGuard/SELF-TERMINATED 관련 실제 로그: TODO_RUNTIME

## 3. Root Cause Analysis (원인 분석)

- 시간에 따른 RSS/MEM 증가 패턴: TODO_RUNTIME
- CPU와 메모리 변화의 관계: TODO_RUNTIME
- 애플리케이션 보호정책이 종료를 선택한 이유: TODO_RUNTIME

## 4. Workaround & Verification (조치 및 검증)

| 항목 | Before | After |
|---|---|---|
| `MEMORY_LIMIT` | TODO_RUNTIME | TODO_RUNTIME |
| 실행 횟수/조건 | TODO_RUNTIME | TODO_RUNTIME |
| 생존 시간 | TODO_RUNTIME | TODO_RUNTIME |
| 종료 여부 | TODO_RUNTIME | TODO_RUNTIME |
| 종료 시 RSS/MEM | TODO_RUNTIME | TODO_RUNTIME |

### 결론

TODO_RUNTIME

## 5. 근본 해결 제안

환경변수 상향은 임시 조치입니다. 실제 소스 수정이 가능하다면 불필요한 객체/버퍼의 생명주기, 참조 유지, 캐시/컬렉션 증가 지점을 찾아 해제·상한·백프레셔 등의 구조적 개선을 검토합니다.
