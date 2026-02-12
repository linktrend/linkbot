# AI Handoff Briefing - LiNKbot Project

**Project:** LiNKbot Multi-Bot Orchestrator  
**Current Bot:** Lisa (Business Partner Bot)  
**VPS:** root@178.128.77.125 (Lisa-LiNKbot)  
**Date:** February 12, 2026

---

## Quick Start for New AI Agent

### Step 1: Repository Structure Overview

**Read these files IN ORDER to understand the project:**

1. **`README.md`** - Project overview, goals, bot roster
2. **`SKILLS_AND_AGENTS_CATALOG.json`** - All 67 available skills/agents (67 items, 100% security-scanned)
3. **`SECURITY_SCANNING_COMPLETE.md`** - Security infrastructure and validation
4. **`docs/GOOGLE_WORKSPACE_FIX_COMPLETE.md`** - Current Google Workspace integration status
5. **`VPS_DEPLOYMENT_COMPLETE.md`** - VPS deployment architecture

### Step 2: Understand Core Architecture

```
/Users/linktrend/Projects/LiNKbot/    (Local monorepo)
├── bots/
│   └── lisa/                          (Bot-specific code)
│       ├── config/lisa/
│       │   ├── openclaw.json          (PRIMARY CONFIG - what's enabled)
│       │   └── .env.example           (API keys template)
│       ├── src/                       (Bot source code)
│       └── package.json
│
├── skills/                            (Shared skills - all bots can use)
│   ├── antigravity/                   (37 skills from Google Labs)
│   ├── coding/                        (Python, TypeScript coding skills)
│   ├── specialized/                   (Task management, financial, etc.)
│   ├── shared/                        (Cross-bot shared skills)
│   │   ├── google-docs/               (MCP server - Node.js)
│   │   ├── google-sheets/             (MCP server - Python)
│   │   ├── gmail-integration/         (MCP server - Python)
│   │   └── web-research/
│   └── mcp-wrappers/                  (OpenClaw skill wrappers for MCP)
│       └── google-docs-mcp/           (Wrapper with SKILL.md)
│
├── agents/                            (Specialized agents)
│   └── antigravity/                   (20 agents from Google Labs)
│
├── scripts/                           (Deployment & security tools)
│   ├── deploy-bot.sh                  (PRIMARY DEPLOYMENT SCRIPT)
│   ├── full-security-scan.sh          (Security scanner orchestrator)
│   ├── scan-antigravity-kit.sh
│   └── remove-gog.sh
│
├── config/                            (Shared configuration)
│   └── mcporter.json                  (MCP server registry - NOT YET ON VPS)
│
└── docs/                              (Documentation)
    ├── security/                      (Security policies)
    └── GOOGLE_*.md                    (Google Workspace setup guides)
```

### Step 3: VPS Deployment Structure

```
/root/                                 (VPS structure)
├── linkbot/                           (Git clone of monorepo)
│   ├── bots/lisa/
│   ├── skills/
│   ├── agents/
│   └── scripts/
│
├── openclaw-bot/                      (Symlink to current deployment)
│   ├── .env                          (Minimal - systemd env file)
│   └── [symlinked to /root/linkbot/bots/lisa/]
│
└── .openclaw/                         (Runtime data directory)
    ├── .env                          (MAIN ENV FILE - all API keys)
    ├── openclaw.json                 (Active config - synced from repo)
    ├── skills/ -> /root/linkbot/skills/  (Symlink)
    ├── agents/ -> /root/linkbot/agents/  (Symlink)
    ├── workspace/                    (Agent working directory)
    ├── credentials/                  (OAuth tokens, secrets)
    ├── secrets/
    │   ├── google-service-account.json
    │   └── google-oauth.json
    └── telegram/                     (Telegram session data)
```

---

## Critical Files to Understand

### Configuration Files (READ FIRST)

1. **`bots/lisa/config/lisa/openclaw.json`**
   - **What:** Primary bot configuration
   - **Contains:** Enabled skills/agents, model routing, API key references
   - **Deployment:** Synced to `/root/.openclaw/openclaw.json` on VPS
   - **Structure:**
     ```json
     {
       env: { /* API keys via ${VAR} */ },
       agents: { /* Model config, sub-agents */ },
       skills: {
         shared: { "google-docs-mcp": { enabled: true } },
         antigravity: { "behavioral-modes": { enabled: true } }
       }
     }
     ```

2. **`/root/.openclaw/.env`** (ON VPS ONLY)
   - **What:** Actual API keys (NOT in git)
   - **Contains:** OPENROUTER_API_KEY, GOOGLE_API_KEY, TELEGRAM_BOT_TOKEN, etc.
   - **Security:** chmod 600, never commit

3. **`SKILLS_AND_AGENTS_CATALOG.json`**
   - **What:** Master catalog of all security-scanned items
   - **Contains:** 67 items (10 existing + 57 Antigravity)
   - **Structure:**
     ```json
     {
       "name": "google-docs",
       "enabled": false,
       "risk_score": 0,
       "category": "productivity",
       "description": "...",
       "source": "antigravity-kit"
     }
     ```

---

## How Skills Work

### Skill Types

1. **Traditional OpenClaw Skills**
   - **Location:** `skills/{category}/{skill-name}/`
   - **Required:** `SKILL.md` with frontmatter metadata
   - **Loaded:** OpenClaw scans directories for SKILL.md files
   - **Enabled:** Via `openclaw.json` skills section

2. **MCP Servers** (Model Context Protocol)
   - **Location:** `skills/shared/{mcp-server-name}/`
   - **Structure:** Full server application (Node.js or Python)
   - **Protocol:** Separate process, communicates via MCP
   - **Client:** Accessed via `mcporter` CLI
   - **Wrapper:** Need `mcp-wrappers/{name}/SKILL.md` for OpenClaw integration

3. **MCP Wrapper Skills**
   - **Location:** `skills/mcp-wrappers/{name}/`
   - **Required:** `SKILL.md` that calls `mcporter`
   - **Purpose:** Bridge between OpenClaw and MCP servers
   - **Example:** `google-docs-mcp` wraps the `google-docs` MCP server

### Enabling Skills

**Method 1: Via openclaw.json (Runtime)**
```json
{
  "skills": {
    "shared": {
      "google-docs-mcp": { "enabled": true }
    }
  }
}
```

**Method 2: Via Catalog (Planning)**
- Edit `SKILLS_AND_AGENTS_CATALOG.json`
- Set `"enabled": true` for desired skills
- Transfer selections to `openclaw.json`

---

## How Agents Work

### Agent Types

1. **Antigravity Agents** (Markdown-based)
   - **Location:** `agents/antigravity/{agent-name}/`
   - **Required:** Agent markdown file (e.g., `project-planner.md`)
   - **Purpose:** Specialized AI behaviors/workflows
   - **Enabled:** Via `openclaw.json` agents section

### Enabling Agents

```json
{
  "agents": {
    "enabled": [
      "orchestrator",
      "project-planner",
      "technical-architect"
    ]
  }
}
```

---

## How MCP Servers Work (IMPORTANT!)

### Current MCP Setup

**MCP Registry:** `/root/linkbot/config/mcporter.json` (LOCAL ONLY, NOT ON VPS YET)

```json
{
  "mcpServers": {
    "google-docs": {
      "command": "node",
      "args": ["/root/linkbot/skills/shared/google-docs/index.js"],
      "env": {
        "SERVICE_ACCOUNT_PATH": "/root/.openclaw/secrets/google-service-account.json",
        "DRIVE_FOLDER_ID": "11ZfeG_-kHcXR-RIe08EaE3uM-aQde8Ta"
      }
    }
  }
}
```

**How to Use MCP Servers:**
```bash
# List available MCP servers
mcporter --config /root/linkbot/config/mcporter.json list

# Call an MCP tool
mcporter --config /root/linkbot/config/mcporter.json call google-docs.createDocument title="Test"
```

**Integration with OpenClaw:**
1. MCP server runs as separate process
2. OpenClaw skill wrapper calls `mcporter` CLI
3. `mcporter` communicates with MCP server
4. Results returned to OpenClaw

---

## Deployment Workflow

### Full Deployment Process

**Script:** `scripts/deploy-bot.sh`

**Usage:**
```bash
# From local machine
cd /Users/linktrend/Projects/LiNKbot
./scripts/deploy-bot.sh lisa vps
```

**What it does:**
1. Validates bot exists in `bots/{bot-name}/`
2. Reads config from `scripts/deploy-config.sh`
3. For remote (VPS):
   - SSHs to VPS
   - Performs `git pull` in `/root/linkbot/`
   - Copies config to `/root/.openclaw/openclaw.json`
   - Runs `npm install` if needed
   - Restarts systemd service
4. For local:
   - Copies files locally
   - Starts bot via PM2 or npm

### Manual Deployment

```bash
# SSH to VPS
ssh root@178.128.77.125

# Navigate to repo
cd /root/linkbot

# Pull latest changes
git pull

# Sync config
cp bots/lisa/config/lisa/openclaw.json /root/.openclaw/openclaw.json

# Restart service
systemctl restart openclaw

# Check status
systemctl status openclaw
journalctl -u openclaw -f
```

### Systemd Service

**Service file:** `/etc/systemd/system/openclaw.service`

```ini
[Unit]
Description=OpenClaw Business Partner Bot (Lisa)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/openclaw-bot
EnvironmentFile=/root/openclaw-bot/.env
Environment="PATH=/usr/local/bin:/usr/bin:/bin"
ExecStart=/usr/bin/node /root/openclaw-bot/openclaw.mjs gateway --bind lan --port 18789
Restart=always
RestartSec=10
```

---

## Google Workspace Integration (CURRENT STATE)

### Status: INCOMPLETE

**What's Installed:**
- ✅ MCP servers installed (google-docs, google-sheets, gmail-integration)
- ✅ Dependencies installed (npm, Python/uv)
- ✅ `mcporter` CLI installed globally
- ✅ MCP config created: `config/mcporter.json`
- ✅ Service account exists: `/root/.openclaw/secrets/google-service-account.json`
- ✅ Shared Drive folder: `11ZfeG_-kHcXR-RIe08EaE3uM-aQde8Ta`
- ❌ `gog` CLI removed (no longer used)

**What's NOT Working:**
- ❌ **OAuth authentication incomplete** - No token.json files
- ❌ Service account fails (storage quota exceeded)
- ❌ Web OAuth fails (redirect URI/firewall issues)
- ❌ Lisa cannot write content to Google Docs yet

**Root Cause:**
- OAuth client is "Web application" type (not Desktop app)
- Requires browser redirect to VPS URL
- VPS firewall blocks external access to port 18789
- Device code flow not supported by Web OAuth client

**Solution Required:**
1. Create Desktop app OAuth credentials in Google Cloud Console
2. OR: Configure web OAuth with proper SSL/domain
3. OR: Use OAuth from a local machine that has browser access

### Google Workspace Architecture

```
Lisa Bot
├── MCP Servers (Separate processes)
│   ├── google-docs (Node.js server)
│   ├── google-sheets (Python server)  
│   └── gmail-integration (Python server)
│
├── MCP Client: mcporter CLI
│   └── Config: /root/linkbot/config/mcporter.json
│
└── OpenClaw Skills (Call mcporter)
    └── google-docs-mcp/SKILL.md
```

---

## Security Infrastructure

### Security Scanning Pipeline (5 Layers)

**Scripts:** `scripts/full-security-scan.sh`

**Layers:**
1. **Cisco Skill Scanner** - OpenClaw-specific threats
2. **Semgrep** - SAST (Static Analysis)
3. **TruffleHog** - Secrets scanning
4. **AI Analysis** - GPT-4o-mini (optional, $0 if key not found)
5. **Provenance Check** - GitHub reputation analysis

**Results:**
- All 67 items scanned (10 existing + 57 Antigravity)
- 100% approved (risk score 0-60 threshold)
- $0 cost (AI layer skipped, key not configured)

**Reports Location:** `skills/scan-reports/`

---

## API Keys and Secrets

### Where Secrets Live

**On VPS:**
- `/root/.openclaw/.env` - Main environment file (all API keys)
- `/root/.openclaw/secrets/` - OAuth credentials, service accounts
- `/root/openclaw-bot/.env` - Minimal (systemd only, mostly empty now)

**Structure of .env:**
```bash
# AI Models
OPENROUTER_API_KEY=...
GOOGLE_API_KEY=...
ANTHROPIC_API_KEY=...

# Telegram
TELEGRAM_BOT_TOKEN=...
TELEGRAM_CHAT_ID=...

# Google Workspace
GOOGLE_OAUTH_CLIENT_ID=...
GOOGLE_OAUTH_CLIENT_SECRET=...
SERVICE_ACCOUNT_PATH=/root/.openclaw/secrets/google-service-account.json

# Other
BRAVE_API_KEY=...
```

### Never Commit These

- Any `.env` file with real values
- `token.json` files (OAuth tokens)
- Service account keys
- API keys

---

## Testing Lisa

### Via Telegram

**Bot Handle:** @lisalinktrendlinkbot

**Test Commands:**
```
"Lisa, what skills do you have?"
"Lisa, list your capabilities"
"Lisa, search my emails from yesterday"
```

### Via Logs

```bash
# SSH to VPS
ssh root@178.128.77.125

# Follow logs
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log

# Check service
systemctl status openclaw
journalctl -u openclaw -n 50
```

### Via Local Testing

**NOT CURRENTLY SET UP** - Local testing was attempted but abandoned due to missing `gog` CLI and OAuth complexity.

---

## Known Issues (CRITICAL)

### Issue 1: Google Workspace Not Working

**Problem:** Lisa cannot write content to Google Docs

**Root Cause:**
- MCP servers installed but not authenticated
- Service account has zero storage quota
- OAuth credentials are "Web app" type (need Desktop app)
- Web OAuth redirect blocked by VPS firewall

**What Was Tried:**
1. ❌ Service account - Storage quota exceeded
2. ❌ Web OAuth with callback server - Firewall blocked
3. ❌ Device code flow - Not supported by Web OAuth client
4. ❌ Manual OOB flow - Invalid redirect URI error

**Status:** UNRESOLVED

**Next Steps:**
- Option A: Create Desktop app OAuth credentials in Google Cloud Console
- Option B: Configure proper SSL/domain for web OAuth
- Option C: Use OAuth from local machine with browser

### Issue 2: gog CLI Removed

**Action Taken:** Removed `gog` CLI completely

**Files Removed:**
- `/usr/local/bin/gog`
- `/usr/local/bin/gog-wrapper`
- `/root/.config/gogcli/`
- All `GOG_KEYRING_PASSWORD` references

**Reason:** User wants to use MCP servers exclusively

**Impact:** No fallback for Google Workspace operations

---

## File Organization Conventions

### Skills

**Pattern:** `skills/{category}/{skill-name}/`

**Categories:**
- `antigravity/` - Google Labs Antigravity Kit skills
- `coding/` - Programming language skills
- `specialized/` - Domain-specific skills
- `shared/` - Cross-bot shared skills (including MCP servers)
- `mcp-wrappers/` - OpenClaw wrappers for MCP servers

**Required File:** `SKILL.md` with YAML frontmatter

**Example Structure:**
```
skills/antigravity/brainstorming/
└── brainstorming.md          (The actual agent/skill definition)
```

### Agents

**Pattern:** `agents/{category}/{agent-name}/`

**Categories:**
- `antigravity/` - Google Labs specialized agents

**Required File:** Agent markdown file (e.g., `orchestrator.md`)

**Example Structure:**
```
agents/antigravity/orchestrator/
└── orchestrator.md           (Agent behavior definition)
```

### MCP Servers

**Pattern:** `skills/shared/{mcp-server-name}/`

**Required Files:**
- `package.json` (Node.js) OR `pyproject.toml` (Python)
- `index.js` or main entry point
- `credentials.json` (OAuth credentials)
- `token.json` (Generated after OAuth)

**Example Structure:**
```
skills/shared/google-docs/
├── package.json
├── index.js                  (Entry point)
├── src/                      (TypeScript source)
├── dist/                     (Compiled JavaScript)
├── credentials.json          (OAuth client credentials)
└── token.json                (OAuth access/refresh tokens) ← MISSING
```

**OpenClaw Wrapper:**
```
skills/mcp-wrappers/google-docs-mcp/
└── SKILL.md                  (Calls mcporter CLI)
```

---

## Deployment Checklist

### Before Deploying

- [ ] Changes committed to git
- [ ] Config updated in `bots/lisa/config/lisa/openclaw.json`
- [ ] Dependencies updated (package.json, requirements.txt)
- [ ] Security scan passed (if new skills)

### Deployment Steps

```bash
# 1. Commit changes locally
cd /Users/linktrend/Projects/LiNKbot
git add -A
git commit -m "Your change description"
git push

# 2. Deploy to VPS
./scripts/deploy-bot.sh lisa vps

# 3. Verify on VPS
ssh root@178.128.77.125
systemctl status openclaw
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
```

### Manual Deployment (If script fails)

```bash
# SSH to VPS
ssh root@178.128.77.125

# Pull latest
cd /root/linkbot
git pull

# Sync config
cp bots/lisa/config/lisa/openclaw.json /root/.openclaw/openclaw.json

# Install dependencies (if needed)
cd /root/openclaw-bot
npm install

# Restart
systemctl restart openclaw
```

---

## Repository Navigation Guide

### Key Documentation Files

**Start Here:**
1. `README.md` - Project overview
2. `SECURITY_SCANNING_COMPLETE.md` - Phase 1 & 2 complete
3. `SKILLS_AND_AGENTS_CATALOG.json` - All available items

**Google Workspace:**
4. `docs/GOOGLE_WORKSPACE_FIX_COMPLETE.md` - gog removal, MCP setup
5. `docs/GOOGLE_MCP_OAUTH_SETUP.md` - OAuth setup guide
6. `GOOGLE_MCP_SETUP_FINAL.md` - Service account attempt
7. `3_STEP_PLAN_STATUS.md` - Original 3-step plan

**Deployment:**
8. `VPS_DEPLOYMENT_COMPLETE.md` - VPS architecture
9. `LOCAL_TESTING_GUIDE.md` - Local testing (incomplete)

**Skills & Agents:**
10. `agents/antigravity/README.md` - 20 agents documentation
11. `skills/antigravity/README.md` - 37 skills documentation
12. `LISA_ENABLED_SKILLS_AGENTS.md` - Current enabled items (16 skills + 5 agents)

### Finding Information

**Question:** "How do I enable a new skill?"
**Answer:** Read `LISA_ENABLED_SKILLS_AGENTS.md` then edit `bots/lisa/config/lisa/openclaw.json`

**Question:** "How does deployment work?"
**Answer:** Read `VPS_DEPLOYMENT_COMPLETE.md` and `scripts/deploy-bot.sh`

**Question:** "What security measures are in place?"
**Answer:** Read `SECURITY_SCANNING_COMPLETE.md` and `scripts/full-security-scan.sh`

**Question:** "How do MCP servers work?"
**Answer:** Read `docs/GOOGLE_WORKSPACE_FIX_COMPLETE.md` and check `config/mcporter.json`

**Question:** "What's the repo structure?"
**Answer:** Read `README.md` and run `find . -maxdepth 2 -type d | grep -v node_modules`

---

## Current Production Status

### ✅ Working on VPS

- OpenClaw service running (systemd)
- Telegram bot connected (@lisalinktrendlinkbot)
- 73 skills loaded (16 enabled)
- 5 agents enabled
- Basic chat and command handling

### ⚠️ Partially Working

- Skills work but some may have issues
- Agents loaded but not fully tested
- Gmail integration (uncertain - needs OAuth)
- Calendar operations (uncertain)

### ❌ Not Working

- **Google Docs content writing** - OAuth incomplete
- **Google Sheets** - OAuth incomplete
- Python coding skill (path issues)
- Local testing environment

---

## Git Workflow

### Current State

**Branch:** main  
**Latest Commit:** 52cc501 "Setup Google MCP via mcporter - needs folder sharing"  
**VPS Status:** Synced to 52cc501

### Making Changes

```bash
# 1. Make changes locally
# 2. Test if possible
# 3. Commit
git add -A
git commit -m "Description"
git push

# 4. Deploy
./scripts/deploy-bot.sh lisa vps
```

---

## Critical Paths Reference

### Local Repository
```
/Users/linktrend/Projects/LiNKbot/
```

### VPS Paths
```
/root/linkbot/                         (Git repo)
/root/openclaw-bot/                    (Symlink to bots/lisa)
/root/.openclaw/                       (Runtime data)
/root/.openclaw/.env                   (MAIN ENV FILE)
/root/.openclaw/openclaw.json          (Active config)
/root/.openclaw/secrets/               (OAuth, service account)
```

### Important Scripts
```
scripts/deploy-bot.sh                  (Deployment)
scripts/full-security-scan.sh          (Security scanning)
scripts/scan-antigravity-kit.sh        (Import Antigravity items)
scripts/remove-gog.sh                  (gog cleanup - already executed)
```

---

## Budget & Cost Tracking

**Cost Strategy:** 98% savings (target: $17-30/month vs $1,300 baseline)

**Model Usage:**
- Primary: Kimi K2.5 ($0.45/$2.25 per 1M)
- Heartbeat: Gemini 2.5 Flash Lite (FREE)
- Sub-agents: Devstral 2 (FREE)
- Skills: 60-70% use FREE Gemini models

**Security Scanning Cost:** $0 (AI layer skipped)

**Current OpenRouter Credit:** ~$80 available

---

## Troubleshooting

### Service Won't Start

```bash
# Check logs
journalctl -u openclaw -n 50

# Check for port conflicts
lsof -i :18789

# Check environment
systemctl show openclaw --property=Environment
```

### Skills Not Loading

```bash
# Verify skill exists
ls -la /root/linkbot/skills/

# Check openclaw.json
cat /root/.openclaw/openclaw.json | grep -A5 "skills"

# Check logs for errors
tail -100 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep -i error
```

### Git Pull Conflicts

```bash
# Stash local changes
cd /root/linkbot
git stash

# Pull
git pull

# Reapply if needed
git stash pop
```

---

## Next AI Agent Instructions

When you take over this project:

1. **First, READ these files:**
   - `README.md`
   - `SKILLS_AND_AGENTS_CATALOG.json`
   - `VPS_DEPLOYMENT_COMPLETE.md`
   - This file (`AI_HANDOFF_BRIEFING.md`)

2. **Understand the unresolved issue:**
   - Google Workspace MCP servers need OAuth authentication
   - Service account approach failed (storage quota)
   - Web OAuth approach blocked (firewall/SSL)
   - Solution: Create Desktop app OAuth OR fix web OAuth

3. **Respect the user's requirements:**
   - Keep costs under $50/month
   - Use MCP servers (not gog CLI)
   - Fully automate where possible
   - Professional, production-ready solutions

4. **Testing protocol:**
   - Always test on VPS via Telegram (@lisalinktrendlinkbot)
   - Monitor logs: `tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log`
   - Verify operations actually work (not hallucinations)

5. **Deployment workflow:**
   - Edit locally, commit to git, deploy via script
   - Never edit directly on VPS without committing
   - Always verify service restarts successfully

---

## File Locations Quick Reference

| What | Local Path | VPS Path |
|------|-----------|----------|
| Bot code | `bots/lisa/` | `/root/linkbot/bots/lisa/` |
| Config | `bots/lisa/config/lisa/openclaw.json` | `/root/.openclaw/openclaw.json` |
| Skills | `skills/` | `/root/linkbot/skills/` (symlinked) |
| Agents | `agents/` | `/root/linkbot/agents/` (symlinked) |
| Scripts | `scripts/` | `/root/linkbot/scripts/` |
| Secrets | N/A | `/root/.openclaw/secrets/` |
| Logs | N/A | `/tmp/openclaw/openclaw-YYYY-MM-DD.log` |
| Service | N/A | `/etc/systemd/system/openclaw.service` |

---

## Summary for Next Agent

**Project State:** 
- Infrastructure: ✅ Complete
- Security: ✅ Complete (67 items scanned)
- Deployment: ✅ Working
- Skills/Agents: ✅ 21 items enabled
- Google Workspace: ❌ OAuth incomplete

**Immediate Priority:**
Fix Google Workspace OAuth authentication so Lisa can write content to Google Docs.

**Approach:**
1. Create Desktop app OAuth credentials in Google Cloud Console
2. OR configure web OAuth properly with SSL
3. Generate token.json files for MCP servers
4. Test document creation with content
5. Verify no hallucinations

**Success Criteria:**
- Lisa creates a Google Doc
- Content is actually written (not empty)
- User opens link and sees the content
- No "gog CLI cannot write content" messages

---

## Contact Info

**User:** Solo founder, non-technical  
**VPS:** root@178.128.77.125  
**Telegram:** @lisalinktrendlinkbot  
**Google Account:** lisa@linktrend.media  
**GitHub Repo:** https://github.com/linktrend/linkbot

---

**This document should give you everything you need to take over and complete the Google Workspace integration.**
