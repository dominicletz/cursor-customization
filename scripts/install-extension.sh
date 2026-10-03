#!/usr/bin/env bash
# Package extensions/cursor-status as a .vsix and install it with the cursor CLI.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require node
require npx
require sqlite3
require cursor

EXT_SRC="$REPO_DIR/extensions/cursor-status"
OUT_DIR="$REPO_DIR/dist"
VSIX="$OUT_DIR/cursor-status.vsix"

mkdir -p "$OUT_DIR"
(cd "$EXT_SRC" && npx --yes @vscode/vsce package \
  --skip-license --allow-missing-repository --no-dependencies \
  --out "$VSIX")

# Remove an older manual copy so it does not clash with the packaged install.
rm -rf "$EXTENSIONS_DIR"/dominicletz.cursor-status-*

cursor --install-extension "$VSIX" --force
echo "Installed cursor-status. Reload the Cursor window to activate it."
