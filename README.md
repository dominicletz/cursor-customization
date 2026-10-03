# cursor-customization

Personal customizations for the Cursor IDE status bar.

## What it does

Cursor shows three AI items in the status bar by default:

- `Tab Stats`
- `Agent Stats`
- the last commit, for example `5495ac6 100.00% AI`

This repo replaces them with:

- `Cursor/Other 17%/23%` — share of your included usage that you used on Cursor models and on Other models
- git blame for the current line, for example `Name (3 hours ago)`

## Contents

| Path | Purpose |
|------|---------|
| `extensions/cursor-status/` | Small extension. It adds the `Cursor/Other` status bar item. |
| `settings/settings.snippet.json` | Settings that turn on current-line git blame. |
| `scripts/install.sh` | Does all steps below in one run. |
| `scripts/apply_settings.py` | Merges the settings snippet into `settings.json`. |
| `scripts/hide-status-items.sh` | Hides (or restores) the built-in AI status items. |
| `scripts/install-extension.sh` | Packages and installs the extension. |

## Requirements

- macOS or Linux
- Cursor, with the `cursor` command on your `PATH`
  (Command Palette → `Shell Command: Install 'cursor' command`)
- `node` and `npx` (to package the extension)
- `sqlite3` and `python3`

## Quick install

1. Quit Cursor.
2. Run:

   ```bash
   git clone https://github.com/dominicletz/cursor-customization.git
   cd cursor-customization
   scripts/install.sh
   ```

3. Start Cursor.

If Cursor is still running, `install.sh` skips the hide step and tells you.
Cursor can undo the hide step when it quits. Quit Cursor, then run
`scripts/hide-status-items.sh`.

Options for `install.sh`: `--skip-settings`, `--skip-hide`, `--skip-extension`.

## Manual install

Use these steps if you do not want to run the scripts.

### 1. Hide the built-in items

Right-click the status bar. Clear the check marks for these items:

- `AI Code Tracking Stats - Tab`
- `AI Code Tracking Stats - Agent`
- `AI Code Tracking - Recent Commit`

Cursor stores the hidden item ids in `state.vscdb` under the key
`workbench.statusbar.hidden`. The ids are:

```json
["aiCodeTracking.stats.tab", "aiCodeTracking.stats.composer", "aiCodeTracking.stats.recentCommit"]
```

To restore the items, run `scripts/hide-status-items.sh --show`
(with Cursor closed), or tick them again in the status bar menu.

### 2. Turn on git blame for the current line

Add the keys from `settings/settings.snippet.json` to your user `settings.json`:

| OS | Path |
|----|------|
| macOS | `~/Library/Application Support/Cursor/User/settings.json` |
| Linux | `~/.config/Cursor/User/settings.json` |

`git.blame.*` keys belong to the built-in git extension.
`gitblame.statusBarMessageFormat` applies only if you also install the
Git Blame extension (`waderyan.gitblame`). If you use both, hide one of the
two blame items.

Change `git.blame.statusBarItem.template` to change the text. Open Settings and
search for `git.blame` to see the template variables.

### 3. Install the extension

```bash
cd extensions/cursor-status
npx @vscode/vsce package --skip-license --allow-missing-repository --no-dependencies
cursor --install-extension cursor-status-0.0.1.vsix
```

Or use the Command Palette: `Extensions: Install from VSIX...`.

Then run `Developer: Reload Window`.

## How the `Cursor/Other` numbers work

The extension reads your Cursor sign-in token from the local Cursor state database
with the `sqlite3` command. It sends the token only to `https://cursor.com`, to
`/api/usage-summary`. The token is never written to a file or a log.

The response has two values:

- `autoPercentUsed` — the **Cursor Models** pool (Cursor Grok, Composer)
- `apiPercentUsed` — the **Other Models** pool (third-party models)

The status bar shows them as `Cursor/Other <auto>%/<api>%`.
It refreshes every 5 minutes. Hover to see the full messages.
Click it to open the [Spending dashboard](https://cursor.com/dashboard/spending).

Commands:

- `Cursor Status: Refresh spend`
- `Cursor Status: Open Spending dashboard`

## Limits

- `/api/usage-summary` is not a documented API. Cursor can change it at any time.
  If the item shows `Cursor/Other ?`, hover to see the error.
- The extension needs a signed-in Cursor app.
- Team and Enterprise accounts can have different response fields.
- Cursor can say "Please restart VS Code before reinstalling" if you reinstall an
  extension while Cursor runs. Quit Cursor, then run
  `scripts/install-extension.sh` again.

## Uninstall

```bash
cursor --uninstall-extension dominicletz.cursor-status
scripts/hide-status-items.sh --show
```

Then remove the keys from `settings/settings.snippet.json` in your `settings.json`.

## License

MIT
