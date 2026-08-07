# B1-2 Learning Guide

> G7 학습 자료의 준비본이다. 실제 Runtime 결과가 들어오기 전에는 `MASTERED` 또는 `PASS`로 표시하지 않는다.

## 1. 이 미션에서 설명할 수 있어야 하는 것

### Memory Leak / OOM

- 프로세스 메모리가 시간에 따라 계속 증가한다는 것을 어떤 수치로 확인했는가?
- `%MEM`과 RSS가 무엇을 보여 주는가?
- 실제 종료는 Linux 커널 OOM Killer인가, 애플리케이션 MemoryGuard인가? 어떤 로그로 구분했는가?
- `MEMORY_LIMIT`을 변경했을 때 왜 생존 시간이 달라졌는가?
- 임계치를 높이는 것은 왜 근본 해결이 아닌가?

### CPU Spike

- 시스템 전체 CPU와 특정 PID의 CPU를 어떻게 구분해 측정했는가?
- 특정 프로세스의 과점유가 다른 프로세스의 응답 지연에 어떤 영향을 줄 수 있는가?
- Watchdog는 어떤 증거를 기준으로 애플리케이션 보호 조치로 판단했는가?
- `CPU_MAX_OCCUPY` 변경 전·후 실제 결과가 어떻게 달라졌는가?

### Deadlock

- 프로세스가 살아 있다는 것과 정상 동작한다는 것이 왜 다른가?
- PID 생존, CPU/MEM 정체, 로그 정지, 스레드 대기 증거가 어떻게 하나의 판단으로 연결되는가?
- 교착상태 4대 조건을 본인의 실제 증거와 연결해 설명할 수 있는가?
  - Mutual Exclusion — 상호 배제
  - Hold and Wait — 점유 대기
  - No Preemption — 비선점
  - Circular Wait — 순환 대기
- 특히 순환 대기 관계를 로그에서 어떻게 추적했는가?
- `MULTI_THREAD_ENABLE` 변경 전·후 결과는 무엇이 달랐는가?

## 2. 명령어를 '왜' 썼는지 설명하기

실제 Runtime 후 아래 표의 `내 실행 결과`를 채운다.

| 명령/도구 | 무엇을 확인하는가 | 내 실행 결과 |
|---|---|---|
| `pgrep -af agent-leak-app` | 대상 프로세스와 PID 존재 | TODO |
| `ps -p PID -o ...` | 특정 PID CPU/MEM/RSS/상태 | TODO |
| `top -p PID` | 특정 프로세스의 시간 변화 관찰 | TODO |
| `ps -L -p PID` | 프로세스 내부 스레드 상태 | TODO |
| `top -H -p PID` | 스레드별 CPU/상태 변화 | TODO |
| `tail` | 앱 로그의 마지막 진행 지점 | TODO |
| `grep` | MemoryGuard/Watchdog/WAITING 등 후보 로그 위치 탐색 | TODO |
| `monitor.sh` | 동일 형식의 시계열 프로세스 지표 누적 | TODO |

중요: `grep` 결과 하나만 보고 원인을 확정하지 않는다. 원문 로그 문맥 + 프로세스 지표 + 설정 전·후를 함께 본다.

## 3. 증거 기반 트러블슈팅 사고 순서

```text
현상
  ↓
PID와 시간 고정
  ↓
프로세스/스레드/자원 관측
  ↓
애플리케이션 로그와 시간축 맞춤
  ↓
가설
  ↓
환경변수 한 개만 변경
  ↓
동일 방식으로 재실행
  ↓
Before / After
  ↓
Root Cause와 Workaround 구분
```

핵심은 '장애 이름을 먼저 정하고 증거를 끼워 맞추기'가 아니라, 관측값에서 결론으로 이동하는 것이다.

## 4. Runtime 후 1문장 요약 연습

각 Case를 아래 형식으로 한 문장으로 설명한다.

- OOM: `TODO: [어떤 수치]가 [어떻게 변화]했고 [어떤 로그]가 발생했으므로 [판정]했다.`
- CPU: `TODO: PID [x]의 CPU가 [수치]까지 올라가고 [로그]가 남아 [판정]했다.`
- Deadlock: `TODO: PID는 유지되지만 [자원/로그/스레드 증거]가 멈추고 [순환 대기 증거]가 있어 [판정]했다.`

## 5. 임시 조치와 근본 해결 구분

환경변수 임계치 조정은 Mission이 요구하는 **Workaround & Verification**이다. 실제 서비스의 근본 해결은 실제 원인이 확인된 뒤 코드/설계 수준에서 별도로 제안한다.

- OOM: 단순한 LIMIT 상향과 누수 제거는 다르다.
- CPU: Watchdog threshold 상향과 과도한 연산/루프 개선은 다르다.
- Deadlock: 멀티스레드 기능 비활성화와 lock 순서/동기화 설계 수정은 다르다.

위 근본 해결 예시는 일반적 방향이다. 최종 리포트에서는 실제 수집한 증거와 연결되는 것만 채택한다.

## 6. G7 완료 기준

- [ ] 실제 사용한 명령과 옵션을 본인의 말로 설명한다.
- [ ] OOM/CPU/Deadlock 판정 근거를 실제 Evidence 링크로 설명한다.
- [ ] Before/After 값을 외우는 것이 아니라 왜 달라졌는지 설명한다.
- [ ] Workaround와 Root Cause Fix를 구분한다.
- [ ] 세 Case를 각각 1분 이내에 증거 중심으로 설명할 수 있다.

Current learning status: `NOT-STUDIED / 준비본`.
