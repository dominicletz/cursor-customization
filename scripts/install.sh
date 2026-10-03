#!/usr/bin/env bash
# Install all customizations: settings, hidden status items, extension.
# Usage: scripts/install.sh [--skip-hide] [--skip-extension] [--skip-settings] [--skip-rules]
set -euo pipefail
HERE="$(dirname "${BASH_SOURCE[0]}")"
source "$HERE/lib.sh"

skip_hide=0; skip_ext=0; skip_settings=0; skip_rules=0
for arg in "$@"; do
  case "$arg" in
    --skip-hide) skip_hide=1 ;;
    --skip-extension) skip_ext=1 ;;
    --skip-settings) skip_settings=1 ;;
    --skip-rules) skip_rules=1 ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

if [ "$skip_settings" -eq 0 ]; then
  python3 "$HERE/apply_settings.py"
fi

if [ "$skip_rules" -eq 0 ]; then
  "$HERE/install-rules.sh"
fi

if [ "$skip_hide" -eq 0 ]; then
  if cursor_is_running; then
    echo "Cursor is running. Quit Cursor, then run:" >&2
    echo "  scripts/hide-status-items.sh" >&2
    echo "Or hide the items by hand: right-click the status bar." >&2
  else
    "$HERE/hide-status-items.sh"
  fi
fi

if [ "$skip_ext" -eq 0 ]; then
  "$HERE/install-extension.sh"
fi

echo "Done. Start Cursor, or run 'Developer: Reload Window'."
