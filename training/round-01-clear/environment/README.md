# B1-2 R01 Environment

## 역할

B1-2는 OOM/Memory Leak, CPU Spike, Deadlock을 의도적으로 재현하므로 **격리 환경과 실험 통제**가 환경 구성의 핵심입니다.

상세 안전 절차는 `RUNTIME-SAFETY.md`, Before/After 통제 기준은 `../docs/experiment-matrix.md`를 사용합니다.

## Golden Path

- Ubuntu 22.04 LTS 또는 동등 Linux
- 전용 WSL2 Ubuntu / VM / 실습 Linux 우선
- root가 아닌 일반 사용자로 제공 앱 실행
- `agent-app-leak.zip`
- `ps`, `top`, `pgrep`, `ss`, `free`, `nproc`, `awk`, `grep`, `unzip`, `file`, `kill`
- B1-1에서 익힌 관제 사고를 재사용하되 B1-2 Evidence는 R01에서 새로 수집

공유 운영 서버에서는 장애 재현을 하지 않습니다.

## 공식 Runtime 조건

- `AGENT_HOME` 설정
- `AGENT_PORT=15034`
- `AGENT_UPLOAD_DIR=$AGENT_HOME/upload_files`
- `AGENT_KEY_PATH=$AGENT_HOME/api_keys`
- `AGENT_LOG_DIR`: 존재 + 실행 사용자 쓰기 가능
- `MEMORY_LIMIT`: 정수 50~512 MB
- `CPU_MAX_OCCUPY`: 정수 10~100 %
- `MULTI_THREAD_ENABLE`: true/false 계열
- `$AGENT_HOME/api_keys/secret.key` 존재
- `0.0.0.0:15034` 바인딩 가능

> `AGENT_KEY_PATH`는 B1-2 공식 Mission의 표현에 따라 `api_keys` 디렉터리를 가리키고, 실제 `secret.key`는 그 디렉터리 아래에 둡니다.

## Reference 경로

Beginner Guide는 사용자 홈 아래의 별도 실험 경로를 사용합니다.

```bash
export AGENT_HOME="$HOME/b1-2-agent"
```

이 경로는 B1-1 Runtime 자산과 B1-2 장애 실험 자산을 섞지 않기 위한 것입니다.

## 실험 통제

세 장애 모두 다음 흐름으로 비교합니다.

```text
동일 host/binary
→ Before 조건 기록
→ PID + app log + monitor log
→ 핵심 변수 1개 조정
→ After 재실행
→ 수치/종료/로그 Before & After 비교
```

- OOM: `MEMORY_LIMIT`
- CPU: `CPU_MAX_OCCUPY`
- Deadlock: `MULTI_THREAD_ENABLE`

환경변수를 바꿨다는 사실 자체를 개선 결과로 간주하지 않습니다. 실제 생존시간, CPU/RSS 패턴, 종료 여부, 로그 진행 여부가 어떻게 달라졌는지 확인합니다.

## Secret

`secret.key` 실제 값은 공식 원본에서 확인하고 **실제 Runtime 머신에서만** 입력합니다.

금지:

- GitHub에 실제 key 파일 commit
- 채팅에 값 붙여넣기
- `cat secret.key` 결과를 Evidence에 저장
- shell trace(`set -x`) 상태에서 Secret 입력
- Secret 값이 보이는 화면 캡처

검증은 존재/권한만 사용합니다.

## Runtime 안전 Gate

장애 실험 전:

```bash
free -h
nproc
pgrep -af 'agent.*leak' || true
ss -lntp | grep ':15034' || true
```

- 이전 실험 process가 남아 있지 않아야 함
- 15034가 다른 중요한 서비스와 충돌하지 않아야 함
- host에 충분한 여유가 있어야 함

## 종료 원칙

- 재부팅/강제 종료보다 Evidence를 먼저 수집
- Deadlock은 PID/thread/log 상태를 수집한 후 대상 PID만 종료
- 광범위한 `pkill -9` 금지
- Runtime 종료 후 process/port 잔존 여부 재확인

## 검증

```bash
# Phase A/Reference 구조와 필수 도구
bash training/round-01-clear/environment/verify.sh

# Phase C 실제 Evidence Gate
bash training/round-01-clear/environment/verify.sh --runtime
```

`--runtime` 성공은 단순 파일 존재만으로 CLEAR를 의미하지 않습니다. 실제 결과 해석, 3개 리포트, Evaluation 설명, Secret 검토까지 완료되어야 합니다.
