# Skills Installation Guide - Business Partner Bot

## Overview

This guide walks through sourcing, scanning, and installing OpenClaw skills for Lisa. **Security first**: All skills MUST pass Cisco Skill Scanner validation before deployment.

**Architecture**: 
- Root `/skills` folder = Staging area for scanning
- Bot folder `bots/business-partner/.openclaw/skills/` = Production deployment

**Estimated Time**: 15-20 hours  
**Prerequisites**: VPS deployed, Google Workspace configured, Telegram working

---

## Phase 1: Set Up Cisco Skill Scanner (30 minutes)

### 1.1 Install Skill Scanner

**On Mac** (local scanning before VPS deployment):

```bash
# Navigate to skills staging directory
cd /Users/linktrend/Projects/LiNKbot/skills

# Clone Cisco Skill Scanner
git clone https://github.com/cisco-ai-defense/skill-scanner.git

# Install dependencies (requires Python 3.8+)
cd skill-scanner

# Check Python version
python3 --version  # Should be 3.8+

# Install scanner (recommended: use venv)
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Verify installation
python skill_scanner.py --help
```

**Expected output**: Usage help for skill scanner

---

### 1.2 Understand Scan Results

**Scanner checks for**:
- ✅ Malicious code patterns
- ✅ Hardcoded secrets/credentials
- ✅ Suspicious network requests
- ✅ File system access (read/write/delete)
- ✅ Shell command execution
- ✅ Code injection vulnerabilities
- ✅ Unsafe dependencies

**Result Categories**:
- 🟢 **PASS**: Safe to use, no issues found
- 🟡 **WARNING**: Potential issues, manual review needed
- 🔴 **FAIL**: Security risks found, do NOT use

---

### 1.3 Create Scan Workflow Script

**Create scanning automation**:

```bash
cd /Users/linktrend/Projects/LiNKbot/skills

# Create scan script
cat > scan-skill.sh <<'EOF'
#!/bin/bash
# Skills Security Scanning Script

set -e

SKILL_NAME=$1
SKILL_DIR="/Users/linktrend/Projects/LiNKbot/skills/${SKILL_NAME}"
SCANNER_DIR="/Users/linktrend/Projects/LiNKbot/skills/skill-scanner"
REPORT_DIR="/Users/linktrend/Projects/LiNKbot/skills/scan-reports"

if [ -z "$SKILL_NAME" ]; then
    echo "Usage: ./scan-skill.sh <skill-name>"
    exit 1
fi

if [ ! -d "$SKILL_DIR" ]; then
    echo "Error: Skill directory not found: $SKILL_DIR"
    exit 1
fi

mkdir -p "$REPORT_DIR"

echo "============================================"
echo "Scanning Skill: $SKILL_NAME"
echo "============================================"

cd "$SCANNER_DIR"
source venv/bin/activate

python skill_scanner.py "$SKILL_DIR" \
    --output "$REPORT_DIR/${SKILL_NAME}-scan-$(date +%Y%m%d-%H%M%S).json" \
    --verbose

SCAN_EXIT_CODE=$?

if [ $SCAN_EXIT_CODE -eq 0 ]; then
    echo "✅ PASS: $SKILL_NAME is safe to deploy"
    echo "$SKILL_NAME" >> "$REPORT_DIR/approved-skills.txt"
else
    echo "❌ FAIL: $SKILL_NAME failed security scan"
    echo "$SKILL_NAME" >> "$REPORT_DIR/rejected-skills.txt"
fi

deactivate
echo "============================================"
exit $SCAN_EXIT_CODE
EOF

chmod +x scan-skill.sh
```

---

## Phase 2: Source Critical Skills (3-4 hours)

### 2.1 Identify Required Skills

**Based on Lisa's role** (Strategic Operations & Execution Lead):

**Tier 1: Critical (Must Have)**:
1. ✅ **Gmail Integration** - Send/receive/manage emails
2. ✅ **Google Calendar** - Schedule meetings, manage calendar
3. ✅ **Google Docs** - Create/edit documents
4. ✅ **Google Sheets** - Spreadsheet creation/analysis
5. ✅ **Google Slides** - Presentation creation
6. ✅ **Web Research** - Brave Search, web scraping
7. ✅ **Task Management** - To-do lists, project tracking

**Tier 2: Important (Should Have)**:
8. ✅ **Financial Calculations** - Budget analysis, ROI calculations
9. ✅ **Meeting Scheduling** - Calendar coordination
10. ✅ **Document Generation** - Templates, reports
11. ✅ **Data Analysis** - CSV/JSON processing
12. ✅ **Email Templates** - Professional email drafting

**Tier 3: Nice to Have**:
13. ⭕ **Time Zone Conversion** - Multi-timezone coordination
14. ⭕ **Weather Updates** - Travel planning
15. ⭕ **Translation** - Multi-language support

---

### 2.2 Source Skills from Repositories

**Primary sources**:
1. **ClawHub** (Official Registry): https://clawhub.ai
2. **VoltAgent Collection**: https://github.com/VoltAgent/awesome-openclaw-skills
3. **OpenClaw Official**: https://github.com/openclaw/skills
4. **Community Repos**: GitHub search for "openclaw-skill"

**Workflow for each skill**:

```bash
# Navigate to staging directory
cd /Users/linktrend/Projects/LiNKbot/skills

# Example: Gmail skill
mkdir -p gmail-skill
cd gmail-skill

# Option A: Clone from ClawHub/GitHub
git clone https://github.com/USER/openclaw-gmail-skill.git .

# Option B: Download as ZIP
curl -L https://github.com/USER/openclaw-gmail-skill/archive/refs/heads/main.zip -o skill.zip
unzip skill.zip
mv openclaw-gmail-skill-main/* .
rm -rf openclaw-gmail-skill-main skill.zip

# Option C: Manual download from ClawHub
# Visit clawhub.ai, download skill, extract to /skills/gmail-skill/
```

---

### 2.3 Curated Skill Sources (Recommended)

**Gmail Integration**:
```bash
cd /Users/linktrend/Projects/LiNKbot/skills
git clone https://github.com/openclaw/gmail-skill.git gmail-skill
```

**Google Calendar**:
```bash
git clone https://github.com/openclaw/calendar-skill.git calendar-skill
```

**Web Research (Brave Search)**:
```bash
git clone https://github.com/VoltAgent/brave-search-skill.git web-research-skill
```

**Task Management**:
```bash
git clone https://github.com/openclaw/task-manager-skill.git task-management-skill
```

**Financial Calculations**:
```bash
git clone https://github.com/VoltAgent/finance-calculator-skill.git financial-calc-skill
```

**Document Generation**:
```bash
git clone https://github.com/openclaw/doc-generator-skill.git doc-generation-skill
```

**Note**: These are example URLs. You'll need to search for actual skills on ClawHub.ai and GitHub.

---

## Phase 3: Security Scanning (4-6 hours)

### 3.1 Scan Each Skill

**For each skill in `/skills` directory**:

```bash
cd /Users/linktrend/Projects/LiNKbot/skills

# List all skills
ls -d */ | grep -v skill-scanner

# Scan each skill individually
./scan-skill.sh gmail-skill
./scan-skill.sh calendar-skill
./scan-skill.sh web-research-skill
./scan-skill.sh task-management-skill
./scan-skill.sh financial-calc-skill
./scan-skill.sh doc-generation-skill

# Continue for all skills...
```

---

### 3.2 Review Scan Reports

**Check scan reports**:
```bash
cd /Users/linktrend/Projects/LiNKbot/skills/scan-reports

# View latest scan results
ls -lt *.json | head -10

# View approved skills
cat approved-skills.txt

# View rejected skills
cat rejected-skills.txt
```

**For each report**:
```bash
# View detailed scan report
cat gmail-skill-scan-20260209-143000.json | jq .

# Key sections to check:
# - "risk_score": 0-100 (0 = safe, 100 = very dangerous)
# - "findings": List of security issues
# - "recommendations": Suggested fixes
```

---

### 3.3 Decision Matrix

**For each skill**:

| Risk Score | Findings | Decision |
|-----------|----------|----------|
| 0-20 | None or minor warnings | ✅ Approve immediately |
| 21-40 | Minor issues, no critical | 🟡 Review manually, approve if safe |
| 41-60 | Moderate issues | 🟡 Fix issues, re-scan |
| 61-80 | Serious issues | 🔴 Reject or major fixes needed |
| 81-100 | Critical vulnerabilities | 🔴 Reject immediately |

---

### 3.4 Handle Warnings and Failures

**For skills with warnings**:

```bash
# Example: Skill accesses file system
# Review findings
cat scan-reports/some-skill-scan-*.json | jq '.findings[] | select(.severity == "WARNING")'

# Decision tree:
# 1. Is file access necessary for skill function? (YES/NO)
# 2. Is access restricted to skill workspace only? (YES/NO)
# 3. Are file paths validated/sanitized? (YES/NO)
# 
# If all YES -> Approve with documentation
# If any NO -> Fix or reject
```

**For failed skills**:

```bash
# Example: Skill has hardcoded API key
# Reject immediately - DO NOT USE

# Document rejection
echo "Skill: some-skill | Reason: Hardcoded credentials | Date: $(date)" >> scan-reports/rejected-log.txt

# Search for alternative skill
# Re-scan new candidate
```

---

## Phase 4: Skill Configuration & Customization (2-3 hours)

### 4.1 Configure Approved Skills

**For each approved skill**:

```bash
cd /Users/linktrend/Projects/LiNKbot/skills/gmail-skill

# Check for configuration file
ls -la config.json skill.json manifest.json

# Edit configuration
nano config.json
```

**Common configuration patterns**:

```json
{
  "name": "gmail-integration",
  "version": "1.0.0",
  "description": "Send and manage emails via Gmail",
  
  "permissions": [
    "gmail.read",
    "gmail.send",
    "gmail.modify"
  ],
  
  "config": {
    "defaultSender": "${GMAIL_SENDER_EMAIL}",
    "maxResults": 50,
    "autoArchive": true
  },
  
  "dependencies": {
    "googleapis": "^118.0.0"
  }
}
```

**Customize for Lisa**:
- Replace placeholder values with actual config
- Set environment variables (don't hardcode secrets!)
- Configure skill-specific options

---

### 4.2 Test Skills Locally (Optional)

**Before deploying to VPS, test locally**:

```bash
# Install OpenClaw locally if not already installed
npm install -g openclaw

# Copy skill to local OpenClaw
mkdir -p ~/.openclaw/skills
cp -r /Users/linktrend/Projects/LiNKbot/skills/gmail-skill ~/.openclaw/skills/

# Test skill
openclaw skills test gmail-integration

# Expected: Skill loads without errors
```

---

## Phase 5: Deploy to VPS (1-2 hours)

### 5.1 Prepare Skills Package

**Create deployment package** with only approved skills:

```bash
cd /Users/linktrend/Projects/LiNKbot/skills

# Create clean package directory
mkdir -p approved-for-deployment

# Copy each approved skill (check approved-skills.txt)
while read skill; do
    if [ -d "$skill" ]; then
        cp -r "$skill" approved-for-deployment/
        echo "✅ Packaged: $skill"
    fi
done < scan-reports/approved-skills.txt

# Create tarball for transfer
tar -czf lisa-skills-$(date +%Y%m%d).tar.gz -C approved-for-deployment .

# Verify package
tar -tzf lisa-skills-*.tar.gz | head -20
```

---

### 5.2 Transfer to VPS

```bash
# Transfer skills package
scp lisa-skills-*.tar.gz root@YOUR_DROPLET_IP:/tmp/

# SSH into VPS
ssh root@YOUR_DROPLET_IP

# Extract skills to OpenClaw directory
mkdir -p ~/.openclaw/skills
cd ~/.openclaw/skills
tar -xzf /tmp/lisa-skills-*.tar.gz

# Set permissions
find ~/.openclaw/skills -type f -name "*.sh" -exec chmod +x {} \;
find ~/.openclaw/skills -type d -exec chmod 755 {} \;
find ~/.openclaw/skills -type f -exec chmod 644 {} \;

# Clean up
rm /tmp/lisa-skills-*.tar.gz

# Verify installation
ls -la ~/.openclaw/skills/
```

---

### 5.3 Configure Skills in OpenClaw

**Edit `openclaw.json` on VPS**:

```bash
ssh root@YOUR_DROPLET_IP
nano ~/.openclaw/openclaw.json
```

**Add skills configuration**:

```json5
  // ============================================================================
  // SKILLS CONFIGURATION
  // ============================================================================
  skills: {
    enabled: true,
    
    // Directory where skills are installed
    path: "~/.openclaw/skills",
    
    // Auto-load all skills in directory
    autoLoad: true,
    
    // Skill-specific configurations
    config: {
      "gmail-integration": {
        enabled: true,
        defaultSender: "${GMAIL_SENDER_EMAIL}",
        maxResults: 50,
      },
      
      "calendar-integration": {
        enabled: true,
        defaultCalendar: "primary",
        timezone: "America/New_York",
      },
      
      "web-research": {
        enabled: true,
        searchProvider: "brave",
        apiKey: "${BRAVE_API_KEY}",
        maxResults: 10,
      },
      
      "task-management": {
        enabled: true,
        storageBackend: "local", // or "google-drive"
        defaultPriority: "medium",
      },
      
      "financial-calculations": {
        enabled: true,
        currency: "USD",
        taxRate: 0.28, // Customize to your tax rate
      },
      
      "document-generation": {
        enabled: true,
        templatesPath: "~/.openclaw/templates",
        outputFormat: "google-docs", // or "pdf", "markdown"
      },
    },
    
    // Security settings
    security: {
      // Restrict skills to workspace directory only
      sandboxed: true,
      
      // Maximum execution time per skill (seconds)
      timeout: 30,
      
      // Require skill signature verification
      verifySignatures: false, // Enable if skills support signing
    },
  },
```

**Save**: `Ctrl+O`, Enter, `Ctrl+X`

---

### 5.4 Restart OpenClaw and Verify

```bash
# Restart service
sudo systemctl restart openclaw

# Monitor logs for skill loading
sudo journalctl -u openclaw -f | grep -i skill

# Expected output:
# [INFO] Loading skills from ~/.openclaw/skills
# [INFO] Loaded skill: gmail-integration
# [INFO] Loaded skill: calendar-integration
# [INFO] Loaded skill: web-research
# ... (all skills)
# [INFO] Skills initialized: 7 loaded, 0 failed
```

**Check skills status**:
```bash
openclaw skills list

# Expected: List of all loaded skills with status
```

---

## Phase 6: End-to-End Testing (3-4 hours)

### 6.1 Test Gmail Skill

**From Mac**:
```bash
openclaw chat --gateway lisa-production "Use the Gmail skill to send a test email to carlos@yourdomain.com with subject 'Test: Gmail Skill Integration' and body 'This tests the Gmail skill is working correctly.'"
```

**Expected**:
- ✅ Email arrives in inbox
- ✅ Sender is Lisa
- ✅ Skill executes without errors

---

### 6.2 Test Calendar Skill

```bash
openclaw chat --gateway lisa-production "Use the Calendar skill to create an event tomorrow at 3pm titled 'Test: Calendar Skill Integration' with 1 hour duration."
```

**Expected**:
- ✅ Event appears in Lisa's calendar
- ✅ Reminders configured
- ✅ Event details correct

---

### 6.3 Test Web Research Skill

```bash
openclaw chat --gateway lisa-production "Use the Web Research skill to find the top 3 news articles about AI agents in 2026."
```

**Expected**:
- ✅ Returns 3 relevant articles
- ✅ Includes titles, URLs, summaries
- ✅ Results are current/relevant

---

### 6.4 Test Task Management Skill

```bash
openclaw chat --gateway lisa-production "Use the Task Management skill to create a task: 'Review Q2 budget proposal' with high priority and due date 3 days from now."
```

**Expected**:
- ✅ Task created successfully
- ✅ Priority set to high
- ✅ Due date calculated correctly

---

### 6.5 Test Financial Calculations Skill

```bash
openclaw chat --gateway lisa-production "Use the Financial Calculations skill to calculate the ROI if I invest $10,000 and expect $15,000 return over 2 years."
```

**Expected**:
- ✅ Calculates ROI percentage
- ✅ Shows annualized return
- ✅ Provides clear explanation

---

### 6.6 Test Document Generation Skill

```bash
openclaw chat --gateway lisa-production "Use the Document Generation skill to create a meeting agenda document for 'Q2 Strategy Review' with sections: Goals, Budget, Timeline, Next Steps."
```

**Expected**:
- ✅ Google Doc created in Drive
- ✅ Document has requested structure
- ✅ Professional formatting

---

### 6.7 Test Multi-Skill Workflow

**Complex task using multiple skills**:

```bash
openclaw chat --gateway lisa-production "Do the following:
1. Research the top 3 project management tools for 2026
2. Create a Google Sheet comparing them (features, pricing, pros/cons)
3. Schedule a 30-minute meeting for next Tuesday at 2pm to discuss findings
4. Send me an email with the research summary and calendar invite"
```

**Expected**:
- ✅ Uses Web Research skill for articles
- ✅ Uses Google Sheets skill to create comparison
- ✅ Uses Calendar skill to schedule meeting
- ✅ Uses Gmail skill to send summary email
- ✅ All tasks complete successfully in sequence

---

## Phase 7: Documentation & Maintenance (1-2 hours)

### 7.1 Document Installed Skills

**Create skills inventory**:

```bash
cd /Users/linktrend/Projects/LiNKbot/docs

cat > SKILLS_INVENTORY.md <<'EOF'
# Skills Inventory - Business Partner Bot (Lisa)

## Deployed Skills

### Tier 1: Critical

#### 1. Gmail Integration
- **Version**: 1.0.0
- **Source**: github.com/openclaw/gmail-skill
- **Scan Date**: 2026-02-09
- **Scan Result**: PASS (Risk Score: 12)
- **Status**: ✅ Active
- **Functions**: Send email, read inbox, search, archive, label

#### 2. Google Calendar
- **Version**: 1.0.0
- **Source**: github.com/openclaw/calendar-skill
- **Scan Date**: 2026-02-09
- **Scan Result**: PASS (Risk Score: 8)
- **Status**: ✅ Active
- **Functions**: Create events, update, delete, check availability

... (continue for all skills)

## Scan History

| Skill | Scan Date | Risk Score | Result | Notes |
|-------|-----------|-----------|--------|-------|
| gmail-integration | 2026-02-09 | 12 | PASS | File access limited to attachments |
| calendar-integration | 2026-02-09 | 8 | PASS | No issues found |
| web-research | 2026-02-09 | 15 | PASS | Network access required (expected) |

## Rejected Skills

| Skill | Source | Reason | Date |
|-------|--------|--------|------|
| insecure-email-skill | github.com/user/bad-skill | Hardcoded credentials | 2026-02-09 |

## Maintenance Schedule

- **Weekly**: Check for skill updates
- **Monthly**: Re-scan updated skills
- **Quarterly**: Review skill usage and prune unused skills

EOF

```

---

### 7.2 Create Skill Update Workflow

**For future skill updates**:

```bash
cd /Users/linktrend/Projects/LiNKbot/skills

cat > update-skill.sh <<'EOF'
#!/bin/bash
# Skill Update Workflow Script

SKILL_NAME=$1

if [ -z "$SKILL_NAME" ]; then
    echo "Usage: ./update-skill.sh <skill-name>"
    exit 1
fi

echo "Updating skill: $SKILL_NAME"

# 1. Pull latest from source
cd "$SKILL_NAME"
git pull origin main

# 2. Re-scan for security
cd ..
./scan-skill.sh "$SKILL_NAME"

# 3. If scan passes, redeploy
if [ $? -eq 0 ]; then
    echo "Scan passed. Redeploying to VPS..."
    
    # Create package
    tar -czf "${SKILL_NAME}-update.tar.gz" "$SKILL_NAME"
    
    # Transfer to VPS
    scp "${SKILL_NAME}-update.tar.gz" root@YOUR_DROPLET_IP:/tmp/
    
    # Deploy on VPS
    ssh root@YOUR_DROPLET_IP <<'REMOTE'
        cd ~/.openclaw/skills
        rm -rf "$SKILL_NAME"
        tar -xzf "/tmp/${SKILL_NAME}-update.tar.gz"
        sudo systemctl restart openclaw
        rm "/tmp/${SKILL_NAME}-update.tar.gz"
REMOTE
    
    echo "✅ Skill updated successfully"
else
    echo "❌ Scan failed. Update aborted."
fi
EOF

chmod +x update-skill.sh
```

---

### 7.3 Set Up Monitoring

**Monitor skill performance**:

```bash
# SSH into VPS
ssh root@YOUR_DROPLET_IP

# Create monitoring script
cat > ~/.openclaw/monitor-skills.sh <<'EOF'
#!/bin/bash

echo "========================================="
echo "OpenClaw Skills Status Report"
echo "========================================="
echo "Generated: $(date)"
echo ""

echo "Loaded Skills:"
openclaw skills list | grep -E "✅|❌"

echo ""
echo "Recent Skill Errors:"
journalctl -u openclaw --since "24 hours ago" | grep -i "skill.*error" | tail -10

echo ""
echo "Skill Execution Times (last 100 calls):"
journalctl -u openclaw --since "24 hours ago" | grep "skill.*completed" | tail -100 | awk '{print $NF}' | sort -n | tail -10

echo "========================================="
EOF

chmod +x ~/.openclaw/monitor-skills.sh

# Run report
./monitor-skills.sh
```

---

## Troubleshooting

### Skill fails to load

**Check logs**:
```bash
ssh root@YOUR_DROPLET_IP
sudo journalctl -u openclaw | grep -A 5 "skill-name"
```

**Common issues**:
1. **Missing dependencies**: Install via npm/pip in skill directory
2. **Permission errors**: Check file permissions (644 for files, 755 for dirs)
3. **Config errors**: Verify config in `openclaw.json`

---

### Skill executes but fails

**Debug skill execution**:
```bash
# Enable verbose logging
nano ~/.openclaw/openclaw.json

# Add:
skills: {
  enabled: true,
  debug: true,  // Add this line
  logLevel: "verbose",
}

# Restart
sudo systemctl restart openclaw

# Test skill
openclaw chat "Test the gmail skill"

# Check detailed logs
sudo journalctl -u openclaw -n 200 | less
```

---

### Skill is slow

**Check execution time**:
```bash
sudo journalctl -u openclaw | grep "gmail-skill.*completed" | tail -10
```

**Optimization**:
- Reduce API calls
- Cache results where possible
- Increase timeout in config
- Check network latency

---

## Success Criteria

✅ Cisco Skill Scanner installed and working  
✅ All Tier 1 critical skills sourced  
✅ All skills scanned and passed security review  
✅ Approved skills deployed to VPS  
✅ Skills loaded successfully in OpenClaw  
✅ Gmail skill tested (send/receive)  
✅ Calendar skill tested (create events)  
✅ Web Research skill tested (search results)  
✅ Task Management skill tested (create tasks)  
✅ Financial Calc skill tested (calculations)  
✅ Document Generation skill tested (create docs)  
✅ Multi-skill workflow tested successfully  
✅ Skills inventory documented  

---

## Next Steps

1. ✅ All critical skills installed and tested
2. ➡️ **Proceed to**: Final System Testing & Documentation
3. ➡️ **Then**: Production deployment complete!

---

**Total Time**: 15-20 hours  
**Status**: Ready to begin  
**Critical**: Do NOT skip security scanning step!
