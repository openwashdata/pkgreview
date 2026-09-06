#!/usr/bin/env python3
"""Em dash and emoji check over tracked text files (part of scripts/lint.sh)."""
import re
import subprocess
import sys

files = subprocess.run(
    ["git", "ls-files", "*.md", "*.R", "*.sh", "*.py", "*.yml", "*.yaml", "*.json", "*.Rmd"],
    capture_output=True, text=True, check=True,
).stdout.split()
pattern = re.compile("[\\u2014\\U0001F300-\\U0001FAFF\\u2600-\\u27BF]")
bad = 0
for path in files:
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            for number, line in enumerate(fh, 1):
                if pattern.search(line):
                    print(f"lint: em dash or emoji: {path}:{number}: {line.strip()[:80]}")
                    bad = 1
    except OSError:
        pass
sys.exit(bad)
