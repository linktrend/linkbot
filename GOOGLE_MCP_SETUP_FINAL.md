# Google MCP Setup - Final Step Required

**Status:** MCP servers installed and configured ✅  
**Issue:** Service account needs Drive folder access  
**Action Required:** Share a Google Drive folder (2 minutes)

---

## What's Working Now

✅ **`gog` CLI removed** - No more conflicts  
✅ **`mcporter` installed** - MCP client ready  
✅ **Google Docs MCP server** - Running with 30+ tools  
✅ **Google Sheets MCP server** - Running with 17 tools  
✅ **OpenClaw configured** - google-docs-mcp skill enabled  

---

## The Problem

The service account email is:
```
lisa-linkbot@linkbot-901208.iam.gserviceaccount.com
```

This service account needs permission to access your Google Drive to create/edit documents.

**Error:** `Permission denied. Make sure you have write access to the destination folder.`

---

## Solution: Share a Drive Folder (2 Minutes)

### Step 1: Create a Folder in Google Drive

1. Go to https://drive.google.com
2. Click **"New" → "Folder"**
3. Name it: **"Lisa Bot Documents"**
4. Click **"Create"**

### Step 2: Share the Folder with Service Account

1. **Right-click** the "Lisa Bot Documents" folder
2. Click **"Share"**
3. In the "Add people" field, paste:
   ```
   lisa-linkbot@linkbot-901208.iam.gserviceaccount.com
   ```
4. Set permission to: **"Editor"**
5. **Uncheck** "Notify people" (it's a service account, not a person)
6. Click **"Share"**

### Step 3: Get the Folder ID

1. **Open** the "Lisa Bot Documents" folder
2. Look at the URL in your browser:
   ```
   https://drive.google.com/drive/folders/1abc123xyz...
                                            └── This is the folder ID ──┘
   ```
3. **Copy the folder ID** (the long string after `/folders/`)

### Step 4: Configure Lisa to Use This Folder

Tell me the folder ID and I'll configure Lisa to create all documents in that shared folder.

---

## Alternative: Use Your Personal OAuth (Not Recommended)

If you don't want to use service account, we could set up OAuth with your personal Google account, but this requires:
- Browser authentication flow
- Token refresh management
- More complex setup

**Service account is simpler and more reliable for automation.**

---

## After You Share the Folder

Once you share the folder and give me the folder ID, Lisa will be able to:

✅ Create Google Docs with content  
✅ Write and format text  
✅ Use markdown for easy formatting  
✅ Create tables, insert images  
✅ Manage Google Sheets  
✅ All via natural language!

---

## Test Command After Setup

Once configured, test with:

```
Lisa, create a Google Doc in our shared folder titled "MCP Test" and write:

# Success!

This document was created by Lisa using:
- Google Docs MCP server
- Service account authentication  
- mcporter CLI client

The setup is complete!
```

---

## Why Service Account?

| Method | Setup | Maintenance | Reliability |
|--------|-------|-------------|-------------|
| **Service Account** | Share folder once | Zero | ✅ Never expires |
| OAuth Browser | Auth flow each setup | Token refresh | ⚠️ Can expire |
| `gog` CLI | Complex keyring | Password issues | ❌ We removed this |

---

**Please share the folder and give me the folder ID, then we'll test Lisa's document creation!** 📝
