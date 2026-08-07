# [Bug] OOM / Memory Leak — 실제 관측 후 제목 확정

> Runtime status: `NEEDS-RUNTIME`
>
> Evidence rule: 아래 `TODO`는 반드시 제공된 `agent-leak-app`을 실제 실행하여 얻은 값으로만 교체한다. Mission PDF의 결과 예시는 실제 증빙으로 복사하지 않는다.

## 1. Description (현상 설명)

- 재현 일시: `TODO`
- 실행 환경/아키텍처: `TODO`
- 프로세스 PID: `TODO`
- Before `MEMORY_LIMIT`: `TODO` MB
- 관측된 현상: `TODO`
- 종료 또는 상태 변화 시각: `TODO`

## 2. Evidence & Logs (증거 자료)

### 2.1 `monitor.sh` 메모리 상승 추이

Evidence path: `evidence/oom/`

```text
TODO: 실제 monitor.log에서 타임스탬프 + PID + MEM/RSS_KB가 증가하는 구간을 발췌
```

### 2.2 애플리케이션 종료 직전/직후 로그

```text
TODO: 실제 MemoryGuard / memory limit / self-termination 관련 원문 로그 발췌
```

### 2.3 확인 명령

```text
TODO: 실제 사용한 ps/top/pgrep 등 명령과 출력
```

## 3. Root Cause Analysis (원인 분석)

### 증거에서 확인된 사실

- `TODO`

### 기술적 원인 판단

- `TODO: 메모리 사용 증가와 종료 로그 사이의 인과를 실제 증거에 근거하여 설명`

### 관련 OS 원리

- `TODO: 프로세스 메모리/RSS, 메모리 누수의 영향, 애플리케이션 보호 정책을 구분해 설명`

> 주의: 이 미션의 종료가 Linux 커널 OOM Killer에 의한 것인지, 애플리케이션의 MemoryGuard에 의한 것인지는 실제 종료 로그를 근거로 판정한다.

## 4. Workaround & Verification (조치 및 검증)

### Before — Run 1

- `MEMORY_LIMIT`: `TODO`
- 시작 시각: `TODO`
- 종료/관측 시각: `TODO`
- 생존 시간: `TODO`
- 핵심 결과: `TODO`
- Evidence: `TODO`

### After — Run 2

- 변경한 `MEMORY_LIMIT`: `TODO`
- 시작 시각: `TODO`
- 종료/관측 시각: `TODO`
- 생존 시간: `TODO`
- 핵심 결과: `TODO`
- Evidence: `TODO`

### Before & After

| 항목 | Before | After |
|---|---|---|
| MEMORY_LIMIT | TODO | TODO |
| 생존 시간/종료 여부 | TODO | TODO |
| 종료 직전 RSS/MEM | TODO | TODO |
| 보호 로그 | TODO | TODO |

### 임시 조치와 근본 해결 구분

- Workaround: `TODO`
- 근본 해결 제안: `TODO: 실제 원인과 증거가 확보된 뒤 작성`

## Evidence checklist

- [ ] 메모리 증가 수치가 시간 순서로 존재한다.
- [ ] 종료 직전/직후 실제 애플리케이션 로그가 있다.
- [ ] `MEMORY_LIMIT`을 변경한 최소 2회 실행 결과가 있다.
- [ ] PID와 타임스탬프를 추적할 수 있다.
- [ ] Mission PDF 예시가 아니라 실제 실행 증거다.
