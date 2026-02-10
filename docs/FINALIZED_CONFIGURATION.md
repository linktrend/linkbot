# Finalized Configuration - Business Partner Bot (Lisa)

**Date**: February 9, 2026  
**Status**: ✅ LOCKED AND READY FOR DEPLOYMENT  
**Cost**: $17-30/month (98% savings vs. $1,300 baseline)

---

## 🎯 Configuration Summary

### **Primary Decisions**

1. **Communication Channel**: Telegram (Slack can be added later)
2. **AI Model Strategy**: Hybrid OpenRouter + Direct APIs with FREE models priority
3. **Coding Approach**: Dual-track (Antigravity primary + File-based fallback)
4. **Context Management**: Safeguard mode + aggressive compaction + /new command
5. **Cost Optimization**: 98% savings through strategic FREE model usage

---

## 💰 Cost Breakdown (Monthly)

| Component | Model/Service | Cost | Notes |
|-----------|--------------|------|-------|
| **Strategic Reasoning** | Kimi K2.5 (OpenRouter) | $12-20 | Primary model for complex tasks |
| **Heartbeat** | Gemini Flash Lite (direct) | **$0** | FREE tier (45k req/month) |
| **Sub-agents** | Devstral 2 (OpenRouter) | **$0** | FREE coding model |
| **Coding (Antigravity)** | Google OAuth | **$0** | FREE Opus/Gemini access |
| **Coding (Fallback)** | Devstral 2 (OpenRouter) | **$0** | FREE file-based coding |
| **Skills (60-70%)** | Gemini Flash (direct) | **$0** | FREE tier usage |
| **Skills (20-30%)** | Kimi K2.5 (OpenRouter) | $5-10 | Premium skills only |
| **Images** | Gemini 3 Flash (direct) | **$0** | FREE vision model |
| **VPS** | DigitalOcean 4GB | $24 | Infrastructure |
| **TOTAL** | | **$41-54/month** | |

**Note**: Without VPS ($24), pure AI costs = **$17-30/month**

**Comparison**:
- Previous config: $1,300/month
- Finalized config: $41-54/month
- **Savings: 96-97%** 🎯

---

## 🤖 AI Models Configuration

### **Primary Model: Kimi K2.5**
- **Provider**: OpenRouter
- **Cost**: $0.45/$2.25 per 1M tokens
- **Usage**: Strategic reasoning, complex decision-making
- **Why**: 30x cheaper than Sonnet 4.5, #1 ranked for agentic tasks
- **Estimated monthly**: $12-20

### **Heartbeat: Gemini 2.5 Flash Lite**
- **Provider**: Google AI (direct API)
- **Cost**: **FREE** (up to 1,500 req/day)
- **Usage**: Status checks every 60 minutes
- **Why**: Zero cost for background monitoring
- **Estimated monthly**: **$0**

### **Sub-agents: Devstral 2**
- **Provider**: OpenRouter
- **Cost**: **FREE**
- **Usage**: Parallel tasks, complex coding
- **Why**: 73%+ SWE-bench, zero cost
- **Estimated monthly**: **$0**

### **Coding Primary: Antigravity**
- **Provider**: Google Cloud Code Assist (OAuth)
- **Cost**: **FREE** (uses Google's quota)
- **Usage**: All coding tasks (try first)
- **Why**: Free Opus 4.5 + Gemini access
- **Estimated monthly**: **$0**

### **Coding Fallback: Devstral 2 (File-based)**
- **Provider**: OpenRouter
- **Cost**: **FREE**
- **Usage**: When Antigravity fails or rate-limited
- **Why**: Free, reliable fallback
- **Estimated monthly**: **$0**

### **Skills Routing**
| Skill Type | Model | Cost | % of Tasks |
|------------|-------|------|------------|
| Email, Calendar, Docs | Gemini Flash (direct) | **FREE** | 60-70% |
| Document Gen, Tasks | Kimi K2.5 (OpenRouter) | $0.45/$2.25 | 20-30% |
| Financial Calc | DeepSeek Reasoner (OpenRouter) | $0.14/$0.28 | 5-10% |

### **Images: Gemini 3 Flash**
- **Provider**: Google AI (direct API)
- **Cost**: **FREE**
- **Usage**: Image analysis, vision tasks
- **Estimated monthly**: **$0**

---

## 🔄 Coding Workflow (Task-Level Persistence)

### **Strategy: Once Started, Must Finish**

```
New Coding Task Arrives
    ↓
Try Antigravity First (FREE Opus/Gemini)
    ↓
Task Started with Antigravity
    ↓
[If Rate Limit Hit Mid-Task]
    ↓
Wait 30 minutes, check every 5 min
    ↓
[If Still Limited After 30 min]
    ↓
Wait another 30 min (total 60 min)
    ↓
[Continue waiting up to 4 hours max]
    ↓
[If Rate Limit Lifts]
    ↓
Resume Antigravity (preserve continuity)
    ↓
Task Completes with Antigravity ✅

[If Complete Failure After 4 Hours]
    ↓
Switch to File-based Devstral (FREE)
    ↓
Task Completes with Devstral ✅
```

**Key Principle**: **No mid-task switching** - Preserves code continuity and architecture

### **Rate Limit Handling**
- **Initial wait**: 30 minutes
- **Check interval**: Every 5 minutes
- **Max wait**: 4 hours
- **Telegram updates**: Every 30 minutes
- **Only fallback on**: Complete failure (auth error, service down, 4-hour timeout)

### **User Notifications**
```
9:30 AM - 🔴 "Rate limit hit on dashboard project. Waiting 30 min for reset."
10:00 AM - 🟢 "Rate limit lifted. Dashboard coding resumed with Antigravity."
[If exceeds 1 hour] - ⏳ "Still waiting for rate limit. Task persisting..."
[If approaching 4 hours] - ⚠️ "Will switch to file-based in 15 min if not resolved."
```

---

## 📱 Communication: Telegram (Primary)

### **Why Telegram**
- ✅ Faster setup (30 min vs 1-2 hours for Slack)
- ✅ More secure encryption (MTProto 2.0, 256-bit AES)
- ✅ Data sovereignty (EU data residency, GDPR compliant)
- ✅ Perfect for solo founder use case
- ✅ Mobile-first notifications

### **Slack: Future Addition**
- Add later if team grows
- Enterprise controls become relevant with multiple users
- Deep workspace integrations (Salesforce, Jira, etc.)

---

## 🧠 Context Management (40-50% Token Reduction)

### **Safeguard Mode Compaction**
```json5
compaction: {
  enabled: true,
  mode: "safeguard",  // Prevents infinite retry loops
  keepRecentTokens: 8000,  // Aggressive (4-5 recent messages)
  reserveTokens: 8000,  // Space for response
  autoTrigger: true,
}
```

### **Session Pruning**
```json5
pruning: {
  enabled: true,
  mode: "cache-TTL",
  maxToolResults: 10,  // Keep only last 10 tool outputs
}
```

### **/new Command with Memory Persistence**
- Archives current session to `~/.openclaw/sessions/session-xxx.jsonl`
- Extracts key facts to long-term memory
- Starts fresh session with clean context
- **Memory remains searchable** - Lisa can query archived sessions
- **Result**: Fast responses (2-15 sec) + full context preservation

---

## 🎓 Per-Skill Model Routing

### **FREE Tier Skills** (60-70% of tasks)
- Gmail integration → Gemini Flash (FREE)
- Calendar integration → Gemini Flash (FREE)
- Web research → Gemini Flash (FREE)
- Google Docs → Gemini Flash (FREE)
- Google Sheets → Gemini Flash (FREE)
- Google Slides → Gemini Flash (FREE)

### **Mid-Tier Skills** (20-30% of tasks)
- Document generator → Kimi K2.5 ($0.45/$2.25)
- Task management → Kimi K2.5
- Meeting scheduler → Kimi K2.5

### **Specialized Skills** (5-10% of tasks)
- Financial calculations → DeepSeek Reasoner ($0.14/$0.28)

### **Coding Skills** (Dual-track, all FREE)
- Python coding → Antigravity (FREE) or Devstral sub-agent (FREE)
- TypeScript coding → Antigravity (FREE) or Devstral sub-agent (FREE)
- JavaScript coding → Antigravity (FREE) or Devstral sub-agent (FREE)

---

## 🏭 Factory Projects Strategy

### **Lisa Will NOT Handle**:
- App Factory projects (template-based customization)
- Website Factory projects (CMS multi-tenant system)

### **Separate Specialized Bots** (Weeks 2-4):
1. **Bot #2: AppFactory Bot** (Mac Mini, local models)
   - Specializes in starter kit customization
   - Learns app patterns over time
   - Uses local Ollama models (zero cost)

2. **Bot #3: WebFactory Bot** (Mac Mini, local models)
   - Specializes in template + CMS configuration
   - Manages website ID system
   - Uses local Ollama models (zero cost)

### **Bot-to-Bot Communication**:
- Shared filesystem (simplest)
- Lisa delegates factory tasks to specialized bots
- Factory bots report completion back to Lisa
- Lisa notifies you via Telegram

---

## 📋 API Keys Required

### **Required for Week 1**:
1. ✅ **OpenRouter API Key** - Kimi K2.5 + FREE Devstral 2
2. ✅ **Google AI API Key** - FREE Gemini models (critical!)
3. ✅ **Brave Search API Key** - FREE tier web research

### **Optional for Week 1**:
4. ⭕ **Anthropic API Key** - Emergency fallback (likely $0-5/month usage)

### **Set Up in Week 2**:
5. 🔜 **Google OAuth** - Antigravity integration (FREE coding)
6. 🔜 **Telegram Bot Token** - Notifications channel
7. 🔜 **Google Workspace OAuth** - Gmail, Calendar, Docs access

---

## ✅ Deployment Timeline

### **Day 1** (5-6 hours): Foundation
- API keys setup (OpenRouter, Google AI, Brave)
- VPS deployment with security hardening
- OpenClaw installation with finalized config
- Gateway testing

### **Day 2** (10 hours): Integrations + Coding
- Google Workspace setup (Gmail, Calendar, Docs)
- Telegram bot configuration
- Antigravity plugin installation (FREE coding)
- Skills scanner setup
- Source critical skills

### **Day 3** (10 hours): Skills Security
- Scan ALL skills with Cisco Skill Scanner
- Review risk scores, approve/reject
- Configure approved skills

### **Day 4** (10 hours): Testing & Production
- Deploy skills to VPS
- End-to-end testing (all skills, integrations)
- Multi-skill workflow testing
- Final system verification

**Total**: 35-40 hours over 4 days ✅

---

## 🎯 Success Criteria

### **Week 1 Goals**
- [x] Configuration finalized (98% cost savings)
- [ ] VPS deployed with security hardening
- [ ] OpenClaw running with Kimi K2.5 + FREE models
- [ ] All integrations working (Gmail, Calendar, Telegram)
- [ ] Antigravity coding operational
- [ ] All Tier 1 skills deployed and tested
- [ ] API costs < $20 for Week 1

### **Month 1 Goals**
- [ ] 99%+ uptime
- [ ] Average response time < 5 seconds
- [ ] API costs stabilized at $17-30/month
- [ ] User (Carlos) fully productive with Lisa
- [ ] Zero security incidents
- [ ] Coding tasks completing via Antigravity (FREE)

---

## 🔒 Security Posture

✅ **Network**: UFW firewall + IP whitelisting  
✅ **SSH**: Key-only auth, passwords disabled  
✅ **Secrets**: `.env` files with chmod 600  
✅ **Skills**: Mandatory Cisco Skill Scanner  
✅ **Context**: Sandboxed execution  
✅ **Multi-model**: Provider diversity for resilience  

---

## 📞 Support Resources

- **Documentation**: `/docs/guides/` (6 comprehensive guides)
- **Master Checklist**: `/docs/MASTER_DEPLOYMENT_CHECKLIST.md`
- **Orchestration Brief**: `/docs/ORCHESTRATION_BRIEFING.md`
- **OpenClaw Docs**: https://docs.openclaw.com
- **OpenRouter**: https://openrouter.ai/docs
- **Google AI Studio**: https://aistudio.google.com/

---

**Configuration Version**: 2.0 (Finalized)  
**Lock Date**: February 9, 2026  
**Status**: ✅ READY FOR DEPLOYMENT  
**Next Step**: Begin Phase 1 - API Keys Setup
