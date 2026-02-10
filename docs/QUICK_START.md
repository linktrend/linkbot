# Quick Start - Deploy Lisa in 4 Days

**Status**: Configuration Finalized ✅  
**Cost**: $17-30/month (98% savings)  
**Timeline**: 4 days (35-40 hours)

---

## 🚀 Day-by-Day Plan

### **Day 1: Foundation** (5-6 hours)

```bash
# 1. Get API Keys (1-2 hours)
# Required: OpenRouter, Google AI, Brave Search
open https://openrouter.ai/  # Get Kimi K2.5 + FREE Devstral 2
open https://aistudio.google.com/apikey  # Get FREE Gemini models

# 2. Deploy to VPS (3-4 hours)
# SSH hardening, firewall, OpenClaw install
ssh root@YOUR_DROPLET_IP
# Follow: /docs/guides/VPS_DEPLOYMENT.md

# End of Day 1: OpenClaw running on VPS ✅
```

### **Day 2: Integrations** (10 hours)

```bash
# 1. Google Workspace (2-3 hours)
# Gmail, Calendar, Docs, Sheets, Slides
# Follow: /docs/guides/GOOGLE_WORKSPACE_SETUP.md

# 2. Telegram Bot (30 min)
# Fast notifications channel
# Follow: /docs/guides/TELEGRAM_BOT_SETUP.md

# 3. Antigravity Coding (2 hours)
# FREE Opus/Gemini for coding
npm install -g openclaw-antigravity-auth
# Configure OAuth with Google

# 4. Source Skills (5 hours)
# Download from ClawHub, GitHub
# End of Day 2: All integrations + skills sourced ✅
```

### **Day 3: Security** (10 hours)

```bash
# 1. Install Cisco Skill Scanner (30 min)
cd /Users/linktrend/Projects/LiNKbot/skills
git clone https://github.com/cisco-ai-defense/skill-scanner.git

# 2. Scan ALL Skills (4-6 hours)
# MANDATORY - no exceptions!
./scan-skill.sh gmail-skill
./scan-skill.sh calendar-skill
# ... all skills

# 3. Configure Approved Skills (2-3 hours)
# Customize for Lisa's environment
# End of Day 3: All skills security-validated ✅
```

### **Day 4: Production** (10 hours)

```bash
# 1. Deploy Skills to VPS (1-2 hours)
scp -r approved-skills/* root@VPS_IP:~/.openclaw/skills/

# 2. Test Everything (3-4 hours)
openclaw chat "Send test email"
openclaw chat "Create calendar event"
openclaw chat "Build simple Python script"
# Test ALL integrations

# 3. Multi-skill Workflow Test (2-3 hours)
openclaw chat "Research CRM tools, create comparison spreadsheet, 
schedule meeting, email me summary"

# 4. Final Documentation (1-2 hours)
# End of Day 4: PRODUCTION READY ✅
```

---

## 📋 Prerequisites Checklist

Before starting:
- [ ] DigitalOcean account with droplet (4GB+ RAM)
- [ ] Google Workspace admin access
- [ ] Telegram account
- [ ] Mac with Cursor IDE
- [ ] 35-45 hours available over 4 days
- [ ] Credit cards for API services (OpenRouter, optional Anthropic)

---

## 💰 Cost Setup

**Week 1 spending**:
- OpenRouter: $0-5 (testing Kimi K2.5)
- Google AI: $0 (FREE tier)
- Antigravity: $0 (FREE via OAuth)
- VPS: $24 (prorated for Feb)
- **Total**: ~$24-29

**Monthly ongoing**:
- AI models: $17-30
- VPS: $24
- **Total**: $41-54/month

---

## 🎯 Critical Success Factors

✅ **Use FREE models aggressively** - 60-70% of tasks  
✅ **Antigravity for all coding** - Zero cost  
✅ **Scan ALL skills** - No exceptions  
✅ **Task-level persistence** - No mid-task switching  
✅ **Context compaction** - Safeguard mode enabled  

---

## 📞 Need Help?

- **Full Checklist**: `/docs/MASTER_DEPLOYMENT_CHECKLIST.md`
- **Configuration**: `/docs/FINALIZED_CONFIGURATION.md`
- **Guides**: `/docs/guides/` (6 step-by-step guides)
- **Briefing**: `/docs/ORCHESTRATION_BRIEFING.md`

---

**Ready? Start here**:
```bash
open /Users/linktrend/Projects/LiNKbot/docs/guides/API_KEYS_SETUP.md
```
