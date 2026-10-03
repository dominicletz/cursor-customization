#!/usr/bin/env python3
"""Hide built-in Cursor status bar items by id.

Cursor keeps the list of hidden items in state.vscdb (ItemTable key
"workbench.statusbar.hidden"). Close Cursor before you run this script,
or Cursor can overwrite the change when it quits.

Usage: hide_status_items.py [--show] [item-id ...]
Default ids: Tab Stats, Agent Stats, and the recent-commit AI percent.
--show removes the ids from the hidden list again.
"""
import json
import os
import sqlite3
import sys

KEY = "workbench.statusbar.hidden"
DEFAULT_IDS = [
    "aiCodeTracking.stats.tab",
    "aiCodeTracking.stats.composer",
    "aiCodeTracking.stats.recentCommit",
]

args = sys.argv[1:]
show = "--show" in args
ids = [a for a in args if not a.startswith("--")] or DEFAULT_IDS

db_path = os.environ["STATE_DB"]
if not os.path.exists(db_path):
    sys.exit(f"State database not found: {db_path}")

con = sqlite3.connect(db_path)
row = con.execute("SELECT value FROM ItemTable WHERE key = ?", (KEY,)).fetchone()
hidden = json.loads(row[0]) if row and row[0] else []

if show:
    hidden = [h for h in hidden if h not in ids]
else:
    hidden += [i for i in ids if i not in hidden]

con.execute(
    "INSERT INTO ItemTable(key, value) VALUES(?, ?) "
    "ON CONFLICT(key) DO UPDATE SET value = excluded.value",
    (KEY, json.dumps(hidden)),
)
con.commit()
con.close()
print(f"{KEY} = {hidden}")
