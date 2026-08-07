# B1-2 Learning Guide

> G7 학습 자료다. 실제 Runtime Evidence와 연결되어 있다. 미션 산출물의 `G7 LEARN` 완료와 학습자의 개인 숙련도(`MASTERED`)는 별개다.

## 1. 이 미션에서 설명할 수 있어야 하는 것

### Memory Leak / OOM

실제 근거: `evidence/oom/before.log`, `evidence/oom/after.log`, `reports/oom.md`

- Before PID `2080`의 RSS는 `18,236 → 43,840 → 69,444 KiB`로 증가했다.
- `MEMORY_LIMIT=64`에서 Heap `75MB` 시 `Memory limit exceeded (75MB >= 64MB)`와 `Self-terminating process 2080`이 기록됐다.
- `MEMORY_LIMIT=128`에서는 Heap이 `150MB`까지 증가한 뒤 같은 MemoryGuard 정책으로 종료됐다.
- 생존 시간은 `8초 → 18초`로 늘었다.
- 따라서 이번 종료는 Linux kernel OOM Killer라고 단정하지 않고 **애플리케이션 MemoryGuard의 보호 종료**로 판정한다.
- LIMIT 상향은 생존 시간을 늘린 workaround일 뿐, 지속적인 메모리 증가의 근본 원인을 없애지 않는다.

### CPU Spike

실제 근거: `evidence/cpu/before.log`, `evidence/cpu/after.log`, `evidence/cpu/interval.log`, `reports/cpu.md`

- `CPU_MAX_OCCUPY=10`에서는 CpuWorker가 `5~10%` 범위에서 peak/cooldown을 반복했고 45초 동안 보호 위반이 없었다.
- `CPU_MAX_OCCUPY=90`에서는 CpuWorker telemetry가 `5 → 9.76 → 14.46 → ... → 55.58%`까지 상승한 뒤 `CPU Threshold Violated!`를 기록하고 프로세스가 종료됐다.
- `/proc/<pid>/stat` interval 관제에서도 target listener/worker PID `2378`의 짧은 구간 CPU가 `3.91 → 7.82 → 11.73 → 15.64 → 19.54%`로 상승하는 구간이 관측됐다.
- 이 공급 build에는 literal `[WATCHDOG]`/`SIGTERM` 앱 로그가 없었다. 따라서 존재하지 않는 문자열을 만들지 않고, 실제 보호 근거인 `CPU Threshold Violated!` + exit `143`을 사용한다.
- `ps %CPU`는 lifetime average라 짧은 spike와 정확히 일치하지 않을 수 있으므로, 어떤 CPU metric을 썼는지 함께 설명해야 한다.

### Deadlock

실제 근거: `evidence/deadlock/enabled.log`, `evidence/deadlock/disabled.log`, `reports/deadlock.md`

- `MULTI_THREAD_ENABLE=true`에서 PID `2201`은 살아 있고 tcp/15034도 LISTEN했지만, RSS `18,184 KiB`가 장시간 고정되고 CPU가 `0.0~0.1%`로 떨어졌다.
- Thread-1은 `Shared_Memory_A`를 보유한 채 `Socket_Pool_B`를 기다렸고, Thread-2는 `Socket_Pool_B`를 보유한 채 `Shared_Memory_A`를 기다렸다.
- 두 로그 모두 `WAITING ... (Status: BLOCKED)`를 남겼고 OS thread WCHAN에서도 `futex_` wait가 확인됐다.
- `MULTI_THREAD_ENABLE=false`에서는 동일한 mutual WAITING/BLOCKED sequence가 나타나지 않았고, RSS와 MemoryWorker/CpuWorker 로그가 계속 진행했다.
- 이 증거를 Deadlock 4대 조건과 연결한다.
  - Mutual Exclusion — 각 lock은 동시에 한 worker만 보유
  - Hold and Wait — 이미 하나를 보유한 채 다른 lock 대기
  - No Preemption — 상대 lock을 강제로 회수하지 않음
  - Circular Wait — Thread-1 ↔ Thread-2의 자원 대기 고리

## 2. 명령어를 '왜' 썼는지 설명하기

| 명령/도구 | 무엇을 확인하는가 | 실제 실행에서 확인한 것 |
|---|---|---|
| `ss -lntp` | tcp/15034를 실제 소유한 PID | PyInstaller launcher가 아니라 실제 listener PID 식별 |
| `ps -p PID -o ...` | 특정 PID CPU/MEM/RSS/상태 | OOM의 RSS 증가, Deadlock의 PID 생존/정체 |
| `top -p PID` | 특정 프로세스의 시간 변화 관찰 | process 중심 관제 보조 수단 |
| `ps -L -p PID` | 프로세스 내부 스레드 상태 | Deadlock worker LWP와 wait state 확인 |
| `top -H -p PID` | 스레드별 CPU/상태 변화 | Deadlock thread 관찰 보조 |
| `/proc/<pid>/stat` interval | PID별 짧은 구간 CPU tick 변화 | CPU worker/listener의 interval CPU 상승 구간 확인 |
| `tail` | 앱 로그의 마지막 진행 지점 | Deadlock WAITING/BLOCKED 직전·직후 문맥 확인 |
| `grep` | MemoryGuard/CPU Threshold/WAITING 후보 로그 검색 | 후보 위치를 찾고 원문 문맥과 대조 |
| `monitor.sh` | 동일 형식의 PID/RSS/CPU/thread/port 시계열 | OOM RSS 증가와 Deadlock RSS 정체를 누적 |

중요: `grep` 결과 하나만 보고 원인을 확정하지 않는다. 원문 로그 문맥 + PID별 프로세스 지표 + 설정 전·후를 함께 본다.

## 3. 증거 기반 트러블슈팅 사고 순서

```text
현상
  ↓
PID와 시간 고정
  ↓
프로세스/스레드/자원 관측
  ↓
애플리케이션 로그와 시간축 맞춤
  ↓
가설
  ↓
환경변수 한 개만 변경
  ↓
동일 방식으로 재실행
  ↓
Before / After
  ↓
Root Cause와 Workaround 구분
```

핵심은 장애 이름을 먼저 정하고 증거를 끼워 맞추는 것이 아니라 **관측값에서 결론으로 이동하는 것**이다.

## 4. 실제 결과 1문장 요약 연습

- OOM: `PID 2080의 RSS가 18,236→69,444 KiB로 증가하고 MemoryGuard가 75MB>=64MB를 기록하며 self-terminate했으며, LIMIT 128에서는 생존 시간이 8→18초로 늘어 애플리케이션 메모리 보호 종료로 판정했다.`
- CPU: `CPU_MAX_OCCUPY=90에서 target process의 interval CPU 상승과 CpuWorker 55.58~56.92% 상승이 함께 관측되고 CPU Threshold Violated 로그 뒤 프로세스가 종료되어 CPU 보호 정책 동작으로 판정했다.`
- Deadlock: `PID 2201과 포트는 살아 있었지만 RSS 18,184 KiB가 고정되고 두 worker가 서로 상대 lock을 WAITING/BLOCKED하며 futex 대기에 들어가 순환 대기형 Deadlock으로 판정했다.`

## 5. 임시 조치와 근본 해결 구분

환경변수 조정은 Mission이 요구하는 **Workaround & Verification**이다. 실제 서비스의 근본 해결은 코드/설계 수준에서 별도다.

- OOM: `MEMORY_LIMIT` 상향 ≠ 누수 원인 제거. 정상 소스에서 객체/버퍼 수명과 해제를 수정해야 한다.
- CPU: `CPU_MAX_OCCUPY` 조정 ≠ 과도한 연산 제거. loop/backoff/rate limit/concurrency를 코드 수준에서 개선한다.
- Deadlock: `MULTI_THREAD_ENABLE=false` ≠ lock 설계 수정. lock 획득 순서 통일, 복수 lock 최소화, timeout/try-lock 등이 근본 방향이다.

위 코드 수준 해결책은 일반적인 개선 방향이며, 이 미션에서는 금지된 바이너리 역공학으로 특정 소스 라인을 추정하지 않았다.

## 6. 평가 대비 설명 포인트

### OOM과 Deadlock이 동시에 의심되면

1. 먼저 시스템/프로세스가 아직 살아 있는지, 메모리 압박이 시스템 전체 안정성을 위협하는지 확인한다.
2. OOM 위험이 즉시 시스템 자원 고갈로 이어진다면 우선 완화한다.
3. 그 뒤 PID/thread/log progression을 고정해 deadlock 여부를 분석한다.
4. 복구 전에 evidence를 남겨 재현 가능한 원인 분석을 보존한다.

### `monitor.sh`를 운영용으로 개선한다면

- RSS 절대값뿐 아니라 증가율(rate)과 연속 증가 횟수 추가
- PID 재시작 감지
- threshold + 지속시간 기반 alert
- thread count/blocked state 보조 수집
- 로그 rotation과 evidence correlation ID 추가

### 코드 수정 권한이 있다면

- OOM: allocation lifetime/해제 경로 수정
- CPU: busy loop/과도한 polling 억제, backoff/rate limit
- Deadlock: lock acquisition order 통일, critical section 축소, timeout/try-lock

## 7. G7 완료 기준

- [x] 실제 사용한 명령과 옵션을 설명하는 자료가 있다.
- [x] OOM/CPU/Deadlock 판정 근거가 실제 Evidence 링크와 연결되어 있다.
- [x] Before/After 값과 변화 이유가 정리되어 있다.
- [x] Workaround와 Root Cause Fix가 구분되어 있다.
- [x] 세 Case를 1분 이내에 설명할 수 있는 1문장 요약이 준비되어 있다.

Mission artifact status: `G7 LEARN = PASS`.

Personal learning status: `NOT-STUDIED` 유지. 저장소가 완성됐다는 사실만으로 학습자가 `MASTERED`했다고 표시하지 않는다.
