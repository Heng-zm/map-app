#!/usr/bin/env python3
"""
parse-test-failures.py
Extracts and prints detailed test failures from an Xcode .xcresult bundle.
"""

import json
import subprocess
import sys
from pathlib import Path

def main():
    xcresult_path = Path("build/TestResults.xcresult")
    if not xcresult_path.exists():
        print(f"Notice: Result bundle not found at {xcresult_path}")
        return

    try:
        # Xcode 16 requires --legacy for 'get --format json', while Xcode 15 does not support it
        proc = subprocess.run(
            ["xcrun", "xcresulttool", "get", "--path", str(xcresult_path), "--format", "json", "--legacy"],
            capture_output=True,
            text=True
        )
        if proc.returncode != 0 or not proc.stdout.strip():
            proc = subprocess.run(
                ["xcrun", "xcresulttool", "get", "--path", str(xcresult_path), "--format", "json"],
                capture_output=True,
                text=True
            )
            
        data = None
        if proc.returncode == 0 and proc.stdout.strip():
            try:
                data = json.loads(proc.stdout)
            except Exception:
                pass

        has_output = False
        if data:
            issues = data.get("issues", {})
            test_failures = issues.get("testFailureSummaries", {}).get("_values", [])
            build_errors = issues.get("errorSummaries", {}).get("_values", [])
            
            if build_errors:
                has_output = True
                print(f"\n================ FOUND {len(build_errors)} BUILD / COMPILER ERROR(S) ================")
                for idx, err in enumerate(build_errors, 1):
                    msg = err.get("message", {}).get("_value", "No error message")
                    doc = err.get("documentLocationInCreatingWorkspace", {}).get("url", {}).get("_value", "")
                    print(f"[{idx}] Compiler Error:")
                    print(f"    Message:  {msg}")
                    if doc:
                        print(f"    Location: {doc}")
                print("=======================================================================\n")
                
            if test_failures:
                has_output = True
                print(f"\n================ FOUND {len(test_failures)} TEST FAILURE(S) ================")
                for idx, f in enumerate(test_failures, 1):
                    name = f.get("testCaseName", {}).get("_value", "Unknown Test")
                    msg = f.get("message", {}).get("_value", "No error message provided")
                    doc = f.get("documentLocationInCreatingWorkspace", {}).get("url", {}).get("_value", "")
                    print(f"[{idx}] {name}")
                    print(f"    Message:  {msg}")
                    if doc:
                        print(f"    Location: {doc}")
                print("=================================================================\n")

        # Fallback to xcodebuild.log if available and no errors found in xcresult
        log_file = Path("xcodebuild.log")
        if not has_output and log_file.exists():
            log_text = log_file.read_text(encoding="utf-8", errors="replace")
            error_lines = [
                line for line in log_text.splitlines()
                if "error:" in line or "fatal error:" in line or "** TEST FAILED **" in line
            ]
            if error_lines:
                print(f"\n================ ERRORS FROM xcodebuild.log ({len(error_lines)} lines) ================")
                for line in error_lines[:30]:
                    print("  " + line.strip())
                print("=====================================================================\n")
                has_output = True

        if not has_output:
            print("No testFailureSummaries or errorSummaries found in xcresult root.")
    except Exception as e:
        print("Failed to parse TestResults.xcresult:", e)

if __name__ == "__main__":
    main()
