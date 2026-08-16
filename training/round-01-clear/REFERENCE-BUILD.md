# B1-2 R01 — Reference Build

## 목적

B1-2의 공식 Mission/Evaluation을 기준으로 **OOM Crash, CPU Spike, Deadlock 3개 장애를 재현·분석·비교·리포팅하는 기준 경로**를 준비합니다.

Reference Build는 실제 장애를 재현했다고 주장하는 단계가 아닙니다. 실제 앱 실행, 장애 발생, PID/자원 수치, 핵심 로그, Before & After, 스크린샷/Evidence는 Phase C Runtime에서만 채웁니다.

## Source of Truth

1. `b1-2-mission.pdf`
2. `b1-2-mission.md`
3. `b1-2-evaluation.md`
4. `agent-app-leak.zip`

## 공식 최종 결과

- OOM Crash GitHub Issue 형식 리포트 1건
- CPU Latency/Spike GitHub Issue 형식 리포트 1건
- Deadlock GitHub Issue 형식 리포트 1건
- 각 리포트: 현상 → 증거 → 근본 원인 → 조치/Before & After 검증

## R01 Runtime 원칙

- 전용 WSL2/VM/실습 Linux에서 수행
- root가 아닌 일반 사용자로 제공 앱 실행
- 실제 ZIP/architecture는 Runtime에서 확인
- 실제 Secret 값은 로컬 Runtime에만 존재
- 동일 host/binary에서 Before/After 비교
- 한 번에 핵심 실험 변수 하나를 우선 변경
- 환경변수를 바꾼 사실이 아니라 실제 관측 변화로 판단
- 장애 후 재부팅/광범위 kill보다 Evidence 보존 우선

## Reference Complete Path

1. Source/Evaluation 분석
2. 격리 Runtime + Safety Gate
3. `agent-app-leak.zip` architecture 확인
4. 공통 환경/Secret local-only
5. diagnostic `monitor.sh`
6. Controlled Experiment Matrix
7. OOM Before → 핵심 로그 → MEMORY_LIMIT After
8. CPU Before → Watchdog 로그 → CPU_MAX_OCCUPY After
9. Deadlock 재현 → PID/resource/log/thread evidence → MULTI_THREAD_ENABLE 회피
10. 3개 Issue 리포트
11. Runtime verify
12. Evaluation Q&A
13. Secret/Evidence audit
14. CLEAR Gate

## Phase A 준비 결과

- [x] Source/Evaluation 분석
- [x] `BEGINNER-GUIDE.md` Step 01~10
- [x] `CHECKLIST.md` Reference/Runtime 분리
- [x] 진단용 `monitor.sh`
- [x] `environment/README.md`
- [x] `environment/RUNTIME-SAFETY.md`
- [x] Reference/Runtime `environment/verify.sh`
- [x] `docs/experiment-matrix.md`
- [x] Issue 공통 템플릿
- [x] OOM/CPU/Deadlock report skeleton 3종
- [x] Requirement/Implementation/Verification/Evidence Mapping
- [x] Evaluation Q&A
- [x] Evidence Guide
- [x] `REFERENCE-STATUS.md`
- [x] 실제 Secret 값 미저장
- [x] 실제 Runtime PID/수치/로그를 만들어내지 않음

## 자체감사에서 보완한 사항

### 1. 실험 안전

OOM/CPU/Deadlock을 공유 운영 서버에서 수행하지 않도록 Runtime Safety Gate를 별도 문서로 분리했습니다. Deadlock은 별도 터미널에서 증거를 먼저 확보하고 대상 PID만 종료합니다.

### 2. Before/After 인과성

세 장애를 동일 host/binary에서 비교하고 핵심 환경변수 하나를 우선 변경하도록 Controlled Experiment Matrix를 추가했습니다. 실제 결과가 예상과 다르면 숨기지 않고 가설을 수정합니다.

### 3. monitor 입력/증거 품질

- 잘못된/과거 PID를 시작 전에 차단
- interval 0을 금지하여 monitor 자체가 busy loop가 되는 것을 방지
- sample count를 종료 marker에 남김
- CPU/MEM/RSS/THREADS/ELAPSED를 동일 형식으로 기록

### 4. Runtime Evidence Gate

`verify.sh --runtime`이 report placeholder뿐 아니라 최소 Before/After 파일, PID 형식, monitor 시계열 record, Evidence Secret-pattern 파일을 확인하도록 강화했습니다.

### 5. Deadlock 판정 엄격화

PID 존재만으로 Deadlock을 단정하지 않고 자원 정체, 로그 중단, thread/lock 대기 근거를 함께 요구합니다.

## Phase C에서만 완료할 것

- [ ] ZIP 내부/CPU architecture 실제 확인
- [ ] 필수 환경변수/Secret 실제 설정
- [ ] OOM 실제 재현 + 최소 2회 Before/After
- [ ] CPU Spike 실제 재현 + Before/After
- [ ] Deadlock 실제 재현 + 회피 비교
- [ ] PID/timestamp/핵심 app log/resource time series
- [ ] 3개 report의 `TODO_RUNTIME`을 실제 Evidence로 교체
- [ ] `verify.sh --runtime` 0 FAIL
- [ ] Evaluation 자기 말 설명
- [ ] Secret 노출 없음 최종 확인
- [ ] `✅ B1-2 CLEAR`

## 현재 판정

**Phase A Reference Build: CORE READY**

**Mission Runtime 상태: ⬜ NOT STARTED / CLEAR 아님**

다음 Phase A 작업은 B2-1 자체감사/정합성 마감입니다. B1-2 Runtime은 B1-1 실제 CLEAR 이후 시작합니다.
