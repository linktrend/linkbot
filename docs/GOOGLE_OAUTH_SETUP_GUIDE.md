# Google Workspace OAuth Setup Guide for Lisa

## Overview
This guide walks you through authenticating Lisa with your Google Workspace account to enable Gmail, Calendar, Drive, Docs, Sheets, and Contacts access.

## Prerequisites
- ✅ gog CLI installed on VPS (v0.8.0)
- ✅ Google OAuth credentials configured
- ✅ Access to info@linktrend.media Google account
- ✅ SSH access to VPS (178.128.77.125)

## Step-by-Step Instructions

### Step 1: Open SSH Tunnel (Terminal 1)

Open a terminal on your LOCAL machine and run:

```bash
ssh -L 8080:localhost:8080 root@178.128.77.125
```

**Important:** 
- Keep this terminal window OPEN during the entire OAuth process
- This creates a tunnel that allows the VPS to communicate with your local browser

### Step 2: Start OAuth Flow (Terminal 2)

Open a SECOND terminal window and run:

```bash
ssh root@178.128.77.125
```

Then on the VPS, run:

```bash
gog auth add info@linktrend.media --services gmail,calendar,drive,contacts,docs,sheets --port 8080
```

**What happens:**
- gog starts a local web server on port 8080 (tunneled to your machine)
- It displays a URL like: `http://localhost:8080/auth/...`
- The command waits for you to complete authentication

### Step 3: Complete OAuth in Browser

1. **Copy the URL** displayed in Terminal 2 (starts with `http://localhost:8080/auth/...`)
2. **Open the URL** in your web browser
3. **Sign in** with your Google account: `info@linktrend.media`
4. **Review permissions** - You'll be asked to grant access to:
   - Gmail (read, send, modify)
   - Google Calendar (read, write)
   - Google Drive (read, write)
   - Google Docs (read, write)
   - Google Sheets (read, write)
   - Contacts (read, write)
5. **Click "Allow"** to grant all permissions
6. **Success page** - Browser will show "Authentication successful"
7. **Return to Terminal 2** - You'll see "Successfully authenticated"

### Step 4: Verify Authentication

In Terminal 2 (still on VPS), run these test commands:

```bash
# List authenticated accounts
gog auth list

# Test Gmail
gog gmail list --account info@linktrend.media --max 5

# Test Calendar  
gog calendar list-calendars --account info@linktrend.media

# Test Drive
gog drive list --account info@linktrend.media --max 10

# Test Contacts
gog contacts list --account info@linktrend.media --max 5
```

**Expected output:**
- `gog auth list` shows: `info@linktrend.media`
- Each test command returns data (emails, calendars, files, contacts)

### Step 5: Restart OpenClaw

Still in Terminal 2 (on VPS):

```bash
# Restart OpenClaw service
sudo systemctl restart openclaw

# Wait 10 seconds
sleep 10

# Check service status
sudo systemctl status openclaw

# Verify gog skill is ready
cd /root/openclaw-bot && node openclaw.mjs skills list | grep gog
```

**Expected output:**
- Service status: `active (running)`
- gog skill: `✓ ready`

### Step 6: Close SSH Tunnel

In Terminal 1, press `Ctrl+C` to close the SSH tunnel.

## Verification Checklist

- [ ] SSH tunnel opened successfully
- [ ] OAuth flow completed in browser
- [ ] `gog auth list` shows info@linktrend.media
- [ ] Gmail test command returns emails
- [ ] Calendar test command returns calendars
- [ ] Drive test command returns files
- [ ] OpenClaw service restarted successfully
- [ ] gog skill shows as "ready"

## Troubleshooting

### Port 8080 Already in Use

If port 8080 is busy on your local machine, use a different port:

```bash
# Terminal 1: Use port 8081
ssh -L 8081:localhost:8081 root@178.128.77.125

# Terminal 2: Specify port 8081
gog auth add info@linktrend.media --services gmail,calendar,drive,contacts,docs,sheets --port 8081
```

### OAuth URL Not Loading

1. Verify SSH tunnel is still open (Terminal 1)
2. Check that you're using `localhost` not `127.0.0.1`
3. Try a different browser (Chrome, Firefox, Safari)

### "Invalid Redirect URI" Error

This means the OAuth credentials have a different redirect URI configured. Check:

```bash
cat ~/.openclaw/secrets/google-oauth.json | grep redirect_uris
```

The redirect URI should be: `http://localhost:8080`

If it's different, you may need to update the Google Cloud Console OAuth configuration.

### Permissions Not Granted

If some services don't work after OAuth:

1. Check which scopes were granted:
   ```bash
   gog auth tokens list info@linktrend.media
   ```

2. Re-run OAuth with specific services:
   ```bash
   gog auth add info@linktrend.media --services gmail,calendar,drive,contacts,docs,sheets --port 8080
   ```

### Token Expired

If authentication stops working later:

```bash
# Remove old token
gog auth remove info@linktrend.media

# Re-authenticate (follow steps 1-3 again)
gog auth add info@linktrend.media --services gmail,calendar,drive,contacts,docs,sheets --port 8080
```

## Security Notes

- **Tokens are stored securely** in `~/.config/gogcli/` on the VPS
- **Refresh tokens** allow long-term access without re-authentication
- **Revoke access** anytime at: https://myaccount.google.com/permissions
- **Never share** your OAuth tokens or credentials

## What's Next?

After successful setup, Lisa can:
- ✅ Read and send emails via Gmail
- ✅ Create and manage calendar events
- ✅ Access and manage Drive files
- ✅ Read and edit Google Docs
- ✅ Read and edit Google Sheets
- ✅ Manage contacts

Test Lisa's new capabilities via Telegram:
- "Check my Gmail inbox"
- "What's on my calendar today?"
- "List my recent Drive files"
- "Create a new Google Doc titled 'Meeting Notes'"

## Reference

- **VPS IP:** 178.128.77.125
- **gog CLI:** v0.8.0
- **OAuth Credentials:** ~/.openclaw/secrets/google-oauth.json
- **Google Account:** info@linktrend.media
- **OpenClaw Gateway:** ws://0.0.0.0:18789

---

**Need Help?** Check the gog documentation: https://gogcli.sh
