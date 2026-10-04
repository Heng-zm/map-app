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
        proc = subprocess.run(
            ["xcrun", "xcresulttool", "get", "--path", str(xcresult_path), "--format", "json"],
            capture_output=True,
            text=True
        )
        if proc.returncode != 0 or not proc.stdout.strip():
            print("xcresulttool invocation failed:", proc.stderr)
            return

        data = json.loads(proc.stdout)
        failures = data.get("issues", {}).get("testFailureSummaries", {}).get("_values", [])
        
        if failures:
            print(f"\n================ FOUND {len(failures)} TEST FAILURE(S) ================")
            for idx, f in enumerate(failures, 1):
                name = f.get("testCaseName", {}).get("_value", "Unknown Test")
                msg = f.get("message", {}).get("_value", "No error message provided")
                doc = f.get("documentLocationInCreatingWorkspace", {}).get("url", {}).get("_value", "")
                print(f"[{idx}] {name}")
                print(f"    Message:  {msg}")
                if doc:
                    print(f"    Location: {doc}")
            print("=================================================================\n")
        else:
            print("No testFailureSummaries found in root summary. The failure may be a compilation or setup error.")
    except Exception as e:
        print("Failed to parse TestResults.xcresult:", e)

if __name__ == "__main__":
    main()
