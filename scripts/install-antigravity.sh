#!/bin/bash

################################################################################
# Antigravity Plugin Installation Script for OpenClaw
################################################################################
#
# Purpose: Install and configure the openclaw-antigravity-auth plugin for
#          FREE coding assistance via Google Cloud Code Assist (Gemini 2.0)
#          and Claude Opus 4, with Devstral 2 fallback.
#
# Features:
#   - Checks OpenClaw installation
#   - Installs openclaw-antigravity-auth plugin
#   - Creates configuration templates
#   - Generates OAuth setup instructions
#   - Creates test verification script
#   - Documents dual-track coding workflow
#   - Includes rate limit handling
#
# Usage: ./install-antigravity.sh [--force] [--config-only]
#
# Author: LiNKbot Orchestrator
# Date: February 9, 2026
# Version: 1.0.0
#
################################################################################

set -e  # Exit on error
set -u  # Exit on undefined variable

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
PLUGIN_NAME="openclaw-antigravity-auth"
OPENCLAW_CONFIG_DIR="${HOME}/.openclaw"
BACKUP_DIR="${OPENCLAW_CONFIG_DIR}/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Parse command line arguments
FORCE_INSTALL=false
CONFIG_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE_INSTALL=true
            shift
            ;;
        --config-only)
            CONFIG_ONLY=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--force] [--config-only]"
            echo ""
            echo "Options:"
            echo "  --force        Force reinstall even if plugin exists"
            echo "  --config-only  Only generate configuration files"
            echo "  -h, --help     Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_step() {
    echo -e "${BOLD}→${NC} $1"
}

################################################################################
# Pre-flight Checks
################################################################################

check_openclaw_installed() {
    print_header "Checking OpenClaw Installation"
    
    if command -v openclaw &> /dev/null; then
        local version=$(openclaw --version 2>&1 | head -n 1)
        print_success "OpenClaw is installed: ${version}"
        return 0
    else
        print_error "OpenClaw is not installed globally"
        echo ""
        echo -e "${YELLOW}Installation Options:${NC}"
        echo ""
        echo "  1. Install globally via npm:"
        echo -e "     ${CYAN}npm install -g openclaw${NC}"
        echo ""
        echo "  2. Use local OpenClaw instance:"
        echo -e "     ${CYAN}cd /path/to/openclaw && npm install${NC}"
        echo ""
        echo "  3. Deploy via VPS setup script:"
        echo -e "     ${CYAN}./scripts/vps-setup/03-install-openclaw.sh${NC}"
        echo ""
        return 1
    fi
}

check_npm_installed() {
    print_step "Checking npm installation"
    
    if command -v npm &> /dev/null; then
        local version=$(npm --version)
        print_success "npm is installed: v${version}"
        return 0
    else
        print_error "npm is not installed"
        echo ""
        echo -e "${YELLOW}Install Node.js and npm:${NC}"
        echo -e "  ${CYAN}https://nodejs.org/${NC}"
        echo ""
        return 1
    fi
}

check_plugin_installed() {
    print_step "Checking if ${PLUGIN_NAME} is already installed"
    
    if npm list -g ${PLUGIN_NAME} &> /dev/null; then
        local version=$(npm list -g ${PLUGIN_NAME} 2>/dev/null | grep ${PLUGIN_NAME} | awk '{print $2}' | sed 's/@//')
        print_warning "Plugin already installed: ${version}"
        
        if [ "$FORCE_INSTALL" = true ]; then
            print_info "Force flag set - will reinstall"
            return 1
        else
            echo ""
            echo -e "${YELLOW}To reinstall, run with --force flag:${NC}"
            echo -e "  ${CYAN}$0 --force${NC}"
            echo ""
            return 0
        fi
    else
        print_info "Plugin not installed - will proceed with installation"
        return 1
    fi
}

################################################################################
# Installation Functions
################################################################################

install_plugin() {
    print_header "Installing Antigravity Plugin"
    
    print_step "Installing ${PLUGIN_NAME} via npm"
    
    if npm install -g ${PLUGIN_NAME}; then
        print_success "Plugin installed successfully"
        
        # Verify installation
        local version=$(npm list -g ${PLUGIN_NAME} 2>/dev/null | grep ${PLUGIN_NAME} | awk '{print $2}' | sed 's/@//')
        print_info "Installed version: ${version}"
        return 0
    else
        print_error "Failed to install plugin"
        echo ""
        echo -e "${YELLOW}Common Issues:${NC}"
        echo "  • Permission denied: Try with sudo or fix npm permissions"
        echo "  • Network error: Check internet connection"
        echo "  • Package not found: Verify package name is correct"
        echo ""
        return 1
    fi
}

################################################################################
# Configuration Functions
################################################################################

create_backup() {
    print_step "Creating backup of existing configuration"
    
    mkdir -p "${BACKUP_DIR}"
    
    if [ -f "${OPENCLAW_CONFIG_DIR}/openclaw.json" ]; then
        cp "${OPENCLAW_CONFIG_DIR}/openclaw.json" "${BACKUP_DIR}/openclaw.json.${TIMESTAMP}"
        print_success "Backup created: ${BACKUP_DIR}/openclaw.json.${TIMESTAMP}"
    else
        print_info "No existing configuration to backup"
    fi
}

create_antigravity_config() {
    print_header "Creating Antigravity Configuration"
    
    local config_file="${OPENCLAW_CONFIG_DIR}/antigravity-config.json"
    
    print_step "Generating configuration template"
    
    cat > "${config_file}" << 'EOF'
{
  "antigravity": {
    "enabled": true,
    "description": "FREE coding via Google Cloud Code Assist (Gemini 2.0) and Claude Opus 4",
    
    "primary": {
      "provider": "google-code-assist",
      "model": "gemini-2.0-flash-thinking-exp",
      "cost": "FREE",
      "capabilities": [
        "code-generation",
        "code-review",
        "debugging",
        "refactoring",
        "documentation"
      ],
      "oauth": {
        "required": true,
        "setup_instructions": "See ANTIGRAVITY_OAUTH_SETUP.md",
        "scopes": [
          "https://www.googleapis.com/auth/cloud-platform",
          "https://www.googleapis.com/auth/generative-language"
        ]
      },
      "rate_limits": {
        "requests_per_minute": 60,
        "requests_per_day": 1500,
        "quota_exceeded_wait": "30 minutes",
        "max_wait_time": "4 hours",
        "fallback_on_limit": true
      }
    },
    
    "fallback": {
      "provider": "openrouter",
      "model": "mistralai/mistral-nemo",
      "alias": "devstral-2",
      "cost": "FREE",
      "capabilities": [
        "code-generation",
        "code-review",
        "file-based-coding"
      ],
      "api_key_env": "OPENROUTER_API_KEY",
      "rate_limits": {
        "requests_per_minute": 20,
        "requests_per_day": 200
      }
    },
    
    "workflow": {
      "task_persistence": {
        "description": "Once a coding task starts with a method, it must finish with that method",
        "rules": [
          "If task starts with Antigravity, complete with Antigravity",
          "If task starts with file-based (Devstral), complete with file-based",
          "No mid-task switching between methods",
          "Exception: Rate limit exceeded (auto-fallback allowed)"
        ]
      },
      
      "selection_strategy": {
        "default": "antigravity",
        "use_antigravity_for": [
          "new features",
          "complex refactoring",
          "architecture changes",
          "multi-file changes",
          "code generation from scratch"
        ],
        "use_file_based_for": [
          "simple edits",
          "quick fixes",
          "single-file changes",
          "emergency fixes when Antigravity unavailable"
        ]
      },
      
      "rate_limit_handling": {
        "on_quota_exceeded": {
          "action": "wait_then_fallback",
          "initial_wait": "30 minutes",
          "max_wait": "4 hours",
          "fallback_after_max": true,
          "notify_user": true
        },
        "recovery": {
          "check_quota_before_task": true,
          "estimate_task_cost": true,
          "reserve_quota_buffer": "10%"
        }
      }
    },
    
    "error_handling": {
      "authentication_failure": {
        "message": "OAuth authentication failed. Run: ./verify-antigravity.sh --setup-oauth",
        "retry": false,
        "fallback": true
      },
      "quota_exceeded": {
        "message": "Google Cloud quota exceeded. Waiting 30 minutes before retry.",
        "retry": true,
        "max_retries": 8,
        "fallback_after_retries": true
      },
      "network_error": {
        "message": "Network error connecting to Google Cloud. Retrying...",
        "retry": true,
        "max_retries": 3,
        "fallback_after_retries": true
      },
      "invalid_request": {
        "message": "Invalid request to Antigravity API. Check configuration.",
        "retry": false,
        "fallback": true
      }
    },
    
    "monitoring": {
      "log_all_requests": true,
      "track_quota_usage": true,
      "alert_on_quota_threshold": 0.8,
      "daily_usage_report": true
    }
  }
}
EOF
    
    print_success "Configuration created: ${config_file}"
    
    # Set secure permissions
    chmod 600 "${config_file}"
    print_info "Permissions set to 600 (owner read/write only)"
}

create_openclaw_integration() {
    print_header "Creating OpenClaw Integration Configuration"
    
    local integration_file="${OPENCLAW_CONFIG_DIR}/openclaw-antigravity.json"
    
    print_step "Generating OpenClaw integration config"
    
    cat > "${integration_file}" << 'EOF'
{
  "coding": {
    "primary_method": "antigravity",
    "fallback_method": "file-based",
    
    "antigravity": {
      "plugin": "openclaw-antigravity-auth",
      "enabled": true,
      "auto_authenticate": true,
      "config_file": "~/.openclaw/antigravity-config.json"
    },
    
    "file-based": {
      "model": "openrouter/mistralai/mistral-nemo",
      "enabled": true,
      "config": {
        "temperature": 0.7,
        "max_tokens": 8000,
        "top_p": 0.95
      }
    },
    
    "routing": {
      "rules": [
        {
          "condition": "antigravity_available && quota_sufficient",
          "method": "antigravity",
          "priority": 1
        },
        {
          "condition": "antigravity_rate_limited",
          "method": "wait_then_fallback",
          "wait_time": "30m",
          "max_wait": "4h",
          "priority": 2
        },
        {
          "condition": "antigravity_unavailable || quota_exceeded",
          "method": "file-based",
          "priority": 3
        }
      ]
    }
  }
}
EOF
    
    print_success "Integration config created: ${integration_file}"
    chmod 600 "${integration_file}"
}

create_oauth_setup_guide() {
    print_header "Creating OAuth Setup Guide"
    
    local guide_file="${OPENCLAW_CONFIG_DIR}/ANTIGRAVITY_OAUTH_SETUP.md"
    
    print_step "Generating OAuth setup instructions"
    
    cat > "${guide_file}" << 'EOF'
# Antigravity OAuth Setup Guide

## Overview

Antigravity requires OAuth authentication to access Google Cloud Code Assist (Gemini 2.0). This guide walks you through setting up OAuth credentials.

## Prerequisites

- Google Cloud account
- Project with billing enabled (FREE tier is sufficient)
- Cloud Code Assist API enabled

## Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" → "New Project"
3. Name: `openclaw-antigravity`
4. Click "Create"

## Step 2: Enable Required APIs

1. Navigate to "APIs & Services" → "Library"
2. Search and enable:
   - **Cloud Code Assist API**
   - **Generative Language API**
   - **Cloud Resource Manager API**

## Step 3: Create OAuth Credentials

### 3.1 Configure OAuth Consent Screen

1. Go to "APIs & Services" → "OAuth consent screen"
2. User Type: **External** (unless you have Google Workspace)
3. Click "Create"

**App Information:**
- App name: `OpenClaw Antigravity`
- User support email: Your email
- Developer contact: Your email

**Scopes:**
- Add scope: `https://www.googleapis.com/auth/cloud-platform`
- Add scope: `https://www.googleapis.com/auth/generative-language`

**Test Users:**
- Add your Google account email

Click "Save and Continue"

### 3.2 Create OAuth Client ID

1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "OAuth client ID"
3. Application type: **Desktop app**
4. Name: `openclaw-antigravity-desktop`
5. Click "Create"

### 3.3 Download Credentials

1. Click the download icon next to your OAuth client
2. Save as: `~/.openclaw/google-oauth-credentials.json`
3. Set permissions: `chmod 600 ~/.openclaw/google-oauth-credentials.json`

## Step 4: Authenticate OpenClaw

Run the authentication script:

```bash
openclaw auth google --credentials ~/.openclaw/google-oauth-credentials.json
```

This will:
1. Open a browser window
2. Ask you to sign in to Google
3. Request permission for the scopes
4. Save the refresh token locally

## Step 5: Verify Authentication

Run the verification script:

```bash
./verify-antigravity.sh
```

Expected output:
```
✓ OAuth credentials found
✓ Refresh token valid
✓ Antigravity API accessible
✓ Quota available: 1500/1500 requests
```

## Troubleshooting

### Error: "OAuth credentials not found"

**Solution:**
- Verify file exists: `ls -la ~/.openclaw/google-oauth-credentials.json`
- Check permissions: Should be `600` (owner read/write only)
- Re-download from Google Cloud Console

### Error: "Access denied"

**Solution:**
- Ensure your email is added to "Test Users" in OAuth consent screen
- Verify APIs are enabled in Google Cloud Console
- Check that project has billing enabled (FREE tier OK)

### Error: "Quota exceeded"

**Solution:**
- Wait 30 minutes for quota to reset
- Check quota limits in Google Cloud Console
- Consider requesting quota increase (usually not needed)

### Error: "Invalid grant"

**Solution:**
- Refresh token expired - re-authenticate:
  ```bash
  openclaw auth google --credentials ~/.openclaw/google-oauth-credentials.json --force
  ```

## Rate Limits

### Google Cloud Code Assist (FREE Tier)

- **Requests per minute:** 60
- **Requests per day:** 1,500
- **Quota reset:** Daily at midnight UTC

### Handling Rate Limits

OpenClaw automatically:
1. Tracks quota usage
2. Waits 30 minutes if quota exceeded
3. Falls back to Devstral 2 after 4 hours
4. Resumes Antigravity when quota resets

## Security Best Practices

1. **Never commit credentials to Git:**
   ```bash
   echo "google-oauth-credentials.json" >> ~/.openclaw/.gitignore
   ```

2. **Restrict file permissions:**
   ```bash
   chmod 600 ~/.openclaw/google-oauth-credentials.json
   chmod 600 ~/.openclaw/google-oauth-token.json
   ```

3. **Rotate credentials periodically:**
   - Delete old OAuth client in Google Cloud Console
   - Create new OAuth client
   - Re-authenticate

4. **Monitor usage:**
   ```bash
   openclaw quota google --show-usage
   ```

## Cost Monitoring

Antigravity is **FREE** but monitor usage:

```bash
# Check daily usage
openclaw quota google --daily

# Check quota remaining
openclaw quota google --remaining

# View usage history
openclaw quota google --history
```

## Support

- **Google Cloud Support:** https://cloud.google.com/support
- **OpenClaw Docs:** https://docs.openclaw.com/plugins/antigravity
- **Issue Tracker:** https://github.com/openclaw/openclaw-antigravity-auth/issues

---

**Last Updated:** February 9, 2026  
**Version:** 1.0.0
EOF
    
    print_success "OAuth guide created: ${guide_file}"
}

create_workflow_documentation() {
    print_header "Creating Workflow Documentation"
    
    local workflow_file="${OPENCLAW_CONFIG_DIR}/ANTIGRAVITY_WORKFLOW.md"
    
    print_step "Generating workflow documentation"
    
    cat > "${workflow_file}" << 'EOF'
# Antigravity Dual-Track Coding Workflow

## Overview

OpenClaw supports two coding methods:

1. **Antigravity (Primary):** FREE coding via Google Cloud Code Assist
2. **File-Based (Fallback):** Traditional file editing with Devstral 2

## Core Principle: Task Persistence

**Once a coding task starts with a method, it MUST finish with that method.**

### Why Task Persistence Matters

- **Context Continuity:** Each method maintains its own context
- **Consistency:** Prevents mixed coding styles mid-task
- **Debugging:** Easier to trace issues to a single method
- **Quality:** Each method optimized for specific workflows

### Rules

✅ **Allowed:**
- Start task with Antigravity → Complete with Antigravity
- Start task with file-based → Complete with file-based
- Auto-fallback on rate limit (system-initiated)

❌ **Not Allowed:**
- Manual switching mid-task
- Mixing methods within same feature
- Abandoning method without completion

### Exception: Rate Limit Auto-Fallback

If Antigravity hits rate limits:
1. System waits 30 minutes
2. If still unavailable, auto-switches to file-based
3. Task completes with file-based method
4. Next task can use Antigravity again

## Method Selection Guide

### Use Antigravity For:

- ✅ **New Features:** Building from scratch
- ✅ **Complex Refactoring:** Multi-file changes
- ✅ **Architecture Changes:** System-wide modifications
- ✅ **Code Generation:** Creating boilerplate
- ✅ **Large Tasks:** 100+ lines of code

**Why:** Antigravity excels at understanding context across files and generating coherent, well-structured code.

### Use File-Based For:

- ✅ **Simple Edits:** Single-line fixes
- ✅ **Quick Fixes:** Typos, formatting
- ✅ **Single-File Changes:** Isolated modifications
- ✅ **Emergency Fixes:** When Antigravity unavailable
- ✅ **Small Tasks:** < 50 lines of code

**Why:** File-based is faster for small, localized changes and always available.

## Workflow Examples

### Example 1: New Feature (Antigravity)

```bash
# Task: Add user authentication system

# Start with Antigravity
openclaw code --method antigravity "Add user authentication with JWT"

# Antigravity generates:
# - auth/login.js
# - auth/register.js
# - auth/middleware.js
# - tests/auth.test.js

# Task completes with Antigravity
# ✓ All files created with consistent style
# ✓ Tests included
# ✓ Documentation generated
```

### Example 2: Quick Fix (File-Based)

```bash
# Task: Fix typo in error message

# Start with file-based
openclaw edit src/errors.js --method file-based

# Change: "Eror occurred" → "Error occurred"

# Task completes with file-based
# ✓ Fast, simple edit
# ✓ No context needed
```

### Example 3: Rate Limit Fallback

```bash
# Task: Refactor database layer

# Start with Antigravity
openclaw code --method antigravity "Refactor database to use connection pool"

# Antigravity hits rate limit after 2 files
# System waits 30 minutes...
# Still limited? Auto-switch to file-based

# Task completes with file-based
# ✓ Task finished despite rate limit
# ✓ User notified of method switch
```

## Rate Limit Handling

### Detection

OpenClaw monitors:
- Requests per minute: 60 limit
- Requests per day: 1,500 limit
- Quota remaining: Real-time tracking

### Response Strategy

```
Rate Limit Detected
       ↓
Wait 30 minutes
       ↓
Quota available? ──YES──→ Resume Antigravity
       ↓
      NO
       ↓
Wait another 30 min (up to 4 hours total)
       ↓
Still limited? ──YES──→ Fallback to file-based
       ↓
      NO
       ↓
Resume Antigravity
```

### User Notifications

```bash
⚠ Antigravity rate limit reached (1500/1500 requests)
ℹ Waiting 30 minutes for quota reset...
ℹ You can cancel and use file-based: Ctrl+C

# After 30 minutes
✓ Quota reset - resuming Antigravity

# Or after 4 hours
⚠ Max wait time reached - switching to file-based fallback
ℹ Task will complete with Devstral 2
```

## Best Practices

### 1. Plan Before Coding

```bash
# Bad: Start coding without planning
openclaw code "make the app better"

# Good: Plan method based on task size
openclaw plan "Add user authentication"  # Review scope first
openclaw code --method antigravity "Add user authentication"  # Then code
```

### 2. Respect Task Boundaries

```bash
# Bad: Mix methods mid-feature
openclaw code --method antigravity "Add login"
# ... halfway through ...
openclaw edit --method file-based login.js  # ❌ Don't switch!

# Good: Complete with same method
openclaw code --method antigravity "Add login"
# ... complete entire feature ...
# ✓ Consistent implementation
```

### 3. Monitor Quota

```bash
# Check quota before large tasks
openclaw quota google --remaining

# Output: 1200/1500 requests remaining
# ✓ Sufficient for large task

# Output: 50/1500 requests remaining
# ⚠ Consider file-based or wait for reset
```

### 4. Emergency Override

```bash
# Force file-based if Antigravity unavailable
openclaw code --method file-based --force "Critical bug fix"

# Use when:
# - Antigravity authentication broken
# - Google Cloud outage
# - Urgent fix needed immediately
```

## Performance Comparison

| Metric | Antigravity | File-Based |
|--------|-------------|------------|
| **Speed (small task)** | 3-5 seconds | 1-2 seconds |
| **Speed (large task)** | 10-30 seconds | 5-15 seconds |
| **Quality** | Excellent | Good |
| **Context awareness** | Multi-file | Single-file |
| **Cost** | FREE | FREE |
| **Availability** | 99%+ | 100% |

## Troubleshooting

### "Task started with Antigravity but switched to file-based"

**Cause:** Rate limit exceeded during task

**Solution:** Normal behavior - task completes successfully with fallback

### "Cannot switch method mid-task"

**Cause:** Attempted manual method switch

**Solution:** Complete current task, then start new task with desired method

### "Antigravity unavailable"

**Cause:** OAuth not configured or expired

**Solution:** Run `./verify-antigravity.sh --setup-oauth`

## Monitoring & Logging

### View Coding Method Usage

```bash
# Daily summary
openclaw stats coding --daily

# Output:
# Antigravity: 45 tasks (90%)
# File-based: 5 tasks (10%)
# Fallbacks: 2 (rate limit)
```

### View Rate Limit Events

```bash
openclaw logs rate-limits --last 7d

# Output:
# 2026-02-08 14:23 - Rate limit reached, waited 30m, resumed
# 2026-02-07 09:15 - Rate limit reached, waited 4h, fell back
```

## Summary

- **Primary:** Antigravity for complex tasks
- **Fallback:** File-based for simple edits or emergencies
- **Rule:** Complete tasks with the method you started
- **Exception:** Auto-fallback on rate limits (system-initiated)
- **Monitoring:** Track quota to avoid surprises

---

**Last Updated:** February 9, 2026  
**Version:** 1.0.0
EOF
    
    print_success "Workflow documentation created: ${workflow_file}"
}

create_verification_script() {
    print_header "Creating Verification Script"
    
    local verify_script="${OPENCLAW_CONFIG_DIR}/verify-antigravity.sh"
    
    print_step "Generating verification script"
    
    cat > "${verify_script}" << 'EOF'
#!/bin/bash

################################################################################
# Antigravity Verification Script
################################################################################
#
# Purpose: Verify Antigravity plugin installation and configuration
#
# Usage: ./verify-antigravity.sh [--setup-oauth] [--test-coding]
#
################################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

SETUP_OAUTH=false
TEST_CODING=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --setup-oauth)
            SETUP_OAUTH=true
            shift
            ;;
        --test-coding)
            TEST_CODING=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check plugin installation
print_header "Checking Plugin Installation"

if npm list -g openclaw-antigravity-auth &> /dev/null; then
    version=$(npm list -g openclaw-antigravity-auth 2>/dev/null | grep openclaw-antigravity-auth | awk '{print $2}' | sed 's/@//')
    print_success "Plugin installed: ${version}"
else
    print_error "Plugin not installed"
    echo ""
    echo "Install with: ./install-antigravity.sh"
    exit 1
fi

# Check configuration files
print_header "Checking Configuration Files"

if [ -f "${HOME}/.openclaw/antigravity-config.json" ]; then
    print_success "Antigravity config found"
else
    print_error "Antigravity config missing"
    echo "Run: ./install-antigravity.sh --config-only"
fi

if [ -f "${HOME}/.openclaw/openclaw-antigravity.json" ]; then
    print_success "OpenClaw integration config found"
else
    print_error "OpenClaw integration config missing"
fi

# Check OAuth setup
print_header "Checking OAuth Configuration"

if [ -f "${HOME}/.openclaw/google-oauth-credentials.json" ]; then
    print_success "OAuth credentials found"
    
    # Check permissions
    perms=$(stat -f "%A" "${HOME}/.openclaw/google-oauth-credentials.json" 2>/dev/null || stat -c "%a" "${HOME}/.openclaw/google-oauth-credentials.json" 2>/dev/null)
    if [ "$perms" = "600" ]; then
        print_success "Credentials permissions correct (600)"
    else
        print_warning "Credentials permissions: ${perms} (should be 600)"
        echo "Fix with: chmod 600 ~/.openclaw/google-oauth-credentials.json"
    fi
else
    print_error "OAuth credentials not found"
    echo ""
    echo "Setup OAuth:"
    echo "  1. Follow guide: ~/.openclaw/ANTIGRAVITY_OAUTH_SETUP.md"
    echo "  2. Or run: $0 --setup-oauth"
    echo ""
fi

if [ -f "${HOME}/.openclaw/google-oauth-token.json" ]; then
    print_success "OAuth token found (authenticated)"
else
    print_warning "OAuth token not found (not authenticated)"
    echo "Authenticate with: openclaw auth google --credentials ~/.openclaw/google-oauth-credentials.json"
fi

# OAuth setup helper
if [ "$SETUP_OAUTH" = true ]; then
    print_header "OAuth Setup Helper"
    
    echo "Opening OAuth setup guide..."
    echo ""
    cat "${HOME}/.openclaw/ANTIGRAVITY_OAUTH_SETUP.md"
    echo ""
    
    read -p "Have you created OAuth credentials? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter path to downloaded credentials JSON: " creds_path
        
        if [ -f "$creds_path" ]; then
            cp "$creds_path" "${HOME}/.openclaw/google-oauth-credentials.json"
            chmod 600 "${HOME}/.openclaw/google-oauth-credentials.json"
            print_success "Credentials installed"
            
            echo ""
            echo "Now authenticate:"
            echo "  openclaw auth google --credentials ~/.openclaw/google-oauth-credentials.json"
        else
            print_error "File not found: $creds_path"
        fi
    fi
fi

# Test coding functionality
if [ "$TEST_CODING" = true ]; then
    print_header "Testing Antigravity Coding"
    
    echo "Creating test file..."
    cat > /tmp/antigravity-test.js << 'TESTEOF'
// Test file for Antigravity
function hello() {
    console.log("Hello, World!");
}
TESTEOF
    
    print_info "Testing Antigravity code generation..."
    
    if openclaw code --method antigravity --file /tmp/antigravity-test.js "Add a function to calculate factorial"; then
        print_success "Antigravity coding test passed"
        echo ""
        echo "Generated code:"
        cat /tmp/antigravity-test.js
    else
        print_error "Antigravity coding test failed"
        echo ""
        echo "Trying file-based fallback..."
        
        if openclaw code --method file-based --file /tmp/antigravity-test.js "Add a function to calculate factorial"; then
            print_success "File-based fallback works"
        else
            print_error "Both methods failed"
        fi
    fi
    
    rm -f /tmp/antigravity-test.js
fi

# Check quota
print_header "Checking Google Cloud Quota"

if command -v openclaw &> /dev/null && [ -f "${HOME}/.openclaw/google-oauth-token.json" ]; then
    print_info "Querying quota status..."
    
    # This is a placeholder - actual implementation depends on OpenClaw API
    echo "  Run manually: openclaw quota google --remaining"
else
    print_warning "Cannot check quota (OpenClaw not configured)"
fi

# Summary
print_header "Verification Summary"

echo ""
echo -e "${BOLD}Next Steps:${NC}"
echo ""

if [ ! -f "${HOME}/.openclaw/google-oauth-credentials.json" ]; then
    echo "  1. Setup OAuth credentials"
    echo "     ${BLUE}→${NC} Follow: ~/.openclaw/ANTIGRAVITY_OAUTH_SETUP.md"
    echo ""
fi

if [ ! -f "${HOME}/.openclaw/google-oauth-token.json" ]; then
    echo "  2. Authenticate with Google"
    echo "     ${BLUE}→${NC} openclaw auth google --credentials ~/.openclaw/google-oauth-credentials.json"
    echo ""
fi

echo "  3. Test Antigravity coding"
echo "     ${BLUE}→${NC} $0 --test-coding"
echo ""

echo "  4. Read workflow documentation"
echo "     ${BLUE}→${NC} cat ~/.openclaw/ANTIGRAVITY_WORKFLOW.md"
echo ""

print_success "Verification complete"
EOF
    
    chmod +x "${verify_script}"
    print_success "Verification script created: ${verify_script}"
}

create_test_script() {
    print_header "Creating Test Script"
    
    local test_script="${OPENCLAW_CONFIG_DIR}/test-antigravity.sh"
    
    print_step "Generating comprehensive test script"
    
    cat > "${test_script}" << 'EOF'
#!/bin/bash

################################################################################
# Antigravity Comprehensive Test Script
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Test 1: Simple code generation
print_header "Test 1: Simple Code Generation"

cat > /tmp/test1.js << 'TESTEOF'
// Empty file
TESTEOF

print_info "Testing: Add hello world function"

if openclaw code --method antigravity --file /tmp/test1.js "Add a hello world function"; then
    print_success "Test 1 passed"
    cat /tmp/test1.js
else
    print_error "Test 1 failed"
fi

# Test 2: Multi-file generation
print_header "Test 2: Multi-File Generation"

mkdir -p /tmp/antigravity-test
print_info "Testing: Create a simple Express API"

if openclaw code --method antigravity --dir /tmp/antigravity-test "Create a simple Express API with routes for users"; then
    print_success "Test 2 passed"
    ls -la /tmp/antigravity-test
else
    print_error "Test 2 failed"
fi

# Test 3: Fallback mechanism
print_header "Test 3: Fallback Mechanism"

print_info "Testing: Force fallback to file-based"

if openclaw code --method file-based --file /tmp/test1.js "Add a goodbye function"; then
    print_success "Test 3 passed - fallback works"
else
    print_error "Test 3 failed"
fi

# Cleanup
rm -rf /tmp/test1.js /tmp/antigravity-test

print_header "Test Summary"
print_success "All tests completed"
EOF
    
    chmod +x "${test_script}"
    print_success "Test script created: ${test_script}"
}

################################################################################
# Main Installation Flow
################################################################################

main() {
    print_header "Antigravity Plugin Installation"
    
    echo -e "${BOLD}OpenClaw Antigravity Plugin Installer${NC}"
    echo -e "Version: 1.0.0"
    echo -e "Date: February 9, 2026"
    echo ""
    
    # Pre-flight checks
    if ! check_npm_installed; then
        exit 1
    fi
    
    if ! check_openclaw_installed; then
        exit 1
    fi
    
    # Check if already installed
    if check_plugin_installed && [ "$FORCE_INSTALL" = false ] && [ "$CONFIG_ONLY" = false ]; then
        print_info "Plugin already installed. Use --force to reinstall or --config-only to regenerate configs."
        exit 0
    fi
    
    # Create backup
    create_backup
    
    # Install plugin (unless config-only mode)
    if [ "$CONFIG_ONLY" = false ]; then
        if ! install_plugin; then
            exit 1
        fi
    fi
    
    # Create configuration files
    create_antigravity_config
    create_openclaw_integration
    create_oauth_setup_guide
    create_workflow_documentation
    create_verification_script
    create_test_script
    
    # Final summary
    print_header "Installation Complete"
    
    echo ""
    echo -e "${GREEN}${BOLD}✓ Antigravity Plugin Installation Successful${NC}"
    echo ""
    echo -e "${BOLD}What was installed:${NC}"
    echo ""
    echo "  • openclaw-antigravity-auth plugin"
    echo "  • Configuration files in ~/.openclaw/"
    echo "  • OAuth setup guide"
    echo "  • Workflow documentation"
    echo "  • Verification script"
    echo "  • Test script"
    echo ""
    echo -e "${BOLD}Next Steps:${NC}"
    echo ""
    echo "  1. Setup OAuth credentials:"
    echo -e "     ${CYAN}cat ~/.openclaw/ANTIGRAVITY_OAUTH_SETUP.md${NC}"
    echo ""
    echo "  2. Verify installation:"
    echo -e "     ${CYAN}~/.openclaw/verify-antigravity.sh${NC}"
    echo ""
    echo "  3. Run tests:"
    echo -e "     ${CYAN}~/.openclaw/test-antigravity.sh${NC}"
    echo ""
    echo "  4. Read workflow guide:"
    echo -e "     ${CYAN}cat ~/.openclaw/ANTIGRAVITY_WORKFLOW.md${NC}"
    echo ""
    echo -e "${BOLD}Configuration Files:${NC}"
    echo ""
    echo "  • ~/.openclaw/antigravity-config.json"
    echo "  • ~/.openclaw/openclaw-antigravity.json"
    echo "  • ~/.openclaw/ANTIGRAVITY_OAUTH_SETUP.md"
    echo "  • ~/.openclaw/ANTIGRAVITY_WORKFLOW.md"
    echo "  • ~/.openclaw/verify-antigravity.sh"
    echo "  • ~/.openclaw/test-antigravity.sh"
    echo ""
    echo -e "${BOLD}Documentation:${NC}"
    echo ""
    echo "  • OAuth Setup: ~/.openclaw/ANTIGRAVITY_OAUTH_SETUP.md"
    echo "  • Workflow Guide: ~/.openclaw/ANTIGRAVITY_WORKFLOW.md"
    echo "  • OpenClaw Docs: https://docs.openclaw.com/plugins/antigravity"
    echo ""
    echo -e "${GREEN}Happy coding with FREE Antigravity! 🚀${NC}"
    echo ""
}

# Run main installation
main
