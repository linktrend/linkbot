# Briefing Prompt for Next AI Agent

Copy this entire prompt to give to the next AI agent taking over this project:

---

## Context

You are taking over a project called **LiNKbot** - a multi-bot AI orchestrator system. The first bot, **Lisa** (Business Partner Bot), is deployed and running on a VPS but has one critical incomplete feature: Google Workspace integration.

## Your Mission

Complete the Google Workspace OAuth authentication so Lisa can write content to Google Docs, Sheets, and access Gmail via MCP (Model Context Protocol) servers.

## Quick Start Instructions

### Step 1: Read the Handoff Document

The previous AI agent created a comprehensive handoff document. Read this file FIRST:

**File:** `@AI_HANDOFF_BRIEFING.md` (23KB, 875 lines)

This contains:
- Complete repository structure
- How skills, agents, and MCP servers work
- Deployment workflow
- Current status and known issues
- All file locations and paths

### Step 2: Understand the Problem

**Current State:**
- ✅ MCP servers installed (google-docs, google-sheets, gmail-integration)
- ✅ `mcporter` CLI configured
- ✅ Service account exists
- ❌ OAuth authentication incomplete (NO token.json files)

**What's Not Working:**
- Lisa cannot write content to Google Docs (fails with permission errors)
- MCP servers need OAuth tokens to function
- Multiple OAuth approaches tried and failed:
  - Service account (storage quota exceeded)
  - Web OAuth (firewall/redirect issues)
  - Device code flow (not supported by client type)
  - OOB flow (deprecated/hangs)

**Root Cause:**
- OAuth client configured as "Web application" in Google Cloud Console
- VPS doesn't have browser for interactive OAuth
- Firewall blocks external access to callback port
- Desktop app OAuth credentials would work better

### Step 3: Review Key Files

Read these files in order:

1. **`@AI_HANDOFF_BRIEFING.md`** - Complete overview (READ FIRST)
2. **`@docs/GOOGLE_WORKSPACE_FIX_COMPLETE.md`** - History of what was tried
3. **`@docs/GOOGLE_MCP_OAUTH_SETUP.md`** - OAuth setup attempts
4. **`@config/mcporter.json`** - MCP server configuration
5. **`@bots/lisa/config/lisa/openclaw.json`** - Lisa's active config

### Step 4: Navigate the Repository

**Local Repository:** `/Users/linktrend/Projects/LiNKbot/`

**Key Directories:**
- `bots/lisa/` - Lisa bot code and config
- `skills/` - Shared skills (including MCP servers)
  - `skills/shared/google-docs/` - Google Docs MCP server (Node.js)
  - `skills/shared/google-sheets/` - Google Sheets MCP server (Python)
  - `skills/mcp-wrappers/google-docs-mcp/` - OpenClaw wrapper
- `agents/` - Specialized AI agents
- `scripts/` - Deployment and security tools
- `config/` - Shared configuration (mcporter.json)
- `docs/` - Documentation

**VPS Paths:**
- `/root/linkbot/` - Git clone (synced with local)
- `/root/.openclaw/` - Runtime data and secrets
- `/root/.openclaw/.env` - Main environment file (API keys)
- `/root/.openclaw/secrets/` - OAuth credentials, service accounts

### Step 5: Understand MCP Architecture

**How it works:**
1. MCP servers run as separate processes (Node.js or Python)
2. They communicate via Model Context Protocol (stdin/stdout)
3. `mcporter` CLI acts as the client to call MCP servers
4. OpenClaw skills wrap `mcporter` calls to expose functionality to Lisa

**Configuration:** `config/mcporter.json` registers MCP servers

**Example MCP call:**
```bash
mcporter --config /root/linkbot/config/mcporter.json call google-docs.createDocument title="Test"
```

**Problem:** MCP servers need OAuth tokens to authenticate with Google APIs

**Missing Files:**
- `skills/shared/google-docs/token.json` (OAuth access/refresh tokens)
- `skills/shared/google-sheets/token.json`
- `skills/shared/gmail-integration/tokens.json`

### Step 6: Your Task

**Objective:** Generate OAuth tokens for the three MCP servers

**Constraints:**
- User's budget: Keep under $50 in API costs
- Must work on headless VPS (no GUI browser)
- Use Lisa's Google account: lisa@linktrend.media
- Password: <REDACTED_PASSWORD>

**Recommended Approach:**

**Option A: Desktop App OAuth (Recommended)**
1. Create new OAuth credentials in Google Cloud Console
   - Type: Desktop application
   - Scopes: Drive, Docs, Sheets, Gmail
2. Download credentials.json
3. Generate authorization URL
4. User opens URL on their Mac, approves
5. User copies authorization code back
6. Exchange code for tokens
7. Save token.json files to MCP server directories

**Option B: Local Machine OAuth**
1. Clone repo to user's Mac (`/Users/linktrend/Projects/LiNKbot/`)
2. Run OAuth flow locally (browser available)
3. Generate token.json files
4. Copy to VPS via deployment script

**Option C: Fix Web OAuth**
1. Configure proper SSL/domain for VPS
2. Update firewall to allow OAuth callback
3. Complete web OAuth flow

### Step 7: Testing Success

After generating tokens:

```bash
# SSH to VPS
ssh root@178.128.77.125

# Test MCP server
mcporter --config /root/linkbot/config/mcporter.json call google-docs.createDocument \
  title="Test Document" \
  content="This is a test from Lisa"

# Check if document was created (should return doc ID and URL)

# Test via Telegram
# Message @lisalinktrendlinkbot:
# "Lisa, create a Google Doc titled 'Test' with content 'Hello World'"

# Verify document exists in Google Drive
```

### Step 8: Deployment Workflow

**Standard workflow:**
1. Make changes locally
2. Commit to git: `git add -A && git commit -m "..." && git push`
3. Deploy: `./scripts/deploy-bot.sh lisa vps`
4. Verify: `ssh root@178.128.77.125 "systemctl status openclaw"`

**Or manually:**
```bash
ssh root@178.128.77.125
cd /root/linkbot
git pull
systemctl restart openclaw
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
```

## Important Notes

### Security
- Never commit real API keys or tokens to git
- Use `.gitignore` for `.env`, `token.json`, `credentials.json`
- Keep secrets in `/root/.openclaw/secrets/` on VPS

### User Profile
- Solo founder, non-technical
- Expects professional, production-ready solutions
- Budget-conscious (target $17-30/month, max $50)
- Frustrated with previous OAuth attempts

### Code Quality
- Use proper error handling
- Add logging for debugging
- Test on VPS, not just locally
- Verify operations actually work (no hallucinations)

### Architecture Decisions Already Made
- ✅ Use MCP servers (NOT gog CLI - removed)
- ✅ Monorepo structure
- ✅ Deployment via git + systemd
- ✅ Skills/agents security-scanned (67 items)
- ❌ Local testing (abandoned due to complexity)

## Quick Reference

**VPS IP:** 178.128.77.125  
**VPS User:** root  
**Lisa Telegram:** @lisalinktrendlinkbot  
**Lisa Gmail:** lisa@linktrend.media  
**Lisa Password:** <REDACTED_PASSWORD>  
**Shared Drive Folder:** 11ZfeG_-kHcXR-RIe08EaE3uM-aQde8Ta  

**Commands:**
```bash
# Check Lisa status
ssh root@178.128.77.125 "systemctl status openclaw"

# View logs
ssh root@178.128.77.125 "tail -f /tmp/openclaw/openclaw-\$(date +%Y-%m-%d).log"

# Restart Lisa
ssh root@178.128.77.125 "systemctl restart openclaw"

# List MCP servers
ssh root@178.128.77.125 "mcporter --config /root/linkbot/config/mcporter.json list"
```

## Success Criteria

You will know you've succeeded when:

1. ✅ OAuth tokens generated (token.json files exist)
2. ✅ `mcporter call google-docs.createDocument` creates a real document
3. ✅ Document URL opens in browser and shows content
4. ✅ Lisa responds via Telegram with working Google Doc links
5. ✅ No "permission denied" or "storage quota" errors
6. ✅ User confirms they can see the created documents

## Resources

**Google Cloud Console:** https://console.cloud.google.com  
**Project ID:** linkbot-901208  
**Service Account:** lisa-linkbot@linkbot-901208.iam.gserviceaccount.com  

**MCP Documentation:**
- Google Docs MCP: https://github.com/a-bonus/google-docs-mcp
- Google Sheets MCP: Check repo for Python implementation
- Gmail MCP: Check `/root/linkbot/skills/shared/gmail-integration/`

## Final Instructions

1. Start by reading `AI_HANDOFF_BRIEFING.md` completely
2. Don't repeat failed approaches (service account, web OAuth without SSL)
3. Focus on Desktop app OAuth or local machine OAuth
4. Test incrementally - verify each step works
5. Update user frequently - they're frustrated with lack of progress
6. When complete, confirm with user and provide test instructions

**Your immediate next action should be:**

Read `@AI_HANDOFF_BRIEFING.md` in full, then propose a specific OAuth approach with step-by-step instructions for the user.

---

## End of Briefing Prompt

Give this prompt to the next AI agent verbatim. They should have everything needed to complete the Google Workspace integration.
