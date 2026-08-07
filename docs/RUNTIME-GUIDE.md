# B1-2 Human Runtime Guide

> 이 문서는 **실제 Linux + 공식 제공 `agent-app-leak.zip`**으로 증빙을 만들기 위한 실행 절차다. 실행 전 `MISSION-WORK-PACKET.md`를 기준으로 Source 상태를 확인한다.
>
> Mission PDF의 예시 출력은 정답/증빙이 아니다. 아래 명령으로 직접 얻은 결과만 `evidence/`와 `reports/`에 기록한다.

## 0. 안전 원칙

- 로컬/VM/컨테이너 등 격리된 Linux 환경을 우선한다.
- 제공 바이너리는 **root가 아닌 일반 사용자**로 실행한다.
- 바이너리를 디컴파일/리버스 엔지니어링하지 않는다.
- 장애가 보이면 재부팅/강제종료부터 하지 말고 PID, 자원, 로그를 먼저 저장한다.
- `0.0.0.0:15034`가 바인딩되므로 공유 네트워크에서는 방화벽/노출 범위를 확인한다.

## 1. 공식 런타임 파일 확보와 아키텍처 확인

현재 저장소에는 `agent-app-leak.zip`이 포함되어 있지 않다. 공식 제공 파일을 로컬에 준비한 뒤 시작한다.

```bash
uname -m
mkdir -p runtime
unzip -l agent-app-leak.zip
unzip agent-app-leak.zip -d runtime
find runtime -maxdepth 3 -type f -print -exec file {} \;
```

Mission PDF가 안내하는 실행 파일:

- Intel/x86 계열: `agent-app-leak-x86`
- Apple/ARM64 계열: `agent-app-leak-arm64`

`uname -m`과 `file` 결과를 근거로 하나를 선택한다. 임의로 바이너리 내부를 분석하지 않는다.

예시:

```bash
# 실제 추출 경로에 맞게 바꾼다.
APP_BIN="runtime/agent-app-leak-x86"
file "$APP_BIN"
```

## 2. Mission PDF 사전 조건 구성

현재 사용자가 root가 아닌지 확인한다.

```bash
id
id -u
```

`id -u`가 `0`이면 해당 셸에서는 실행하지 않는다.

실습용 홈을 현재 저장소 아래 `runtime/agent-home`에 둔 예시다.

```bash
export AGENT_HOME="$PWD/runtime/agent-home"
export AGENT_PORT=15034
export AGENT_UPLOAD_DIR="$AGENT_HOME/upload_files"
export AGENT_KEY_PATH="$AGENT_HOME/api_keys"
export AGENT_LOG_DIR="$AGENT_HOME/logs"

mkdir -p "$AGENT_UPLOAD_DIR" "$AGENT_KEY_PATH" "$AGENT_LOG_DIR"
printf '%s\n' 'agent_api_key_test' > "$AGENT_KEY_PATH/secret.key"
chmod 700 "$AGENT_KEY_PATH"
chmod 600 "$AGENT_KEY_PATH/secret.key"
```

선택한 제공 바이너리를 실행 위치에 둔다.

```bash
install -m 750 "$APP_BIN" "$AGENT_HOME/agent-leak-app"
file "$AGENT_HOME/agent-leak-app"
```

필수 환경변수 범위는 Mission PDF 기준이다.

| 변수 | 공식 조건 |
|---|---|
| `MEMORY_LIMIT` | 정수 50~512 MB |
| `CPU_MAX_OCCUPY` | 정수 10~100 % |
| `MULTI_THREAD_ENABLE` | true/false (`1/0`, `yes/no` 허용) |

한 번에 세 장애를 섞지 말고 케이스별로 값을 기록하며 실행한다.

## 3. Evidence 디렉터리 준비

```bash
mkdir -p evidence/runtime/preflight evidence/oom evidence/cpu evidence/deadlock
```

사전 조건을 텍스트로 남긴다.

```bash
{
  date --iso-8601=seconds
  uname -a
  id
  printf 'AGENT_HOME=%s\n' "$AGENT_HOME"
  printf 'AGENT_PORT=%s\n' "$AGENT_PORT"
  printf 'AGENT_UPLOAD_DIR=%s\n' "$AGENT_UPLOAD_DIR"
  printf 'AGENT_KEY_PATH=%s\n' "$AGENT_KEY_PATH"
  printf 'AGENT_LOG_DIR=%s\n' "$AGENT_LOG_DIR"
  test -d "$AGENT_UPLOAD_DIR" && echo 'upload_dir=OK'
  test -d "$AGENT_KEY_PATH" && echo 'key_path=OK'
  test -f "$AGENT_KEY_PATH/secret.key" && echo 'secret_key_file=OK'
  test -w "$AGENT_LOG_DIR" && echo 'log_dir_writable=OK'
  file "$AGENT_HOME/agent-leak-app"
} | tee "evidence/runtime/preflight/preflight-$(date '+%Y%m%d-%H%M%S').txt"
```

키 파일의 실제 내용은 평가에 필요한 고정 테스트 문자열이지만, 증빙에서는 파일 존재 여부만으로 충분하면 전체 내용을 반복 출력하지 않는다.

## 4. 공통 관제 방법

### Terminal A — 앱 실행

케이스에 맞는 환경변수를 설정한 뒤 실행한다.

```bash
export MEMORY_LIMIT=256
export CPU_MAX_OCCUPY=80
export MULTI_THREAD_ENABLE=true

RUN_ID="$(date '+%Y%m%d-%H%M%S')"
"$AGENT_HOME/agent-leak-app" 2>&1 | tee "$AGENT_LOG_DIR/app-${RUN_ID}.log"
```

위 `256/80/true`는 **실행 예시**일 뿐 평가 증빙값을 대신하지 않는다. 실제 비교에서는 어떤 값을 사용했는지 각 리포트에 정확히 기록한다.

### Terminal B — 대상 프로세스 모니터

```bash
export AGENT_PROCESS_PATTERN='agent-leak-app'
export AGENT_PORT=15034
export AGENT_LOG_DIR="$PWD/evidence/runtime"

while true; do
  ./scripts/monitor.sh
  sleep 5
done
```

`monitor.sh`는 PID, process CPU%, process MEM%, RSS(KiB), thread 수, process state를 기록한다.

추가 확인:

```bash
pgrep -af agent-leak-app
ps -ef | grep '[a]gent-leak-app'
```

## 5. Case 1 — OOM / Memory Leak

목표는 다음 세 가지다.

1. 시간 경과에 따른 대상 프로세스 메모리 증가
2. MemoryGuard/메모리 임계치 관련 실제 종료 로그
3. `MEMORY_LIMIT` 변경 전·후 최소 2회 비교

### Run 1 — Before

`MEMORY_LIMIT` 값을 공식 범위 안에서 정하고 기록한다. 격리 환경에서 빠른 재현이 필요하면 낮은 범위에서 시작할 수 있지만, 실제 앱 동작을 보고 결정한다.

앱 실행과 동시에 `monitor.sh`를 반복 실행한다. 종료 후 다음을 보존한다.

```bash
cp "$AGENT_LOG_DIR"/app-*.log evidence/oom/ 2>/dev/null || true
cp evidence/runtime/monitor.log evidence/oom/monitor-before.log
```

핵심 로그 검색은 **검색 결과를 그대로 판정하지 말고 주변 문맥까지 확인**한다.

```bash
grep -nEi 'memory|limit|guard|terminated|self' evidence/oom/*.log
```

### Run 2 — After

`MEMORY_LIMIT`만 변경해 동일한 방식으로 재실행하고, 생존 시간 또는 종료 시점 변화를 기록한다.

```bash
# 실제 선택값을 기록한 뒤 설정한다.
export MEMORY_LIMIT=<변경한_50~512_정수>
```

`<...>`는 문서상의 자리표시자다. 실제 셸에는 정수값을 넣는다.

비교 항목:

- Before/After `MEMORY_LIMIT`
- 시작/종료 또는 관찰 종료 시각
- 생존 시간
- 종료 직전 MEM/RSS
- MemoryGuard 관련 로그

결과는 `reports/oom.md`에 반영한다.

## 6. Case 2 — CPU Spike / Watchdog

목표:

1. 시스템 전체가 아니라 **대상 PID의 CPU 급상승** 확인
2. Watchdog 보호 조치/종료 로그 확인
3. `CPU_MAX_OCCUPY` 변경 전·후 비교

관찰 명령:

```bash
PID="$(pgrep -f agent-leak-app | head -n 1)"
ps -p "$PID" -o pid,ppid,pcpu,pmem,rss,etime,stat,comm

top -b -d 1 -n 10 -p "$PID" | tee "evidence/cpu/top-${PID}-$(date '+%Y%m%d-%H%M%S').txt"
```

종료 로그에서 실제 Watchdog/신호 관련 문구를 보존한다.

```bash
grep -nEi 'watchdog|sigterm|abort|cpu' "$AGENT_LOG_DIR"/app-*.log
```

Run 1과 Run 2에서 `CPU_MAX_OCCUPY`만 변경하고, 다음을 비교한다.

- 최고 관측 CPU
- 종료 여부/생존 시간
- Watchdog 로그

결과는 `reports/cpu.md`에 반영한다.

## 7. Case 3 — Deadlock

Mission이 요구하는 진단 조합은 다음이다.

- PID는 존재
- CPU/MEM 변화가 멈춤
- 로그 진행이 멈춤
- 스레드/락 대기 근거
- `MULTI_THREAD_ENABLE` 변경 전·후 비교

### Before — 멀티스레드 조건

```bash
export MULTI_THREAD_ENABLE=true
```

무응답이 의심되면 **프로세스를 바로 죽이지 말고** 아래를 먼저 저장한다.

```bash
PID="$(pgrep -f agent-leak-app | head -n 1)"

ps -ef | grep '[a]gent-leak-app' | tee "evidence/deadlock/ps-ef-${PID}.txt"
ps -L -p "$PID" -o pid,tid,psr,pcpu,pmem,stat,wchan:32,comm \
  | tee "evidence/deadlock/ps-L-${PID}.txt"

top -H -b -d 1 -n 5 -p "$PID" \
  | tee "evidence/deadlock/top-H-${PID}.txt"
```

마지막 로그를 보존한다.

```bash
tail -n 100 "$AGENT_LOG_DIR"/app-*.log \
  | tee "evidence/deadlock/app-tail-${PID}.txt"
```

Mission에서 언급한 `WAITING`/`BLOCKED` 또는 이에 준하는 실제 대기 관계가 로그에 있는지 확인한다.

### After — 설정 변경

Mission 요구에 따라 `MULTI_THREAD_ENABLE`을 변경하여 동일 조건에서 재실행하고 Deadlock 재현/회피 여부를 비교한다.

```bash
export MULTI_THREAD_ENABLE=false
```

Before와 같은 시간 범위/관찰 방식으로 PID, CPU/MEM, 로그 진행 여부를 다시 기록한다.

결과는 `reports/deadlock.md`에 반영한다.

## 8. Runtime 종료 판정

다음이 모두 실제 파일/출력으로 확보되기 전에는 G5/G6를 PASS하지 않는다.

- OOM: 메모리 증가 + 종료 로그 + `MEMORY_LIMIT` 전후
- CPU: 대상 PID CPU 상승 + Watchdog 로그 + `CPU_MAX_OCCUPY` 전후
- Deadlock: PID 생존 + 자원/로그 정체 + thread/lock 대기 근거 + `MULTI_THREAD_ENABLE` 전후
- 3개 리포트의 PID/타임스탬프/실제 명령 출력 추적 가능

완료 후:

```bash
python3 scripts/validate_reports.py
```

정적 검증 PASS는 Runtime PASS를 의미하지 않는다. 실제 증빙 검토가 별도로 필요하다.
