# [Bug] OOM / Memory Leak — MemoryGuard가 지속적인 메모리 증가를 감지해 프로세스를 종료

> Runtime status: `PASS`
>
> 실제 Linux 실행 근거: GitHub Actions `31216511416`, artifact `b1-2-runtime-cases` (`9008779652`). Mission PDF 예시는 실제 증빙으로 사용하지 않았다.

## 1. Description (현상 설명)

- 재현 일시: `2026-08-07 20:35:24~20:35:50 UTC`
- 실행 환경/아키텍처: GitHub-hosted Ubuntu 24.04 / x86_64 / non-root `runner` (uid 1001)
- Before PID: `2080`
- After PID: `2337`
- Before `MEMORY_LIMIT`: `64 MB`
- After `MEMORY_LIMIT`: `128 MB`
- 관측 현상: 대상 프로세스의 RSS와 애플리케이션 Heap 값이 시간에 따라 계단식으로 증가했고, 설정한 메모리 한계를 넘자 `MemoryGuard`가 직접 self-termination 로그를 남긴 뒤 프로세스가 종료됐다.

## 2. Evidence & Logs (증거 자료)

Evidence path: `evidence/oom/before.log`, `evidence/oom/after.log`

### 2.1 `monitor.sh` 메모리 상승 추이

Before PID `2080`:

```text
20:35:24 RSS_KB:18236
20:35:26 RSS_KB:43840
20:35:30 RSS_KB:69444
```

After PID `2337`:

```text
20:35:32 RSS_KB:18176
20:35:35 RSS_KB:43780
20:35:41 RSS_KB:94988
20:35:43 RSS_KB:120592
20:35:49 RSS_KB:146196
```

### 2.2 애플리케이션 종료 직전/직후 로그

Before (`MEMORY_LIMIT=64`):

```text
2026-08-07 20:35:26,226 [INFO] [MemoryWorker] Current Heap: 25MB
2026-08-07 20:35:29,245 [INFO] [MemoryWorker] Current Heap: 50MB
2026-08-07 20:35:32,265 [INFO] [MemoryWorker] Current Heap: 75MB
2026-08-07 20:35:32,266 [CRITICAL] [MemoryGuard] Memory limit exceeded (75MB >= 64MB) / (Recommend Over 256MB)
2026-08-07 20:35:32,266 [CRITICAL] [MemoryGuard] Self-terminating process 2080 to prevent system instability.
```

After (`MEMORY_LIMIT=128`):

```text
2026-08-07 20:35:43,554 [INFO] [MemoryWorker] Current Heap: 100MB
2026-08-07 20:35:46,572 [INFO] [MemoryWorker] Current Heap: 125MB
2026-08-07 20:35:49,591 [INFO] [MemoryWorker] Current Heap: 150MB
2026-08-07 20:35:49,592 [CRITICAL] [MemoryGuard] Memory limit exceeded (150MB >= 128MB) / (Recommend Over 256MB)
2026-08-07 20:35:49,592 [CRITICAL] [MemoryGuard] Self-terminating process 2337 to prevent system instability.
```

### 2.3 확인 명령/관제 방법

- 포트 소유 PID: `ss -lntp` 기반으로 tcp/15034 listener PID 식별
- 반복 관제: `scripts/monitor.sh`
- 프로세스 상태/메모리: `ps -p <PID> -o pid,ppid,%cpu,%mem,rss,etime,stat,comm`
- 애플리케이션 로그: `agent_app.log` / stdout

## 3. Root Cause Analysis (원인 분석)

### 증거에서 확인된 사실

- 동일 프로세스 PID에서 RSS가 계속 증가했다.
- 애플리케이션의 `MemoryWorker`도 Heap 25 → 50 → 75MB, 이후 100 → 125 → 150MB 증가를 기록했다.
- 종료 시점에는 Linux kernel OOM Killer 메시지가 아니라 애플리케이션 자체 `MemoryGuard`의 `Memory limit exceeded`와 `Self-terminating` 메시지가 존재한다.

### 기술적 원인 판단

이번 장애의 직접적인 종료 원인은 **애플리케이션 내부 MemoryGuard의 보호 정책**이다. 지속적인 메모리 증가 패턴이 설정 임계치를 넘었고, MemoryGuard가 시스템 불안정을 방지하기 위해 프로세스를 종료했다. 실제 코드의 누수 지점을 역공학한 것은 아니므로, 증거가 말하는 범위를 넘어 특정 코드 라인을 원인으로 단정하지 않는다.

### 관련 OS 원리

RSS(Resident Set Size)는 현재 프로세스가 실제 물리 메모리에 점유 중인 resident memory를 보여준다. 메모리 사용이 해제되지 않고 계속 증가하면 가용 메모리가 감소해 다른 프로세스와 시스템 전체에 영향을 줄 수 있다. 이번 실행에서는 OS OOM Killer가 개입하기 전에 애플리케이션 자체 보호 장치가 종료했다.

## 4. Workaround & Verification (조치 및 검증)

### Before — Run 1

- `MEMORY_LIMIT=64`
- 시작: `20:35:24Z`
- 종료: `20:35:32Z`
- 생존 시간: `8초`
- 종료 직전 관측 RSS: `69,444 KiB`
- MemoryWorker 마지막 값: `75MB`
- Evidence: `evidence/oom/before.log`

### After — Run 2

- `MEMORY_LIMIT=128`
- 시작: `20:35:32Z`
- 종료: `20:35:50Z`
- 생존 시간: `18초`
- 종료 직전 관측 RSS: `146,196 KiB`
- MemoryWorker 마지막 값: `150MB`
- Evidence: `evidence/oom/after.log`

### Before & After

| 항목 | Before | After |
|---|---:|---:|
| MEMORY_LIMIT | 64 MB | 128 MB |
| 생존 시간 | 8초 | 18초 |
| 종료 직전 관측 RSS | 69,444 KiB | 146,196 KiB |
| 마지막 Heap 로그 | 75 MB | 150 MB |
| 보호 로그 | MemoryGuard self-termination | MemoryGuard self-termination |

### 임시 조치와 근본 해결 구분

- Workaround: `MEMORY_LIMIT`을 높이면 실제 실행에서 생존 시간이 8초 → 18초로 늘어났다.
- 근본 해결 제안: 메모리를 지속적으로 보유하는 코드 경로를 정상 소스 수준에서 추적해 객체/버퍼 수명과 해제를 수정하고, RSS 증가율을 사전 경보로 관제해야 한다. 바이너리 역공학은 미션 제약에 따라 수행하지 않았다.

## Evidence checklist

- [x] 메모리 증가 수치가 시간 순서로 존재한다.
- [x] 종료 직전/직후 실제 애플리케이션 로그가 있다.
- [x] `MEMORY_LIMIT`을 변경한 최소 2회 실행 결과가 있다.
- [x] PID와 타임스탬프를 추적할 수 있다.
- [x] Mission PDF 예시가 아니라 실제 실행 증거다.
