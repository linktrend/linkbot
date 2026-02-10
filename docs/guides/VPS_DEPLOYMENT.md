# VPS Deployment Guide - Business Partner Bot

## Overview

This guide walks you through deploying OpenClaw to your DigitalOcean VPS with full security hardening. We're using **manual installation** on your existing droplet for maximum control and cost savings.

**Estimated Time**: 3-4 hours  
**Prerequisites**: API keys obtained and stored locally in `.env` file

---

## Phase 1: Pre-Deployment Checks (15 minutes)

### 1.1 Verify Local Configuration

```bash
# Navigate to config directory
cd /Users/linktrend/Projects/LiNKbot/bots/business-partner/config/business-partner

# Verify all required files exist
ls -la openclaw.json .env verify-config.sh

# Verify .env permissions (should be 600)
ls -la .env | grep -- "-rw-------"

# Run verification script
chmod +x verify-config.sh
./verify-config.sh
```

**Expected Output**: All checks should PASS or show clear warnings to address.

---

### 1.2 Check DigitalOcean Droplet Specifications

**OpenClaw Minimum Requirements**:
- **CPU**: 2 vCPUs (recommended 4 for multiple bots)
- **RAM**: 4 GB minimum (8 GB recommended)
- **Storage**: 25 GB SSD minimum (50 GB recommended)
- **OS**: Ubuntu 22.04 LTS or 24.04 LTS

**Check your current droplet**:
1. Log in to DigitalOcean Dashboard: https://cloud.digitalocean.com/
2. Navigate to "Droplets"
3. Check current specs

**If upsizing needed**:
1. Select droplet → "Resize"
2. Choose plan (e.g., "Basic" → $24/month for 4GB RAM)
3. Click "Resize Droplet" (causes 1-2 min downtime)

---

### 1.3 Gather Connection Information

You'll need:
- Droplet IP address: `_______________`
- SSH key configured: Yes / No
- Root password (if no SSH key): `_______________`

---

## Phase 2: SSH Security Hardening (30 minutes)

### 2.1 Generate SSH Key (if not already done)

**On your Mac**:
```bash
# Check if SSH key already exists
ls -la ~/.ssh/id_ed25519.pub

# If not, generate new key
ssh-keygen -t ed25519 -C "linkbot-vps-access"
# Press Enter for default location
# Set a strong passphrase when prompted

# Display public key
cat ~/.ssh/id_ed25519.pub
```

**Copy the public key** (entire line starting with `ssh-ed25519 ...`)

---

### 2.2 Add SSH Key to DigitalOcean Droplet

**Method A: Via DigitalOcean Dashboard**:
1. Go to: https://cloud.digitalocean.com/account/security
2. Click "Add SSH Key"
3. Paste your public key
4. Name it: "MacBook - LiNKbot Access"
5. Click "Add SSH Key"

**Method B: Manually on droplet**:
```bash
# SSH into droplet with password
ssh root@YOUR_DROPLET_IP

# Create .ssh directory if needed
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add your public key
echo "ssh-ed25519 YOUR_PUBLIC_KEY linkbot-vps-access" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Exit
exit
```

---

### 2.3 Test SSH Key Authentication

```bash
# Test connection with SSH key
ssh root@YOUR_DROPLET_IP

# Should connect without password prompt
```

If successful, you'll see the Ubuntu welcome message.

---

### 2.4 Disable Password Authentication

**Critical security step**: Once SSH key works, disable password login.

```bash
# SSH into droplet
ssh root@YOUR_DROPLET_IP

# Backup SSH config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Find and change these lines:
#   PasswordAuthentication yes  →  PasswordAuthentication no
#   PubkeyAuthentication yes    →  PubkeyAuthentication yes
#   PermitRootLogin yes         →  PermitRootLogin prohibit-password

# Save: Ctrl+O, Enter, Ctrl+X

# Restart SSH service
sudo systemctl restart sshd

# Verify config
sudo sshd -t
```

**⚠️ IMPORTANT**: Keep your current SSH session open! Test new connection in a separate terminal before closing.

```bash
# In NEW terminal window, test connection
ssh root@YOUR_DROPLET_IP
# Should still work with SSH key
```

---

## Phase 3: Firewall Configuration (20 minutes)

### 3.1 Set Up UFW (Uncomplicated Firewall)

```bash
# SSH into droplet
ssh root@YOUR_DROPLET_IP

# Install UFW if not present
sudo apt update
sudo apt install -y ufw

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (CRITICAL - do this first!)
sudo ufw allow 22/tcp comment 'SSH access'

# Allow OpenClaw gateway ONLY from your IP
# Replace YOUR_HOME_IP with your actual IP (find at: https://whatismyip.com)
sudo ufw allow from YOUR_HOME_IP to any port 18789 proto tcp comment 'OpenClaw gateway - home IP only'

# Enable firewall
sudo ufw enable
# Type 'y' when prompted

# Verify firewall status
sudo ufw status verbose
```

**Expected Output**:
```
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere                  # SSH access
18789/tcp                  ALLOW       YOUR_HOME_IP              # OpenClaw gateway - home IP only
```

---

### 3.2 Add Additional Trusted IPs (Optional)

If you work from multiple locations:

```bash
# Add office IP
sudo ufw allow from OFFICE_IP to any port 18789 proto tcp comment 'OpenClaw - office IP'

# Add mobile hotspot IP (if static)
sudo ufw allow from MOBILE_IP to any port 18789 proto tcp comment 'OpenClaw - mobile IP'

# Verify
sudo ufw status numbered
```

---

### 3.3 Save Firewall Rules

```bash
# Rules are auto-saved by UFW
# Verify they persist across reboot
sudo ufw reload

# Check status
sudo ufw status
```

---

## Phase 4: Install Node.js & Dependencies (20 minutes)

### 4.1 Install Node.js 20 LTS

```bash
# SSH into droplet
ssh root@YOUR_DROPLET_IP

# Install Node.js 20 (OpenClaw requires 20+)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version  # Should show v20.x.x
npm --version   # Should show 10.x.x

# Install build tools
sudo apt-get install -y build-essential git
```

---

### 4.2 Install Global NPM Packages

```bash
# Install OpenClaw globally
sudo npm install -g openclaw@latest

# Verify installation
openclaw version

# Expected output: openclaw 2026.2.x or later
```

---

## Phase 5: Deploy OpenClaw Configuration (30 minutes)

### 5.1 Create OpenClaw Directory Structure

```bash
# SSH into droplet
ssh root@YOUR_DROPLET_IP

# Create OpenClaw home directory
mkdir -p ~/.openclaw/workspace
mkdir -p ~/.openclaw/skills
mkdir -p ~/.openclaw/logs

# Verify structure
ls -la ~/.openclaw/
```

---

### 5.2 Transfer Configuration Files from Mac to VPS

**On your Mac** (in new terminal):

```bash
# Navigate to config directory
cd /Users/linktrend/Projects/LiNKbot/bots/business-partner/config/business-partner

# Transfer openclaw.json
scp openclaw.json root@YOUR_DROPLET_IP:~/.openclaw/openclaw.json

# Transfer .env (contains secrets)
scp .env root@YOUR_DROPLET_IP:~/.openclaw/.env

# Transfer IDENTITY.md (bot persona)
scp /Users/linktrend/Projects/LiNKbot/config/business-partner/workspace/IDENTITY.md root@YOUR_DROPLET_IP:~/.openclaw/workspace/IDENTITY.md

# Transfer SOUL.md (operational doctrine)
scp /Users/linktrend/Projects/LiNKbot/config/business-partner/workspace/SOUL.md root@YOUR_DROPLET_IP:~/.openclaw/workspace/SOUL.md

# Transfer USER.md (if exists)
scp /Users/linktrend/Projects/LiNKbot/config/business-partner/workspace/USER.md root@YOUR_DROPLET_IP:~/.openclaw/workspace/USER.md 2>/dev/null || echo "USER.md not found, skipping"
```

---

### 5.3 Secure Configuration Files on VPS

**Back on VPS SSH session**:

```bash
# Set strict permissions on .env (owner read/write only)
chmod 600 ~/.openclaw/.env

# Set permissions on other config files
chmod 644 ~/.openclaw/openclaw.json
chmod 644 ~/.openclaw/workspace/*.md

# Verify permissions
ls -la ~/.openclaw/.env | grep -- "-rw-------"
ls -la ~/.openclaw/
```

**Expected**: `.env` should show `-rw-------` (600)

---

### 5.4 Verify Configuration

```bash
# Test OpenClaw configuration
openclaw doctor

# Expected output: Should check configuration and report any issues
```

**Common issues**:
- **"Missing API key"**: Check `.env` file has all required keys
- **"Invalid JSON"**: Check `openclaw.json` syntax
- **"Model not available"**: Verify API keys are correct

---

## Phase 6: Set Up Systemd Service (20 minutes)

### 6.1 Create Systemd Service File

**Why**: Ensures OpenClaw starts automatically on boot and restarts on crashes.

```bash
# Create service file
sudo nano /etc/systemd/system/openclaw.service
```

**Paste this content**:

```ini
[Unit]
Description=OpenClaw - Business Partner Bot (Lisa)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/.openclaw
Environment="NODE_ENV=production"
Environment="OPENCLAW_HOME=/root/.openclaw"
ExecStart=/usr/bin/openclaw gateway start
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=openclaw

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=/root/.openclaw

[Install]
WantedBy=multi-user.target
```

**Save**: `Ctrl+O`, Enter, `Ctrl+X`

---

### 6.2 Enable and Start Service

```bash
# Reload systemd to recognize new service
sudo systemctl daemon-reload

# Enable service (start on boot)
sudo systemctl enable openclaw

# Start service now
sudo systemctl start openclaw

# Check status
sudo systemctl status openclaw
```

**Expected output**: Status should show "active (running)"

---

### 6.3 Monitor Service Logs

```bash
# View live logs
sudo journalctl -u openclaw -f

# View recent logs (last 100 lines)
sudo journalctl -u openclaw -n 100

# View logs with timestamps
sudo journalctl -u openclaw --since "1 hour ago"
```

**Look for**:
- ✅ "Gateway listening on port 18789"
- ✅ "Models authenticated successfully"
- ❌ Any ERROR messages (troubleshoot if found)

---

### 6.4 Test Gateway Connection

**From your Mac**:

```bash
# Test OpenClaw gateway (replace YOUR_DROPLET_IP and YOUR_AUTH_TOKEN)
curl -X POST http://YOUR_DROPLET_IP:18789/api/v1/chat \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hello Lisa, this is a deployment test.",
    "sessionId": "test-session-001"
  }'
```

**Expected response**: JSON with Lisa's greeting message

**If connection fails**:
1. Check firewall: `sudo ufw status` on VPS
2. Check service: `sudo systemctl status openclaw` on VPS
3. Check logs: `sudo journalctl -u openclaw -n 50` on VPS
4. Verify your IP is whitelisted in firewall

---

## Phase 7: Verification & Testing (30 minutes)

### 7.1 Run Comprehensive Verification

```bash
# On VPS: Check OpenClaw health
openclaw status

# Expected output:
# - Gateway: Running on port 18789
# - Models: X models authenticated
# - Sessions: 0 active sessions
```

---

### 7.2 Test Model Routing

**Test primary model (Claude Sonnet)**:
```bash
curl -X POST http://YOUR_DROPLET_IP:18789/api/v1/chat \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "What model are you using?",
    "sessionId": "model-test-001"
  }'
```

**Expected**: Response should indicate Claude Sonnet 4.5

---

### 7.3 Test Fallback Chain

**Temporarily disable Anthropic API key** to test fallback:

```bash
# SSH into VPS
ssh root@YOUR_DROPLET_IP

# Backup .env
cp ~/.openclaw/.env ~/.openclaw/.env.backup

# Comment out Anthropic key
sed -i 's/^ANTHROPIC_API_KEY=/# ANTHROPIC_API_KEY=/' ~/.openclaw/.env

# Restart service
sudo systemctl restart openclaw

# Check logs (should see fallback to GPT-4 or Gemini)
sudo journalctl -u openclaw -n 50
```

**Test fallback**:
```bash
curl -X POST http://YOUR_DROPLET_IP:18789/api/v1/chat \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Testing fallback - what model are you using?",
    "sessionId": "fallback-test-001"
  }'
```

**Expected**: Should use GPT-4 or Gemini Flash (first working fallback)

**Restore Anthropic key**:
```bash
# Restore backup
mv ~/.openclaw/.env.backup ~/.openclaw/.env

# Restart service
sudo systemctl restart openclaw
```

---

### 7.4 Security Verification Checklist

✅ **SSH Security**:
```bash
# Verify password auth is disabled
sudo grep "^PasswordAuthentication" /etc/ssh/sshd_config
# Expected: PasswordAuthentication no
```

✅ **Firewall Security**:
```bash
# Verify only allowed IPs can access port 18789
sudo ufw status verbose
# Expected: Port 18789 allowed only from specific IPs
```

✅ **File Permissions**:
```bash
# Verify .env is not world-readable
ls -la ~/.openclaw/.env
# Expected: -rw------- (600)
```

✅ **Service Isolation**:
```bash
# Verify service runs with correct permissions
sudo systemctl show openclaw | grep User
# Expected: User=root (or dedicated user if created)
```

---

## Phase 8: Create Local Gateway Client (15 minutes)

**On your Mac**: Set up easy access to Lisa bot from command line.

```bash
# Create OpenClaw CLI config on Mac
mkdir -p ~/.openclaw

# Create gateway config
cat > ~/.openclaw/gateways.json <<EOF
{
  "gateways": {
    "lisa-production": {
      "url": "http://YOUR_DROPLET_IP:18789",
      "authToken": "YOUR_AUTH_TOKEN",
      "default": true
    }
  }
}
EOF

# Set permissions
chmod 600 ~/.openclaw/gateways.json

# Test connection
openclaw chat --gateway lisa-production "Hello Lisa, can you hear me?"
```

**Expected**: Lisa responds from VPS

---

## Troubleshooting

### Service Won't Start

**Check logs**:
```bash
sudo journalctl -u openclaw -n 100 --no-pager
```

**Common issues**:
1. **Port already in use**: `sudo lsof -i :18789` (kill conflicting process)
2. **Missing API keys**: Check `.env` file
3. **Invalid JSON**: Validate `openclaw.json` with `jq . openclaw.json`
4. **Permissions**: Ensure `.env` is readable by service user

---

### Cannot Connect from Mac

**Check firewall on VPS**:
```bash
sudo ufw status verbose | grep 18789
```

**Verify your current IP**:
```bash
curl https://api.ipify.org
```

**Add your IP if not whitelisted**:
```bash
sudo ufw allow from YOUR_CURRENT_IP to any port 18789 proto tcp comment 'OpenClaw - updated IP'
```

---

### High Costs / Unexpected Usage

**Check model usage**:
```bash
# On VPS
openclaw status --usage

# Review which models are being called
sudo journalctl -u openclaw | grep "Model:" | tail -50
```

**Verify fallback isn't triggering unexpectedly**:
```bash
sudo journalctl -u openclaw | grep -i "fallback\|error" | tail -50
```

---

### Slow Response Times

**Check VPS resources**:
```bash
# Check CPU/RAM usage
htop

# Check disk space
df -h

# Check network latency
ping -c 5 google.com
```

**If RAM is maxed**: Consider upsizing droplet

---

## Rollback Procedure

If deployment fails and you need to rollback:

```bash
# Stop OpenClaw service
sudo systemctl stop openclaw
sudo systemctl disable openclaw

# Remove service file
sudo rm /etc/systemd/system/openclaw.service
sudo systemctl daemon-reload

# Remove OpenClaw
sudo npm uninstall -g openclaw
rm -rf ~/.openclaw

# Revert firewall rules
sudo ufw delete allow from ANY to any port 18789
sudo ufw reload
```

---

## Success Criteria

✅ OpenClaw service running and auto-starts on boot  
✅ Gateway accessible from Mac via curl/CLI  
✅ Model routing working (primary + fallbacks tested)  
✅ SSH password authentication disabled  
✅ Firewall configured with IP whitelisting  
✅ `.env` file secured with chmod 600  
✅ Logs accessible via `journalctl`  
✅ Lisa responds to test messages  

---

## Next Steps

Once VPS deployment is verified:

1. ✅ VPS deployment complete
2. ➡️ **Proceed to**: Google Workspace API Setup Guide
3. ➡️ **Then**: Telegram Bot Setup Guide
4. ➡️ **Finally**: Skills Installation Guide

---

**Deployment Time**: 3-4 hours  
**Status**: Ready to deploy  
**Support**: Refer to troubleshooting section or OpenClaw docs
