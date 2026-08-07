# [Bug] Deadlock — 실제 관측 후 제목 확정

> Runtime status: `NEEDS-RUNTIME`
>
> Evidence rule: 아래 `TODO`는 반드시 제공된 `agent-leak-app`을 실제 실행하여 얻은 값으로만 교체한다. Mission PDF의 결과 예시는 실제 증빙으로 복사하지 않는다.

## 1. Description (현상 설명)

- 재현 일시: `TODO`
- 실행 환경/아키텍처: `TODO`
- 프로세스 PID: `TODO`
- Before `MULTI_THREAD_ENABLE`: `TODO`
- 관측된 무응답 현상: `TODO`
- 로그가 마지막으로 진행된 시각: `TODO`

## 2. Evidence & Logs (증거 자료)

### 2.1 PID 생존 증거

Evidence path: `evidence/deadlock/`

```text
TODO: 실제 pgrep 또는 ps -ef 출력
```

### 2.2 CPU/MEM 변화 정체 및 스레드 상태

```text
TODO: 반복 monitor 수치 + top -H 또는 ps -L 출력
```

### 2.3 마지막 애플리케이션 로그

```text
TODO: 실제 WAITING/BLOCKED 또는 자원 대기 관계를 보여 주는 마지막 로그 원문
```

### 2.4 스레드/락 대기 추적

- Thread/worker A가 기다리는 자원: `TODO`
- Thread/worker B가 기다리는 자원: `TODO`
- 로그에서 확인한 의존 방향: `TODO`

## 3. Root Cause Analysis (원인 분석)

### 증거에서 확인된 사실

- PID 생존: `TODO`
- CPU/MEM 정체: `TODO`
- 로그 정지: `TODO`
- 스레드 대기 관계: `TODO`

### 기술적 원인 판단

- `TODO: 마지막 로그와 스레드 상태를 근거로 순환 대기를 설명`

### 관련 OS 원리

- 상호 배제(Mutual Exclusion): `TODO`
- 점유 대기(Hold and Wait): `TODO`
- 비선점(No Preemption): `TODO`
- 순환 대기(Circular Wait): `TODO`

> 최소한 상호 배제와 순환 대기는 실제 관측한 대기 관계에 연결해서 설명한다. 단지 프로세스가 느리다는 이유만으로 Deadlock이라고 판정하지 않는다.

## 4. Workaround & Verification (조치 및 검증)

### Before — 멀티스레드 조건

- `MULTI_THREAD_ENABLE`: `TODO`
- PID: `TODO`
- 일정 시간 뒤 상태: `TODO`
- CPU/MEM/로그 변화: `TODO`
- Evidence: `TODO`

### After — 설정 변경 조건

- 변경한 `MULTI_THREAD_ENABLE`: `TODO`
- PID: `TODO`
- 동일 관찰 시간 뒤 상태: `TODO`
- CPU/MEM/로그 변화: `TODO`
- Evidence: `TODO`

### Before & After

| 항목 | Before | After |
|---|---|---|
| MULTI_THREAD_ENABLE | TODO | TODO |
| PID 생존 | TODO | TODO |
| CPU/MEM 진행 여부 | TODO | TODO |
| 로그 진행 여부 | TODO | TODO |
| Deadlock 재현 여부 | TODO | TODO |

### 임시 조치와 근본 해결 구분

- Workaround: `TODO`
- 근본 해결 제안: `TODO: 실제 lock 순서/대기 관계 증거를 확보한 뒤 작성`

## Evidence checklist

- [ ] PID가 살아있는 실제 출력이 있다.
- [ ] CPU/MEM 변화 정체를 비교할 수 있다.
- [ ] `top -H` 또는 `ps -L` 등 스레드 관찰 증거가 있다.
- [ ] 마지막 WAITING/BLOCKED 또는 이에 준하는 실제 로그가 있다.
- [ ] 스레드/락 순환 대기 판단 근거가 있다.
- [ ] `MULTI_THREAD_ENABLE` 변경 전·후 비교가 있다.
- [ ] Mission PDF 예시가 아니라 실제 실행 증거다.
