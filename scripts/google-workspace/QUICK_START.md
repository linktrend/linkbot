# Google Workspace Setup - Quick Start Guide

## 🚀 Quick Setup (35-50 minutes total)

Two helper scripts automate the Google Workspace API configuration for Lisa.

---

## Step 1: OAuth Setup (20-30 minutes)

```bash
cd /Users/linktrend/Projects/LiNKbot/scripts/google-workspace
./setup-oauth.sh
```

**What it does**:
- ✅ Opens Google Cloud Console
- ✅ Guides you through project creation
- ✅ Lists 7 APIs to enable
- ✅ Configures OAuth consent screen
- ✅ Creates OAuth credentials
- ✅ Validates and securely stores credentials

**Output**: `config/business-partner/secrets/google-oauth-credentials.json`

---

## Step 2: Service Account Setup (15-20 minutes)

```bash
./setup-service-account.sh
```

**What it does**:
- ✅ Opens service accounts page
- ✅ Guides service account creation
- ✅ Generates service account key
- ✅ Extracts client ID
- ✅ Generates scope list
- ✅ Opens Admin Console for delegation
- ✅ Validates and securely stores credentials

**Output**: `config/business-partner/secrets/google-service-account.json`

---

## What You'll Need

### Before Starting
- [ ] Google Workspace account with **admin access**
- [ ] Web browser
- [ ] 35-50 minutes of uninterrupted time

### During Setup
You'll be prompted to:
1. Create a Google Cloud Project
2. Enable 7 APIs (Gmail, Calendar, Docs, Sheets, Slides, Drive, People)
3. Configure OAuth consent screen
4. Download OAuth credentials JSON
5. Create service account
6. Download service account key JSON
7. Configure domain-wide delegation in Admin Console

---

## APIs Enabled

Both scripts ensure these APIs are enabled:

| # | API | Purpose |
|---|-----|---------|
| 1 | Gmail API | Email management |
| 2 | Google Calendar API | Calendar events |
| 3 | Google Docs API | Document creation |
| 4 | Google Sheets API | Spreadsheets |
| 5 | Google Slides API | Presentations |
| 6 | Google Drive API | File storage |
| 7 | People API | Contacts (optional) |

---

## OAuth Scopes Configured

### Gmail (4 scopes)
- `gmail.readonly` - Read emails
- `gmail.send` - Send emails
- `gmail.modify` - Modify emails
- `gmail.compose` - Compose drafts

### Calendar (2 scopes)
- `calendar` - Full calendar access
- `calendar.events` - Manage events

### Drive & Docs (4 scopes)
- `drive.file` - File access
- `documents` - Google Docs
- `spreadsheets` - Google Sheets
- `presentations` - Google Slides

### Profile (2 scopes)
- `userinfo.email` - User email
- `userinfo.profile` - User profile

**Total**: 12 scopes

---

## Security Features

### ✅ Automated Security
- Creates secrets directory with `chmod 700`
- Sets file permissions to `chmod 600`
- Validates JSON structure
- Verifies credentials before storage

### ✅ File Permissions
```
drwx------  (700)  secrets/
-rw-------  (600)  google-oauth-credentials.json
-rw-------  (600)  google-service-account.json
```

### ✅ Git Protection
- Secrets directory in `.gitignore`
- Credentials never committed to repository

---

## After Setup

### 1. Verify Credentials
```bash
ls -la /Users/linktrend/Projects/LiNKbot/config/business-partner/secrets/
```

Expected output:
```
drwx------  secrets/
-rw-------  google-oauth-credentials.json
-rw-------  google-service-account.json
```

### 2. Transfer to VPS
```bash
# OAuth credentials
scp config/business-partner/secrets/google-oauth-credentials.json \
    root@YOUR_VPS_IP:~/.openclaw/secrets/google-oauth.json

# Service account credentials
scp config/business-partner/secrets/google-service-account.json \
    root@YOUR_VPS_IP:~/.openclaw/secrets/google-service-account.json
```

### 3. Configure OpenClaw
Edit `~/.openclaw/openclaw.json` on VPS to add Google integration settings.

See: `/docs/guides/GOOGLE_WORKSPACE_SETUP.md` Phase 4

### 4. Test Integration
```bash
# Test Gmail
openclaw chat "Send a test email to carlos@yourdomain.com"

# Test Calendar
openclaw chat "Create a calendar event for tomorrow at 2pm"

# Test Docs
openclaw chat "Create a Google Doc titled 'Test Document'"
```

---

## Troubleshooting

### Scripts won't run
```bash
chmod +x setup-oauth.sh setup-service-account.sh
```

### Browser doesn't open
- URLs are displayed in terminal
- Manually copy and paste into browser

### JSON validation fails
- Ensure correct file downloaded from Google Cloud Console
- Check file is not corrupted
- Verify JSON syntax

### Permission errors
```bash
chmod 700 config/business-partner/secrets
chmod 600 config/business-partner/secrets/*.json
```

### "Insufficient permissions" error
- Wait 10-15 minutes for delegation changes to propagate
- Verify domain-wide delegation is configured in Admin Console
- Restart OpenClaw: `sudo systemctl restart openclaw`

---

## Script Features

### 🎨 Color-Coded Output
- 🔵 **Blue**: Headers and info
- 🟢 **Green**: Success messages
- 🟡 **Yellow**: Warnings
- 🔴 **Red**: Errors
- 🔵 **Cyan**: Steps and URLs

### 🤖 Automation
- Opens correct URLs in browser
- Extracts client ID from service account JSON
- Generates formatted scope list
- Copies to clipboard (macOS/Linux)
- Validates JSON structure
- Sets secure permissions

### ✅ Validation
- JSON syntax checking
- OAuth credentials structure
- Service account key structure
- File existence verification
- Permission verification

### 📋 Guidance
- Step-by-step instructions
- Pause at each step
- Clear formatting
- Error handling
- Recovery options

---

## Time Breakdown

| Task | Time | Script |
|------|------|--------|
| Create Google Cloud Project | 5 min | `setup-oauth.sh` |
| Enable 7 APIs | 5 min | `setup-oauth.sh` |
| Configure OAuth consent | 5 min | `setup-oauth.sh` |
| Create OAuth credentials | 5 min | `setup-oauth.sh` |
| Validate and store | 2 min | `setup-oauth.sh` |
| **OAuth Total** | **20-30 min** | |
| Create service account | 5 min | `setup-service-account.sh` |
| Generate service account key | 3 min | `setup-service-account.sh` |
| Enable domain-wide delegation | 3 min | `setup-service-account.sh` |
| Configure Admin Console | 5 min | `setup-service-account.sh` |
| Validate and store | 2 min | `setup-service-account.sh` |
| **Service Account Total** | **15-20 min** | |
| **Grand Total** | **35-50 min** | |

---

## Next Steps

After completing both scripts:

1. ✅ **Google Workspace setup complete**
2. ➡️ **Next**: Telegram Bot Setup
   ```bash
   # See: /docs/guides/TELEGRAM_BOT_SETUP.md
   ```
3. ➡️ **Then**: Skills Installation
   ```bash
   # See: /docs/guides/SKILLS_INSTALLATION.md
   ```

---

## Support Resources

### Documentation
- **Full Guide**: `/docs/guides/GOOGLE_WORKSPACE_SETUP.md`
- **Master Checklist**: `/docs/MASTER_DEPLOYMENT_CHECKLIST.md`
- **Script README**: `README.md` (this directory)

### Google Resources
- **Cloud Console**: https://console.cloud.google.com/
- **Admin Console**: https://admin.google.com/
- **API Documentation**: https://developers.google.com/workspace

---

## Success Criteria

After running both scripts, you should have:

- ✅ Google Cloud Project created
- ✅ 7 APIs enabled
- ✅ OAuth consent screen configured
- ✅ OAuth credentials downloaded and stored
- ✅ Service account created
- ✅ Service account key downloaded and stored
- ✅ Domain-wide delegation enabled
- ✅ Admin Console delegation configured
- ✅ All credentials validated
- ✅ Secure permissions set (600/700)
- ✅ Ready for VPS deployment

---

**Quick Start Version**: 1.0.0  
**Last Updated**: February 9, 2026  
**Estimated Time**: 35-50 minutes  
**Difficulty**: Beginner-friendly with guided scripts
