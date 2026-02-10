# Google Workspace Integration Helper Scripts

This directory contains helper scripts to streamline the Google Workspace API setup process for Lisa (Business Partner Bot).

## Overview

These scripts guide you through the OAuth 2.0 and Service Account configuration required for Lisa to access Gmail, Calendar, Google Docs, Sheets, and Slides.

## Scripts

### 1. `setup-oauth.sh` - OAuth 2.0 Credentials Setup

**Purpose**: Configure OAuth 2.0 credentials for user authentication.

**What it does**:
- Opens Google Cloud Console in your browser
- Displays step-by-step checklist for:
  - Creating a Google Cloud Project
  - Enabling required APIs (Gmail, Calendar, Docs, Sheets, Slides, Drive, People)
  - Configuring OAuth consent screen
  - Creating OAuth 2.0 credentials
- Validates downloaded credentials JSON file
- Copies credentials to secure location with proper permissions
- Verifies JSON structure and security settings

**Usage**:
```bash
cd /Users/linktrend/Projects/LiNKbot/scripts/google-workspace
./setup-oauth.sh
```

**Time Required**: 20-30 minutes

**Prerequisites**:
- Google Workspace account with admin access
- Web browser

**Output**:
- Credentials stored at: `/Users/linktrend/Projects/LiNKbot/config/business-partner/secrets/google-oauth-credentials.json`
- Permissions: `600` (read/write owner only)

---

### 2. `setup-service-account.sh` - Service Account & Domain-Wide Delegation

**Purpose**: Configure service account with domain-wide delegation for Lisa to act on behalf of users.

**What it does**:
- Opens Google Cloud Console service accounts page
- Displays step-by-step checklist for:
  - Creating a service account
  - Generating service account key (JSON)
  - Enabling domain-wide delegation
- Validates service account JSON file
- Extracts client ID for Admin Console configuration
- Generates formatted scope list (comma-separated)
- Copies scopes to clipboard (if available)
- Opens Google Workspace Admin Console for delegation setup
- Securely stores credentials with proper permissions

**Usage**:
```bash
cd /Users/linktrend/Projects/LiNKbot/scripts/google-workspace
./setup-service-account.sh
```

**Time Required**: 15-20 minutes

**Prerequisites**:
- OAuth setup completed (run `setup-oauth.sh` first)
- Google Workspace admin access
- Web browser

**Output**:
- Credentials stored at: `/Users/linktrend/Projects/LiNKbot/config/business-partner/secrets/google-service-account.json`
- Permissions: `600` (read/write owner only)
- Client ID and scopes ready for Admin Console

---

## Workflow

**Recommended order**:

1. **Run OAuth Setup First**:
   ```bash
   ./setup-oauth.sh
   ```
   - Creates Google Cloud Project
   - Enables all required APIs
   - Configures OAuth credentials

2. **Run Service Account Setup Second**:
   ```bash
   ./setup-service-account.sh
   ```
   - Creates service account
   - Enables domain-wide delegation
   - Configures Admin Console

3. **Deploy to VPS**:
   ```bash
   # Transfer OAuth credentials
   scp /Users/linktrend/Projects/LiNKbot/config/business-partner/secrets/google-oauth-credentials.json \
       root@YOUR_VPS_IP:~/.openclaw/secrets/google-oauth.json

   # Transfer service account credentials
   scp /Users/linktrend/Projects/LiNKbot/config/business-partner/secrets/google-service-account.json \
       root@YOUR_VPS_IP:~/.openclaw/secrets/google-service-account.json
   ```

---

## Required APIs

Both scripts ensure these APIs are enabled:

| API | Purpose |
|-----|---------|
| Gmail API | Email management (send, read, modify) |
| Google Calendar API | Calendar events and scheduling |
| Google Docs API | Document creation and editing |
| Google Sheets API | Spreadsheet management |
| Google Slides API | Presentation creation |
| Google Drive API | File storage and access |
| People API | Contact management (optional) |

---

## Required OAuth Scopes

Both scripts configure these OAuth scopes:

### Gmail Scopes
```
https://www.googleapis.com/auth/gmail.readonly
https://www.googleapis.com/auth/gmail.send
https://www.googleapis.com/auth/gmail.modify
https://www.googleapis.com/auth/gmail.compose
```

### Calendar Scopes
```
https://www.googleapis.com/auth/calendar
https://www.googleapis.com/auth/calendar.events
```

### Drive & Docs Scopes
```
https://www.googleapis.com/auth/drive.file
https://www.googleapis.com/auth/documents
https://www.googleapis.com/auth/spreadsheets
https://www.googleapis.com/auth/presentations
```

### Profile Scopes
```
https://www.googleapis.com/auth/userinfo.email
https://www.googleapis.com/auth/userinfo.profile
```

---

## Features

### ✅ Interactive Guidance
- Step-by-step instructions with clear formatting
- Color-coded output (success, error, warning, info)
- Browser auto-opens to correct Google Cloud Console pages
- Pause at each step for user confirmation

### ✅ Validation & Error Handling
- JSON syntax validation
- OAuth credentials structure validation
- Service account key structure validation
- File existence checks
- Permission verification

### ✅ Security Best Practices
- Creates secure secrets directory (`chmod 700`)
- Sets restrictive file permissions (`chmod 600`)
- Validates credentials before storage
- Never commits credentials to Git (in `.gitignore`)

### ✅ Automation
- Extracts client ID from service account JSON
- Generates formatted scope list for Admin Console
- Copies client ID and scopes to clipboard (macOS/Linux)
- Opens correct URLs in browser

### ✅ Verification
- Confirms file storage location
- Verifies file permissions
- Validates JSON structure
- Displays summary of configuration

---

## Troubleshooting

### Script won't run
```bash
# Make scripts executable
chmod +x setup-oauth.sh setup-service-account.sh
```

### Browser doesn't open automatically
- URLs are displayed in terminal
- Manually copy and paste into browser

### JSON validation fails
- Ensure you downloaded the correct file from Google Cloud Console
- OAuth: File should be named `client_secret_*.json`
- Service Account: File should be named `PROJECT_ID-*.json`
- Check that file is not corrupted

### Permission errors
```bash
# Fix secrets directory permissions
chmod 700 /Users/linktrend/Projects/LiNKbot/config/business-partner/secrets

# Fix credentials file permissions
chmod 600 /Users/linktrend/Projects/LiNKbot/config/business-partner/secrets/*.json
```

### Python3 not found
- Scripts work without Python3 but skip advanced validation
- Install Python3 for full validation:
  ```bash
  brew install python3  # macOS
  ```

### Clipboard not working
- Scripts will display information for manual copy
- Client ID and scopes shown in terminal

---

## Security Notes

### ⚠️ Credential Security

**DO NOT**:
- ❌ Commit credentials to Git
- ❌ Share credentials files
- ❌ Store credentials in unsecured locations
- ❌ Use overly permissive file permissions

**DO**:
- ✅ Keep credentials in secrets directory
- ✅ Use `chmod 600` for credential files
- ✅ Use `chmod 700` for secrets directory
- ✅ Rotate service account keys annually
- ✅ Review API access quarterly

### 🔒 File Permissions

Correct permissions after running scripts:

```bash
$ ls -la /Users/linktrend/Projects/LiNKbot/config/business-partner/secrets/
drwx------  (700)  secrets/
-rw-------  (600)  google-oauth-credentials.json
-rw-------  (600)  google-service-account.json
```

### 🛡️ Access Control

- OAuth credentials: User authentication only
- Service account: Domain-wide delegation (acts on behalf of users)
- Both required for full Google Workspace integration

---

## Related Documentation

- **Full Setup Guide**: `/docs/guides/GOOGLE_WORKSPACE_SETUP.md`
- **Master Deployment Checklist**: `/docs/MASTER_DEPLOYMENT_CHECKLIST.md`
- **API Keys Setup**: `/docs/guides/API_KEYS_SETUP.md`

---

## Support

### Google Cloud Console
- **Console**: https://console.cloud.google.com/
- **APIs & Services**: https://console.cloud.google.com/apis/
- **Service Accounts**: https://console.cloud.google.com/iam-admin/serviceaccounts

### Google Workspace Admin
- **Admin Console**: https://admin.google.com/
- **Domain-Wide Delegation**: https://admin.google.com/ac/owl/domainwidedelegation

### Documentation
- **Google Workspace APIs**: https://developers.google.com/workspace
- **OAuth 2.0**: https://developers.google.com/identity/protocols/oauth2
- **Service Accounts**: https://cloud.google.com/iam/docs/service-accounts

---

## Version History

- **v1.0** (Feb 9, 2026): Initial release
  - OAuth setup script
  - Service account setup script
  - Full validation and error handling
  - Clipboard integration
  - Browser automation

---

**Project**: LiNKbot - Business Partner Bot (Lisa)  
**Scripts Version**: 1.0.0  
**Last Updated**: February 9, 2026  
**Maintainer**: LiNKtrend Venture Studio
