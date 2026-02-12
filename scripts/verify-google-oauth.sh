#!/bin/bash
# Verify Google Workspace MCP OAuth readiness on VPS.

set -euo pipefail

VPS_IP="${VPS_IP:-178.128.77.125}"
VPS_USER="${VPS_USER:-root}"
REMOTE="${VPS_USER}@${VPS_IP}"

echo "=========================================="
echo "Google Workspace MCP OAuth Verification"
echo "Target: ${REMOTE}"
echo "=========================================="
echo

echo "1) Checking token artifacts..."
ssh "$REMOTE" '
for f in \
  /root/linkbot/skills/shared/google-docs/token.json \
  /root/linkbot/skills/shared/google-sheets/token.json \
  /root/linkbot/skills/shared/google-slides/token.json \
  /root/linkbot/skills/shared/gmail-integration/tokens.json \
  /root/gmail_mcp_tokens/tokens.json; do
  if [ -f "$f" ]; then
    echo "  ✅ $f"
  else
    echo "  ❌ $f"
  fi
done
'
echo

echo "2) Checking MCP server registration..."
ssh "$REMOTE" 'mcporter --config /root/linkbot/config/mcporter.json list || true'
echo

echo "3) Checking OpenClaw service state..."
if ssh "$REMOTE" "systemctl is-active openclaw" | grep -q "active"; then
  echo "  ✅ openclaw is active"
else
  echo "  ❌ openclaw is not active"
fi
echo

echo "4) Optional schema checks (non-destructive)..."
ssh "$REMOTE" '
mcporter --config /root/linkbot/config/mcporter.json list google-docs --schema >/dev/null 2>&1 \
  && echo "  ✅ google-docs schema reachable" \
  || echo "  ⚠️  google-docs schema check failed"

mcporter --config /root/linkbot/config/mcporter.json list google-sheets --schema >/dev/null 2>&1 \
  && echo "  ✅ google-sheets schema reachable" \
  || echo "  ⚠️  google-sheets schema check failed"

mcporter --config /root/linkbot/config/mcporter.json list gmail-integration --schema >/dev/null 2>&1 \
  && echo "  ✅ gmail-integration schema reachable" \
  || echo "  ⚠️  gmail-integration schema check failed"
'
echo

echo "Verification complete."
