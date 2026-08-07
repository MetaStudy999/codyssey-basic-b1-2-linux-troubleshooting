#!/usr/bin/env python3
"""Static B1-2 report contract validator.

This validator checks only repository structure and required report sections.
It deliberately does NOT certify runtime evidence or mission PASS.
"""

from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
REPORTS = {
    "OOM": ROOT / "reports" / "oom.md",
    "CPU": ROOT / "reports" / "cpu.md",
    "Deadlock": ROOT / "reports" / "deadlock.md",
}

REQUIRED_HEADINGS = [
    "## 1. Description (현상 설명)",
    "## 2. Evidence & Logs (증거 자료)",
    "## 3. Root Cause Analysis (원인 분석)",
    "## 4. Workaround & Verification (조치 및 검증)",
]

REQUIRED_PHRASES = [
    "Runtime status:",
    "Before & After",
    "Evidence checklist",
    "Mission PDF 예시",
]

CASE_PHRASES = {
    "OOM": ["MEMORY_LIMIT", "monitor", "PID", "타임스탬프"],
    "CPU": ["CPU_MAX_OCCUPY", "Watchdog", "PID", "타임스탬프"],
    "Deadlock": ["MULTI_THREAD_ENABLE", "PID", "top -H", "ps -L"],
}


def validate(name: str, path: Path) -> list[str]:
    errors: list[str] = []
    if not path.is_file():
        return [f"missing report: {path.relative_to(ROOT)}"]

    text = path.read_text(encoding="utf-8")
    if not text.lstrip().startswith("# [Bug]"):
        errors.append("first heading must be GitHub Issue style '# [Bug] ...'")

    for heading in REQUIRED_HEADINGS:
        if heading not in text:
            errors.append(f"missing heading: {heading}")

    for phrase in REQUIRED_PHRASES + CASE_PHRASES[name]:
        if phrase not in text:
            errors.append(f"missing required marker: {phrase}")

    status_lines = [line.strip() for line in text.splitlines() if "Runtime status:" in line]
    if len(status_lines) != 1:
        errors.append("exactly one Runtime status line is required")
    elif "NEEDS-RUNTIME" not in status_lines[0] and "PASS" not in status_lines[0]:
        errors.append("Runtime status must be NEEDS-RUNTIME or PASS")

    return errors


def main() -> int:
    failed = False
    print("B1-2 static report validation")
    print("NOTE: this does not validate actual Linux runtime evidence.\n")

    for name, path in REPORTS.items():
        errors = validate(name, path)
        rel = path.relative_to(ROOT)
        if errors:
            failed = True
            print(f"[FAIL] {name}: {rel}")
            for error in errors:
                print(f"  - {error}")
        else:
            print(f"[PASS] {name}: {rel}")

    if failed:
        print("\nStatic contract validation FAILED.")
        return 1

    print("\nStatic contract validation PASSED.")
    print("Runtime/Evidence requirements remain separate and must be actually executed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
