# B1-2 Round 01 — Mission Clear Checklist

> Mission 상태는 `⬜ NOT STARTED`, `🟡 ACTIVE`, `⛔ BLOCKED`, `✅ CLEAR`만 사용합니다. B1-2 Runtime은 B1-1 CLEAR 이후에 시작합니다. **Phase A CORE READY는 Runtime PASS가 아닙니다.**

## 현재 상태

- Training Round: **R01 — CLEAR**
- Mission: **B1-2**
- Runtime Mission 상태: **⬜ NOT STARTED**
- Phase A Reference 상태: **CORE READY**

## A. Source / Scope

- [x] `b1-2-mission.pdf` 확인
- [x] `b1-2-mission.md` 확인
- [x] `b1-2-evaluation.md` 확인
- [x] `agent-app-leak.zip` 존재 확인
- [x] OOM / CPU Spike / Deadlock 3개 필수 케이스 분리
- [x] 보너스 스케줄링 추론은 필수 CLEAR와 분리
- [x] 실제 ZIP 내부/CPU architecture 확인은 Runtime 전용으로 분리

## B. Phase A Reference Build

- [x] `REFERENCE-BUILD.md`
- [x] `BEGINNER-GUIDE.md` Step 01~10
- [x] 각 Step ①~⑩ 구조
- [x] 진단용 `monitor.sh`
- [x] positive PID/interval 검증
- [x] CPU/MEM/RSS/THREADS/ELAPSED 시계열 필드
- [x] 대상 종료/사용자 중단 marker
- [x] `environment/README.md`
- [x] `environment/RUNTIME-SAFETY.md`
- [x] `environment/verify.sh` Reference/Runtime 모드
- [x] `docs/experiment-matrix.md`
- [x] Issue 공통 템플릿
- [x] OOM report skeleton
- [x] CPU report skeleton
- [x] Deadlock report skeleton
- [x] Requirement → Implementation → Verification → Evidence Mapping
- [x] Evaluation Q&A
- [x] Evidence Guide
- [x] `REFERENCE-STATUS.md`
- [x] actual Secret value를 Reference 산출물에 새로 저장하지 않음
- [x] 실제 PID/수치/로그를 만들어내지 않음
- [x] Phase A 자체감사 BLOCKER/MAJOR 0

## C. Runtime 공통 사전조건 — Phase C

- [ ] 격리 Linux/WSL2/VM 확인
- [ ] host memory/CPU 여유 확인
- [ ] `agent-app-leak.zip` 실제 내부 확인
- [ ] 실제 CPU architecture와 binary 일치
- [ ] root 아닌 일반 사용자 실행
- [ ] `AGENT_HOME`
- [ ] `AGENT_PORT=15034`
- [ ] `AGENT_UPLOAD_DIR=$AGENT_HOME/upload_files`
- [ ] `AGENT_KEY_PATH=$AGENT_HOME/api_keys`
- [ ] 쓰기 가능한 `AGENT_LOG_DIR`
- [ ] `MEMORY_LIMIT` 정수 50~512
- [ ] `CPU_MAX_OCCUPY` 정수 10~100
- [ ] `MULTI_THREAD_ENABLE` true/false 계열
- [ ] `$AGENT_HOME/api_keys/secret.key` 존재
- [ ] Secret 값 노출 없음
- [ ] `0.0.0.0:15034` bind 가능
- [ ] 이전 실험 프로세스/port 충돌 없음

## D. Controlled Experiment 원칙

- [x] Before/After 비교 matrix 준비
- [x] 같은 host/binary 사용 원칙
- [x] 핵심 변수 하나를 우선 변경하는 원칙
- [x] PID/app log/monitor log를 실행별 분리
- [x] 변수 변경 자체가 아니라 실제 관측 차이로 판정
- [ ] 실제 Runtime에서 각 실행 조건/시작·종료시간 기록

## E. OOM / Memory Leak — Phase C

- [ ] Before 실행 조건
- [ ] 실제 PID
- [ ] MEM/RSS가 시간에 따라 증가하는 패턴
- [ ] 종료 직전/직후 실제 app log
- [ ] MemoryGuard/메모리 보호정책 관련 실제 핵심 로그
- [ ] `MEMORY_LIMIT` 변경 후 After 실행
- [ ] 최소 2회 실행/비교
- [ ] 생존 시간 Before/After
- [ ] 대표/최대 메모리 수치 Before/After
- [ ] 실제 원인 분석
- [ ] OOM Issue 리포트 완성

## F. CPU Spike / Watchdog — Phase C

- [ ] Before 실행 조건
- [ ] 실제 PID
- [ ] 시스템 전체가 아닌 대상 PID CPU 급상승 증거
- [ ] monitor + `top -p` 또는 `ps` 증거
- [ ] Watchdog/보호 종료 관련 실제 핵심 로그
- [ ] `CPU_MAX_OCCUPY` 변경 후 After 실행
- [ ] 종료 여부/생존시간 Before/After
- [ ] CPU peak/패턴 Before/After
- [ ] 실제 원인 분석
- [ ] CPU Issue 리포트 완성

## G. Deadlock — Phase C

- [ ] 재현 조건 기록
- [ ] 실제 PID가 살아 있는 상태 확인
- [ ] 여러 sample의 CPU/MEM 정체
- [ ] app log 진행 중단 시점
- [ ] `top -H` 또는 `ps -L` thread 증거
- [ ] WAITING/BLOCKED 또는 실제 앱의 동등 핵심 로그
- [ ] thread/lock 대기 추론 근거
- [ ] 상호 배제/점유 대기/비선점/순환 대기 연결 설명
- [ ] `MULTI_THREAD_ENABLE` 변경 후 회피 비교
- [ ] 실제 원인 분석
- [ ] Deadlock Issue 리포트 완성
- [ ] Evidence 수집 후 대상 PID 안전 종료/정리

## H. 3개 Issue Report Format

세 리포트 모두:

- [ ] `Description`
- [ ] `Evidence & Logs`
- [ ] `Root Cause Analysis`
- [ ] `Workaround & Verification`
- [ ] 실제 PID
- [ ] 실제 timestamp
- [ ] 실제 핵심 app log
- [ ] monitor/time-series evidence
- [ ] Before & After 표
- [ ] Workaround와 코드 수준 근본 해결 구분
- [ ] `TODO_RUNTIME` 0개 — 실제 Evidence 확보 후에만 제거

## I. Evaluation — 관제/진단 설명

- [x] Memory Leak/OOM 판정 기준 답안
- [x] `MEMORY_LIMIT` 상향이 근본 해결이 아닌 이유
- [x] 특정 PID CPU 추적 명령/이유
- [x] Watchdog 보호 의미
- [x] 살아있지만 멈춘 프로세스의 진단 순서
- [x] PID만으로 Deadlock 단정 금지
- [ ] 사용자 실제 Runtime 결과로 자기 말 설명

## J. Evaluation — OS 원리 / 장애 원인

- [x] Deadlock 4대 조건 기준 답안
- [x] A→B / B→A 순환 관계 추론 기준
- [x] 로그가 부족하면 단정하지 않는 원칙
- [x] 환경변수 조정과 코드 결함 수정을 구분
- [ ] 실제 로그/스레드 결과를 근거로 자기 말 설명

## K. Evaluation — 운영 대응 / 개선

- [x] monitor 개선: 시계열/증가율/지속시간/알림 방향
- [x] OOM 코드 수준 개선
- [x] CPU 코드 수준 개선
- [x] Deadlock 코드 수준 개선
- [x] OOM+Deadlock 동시 의심 시 안정성/증거 우선 원칙
- [ ] 실제 수행 후 본인 접근 개선점 설명

## L. Verify / Evidence

- [x] Reference 구조 검사 설계
- [x] Runtime 최소 Evidence 파일 Gate 설계
- [x] PID 형식 검사 설계
- [x] monitor time-series 최소 record 검사 설계
- [x] Evidence 아래 Secret-pattern file 검사 설계
- [ ] 실제 환경에서 Reference `verify.sh` 결과 0 FAIL
- [ ] OOM 실제 Evidence
- [ ] CPU 실제 Evidence
- [ ] Deadlock 실제 Evidence
- [ ] `verify.sh --runtime` 실제 0 FAIL
- [ ] 제출 Evidence 최종 Secret 검토

## M. Final CLEAR

- [ ] OOM 리포트 실제 완료
- [ ] CPU 리포트 실제 완료
- [ ] Deadlock 리포트 실제 완료
- [ ] Evaluation 20문항 대응 가능
- [ ] Runtime 요구사항/증거 누락 없음
- [ ] Secret 노출 없음
- [ ] **✅ B1-2 CLEAR**

**운영 규칙:** B1-2 Reference Build는 선제 준비할 수 있지만 B1-2 Runtime은 B1-1이 실제 `✅ CLEAR`된 후 시작합니다.
