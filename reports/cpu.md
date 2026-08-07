# [Bug] CPU Spike / Watchdog — 실제 관측 후 제목 확정

> Runtime status: `NEEDS-RUNTIME`
>
> Evidence rule: 아래 `TODO`는 반드시 제공된 `agent-leak-app`을 실제 실행하여 얻은 값으로만 교체한다. Mission PDF의 결과 예시는 실제 증빙으로 복사하지 않는다.

## 1. Description (현상 설명)

- 재현 일시: `TODO`
- 실행 환경/아키텍처: `TODO`
- 프로세스 PID: `TODO`
- Before `CPU_MAX_OCCUPY`: `TODO` %
- 관측된 현상: `TODO`
- 종료 또는 상태 변화 시각: `TODO`

## 2. Evidence & Logs (증거 자료)

### 2.1 특정 프로세스 CPU 급상승 구간

Evidence path: `evidence/cpu/`

```text
TODO: 실제 monitor.log, ps 또는 top에서 PID와 CPU 사용률이 보이는 구간 발췌
```

### 2.2 애플리케이션 Watchdog 종료 로그

```text
TODO: 실제 Watchdog / SIGTERM / 보호 조치 관련 원문 로그 발췌
```

### 2.3 시스템 전체 부하와 대상 프로세스 구분

```text
TODO: 대상 PID의 CPU 사용률을 식별한 명령과 필요한 비교 출력
```

## 3. Root Cause Analysis (원인 분석)

### 증거에서 확인된 사실

- `TODO`

### 기술적 원인 판단

- `TODO: CPU 상승과 Watchdog 종료 사이의 관계를 실제 로그와 PID 기준으로 설명`

### 관련 OS 원리

- `TODO: 단일 프로세스의 CPU 과점유가 다른 작업의 스케줄링/응답 지연에 미치는 영향 설명`

> 주의: 단순히 시스템 전체 CPU가 높다는 사실만으로 대상 프로세스의 과점유를 단정하지 않는다. PID 기준 증거가 필요하다.

## 4. Workaround & Verification (조치 및 검증)

### Before — Run 1

- `CPU_MAX_OCCUPY`: `TODO`
- 시작 시각: `TODO`
- 종료/관측 시각: `TODO`
- 생존 시간/종료 여부: `TODO`
- 최고 관측 CPU: `TODO`
- Evidence: `TODO`

### After — Run 2

- 변경한 `CPU_MAX_OCCUPY`: `TODO`
- 시작 시각: `TODO`
- 종료/관측 시각: `TODO`
- 생존 시간/종료 여부: `TODO`
- 최고 관측 CPU: `TODO`
- Evidence: `TODO`

### Before & After

| 항목 | Before | After |
|---|---|---|
| CPU_MAX_OCCUPY | TODO | TODO |
| 최고 관측 CPU | TODO | TODO |
| 생존 시간/종료 여부 | TODO | TODO |
| Watchdog 로그 | TODO | TODO |

### 임시 조치와 근본 해결 구분

- Workaround: `TODO`
- 근본 해결 제안: `TODO: 실제 원인과 증거가 확보된 뒤 작성`

## Evidence checklist

- [ ] 대상 PID의 CPU 급상승 구간이 있다.
- [ ] 실제 Watchdog/종료 로그가 있다.
- [ ] `CPU_MAX_OCCUPY` 변경 전·후 결과가 있다.
- [ ] PID와 타임스탬프를 추적할 수 있다.
- [ ] Mission PDF 예시가 아니라 실제 실행 증거다.
