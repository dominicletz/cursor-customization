#!/usr/bin/env python3
"""Merge settings/settings.snippet.json into the Cursor user settings.json.

Existing keys stay. Keys from the snippet are added or overwritten.
If settings.json has comments (JSONC), the script stops and prints the
snippet so you can paste it by hand.
"""
import json
import os
import sys
from pathlib import Path

snippet_path = Path(os.environ["REPO_DIR"]) / "settings" / "settings.snippet.json"
settings_path = Path(os.environ["SETTINGS_FILE"])

snippet = json.loads(snippet_path.read_text())

if settings_path.exists() and settings_path.read_text().strip():
    try:
        current = json.loads(settings_path.read_text())
    except json.JSONDecodeError:
        print(f"{settings_path} has comments or invalid JSON.", file=sys.stderr)
        print("Add these keys by hand:\n", file=sys.stderr)
        print(snippet_path.read_text(), file=sys.stderr)
        sys.exit(1)
else:
    current = {}

current.update(snippet)
settings_path.parent.mkdir(parents=True, exist_ok=True)
settings_path.write_text(json.dumps(current, indent=4) + "\n")
print(f"Updated {settings_path}")
