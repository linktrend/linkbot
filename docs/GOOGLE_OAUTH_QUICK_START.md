# Google OAuth Quick Start - 5 Minute Setup

## 🚀 Quick Commands

### Terminal 1 (Keep Open)
```bash
ssh -L 8080:localhost:8080 root@178.128.77.125
```

### Terminal 2 (Run OAuth)
```bash
ssh root@178.128.77.125

gog auth add info@linktrend.media \
  --services gmail,calendar,drive,contacts,docs,sheets \
  --port 8080
```

### Browser
1. Copy the URL from Terminal 2: `http://localhost:8080/auth/...`
2. Open in browser
3. Sign in with: **info@linktrend.media**
4. Click **Allow** for all permissions
5. Wait for "Authentication successful"

### Verify (Terminal 2)
```bash
# Check auth
gog auth list

# Test Gmail
gog gmail list --account info@linktrend.media --max 3

# Test Calendar
gog calendar list-calendars --account info@linktrend.media

# Restart OpenClaw
sudo systemctl restart openclaw
sleep 10
cd /root/openclaw-bot && node openclaw.mjs skills list | grep gog
```

### Expected Result
```
✓ ready   │ 🎮 gog  │ Google Workspace CLI for Gmail, Calendar, Drive, Contacts, Sheets, and Docs
```

## ✅ Done!

Lisa can now access your Google Workspace.

---

**Full Guide:** See `GOOGLE_OAUTH_SETUP_GUIDE.md` for detailed instructions and troubleshooting.
