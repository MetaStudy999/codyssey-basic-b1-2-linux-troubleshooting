# B1-2 Round 01 — Mission Clear Checklist

> Mission 상태는 `⬜ NOT STARTED`, `🟡 ACTIVE`, `⛔ BLOCKED`, `✅ CLEAR`만 사용합니다. B1-2는 현재 Reference Build만 준비하며 Runtime은 B1-1 CLEAR 이후 시작합니다.

## 현재 상태

- Training Round: **R01 — CLEAR**
- Mission: **B1-2**
- Mission 상태: **⬜ NOT STARTED**
- Reference Build: 기준본 준비

## A. Source

- [x] `b1-2-mission.pdf` 확인
- [x] `b1-2-mission.md` 확인
- [x] `b1-2-evaluation.md` 확인
- [x] `agent-app-leak.zip` 존재 확인
- [x] 필수/보너스 구분
- [x] Reference Complete Path 설계
- [ ] Runtime에서 ZIP 내부/CPU 아키텍처 실제 확인

## B. Reference Build

- [x] `REFERENCE-BUILD.md`
- [x] `BEGINNER-GUIDE.md` 전체 Step 01~10
- [x] 진단용 `monitor.sh`
- [x] `environment/README.md`
- [x] `environment/verify.sh`
- [x] Issue 공통 템플릿
- [x] OOM report skeleton
- [x] CPU report skeleton
- [x] Deadlock report skeleton
- [x] Requirement/Evidence Mapping
- [x] Evaluation Q&A
- [x] Evidence Guide
- [x] 실제 Secret 값을 Reference 산출물에 저장하지 않음
- [x] 실제 Runtime 값을 조작해 채우지 않음

## C. Runtime 공통 사전조건

- [ ] 일반 사용자 실행
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
- [ ] `0.0.0.0:15034` 바인딩 가능

## D. OOM / Memory Leak

- [ ] Before 실행 조건 기록
- [ ] PID 기록
- [ ] MEM/RSS 시간 증가 패턴
- [ ] 종료 직전/직후 로그
- [ ] MemoryGuard 관련 실제 로그
- [ ] SELF-TERMINATED 관련 실제 로그
- [ ] `MEMORY_LIMIT` 변경 후 재실행
- [ ] 최소 2회 비교
- [ ] 생존 시간 Before/After
- [ ] 핵심 메모리 수치 Before/After
- [ ] OOM report 완성

## E. CPU Spike / Watchdog

- [ ] Before 실행 조건 기록
- [ ] PID 기록
- [ ] 특정 Agent 프로세스 CPU 급상승
- [ ] `top`/`ps`/monitor 증거
- [ ] Watchdog 관련 실제 로그
- [ ] SIGTERM/종료 관련 실제 로그
- [ ] `CPU_MAX_OCCUPY` 변경 후 재실행
- [ ] 생존 시간/종료 여부 Before/After
- [ ] CPU report 완성

## F. Deadlock

- [ ] `MULTI_THREAD_ENABLE=true` 재현 조건
- [ ] PID 유지 증거
- [ ] CPU/MEM 정체 구간
- [ ] 로그 중단 시점
- [ ] `top -H` 또는 `ps -L` 스레드 증거
- [ ] WAITING/BLOCKED 관련 실제 로그
- [ ] 스레드/락 대기 추론 근거
- [ ] 상호 배제 설명
- [ ] 순환 대기 설명
- [ ] `MULTI_THREAD_ENABLE=false` 회피 비교
- [ ] Deadlock report 완성

## G. Report Format

세 리포트 모두:

- [ ] Description / 현상
- [ ] Evidence & Logs / 증거
- [ ] Root Cause Analysis / 근본 원인
- [ ] Workaround & Verification / 조치 및 검증
- [ ] PID
- [ ] 실제 타임스탬프
- [ ] 핵심 로그 메시지
- [ ] Before & After 표
- [ ] 임시 조치와 근본 해결을 구분
- [ ] `TODO_RUNTIME` 없음 — 실제 Evidence로만 제거

## H. Evaluation — 관제/진단 설명

- [x] Reference Q&A에 메모리 증가 추적 명령/방법 정리
- [x] Reference Q&A에 CPU 도구/옵션 설명 정리
- [x] Reference Q&A에 살아있지만 멈춘 상태 진단 순서 정리
- [ ] 사용자 본인의 실제 결과로 설명

## I. Evaluation — OS 원리

- [x] Memory Leak/보호정책 종료 이유 정리
- [x] CPU 과점유/시스템 보호 이유 정리
- [x] Deadlock 4대 조건 정리
- [x] A→B / B→A 순환 관계 추론 기준 정리
- [ ] 실제 로그를 근거로 자기 말로 설명

## J. Evaluation — 운영 대응

- [x] monitor.sh 개선 방향 정리
- [x] OOM/CPU/Deadlock 근본 개선 예시 정리
- [x] OOM+Deadlock 동시 의심 시 우선순위 정리
- [ ] 실제 수행 후 본인의 개선점 설명

## K. Verify / Evidence

- [x] `environment/verify.sh` Reference 모드 준비
- [ ] Reference verify 실제 실행 결과 0 FAIL
- [ ] OOM Evidence 폴더 실제 생성/자료 확보
- [ ] CPU Evidence 폴더 실제 생성/자료 확보
- [ ] Deadlock Evidence 폴더 실제 생성/자료 확보
- [ ] `verify.sh --runtime` 0 FAIL
- [ ] Evidence에 Secret/Password/Token/Private Key 없음

## L. Final CLEAR

- [ ] OOM 리포트 실제 완료
- [ ] CPU 리포트 실제 완료
- [ ] Deadlock 리포트 실제 완료
- [ ] Evaluation 20문항 대응 가능
- [ ] 모든 Runtime 필수 증거 확보
- [ ] Secret 노출 없음
- [ ] **✅ B1-2 CLEAR**

**운영 규칙:** B1-2 Reference Build는 선제 준비할 수 있지만 B1-2 Runtime은 B1-1이 실제 `✅ CLEAR`된 후 시작합니다.
