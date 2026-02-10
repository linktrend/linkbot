# OpenClaw Deployment Checklist

**Print this checklist and check off items as you complete them**

---

## PRE-DEPLOYMENT PREPARATION

### Account & Access
- [ ] DigitalOcean account logged in
- [ ] Payment method verified and active
- [ ] SSH key created and added to DO account
  - Location: Settings → Security → SSH Keys
  - Test: `ssh-keygen -l -f ~/.ssh/id_ed25519.pub`

### API Keys & Credentials
- [ ] Anthropic API key obtained and saved
  - Get from: https://console.anthropic.com/
  - Saved securely: ________________
- [ ] API key tested and has credits available

### Configuration Decisions
- [ ] Region selected: **SFO2** (recommended)
- [ ] Hostname decided: _________________________
- [ ] Backup plan selected: 
  - [ ] Weekly (+$4.80/month)
  - [ ] Daily (+$7.20/month)
- [ ] Budget approved: **$28.80/month** (base + weekly backup)

### Existing Droplet Plan
- [ ] Decision made on linkbot-cloud-01:
  - [ ] Keep both (test period)
  - [ ] Destroy after testing
  - [ ] Repurpose for other use

---

## DEPLOYMENT EXECUTION

### Step 1: Create Droplet
- [ ] Navigate to: https://cloud.digitalocean.com/droplets/new
- [ ] Select "Marketplace" tab
- [ ] Search for "OpenClaw" and select image
- [ ] Region: **SFO2**
- [ ] Plan: **s-2vcpu-4gb** (4GB RAM, 2 vCPU, $24/month)
- [ ] Enable backups: ☑️ (Weekly)
- [ ] Enable monitoring: ☑️ (Free)
- [ ] Authentication: **SSH Key** selected
- [ ] Hostname entered: _________________________
- [ ] Optional tags added: openclaw, production, ai-agent
- [ ] Price verified: **$28.80/month**
- [ ] Click "Create Droplet"
- [ ] Wait 5-10 minutes for initialization

### Step 2: Record Information
```
Droplet IP Address: ___________________________
Dashboard URL: _________________________________
Gateway Token: __________________________________
```

### Step 3: Initial SSH Connection
- [ ] Connect: `ssh root@YOUR_DROPLET_IP`
- [ ] Welcome message displayed
- [ ] Configuration wizard started

### Step 4: Configure OpenClaw
- [ ] AI Provider selected: **Anthropic**
- [ ] API key entered and accepted
- [ ] Pairing automation: Type **"yes"**
- [ ] Dashboard URL displayed and saved
- [ ] Browser opened with dashboard URL
- [ ] Return to terminal: Type **"continue"**
- [ ] Browser refreshed → Redirected to chat page

---

## POST-DEPLOYMENT VERIFICATION

### Access Tests
- [ ] SSH access working
- [ ] Dashboard accessible in browser
- [ ] Chat interface loaded
- [ ] AI model responding to queries

### Health Checks
```bash
# Run these commands via SSH
```
- [ ] `openclaw gateway health --url ws://127.0.0.1:18789`
  - Expected: Health check passes
- [ ] `openclaw skills`
  - Expected: 50+ skills listed
- [ ] `docker ps`
  - Expected: Containers running
- [ ] `/opt/openclaw-tui.sh`
  - Expected: TUI interface loads

### Functionality Tests
- [ ] **Test 1:** Ask bot: "What files can you currently see?"
  - Expected: Lists sandbox files
- [ ] **Test 2:** Navigate to Skills → Install a skill
  - Expected: Skill installs successfully
- [ ] **Test 3:** Check monitoring metrics (if enabled)
  - Location: Droplet → Graphs
  - Expected: CPU/RAM/Disk metrics showing

### Security Verification
- [ ] Gateway token authentication working
- [ ] Firewall rules active: `sudo ufw status`
- [ ] Docker containers isolated: `docker ps`
- [ ] Non-root user exists: `id openclaw`
- [ ] fail2ban running: `sudo systemctl status fail2ban`

---

## CONFIGURATION & CUSTOMIZATION

### Optional Setup
- [ ] Connect messaging channel (WhatsApp/Telegram/Discord)
  - Command: `openclaw channels login --channel whatsapp`
- [ ] Install additional skills
  - Browse: `openclaw skills`
  - Install: `npx clawhub install <skill_name>`
- [ ] Configure cron jobs (scheduled tasks)
  - Via Dashboard → Cron Jobs
- [ ] Set up domain name (optional)
  - Point A record to Droplet IP
- [ ] Configure additional security (optional)
  - Rotate gateway token
  - Set up Tailscale for secure remote access

---

## MONITORING & MAINTENANCE

### Week 1 Checks
- [ ] **Day 1:** Verify bot responding correctly
- [ ] **Day 3:** Check AI API usage costs
  - Location: https://console.anthropic.com/
- [ ] **Day 7:** Review any errors in logs
  - Command: `journalctl -u openclaw -n 100`

### Week 2-4 Testing
- [ ] Test core functionality needed for your use case
- [ ] Monitor costs (Droplet + AI API)
- [ ] Verify backups are running
  - Location: Droplet → Backups in dashboard
- [ ] Check skill performance
- [ ] Document any issues or limitations

### Cost Monitoring
- [ ] **Week 1:** Check DigitalOcean bill: $__________
- [ ] **Week 2:** Check Anthropic bill: $__________
- [ ] **Week 4:** Total costs: $__________
- [ ] Compare to budget: Under/Over by: $__________

---

## EXISTING DROPLET DECISION

### After 2-4 Week Test Period

**Decision Date:** _________________________

#### Option A: Destroy linkbot-cloud-01
- [ ] Backup all needed data first
- [ ] Export configurations
- [ ] Create snapshot (optional): Droplet → Snapshots
- [ ] Verify OpenClaw meets all requirements
- [ ] Destroy via: Droplet → Destroy
- [ ] Confirm: Type droplet name
- [ ] **Savings:** $16/month ($192/year)

#### Option B: Repurpose linkbot-cloud-01
- [ ] New purpose: _________________________
- [ ] Configuration updated
- [ ] **Cost:** Continue at $16/month

#### Option C: Keep Both
- [ ] Justification: _________________________
- [ ] **Cost:** $44.80/month total

---

## TROUBLESHOOTING QUICK REFERENCE

### If Something Goes Wrong

**Cannot SSH:**
```bash
# Check droplet status
doctl compute droplet list
# Try verbose SSH
ssh -v root@YOUR_DROPLET_IP
```

**Dashboard Not Loading:**
```bash
# Check services
docker ps
# Get fresh URL
openclaw dashboard
```

**API Key Issues:**
```bash
# Re-export key
export ANTHROPIC_API_KEY="your_key"
# Restart OpenClaw
docker restart <container_id>
```

**Skills Not Working:**
```bash
# Refresh registry
openclaw skills refresh
# Reinstall skill
npx clawhub install <skill_name>
```

---

## SUPPORT CONTACTS

### DigitalOcean Support
- Portal: https://cloud.digitalocean.com/support/tickets
- Docs: https://docs.digitalocean.com/

### OpenClaw Resources
- Documentation: https://docs.openclaw.ai/
- Tutorial: https://digitalocean.com/community/tutorials/how-to-run-openclaw
- GitHub: https://github.com/OpenClawAI/openclaw

---

## SUCCESS CRITERIA

**Deployment is successful when:**
- ✅ Bot responds to chat messages
- ✅ Skills can be installed and used
- ✅ Dashboard is accessible
- ✅ Costs are within budget
- ✅ Security checks pass
- ✅ Backups are running
- ✅ All tests passed

---

## COMPLETION SIGNATURE

**Deployment completed by:** _________________________  
**Date:** _________________________  
**Time elapsed:** _________ minutes  
**Status:** ⭕ Success / ⭕ Issues (see notes)  
**Notes:**
```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

**Next Steps After Successful Deployment:**
1. Explore skills and capabilities
2. Connect to messaging platforms
3. Monitor costs for first month
4. Decide on existing Droplet
5. Document any custom configurations

---

**Checklist Version:** 1.0  
**Last Updated:** February 7, 2026
