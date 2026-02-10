# Deployment Preparation Checklist

**Bot Instance:** Business Partner Bot  
**Target Environment:** DigitalOcean Droplet (VPS)  
**Deployment Approach:** Option B (Configure Locally → Deploy to VPS)  
**Last Updated:** February 7, 2026

---

## Pre-Deployment Checklist

### Phase 1: Repository Setup ✅

- [x] **Workspace Cleaned**
  - Verified clean workspace at `/Users/linktrend/Projects/LiNKbot/`
  - Removed old test files and configurations
  - Status: Completed 2026-02-07

- [x] **OpenClaw Forked**
  - Forked `openclaw/openclaw` → `linktrend/openclaw`
  - Fork URL: https://github.com/linktrend/openclaw
  - Status: Completed 2026-02-07

- [x] **OpenClaw Cloned**
  - Cloned to: `/Users/linktrend/Projects/LiNKbot/bots/business-partner/`
  - Repository size: 236 MB
  - Verified structure: src/, skills/, docs/, packages/
  - Status: Completed 2026-02-07

- [x] **Workspace Git Initialized**
  - Initialized git repository in workspace root
  - Added remote: https://github.com/linktrend/linkbot-partner
  - Created .gitignore excluding `bots/business-partner/`
  - Status: Completed 2026-02-07

- [x] **Documentation Created**
  - Created `docs/GIT_STRATEGY.md`
  - Created `docs/DEPLOYMENT_PREP.md` (this file)
  - Status: Completed 2026-02-07

---

### Phase 2: Multi-Model Routing Configuration ⏳

- [ ] **Review OpenClaw Routing Documentation**
  - Read: `bots/business-partner/docs/routing/`
  - Understand model selection logic
  - Identify configuration files

- [ ] **Create Routing Configuration**
  - Create: `config/business-partner/routing.yaml`
  - Define model tiers:
    - Fast: GPT-4o-mini, Claude 3.5 Haiku
    - Standard: GPT-4o, Claude 3.5 Sonnet
    - Advanced: o1, Claude 3.7 Opus
  - Set cost thresholds
  - Configure fallback chains

- [ ] **Test Routing Logic**
  - Test with sample queries
  - Verify model selection
  - Validate cost calculations

---

### Phase 3: Telegram Bot Setup ⏳

- [ ] **Create Telegram Bot**
  - Talk to @BotFather on Telegram
  - Create new bot: `/newbot`
  - Choose username (e.g., `linkbot_business_partner_bot`)
  - Save bot token securely

- [ ] **Configure Telegram Bot**
  - Create: `config/business-partner/telegram-config.json`
  - Set bot token
  - Configure allowed user IDs
  - Set command aliases
  - Configure rate limits

- [ ] **Set Bot Commands**
  - Use @BotFather: `/setcommands`
  - Define available commands
  - Set bot description and about text

- [ ] **Test Telegram Integration**
  - Start bot locally
  - Send test messages
  - Verify responses
  - Test command handling

---

### Phase 4: Email SMTP Configuration ⏳

- [ ] **Choose Email Provider**
  - Options: Gmail, SendGrid, Mailgun, AWS SES
  - Consider: Cost, reliability, deliverability

- [ ] **Configure SMTP Credentials**
  - Create: `config/business-partner/.env.production`
  - Set SMTP host, port, username, password
  - Configure from/reply-to addresses

- [ ] **Test Email Sending**
  - Send test email
  - Verify delivery
  - Check spam folder
  - Test HTML formatting

---

### Phase 5: Skills Installation and Vetting ⏳

- [ ] **Review Available Skills**
  - List skills: `bots/business-partner/skills/`
  - Read skill documentation
  - Identify required skills for business partner bot

- [ ] **Install Required Skills**
  - Skills to consider:
    - Web search
    - Document analysis
    - Calendar management
    - Email composition
    - Data analysis
  - Install dependencies for each skill

- [ ] **Vet Skills for Security**
  - Review skill code for:
    - API key exposure
    - Unsafe file operations
    - Command injection vulnerabilities
    - Data exfiltration risks
  - Document security findings

- [ ] **Configure Skill Permissions**
  - Create: `config/business-partner/skills-config.json`
  - Enable/disable skills
  - Set skill-specific parameters
  - Configure rate limits per skill

- [ ] **Test Skills Locally**
  - Test each enabled skill
  - Verify functionality
  - Check error handling
  - Validate security boundaries

---

### Phase 6: Security Hardening ⏳

- [ ] **Environment Variables**
  - Create `.env.production` from `.env.example`
  - Set all required API keys:
    - OpenAI API key
    - Anthropic API key
    - Google AI API key
    - Telegram bot token
    - SMTP credentials
  - Verify no secrets in git history

- [ ] **Access Control**
  - Configure allowed Telegram user IDs
  - Set up admin user list
  - Configure rate limiting
  - Set up IP whitelisting (if applicable)

- [ ] **Data Privacy**
  - Configure conversation logging
  - Set data retention policies
  - Configure PII handling
  - Set up data encryption at rest

- [ ] **Network Security**
  - Plan firewall rules for VPS
  - Configure HTTPS/TLS
  - Set up reverse proxy (nginx)
  - Plan DDoS protection

---

### Phase 7: Local Testing ⏳

- [ ] **Install Dependencies**
  ```bash
  cd bots/business-partner/
  pnpm install
  ```

- [ ] **Copy Configurations**
  ```bash
  cp ../../config/business-partner/.env.production .env
  cp ../../config/business-partner/routing.yaml config/routing.yaml
  cp ../../config/business-partner/telegram-config.json config/telegram.json
  cp ../../config/business-partner/skills-config.json config/skills.json
  ```

- [ ] **Build OpenClaw**
  ```bash
  pnpm build
  ```

- [ ] **Run Locally**
  ```bash
  pnpm start
  ```

- [ ] **Functional Testing**
  - Test Telegram bot interaction
  - Test multi-model routing
  - Test skill execution
  - Test error handling
  - Test rate limiting

- [ ] **Performance Testing**
  - Measure response times
  - Check memory usage
  - Monitor CPU usage
  - Test under load

---

### Phase 8: First Git Commit ⏳

- [ ] **Stage Configuration Files**
  ```bash
  git add config/business-partner/
  git add docs/
  git add scripts/
  git add README.md
  ```

- [ ] **Create Initial Commit**
  ```bash
  git commit -m "Initial configuration for Business Partner bot

  - Multi-model routing configured
  - Telegram bot integrated
  - Skills vetted and enabled
  - Security hardened
  - Local testing completed"
  ```

- [ ] **Push to GitHub**
  ```bash
  git push -u origin main
  ```

---

### Phase 9: VPS Deployment ⏳

- [ ] **Provision DigitalOcean Droplet**
  - Size: 2 GB RAM minimum (4 GB recommended)
  - OS: Ubuntu 24.04 LTS
  - Region: Choose closest to target users
  - Enable monitoring

- [ ] **Initial Server Setup**
  - SSH access configured
  - Create non-root user
  - Configure firewall (ufw)
  - Install Node.js (v20+)
  - Install pnpm
  - Install nginx

- [ ] **Clone OpenClaw on VPS**
  ```bash
  ssh user@droplet
  cd /opt/
  git clone https://github.com/linktrend/openclaw openclaw-business-partner
  ```

- [ ] **Copy Configurations to VPS**
  ```bash
  # From local machine
  scp -r config/business-partner/ user@droplet:/opt/openclaw-business-partner/config/
  ```

- [ ] **Install Dependencies on VPS**
  ```bash
  ssh user@droplet
  cd /opt/openclaw-business-partner/
  pnpm install
  pnpm build
  ```

- [ ] **Configure Systemd Service**
  - Create: `/etc/systemd/system/openclaw-business-partner.service`
  - Enable service: `systemctl enable openclaw-business-partner`
  - Start service: `systemctl start openclaw-business-partner`

- [ ] **Configure Nginx Reverse Proxy**
  - Create nginx config
  - Enable HTTPS with Let's Encrypt
  - Configure rate limiting
  - Set up logging

- [ ] **Verify Deployment**
  - Check service status
  - Test Telegram bot
  - Monitor logs
  - Test all skills

---

## Post-Deployment

### Monitoring Setup

- [ ] **Set Up Logging**
  - Configure log rotation
  - Set up centralized logging (optional)
  - Configure error alerting

- [ ] **Set Up Monitoring**
  - Monitor CPU/RAM usage
  - Monitor disk space
  - Monitor network traffic
  - Set up uptime monitoring

- [ ] **Set Up Backups**
  - Configure daily backups
  - Test backup restoration
  - Document backup procedures

### Documentation

- [ ] **Create Operations Runbook**
  - Document startup procedures
  - Document shutdown procedures
  - Document troubleshooting steps
  - Document rollback procedures

- [ ] **Create User Guide**
  - Document available commands
  - Document bot capabilities
  - Document limitations
  - Create FAQ

---

## Current Status Summary

### ✅ Completed (Phase 1)

1. Workspace cleaned and prepared
2. OpenClaw forked to `linktrend/openclaw`
3. OpenClaw cloned to `bots/business-partner/` (236 MB)
4. Workspace initialized as git repository
5. Git remote configured: `linkbot-partner`
6. Documentation created:
   - `docs/GIT_STRATEGY.md` - Fork → Configure → Deploy pattern
   - `docs/DEPLOYMENT_PREP.md` - This checklist
7. README.md updated with deployment approach

### ⏳ Next Steps (Phase 2)

1. **Configure Multi-Model Routing**
   - Review OpenClaw routing documentation
   - Create `config/business-partner/routing.yaml`
   - Define model tiers and fallback chains

2. **Create Telegram Bot**
   - Talk to @BotFather
   - Get bot token
   - Configure bot settings

3. **Configure Email SMTP**
   - Choose email provider
   - Set up SMTP credentials
   - Test email sending

---

## Timeline Estimate

| Phase | Tasks | Estimated Effort |
|-------|-------|------------------|
| Phase 1: Repository Setup | 5 tasks | ✅ Completed |
| Phase 2: Multi-Model Routing | 3 tasks | 2-3 hours |
| Phase 3: Telegram Bot | 4 tasks | 1-2 hours |
| Phase 4: Email SMTP | 3 tasks | 1 hour |
| Phase 5: Skills Vetting | 5 tasks | 4-6 hours |
| Phase 6: Security Hardening | 4 tasks | 2-3 hours |
| Phase 7: Local Testing | 6 tasks | 3-4 hours |
| Phase 8: First Commit | 3 tasks | 30 minutes |
| Phase 9: VPS Deployment | 7 tasks | 3-4 hours |
| **Total** | **40 tasks** | **17-24 hours** |

---

## Risk Assessment

### High Priority Risks

1. **API Key Exposure**
   - Mitigation: Never commit `.env` files, use `.gitignore`
   - Verification: Check git history before pushing

2. **Skill Security Vulnerabilities**
   - Mitigation: Vet all skills before enabling
   - Verification: Code review and security testing

3. **VPS Security**
   - Mitigation: Firewall, SSH keys only, regular updates
   - Verification: Security audit after deployment

### Medium Priority Risks

1. **Configuration Drift**
   - Mitigation: Version control all configurations
   - Verification: Document all changes in git commits

2. **OpenClaw Updates Breaking Changes**
   - Mitigation: Test updates locally before deploying
   - Verification: Maintain staging environment

---

## Success Criteria

### Deployment Complete When:

- [x] OpenClaw cloned and verified
- [ ] All configurations created and tested locally
- [ ] Telegram bot responding to commands
- [ ] Multi-model routing working correctly
- [ ] All enabled skills tested and working
- [ ] Security hardening completed
- [ ] VPS deployment successful
- [ ] Monitoring and logging configured
- [ ] Documentation complete
- [ ] User guide created

---

## References

- **Git Strategy:** `docs/GIT_STRATEGY.md`
- **OpenClaw Documentation:** `bots/business-partner/docs/`
- **Deployment Guide:** `docs/deployment/OPENCLAW_DEPLOYMENT_GUIDE.md`
- **Quick Reference:** `docs/deployment/OPENCLAW_QUICK_REFERENCE.md`

---

## Notes

- This checklist is a living document - update as you progress
- Check off items as they're completed
- Add notes and timestamps for important milestones
- Document any deviations from the plan
- Keep this file in sync with actual deployment status

---

**Last Updated:** February 7, 2026  
**Next Review:** After Phase 2 completion
