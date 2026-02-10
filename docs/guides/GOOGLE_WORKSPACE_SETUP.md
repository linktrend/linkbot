# Google Workspace API Setup Guide - Business Partner Bot

## Overview

This guide configures Lisa's access to your Google Workspace (Gmail, Calendar, Google Docs, Sheets, Slides) so she can manage email, create calendar events, and generate documents as your strategic partner.

**Estimated Time**: 60-90 minutes  
**Prerequisites**: 
- Google Workspace account with admin access ✅ (confirmed)
- OpenClaw deployed on VPS
- Business email for Lisa created or identified

---

## Phase 1: Google Cloud Project Setup (20 minutes)

### 1.1 Create Google Cloud Project

1. Visit **Google Cloud Console**: https://console.cloud.google.com/
2. Sign in with your Google Workspace admin account
3. Click "Select a project" dropdown (top nav)
4. Click "New Project"

**Project Details**:
- **Project name**: `OpenClaw-BusinessPartner-Lisa`
- **Organization**: Your domain (auto-selected)
- **Location**: Your organization
- Click "Create"

**Wait ~30 seconds** for project creation, then click "Select Project"

---

### 1.2 Enable Required APIs

Navigate to **APIs & Services → Library**: https://console.cloud.google.com/apis/library

**Enable these APIs** (search and click "Enable" for each):

1. ✅ **Gmail API** - Email management
2. ✅ **Google Calendar API** - Calendar events
3. ✅ **Google Docs API** - Document creation/editing
4. ✅ **Google Sheets API** - Spreadsheet management
5. ✅ **Google Slides API** - Presentation creation
6. ✅ **Google Drive API** - File storage access
7. ✅ **People API** - Contact management (optional but recommended)

**How to enable each**:
- Search for API name in library
- Click on API
- Click "Enable" button
- Wait for confirmation (~5-10 seconds each)

---

### 1.3 Configure OAuth Consent Screen

**Navigate to**: APIs & Services → OAuth consent screen

**Step 1: Choose User Type**:
- Select **"Internal"** (recommended for Google Workspace)
  - Only users in your Workspace can authenticate
  - No Google verification required
  - Click "Create"

**Step 2: App Information**:
- **App name**: `Lisa - Business Partner Bot`
- **User support email**: Your admin email
- **App logo**: (optional, skip for now)
- **Application home page**: (leave blank or use your company website)
- **Authorized domains**: Your company domain (e.g., `linktrend.com`)
- **Developer contact**: Your admin email
- Click "Save and Continue"

**Step 3: Scopes**:
- Click "Add or Remove Scopes"
- **Search and add these scopes**:

```
Gmail:
- https://www.googleapis.com/auth/gmail.readonly
- https://www.googleapis.com/auth/gmail.send
- https://www.googleapis.com/auth/gmail.modify
- https://www.googleapis.com/auth/gmail.compose

Calendar:
- https://www.googleapis.com/auth/calendar
- https://www.googleapis.com/auth/calendar.events

Drive & Docs:
- https://www.googleapis.com/auth/drive.file
- https://www.googleapis.com/auth/documents
- https://www.googleapis.com/auth/spreadsheets
- https://www.googleapis.com/auth/presentations

Profile:
- https://www.googleapis.com/auth/userinfo.email
- https://www.googleapis.com/auth/userinfo.profile
```

- Click "Update"
- Click "Save and Continue"

**Step 4: Test Users**:
- (Skip if using "Internal" user type)
- Click "Save and Continue"

**Step 5: Summary**:
- Review settings
- Click "Back to Dashboard"

---

### 1.4 Create OAuth 2.0 Credentials

**Navigate to**: APIs & Services → Credentials

**Click "Create Credentials" → "OAuth client ID"**:

**Application type**: `Web application`

**Name**: `Lisa Business Partner Bot - OpenClaw`

**Authorized JavaScript origins**: (leave empty for CLI/API access)

**Authorized redirect URIs**: Add these:
```
http://localhost:8080
http://localhost:3000
http://localhost:5000
urn:ietf:wg:oauth:2.0:oob
```
(OpenClaw uses localhost for OAuth callback during setup)

**Click "Create"**

**IMPORTANT: Download credentials**:
- A popup appears with Client ID and Client Secret
- Click "Download JSON"
- Save as `google-oauth-credentials.json`
- **Copy to Mac**: `/Users/linktrend/Projects/LiNKbot/config/business-partner/secrets/google-oauth-credentials.json`

**Security**: These credentials are sensitive. Store securely.

```bash
# On Mac: Create secrets directory
mkdir -p /Users/linktrend/Projects/LiNKbot/config/business-partner/secrets

# Set permissions
chmod 700 /Users/linktrend/Projects/LiNKbot/config/business-partner/secrets

# Move downloaded JSON (adjust path if downloaded elsewhere)
mv ~/Downloads/client_secret_*.json /Users/linktrend/Projects/LiNKbot/config/business-partner/secrets/google-oauth-credentials.json

# Set restrictive permissions
chmod 600 /Users/linktrend/Projects/LiNKbot/config/business-partner/secrets/google-oauth-credentials.json
```

---

## Phase 2: Service Account Setup (15 minutes)

**Why Service Account?**: Allows Lisa to act on behalf of the business with domain-wide delegation.

### 2.1 Create Service Account

**Navigate to**: APIs & Services → Credentials

**Click "Create Credentials" → "Service account"**:

**Service account details**:
- **Name**: `lisa-business-partner-sa`
- **ID**: `lisa-business-partner-sa` (auto-generated)
- **Description**: `Service account for Lisa Business Partner Bot to access Gmail, Calendar, Docs, Sheets, Slides on behalf of users`
- Click "Create and Continue"

**Grant access (optional)**: 
- (Skip - we'll use domain-wide delegation instead)
- Click "Continue"

**Grant users access (optional)**:
- (Skip)
- Click "Done"

---

### 2.2 Generate Service Account Key

**From Credentials page**:
- Find your new service account in the list
- Click on the service account email
- Go to "Keys" tab
- Click "Add Key" → "Create new key"
- Choose **JSON** format
- Click "Create"

**Download**: `lisa-business-partner-sa-xxxxxx.json`

**Move to secure location**:
```bash
# On Mac
mv ~/Downloads/lisa-business-partner-sa-*.json /Users/linktrend/Projects/LiNKbot/config/business-partner/secrets/google-service-account.json

# Set permissions
chmod 600 /Users/linktrend/Projects/LiNKbot/config/business-partner/secrets/google-service-account.json
```

---

### 2.3 Enable Domain-Wide Delegation

**Still on service account details page**:
- Check "Enable Google Workspace Domain-wide Delegation"
- **Product name for consent**: `Lisa Business Partner Bot`
- Click "Save"

**Note the "Unique ID"** (a long number like `112233445566778899000`)
- You'll need this for Admin Console delegation

---

## Phase 3: Google Workspace Admin Delegation (20 minutes)

**Purpose**: Allow service account to act on behalf of users in your Workspace.

### 3.1 Access Google Workspace Admin Console

1. Visit: https://admin.google.com/
2. Sign in with **Workspace admin account**
3. Navigate to: **Security → Access and data control → API controls**

---

### 3.2 Configure Domain-Wide Delegation

**Click "Manage Domain Wide Delegation"**

**Click "Add new"**:

**Client ID**: `112233445566778899000` (your service account Unique ID from step 2.3)

**OAuth Scopes**: Paste all scopes (comma-separated):
```
https://www.googleapis.com/auth/gmail.readonly,https://www.googleapis.com/auth/gmail.send,https://www.googleapis.com/auth/gmail.modify,https://www.googleapis.com/auth/gmail.compose,https://www.googleapis.com/auth/calendar,https://www.googleapis.com/auth/calendar.events,https://www.googleapis.com/auth/drive.file,https://www.googleapis.com/auth/documents,https://www.googleapis.com/auth/spreadsheets,https://www.googleapis.com/auth/presentations,https://www.googleapis.com/auth/userinfo.email,https://www.googleapis.com/auth/userinfo.profile
```

**Click "Authorize"**

**Confirmation**: You should see your client listed with all scopes.

---

## Phase 4: Configure OpenClaw Integration (30 minutes)

### 4.1 Transfer Google Credentials to VPS

**On Mac**:
```bash
# Transfer OAuth credentials
scp /Users/linktrend/Projects/LiNKbot/config/business-partner/secrets/google-oauth-credentials.json root@YOUR_DROPLET_IP:~/.openclaw/secrets/google-oauth.json

# Transfer service account credentials
scp /Users/linktrend/Projects/LiNKbot/config/business-partner/secrets/google-service-account.json root@YOUR_DROPLET_IP:~/.openclaw/secrets/google-service-account.json
```

**On VPS**:
```bash
# SSH into VPS
ssh root@YOUR_DROPLET_IP

# Create secrets directory
mkdir -p ~/.openclaw/secrets
chmod 700 ~/.openclaw/secrets

# Set permissions on transferred files
chmod 600 ~/.openclaw/secrets/google-*.json

# Verify files exist
ls -la ~/.openclaw/secrets/
```

---

### 4.2 Update OpenClaw Configuration

**Edit `openclaw.json` on VPS**:
```bash
ssh root@YOUR_DROPLET_IP
nano ~/.openclaw/openclaw.json
```

**Add Google integration section** (after the `tools:` section):

```json5
  // ============================================================================
  // GOOGLE WORKSPACE INTEGRATION
  // ============================================================================
  integrations: {
    google: {
      enabled: true,
      
      // OAuth credentials for user authentication
      oauth: {
        credentialsPath: "~/.openclaw/secrets/google-oauth.json",
        scopes: [
          "https://www.googleapis.com/auth/gmail.readonly",
          "https://www.googleapis.com/auth/gmail.send",
          "https://www.googleapis.com/auth/gmail.modify",
          "https://www.googleapis.com/auth/calendar",
          "https://www.googleapis.com/auth/calendar.events",
          "https://www.googleapis.com/auth/drive.file",
          "https://www.googleapis.com/auth/documents",
          "https://www.googleapis.com/auth/spreadsheets",
          "https://www.googleapis.com/auth/presentations",
        ],
      },
      
      // Service account for domain-wide delegation
      serviceAccount: {
        credentialsPath: "~/.openclaw/secrets/google-service-account.json",
        subject: "lisa@yourdomain.com", // Replace with Lisa's email
      },
      
      // Gmail configuration
      gmail: {
        enabled: true,
        defaultSender: "lisa@yourdomain.com", // Replace with Lisa's email
        signature: "\n\n---\nLisa\nStrategic Operations & Execution Lead\nLiNKtrend Venture Studio",
        autoArchive: true,
        maxResults: 50,
      },
      
      // Calendar configuration
      calendar: {
        enabled: true,
        defaultCalendar: "primary",
        timeZone: "America/New_York", // Replace with your timezone
        defaultReminders: [
          { method: "email", minutes: 1440 }, // 1 day before
          { method: "popup", minutes: 30 },   // 30 min before
        ],
      },
      
      // Docs/Sheets/Slides configuration
      docs: {
        enabled: true,
        defaultFolder: "OpenClaw - Lisa", // Folder name in Drive
        shareByDefault: false,
      },
    },
  },
```

**Save**: `Ctrl+O`, Enter, `Ctrl+X`

**Restart OpenClaw**:
```bash
sudo systemctl restart openclaw
sudo journalctl -u openclaw -f
# Watch for any errors related to Google integration
```

---

### 4.3 Create Lisa's Google Workspace Account

**Option A: Use existing email** (if Lisa already has an account)
- Skip to 4.4

**Option B: Create new account**:

1. Visit **Google Workspace Admin Console**: https://admin.google.com/
2. Navigate to: **Directory → Users**
3. Click "Add new user"

**User details**:
- **First name**: `Lisa`
- **Last name**: `Strategic Operations`
- **Primary email**: `lisa@yourdomain.com`
- **Secondary email**: (optional, your personal email)
- **Organizational unit**: Select appropriate OU
- **Password**: Generate strong password
- **Ask to change password**: No (this is a bot account)

4. Click "Add new user"
5. **Important**: Save password securely (Lisa won't use it directly, but needed for account management)

---

### 4.4 Authenticate OpenClaw with Google

**From Mac**:
```bash
# Use OpenClaw CLI to initiate OAuth flow
openclaw integrations google auth --gateway lisa-production

# Follow prompts:
# 1. Browser will open with Google OAuth consent screen
# 2. Sign in as Lisa (or admin who can delegate)
# 3. Grant all requested permissions
# 4. Copy authorization code from browser
# 5. Paste into terminal

# Expected output: "Authentication successful! Refresh token saved."
```

**Alternative: Direct OAuth on VPS**:
```bash
# SSH into VPS
ssh root@YOUR_DROPLET_IP

# Run OAuth flow
openclaw integrations google auth

# If browser doesn't open, you'll get a URL
# Copy URL and open in your Mac browser
# Complete auth flow, copy code back to terminal
```

---

## Phase 5: Testing & Verification (30 minutes)

### 5.1 Test Gmail Integration

**Send test email from Lisa**:
```bash
openclaw chat --gateway lisa-production "Send a test email to carlos@yourdomain.com with subject 'Lisa Test - Gmail Integration' and body 'This is a test email from Lisa to verify Gmail integration is working correctly.'"
```

**Expected**:
- ✅ Email arrives in carlos@yourdomain.com inbox
- ✅ Sender shows "Lisa" (lisa@yourdomain.com)
- ✅ Signature includes "Strategic Operations & Execution Lead"

**Check sent items**:
- Log in to lisa@yourdomain.com webmail
- Verify email appears in Sent folder

---

### 5.2 Test Calendar Integration

**Create test event**:
```bash
openclaw chat --gateway lisa-production "Create a calendar event for tomorrow at 2pm titled 'Test Meeting - Calendar Integration' with 30 minute duration. Add a description: 'Testing Lisa's calendar integration capabilities.'"
```

**Expected**:
- ✅ Event appears in Lisa's Google Calendar
- ✅ Event has correct title, time, duration
- ✅ Reminders are configured (1 day before, 30 min before)

**Verify**:
- Visit https://calendar.google.com/
- Sign in as Lisa
- Check calendar for new event

---

### 5.3 Test Google Docs Integration

**Create test document**:
```bash
openclaw chat --gateway lisa-production "Create a Google Doc titled 'Test Document - Lisa Integration' with the following content: Title: 'Integration Test', Heading: 'Purpose', Body: 'This document tests Lisa's ability to create and edit Google Docs.' Save it to my Drive."
```

**Expected**:
- ✅ Document created in Lisa's Google Drive
- ✅ Content matches request
- ✅ Document is in "OpenClaw - Lisa" folder (if folder exists)

**Verify**:
- Visit https://drive.google.com/
- Sign in as Lisa
- Locate and open document

---

### 5.4 Test Google Sheets Integration

**Create test spreadsheet**:
```bash
openclaw chat --gateway lisa-production "Create a Google Sheet titled 'Test Spreadsheet - Lisa Integration' with columns: Name, Email, Status. Add 3 sample rows of data."
```

**Expected**:
- ✅ Spreadsheet created in Drive
- ✅ Columns and data match request
- ✅ Properly formatted

---

### 5.5 Test Google Slides Integration

**Create test presentation**:
```bash
openclaw chat --gateway lisa-production "Create a Google Slides presentation titled 'Test Presentation - Lisa Integration' with 3 slides: Title slide, Content slide, Closing slide."
```

**Expected**:
- ✅ Presentation created in Drive
- ✅ 3 slides with requested structure

---

## Phase 6: Advanced Configuration (Optional)

### 6.1 Email Filters and Rules

**Configure Lisa to handle emails intelligently**:

Edit `openclaw.json` on VPS:
```json5
gmail: {
  enabled: true,
  defaultSender: "lisa@yourdomain.com",
  signature: "\n\n---\nLisa\nStrategic Operations & Execution Lead\nLiNKtrend Venture Studio",
  
  // Auto-handling rules
  rules: [
    {
      name: "Priority Inbox",
      condition: "from:carlos@yourdomain.com OR label:priority",
      action: "alert", // Send Telegram notification
      priority: "high",
    },
    {
      name: "Auto-reply OOO",
      condition: "subject:[Out of Office]",
      action: "archive",
      notify: false,
    },
    {
      name: "Newsletter Archive",
      condition: "category:promotions OR category:updates",
      action: "archive",
      notify: false,
    },
  ],
  
  // Monitoring
  checkInterval: 60, // Check every 60 seconds
  maxResults: 50,
},
```

---

### 6.2 Calendar Sync & Scheduling

**Enable Lisa to manage your calendar**:

```json5
calendar: {
  enabled: true,
  defaultCalendar: "primary",
  timeZone: "America/New_York",
  
  // Scheduling preferences
  workingHours: {
    start: "09:00",
    end: "17:00",
    days: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
  },
  
  // Meeting defaults
  defaultMeetingDuration: 30, // minutes
  bufferBetweenMeetings: 15, // minutes
  
  // Reminders
  defaultReminders: [
    { method: "email", minutes: 1440 }, // 1 day
    { method: "popup", minutes: 30 },
  ],
},
```

---

## Troubleshooting

### "Invalid grant" or "Token expired"

**Problem**: Refresh token invalid or expired.

**Solution**: Re-authenticate:
```bash
openclaw integrations google auth --force
```

---

### "Insufficient permissions"

**Problem**: Service account doesn't have domain-wide delegation.

**Solution**:
1. Verify domain-wide delegation is enabled (Admin Console → Security → API Controls)
2. Verify all scopes are listed
3. Wait 10-15 minutes for changes to propagate
4. Restart OpenClaw: `sudo systemctl restart openclaw`

---

### Email not sending

**Check logs**:
```bash
sudo journalctl -u openclaw -n 100 | grep -i gmail
```

**Common issues**:
1. **Wrong sender email**: Verify `defaultSender` in `openclaw.json` matches Lisa's actual email
2. **Missing Gmail API**: Verify Gmail API is enabled in Google Cloud Console
3. **Authentication expired**: Re-run OAuth flow

---

### Calendar events not creating

**Check permissions**:
```bash
openclaw integrations google check-permissions
```

**Verify**:
1. Calendar API enabled in Cloud Console
2. Service account has calendar scopes
3. Lisa's account exists and is active

---

## Security Best Practices

✅ **Restrict service account access**:
- Only grant necessary scopes
- Review access quarterly
- Rotate service account keys annually

✅ **Monitor usage**:
```bash
# Check Google Workspace Admin Console → Reports → Audit Logs
# Review API usage and authentication events
```

✅ **Secure credentials**:
```bash
# Verify permissions on VPS
ls -la ~/.openclaw/secrets/
# Expected: drwx------ (700) for directory, -rw------- (600) for files
```

---

## Success Criteria

✅ OAuth credentials configured and authenticated  
✅ Service account created with domain-wide delegation  
✅ All required Google APIs enabled  
✅ Gmail: Can send and receive emails as Lisa  
✅ Calendar: Can create, read, update events  
✅ Docs: Can create and edit documents  
✅ Sheets: Can create and edit spreadsheets  
✅ Slides: Can create and edit presentations  
✅ Integration tested end-to-end  

---

## Next Steps

1. ✅ Google Workspace integration complete
2. ➡️ **Proceed to**: Telegram Bot Setup Guide
3. ➡️ **Then**: Skills Installation Guide

---

**Setup Time**: 60-90 minutes  
**Status**: Ready to configure  
**Prerequisites**: VPS deployed, API keys obtained
