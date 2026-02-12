# Ready for Tomorrow - Quick Start Guide

**Good Morning! Here's what's ready for you:**

---

## ⏱️ 10-Minute Setup

### Step 1: OAuth Authentication (3 minutes)

```bash
ssh root@178.128.77.125
python3 /root/linkbot/scripts/vps-google-auth.py
```

**What happens:**
1. Script shows OAuth URL
2. You open it in browser
3. Log in with lisa@linktrend.media / <REDACTED_PASSWORD>
4. Approve permissions
5. Browser redirects to localhost (will fail - that's ok!)
6. Copy the ENTIRE URL from address bar
7. Paste into terminal
8. Script saves token.json

### Step 2: Test (5 minutes)

```bash
systemctl restart openclaw
```

Message @lisalinktrendlinkbot:

```
Lisa, create a Google Doc titled "Test MCP" and write a short poem about AI assistants in it
```

**Verify:**
- ✅ Doc created
- ✅ Content actually written (check the link)
- ✅ Not just hallucination

### Step 3: Remove gog (2 minutes)

```bash
/root/linkbot/scripts/remove-gog.sh
```

Type `yes` when prompted.

---

## 📚 Full Documentation

- **Detailed Guide:** `docs/GOOGLE_MCP_OAUTH_SETUP.md`
- **Status Report:** `3_STEP_PLAN_STATUS.md`
- **Original Fix:** `docs/GOOGLE_WORKSPACE_FIX_COMPLETE.md`

---

## ✅ What's Already Done

- ✅ OAuth credentials created
- ✅ All dependencies installed
- ✅ Authentication script ready
- ✅ Cleanup script ready
- ✅ Testing commands documented
- ✅ Everything committed to git

---

## 🎯 Expected Result

**After 10 minutes:**

Lisa will be able to:
- ✅ Create Google Docs AND write content
- ✅ Create Google Sheets AND populate data
- ✅ Search and read Gmail
- ✅ Create Calendar events with Meet links
- ✅ All via natural language through Telegram!

**And:**
- ✅ Single authentication method (OAuth)
- ✅ No more keyring password issues
- ✅ No more hallucinated operations
- ✅ Clean, simple architecture

---

**Start here:** `ssh root@178.128.77.125` then run the vps-google-auth.py script!
