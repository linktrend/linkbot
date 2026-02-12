# Google MCP Skills - OAuth Setup Guide

**Status:** Ready for Step 1 Completion  
**Date:** February 12, 2026  
**Target:** Lisa on VPS (root@178.128.77.125)

---

## Overview

This guide completes the 3-step plan to set up Google Workspace MCP skills and remove the `gog` CLI.

### What's Been Done ✅

1. ✅ OAuth credentials created (`credentials.json`) for all MCP skills:
   - `/root/linkbot/skills/shared/google-docs/credentials.json`
   - `/root/linkbot/skills/shared/google-sheets/credentials.json`
   - `/root/linkbot/skills/shared/google-slides/credentials.json`

2. ✅ Python dependencies installed:
   - `google-sheets` skill dependencies via `uv sync`
   - `gmail-integration` skill dependencies via `uv sync`

3. ✅ Node.js dependencies installed:
   - `google-docs` skill dependencies via `npm install`

4. ✅ Authentication script created:
   - `/root/linkbot/scripts/vps-google-auth.py`

### What You Need to Do 🔧

Run one OAuth flow that writes tokens for docs, sheets, slides (future), and gmail-integration:

---

## Step 1: Run Unified OAuth Bootstrap

**SSH into VPS:**
```bash
ssh root@178.128.77.125
```

**Run the authentication script:**
```bash
python3 /root/linkbot/scripts/vps-google-auth.py --reset
```

**You'll see an OAuth URL like this:**
```
https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=...
```

**Follow these steps:**

1. **Copy the URL** from the terminal

2. **Open it in your browser** on your computer (not the VPS)

3. **Log in** with Lisa's Google account

4. **Approve all requested permissions** when Google asks:
   - ✅ View and manage spreadsheets
   - ✅ View and manage Drive files

5. **Browser will redirect to `http://localhost/?code=...`**
   - The page will fail to load (that's expected!)
   - **Copy the ENTIRE URL** from your browser address bar
   - It looks like: `http://localhost/?code=4/0AanRRruT...&scope=https://...`

6. **Paste the URL** into the terminal prompt:
   ```
   Paste the redirect URL here: http://localhost/?code=4/0AanRRruT...
   ```

7. **Press Enter**

**Expected output includes token write summary for:**
- `/root/linkbot/skills/shared/google-docs/token.json`
- `/root/linkbot/skills/shared/google-sheets/token.json`
- `/root/linkbot/skills/shared/google-slides/token.json`
- `/root/linkbot/skills/shared/gmail-integration/tokens.json`

---

## Step 2: Test Everything

After OAuth setup is complete, test the MCP skills:

### Restart OpenClaw

```bash
systemctl restart openclaw
sleep 5
systemctl status openclaw
```

### Test Via Telegram

Message your Lisa bot: **@lisalinktrendlinkbot**

#### Test 1: Create Google Doc with Content
```
Lisa, create a Google Doc titled "Test from MCP Skill" and write a short poem about AI assistants in it
```

**Expected:**
- ✅ Doc created
- ✅ Content written
- ✅ Link provided

#### Test 2: Google Sheets
```
Lisa, create a Google Sheet titled "Budget 2026" with headers: Category, Amount, Notes
```

**Expected:**
- ✅ Sheet created
- ✅ Headers added
- ✅ Link provided

#### Test 3: Gmail
```
Lisa, search my emails from the last 2 days
```

**Expected:**
- ✅ Emails retrieved
- ✅ Summaries provided

### Monitor Logs

```bash
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
```

Watch for:
- ✅ MCP server initialization
- ✅ Google API calls
- ❌ Any authentication errors

---

## Step 3: Remove `gog` CLI (After Testing)

Once you confirm the MCP skills work, clean up the `gog` installation:

```bash
# SSH to VPS
ssh root@178.128.77.125

# Remove gog binaries
rm -f /usr/local/bin/gog
rm -f /usr/local/bin/gog-wrapper

# Remove gog configuration
rm -rf /root/.config/gogcli/

# Remove from environment files
sed -i '/GOG_KEYRING_PASSWORD/d' /root/openclaw-bot/.env
sed -i '/GOG_ACCOUNT/d' /root/openclaw-bot/.env
sed -i '/GOG_KEYRING_PASSWORD/d' /root/.openclaw/.env
sed -i '/GOG_ACCOUNT/d' /root/.openclaw/.env

# Remove from .bashrc
sed -i '/GOG_KEYRING_PASSWORD/d' /root/.bashrc

# Remove system-wide profile
rm -f /etc/profile.d/gog-keyring.sh

# Update systemd service (remove GOG_KEYRING_PASSWORD line)
sed -i '/GOG_KEYRING_PASSWORD/d' /etc/systemd/system/openclaw.service

# Reload and restart
systemctl daemon-reload
systemctl restart openclaw

echo "✅ gog CLI removed successfully!"
```

### Verify Cleanup

```bash
# Check gog is gone
which gog  # Should return: command not found

# Check environment is clean
grep -i gog /root/openclaw-bot/.env /root/.openclaw/.env /root/.bashrc || echo "✅ gog references removed"

# Verify OpenClaw still works
systemctl status openclaw
```

---

## Troubleshooting

### Issue: "Token not found" errors in logs

**Solution:** Re-run the OAuth setup:
```bash
cd /root/linkbot/skills/shared/google-sheets
rm -f token.json
python3 /root/linkbot/scripts/vps-google-auth.py
```

### Issue: "Invalid redirect URI"

**Check credentials.json has:**
```json
{
  "installed": {
    "redirect_uris": ["http://localhost"]
  }
}
```

### Issue: Google Docs still can't write content

**Verify:**
1. `token.json` exists in `/root/linkbot/skills/shared/google-docs/`
2. OpenClaw logs show MCP server starting
3. Skill is enabled in `openclaw.json`

---

## Why This Approach Works

### MCP Skills vs `gog` CLI

| Feature | MCP Skills | `gog` CLI |
|---------|------------|-----------|
| **Write doc content** | ✅ Yes | ❌ No |
| **Format text** | ✅ Yes (bold, italic, colors) | ❌ No |
| **Markdown support** | ✅ Yes | ❌ No |
| **Tables, images** | ✅ Yes | ❌ No |
| **Sheets formulas** | ✅ Yes | ⚠️ Basic |
| **Comments** | ✅ Yes | ❌ No |
| **Authentication** | One-time OAuth | Keyring password issues |

**Winner:** MCP Skills are superior in every way!

---

## Final Architecture

After completing all steps:

```
Lisa (OpenClaw Bot)
├── MCP Skills (Direct Google APIs)
│   ├── google-docs ──→ token.json (OAuth)
│   ├── google-sheets ─→ token.json (OAuth)
│   └── gmail-integration → ~/gmail_mcp_tokens/tokens.json (OAuth)
└── ❌ gog CLI (REMOVED)
```

**One authentication method, full functionality!**

---

## Summary

### Current Status

| Component | Status | Action Required |
|-----------|--------|-----------------|
| OAuth credentials | ✅ Created | None |
| Dependencies | ✅ Installed | None |
| google-sheets auth | ⚠️ Pending | **Run OAuth flow (you)** |
| google-docs auth | ⚠️ Pending | **Run OAuth flow (you)** |
| gmail-integration | ⏳ Auto | First-run auth |
| Testing | ⏳ Pending | After OAuth complete |
| `gog` removal | ⏳ Pending | After testing |

### Time Required

- **OAuth Setup:** 2-3 minutes (just google-sheets + google-docs)
- **Testing:** 5 minutes
- **Cleanup:** 2 minutes
- **Total:** ~10 minutes

---

## Quick Start Command

```bash
# SSH to VPS
ssh root@178.128.77.125

# Run OAuth setup
python3 /root/linkbot/scripts/vps-google-auth.py

# After completing browser auth, restart and test
systemctl restart openclaw
```

**That's it! Tomorrow you'll have fully working Google Workspace integration via MCP skills, with `gog` completely removed.** 🎯
