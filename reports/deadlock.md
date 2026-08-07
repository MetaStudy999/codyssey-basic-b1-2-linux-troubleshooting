# [Bug] Deadlock — 두 Worker가 서로의 Lock을 기다리며 진행이 정지

> Runtime status: `PASS`
>
> 실제 Linux 실행 근거: GitHub Actions `31216931577`, artifact `b1-2-deadlock-probe` (`9008913750`). Mission PDF 예시는 실제 증빙으로 사용하지 않았다.

## 1. Description (현상 설명)

- 재현 일시: `2026-08-07 20:41:24~20:43:25 UTC`
- 실행 환경/아키텍처: GitHub-hosted Ubuntu 24.04 / x86_64 / non-root `runner` (uid 1001)
- Before PID: `2201`
- Before `MULTI_THREAD_ENABLE=true`
- After PID: `3605`
- After `MULTI_THREAD_ENABLE=false`
- 관측된 무응답 현상: Before에서는 두 Worker가 서로 상대 자원을 기다리는 `WAITING ... BLOCKED` 로그를 남긴 뒤 앱 작업 로그와 RSS 진행이 멈췄지만 PID와 tcp/15034 listener는 약 59초 관찰 종료까지 살아 있었다.
- 마지막 lock 진행 로그 시각: `2026-08-07 20:41:33,934 UTC`

## 2. Evidence & Logs (증거 자료)

Evidence path: `evidence/deadlock/enabled.log`, `evidence/deadlock/disabled.log`

### 2.1 PID 생존 증거

Before 관찰 말미에도 PID `2201`이 tcp/15034를 LISTEN하고 있었다.

```text
[2026-08-07 20:42:18+0000] PID:2201 CPU:0.0% MEM:0.1% RSS_KB:18184 THREADS:3 ... PORT:15034/listen
[2026-08-07 20:42:23+0000] PID:2201 CPU:0.0% MEM:0.1% RSS_KB:18184 THREADS:3 ... PORT:15034/listen
```

### 2.2 CPU/MEM 변화 정체 및 스레드 상태

Before에서 장시간 다음 상태가 반복됐다.

- RSS: `18,184 KiB` 고정
- CPU: `0.0~0.1%`
- THREADS: `3`
- `ps -L`/WCHAN 관찰: 두 Worker LWP를 포함해 thread들이 `futex_` wait 상태

반면 After (`MULTI_THREAD_ENABLE=false`)에서는 같은 관찰 시간 동안 RSS가 계속 증가했다.

```text
20:43:04 RSS_KB:325544
20:43:09 RSS_KB:376752
20:43:18 RSS_KB:453564
20:43:24 RSS_KB:504772
```

### 2.3 마지막 애플리케이션 로그

```text
2026-08-07 20:41:31,922 [INFO] [Worker-Thread-1] Process Started. Attempting to lock [Shared_Memory_A]...
2026-08-07 20:41:31,923 [INFO] [AgentWorker][Worker-Thread-2] Process Started. Attempting to lock [Socket_Pool_B]...
2026-08-07 20:41:31,923 [INFO] [AgentWorker][Worker-Thread-1] LOCK ACQUIRED: [Shared_Memory_A]. (Holding...)
2026-08-07 20:41:31,923 [INFO] [AgentWorker][Worker-Thread-2] LOCK ACQUIRED: [Socket_Pool_B]. (Holding...)
2026-08-07 20:41:33,934 [INFO] [AgentWorker][Worker-Thread-1] Need resource [Socket_Pool_B] to finish job.
2026-08-07 20:41:33,934 [INFO] [AgentWorker][Worker-Thread-2] Need resource [Shared_Memory_A] to write logs.
2026-08-07 20:41:33,934 [INFO] [AgentWorker][Worker-Thread-1] WAITING for [Socket_Pool_B]... (Status: BLOCKED)
2026-08-07 20:41:33,934 [INFO] [AgentWorker][Worker-Thread-2] WAITING for [Shared_Memory_A]... (Status: BLOCKED)
```

### 2.4 스레드/락 대기 추적

- Worker-Thread-1: `Shared_Memory_A`를 보유하고 `Socket_Pool_B`를 기다림
- Worker-Thread-2: `Socket_Pool_B`를 보유하고 `Shared_Memory_A`를 기다림
- 의존 방향: `Thread-1 → Socket_Pool_B(held by Thread-2)` + `Thread-2 → Shared_Memory_A(held by Thread-1)`
- 결과: 명백한 순환 대기(circular wait)

## 3. Root Cause Analysis (원인 분석)

### 증거에서 확인된 사실

- PID 생존: 약 59초 관찰 종료까지 PID `2201` 및 tcp/15034 listener 유지
- CPU/MEM 정체: RSS `18,184 KiB` 고정, CPU `0.0~0.1%`
- 로그 정지: 두 Worker의 `WAITING ... BLOCKED` 이후 해당 작업 진행이 멈춤
- 스레드 대기: OS WCHAN에서 `futex_` wait 관측
- 자원 관계: 각 Thread가 하나의 Lock을 보유한 채 상대 Thread가 보유한 Lock을 기다림

### 기술적 원인 판단

두 Worker가 자원을 반대 순서로 획득하면서 서로가 보유한 Lock을 무기한 기다렸다. 프로세스 자체는 종료되지 않고 socket도 살아 있었지만, 실제 업무 스레드는 futex 대기에 들어가 진행하지 못했다. 로그의 자원 보유/대기 관계와 OS thread wait 상태가 동일한 결론을 지지한다.

### 관련 OS 원리

- 상호 배제(Mutual Exclusion): 각 Lock은 한 시점에 한 Thread만 보유할 수 있다.
- 점유 대기(Hold and Wait): Thread-1과 Thread-2가 이미 하나의 자원을 보유한 채 다른 자원을 기다린다.
- 비선점(No Preemption): 다른 Thread가 보유한 Lock을 강제로 빼앗지 않는다.
- 순환 대기(Circular Wait): `Thread-1 → Thread-2의 자원 → Thread-1의 자원` 순환이 형성됐다.

실제 관측에서는 네 조건이 함께 나타났으며, 특히 상호 배제와 순환 대기가 로그로 직접 확인된다.

## 4. Workaround & Verification (조치 및 검증)

### Before — 멀티스레드 조건

- `MULTI_THREAD_ENABLE=true`
- PID: `2201`
- 관찰 종료: PID/listener 생존
- CPU/MEM/로그: RSS `18,184 KiB` 고정, CPU 거의 0%, WAITING/BLOCKED 뒤 lock 작업 로그 정지
- Evidence: `evidence/deadlock/enabled.log`

### After — 설정 변경 조건

- `MULTI_THREAD_ENABLE=false`
- PID: `3605`
- 관찰 종료: PID/listener 생존
- CPU/MEM/로그: MemoryWorker/CpuWorker 진행 지속, RSS `325,544 → 504,772 KiB` 등 변화 지속
- mutual WAITING/BLOCKED lock sequence: 관측되지 않음
- Evidence: `evidence/deadlock/disabled.log`

### Before & After

| 항목 | Before | After |
|---|---|---|
| MULTI_THREAD_ENABLE | true | false |
| PID 생존 | 예 | 예 |
| CPU/MEM 진행 여부 | RSS 정체, CPU 거의 0 | RSS/작업 진행 지속 |
| 로그 진행 여부 | WAITING/BLOCKED에서 lock 작업 정지 | Worker 진행 로그 지속 |
| Deadlock 재현 여부 | 재현됨 | 관찰 기간 내 재현되지 않음 |

### 임시 조치와 근본 해결 구분

- Workaround: `MULTI_THREAD_ENABLE=false`로 동시 실행 경로를 회피했다.
- 근본 해결 제안: 정상 소스에서 공유 자원의 Lock 획득 순서를 하나로 통일하거나, 복수 Lock 동시 획득을 피하고 timeout/try-lock 정책을 적용해야 한다. 바이너리 역공학은 수행하지 않았다.

## Evidence checklist

- [x] PID가 살아있는 실제 출력이 있다.
- [x] CPU/MEM 변화 정체를 비교할 수 있다.
- [x] `top -H` 또는 `ps -L` 등 스레드 관찰 증거가 있다.
- [x] 마지막 WAITING/BLOCKED 실제 로그가 있다.
- [x] 스레드/락 순환 대기 판단 근거가 있다.
- [x] `MULTI_THREAD_ENABLE` 변경 전·후 비교가 있다.
- [x] Mission PDF 예시가 아니라 실제 실행 증거다.
