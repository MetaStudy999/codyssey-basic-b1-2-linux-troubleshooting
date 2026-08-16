# B1-2 R01 — Evidence Guide

B1-2 Evidence는 세 장애 유형을 **실제 재현하고 비교했다는 증거**여야 합니다. 예상값이나 예시 로그를 실제 결과처럼 저장하지 않습니다.

## 권장 구조

```text
evidence/
├── README.md
├── oom/
│   ├── before-monitor.log
│   ├── before-app.log
│   ├── after-monitor.log
│   ├── after-app.log
│   └── commands.txt
├── cpu/
│   ├── before-monitor.log
│   ├── before-app.log
│   ├── after-monitor.log
│   ├── after-app.log
│   └── commands.txt
└── deadlock/
    ├── before-monitor.log
    ├── before-app.log
    ├── threads.txt
    ├── after-monitor.log
    ├── after-app.log
    └── commands.txt
```

실제 Runtime을 시작할 때만 위 하위 폴더를 만듭니다.

## OOM 최소 증거

- PID와 실행 조건
- 시간에 따른 MEM/RSS 증가 수치
- 종료 직전/직후 핵심 로그
- MemoryGuard/SELF-TERMINATED 관련 실제 로그
- `MEMORY_LIMIT` Before/After 값
- 최소 2회 실행 결과 비교
- 생존 시간 또는 종료 시점 비교

## CPU 최소 증거

- PID
- 특정 Agent 프로세스 CPU 급상승 수치
- `top`/`ps`/monitor 결과
- Watchdog/SIGTERM 관련 실제 로그
- `CPU_MAX_OCCUPY` Before/After
- 생존 시간/종료 여부 비교

## Deadlock 최소 증거

- PID가 계속 존재함
- CPU/MEM 변화 정체
- `top -H` 또는 `ps -L` 스레드 출력
- 로그가 멈춘 마지막 시각
- WAITING/BLOCKED 관련 실제 로그
- 스레드/락 순환 대기 추론 근거
- `MULTI_THREAD_ENABLE` Before/After

## Secret 보호

`secret.key` 실제 내용, Password, Token, Private Key는 Evidence에 넣지 않습니다.

파일이 필요하다는 증거는 다음처럼 **존재와 메타데이터만** 확인합니다.

```bash
test -s "$AGENT_HOME/api_keys/secret.key" && echo '[PASS] secret file exists'
stat -c '%U %G %a %n' "$AGENT_HOME/api_keys/secret.key"
```

## 리포트 연결

각 리포트의 Evidence & Logs에는 이 폴더의 실제 파일을 근거로 PID·타임스탬프·핵심 로그와 Before/After 수치를 연결합니다.
