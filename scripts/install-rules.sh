#!/usr/bin/env bash
# Copy the user-level rules from rules/*.mdc to ~/.cursor/rules.
# An existing file with different content is saved as <name>.bak first.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

mkdir -p "$RULES_DIR"

for src in "$REPO_DIR"/rules/*.mdc; do
  dest="$RULES_DIR/$(basename "$src")"
  if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
    echo "Unchanged: $dest"
    continue
  fi
  [ -f "$dest" ] && cp "$dest" "$dest.bak" && echo "Backup:    $dest.bak"
  cp "$src" "$dest"
  echo "Installed: $dest"
done
