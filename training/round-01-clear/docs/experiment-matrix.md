# B1-2 R01 — Controlled Experiment Matrix

## 목적

OOM, CPU Spike, Deadlock을 비교할 때 **한 번에 하나의 핵심 실험 변수만 바꾸고 나머지 조건을 가능한 동일하게 유지**합니다.

공식 Mission은 `MEMORY_LIMIT`, `CPU_MAX_OCCUPY`, `MULTI_THREAD_ENABLE`을 조정하여 Before & After를 비교하도록 요구합니다. 이 문서는 임의의 성공 수치를 미리 정하지 않고, 실제 Runtime에서 비교 가능성을 높이기 위한 실험 통제 기준입니다.

## 공통 원칙

1. 같은 머신/VM과 같은 제공 바이너리를 사용합니다.
2. 각 실행 전에 이전 `agent-app-leak` 프로세스가 남아 있지 않은지 확인합니다.
3. `15034` 포트가 비어 있는지 확인합니다.
4. 각 케이스에서 변경한 핵심 환경변수와 시작/종료 시간을 기록합니다.
5. PID, app log, monitor log를 실행별로 분리합니다.
6. After는 Before와 비교할 핵심 변수 1개를 우선 변경합니다.
7. 예상과 다르면 결과를 숨기지 않고 실제 관측을 기록하고 가설을 수정합니다.
8. 장애 재현은 격리 Linux에서만 수행합니다.

## Evidence 파일 명명 규칙

```text
training/round-01-clear/evidence/
├── oom/
│   ├── before-app.log
│   ├── before-monitor.log
│   ├── before-pid.txt
│   ├── after-app.log
│   ├── after-monitor.log
│   └── after-pid.txt
├── cpu/
│   ├── before-app.log
│   ├── before-monitor.log
│   ├── before-pid.txt
│   ├── before-process-snapshot.txt
│   ├── after-app.log
│   ├── after-monitor.log
│   ├── after-pid.txt
│   └── after-process-snapshot.txt
└── deadlock/
    ├── before-app.log
    ├── before-monitor.log
    ├── before-pid.txt
    ├── before-process.txt
    ├── before-threads.txt
    ├── after-app.log
    ├── after-monitor.log
    ├── after-pid.txt
    └── after-process.txt
```

실제 필요한 캡처/추가 파일은 Runtime에서 추가할 수 있습니다.

## OOM / Memory Leak

| 구분 | 고정할 조건 | 변경할 핵심 변수 | 확인할 결과 |
|---|---|---|---|
| Before | 동일 binary, 동일 host, CPU/Thread 조건 | `MEMORY_LIMIT` 기준값 | RSS/MEM 시간 증가, 보호 종료, 생존 시간 |
| After | Before와 동일 | `MEMORY_LIMIT`만 우선 변경 | 생존 시간/종료 시점/RSS 변화 비교 |

**판정 원칙:** `MEMORY_LIMIT`을 올렸다는 사실 자체가 성공이 아닙니다. 실제로 더 오래 생존했는지, 종료 시점이 달라졌는지 관제와 앱 로그로 확인합니다.

## CPU Spike / Watchdog

| 구분 | 고정할 조건 | 변경할 핵심 변수 | 확인할 결과 |
|---|---|---|---|
| Before | 동일 binary, 동일 host, Memory/Thread 조건 | `CPU_MAX_OCCUPY` 기준값 | 특정 PID CPU 급상승, Watchdog/종료, 생존 시간 |
| After | Before와 동일 | `CPU_MAX_OCCUPY`만 우선 변경 | 종료 여부/시점, CPU peak/패턴 비교 |

**판정 원칙:** 시스템 전체 CPU보다 **대상 PID의 CPU**가 핵심입니다. `ps`, `top -p <PID>`, `monitor.sh` 결과를 함께 사용합니다.

## Deadlock

| 구분 | 고정할 조건 | 변경할 핵심 변수 | 확인할 결과 |
|---|---|---|---|
| Before | 동일 binary, 동일 host, Memory/CPU 조건 | `MULTI_THREAD_ENABLE` 재현 조건 | PID 생존, 자원 정체, 로그 정지, thread 상태 |
| After | Before와 동일 | `MULTI_THREAD_ENABLE` 회피 조건 | 로그/작업 진행 여부, 무응답 회피 여부 |

**판정 원칙:** PID가 존재한다는 사실만으로 Deadlock을 단정하지 않습니다. 일정 시간 동안의 자원/로그 정체와 스레드/락 관련 로그를 함께 연결하여 추론합니다.

## 실행 전 공통 확인

```bash
pgrep -af 'agent.*leak' || true
ss -lntp | grep ':15034' || true
free -h
nproc
```

남아 있는 프로세스가 본인이 직전에 실행한 실험 프로세스인지 확인한 뒤 정상 종료합니다. 이름만 보고 무차별 `pkill`하지 않습니다.

## 리포트에 반드시 적을 비교 정보

- 실행 날짜/시간
- host/OS/architecture
- 사용한 제공 바이너리 파일
- 핵심 환경변수 Before/After 값
- PID
- 관측 시작/종료 시간
- monitor sample 수
- 최대/대표 CPU 또는 RSS
- 실제 종료 여부와 핵심 앱 로그
- 단순 환경변수 조정(Workaround)과 코드 수준 근본 해결 제안의 구분

> 이 문서는 실제 Runtime 값을 제공하지 않습니다. 모든 수치와 결과는 Phase C에서 실제 실행 결과로 채웁니다.
