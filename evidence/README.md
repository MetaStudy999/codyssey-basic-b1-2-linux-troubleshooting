# B1-2 Evidence Rules

이 디렉터리는 **실제 Linux 실행 결과만** 저장한다.

## Directory plan

```text
evidence/
├── README.md
├── runtime/
│   └── preflight/
├── oom/
├── cpu/
└── deadlock/
```

디렉터리는 실제 증빙 파일이 생길 때 생성한다.

## Evidence acceptance rules

- Mission PDF의 예시 로그/수치는 실제 Evidence가 아니다.
- 각 원본 텍스트에는 가능한 한 실행 시각, PID, 사용 명령, 환경변수 값을 추적할 수 있어야 한다.
- 스크린샷만 남기기보다 가능한 경우 원본 텍스트 로그도 함께 보존한다.
- 원본 로그를 리포트에 맞추기 위해 수정하지 않는다. 필요한 부분은 리포트에서 발췌하고 원본 경로를 링크한다.
- 환경변수 변경 전·후 실행은 서로 다른 파일로 보존한다.
- PID나 타임스탬프가 서로 다른 실행을 하나의 실행처럼 합치지 않는다.
- 제공 바이너리나 추출된 런타임 파일 자체는 Evidence로 커밋하지 않는다.

## Minimum evidence

| Case | Minimum actual evidence |
|---|---|
| OOM | 시간에 따른 메모리 증가 수치, 종료 직전/직후 앱 로그, `MEMORY_LIMIT` 변경 전·후 최소 2회 |
| CPU | 대상 PID CPU 급상승, Watchdog/종료 앱 로그, `CPU_MAX_OCCUPY` 변경 전·후 |
| Deadlock | PID 생존, CPU/MEM/로그 정체, `top -H` 또는 `ps -L`, 마지막 대기 로그, `MULTI_THREAD_ENABLE` 전·후 |

## Suggested filenames

```text
evidence/runtime/preflight/preflight-YYYYMMDD-HHMMSS.txt

evidence/oom/monitor-before.txt
evidence/oom/app-before.txt
evidence/oom/monitor-after.txt
evidence/oom/app-after.txt

evidence/cpu/top-PID-YYYYMMDD-HHMMSS.txt
evidence/cpu/app-before.txt
evidence/cpu/app-after.txt

evidence/deadlock/ps-ef-PID.txt
evidence/deadlock/ps-L-PID.txt
evidence/deadlock/top-H-PID.txt
evidence/deadlock/app-tail-PID.txt
```

## Status

Current Evidence status: `NEEDS-RUNTIME`.
