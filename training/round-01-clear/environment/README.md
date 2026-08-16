# B1-2 R01 Environment

## Golden Path

B1-2는 장애를 의도적으로 재현하므로 **로컬 또는 격리된 Linux 환경**에서 수행합니다.

권장:

- Ubuntu 22.04 LTS 또는 동등 Linux
- 일반 사용자 실행
- `agent-app-leak.zip`
- `ps`, `top`, `htop`(선택), `pstree`, `kill`, `ss`, `awk`, `grep`
- B1-1에서 익힌 모니터링 개념 재사용

## 공식 Runtime 조건

- `AGENT_HOME` 설정
- `AGENT_PORT=15034`
- `AGENT_UPLOAD_DIR=$AGENT_HOME/upload_files`
- `AGENT_KEY_PATH=$AGENT_HOME/api_keys`
- `AGENT_LOG_DIR`: 존재하며 실행 사용자가 쓰기 가능
- `MEMORY_LIMIT`: 정수 50~512 MB
- `CPU_MAX_OCCUPY`: 정수 10~100 %
- `MULTI_THREAD_ENABLE`: true/false 계열
- `$AGENT_HOME/api_keys/secret.key` 존재
- `0.0.0.0:15034` 바인딩 가능

## Secret

`secret.key` 실제 값은 공식 원본에서 확인하고 **실제 Runtime 머신에서만** 입력합니다. Reference 문서, GitHub, 채팅, Evidence에는 값을 기록하지 않습니다.

## 안전

- 장애 재현은 공유 운영 서버에서 하지 않습니다.
- OOM/CPU 테스트 전 다른 중요한 작업을 종료합니다.
- 앱이 자체 보호정책으로 종료되더라도 OS 전체에 영향을 주지 않도록 충분한 여유 자원을 둡니다.
- Deadlock은 강제 재부팅보다 PID/스레드/로그 증거를 먼저 수집합니다.
- 바이너리 디컴파일/리버스 엔지니어링을 하지 않습니다.
