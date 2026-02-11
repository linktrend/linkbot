# Antigravity Kit - Specialized Agents

**Source:** [Google Labs Antigravity Kit](https://github.com/linktrend/antigravity-kit)  
**Scanned:** February 11, 2026  
**Security Status:** ✅ All approved (100% pass rate)  
**Total Agents:** 20

---

## About Antigravity Kit

The Antigravity Kit is a collection of specialized AI agents originally developed by Google Labs. While the project is no longer officially maintained, all agents have been security scanned and validated for use in the LiNKbot ecosystem.

**Security Validation:**
- ✅ Cisco Skill Scanner (behavioral + LLM analysis)
- ✅ Semgrep SAST (static code analysis)
- ✅ TruffleHog (secrets detection)
- ✅ Provenance check (GitHub repo verification)
- Risk Score: 0/100 (all agents)

---

## Available Agents

### Development Specialists

1. **backend-specialist.md** - Backend development expert
2. **frontend-specialist.md** - Frontend development specialist  
3. **mobile-developer.md** - iOS & Android development
4. **game-developer.md** - Game development specialist
5. **devops-engineer.md** - DevOps & infrastructure

### Architecture & Design

6. **database-architect.md** - Database design & optimization
7. **orchestrator.md** - Multi-agent orchestration
8. **explorer-agent.md** - Codebase exploration

### Quality & Testing

9. **qa-automation-engineer.md** - QA automation specialist
10. **test-engineer.md** - Testing specialist
11. **debugger.md** - Systematic debugging
12. **performance-optimizer.md** - Performance optimization

### Security & Audit

13. **security-auditor.md** - Security auditing
14. **penetration-tester.md** - Penetration testing

### Project Management

15. **project-planner.md** - Project planning
16. **product-manager.md** - Product management
17. **product-owner.md** - Product ownership

### Analysis & Documentation

18. **code-archaeologist.md** - Code analysis & legacy systems
19. **documentation-writer.md** - Technical documentation
20. **seo-specialist.md** - SEO optimization

---

## Usage

Agents are **disabled by default**. To use an agent:

1. Enable in `bots/<bot-name>/config/<bot-name>/openclaw.json`:

```json
{
  "agents": {
    "antigravity": {
      "backend-specialist": { "enabled": true },
      "frontend-specialist": { "enabled": true }
    }
  }
}
```

2. Invoke agent from your bot:
```javascript
const result = await invokeAgent('backend-specialist', {
  task: 'Design REST API for user authentication'
});
```

---

## Security Scan Results

- **Scan Date:** 2026-02-11
- **Items Scanned:** 20 agents
- **Approved:** 20 (100%)
- **Rejected:** 0
- **Borderline:** 0
- **Cost:** $0.00 (4-layer scan)

**Reports:** `skills/scan-reports/antigravity/`

---

## Deployment

Agents are deployed selectively based on bot configuration. Only enabled agents are copied to deployment targets.

**Deployment Script:** `scripts/deploy-bot.sh`

---

## Support

- **Source Repository:** https://github.com/linktrend/antigravity-kit
- **Security Reports:** `/skills/scan-reports/antigravity/`
- **Issues:** Contact LiNKbot maintainer

**Note:** This is an abandoned Google Labs project. Use at your own discretion.
