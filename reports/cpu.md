# [Bug] CPU Spike / Watchdog — CPU 부하 상승 후 보호 임계치 위반으로 프로세스 종료

> Runtime status: `PASS`
>
> 실제 Linux 실행 근거: GitHub Actions `31217119811` + interval run `31217376403`. Mission PDF 예시는 실제 증빙으로 사용하지 않았다.

## 1. Description (현상 설명)

- 재현 일시: `2026-08-07 20:44:03~20:48:18 UTC`
- 실행 환경/아키텍처: GitHub-hosted Ubuntu 24.04 / x86_64 / non-root `runner` (uid 1001)
- Before listener PID: `2272`, `CPU_MAX_OCCUPY=10`
- After focused listener PID: `2746`, `CPU_MAX_OCCUPY=90`
- interval run worker/listener PID: `2378`
- 관측 현상: 낮은 설정에서는 CpuWorker가 10% 부근에서 반복적으로 cooldown하여 45초 동안 보호 위반이 발생하지 않았다. 높은 설정에서는 애플리케이션 CPU telemetry가 5%에서 55% 이상까지 올라간 뒤 `CPU Threshold Violated!`를 기록하고 프로세스가 종료됐다.

## 2. Evidence & Logs (증거 자료)

Evidence path:

- `evidence/cpu/before.log`
- `evidence/cpu/after.log`
- `evidence/cpu/interval.log`

### 2.1 특정 프로세스 CPU 상승 구간

Linux `/proc/<pid>/stat`을 약 0.25초 간격으로 읽어 시스템 전체가 아니라 공급된 앱의 process group을 PID별로 관측했다. interval run의 listener/worker PID `2378`에서 다음과 같이 관측됐다.

```text
2.302s  PID 2378  CPU 3.91%
8.442s  PID 2378  CPU 7.82%
17.908s PID 2378  CPU 11.73%
20.978s PID 2378  CPU 15.64%
27.118s PID 2378  CPU 19.54%
```

같은 실행의 애플리케이션 CpuWorker telemetry도 상승했다.

```text
20:47:50 Current Load: 5.00%
20:47:56 Current Load: 16.33%
20:48:03 Current Load: 23.70%
20:48:09 Current Load: 35.04%
20:48:12 Current Load: 40.65%
20:48:15 Current Load: 49.99%
20:48:18 Current Load: 56.92%
```

> OS interval CPU와 애플리케이션 내부 `Current Load`는 샘플링 방식/정의가 다르므로 같은 숫자라고 주장하지 않는다. 둘 모두 대상 프로세스/앱의 부하 상승 방향을 독립적으로 보여 준다.

### 2.2 Watchdog / 보호 종료 근거

이 공급 빌드는 Mission PDF 예시의 literal `[WATCHDOG]` 또는 `SIGTERM` 문자열을 애플리케이션 로그에 출력하지 않았다. 실제 build에서 확인된 보호 정책의 종료 signature는 다음이다.

```text
2026-08-07 20:45:20,115 [INFO] [CpuWorker] Current Load: 47.06%
2026-08-07 20:45:23,230 [INFO] [CpuWorker] Current Load: 55.58%
2026-08-07 20:45:23,331 [CRITICAL] [CpuWorker] CPU Threshold Violated! (55.58%).
```

focused run에서 이 직후 프로세스가 종료됐고 launcher exit code는 `143`이었다. Exit 143은 OS 수준에서 SIGTERM 종료와 일치하지만, 존재하지 않은 literal `SIGTERM` 애플리케이션 로그를 만들지는 않는다. 따라서 이 보고서에서 `Watchdog`은 **CPU 과점유 방지 보호 정책의 역할명**으로 사용하고, 실제 로그 증거는 `CPU Threshold Violated!`로 기록한다.

### 2.3 시스템 전체 부하와 대상 프로세스 구분

사용한 관제 방식:

- `ss -lntp`로 tcp/15034 listener PID 식별
- `ps`로 launcher/listener process family 분리
- `/proc/<pid>/stat`의 `utime + stime` tick delta를 0.25초 간격으로 계산하여 PID별 interval CPU 관측
- 애플리케이션 `CpuWorker` 로그와 OS PID telemetry를 시간 순서로 대조

interval 실행에서 관측된 최대 값:

```text
pid=2373 launcher       max_interval_cpu=27.36%
pid=2378 listener/worker max_interval_cpu=19.54%
```

## 3. Root Cause Analysis (원인 분석)

### 증거에서 확인된 사실

- `CPU_MAX_OCCUPY=10`에서는 CpuWorker가 10%에 도달하면 `Starting cooldown`을 반복했고 45초 관찰 동안 CPU 보호 위반은 없었다.
- `CPU_MAX_OCCUPY=90`에서는 CpuWorker telemetry가 55.58%/56.92%까지 상승했다.
- Linux PID별 interval telemetry에서도 대상 worker의 짧은 구간 CPU가 낮은 한 자리수에서 최대 19.54%까지 상승하는 구간이 확인됐다.
- 높은 설정 실행은 `CPU Threshold Violated!` 직후 종료됐다.

### 기술적 원인 판단

`CPU_MAX_OCCUPY`를 낮게 두면 생성 부하가 낮은 수준에서 cooldown되어 보호 임계치에 도달하지 않는다. 높은 값으로 허용하면 부하가 계속 상승하며, 이 공급 빌드가 갖고 있는 CPU 보호 임계치를 넘는 시점에 `CPU Threshold Violated!`를 기록하고 프로세스를 종료한다. 따라서 장애는 시스템 전체 CPU가 높다는 추측이 아니라 **공급 앱 process family의 실제 CPU 관측 + 자체 CpuWorker telemetry + 보호 종료 로그**로 판단했다.

### 관련 OS 원리

CPU를 장시간 과점유하는 프로세스는 scheduler에서 많은 실행 시간을 소비해 다른 runnable task의 latency를 늘릴 수 있다. 서버에서는 이것이 응답 지연과 timeout으로 이어질 수 있으므로 프로세스 단위 관제와 보호 정책이 필요하다. 다만 `%CPU` 도구마다 lifetime average, 짧은 interval, 애플리케이션 내부 metric 등 정의가 다르므로 측정 방식과 PID를 함께 기록해야 한다.

## 4. Workaround & Verification (조치 및 검증)

### Before — Run 1

- `CPU_MAX_OCCUPY=10`
- 시작: `20:44:03Z`
- 관찰 종료: `20:44:48Z`
- 생존/종료: 45초 동안 보호 종료 없음; bounded harness가 종료
- CpuWorker: `5~10%` 범위에서 peak/cooldown 반복
- 실제 Watchdog 역할의 보호 violation 로그: 없음
- Evidence: `evidence/cpu/before.log`

### After — Run 2

- `CPU_MAX_OCCUPY=90`
- 시작: `20:44:49Z`
- 종료: `20:45:23Z`
- 생존 시간: 약 `34초`
- CpuWorker 최고 종료 직전 값: `55.58%` (별도 interval 재실행에서는 `56.92%`)
- 대상 listener/worker OS interval 최고 관측: `19.54%`
- 보호 로그: `CPU Threshold Violated!`
- 종료 결과: exit `143`
- Evidence: `evidence/cpu/after.log`, `evidence/cpu/interval.log`

### Before & After

| 항목 | Before | After |
|---|---|---|
| CPU_MAX_OCCUPY | 10 | 90 |
| CpuWorker 동작 | 10%에서 cooldown 반복 | 50% 이상까지 상승 |
| PID별 OS 관제 | 대상 process family 식별 | interval worker CPU 최대 19.54% |
| 생존/종료 | 45초 보호 종료 없음 | 약 34초 후 보호 종료 |
| Watchdog/보호 로그 | violation 없음 | `CPU Threshold Violated!` |
| literal `WATCHDOG`/`SIGTERM` 앱 로그 | 없음 | 없음 — 공급 build 특성 그대로 기록 |

### 임시 조치와 근본 해결 구분

- Workaround: 이번 공급 앱에서는 `CPU_MAX_OCCUPY`를 낮게 설정하여 부하가 보호 임계치까지 상승하기 전에 cooldown하도록 했다.
- 근본 해결 제안: 정상 소스에서 CPU intensive loop/작업의 단위를 줄이고 sleep/backoff, queue rate limit 또는 worker concurrency limit을 적용하며, process-level CPU를 짧은 interval로 관제해 임계치 접근 전에 경보해야 한다.

## Evidence checklist

- [x] 대상 PID의 CPU 상승 구간이 Linux `/proc` interval 관제로 존재한다.
- [x] 실제 Watchdog 역할의 CPU 보호/종료 근거(`CPU Threshold Violated!` + exit 143)가 있다.
- [x] `CPU_MAX_OCCUPY` 변경 전·후 결과가 있다.
- [x] PID와 타임스탬프를 추적할 수 있다.
- [x] Mission PDF 예시가 아니라 실제 실행 증거다.
