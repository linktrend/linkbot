# Gmail and Calendar Skills - Quick Reference

**Last Updated**: 2026-02-09

---

## Downloaded Skills

### 📧 Gmail Integration
- **Location**: `/skills/gmail-integration/`
- **Source**: https://github.com/bastienchabal/gmail-mcp
- **Language**: Python 3.10+
- **Status**: Beta (WIP)
- **Features**: Context-aware email, thread analysis, optional calendar

### 📅 Calendar Integration
- **Location**: `/skills/calendar-integration/`
- **Source**: https://github.com/nspady/google-calendar-mcp
- **Language**: TypeScript/Node.js
- **Status**: Production-ready (964+ stars)
- **Features**: Multi-account, recurring events, image-based creation

---

## Quick Setup

### Prerequisites
```bash
# Install uv for Python
pip install uv

# Verify Node.js
node --version  # Should be v20+
```

### Google Cloud Setup
1. Go to https://console.cloud.google.com/
2. Create project: "LiNKbot Google Integration"
3. Enable APIs:
   - Gmail API: https://console.cloud.google.com/flows/enableapi?apiid=gmail.googleapis.com
   - Calendar API: https://console.cloud.google.com/flows/enableapi?apiid=calendar-json.googleapis.com
4. Create OAuth 2.0 credentials (Desktop app)
5. Download credentials JSON
6. Add your email as test user

### Gmail Integration Setup
```bash
cd /Users/linktrend/Projects/LiNKbot/skills/gmail-integration
uv venv
source .venv/bin/activate
uv pip install -e .
```

### Calendar Integration Setup
```bash
cd /Users/linktrend/Projects/LiNKbot/skills/calendar-integration
npm install
npm run build
npm run auth  # First-time only
```

---

## Claude Desktop Configuration

Edit `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "gmail-mcp": {
      "command": "/Users/linktrend/Projects/LiNKbot/skills/gmail-integration/.venv/bin/mcp",
      "args": [
        "run",
        "/Users/linktrend/Projects/LiNKbot/skills/gmail-integration/gmail_mcp/main.py:mcp"
      ],
      "cwd": "/Users/linktrend/Projects/LiNKbot/skills/gmail-integration",
      "env": {
        "PYTHONPATH": "/Users/linktrend/Projects/LiNKbot/skills/gmail-integration",
        "CONFIG_FILE_PATH": "/Users/linktrend/Projects/LiNKbot/skills/gmail-integration/config.yaml",
        "GOOGLE_CLIENT_ID": "<your-client-id>",
        "GOOGLE_CLIENT_SECRET": "<your-client-secret>",
        "TOKEN_ENCRYPTION_KEY": "<generate-random-key>"
      }
    },
    "google-calendar": {
      "command": "npx",
      "args": ["@cocal/google-calendar-mcp"],
      "env": {
        "GOOGLE_OAUTH_CREDENTIALS": "/path/to/gcp-oauth.keys.json"
      }
    }
  }
}
```

---

## Common Commands

### Gmail Integration
```bash
# Activate environment
cd /Users/linktrend/Projects/LiNKbot/skills/gmail-integration
source .venv/bin/activate

# Update
git pull
uv pip install -e .

# Test authentication
python debug/auth_test.py
```

### Calendar Integration
```bash
cd /Users/linktrend/Projects/LiNKbot/skills/calendar-integration

# Update
git pull
npm install
npm run build

# Re-authenticate
npm run auth

# Manage accounts
npm run account auth work
npm run account auth personal
```

---

## Testing Queries

### Gmail
- "Show me an overview of my inbox"
- "Find all unread emails from last week"
- "Search for emails about the project deadline"
- "Draft a reply to the last email from John"

### Calendar
- "What meetings do I have this week?"
- "Check my availability tomorrow 2-4pm"
- "Create a calendar event for team meeting next Monday at 10am"
- "Find events that conflict across my work and personal calendars"

### Combined
- "Find the email about the quarterly review and add it to my calendar"
- "What events do I have related to the client presentation?"

---

## Troubleshooting

### Authentication Failed
1. Check OAuth credentials in Google Cloud Console
2. Verify test users are added
3. Ensure Desktop app type (not Web app)
4. Verify ports 3000-3004 are available

### Token Expired
```bash
# Calendar
npm run auth

# Gmail
# Delete ~/gmail_mcp_tokens/tokens.json and restart
```

### MCP Connection Failed
1. Restart Claude Desktop
2. Check claude_desktop_config.json syntax
3. Verify all paths are absolute
4. Check logs for errors

---

## Documentation

### Detailed Guides
- `/skills/SOURCED_SKILLS.md` - Complete research and recommendations
- `/skills/gmail-integration/SKILL_INFO.md` - Gmail setup details
- `/skills/calendar-integration/SKILL_INFO.md` - Calendar setup details
- `/skills/calendar-integration/docs/` - Extensive calendar documentation

### External Resources
- Gmail MCP: https://github.com/bastienchabal/gmail-mcp
- Calendar MCP: https://github.com/nspady/google-calendar-mcp
- Google Cloud Console: https://console.cloud.google.com/

---

## Alternative: Google Workspace MCP

If you need Drive, Docs, Sheets, etc.:

**Repository**: https://github.com/taylorwilsdon/google_workspace_mcp  
**Stars**: 1,329+

### Quick Install
```bash
uvx workspace-mcp --tool-tier core
```

### Features
- 12 Google services
- 65+ tools
- CLI mode for automation
- Tool tiers for quota management

---

## Next Steps

1. ⬜ Complete Google Cloud setup
2. ⬜ Install and configure both skills
3. ⬜ Test with basic queries
4. ⬜ Run security scan with skill-scanner
5. ⬜ Document LiNKbot-specific usage patterns

---

## Quick Links

- **ClawHub**: https://clawhub.ai
- **MCP Servers**: https://mcpservers.org
- **Google APIs**: https://console.cloud.google.com/apis/library
- **OAuth Setup**: https://console.cloud.google.com/apis/credentials

---

## Support

### Gmail Integration
- Issues: https://github.com/bastienchabal/gmail-mcp/issues
- Debug scripts in `/debug` directory

### Calendar Integration
- Issues: https://github.com/nspady/google-calendar-mcp/issues
- Docs in `/docs` directory
- Tests in `/src/tests` directory
