# B1-2 R01 — Reference Status

## 판정

**Phase A Reference Build: CORE READY**

**Runtime Mission: ⬜ NOT STARTED / CLEAR 아님**

B1-2 Runtime은 B1-1이 실제 `✅ CLEAR`된 이후에 시작합니다. 이 문서의 CORE READY는 OOM/CPU/Deadlock을 실제로 재현했다는 뜻이 아니라, 공식 Mission/Evaluation을 수행할 기준 경로와 검증 구조가 Phase A에서 준비되었다는 의미입니다.

## Source of Truth

- `b1-2-mission.pdf`
- `b1-2-mission.md`
- `b1-2-evaluation.md`
- `agent-app-leak.zip`

## Phase A 자체감사 결과

### 1. 장애 실험을 정상 기능 실습과 분리

OOM/CPU/Deadlock은 호스트에 부담을 줄 수 있으므로 전용 WSL2/VM/실습 Linux를 Golden Path로 유지하고 `environment/RUNTIME-SAFETY.md`에 시작/종료 Gate를 명시했습니다.

### 2. Before/After 비교의 통제 강화

`docs/experiment-matrix.md`를 추가하여 동일 host/binary를 유지하고 OOM은 `MEMORY_LIMIT`, CPU는 `CPU_MAX_OCCUPY`, Deadlock은 `MULTI_THREAD_ENABLE`을 핵심 비교 변수로 관리합니다.

환경변수 값을 바꾼 사실 자체를 개선으로 판정하지 않고 실제 생존시간, CPU/RSS 패턴, 종료 여부, 로그 진행 차이를 확인합니다.

### 3. 진단 monitor.sh 보강

- positive PID 검증
- interval > 0 검증
- 실행 시작 시 PID 존재 확인
- CPU/MEM/RSS/THREADS/ELAPSED 수집
- target 종료 시 `STATUS:EXITED`
- 사용자 중단 시 `STATUS:MONITOR_STOPPED_BY_USER`
- sample count 기록

### 4. Runtime verify 강화

Reference mode:

- 핵심 파일 존재
- monitor Bash syntax/필드
- 3개 공식 실험변수 Guide 포함
- 3개 Issue report의 필수 Section
- Runtime 전 TODO placeholder 유지
- Secret-pattern 파일 추적 여부

Runtime mode:

- 3개 report의 `TODO_RUNTIME` 제거 여부
- OOM/CPU/Deadlock 최소 Before/After Evidence
- PID 파일 형식
- monitor time-series record 수
- Evidence 내 Secret-pattern file 부재

### 5. Deadlock 과잉 단정 방지

PID 존재만으로 Deadlock을 판정하지 않습니다. CPU/MEM 변화 정체, app log 중단, thread 상태, WAITING/BLOCKED 또는 실제 앱의 동등 로그를 연결하여 논리적으로 추론합니다.

### 6. 실제 로그 표현 우선

공식 Mission에 예시 핵심 로그 문구가 있어도 Runtime 출력이 정확히 동일하지 않으면 실제 제공 앱의 출력 문구를 Evidence에 사용합니다. 예시 문구를 실제 결과처럼 만들어내지 않습니다.

### 7. Secret 안전성

실제 `secret.key` 값은 GitHub·채팅·로그·Evidence에 저장하지 않습니다. Runtime에서 직접 입력하고 존재/권한만 검증합니다.

## Phase A 준비 완료

- [x] Source/Evaluation 분석
- [x] 3개 장애 요구사항 분리
- [x] Beginner Guide
- [x] diagnostic monitor
- [x] Runtime Safety
- [x] Controlled Experiment Matrix
- [x] Issue template + report skeleton 3종
- [x] Requirement/Verification/Evidence Mapping
- [x] Evaluation Q&A
- [x] Reference/Runtime verify
- [x] Evidence Guide
- [x] Secret-safe 정책
- [x] 허위 PID/수치/로그/PASS 없음

## Phase C에서만 PASS 처리

- [ ] 실제 ZIP 내부/architecture
- [ ] 실제 필수 환경변수/Secret
- [ ] 실제 OOM 재현/Before-After
- [ ] 실제 CPU Spike 재현/Before-After
- [ ] 실제 Deadlock 재현/회피
- [ ] 실제 PID/timestamp/app logs/resource trends
- [ ] 실제 Issue report 3건
- [ ] `verify.sh --runtime` 0 FAIL
- [ ] Evaluation 자기 말 설명
- [ ] 실제 Evidence Secret 검토
- [ ] `✅ B1-2 CLEAR`

## Phase A Gate

- BLOCKER: **0**
- MAJOR: **0**
- Runtime-required: **명확히 분리**
- False Runtime PASS: **없음**

따라서 B1-2는 Phase A 기준 **CORE READY**로 분류합니다.
