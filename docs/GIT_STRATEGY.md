# Git Strategy: Fork → Configure → Deploy Pattern

**Document Version:** 1.0  
**Last Updated:** February 7, 2026  
**Status:** Active

---

## Overview

This document defines the Git strategy for deploying multiple configured OpenClaw bot instances from a single forked repository. This workspace (`LiNKbot`) tracks **configurations and deployment artifacts**, not OpenClaw source code.

---

## Architecture

### Repository Structure

```
LiNKbot/                          # THIS WORKSPACE (linkbot-partner repo)
├── bots/
│   └── business-partner/         # Cloned OpenClaw (NOT tracked here)
│       ├── .git/                 # Points to: github.com/linktrend/openclaw
│       ├── src/                  # OpenClaw source code
│       ├── skills/               # OpenClaw skills
│       └── ...                   # Full OpenClaw structure
├── config/
│   └── business-partner/         # Configuration for this bot instance
│       ├── .env.production       # Environment variables
│       ├── skills-config.json    # Enabled skills
│       ├── routing.yaml          # Multi-model routing
│       └── telegram-config.json  # Telegram bot settings
├── docs/                         # Documentation (tracked)
├── scripts/                      # Deployment scripts (tracked)
└── .gitignore                    # Excludes bots/business-partner/
```

### What Gets Tracked Where

| Content Type | Tracked In | Repository |
|--------------|-----------|------------|
| OpenClaw source code | `bots/business-partner/.git/` | `github.com/linktrend/openclaw` |
| Bot configurations | `config/business-partner/` | `github.com/linktrend/linkbot-partner` |
| Deployment scripts | `scripts/` | `github.com/linktrend/linkbot-partner` |
| Documentation | `docs/` | `github.com/linktrend/linkbot-partner` |
| Skills (custom) | `skills/custom/` | `github.com/linktrend/linkbot-partner` |

---

## Deployment Pattern: Option B (Configure Locally → Deploy to VPS)

### Phase 1: Fork OpenClaw (One-Time)

```bash
# Already completed:
# Forked openclaw/openclaw → linktrend/openclaw
```

### Phase 2: Clone Forked OpenClaw Locally

```bash
cd /Users/linktrend/Projects/LiNKbot/
git clone https://github.com/linktrend/openclaw bots/business-partner
```

**Result:**
- OpenClaw cloned to `bots/business-partner/`
- Size: ~236 MB
- Contains full OpenClaw source, skills, and documentation

### Phase 3: Configure Locally

Configure the bot instance in `config/business-partner/`:

1. **Environment Variables** (`config/business-partner/.env.production`)
   - API keys (OpenAI, Anthropic, Google)
   - Telegram bot token
   - Email SMTP credentials
   - Database connection strings

2. **Multi-Model Routing** (`config/business-partner/routing.yaml`)
   - Define model selection logic
   - Set cost thresholds
   - Configure fallback chains

3. **Skills Configuration** (`config/business-partner/skills-config.json`)
   - Enable/disable skills
   - Configure skill parameters
   - Set security policies

4. **Telegram Bot** (`config/business-partner/telegram-config.json`)
   - Bot username and token
   - Allowed user IDs
   - Command aliases

### Phase 4: Test Locally

```bash
cd bots/business-partner/
# Copy configuration from config/business-partner/ to OpenClaw
cp ../../config/business-partner/.env.production .env
cp ../../config/business-partner/routing.yaml config/routing.yaml
# ... (copy other configs)

# Run OpenClaw locally
pnpm install
pnpm build
pnpm start
```

### Phase 5: Deploy to VPS

```bash
# From workspace root
./scripts/deploy-business-partner.sh

# Script will:
# 1. SSH into DigitalOcean Droplet
# 2. Clone linktrend/openclaw on VPS
# 3. Copy configurations from config/business-partner/
# 4. Install dependencies
# 5. Build OpenClaw
# 6. Start as systemd service
```

---

## Git Workflow

### Initial Setup (Completed)

```bash
# 1. Initialize workspace as git repo
cd /Users/linktrend/Projects/LiNKbot/
git init

# 2. Add remote for configuration repo
git remote add origin https://github.com/linktrend/linkbot-partner.git

# 3. Clone OpenClaw (excluded from workspace git)
git clone https://github.com/linktrend/openclaw bots/business-partner
```

### Daily Workflow

```bash
# Work on configurations
vim config/business-partner/.env.production
vim config/business-partner/routing.yaml

# Commit configuration changes
git add config/business-partner/
git commit -m "Update multi-model routing for business partner bot"
git push origin main

# Update OpenClaw source (if needed)
cd bots/business-partner/
git pull origin main  # Pull from linktrend/openclaw
cd ../..
```

### Updating OpenClaw from Upstream

```bash
cd bots/business-partner/

# Add upstream remote (one-time)
git remote add upstream https://github.com/openclaw/openclaw.git

# Fetch and merge upstream changes
git fetch upstream
git merge upstream/main

# Push to your fork
git push origin main

cd ../..
```

---

## Replicating for Bot #2, #3, etc.

### For Each New Bot Instance:

1. **Create New GitHub Repo**
   ```bash
   # Example: linkbot-sales-assistant
   # Create at: https://github.com/linktrend/linkbot-sales-assistant
   ```

2. **Clone OpenClaw to New Directory**
   ```bash
   cd /Users/linktrend/Projects/LiNKbot/
   git clone https://github.com/linktrend/openclaw bots/sales-assistant
   ```

3. **Create Configuration Directory**
   ```bash
   mkdir -p config/sales-assistant/
   cp config/business-partner/.env.production config/sales-assistant/.env.production
   # Edit for new bot instance
   ```

4. **Update Workspace .gitignore**
   ```bash
   echo "bots/sales-assistant/" >> .gitignore
   ```

5. **Create Deployment Script**
   ```bash
   cp scripts/deploy-business-partner.sh scripts/deploy-sales-assistant.sh
   # Edit for new bot instance
   ```

6. **Commit Configuration**
   ```bash
   git add config/sales-assistant/
   git add scripts/deploy-sales-assistant.sh
   git commit -m "Add sales assistant bot configuration"
   git push origin main
   ```

---

## Why This Pattern?

### Advantages

1. **Separation of Concerns**
   - OpenClaw source code tracked in its own repo
   - Configurations tracked separately
   - Clean separation between framework and instances

2. **Easy Updates**
   - Pull OpenClaw updates without affecting configurations
   - Update configurations without touching OpenClaw source
   - Merge upstream changes from openclaw/openclaw easily

3. **Multiple Bot Instances**
   - Each bot gets its own configuration directory
   - Share the same OpenClaw fork across all bots
   - Independent deployment and testing

4. **Security**
   - Sensitive configurations (API keys) never committed to OpenClaw fork
   - Each bot instance has isolated credentials
   - Configurations can be encrypted at rest

5. **Flexibility**
   - Test locally before deploying to VPS
   - Rollback configurations independently of OpenClaw version
   - Deploy same OpenClaw version with different configurations

### Disadvantages (and Mitigations)

1. **Manual Configuration Copying**
   - Mitigation: Deployment scripts automate this
   - Scripts in `scripts/` directory handle copying

2. **Configuration Drift**
   - Mitigation: Version control all configurations
   - Document configuration changes in commit messages

3. **Duplicate OpenClaw Clones**
   - Mitigation: Acceptable for 2-3 bot instances
   - For 10+ bots, consider Docker images or shared installation

---

## Security Considerations

### Secrets Management

1. **Never Commit Secrets**
   - `.env.production` files are gitignored by default
   - Use `.env.example` as template (tracked)
   - Store actual secrets in password manager

2. **Deployment Secrets**
   - Use environment variables on VPS
   - Consider using systemd environment files
   - Encrypt secrets at rest on VPS

3. **Git History**
   - Never commit API keys or tokens
   - If accidentally committed, rotate keys immediately
   - Use `git filter-branch` to remove from history

### Access Control

1. **GitHub Repository**
   - Keep configuration repos private
   - Use SSH keys for git operations
   - Enable 2FA on GitHub account

2. **VPS Access**
   - Use SSH key authentication only
   - Disable password authentication
   - Restrict SSH access by IP if possible

---

## Troubleshooting

### Problem: OpenClaw Updates Break Configuration

**Solution:**
```bash
cd bots/business-partner/
git log  # Find last working commit
git checkout <commit-hash>
# Test configuration
# Report issue to OpenClaw maintainers
```

### Problem: Configuration Drift Between Local and VPS

**Solution:**
```bash
# Pull latest configurations
git pull origin main

# Redeploy to VPS
./scripts/deploy-business-partner.sh

# Verify deployment
ssh user@vps "cd /opt/openclaw-business-partner && pnpm status"
```

### Problem: Need to Test OpenClaw Changes

**Solution:**
```bash
cd bots/business-partner/
git checkout -b test-feature
# Make changes to OpenClaw source
# Test locally
# If successful, push to fork
git push origin test-feature
# Create PR to linktrend/openclaw
```

---

## References

- **OpenClaw Upstream:** https://github.com/openclaw/openclaw
- **Your Fork:** https://github.com/linktrend/openclaw
- **Configuration Repo:** https://github.com/linktrend/linkbot-partner
- **Deployment Guide:** `docs/DEPLOYMENT_PREP.md`
- **OpenClaw Documentation:** `bots/business-partner/docs/`

---

## Changelog

| Date | Version | Changes |
|------|---------|---------|
| 2026-02-07 | 1.0 | Initial Git strategy document |

---

**Next Steps:**
1. Configure multi-model routing
2. Create Telegram bot
3. Install and vet skills
4. Test locally
5. Deploy to VPS

See `docs/DEPLOYMENT_PREP.md` for detailed checklist.
