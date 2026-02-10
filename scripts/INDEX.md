# LiNKbot Scripts - Complete Index

## 🚀 Quick Navigation

### Configuration Deployment
👉 **Deploy Config**: [`deploy-config-to-vps.sh`](deploy-config-to-vps.sh) - Deploy OpenClaw configuration to VPS

### VPS Setup
📦 **VPS Scripts**: [`vps-setup/`](vps-setup/) - Security hardening and OpenClaw installation

### Google Workspace
☁️ **Google Scripts**: [`google-workspace/`](google-workspace/) - OAuth and service account setup

### Gateway Testing
🧪 **Test Gateway**: [`test-lisa-gateway.sh`](test-lisa-gateway.sh) - Comprehensive gateway testing suite

### Skills Testing
🎯 **Test Skills**: [`test-all-skills.sh`](test-all-skills.sh) - End-to-end skills integration testing

---

## 📁 Complete File Structure

```
scripts/
│
├── 🚀 DEPLOYMENT SCRIPTS
│   ├── deploy-config-to-vps.sh          (723 lines) - VPS configuration deployment
│   ├── DEPLOY_CONFIG_README.md          (Full documentation)
│   ├── DEPLOY_CONFIG_QUICK_REFERENCE.md (Quick reference guide)
│   └── DEPLOYMENT_SCRIPT_SUMMARY.md     (Overview and summary)
│
├── 🔧 VPS SETUP SCRIPTS
│   ├── vps-setup/
│   │   ├── 01-ssh-hardening.sh          (387 lines) - SSH security
│   │   ├── 02-firewall-setup.sh         (427 lines) - Firewall setup
│   │   ├── 03-install-openclaw.sh       (539 lines) - OpenClaw installation
│   │   ├── test-scripts.sh              (388 lines) - Test suite
│   │   ├── INDEX.md                     - VPS scripts index
│   │   ├── QUICK_START.md               - Quick setup guide
│   │   ├── README.md                    - Full documentation
│   │   ├── PACKAGE_SUMMARY.md           - Package overview
│   │   ├── WORKFLOW.md                  - Workflow documentation
│   │   └── .gitignore                   - Git ignore rules
│
├── ☁️ GOOGLE WORKSPACE SCRIPTS
│   ├── google-workspace/
│   │   ├── setup-oauth.sh               - OAuth 2.0 setup
│   │   ├── setup-service-account.sh     - Service account setup
│   │   ├── verify-setup.sh              - Verification script
│   │   ├── INDEX.md                     - Google scripts index
│   │   ├── QUICK_START.md               - Quick setup guide
│   │   ├── README.md                    - Full documentation
│   │   └── SETUP_COMPLETE.md            - Completion guide
│
├── 🧪 GATEWAY TESTING
│   ├── test-lisa-gateway.sh             (300+ lines) - Comprehensive test suite
│   ├── TESTING_GUIDE.md                 (500+ lines) - Complete testing documentation
│   ├── TESTING_QUICK_START.md           (100+ lines) - Quick reference guide
│   └── GATEWAY_TESTING_COMPLETE.md      (400+ lines) - Completion report
│
├── 🎯 SKILLS TESTING
│   ├── test-all-skills.sh               (900+ lines) - End-to-end skills integration testing
│   ├── SKILLS_TESTING_GUIDE.md          (900+ lines) - Complete skills testing documentation
│   └── SKILLS_TESTING_QUICK_START.md    (100+ lines) - Quick reference guide
│
└── 📚 DOCUMENTATION
    └── INDEX.md                         (this file) - Complete index
```

---

## 🎯 Common Workflows

### Workflow 1: Fresh VPS Deployment (Complete Setup)

**Goal**: Set up a new VPS from scratch with OpenClaw and configuration

```bash
# Step 1: SSH Hardening
cd scripts/vps-setup
./01-ssh-hardening.sh YOUR_VPS_IP

# Step 2: Firewall Setup
./02-firewall-setup.sh YOUR_HOME_IP YOUR_VPS_IP

# Step 3: Install OpenClaw
./03-install-openclaw.sh YOUR_VPS_IP

# Step 4: Deploy Configuration
cd ..
./deploy-config-to-vps.sh YOUR_VPS_IP
```

**Time**: ~10-15 minutes  
**Documentation**: 
- VPS Setup: [`vps-setup/QUICK_START.md`](vps-setup/QUICK_START.md)
- Config Deployment: [`DEPLOY_CONFIG_README.md`](DEPLOY_CONFIG_README.md)

---

### Workflow 2: Configuration Update (Existing VPS)

**Goal**: Update configuration on an already-configured VPS

```bash
# Deploy updated configuration
./scripts/deploy-config-to-vps.sh YOUR_VPS_IP

# Monitor logs
ssh root@YOUR_VPS_IP 'sudo journalctl -u openclaw -f'
```

**Time**: ~1-2 minutes  
**Documentation**: [`DEPLOY_CONFIG_QUICK_REFERENCE.md`](DEPLOY_CONFIG_QUICK_REFERENCE.md)

---

### Workflow 3: Google Workspace Integration

**Goal**: Set up Google Workspace API access for OpenClaw

```bash
cd scripts/google-workspace

# Option A: OAuth 2.0 (user access)
./setup-oauth.sh

# Option B: Service Account (automated access)
./setup-service-account.sh

# Verify setup
./verify-setup.sh
```

**Time**: ~15-20 minutes  
**Documentation**: [`google-workspace/QUICK_START.md`](google-workspace/QUICK_START.md)

---

### Workflow 4: Gateway Testing

**Goal**: Validate OpenClaw gateway deployment and functionality

```bash
cd scripts

# Get your authentication token
ssh root@YOUR_VPS_IP 'openclaw dashboard'
# Copy token from the URL: http://IP:18789/?token=YOUR_TOKEN

# Run comprehensive tests
./test-lisa-gateway.sh YOUR_VPS_IP YOUR_TOKEN

# Review results
ls -lt logs/gateway-tests-*.log | head -1
```

**Time**: ~30 seconds  
**Cost**: <$0.01 per test run  
**Documentation**: [`TESTING_QUICK_START.md`](TESTING_QUICK_START.md)

---

### Workflow 5: End-to-End Skills Testing

**Goal**: Test all installed skills through OpenClaw gateway

```bash
cd scripts

# Run skills integration tests
./test-all-skills.sh --vps YOUR_VPS_IP --token YOUR_TOKEN

# Review results
ls -lt logs/skills-test-*.log | head -1
```

**Time**: 4-6 minutes  
**Cost**: ~$0.003 per test run  
**Skills Tested**: Gmail, Calendar, Docs, Sheets, Slides, Web Research, Tasks, Financial, Coding  
**Documentation**: [`SKILLS_TESTING_QUICK_START.md`](SKILLS_TESTING_QUICK_START.md)

---

## 📋 Script Reference

### Deployment Scripts

#### `deploy-config-to-vps.sh`

**Purpose**: Deploy OpenClaw configuration files to VPS

**Usage**:
```bash
./deploy-config-to-vps.sh <VPS_IP> [ssh_user]
```

**Features**:
- ✅ Automatic backup before deployment
- ✅ SSH connection verification
- ✅ File transfer with verification
- ✅ Permission management (600 for .env, 644 for others)
- ✅ Service restart and health check
- ✅ Log monitoring (30 seconds)
- ✅ Rollback capability on failure

**Files Deployed**:
- `openclaw.json` → `~/.openclaw/openclaw.json`
- `.env` → `~/.openclaw/.env`
- `IDENTITY.md` → `~/.openclaw/workspace/IDENTITY.md`
- `SOUL.md` → `~/.openclaw/workspace/SOUL.md`
- `USER.md` → `~/.openclaw/workspace/USER.md` (optional)

**Documentation**:
- Full Guide: [`DEPLOY_CONFIG_README.md`](DEPLOY_CONFIG_README.md)
- Quick Reference: [`DEPLOY_CONFIG_QUICK_REFERENCE.md`](DEPLOY_CONFIG_QUICK_REFERENCE.md)
- Summary: [`DEPLOYMENT_SCRIPT_SUMMARY.md`](DEPLOYMENT_SCRIPT_SUMMARY.md)

**Exit Codes**:
- 0: Success
- 1: Invalid parameters or missing files
- 2: SSH connection failed
- 3: File transfer failed
- 4: Service restart failed
- 5: Verification failed

---

### VPS Setup Scripts

#### `vps-setup/01-ssh-hardening.sh`

**Purpose**: Secure SSH access with key-based authentication

**Usage**:
```bash
./01-ssh-hardening.sh <droplet_ip> [ssh_user]
```

**Features**:
- Generates ED25519 SSH key
- Copies key to VPS
- Disables password authentication
- Secures sshd_config
- Creates backup of original config

**Time**: ~1 minute

---

#### `vps-setup/02-firewall-setup.sh`

**Purpose**: Configure UFW firewall with security defaults

**Usage**:
```bash
./02-firewall-setup.sh <home_ip> <droplet_ip> [ssh_user]
```

**Features**:
- Installs and configures UFW
- Sets default deny incoming
- Opens SSH (port 22) to all
- Restricts OpenClaw (port 18789) to specific IP
- Supports multiple trusted IPs

**Time**: ~1 minute

---

#### `vps-setup/03-install-openclaw.sh`

**Purpose**: Install OpenClaw with systemd service

**Usage**:
```bash
./03-install-openclaw.sh [droplet_ip] [ssh_user]
```

**Features**:
- Updates system packages
- Installs Node.js 20 LTS
- Installs OpenClaw globally
- Creates systemd service
- Starts and enables service
- Health check verification

**Time**: ~3-5 minutes

---

#### `vps-setup/test-scripts.sh`

**Purpose**: Test suite for VPS setup scripts

**Usage**:
```bash
./test-scripts.sh
```

**Tests**:
- Syntax validation
- Executable permissions
- Usage output
- Parameter validation
- Documentation completeness

**Time**: ~30 seconds

---

### Gateway Testing Scripts

#### `test-lisa-gateway.sh`

**Purpose**: Comprehensive automated testing for OpenClaw gateway

**Usage**:
```bash
./test-lisa-gateway.sh <VPS_IP> <AUTH_TOKEN>

# Or with environment variables
export VPS_IP="143.198.123.45"
export OPENCLAW_TOKEN="abc123xyz789def456"
./test-lisa-gateway.sh
```

**Features**:
- ✅ 10 comprehensive tests (connectivity, auth, models, skills, etc.)
- ✅ Color-coded output (PASS/FAIL/SKIP)
- ✅ Detailed logging to timestamped files
- ✅ Response time tracking and averaging
- ✅ Cost estimation based on token usage
- ✅ Summary report with actionable recommendations
- ✅ Cross-platform support (macOS/Linux)
- ✅ Automatic dependency checking

**Test Coverage**:
1. Gateway connectivity (port 18789)
2. Authentication with token
3. Primary model (Kimi K2.5 via OpenRouter)
4. Heartbeat model (Gemini Flash Lite FREE)
5. Simple skill execution
6. Sub-agent spawn capability
7. Telegram notification setup
8. Session creation and /new command
9. Memory persistence (manual test)
10. Rate limit handling

**Documentation**:
- Full Guide: [`TESTING_GUIDE.md`](TESTING_GUIDE.md) (500+ lines)
- Quick Start: [`TESTING_QUICK_START.md`](TESTING_QUICK_START.md) (100+ lines)
- Completion Report: [`GATEWAY_TESTING_COMPLETE.md`](GATEWAY_TESTING_COMPLETE.md) (400+ lines)

**Cost**: <$0.01 per test run (most tests use FREE models)

**Time**: ~30 seconds

---

### Skills Testing Scripts

#### `test-all-skills.sh`

**Purpose**: End-to-end integration testing of all installed skills

**Usage**:
```bash
./test-all-skills.sh --vps YOUR_VPS_IP --token YOUR_TOKEN

# Or with environment variables
export VPS_IP="143.198.123.45"
export AUTH_TOKEN="your_token_here"
./test-all-skills.sh
```

**Features**:
- ✅ Tests 9 major skill categories (27+ individual tests)
- ✅ Gmail (send, read, search, archive)
- ✅ Calendar (create, list, update, delete events)
- ✅ Google Docs (create document, verify in Drive)
- ✅ Google Sheets (create spreadsheet with data)
- ✅ Google Slides (create presentation with 3 slides)
- ✅ Web Research (search "AI agents 2026", top 3 results)
- ✅ Task Management (create, list, complete tasks)
- ✅ Financial Calculator (ROI calculations with verification)
- ✅ Python Coding (generate script, verify file creation)
- ✅ Color-coded real-time output
- ✅ Detailed performance metrics per skill
- ✅ Token usage and cost tracking
- ✅ Comprehensive report with recommendations

**Test Coverage**:
- Total Skills: 9
- Total Tests: 27+
- Expected Pass Rate: 85%+ (after initial setup)

**Documentation**:
- Full Guide: [`SKILLS_TESTING_GUIDE.md`](SKILLS_TESTING_GUIDE.md) (900+ lines)
- Quick Start: [`SKILLS_TESTING_QUICK_START.md`](SKILLS_TESTING_QUICK_START.md) (100+ lines)

**Cost**: ~$0.003 per test run (60% FREE models, 40% optimized paid models)

**Time**: 4-6 minutes

---

### Google Workspace Scripts

#### `google-workspace/setup-oauth.sh`

**Purpose**: Set up OAuth 2.0 for Google Workspace API

**Usage**:
```bash
./setup-oauth.sh
```

**Features**:
- Interactive OAuth setup
- Credential file generation
- Token management
- Scope configuration

**Time**: ~10 minutes

---

#### `google-workspace/setup-service-account.sh`

**Purpose**: Set up service account for automated access

**Usage**:
```bash
./setup-service-account.sh
```

**Features**:
- Service account creation
- Domain-wide delegation
- Key file generation
- Permission configuration

**Time**: ~15 minutes

---

#### `google-workspace/verify-setup.sh`

**Purpose**: Verify Google Workspace API setup

**Usage**:
```bash
./verify-setup.sh
```

**Features**:
- Credential validation
- API access testing
- Permission verification
- Connection testing

**Time**: ~2 minutes

---

## 🔍 Quick Reference by Task

### Initial VPS Setup
```bash
cd scripts/vps-setup
./01-ssh-hardening.sh YOUR_VPS_IP
./02-firewall-setup.sh YOUR_HOME_IP YOUR_VPS_IP
./03-install-openclaw.sh YOUR_VPS_IP
```

### Deploy Configuration
```bash
./scripts/deploy-config-to-vps.sh YOUR_VPS_IP
```

### Update Configuration
```bash
./scripts/deploy-config-to-vps.sh YOUR_VPS_IP
```

### Google Workspace Setup
```bash
cd scripts/google-workspace
./setup-oauth.sh
# or
./setup-service-account.sh
./verify-setup.sh
```

### Test VPS Scripts
```bash
cd scripts/vps-setup
./test-scripts.sh
```

### Test Gateway
```bash
./scripts/test-lisa-gateway.sh YOUR_VPS_IP YOUR_TOKEN
```

### Test All Skills
```bash
./scripts/test-all-skills.sh --vps YOUR_VPS_IP --token YOUR_TOKEN
```

---

## 🆘 Troubleshooting

### Deployment Issues

**Problem**: SSH connection failed
```bash
# Test SSH manually
ssh -v root@YOUR_VPS_IP

# Check firewall
ssh root@YOUR_VPS_IP 'sudo ufw status'
```

**Problem**: File transfer failed
```bash
# Check disk space
ssh root@YOUR_VPS_IP 'df -h'

# Check permissions
ls -la bots/business-partner/config/business-partner/
```

**Problem**: Service won't start
```bash
# Check service logs
ssh root@YOUR_VPS_IP 'sudo journalctl -u openclaw -n 100'

# Verify configuration
ssh root@YOUR_VPS_IP 'cat ~/.openclaw/openclaw.json | jq .'
```

### VPS Setup Issues

**Problem**: Locked out after SSH hardening
```bash
# Access VPS console and restore backup
sudo cp /etc/ssh/sshd_config.backup.* /etc/ssh/sshd_config
sudo systemctl restart sshd
```

**Problem**: Firewall blocking access
```bash
# Access VPS console and reconfigure
sudo ufw disable
sudo ufw allow 22/tcp
sudo ufw enable
```

### Google Workspace Issues

**Problem**: OAuth authentication failed
```bash
# Re-run setup
cd scripts/google-workspace
./setup-oauth.sh
```

**Problem**: Service account not working
```bash
# Verify setup
./verify-setup.sh
```

---

## 📊 Script Statistics

| Category | Scripts | Lines of Code | Documentation |
|----------|---------|---------------|---------------|
| Deployment | 1 | 723 | 3 docs |
| VPS Setup | 4 | 1,741 | 5 docs |
| Google Workspace | 3 | ~800 | 4 docs |
| Gateway Testing | 1 | 300+ | 3 docs |
| **Total** | **9** | **~3,564** | **15 docs** |

---

## 🎓 Documentation Index

### Deployment Documentation
- [`DEPLOY_CONFIG_README.md`](DEPLOY_CONFIG_README.md) - Complete deployment guide
- [`DEPLOY_CONFIG_QUICK_REFERENCE.md`](DEPLOY_CONFIG_QUICK_REFERENCE.md) - Quick reference
- [`DEPLOYMENT_SCRIPT_SUMMARY.md`](DEPLOYMENT_SCRIPT_SUMMARY.md) - Overview

### VPS Setup Documentation
- [`vps-setup/INDEX.md`](vps-setup/INDEX.md) - VPS scripts index
- [`vps-setup/QUICK_START.md`](vps-setup/QUICK_START.md) - Quick setup
- [`vps-setup/README.md`](vps-setup/README.md) - Full documentation
- [`vps-setup/PACKAGE_SUMMARY.md`](vps-setup/PACKAGE_SUMMARY.md) - Package overview
- [`vps-setup/WORKFLOW.md`](vps-setup/WORKFLOW.md) - Workflow guide

### Google Workspace Documentation
- [`google-workspace/INDEX.md`](google-workspace/INDEX.md) - Google scripts index
- [`google-workspace/QUICK_START.md`](google-workspace/QUICK_START.md) - Quick setup
- [`google-workspace/README.md`](google-workspace/README.md) - Full documentation
- [`google-workspace/SETUP_COMPLETE.md`](google-workspace/SETUP_COMPLETE.md) - Completion guide

### Gateway Testing Documentation
- [`TESTING_GUIDE.md`](TESTING_GUIDE.md) - Comprehensive testing guide
- [`TESTING_QUICK_START.md`](TESTING_QUICK_START.md) - Quick start guide
- [`GATEWAY_TESTING_COMPLETE.md`](GATEWAY_TESTING_COMPLETE.md) - Completion report

### Skills Testing Documentation
- [`SKILLS_TESTING_GUIDE.md`](SKILLS_TESTING_GUIDE.md) - Complete skills testing guide (900+ lines)
- [`SKILLS_TESTING_QUICK_START.md`](SKILLS_TESTING_QUICK_START.md) - Quick reference guide

### Project Documentation
- [`../docs/guides/VPS_DEPLOYMENT.md`](../docs/guides/VPS_DEPLOYMENT.md) - VPS deployment guide
- [`../docs/deployment/OPENCLAW_DEPLOYMENT_GUIDE.md`](../docs/deployment/OPENCLAW_DEPLOYMENT_GUIDE.md) - OpenClaw deployment
- [`../START_HERE.md`](../START_HERE.md) - Project quick start

---

## ✅ Pre-Flight Checklist

### For VPS Deployment
- [ ] Fresh Ubuntu/Debian VPS
- [ ] VPS IP address
- [ ] Your home/office IP
- [ ] Initial SSH access
- [ ] VPS console access (backup)
- [ ] 10-15 minutes of time

### For Configuration Deployment
- [ ] VPS already set up with OpenClaw
- [ ] SSH key configured
- [ ] Configuration files exist locally
- [ ] Network access to VPS
- [ ] 2-5 minutes of time

### For Google Workspace Setup
- [ ] Google Workspace admin access
- [ ] Google Cloud Console access
- [ ] Project created in GCP
- [ ] APIs enabled
- [ ] 15-20 minutes of time

---

## 🎯 Success Criteria

### After VPS Setup
- ✅ SSH key-based authentication working
- ✅ Password authentication disabled
- ✅ UFW firewall active
- ✅ OpenClaw service running
- ✅ Systemd service enabled

### After Configuration Deployment
- ✅ All config files transferred
- ✅ Permissions set correctly
- ✅ Service restarted successfully
- ✅ No errors in logs
- ✅ Bot responding to messages

### After Google Workspace Setup
- ✅ OAuth credentials working
- ✅ Service account configured
- ✅ API access verified
- ✅ Permissions granted

### After Gateway Testing
- ✅ 80%+ tests passing
- ✅ No critical failures
- ✅ Response times acceptable (<5s avg)
- ✅ Authentication working
- ✅ Models configured correctly

### After Skills Testing
- ✅ 85%+ skills passing
- ✅ Gmail integration working
- ✅ Calendar operations successful
- ✅ Google Workspace skills functional
- ✅ Web research returning results
- ✅ Task management operational
- ✅ Financial calculations accurate
- ✅ Coding skills generating files

---

## 🔗 Related Documentation

- **Main Project**: [`../README.md`](../README.md)
- **Start Here**: [`../START_HERE.md`](../START_HERE.md)
- **Deployment Guide**: [`../docs/deployment/OPENCLAW_DEPLOYMENT_GUIDE.md`](../docs/deployment/OPENCLAW_DEPLOYMENT_GUIDE.md)
- **VPS Guide**: [`../docs/guides/VPS_DEPLOYMENT.md`](../docs/guides/VPS_DEPLOYMENT.md)
- **Google Setup**: [`../docs/guides/GOOGLE_WORKSPACE_SETUP.md`](../docs/guides/GOOGLE_WORKSPACE_SETUP.md)

---

## 📝 Version Information

- **Package Version**: 1.0.0
- **Last Updated**: February 9, 2026
- **Compatibility**: Ubuntu 20.04+, Debian 10+, macOS
- **Node.js Version**: 20 LTS
- **OpenClaw Version**: Latest (via npm)

---

## 🤝 Contributing

Found an issue or want to improve the scripts?

1. Test on a fresh VPS
2. Ensure idempotency
3. Add error handling
4. Update documentation
5. Run test suite

---

## 📞 Getting Help

1. **Quick issues**: Check relevant QUICK_START.md
2. **Detailed issues**: Check relevant README.md
3. **Understanding**: Read PACKAGE_SUMMARY.md or DEPLOYMENT_SCRIPT_SUMMARY.md
4. **Logs**: Check `/tmp/*-*.log` files

---

## 🎉 Ready to Start?

### New VPS?
👉 Go to [`vps-setup/QUICK_START.md`](vps-setup/QUICK_START.md)

### Deploy Configuration?
👉 Go to [`DEPLOY_CONFIG_QUICK_REFERENCE.md`](DEPLOY_CONFIG_QUICK_REFERENCE.md)

### Google Workspace?
👉 Go to [`google-workspace/QUICK_START.md`](google-workspace/QUICK_START.md)

### Test Gateway?
👉 Go to [`TESTING_QUICK_START.md`](TESTING_QUICK_START.md)

### Test All Skills?
👉 Go to [`SKILLS_TESTING_QUICK_START.md`](SKILLS_TESTING_QUICK_START.md)

---

*This script collection is part of the LiNKbot project.*
