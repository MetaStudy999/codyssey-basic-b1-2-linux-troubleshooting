#!/usr/bin/env bash
# B1-2 R01 verification helper.
# Default: reference structure checks only.
# Runtime mode: ./verify.sh --runtime

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

for f in \
    "$ROUND_DIR/BEGINNER-GUIDE.md" \
    "$ROUND_DIR/CHECKLIST.md" \
    "$ROUND_DIR/REFERENCE-BUILD.md" \
    "$ROUND_DIR/monitor.sh" \
    "$ROUND_DIR/docs/issue-template.md" \
    "$ROUND_DIR/docs/oom-report.md" \
    "$ROUND_DIR/docs/cpu-report.md" \
    "$ROUND_DIR/docs/deadlock-report.md" \
    "$ROUND_DIR/docs/requirements-mapping.md" \
    "$ROUND_DIR/docs/evaluation-qa.md" \
    "$ROUND_DIR/evidence/README.md"; do
    check_file "$f"
done

if bash -n "$ROUND_DIR/monitor.sh" 2>/dev/null; then pass "monitor.sh syntax"; else fail "monitor.sh syntax"; fi

for cmd in bash ps top grep awk sed tee ss; do
    command -v "$cmd" >/dev/null 2>&1 && pass "command exists: $cmd" || fail "command missing: $cmd"
done

# Secret-pattern files must not be tracked outside immutable official source requirements.
if command -v git >/dev/null 2>&1; then
    TRACKED=$(git -C "$REPO_ROOT" ls-files 'training/round-01-clear/**' | grep -E '(^|/)(\.env($|\.)|.*\.(key|pem)$|secrets/)' || true)
    [ -z "$TRACKED" ] && pass "no Secret-pattern files tracked in Round 01" || fail "Secret-pattern files tracked in Round 01"
fi

if [ "$MODE" = "--runtime" ] || [ "$MODE" = "runtime" ]; then
    for case_name in oom cpu deadlock; do
        CASE_DIR="$ROUND_DIR/evidence/$case_name"
        if [ -d "$CASE_DIR" ] && find "$CASE_DIR" -maxdepth 1 -type f -size +0c | grep -q .; then
            pass "runtime evidence exists: $case_name"
        else
            fail "runtime evidence missing: $case_name"
        fi
    done

    for report in "$ROUND_DIR/docs/oom-report.md" "$ROUND_DIR/docs/cpu-report.md" "$ROUND_DIR/docs/deadlock-report.md"; do
        if grep -q 'TODO_RUNTIME' "$report"; then
            fail "runtime placeholders remain: ${report##*/}"
        else
            pass "runtime placeholders cleared: ${report##*/}"
        fi
    done
fi

echo
printf 'Result: %d PASS / %d FAIL\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
