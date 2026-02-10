#!/bin/bash
# Verification script for Google Workspace OAuth setup
# Run this AFTER completing the OAuth flow

set -e

VPS_IP="178.128.77.125"
VPS_USER="root"
GOOGLE_ACCOUNT="info@linktrend.media"

echo "=========================================="
echo "Google Workspace OAuth Verification"
echo "=========================================="
echo ""

# Check 1: Authentication
echo "✓ Checking authenticated accounts..."
ssh ${VPS_USER}@${VPS_IP} "gog auth list" | grep -q "${GOOGLE_ACCOUNT}" && \
  echo "  ✅ ${GOOGLE_ACCOUNT} is authenticated" || \
  echo "  ❌ ${GOOGLE_ACCOUNT} NOT authenticated"
echo ""

# Check 2: Gmail
echo "✓ Testing Gmail access..."
if ssh ${VPS_USER}@${VPS_IP} "gog gmail list --account ${GOOGLE_ACCOUNT} --max 1 --json" &>/dev/null; then
  echo "  ✅ Gmail access working"
else
  echo "  ❌ Gmail access failed"
fi
echo ""

# Check 3: Calendar
echo "✓ Testing Calendar access..."
if ssh ${VPS_USER}@${VPS_IP} "gog calendar list-calendars --account ${GOOGLE_ACCOUNT} --json" &>/dev/null; then
  echo "  ✅ Calendar access working"
else
  echo "  ❌ Calendar access failed"
fi
echo ""

# Check 4: Drive
echo "✓ Testing Drive access..."
if ssh ${VPS_USER}@${VPS_IP} "gog drive list --account ${GOOGLE_ACCOUNT} --max 1 --json" &>/dev/null; then
  echo "  ✅ Drive access working"
else
  echo "  ❌ Drive access failed"
fi
echo ""

# Check 5: Contacts
echo "✓ Testing Contacts access..."
if ssh ${VPS_USER}@${VPS_IP} "gog contacts list --account ${GOOGLE_ACCOUNT} --max 1 --json" &>/dev/null; then
  echo "  ✅ Contacts access working"
else
  echo "  ❌ Contacts access failed"
fi
echo ""

# Check 6: OpenClaw Service
echo "✓ Checking OpenClaw service..."
if ssh ${VPS_USER}@${VPS_IP} "sudo systemctl is-active openclaw" | grep -q "active"; then
  echo "  ✅ OpenClaw service running"
else
  echo "  ❌ OpenClaw service not running"
fi
echo ""

# Check 7: gog skill status
echo "✓ Checking gog skill status..."
if ssh ${VPS_USER}@${VPS_IP} "cd /root/openclaw-bot && node openclaw.mjs skills list" | grep -q "✓ ready.*gog"; then
  echo "  ✅ gog skill is READY"
else
  echo "  ⚠️  gog skill not ready (may need OpenClaw restart)"
fi
echo ""

# Check 8: Token details
echo "✓ Checking token details..."
ssh ${VPS_USER}@${VPS_IP} "gog auth tokens list ${GOOGLE_ACCOUNT} 2>/dev/null" || echo "  ℹ️  Token details not available"
echo ""

# Summary
echo "=========================================="
echo "Verification Complete"
echo "=========================================="
echo ""
echo "If all checks passed (✅), Google Workspace is fully configured!"
echo ""
echo "Next steps:"
echo "  1. Test via Telegram: 'Check my Gmail inbox'"
echo "  2. Test via Telegram: 'What's on my calendar today?'"
echo "  3. Test via Telegram: 'List my recent Drive files'"
echo ""
