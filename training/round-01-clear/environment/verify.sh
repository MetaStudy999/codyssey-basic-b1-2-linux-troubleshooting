#!/usr/bin/env bash
# B1-2 R01 verification helper.
# Default: Reference Build structure/consistency checks.
# Runtime mode: ./verify.sh --runtime
# This script does not reproduce OOM/CPU/Deadlock itself.

set -u

MODE="${1:-reference}"
PASS=0
FAIL=0
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROUND_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)

pass() { echo "[PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL + 1)); }

check_file() {
    [ -f "$1" ] && pass "file exists: ${1#$REPO_ROOT/}" || fail "file missing: ${1#$REPO_ROOT/}"
}

check_nonempty() {
    [ -s "$1" ] && pass "non-empty: ${1#$REPO_ROOT/}" || fail "missing/empty: ${1#$REPO_ROOT/}"
}

check_contains() {
    local file="$1"
    local pattern="$2"
    local label="$3"
    grep -Eq "$pattern" "$file" 2>/dev/null && pass "$label" || fail "$label"
}

# ---------- Phase A / reference consistency ----------
for f in \
    "$ROUND_DIR/BEGINNER-GUIDE.md" \
    "$ROUND_DIR/CHECKLIST.md" \
    "$ROUND_DIR/REFERENCE-BUILD.md" \
    "$ROUND_DIR/monitor.sh" \
    "$ROUND_DIR/environment/README.md" \
    "$ROUND_DIR/environment/RUNTIME-SAFETY.md" \
    "$ROUND_DIR/docs/experiment-matrix.md" \
    "$ROUND_DIR/docs/issue-template.md" \
    "$ROUND_DIR/docs/oom-report.md" \
    "$ROUND_DIR/docs/cpu-report.md" \
    "$ROUND_DIR/docs/deadlock-report.md" \
    "$ROUND_DIR/docs/requirements-mapping.md" \
    "$ROUND_DIR/docs/evaluation-qa.md" \
    "$ROUND_DIR/evidence/README.md"; do
    check_file "$f"
done

if bash -n "$ROUND_DIR/monitor.sh" 2>/dev/null; then
    pass "monitor.sh Bash syntax"
else
    fail "monitor.sh Bash syntax"
fi

# Ensure the monitor contains the fields used by all three reports.
for token in 'RSS_KB' 'THREADS' 'ELAPSED' 'STATUS:EXITED'; do
    grep -q "$token" "$ROUND_DIR/monitor.sh" \
        && pass "monitor field/marker: $token" \
        || fail "monitor field/marker missing: $token"
done

# The guide must preserve all three official experiment variables.
check_contains "$ROUND_DIR/BEGINNER-GUIDE.md" 'MEMORY_LIMIT' "guide covers MEMORY_LIMIT"
check_contains "$ROUND_DIR/BEGINNER-GUIDE.md" 'CPU_MAX_OCCUPY' "guide covers CPU_MAX_OCCUPY"
check_contains "$ROUND_DIR/BEGINNER-GUIDE.md" 'MULTI_THREAD_ENABLE' "guide covers MULTI_THREAD_ENABLE"
check_contains "$ROUND_DIR/BEGINNER-GUIDE.md" 'AGENT_PORT=15034' "guide covers AGENT_PORT=15034"
check_contains "$ROUND_DIR/BEGINNER-GUIDE.md" 'secret\.key' "guide covers secret.key path"

# Each report must retain the canonical Issue-style sections and Runtime
# placeholders until real evidence is collected.
for report in "$ROUND_DIR/docs/oom-report.md" "$ROUND_DIR/docs/cpu-report.md" "$ROUND_DIR/docs/deadlock-report.md"; do
    base=${report##*/}
    check_contains "$report" '^## 1\. Description' "$base Description section"
    check_contains "$report" '^## 2\. Evidence & Logs' "$base Evidence section"
    check_contains "$report" '^## 3\. Root Cause Analysis' "$base Root Cause section"
    check_contains "$report" '^## 4\. Workaround & Verification' "$base Workaround section"

    if [ "$MODE" != "--runtime" ] && [ "$MODE" != "runtime" ]; then
        grep -q 'TODO_RUNTIME' "$report" \
            && pass "$base keeps Runtime placeholders" \
            || fail "$base lost Runtime placeholders before Runtime"
    fi
done

# Required diagnostic commands. htop is optional and therefore not checked.
for cmd in bash ps top pgrep awk grep sed tee ss unzip file free nproc kill git; do
    command -v "$cmd" >/dev/null 2>&1 \
        && pass "command exists: $cmd" \
        || fail "command missing: $cmd"
done

# Secret-pattern files must not be tracked inside R01 artifacts.
TRACKED=$(git -C "$REPO_ROOT" ls-files 'training/round-01-clear/**' \
    | grep -E '(^|/)(\.env($|\.)|.*\.(key|pem)$|secrets/)' || true)
[ -z "$TRACKED" ] \
    && pass "no Secret-pattern files tracked in Round 01" \
    || fail "Secret-pattern files tracked in Round 01"

# ---------- Phase C / runtime evidence gate ----------
if [ "$MODE" = "--runtime" ] || [ "$MODE" = "runtime" ]; then
    # A real Runtime run must replace every report placeholder.
    for report in "$ROUND_DIR/docs/oom-report.md" "$ROUND_DIR/docs/cpu-report.md" "$ROUND_DIR/docs/deadlock-report.md"; do
        if grep -q 'TODO_RUNTIME' "$report"; then
            fail "runtime placeholders remain: ${report##*/}"
        else
            pass "runtime placeholders cleared: ${report##*/}"
        fi
    done

    # Minimum evidence files. Additional screenshots/outputs are welcome, but
    # these files provide a deterministic Before/After audit trail.
    RUNTIME_FILES=(
        "oom/before-app.log"
        "oom/before-monitor.log"
        "oom/before-pid.txt"
        "oom/after-app.log"
        "oom/after-monitor.log"
        "oom/after-pid.txt"
        "cpu/before-app.log"
        "cpu/before-monitor.log"
        "cpu/before-pid.txt"
        "cpu/after-app.log"
        "cpu/after-monitor.log"
        "cpu/after-pid.txt"
        "deadlock/before-app.log"
        "deadlock/before-monitor.log"
        "deadlock/before-pid.txt"
        "deadlock/before-threads.txt"
        "deadlock/after-app.log"
        "deadlock/after-monitor.log"
        "deadlock/after-pid.txt"
    )

    for rel in "${RUNTIME_FILES[@]}"; do
        check_nonempty "$ROUND_DIR/evidence/$rel"
    done

    # PID files must contain a positive integer only.
    for pid_file in "$ROUND_DIR"/evidence/{oom,cpu,deadlock}/{before,after}-pid.txt; do
        if [ -s "$pid_file" ] && grep -Eq '^[1-9][0-9]*$' "$pid_file"; then
            pass "valid PID evidence: ${pid_file#$ROUND_DIR/}"
        else
            fail "invalid/missing PID evidence: ${pid_file#$ROUND_DIR/}"
        fi
    done

    # Monitor files should have more than one sample/marker line; this prevents
    # an empty or single-header file from being treated as time-series evidence.
    for monitor_file in "$ROUND_DIR"/evidence/{oom,cpu,deadlock}/{before,after}-monitor.log; do
        samples=$(grep -Ec '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} ' "$monitor_file" 2>/dev/null || true)
        if [ "$samples" -ge 2 ]; then
            pass "time-series evidence has >=2 records: ${monitor_file#$ROUND_DIR/}"
        else
            fail "insufficient time-series records: ${monitor_file#$ROUND_DIR/}"
        fi
    done

    # Verify that no actual secret-key file was accidentally captured under evidence.
    LEAK_FILES=$(find "$ROUND_DIR/evidence" -type f \( -name '*.key' -o -name '*.pem' -o -name '.env' -o -name '.env.*' \) 2>/dev/null || true)
    [ -z "$LEAK_FILES" ] \
        && pass "no Secret-pattern files in Runtime evidence" \
        || fail "Secret-pattern files found in Runtime evidence"
fi

echo
printf 'Result: %d PASS / %d FAIL\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
