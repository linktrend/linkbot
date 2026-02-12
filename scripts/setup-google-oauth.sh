#!/bin/bash
#
# Unified Google Workspace OAuth setup for LiNKbot MCP servers.
# Runs the VPS-friendly helper that writes token files for:
# - google-docs
# - google-sheets
# - google-slides (future use)
# - gmail-integration
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HELPER="$SCRIPT_DIR/vps-google-auth.py"

if [[ ! -f "$HELPER" ]]; then
  echo "ERROR: Missing helper script: $HELPER" >&2
  exit 1
fi

if [[ "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Usage:
  ./scripts/setup-google-oauth.sh [--reset] [--credentials /path/to/credentials.json]

Examples:
  ./scripts/setup-google-oauth.sh --reset
  ./scripts/setup-google-oauth.sh --credentials /root/linkbot/skills/shared/google-docs/credentials.json
EOF
  exit 0
fi

python3 "$HELPER" "$@"
