# B1-2 R01 — Runtime Safety

## 왜 별도 안전 규칙이 필요한가

B1-2는 제공 앱으로 Memory Leak/OOM, CPU Spike, Deadlock을 **의도적으로 재현**합니다. 따라서 정상 기능 실습보다 격리와 종료 절차가 중요합니다.

## 실행 장소

권장 순서:

1. 전용 WSL2 Ubuntu / 전용 VM / 전용 실습 Linux
2. 다른 중요한 작업이 없는 로컬 Linux
3. 공유 운영 서버는 사용하지 않음

## 시작 전 Gate

다음 조건을 확인하지 못하면 장애 실험을 시작하지 않습니다.

```bash
cat /etc/os-release
uname -m
free -h
nproc
pgrep -af 'agent.*leak' || true
ss -lntp | grep ':15034' || true
```

확인 사항:

- 충분한 여유 메모리가 있는가?
- 중요한 작업이 같은 환경에서 실행 중이지 않은가?
- 이전 B1-2 실험 프로세스가 남아 있지 않은가?
- TCP 15034를 중요한 다른 서비스가 사용하지 않는가?

## 프로세스 종료 원칙

- 앱이 자체 보호정책으로 종료되면 종료 직전 로그와 monitor 결과를 먼저 보존합니다.
- Deadlock처럼 살아 있지만 진행이 멈춘 경우 PID/thread/log 증거를 먼저 수집합니다.
- 종료할 때는 **실제 PID를 확인한 뒤 해당 PID만** 정상 종료합니다.

```bash
ps -p "$APP_PID" -o user,pid,ppid,stat,etime,cmd
kill "$APP_PID"
```

필요할 때만 일정 시간 후 강제 종료를 검토합니다.

```bash
kill -0 "$APP_PID" 2>/dev/null && kill -KILL "$APP_PID"
```

프로세스 이름 패턴만으로 광범위한 `pkill -9`를 사용하지 않습니다.

## OOM 실험

- 공식 범위의 `MEMORY_LIMIT`만 사용합니다.
- 충분한 host 여유 메모리를 확인합니다.
- 메모리 보호정책 로그를 수집한 뒤 Before/After를 비교합니다.
- OS 전체가 메모리 압박을 받으면 실험을 중단하고 더 격리된/여유 있는 환경으로 이동합니다.

## CPU 실험

- 특정 프로세스의 CPU를 관찰합니다.
- 다른 중요한 CPU 작업을 같은 VM에서 수행하지 않습니다.
- 시스템이 과도하게 느려져 터미널 제어가 어려워지면 실험을 중단합니다.

## Deadlock 실험

Deadlock은 종료되지 않을 수 있으므로 별도 터미널을 사용할 것을 권장합니다.

- 터미널 A: 앱 실행
- 터미널 B: `monitor.sh`
- 터미널 C: `ps -L`, `top -H`, 로그 관찰/종료

PID 존재만으로 Deadlock을 단정하지 않습니다. CPU/MEM 변화 정체, 로그 중단, 스레드/락 관련 로그를 함께 수집합니다.

## Secret

- `$AGENT_HOME/api_keys/secret.key` 값은 로컬에서만 입력합니다.
- `cat secret.key`, shell trace(`set -x`)가 켜진 상태의 Secret 입력, Secret 값이 보이는 화면 캡처를 금지합니다.
- Evidence에는 존재/권한만 남깁니다.

## Evidence 위생

앱 로그 자체에 예상하지 못한 민감 값이 포함되지 않았는지 제출 전에 검토합니다.

```bash
# 파일 이름/구조 확인용. Secret 내용을 검색해 출력하는 방식은 사용하지 않습니다.
git status --short
git ls-files | grep -E '(^|/)(\.env($|\.)|.*\.(key|pem)$|secrets/)' || true
```

## Runtime 종료 후

- 실험 프로세스가 남아 있지 않은지 확인
- 15034 LISTEN이 예상대로 정리됐는지 확인
- 각 케이스 Evidence가 다른 케이스 파일과 섞이지 않았는지 확인
- 실제 Secret 파일은 Git 추적 대상이 아닌 로컬 Runtime 경로에 유지

```bash
pgrep -af 'agent.*leak' || true
ss -lntp | grep ':15034' || true
```
