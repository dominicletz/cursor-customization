const { execFile } = require("child_process");
const { promisify } = require("util");
const path = require("path");
const os = require("os");
const vscode = require("vscode");

const execFileAsync = promisify(execFile);
const USAGE_URL = "https://cursor.com/api/usage-summary";
const SPEND_DASHBOARD = "https://cursor.com/dashboard/spending";
const REFRESH_MS = 5 * 60 * 1000;

function stateDbPath() {
  if (process.platform === "darwin") {
    return path.join(
      os.homedir(),
      "Library/Application Support/Cursor/User/globalStorage/state.vscdb"
    );
  }
  if (process.platform === "win32") {
    return path.join(
      process.env.APPDATA || "",
      "Cursor/User/globalStorage/state.vscdb"
    );
  }
  return path.join(
    os.homedir(),
    ".config/Cursor/User/globalStorage/state.vscdb"
  );
}

function decodeJwtPayload(token) {
  const part = token.split(".")[1];
  if (!part) {
    throw new Error("token has no payload");
  }
  const padded = part + "=".repeat((4 - (part.length % 4)) % 4);
  return JSON.parse(Buffer.from(padded, "base64url").toString("utf8"));
}

function sessionCookie(token) {
  const claims = decodeJwtPayload(token);
  const sub = String(claims.sub || "");
  const userId = sub.includes("|") ? sub.split("|").pop() : sub;
  return `${userId}%3A%3A${token}`;
}

async function readAccessToken() {
  const db = stateDbPath();
  const { stdout } = await execFileAsync("sqlite3", [
    db,
    "SELECT value FROM ItemTable WHERE key = 'cursorAuth/accessToken';",
  ]);
  const token = stdout.trim();
  if (!token) {
    throw new Error("no Cursor access token");
  }
  return token;
}

function pickPercents(data) {
  const plan = data?.individualUsage?.plan || data?.planUsage || {};
  const cursor = Number(plan.autoPercentUsed);
  const other = Number(plan.apiPercentUsed);
  if (!Number.isFinite(cursor) || !Number.isFinite(other)) {
    throw new Error("usage payload has no percents");
  }
  return { cursor, other, raw: data };
}

async function fetchUsage() {
  const token = await readAccessToken();
  const cookie = sessionCookie(token);
  const response = await fetch(USAGE_URL, {
    headers: {
      Cookie: `WorkosCursorSessionToken=${cookie}`,
      Origin: "https://cursor.com",
      Referer: "https://cursor.com/dashboard",
      "User-Agent":
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    },
  });
  if (!response.ok) {
    throw new Error(`usage HTTP ${response.status}`);
  }
  return pickPercents(await response.json());
}

function formatPct(n) {
  return `${Math.round(n)}%`;
}

function activate(context) {
  const item = vscode.window.createStatusBarItem(
    "cursorStatus.spend",
    vscode.StatusBarAlignment.Right,
    100
  );
  item.name = "Cursor / Other spend";
  item.command = "cursorStatus.openSpend";
  item.text = "Cursor/Other …";
  item.tooltip = "Cursor model spend vs Other model spend";
  item.show();

  const refresh = async () => {
    try {
      const usage = await fetchUsage();
      item.text = `Cursor/Other ${formatPct(usage.cursor)}/${formatPct(usage.other)}`;
      const messages = [];
      const autoMsg = usage.raw?.autoModelSelectedDisplayMessage;
      const namedMsg = usage.raw?.namedModelSelectedDisplayMessage;
      if (autoMsg) {
        messages.push(autoMsg);
      }
      if (namedMsg) {
        messages.push(namedMsg);
      }
      messages.push("Click to open the Spending dashboard.");
      item.tooltip = messages.join("\n");
      item.backgroundColor = undefined;
    } catch (err) {
      item.text = "Cursor/Other ?";
      item.tooltip = `Could not load spend: ${err.message}`;
    }
  };

  context.subscriptions.push(
    item,
    vscode.commands.registerCommand("cursorStatus.refreshSpend", refresh),
    vscode.commands.registerCommand("cursorStatus.openSpend", () => {
      vscode.env.openExternal(vscode.Uri.parse(SPEND_DASHBOARD));
    })
  );

  refresh();
  const timer = setInterval(refresh, REFRESH_MS);
  context.subscriptions.push({ dispose: () => clearInterval(timer) });
}

function deactivate() {}

module.exports = { activate, deactivate };
