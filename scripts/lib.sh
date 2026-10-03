#!/usr/bin/env bash
# Shared paths for the install scripts. Source this file; do not run it.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "$(uname -s)" in
  Darwin) CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User" ;;
  Linux)  CURSOR_USER_DIR="$HOME/.config/Cursor/User" ;;
  *)      echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

SETTINGS_FILE="$CURSOR_USER_DIR/settings.json"
STATE_DB="$CURSOR_USER_DIR/globalStorage/state.vscdb"
EXTENSIONS_DIR="$HOME/.cursor/extensions"
RULES_DIR="$HOME/.cursor/rules"

export REPO_DIR CURSOR_USER_DIR SETTINGS_FILE STATE_DB EXTENSIONS_DIR RULES_DIR

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing tool: $1" >&2; exit 1; }
}

cursor_is_running() {
  pgrep -x "Cursor" >/dev/null 2>&1 || pgrep -f "Cursor.app/Contents/MacOS/Cursor" >/dev/null 2>&1
}
