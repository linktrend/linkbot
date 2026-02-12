#!/usr/bin/env bash
set -euo pipefail

BASE="/root/linkbot/skills/shared/google-slides"
CREDENTIALS_FILE="$BASE/credentials.json"
TOKEN_FILE="$BASE/token.json"
BUILD_ENTRY="$BASE/build/index.js"

if [[ ! -f "$CREDENTIALS_FILE" ]]; then
  echo "[google-slides-mcp] Missing credentials file: $CREDENTIALS_FILE" >&2
  exit 1
fi

if [[ ! -f "$TOKEN_FILE" ]]; then
  echo "[google-slides-mcp] Missing token file: $TOKEN_FILE" >&2
  exit 1
fi

if [[ ! -f "$BUILD_ENTRY" ]]; then
  cd "$BASE"
  npm install --no-audit --no-fund >/tmp/google-slides-npm-install.log 2>&1
  npm run build >/tmp/google-slides-build.log 2>&1
fi

export GOOGLE_CLIENT_ID="$(
  python3 - "$CREDENTIALS_FILE" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path))
client = data.get("installed") or data.get("web") or {}
print(client.get("client_id", ""))
PY
)"

export GOOGLE_CLIENT_SECRET="$(
  python3 - "$CREDENTIALS_FILE" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path))
client = data.get("installed") or data.get("web") or {}
print(client.get("client_secret", ""))
PY
)"

export GOOGLE_REFRESH_TOKEN="$(
  python3 - "$TOKEN_FILE" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path))
print(data.get("refresh_token", ""))
PY
)"

if [[ -z "${GOOGLE_CLIENT_ID:-}" || -z "${GOOGLE_CLIENT_SECRET:-}" || -z "${GOOGLE_REFRESH_TOKEN:-}" ]]; then
  echo "[google-slides-mcp] Missing GOOGLE_CLIENT_ID/GOOGLE_CLIENT_SECRET/GOOGLE_REFRESH_TOKEN values." >&2
  exit 1
fi

exec /usr/bin/node "$BUILD_ENTRY"
