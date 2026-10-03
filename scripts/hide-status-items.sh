#!/usr/bin/env bash
# Hide (or with --show, restore) built-in status bar items. Quit Cursor first.
# Usage: scripts/hide-status-items.sh [--show] [item-id ...]
set -euo pipefail
HERE="$(dirname "${BASH_SOURCE[0]}")"
source "$HERE/lib.sh"
require python3

if cursor_is_running; then
  echo "Cursor is running. Quit Cursor first, or Cursor can undo this change." >&2
  exit 1
fi

python3 "$HERE/hide_status_items.py" "$@"
