# Antigravity Quick Start Guide

## 🚀 5-Minute Setup

### Step 1: Install Plugin (2 minutes)

```bash
cd /Users/linktrend/Projects/LiNKbot
./scripts/install-antigravity.sh
```

**What this does:**
- ✅ Checks OpenClaw installation
- ✅ Installs `openclaw-antigravity-auth` plugin
- ✅ Creates configuration files
- ✅ Generates OAuth setup guide
- ✅ Creates verification & test scripts

### Step 2: Setup OAuth (3 minutes)

```bash
# Read the guide
cat ~/.openclaw/ANTIGRAVITY_OAUTH_SETUP.md

# Quick steps:
# 1. Go to https://console.cloud.google.com/
# 2. Create project "openclaw-antigravity"
# 3. Enable: Cloud Code Assist API, Generative Language API
# 4. Create OAuth Client ID (Desktop app)
# 5. Download credentials JSON
# 6. Save to ~/.openclaw/google-oauth-credentials.json
# 7. Authenticate:

openclaw auth google --credentials ~/.openclaw/google-oauth-credentials.json
```

### Step 3: Verify (30 seconds)

```bash
~/.openclaw/verify-antigravity.sh
```

**Expected output:**
```
✓ Plugin installed: 1.0.0
✓ Antigravity config found
✓ OAuth credentials found
✓ OAuth token found (authenticated)
✓ Verification complete
```

### Step 4: Test (30 seconds)

```bash
~/.openclaw/test-antigravity.sh
```

## 🎯 Usage Examples

### Example 1: Generate New Feature

```bash
openclaw code --method antigravity "Create user authentication system with JWT"
```

**Result:**
- Generates multiple files (auth/login.js, auth/register.js, etc.)
- Includes tests
- Adds documentation
- **Cost: FREE** ✅

### Example 2: Quick Fix

```bash
openclaw edit src/errors.js --method file-based "Fix typo in error message"
```

**Result:**
- Fast, simple edit
- Single file change
- **Cost: FREE** ✅

### Example 3: Rate Limit Handling

```bash
openclaw code --method antigravity "Refactor database layer"

# If rate limit hit:
# ⚠ Antigravity rate limit reached
# ℹ Waiting 30 minutes...
# (automatic fallback to Devstral 2 after 4 hours)
```

## 📊 Rate Limits

| Limit | Value |
|-------|-------|
| Requests/minute | 60 |
| Requests/day | 1,500 |
| Quota reset | Daily at midnight UTC |
| Wait on limit | 30 minutes |
| Max wait | 4 hours |
| Fallback | Devstral 2 (FREE) |

## 🔧 Common Commands

### Check Installation
```bash
npm list -g openclaw-antigravity-auth
```

### Verify Configuration
```bash
~/.openclaw/verify-antigravity.sh
```

### Check Quota
```bash
openclaw quota google --remaining
```

### View Usage
```bash
openclaw quota google --daily
```

### Re-authenticate
```bash
openclaw auth google --credentials ~/.openclaw/google-oauth-credentials.json --force
```

### Reinstall Plugin
```bash
./scripts/install-antigravity.sh --force
```

### Regenerate Configs
```bash
./scripts/install-antigravity.sh --config-only
```

## 🛡️ Security Checklist

```bash
# ✅ Verify file permissions
ls -la ~/.openclaw/google-oauth-*.json
# Should show: -rw------- (600)

# ✅ Add to .gitignore
echo "google-oauth-credentials.json" >> ~/.openclaw/.gitignore
echo "google-oauth-token.json" >> ~/.openclaw/.gitignore

# ✅ Never commit credentials
git status  # Verify no credentials staged
```

## 🐛 Troubleshooting

### Plugin Not Found
```bash
# Install OpenClaw first
npm install -g openclaw

# Then install Antigravity
./scripts/install-antigravity.sh
```

### OAuth Fails
```bash
# Check credentials file exists
ls -la ~/.openclaw/google-oauth-credentials.json

# Re-authenticate
openclaw auth google --credentials ~/.openclaw/google-oauth-credentials.json --force
```

### Quota Exceeded
```bash
# Check remaining quota
openclaw quota google --remaining

# Wait for reset (automatic)
# Or use file-based fallback
openclaw code --method file-based "your task"
```

## 📚 Documentation

| Document | Location |
|----------|----------|
| Installation README | `/scripts/ANTIGRAVITY_README.md` |
| OAuth Setup | `~/.openclaw/ANTIGRAVITY_OAUTH_SETUP.md` |
| Workflow Guide | `~/.openclaw/ANTIGRAVITY_WORKFLOW.md` |
| Verification Script | `~/.openclaw/verify-antigravity.sh` |
| Test Script | `~/.openclaw/test-antigravity.sh` |

## 💰 Cost Savings

### Before Antigravity
- Coding: Claude Sonnet 4.5
- Cost: **$150-300/month**

### After Antigravity
- Coding: Google Cloud Code Assist (FREE) + Devstral 2 (FREE)
- Cost: **$0/month**
- Savings: **100%** ✅

### Annual Savings
- **$1,800 - $3,600** per bot
- **$5,400 - $10,800** for 3 bots

## 🎓 Key Concepts

### Task Persistence
**Once started with a method, finish with that method.**

✅ **Allowed:**
- Start Antigravity → Finish Antigravity
- Start file-based → Finish file-based
- Auto-fallback on rate limit

❌ **Not Allowed:**
- Manual switching mid-task

### Method Selection

**Use Antigravity for:**
- New features (100+ lines)
- Complex refactoring
- Multi-file changes

**Use File-Based for:**
- Quick fixes (< 50 lines)
- Single-file edits
- Emergency fixes

## ✅ Success Criteria

After setup, you should be able to:

- [x] Install plugin successfully
- [x] Authenticate with Google OAuth
- [x] Generate code with Antigravity
- [x] Verify quota tracking works
- [x] Test automatic fallback
- [x] Monitor daily usage

## 🚦 Next Steps

1. **Read Workflow Guide:**
   ```bash
   cat ~/.openclaw/ANTIGRAVITY_WORKFLOW.md
   ```

2. **Integrate with Lisa Bot:**
   ```bash
   cd /Users/linktrend/Projects/LiNKbot/bots/business-partner/
   # Add Antigravity config to openclaw.json
   ```

3. **Monitor Usage:**
   ```bash
   openclaw stats coding --daily
   ```

4. **Set Up Monitoring:**
   - Daily quota checks
   - Weekly usage reviews
   - Monthly cost analysis

## 📞 Support

- **OpenClaw Docs:** https://docs.openclaw.com/plugins/antigravity
- **Google Cloud Console:** https://console.cloud.google.com/
- **Issue Tracker:** https://github.com/openclaw/openclaw-antigravity-auth/issues

---

**Ready to code for FREE? Start with Step 1!** 🚀

**Last Updated:** February 9, 2026  
**Version:** 1.0.0
