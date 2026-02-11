#!/bin/bash
# Lisa Bot Deployment Script
# Deploys configuration changes from local to VPS

set -e

VPS_HOST="root@178.128.77.125"
VPS_DIR="/root/openclaw-bot"
OPENCLAW_DIR="/root/.openclaw"

echo "🚀 Deploying Lisa Bot to VPS..."

# Step 1: Pull latest code from GitHub
echo "📥 Pulling latest code from GitHub..."
ssh $VPS_HOST "cd $VPS_DIR && git pull origin main"

# Step 2: Install/update dependencies if package.json changed
echo "📦 Checking for dependency updates..."
ssh $VPS_HOST "cd $VPS_DIR && npm install"

# Step 3: Build OpenClaw if source changed
echo "🔨 Building OpenClaw..."
ssh $VPS_HOST "cd $VPS_DIR && npm run build"

# Step 4: Copy openclaw.json to runtime directory
echo "⚙️  Updating runtime configuration..."
ssh $VPS_HOST "cd $VPS_DIR && ./openclaw.mjs doctor --fix"

# Step 5: Deploy exec-approvals.json with correct allowlist format
# OpenClaw requires full paths in agents.*.allowlist[].pattern
echo "🔐 Deploying exec approvals..."
ssh $VPS_HOST "cp $VPS_DIR/config/lisa/exec-approvals.json $OPENCLAW_DIR/exec-approvals.json"

# Step 6: Restart OpenClaw service
echo "🔄 Restarting OpenClaw..."
ssh $VPS_HOST "systemctl restart openclaw"

# Step 7: Wait and check status
echo "⏳ Waiting for service to start..."
sleep 5

echo "✅ Checking service status..."
ssh $VPS_HOST "systemctl status openclaw --no-pager | head -15"

echo ""
echo "🎉 Deployment complete!"
echo "📊 View logs: ssh $VPS_HOST 'journalctl -u openclaw -f'"
echo "🌐 Access UI: ssh -L 18789:localhost:18789 $VPS_HOST"
