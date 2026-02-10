# OpenClaw 1-Click Deployment Guide for DigitalOcean

**Document Version:** 1.0  
**Created:** February 7, 2026  
**Purpose:** Complete deployment guide for OpenClaw on DigitalOcean

---

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Cost Analysis](#cost-analysis)
3. [Prerequisites](#prerequisites)
4. [Pre-Deployment Checklist](#pre-deployment-checklist)
5. [Deployment Steps](#deployment-steps)
6. [Post-Deployment Access](#post-deployment-access)
7. [Verification & Testing](#verification-and-testing)
8. [Existing Droplet Recommendation](#existing-droplet-recommendation)
9. [Security Features](#security-features)
10. [Troubleshooting](#troubleshooting)
11. [Resources](#resources)

---

## Executive Summary

OpenClaw (formerly Moltbot/Clawdbot) is an open-source, self-hosted AI assistant that can execute tasks like managing calendars, browsing the web, organizing files, managing email, and running terminal commands. DigitalOcean's 1-Click deployment provides a **security-hardened, production-ready** setup with minimal configuration.

### Key Benefits
- ✅ One-click deployment with security defaults
- ✅ Docker container isolation
- ✅ Authenticated gateway tokens
- ✅ Hardened firewall rules
- ✅ Non-root user execution
- ✅ Static IP address for always-on operation
- ✅ 50+ pre-loaded skills available

### Deployment Time
- **Initial provisioning:** 5-10 minutes
- **Configuration:** 5-10 minutes
- **Total:** ~15-20 minutes

---

## Cost Analysis

### New OpenClaw Droplet Costs

#### Base Droplet (Recommended Configuration)
- **Plan:** Basic Droplet with 4GB RAM, 2 vCPUs
- **Size:** `s-2vcpu-4gb`
- **Base Cost:** $24.00/month ($0.03571/hour)
- **Billing:** Per-second (60-second minimum) as of Jan 1, 2026

#### Backup Costs
- **Weekly Backups:** 20% of Droplet cost = **$4.80/month**
- **Daily Backups:** 30% of Droplet cost = $7.20/month (alternative option)
- **Usage-based backup:** $0.04/GiB/month for weekly (alternative option)

#### Bandwidth/Transfer
- **Included:** Varies by Droplet size (pooled across team account)
- **Overage:** $0.01 per GiB after included allowance
- **Note:** Inbound transfer is FREE
- **Pool system:** Transfer allowance is cumulative across all Droplets at team level

#### Total Monthly Cost Estimate
```
Base Droplet:        $24.00
Weekly Backups:      $ 4.80
-----------------------------
TOTAL:              $28.80/month
```

#### Annual Cost
```
$28.80 × 12 = $345.60/year
```

### Hidden/Additional Costs to Consider

1. **API Costs for AI Models:**
   - OpenClaw requires an AI model API key
   - **Anthropic (Claude):** Currently supported, usage-based pricing
   - **Gradient AI:** Available through DigitalOcean
   - **OpenAI:** Coming soon
   - ⚠️ **WARNING:** With scheduled jobs and heavy usage, AI API costs can increase quickly

2. **Potential Fees:**
   - SSH Key storage: FREE
   - Firewall rules: FREE
   - Snapshots (separate from backups): Charged separately if used
   - Load balancers: Not needed for single-bot deployment

### Comparison with Existing Droplet
```
Current linkbot-cloud-01:     $16.00/month
New OpenClaw Droplet:         $28.80/month
--------------------------------------------
Additional Monthly Cost:      $12.80/month
```

---

## Prerequisites

### Required Before Deployment

#### 1. DigitalOcean Account
- ✅ You have an existing account (confirmed)
- ✅ Payment method on file
- ✅ Team/account in good standing

#### 2. SSH Key (REQUIRED)
- **Status:** MANDATORY for 1-Click deployments
- **Purpose:** Secure access to Droplet after creation
- **Must be added:** At Droplet creation time (cannot add via control panel later)

**To check if you have SSH keys configured:**
```bash
# Check DigitalOcean dashboard
Go to: Settings > Security > SSH Keys
```

**To create a new SSH key (if needed):**
```bash
# On your Mac
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub
# Copy the output and add to DigitalOcean dashboard
```

#### 3. AI Model API Key (REQUIRED)
You MUST have one of the following:
- **Anthropic API Key** (Claude models) - Currently supported
- **Gradient AI Key** - Available through DigitalOcean
- **OpenAI API Key** - Coming soon

**To obtain Anthropic API key:**
1. Go to: https://console.anthropic.com/
2. Create account or sign in
3. Navigate to API Keys section
4. Generate new API key
5. **SAVE IT SECURELY** - you'll need it during setup

#### 4. Domain Name (OPTIONAL)
- Not required for deployment
- Can be added later if you want custom URL
- Static IP provided automatically

---

## Pre-Deployment Checklist

Print this checklist and check off each item:

- [ ] DigitalOcean account logged in
- [ ] SSH key created and added to DigitalOcean account
- [ ] AI API key (Anthropic/Gradient) obtained and saved securely
- [ ] Region selected (recommend: SFO2 to match your existing droplet)
- [ ] Decided on backup plan (weekly vs daily)
- [ ] Budget approved ($28.80/month)
- [ ] Existing Droplet decision made (keep vs destroy)
- [ ] Hostname decided (e.g., `openclaw-server` or `linkbot-openclaw-01`)

---

## Deployment Steps

### Step 1: Navigate to OpenClaw Marketplace

**Option A: Via Marketplace**
1. Log in to DigitalOcean: https://cloud.digitalocean.com/
2. Click "Create" → "Droplets"
3. Under "Choose an Image" → Select "Marketplace" tab
4. Search for: `OpenClaw`
5. Click the OpenClaw image

**Option B: Direct Link**
- https://marketplace.digitalocean.com/apps/moltbot
- Click "Create OpenClaw Droplet"

### Step 2: Configure Droplet Settings

#### Region
```
Recommended: SFO2 (San Francisco 2)
Reason: Matches your existing droplet location
```

#### Droplet Plan
```
REQUIRED MINIMUM: 4GB RAM (2 vCPUs)
Recommended Size: s-2vcpu-4gb
Cost: $24/month ($0.03571/hour)
```

⚠️ **Do NOT select smaller sizes** - OpenClaw requires at least 4GB RAM to run effectively.

#### Additional Options

**Backups (Recommended):**
- ☑️ Enable automated backups
- Select: Weekly backups (+$4.80/month)
- Provides: 4 most recent weekly backups

**Monitoring (Recommended):**
- ☑️ Enable for free
- Provides: CPU, bandwidth, disk I/O metrics

**IPv6:**
- Optional (not required)

#### Authentication

**CRITICAL:** Select "SSH Key" and choose your SSH key
- ⚠️ Password authentication is less secure
- ⚠️ Cannot add SSH key via control panel after creation

#### Hostname
```
Suggested: openclaw-server
Or: linkbot-openclaw-01
```

#### Tags (Optional)
```
Suggested: openclaw, production, ai-agent
```

### Step 3: Create Droplet

1. Review all settings
2. Verify pricing matches expectations ($24/month + $4.80 backup = $28.80)
3. Click **"Create Droplet"**
4. Wait 5-10 minutes for initialization

### Step 4: Alternative - API/CLI Deployment

For advanced users who prefer command-line deployment:

```bash
# Set your API token
export DIGITALOCEAN_TOKEN="your_api_token_here"

# Create OpenClaw Droplet via API
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{
    "name": "openclaw-server",
    "region": "sfo2",
    "size": "s-2vcpu-4gb",
    "image": "openclaw",
    "backups": true,
    "ssh_keys": ["your_ssh_key_id"]
  }' \
  "https://api.digitalocean.com/v2/droplets"
```

**To get your SSH key ID:**
```bash
curl -X GET \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/account/keys"
```

---

## Post-Deployment Access

### Step 1: Retrieve Droplet IP Address

**Via Dashboard:**
1. Go to: https://cloud.digitalocean.com/droplets
2. Find your new OpenClaw droplet
3. Note the **IPv4 address** (e.g., `143.198.123.45`)

**Via CLI:**
```bash
doctl compute droplet list | grep openclaw
```

### Step 2: SSH into Droplet

```bash
ssh root@YOUR_DROPLET_IP
```

**What to expect:**
- First login may take 1-2 minutes if initialization is still running
- You'll see an OpenClaw welcome message
- Configuration wizard will start automatically

### Step 3: Initial Configuration

You'll be prompted to configure:

#### 1. AI Provider Selection
```
Prompt: Select your AI Provider
Options:
  - Anthropic (Claude) ← Currently recommended
  - Gradient AI (if you have access)
  - OpenAI (coming soon)

Action: Choose Anthropic
```

#### 2. API Key Entry
```
Prompt: Enter your Anthropic API key
Action: Paste your API key
Note: Key is stored in environment variable: ANTHROPIC_API_KEY
```

#### 3. Pairing Automation
```
Prompt: Would you like to run pairing automation now?
Purpose: Access to the GUI dashboard
Action: Type "yes" and press Enter
```

### Step 4: Access Control UI (Dashboard)

#### Dashboard URL Format
```
http://YOUR_DROPLET_IP:18789/?token=YOUR_GATEWAY_TOKEN
```

**Finding the Dashboard URL:**
- After SSH login, look for "Dashboard URL" in the welcome message
- The URL will be displayed with the authentication token pre-filled
- Example output:
  ```
  Control UI & Gateway Access
  Dashboard URL: http://143.198.123.45:18789/?token=abc123xyz789
  ```

#### Opening the Dashboard

**Option 1: During Setup (Recommended)**
1. Copy the full URL provided
2. Open your web browser
3. Paste the URL
4. You'll be automatically authenticated via the token

**Option 2: Manual Access Later**
```bash
# From within the Droplet SSH session
openclaw dashboard
```
This command prints a clean link and opens the dashboard automatically.

### Step 5: Complete Pairing

1. After opening the dashboard URL in browser
2. Return to your SSH terminal
3. Type: `continue`
4. Press Enter to continue automated pairing
5. Refresh your browser
6. You'll be redirected to the default chat page

---

## Verification & Testing

### Post-Deployment Checklist

- [ ] SSH access working
- [ ] Dashboard URL accessible
- [ ] AI model responding to queries
- [ ] Skills registry loaded (50+ skills available)
- [ ] Gateway authentication working
- [ ] Droplet showing in DigitalOcean dashboard
- [ ] Backups scheduled (check: Settings → Backups in dashboard)
- [ ] Monitoring metrics appearing (if enabled)

### Test Commands

#### Test 1: Check OpenClaw Health
```bash
openclaw gateway health --url ws://127.0.0.1:18789
```
**Expected:** Health check passes

#### Test 2: List Available Skills
```bash
openclaw skills
```
**Expected:** List of 50+ available skills

#### Test 3: Test Chat in Dashboard
```
Navigate to Dashboard → Chat
Type: "What files can you currently see on my computer?"
```
**Expected:** OpenClaw responds with list of sandbox files

#### Test 4: Check Docker Containers
```bash
docker ps
```
**Expected:** OpenClaw containers running

#### Test 5: Access Text User Interface (TUI)
```bash
/opt/openclaw-tui.sh
```
**Note:** Older versions may use `/opt/clawdbot-tui.sh`

### What Gets Pre-Configured Automatically

The 1-Click deployment includes:

#### ✅ Pre-installed Software
- OpenClaw version 2026.1.24-1 (or newer)
- Docker and Docker Compose
- All necessary dependencies
- 50+ skills in the skill registry

#### ✅ Security Hardening
- Unique gateway authentication token
- Firewall rules with rate limiting
- fail2ban configured (blocks abusive traffic)
- Non-root user execution (`openclaw` user)
- Docker container isolation
- TLS-secured reverse proxy for external access
- Private DM pairing enabled by default

#### ✅ Network Configuration
- Static IP address assigned
- Port 18789 configured for Control UI
- WebSocket gateway configured
- Predictable networking setup

#### ✅ System Configuration
- Automated updates configured
- Monitoring hooks in place (if enabled)
- Backup scheduling (if enabled)
- Environment variables for API keys

---

## Existing Droplet Recommendation

### Your Current Situation
- **Existing Droplet:** linkbot-cloud-01
- **Location:** SFO2 region
- **Cost:** $16/month
- **Status:** Active

### Recommendation: Keep Both Droplets (Short Term)

#### Rationale
1. **Test Period:** Run OpenClaw for 1-2 weeks to ensure it meets requirements
2. **No Refunds:** DigitalOcean does NOT offer refunds for destroyed Droplets
3. **Minimal Cost:** Additional $12.80/month is manageable for testing
4. **Safety Net:** Maintain existing infrastructure while validating new bot

#### After Testing Period (2-4 weeks)

**Option A: Destroy linkbot-cloud-01 (If OpenClaw meets all needs)**
- Saves $16/month
- No refund for unused time
- Make sure to backup any data first
- Export any needed configurations

**Option B: Repurpose linkbot-cloud-01**
- Use for development/staging
- Database server
- Backup server for OpenClaw data
- Monitoring server
- File storage

**Option C: Keep Both**
- Redundancy/failover
- Separate concerns (production vs testing)
- Total cost: $44.80/month

### How to Destroy a Droplet (When Ready)

⚠️ **WARNING:** This action is PERMANENT and CANNOT be undone. No refunds provided.

#### Via Dashboard
1. Go to: https://cloud.digitalocean.com/droplets
2. Find `linkbot-cloud-01`
3. Click the droplet name
4. Click "Destroy" → "Destroy this Droplet"
5. Type the droplet name to confirm
6. Billing stops immediately (per-second billing)

#### Via CLI
```bash
# List droplets to confirm ID
doctl compute droplet list

# Destroy droplet
doctl compute droplet delete DROPLET_ID
```

#### Billing After Destruction
- ⚠️ **No refunds** for unused time in current billing cycle
- Billing stops immediately upon destruction
- You are charged for the time the Droplet existed (per-second)
- Powered-down Droplets still incur charges (must destroy to stop billing)

#### Before Destroying - Create Snapshot (Recommended)
```bash
# Create snapshot before destroying
1. Go to Droplet → Snapshots
2. Click "Take Snapshot"
3. Wait for completion
4. Then destroy droplet

Cost: $0.06/GB/month for snapshot storage
```

---

## Security Features

### Pre-Configured Security Defaults

The 1-Click deployment includes production-grade security:

#### 1. Gateway Authentication Token
- **What:** Unique token for authenticated WebSocket access
- **Location:** `gateway.auth.token` or `OPENCLAW_GATEWAY_TOKEN` env var
- **Purpose:** Prevents unauthorized access to your agent
- **Usage:** Automatically included in dashboard URL

#### 2. Docker Container Isolation
- **What:** OpenClaw runs in dedicated Docker containers
- **Benefit:** Isolates agent execution from host system
- **Protection:** If agent crashes, only container is affected
- **Sandboxing:** Prevents unintended commands from impacting Droplet

#### 3. Hardened Firewall Rules
- **Pre-configured:** UFW firewall with rate limiting
- **Blocks:** Unauthorized traffic to OpenClaw ports
- **Protection:** Prevents DoS attacks
- **fail2ban:** Automatically blocks abusive IPs

#### 4. Non-Root User Execution
- **User:** `openclaw` (non-root)
- **Benefit:** Limits attack surface
- **Protection:** Prevents privilege escalation
- **Best Practice:** Industry-standard security

#### 5. Private DM Pairing
- **Default:** Enabled automatically
- **Purpose:** Only approved users can interact with bot
- **Benefit:** Prevents unauthorized conversations
- **Limits:** Blast radius of unintended commands

#### 6. TLS-Secured Reverse Proxy
- **What:** All external access routed through encrypted proxy
- **Benefit:** Communication encrypted in transit
- **Auditable:** Clear access path for security reviews
- **Protection:** Internal services not directly exposed

### Security Best Practices

#### ✅ DO:
- Keep SSH keys secure
- Rotate gateway tokens periodically
- Monitor logs for unusual activity
- Update OpenClaw regularly
- Use strong API keys for AI models
- Enable 2FA on DigitalOcean account

#### ❌ DON'T:
- Don't run OpenClaw as root
- Don't disable firewall
- Don't expose Control UI publicly without authentication
- Don't share gateway tokens
- Don't store secrets in code/skills
- Don't run OpenClaw on personal machine with sensitive data

### Important Security Note

⚠️ **OpenClaw should only be run within the DigitalOcean 1-Click Droplet environment alongside the provided security controls. Deploying manually outside this environment removes security protections and may not meet your security requirements.**

---

## Troubleshooting

### Common Issues & Solutions

#### Issue: Cannot SSH into Droplet
**Symptoms:** Connection refused or timeout
**Solutions:**
```bash
# 1. Check if Droplet is powered on
doctl compute droplet list

# 2. Verify SSH key is correct
ssh -v root@YOUR_DROPLET_IP

# 3. Check firewall rules allow SSH
# SSH (port 22) should be open by default

# 4. Wait if Droplet just created (may still be initializing)
```

#### Issue: Dashboard URL not loading
**Symptoms:** Browser shows "Cannot connect" or timeout
**Solutions:**
1. Verify you're using the full URL with token
2. Check if OpenClaw services are running:
   ```bash
   ssh root@YOUR_DROPLET_IP
   docker ps
   ```
3. Restart OpenClaw services if needed
4. Check port 18789 is accessible

#### Issue: API key not working
**Symptoms:** AI model not responding
**Solutions:**
1. Verify API key is valid in Anthropic dashboard
2. Check API key has sufficient credits
3. Re-enter API key:
   ```bash
   # Set environment variable
   export ANTHROPIC_API_KEY="your_key_here"
   ```
4. Restart OpenClaw

#### Issue: Skills not loading
**Symptoms:** Skill registry empty or incomplete
**Solutions:**
```bash
# 1. Refresh skill registry
openclaw skills refresh

# 2. Manually install skill
npx clawhub install <skill_name>

# 3. Check Docker container has internet access
docker exec -it <container_id> ping google.com
```

#### Issue: Gateway authentication failing
**Symptoms:** "Unauthorized" errors in dashboard
**Solutions:**
1. Get fresh dashboard URL:
   ```bash
   openclaw dashboard
   ```
2. Check gateway health:
   ```bash
   openclaw gateway health --url ws://127.0.0.1:18789
   ```
3. Verify token in environment:
   ```bash
   echo $OPENCLAW_GATEWAY_TOKEN
   ```

#### Issue: High API costs
**Symptoms:** Unexpected AI API bills
**Solutions:**
1. Check scheduled cron jobs (may be running frequently)
2. Review usage in Anthropic dashboard
3. Set rate limits or quotas
4. Disable automatic skills if not needed
5. Monitor "Usage" section in OpenClaw dashboard

### Getting Help

#### Official Resources
- **OpenClaw Documentation:** https://docs.openclaw.ai/
- **DigitalOcean Tutorial:** https://digitalocean.com/community/tutorials/how-to-run-openclaw
- **GitHub Issues:** https://github.com/OpenClawAI/openclaw

#### DigitalOcean Support
- **Support Portal:** https://cloud.digitalocean.com/support/tickets
- **Community Forums:** https://digitalocean.com/community
- **Documentation:** https://docs.digitalocean.com/

#### OpenClaw Community
- **Discord:** Check OpenClaw website for invite
- **GitHub Discussions:** OpenClaw repository
- **Community Forum:** https://digitalocean.com/community/tags/ai-ml

---

## Resources

### Official Documentation
- **OpenClaw Official Site:** https://openclaw.ai/
- **OpenClaw Docs:** https://docs.openclaw.ai/
- **DigitalOcean Marketplace Listing:** https://marketplace.digitalocean.com/apps/moltbot
- **Deployment Tutorial:** https://digitalocean.com/community/tutorials/how-to-run-openclaw
- **Technical Deep Dive:** https://digitalocean.com/blog/technical-dive-openclaw-hardened-1-click-app
- **What is OpenClaw:** https://digitalocean.com/resources/articles/what-is-openclaw

### DigitalOcean Documentation
- **Droplet Docs:** https://docs.digitalocean.com/products/droplets/
- **SSH Key Setup:** https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/
- **Destroy Droplet:** https://docs.digitalocean.com/products/droplets/how-to/destroy/
- **Backup Pricing:** https://docs.digitalocean.com/products/backups/details/pricing/
- **Bandwidth Billing:** https://docs.digitalocean.com/platform/billing/bandwidth/

### API Documentation
- **Anthropic API:** https://docs.anthropic.com/
- **DigitalOcean API:** https://docs.digitalocean.com/reference/api/
- **Gradient AI:** https://docs.digitalocean.com/products/gradient-ai-platform/

### Video Tutorials
- **Deploy Moltbot on DigitalOcean:** https://youtube.com/watch?v=n2MrUtIT1m4

### Command Line Tools
- **doctl (DigitalOcean CLI):** https://docs.digitalocean.com/reference/doctl/
- **OpenClaw CLI:** https://docs.openclaw.ai/cli/

---

## Quick Reference Commands

### SSH Access
```bash
# Connect to Droplet
ssh root@YOUR_DROPLET_IP

# Switch to openclaw user
su openclaw

# Change to home directory
cd
```

### OpenClaw Commands
```bash
# Open dashboard
openclaw dashboard

# Check health
openclaw gateway health --url ws://127.0.0.1:18789

# List skills
openclaw skills

# Install skill
npx clawhub install <skill_name>

# Start TUI
/opt/openclaw-tui.sh
```

### Docker Commands
```bash
# List running containers
docker ps

# View logs
docker logs <container_id>

# Restart containers
docker restart <container_id>
```

### System Commands
```bash
# Check disk space
df -h

# Check memory usage
free -h

# Check running processes
htop

# View OpenClaw logs
journalctl -u openclaw -f
```

---

## Appendix: Cost Calculator

### Monthly Cost Scenarios

#### Scenario 1: Single OpenClaw Droplet + Weekly Backups
```
OpenClaw Droplet (4GB):    $24.00
Weekly Backups:            $ 4.80
Bandwidth (included):      $ 0.00
--------------------------------
TOTAL:                     $28.80/month
```

#### Scenario 2: Both Droplets Running
```
linkbot-cloud-01:          $16.00
OpenClaw Droplet:          $24.00
Weekly Backups:            $ 4.80
--------------------------------
TOTAL:                     $44.80/month
```

#### Scenario 3: OpenClaw + Daily Backups
```
OpenClaw Droplet (4GB):    $24.00
Daily Backups:             $ 7.20
Bandwidth (included):      $ 0.00
--------------------------------
TOTAL:                     $31.20/month
```

#### Scenario 4: OpenClaw + Snapshot Backup
```
OpenClaw Droplet (4GB):    $24.00
Weekly Backups:            $ 4.80
Manual Snapshots (40GB):   $ 2.40
--------------------------------
TOTAL:                     $31.20/month
```

### Annual Costs
```
Scenario 1: $28.80 × 12 = $345.60/year
Scenario 2: $44.80 × 12 = $537.60/year
Scenario 3: $31.20 × 12 = $374.40/year
Scenario 4: $31.20 × 12 = $374.40/year
```

### Cost Savings by Destroying linkbot-cloud-01
```
Current (both running):    $44.80/month
After destroying old:      $28.80/month
--------------------------------
Monthly Savings:           $16.00/month
Annual Savings:           $192.00/year
```

---

## Document Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Feb 7, 2026 | Initial release |

---

## Conclusion

This guide provides everything needed to deploy OpenClaw on DigitalOcean with confidence. The 1-Click deployment significantly reduces complexity while maintaining security and control.

**Recommended Next Steps:**
1. ✅ Complete Pre-Deployment Checklist
2. ✅ Deploy OpenClaw Droplet
3. ✅ Configure AI model integration
4. ✅ Test functionality for 2-4 weeks
5. ✅ Decide on linkbot-cloud-01 fate
6. ✅ Install additional skills as needed
7. ✅ Monitor costs (Droplet + AI API usage)

**Questions or Issues?**
- Consult Troubleshooting section
- Check Official Documentation
- Contact DigitalOcean Support
- Engage with OpenClaw Community

---

**Document prepared by:** Deployment Agent  
**Last updated:** February 7, 2026  
**Status:** Ready for deployment
