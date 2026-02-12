#!/usr/bin/env bash
set -euo pipefail

BASE="/root/linkbot/skills/shared/web-research"
DIST_ENTRY="$BASE/dist/index.js"

# Fallback: resolve Brave key from OpenClaw runtime config when env is not pre-set.
if [[ -z "${BRAVE_API_KEY:-}" ]] && [[ -x "/root/openclaw-bot/openclaw.mjs" ]]; then
  BRAVE_API_KEY="$(
    /root/openclaw-bot/openclaw.mjs config get tools.web.search.apiKey --json 2>/dev/null \
      | tr -d '"' \
      | tr -d '\r' \
      | tr -d '\n'
  )"
  export BRAVE_API_KEY
fi

if [[ -z "${BRAVE_API_KEY:-}" ]]; then
  echo "[web-research-mcp] BRAVE_API_KEY is required (env or OpenClaw config)." >&2
  exit 1
fi

if [[ ! -f "$DIST_ENTRY" ]]; then
  cd "$BASE"
  npm install --no-audit --no-fund >/tmp/web-research-npm-install.log 2>&1
  npm run build >/tmp/web-research-build.log 2>&1
fi

exec /usr/bin/node "$DIST_ENTRY" --transport stdio
