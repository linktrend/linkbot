# Antigravity Plugin Installation

## Overview

The Antigravity plugin enables **FREE** coding assistance for OpenClaw using:
- **Primary:** Google Cloud Code Assist (Gemini 2.0 Flash Thinking)
- **Fallback:** Devstral 2 via OpenRouter

This provides enterprise-grade coding capabilities at zero cost, with automatic fallback handling for rate limits and availability issues.

## Quick Start

```bash
# Install Antigravity plugin and generate all configuration
cd /Users/linktrend/Projects/LiNKbot
./scripts/install-antigravity.sh

# Setup OAuth credentials (follow interactive guide)
cat ~/.openclaw/ANTIGRAVITY_OAUTH_SETUP.md

# Verify installation
~/.openclaw/verify-antigravity.sh

# Run tests
~/.openclaw/test-antigravity.sh
```

## Installation Script Features

The `install-antigravity.sh` script provides:

### ✅ Pre-flight Checks
- Verifies OpenClaw is installed globally
- Checks npm availability
- Detects existing plugin installation

### ✅ Plugin Installation
- Installs `openclaw-antigravity-auth` via npm
- Supports force reinstall with `--force` flag
- Configuration-only mode with `--config-only`

### ✅ Configuration Generation
- **antigravity-config.json:** Plugin configuration with rate limits
- **openclaw-antigravity.json:** OpenClaw integration settings
- Secure file permissions (600)
- Automatic backup of existing configs

### ✅ Documentation
- **ANTIGRAVITY_OAUTH_SETUP.md:** Step-by-step OAuth setup
- **ANTIGRAVITY_WORKFLOW.md:** Dual-track coding workflow guide
- Comprehensive troubleshooting sections

### ✅ Verification & Testing
- **verify-antigravity.sh:** Installation and config verification
- **test-antigravity.sh:** Comprehensive functionality tests
- OAuth setup helper
- Quota checking

### ✅ Error Handling
- Missing OAuth credentials
- Google quota exceeded
- Authentication failures
- Network errors
- Invalid requests

## Usage Options

### Standard Installation
```bash
./scripts/install-antigravity.sh
```

Installs plugin, generates all configs, and creates verification scripts.

### Force Reinstall
```bash
./scripts/install-antigravity.sh --force
```

Reinstalls plugin even if already present. Useful for updates.

### Configuration Only
```bash
./scripts/install-antigravity.sh --config-only
```

Regenerates configuration files without reinstalling plugin.

### Help
```bash
./scripts/install-antigravity.sh --help
```

Shows usage information and available options.

## Dual-Track Coding Workflow

### Core Principle: Task Persistence

**Once a coding task starts with a method, it MUST finish with that method.**

### Method Selection

**Use Antigravity for:**
- New features (100+ lines)
- Complex refactoring
- Multi-file changes
- Architecture changes
- Code generation from scratch

**Use File-Based for:**
- Simple edits (< 50 lines)
- Quick fixes
- Single-file changes
- Emergency fixes
- When Antigravity unavailable

### Rate Limit Handling

```
Rate Limit Detected
       ↓
Wait 30 minutes
       ↓
Quota available? ──YES──→ Resume Antigravity
       ↓
      NO
       ↓
Wait up to 4 hours total
       ↓
Still limited? ──YES──→ Fallback to Devstral 2
       ↓
      NO
       ↓
Resume Antigravity
```

## Configuration Files

After installation, the following files are created in `~/.openclaw/`:

| File | Purpose |
|------|---------|
| `antigravity-config.json` | Plugin configuration, rate limits, error handling |
| `openclaw-antigravity.json` | OpenClaw integration and routing rules |
| `ANTIGRAVITY_OAUTH_SETUP.md` | OAuth credentials setup guide |
| `ANTIGRAVITY_WORKFLOW.md` | Dual-track coding workflow documentation |
| `verify-antigravity.sh` | Installation verification script |
| `test-antigravity.sh` | Comprehensive test suite |
| `google-oauth-credentials.json` | OAuth credentials (you create this) |
| `google-oauth-token.json` | OAuth token (auto-generated on auth) |

## OAuth Setup Process

### 1. Create Google Cloud Project

```bash
# Open Google Cloud Console
open https://console.cloud.google.com/

# Create new project: "openclaw-antigravity"
```

### 2. Enable APIs

Required APIs:
- Cloud Code Assist API
- Generative Language API
- Cloud Resource Manager API

### 3. Create OAuth Credentials

1. Configure OAuth consent screen (External)
2. Add scopes:
   - `https://www.googleapis.com/auth/cloud-platform`
   - `https://www.googleapis.com/auth/generative-language`
3. Create OAuth Client ID (Desktop app)
4. Download credentials JSON

### 4. Install Credentials

```bash
# Copy downloaded file
cp ~/Downloads/client_secret_*.json ~/.openclaw/google-oauth-credentials.json

# Set permissions
chmod 600 ~/.openclaw/google-oauth-credentials.json
```

### 5. Authenticate

```bash
openclaw auth google --credentials ~/.openclaw/google-oauth-credentials.json
```

This opens a browser for Google sign-in and saves the refresh token.

## Rate Limits

### Google Cloud Code Assist (FREE Tier)

- **Requests per minute:** 60
- **Requests per day:** 1,500
- **Quota reset:** Daily at midnight UTC

### Automatic Handling

OpenClaw automatically:
1. Tracks quota usage in real-time
2. Waits 30 minutes if quota exceeded
3. Falls back to Devstral 2 after 4 hours
4. Resumes Antigravity when quota resets
5. Notifies user of all state changes

## Error Messages & Solutions

### "OpenClaw is not installed globally"

**Solution:**
```bash
# Install globally
npm install -g openclaw

# Or use local instance
cd /path/to/openclaw && npm install
```

### "OAuth credentials not found"

**Solution:**
```bash
# Follow OAuth setup guide
cat ~/.openclaw/ANTIGRAVITY_OAUTH_SETUP.md

# Or use interactive helper
~/.openclaw/verify-antigravity.sh --setup-oauth
```

### "Google Cloud quota exceeded"

**Solution:**
- Wait 30 minutes for quota reset (automatic)
- System auto-falls back to Devstral 2 after 4 hours
- Check quota: `openclaw quota google --remaining`

### "Authentication failed"

**Solution:**
```bash
# Re-authenticate with force flag
openclaw auth google --credentials ~/.openclaw/google-oauth-credentials.json --force
```

### "Invalid grant"

**Solution:**
Refresh token expired - re-authenticate:
```bash
openclaw auth google --credentials ~/.openclaw/google-oauth-credentials.json --force
```

## Verification Checklist

After installation, verify everything works:

```bash
# 1. Check plugin installation
npm list -g openclaw-antigravity-auth

# 2. Verify configuration files
ls -la ~/.openclaw/antigravity-config.json
ls -la ~/.openclaw/openclaw-antigravity.json

# 3. Check OAuth setup
ls -la ~/.openclaw/google-oauth-credentials.json
ls -la ~/.openclaw/google-oauth-token.json

# 4. Run verification script
~/.openclaw/verify-antigravity.sh

# 5. Test coding functionality
~/.openclaw/verify-antigravity.sh --test-coding

# 6. Run comprehensive tests
~/.openclaw/test-antigravity.sh
```

Expected output:
```
✓ Plugin installed: 1.0.0
✓ Antigravity config found
✓ OpenClaw integration config found
✓ OAuth credentials found
✓ Credentials permissions correct (600)
✓ OAuth token found (authenticated)
✓ Verification complete
```

## Cost Analysis

### Before Antigravity
- Coding: Claude Sonnet 4.5 via Anthropic
- Cost: ~$150-300/month for moderate usage

### After Antigravity
- Coding: Google Cloud Code Assist (FREE) + Devstral 2 (FREE)
- Cost: **$0/month**
- Savings: **100%**

### Annual Savings
- **$1,800 - $3,600** per year per bot

## Integration with LiNKbot

### Business Partner Bot (Lisa)

The Antigravity plugin is configured for the Business Partner bot:

```bash
# Configuration location
cd /Users/linktrend/Projects/LiNKbot/bots/business-partner/config/business-partner/

# Add Antigravity to openclaw.json
# (Already configured in multi-model routing)
```

### Cost Impact

| Component | Before | After | Savings |
|-----------|--------|-------|---------|
| Primary Model | $17-30/mo | $17-30/mo | - |
| Coding | $150-300/mo | **$0/mo** | 100% |
| **Total** | **$167-330/mo** | **$17-30/mo** | **89-95%** |

## Best Practices

### 1. Monitor Quota Daily

```bash
# Check remaining quota
openclaw quota google --remaining

# View daily usage
openclaw quota google --daily

# View usage history
openclaw quota google --history
```

### 2. Plan Large Tasks

Before starting large coding tasks:
1. Check quota remaining
2. Estimate task size (requests needed)
3. Reserve 10% quota buffer
4. Use file-based if quota insufficient

### 3. Respect Task Boundaries

- Complete tasks with the method you started
- Don't manually switch mid-task
- Let system handle auto-fallback on rate limits

### 4. Secure Credentials

```bash
# Never commit credentials
echo "google-oauth-credentials.json" >> ~/.openclaw/.gitignore
echo "google-oauth-token.json" >> ~/.openclaw/.gitignore

# Verify permissions
ls -la ~/.openclaw/google-oauth-*.json
# Should show: -rw------- (600)

# Rotate credentials periodically
# Delete old OAuth client in Google Cloud Console
# Create new OAuth client
# Re-authenticate
```

### 5. Emergency Override

For critical fixes when Antigravity unavailable:

```bash
openclaw code --method file-based --force "Critical bug fix"
```

## Troubleshooting

### Plugin Installation Fails

**Symptoms:** npm install errors

**Solutions:**
```bash
# Check npm permissions
npm config get prefix

# Fix npm permissions (if needed)
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
export PATH=~/.npm-global/bin:$PATH

# Retry installation
./scripts/install-antigravity.sh --force
```

### OAuth Browser Doesn't Open

**Symptoms:** Authentication hangs

**Solutions:**
```bash
# Copy URL from terminal and paste in browser manually
# Or set default browser:
export BROWSER=/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome

# Retry authentication
openclaw auth google --credentials ~/.openclaw/google-oauth-credentials.json
```

### Quota Resets Not Working

**Symptoms:** Quota stays at 0 after midnight UTC

**Solutions:**
```bash
# Check system time is correct
date

# Force quota refresh
openclaw quota google --refresh

# Clear quota cache
rm ~/.openclaw/quota-cache.json
```

### Verification Script Fails

**Symptoms:** verify-antigravity.sh errors

**Solutions:**
```bash
# Regenerate scripts
./scripts/install-antigravity.sh --config-only

# Check permissions
chmod +x ~/.openclaw/verify-antigravity.sh
chmod +x ~/.openclaw/test-antigravity.sh

# Retry verification
~/.openclaw/verify-antigravity.sh
```

## Support Resources

### Documentation
- **OAuth Setup:** `~/.openclaw/ANTIGRAVITY_OAUTH_SETUP.md`
- **Workflow Guide:** `~/.openclaw/ANTIGRAVITY_WORKFLOW.md`
- **OpenClaw Docs:** https://docs.openclaw.com/plugins/antigravity

### Dashboards
- **Google Cloud Console:** https://console.cloud.google.com/
- **API Usage:** https://console.cloud.google.com/apis/dashboard

### Issue Tracking
- **OpenClaw Issues:** https://github.com/openclaw/openclaw/issues
- **Plugin Issues:** https://github.com/openclaw/openclaw-antigravity-auth/issues

## Maintenance

### Weekly Tasks
- Check quota usage trends
- Review error logs
- Verify authentication status

### Monthly Tasks
- Review cost savings
- Update plugin if new version available
- Rotate OAuth credentials (optional)

### Update Plugin

```bash
# Check for updates
npm outdated -g openclaw-antigravity-auth

# Update plugin
npm update -g openclaw-antigravity-auth

# Verify update
npm list -g openclaw-antigravity-auth
```

## Uninstallation

If you need to remove Antigravity:

```bash
# Uninstall plugin
npm uninstall -g openclaw-antigravity-auth

# Backup configuration (optional)
cp -r ~/.openclaw/antigravity-* ~/antigravity-backup/

# Remove configuration files
rm ~/.openclaw/antigravity-config.json
rm ~/.openclaw/openclaw-antigravity.json
rm ~/.openclaw/ANTIGRAVITY_*.md
rm ~/.openclaw/*-antigravity.sh
rm ~/.openclaw/google-oauth-*.json

# Remove from OpenClaw config
# Edit ~/.openclaw/openclaw.json and remove Antigravity sections
```

## Summary

The Antigravity installation script provides:

✅ **Automated Installation:** One command installs everything  
✅ **Comprehensive Configuration:** All settings pre-configured  
✅ **Detailed Documentation:** Step-by-step guides included  
✅ **Verification Tools:** Scripts to test everything works  
✅ **Error Handling:** Clear messages for common issues  
✅ **Idempotent:** Safe to run multiple times  
✅ **Cost Savings:** 100% reduction in coding costs  
✅ **Dual-Track Workflow:** Antigravity + file-based fallback  
✅ **Rate Limit Handling:** Automatic quota management  
✅ **Security:** Proper permissions and credential handling  

**Result:** FREE enterprise-grade coding assistance for OpenClaw with zero configuration hassle.

---

**Last Updated:** February 9, 2026  
**Version:** 1.0.0  
**Maintainer:** LiNKbot Orchestrator
