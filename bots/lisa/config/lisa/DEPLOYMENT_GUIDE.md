# OpenClaw Multi-Model Routing: Deployment Guide

## Overview

This guide walks you through deploying the cost-optimized OpenClaw configuration to your VPS. Follow these steps to achieve 50-80% cost savings on API usage.

## Prerequisites

- ✅ VPS with OpenClaw installed
- ✅ SSH access to VPS
- ✅ API keys from required providers (see .env.example)
- ✅ Basic understanding of JSON5 configuration format

## Deployment Steps

### Step 1: Prepare API Keys

Before deployment, obtain API keys from the following providers:

#### Required Keys

1. **Anthropic API Key** (Primary model)
   - Go to: https://console.anthropic.com/
   - Create API key
   - Cost: $3/M input, $15/M output

2. **Google API Key** (Fallback & images)
   - Go to: https://makersuite.google.com/app/apikey
   - Create API key
   - Cost: $0.075-$3.50/M depending on model

#### Recommended Keys (for full resilience)

3. **OpenAI API Key** (Additional fallback)
   - Go to: https://platform.openai.com/api-keys
   - Create API key
   - Cost: $2.50/M input, $10/M output

4. **DeepSeek API Key** (Cost-effective subagents)
   - Go to: https://platform.deepseek.com/
   - Create API key
   - Cost: $2.74/M

5. **OpenRouter API Key** (Free fallbacks)
   - Go to: https://openrouter.ai/keys
   - Sign up with GitHub
   - Cost: $0 for free tier models

### Step 2: Transfer Configuration Files

Copy the configuration files to your VPS:

```bash
# From your local machine, SCP the files to VPS
scp config/business-partner/openclaw.json user@your-vps:/tmp/
scp config/business-partner/.env.example user@your-vps:/tmp/

# Or use rsync for entire directory
rsync -avz config/business-partner/ user@your-vps:/tmp/openclaw-config/
```

### Step 3: SSH into VPS

```bash
ssh user@your-vps
```

### Step 4: Set Up Environment Variables

```bash
# Copy .env.example to OpenClaw directory
cp /tmp/.env.example ~/.openclaw/.env

# Edit with your actual API keys
nano ~/.openclaw/.env

# Required: Fill in at minimum:
# - ANTHROPIC_API_KEY
# - GOOGLE_API_KEY

# Recommended: Also fill in:
# - OPENAI_API_KEY
# - DEEPSEEK_API_KEY
# - OPENROUTER_API_KEY

# Save and exit (Ctrl+X, Y, Enter)

# Secure the file
chmod 600 ~/.openclaw/.env
```

### Step 5: Deploy Configuration

```bash
# Backup existing config (if any)
if [ -f ~/.openclaw/openclaw.json ]; then
  cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup.$(date +%Y%m%d-%H%M%S)
fi

# Copy new configuration
cp /tmp/openclaw.json ~/.openclaw/openclaw.json

# Verify JSON5 syntax
openclaw doctor

# If doctor reports issues, fix them:
openclaw doctor --fix
```

### Step 6: Verify Authentication

```bash
# Check that all providers are authenticated
openclaw models status

# Expected output should show:
# ✓ anthropic: 1 profile (API key)
# ✓ google: 1 profile (API key)
# ✓ openai: 1 profile (API key) [if configured]
# ✓ deepseek: 1 profile (API key) [if configured]
# ✓ openrouter: 1 profile (API key) [if configured]

# If any providers show errors, check your .env file
```

### Step 7: Test Model Routing

```bash
# Start OpenClaw (if not already running)
openclaw start

# Test primary model
openclaw chat "Hello, please confirm you're using Claude Sonnet 4.5"

# Check model status
openclaw models status --plain

# Should output: anthropic/claude-sonnet-4-5

# Test model switching
openclaw chat "/model gemini flash"
openclaw chat "Confirm you're now using Gemini Flash"

# Test fallback (simulate primary failure)
# This is automatic - fallbacks activate on rate limits or errors
```

### Step 8: Configure Heartbeat (Optional)

If using background tasks and monitoring:

```bash
# Heartbeat is configured in openclaw.json
# Verify it's enabled:
grep -A 5 "heartbeat:" ~/.openclaw/openclaw.json

# Should show:
# heartbeat: {
#   enabled: true,
#   intervalMinutes: 15,
#   model: "google/gemini-2.5-flash-lite",
#   thinking: "off",
# }

# Restart to apply heartbeat settings
openclaw restart
```

### Step 9: Set Up Monitoring

```bash
# Create a monitoring script
cat > ~/check-openclaw-costs.sh << 'EOF'
#!/bin/bash
echo "=== OpenClaw Cost Monitor ==="
echo "Date: $(date)"
echo ""
echo "=== Current Model ==="
openclaw models status --plain
echo ""
echo "=== Provider Usage ==="
openclaw status --usage
echo ""
echo "=== Session Status ==="
openclaw chat "/status"
EOF

chmod +x ~/check-openclaw-costs.sh

# Run it daily via cron
(crontab -l 2>/dev/null; echo "0 18 * * * ~/check-openclaw-costs.sh >> ~/openclaw-costs.log 2>&1") | crontab -

# View logs
tail -f ~/openclaw-costs.log
```

### Step 10: Configure Budget Alerts

Set up alerts in each provider dashboard:

#### Anthropic Console
1. Go to: https://console.anthropic.com/settings/billing
2. Set budget alert at 75% of monthly limit
3. Set hard limit at 100% (if available)

#### Google AI Studio
1. Go to: https://console.cloud.google.com/billing
2. Create budget alert
3. Set threshold at $50/month (adjust as needed)

#### OpenAI Platform
1. Go to: https://platform.openai.com/settings/organization/billing/limits
2. Set soft limit at $50/month
3. Set hard limit at $100/month

#### DeepSeek Platform
1. Go to: https://platform.deepseek.com/billing
2. Configure budget alerts
3. Set appropriate limits

### Step 11: Verify Deployment

Run comprehensive verification:

```bash
# Check configuration is valid
openclaw doctor

# Verify all models are accessible
openclaw models list

# Test each model tier
echo "Testing Sonnet (primary)..."
openclaw chat "/model sonnet" "Test message"

echo "Testing Gemini Flash (fallback)..."
openclaw chat "/model gemini flash" "Test message"

echo "Testing DeepSeek (subagent)..."
openclaw chat "/model deepseek" "Test message"

# Check for any errors
openclaw logs --tail 50
```

### Step 12: Document Deployment

```bash
# Create deployment record
cat > ~/.openclaw/DEPLOYMENT_RECORD.md << EOF
# OpenClaw Deployment Record

## Deployment Date
$(date)

## Configuration Version
1.0 (Multi-Model Routing)

## Deployed Models
- Primary: Claude Sonnet 4.5
- Fallback: GPT-4 Turbo, Gemini Flash
- Heartbeat: Gemini 2.5 Flash Lite
- Subagents: DeepSeek Reasoner
- Images: Gemini 3 Flash

## API Keys Configured
- Anthropic: ✓
- Google: ✓
- OpenAI: ✓
- DeepSeek: ✓
- OpenRouter: ✓

## Expected Monthly Cost
Light usage (10M tokens): \$50-100
Moderate usage (50M tokens): \$200-1,000
Heavy usage (200M tokens): \$1,000-5,000

## Monitoring
- Daily cost check: ~/check-openclaw-costs.sh
- Logs: ~/openclaw-costs.log
- Provider dashboards: Check weekly

## Notes
$(openclaw models status)
EOF

cat ~/.openclaw/DEPLOYMENT_RECORD.md
```

## Post-Deployment Tasks

### Week 1: Monitoring Phase

```bash
# Daily checks
- Run ~/check-openclaw-costs.sh
- Review ~/openclaw-costs.log
- Check openclaw status --usage

# End of week
- Review total costs in provider dashboards
- Compare against baseline estimates
- Adjust model routing if needed
```

### Week 2-4: Optimization Phase

```bash
# Analyze usage patterns
- Which models are used most?
- Are fallbacks activating appropriately?
- Any unexpected costs?

# Optimize if needed
- Adjust primary model if quality issues
- Add more free fallbacks if budget tight
- Tune heartbeat interval
- Adjust subagent model
```

### Monthly: Review & Adjust

```bash
# Monthly review checklist
□ Total costs vs. budget
□ Cost per model tier
□ Fallback activation frequency
□ Quality vs. cost tradeoffs
□ Provider performance
□ API key rotation (if needed)
```

## Troubleshooting

### Issue: "No API key found for provider"

```bash
# Check .env file
cat ~/.openclaw/.env | grep PROVIDER_API_KEY

# Verify environment variables are loaded
openclaw models status

# Restart OpenClaw to reload env
openclaw restart
```

### Issue: "Model is not allowed"

```bash
# Check model allowlist
grep -A 20 "models:" ~/.openclaw/openclaw.json

# Add missing model
nano ~/.openclaw/openclaw.json
# Add model to agents.defaults.models

# Restart
openclaw restart
```

### Issue: High costs

```bash
# Check which models are being used
openclaw status --usage

# Review recent usage
openclaw logs --tail 100 | grep "model:"

# Switch to cheaper models
openclaw chat "/model gemini flash"

# Adjust configuration
nano ~/.openclaw/openclaw.json
# Change primary model to cheaper option
```

### Issue: Fallbacks not working

```bash
# Check fallback configuration
grep -A 5 "fallbacks:" ~/.openclaw/openclaw.json

# Verify fallback providers have API keys
openclaw models status

# Test fallback manually
openclaw chat "/model <fallback-model>" "Test"

# Check logs for fallback activation
openclaw logs --tail 100 | grep "fallback"
```

### Issue: Poor response quality

```bash
# Check current model
openclaw chat "/status"

# Switch to higher quality model
openclaw chat "/model sonnet"

# For critical tasks, use Opus
openclaw chat "/model opus"

# Adjust default in config
nano ~/.openclaw/openclaw.json
# Change agents.defaults.model.primary
```

## Rollback Procedure

If you need to revert to previous configuration:

```bash
# Stop OpenClaw
openclaw stop

# Restore backup
cp ~/.openclaw/openclaw.json.backup.YYYYMMDD-HHMMSS ~/.openclaw/openclaw.json

# Verify backup
openclaw doctor

# Restart
openclaw start

# Verify
openclaw models status
```

## Security Checklist

- ✅ API keys stored in ~/.openclaw/.env (not in config)
- ✅ .env file has 600 permissions (chmod 600)
- ✅ .env file not in version control
- ✅ Auth token generated securely (OPENCLAW_AUTH_TOKEN)
- ✅ Gateway port (18789) firewalled appropriately
- ✅ SSH access secured with key-based auth
- ✅ Regular API key rotation scheduled

## Cost Optimization Checklist

- ✅ Primary model set to Sonnet 4.5 (not Opus)
- ✅ Fallback chain includes cheaper alternatives
- ✅ Heartbeat uses ultra-cheap model (Flash Lite)
- ✅ Subagents use cost-effective model (DeepSeek)
- ✅ Image model set to affordable option (Gemini 3 Flash)
- ✅ Free fallbacks configured (OpenRouter)
- ✅ Budget alerts set in all provider dashboards
- ✅ Daily cost monitoring enabled
- ✅ Local embeddings enabled (no API costs)
- ✅ Direct fetch enabled (no Firecrawl costs)

## Support Resources

- **OpenClaw Documentation**: https://docs.openclaw.com
- **Model Providers Guide**: See docs/concepts/model-providers.md
- **Configuration Reference**: See docs/gateway/configuration.md
- **Cost Analysis**: See config/business-partner/COST_ANALYSIS.md
- **Model Usage Guide**: See config/business-partner/MODEL_USAGE.md

## Next Steps

After successful deployment:

1. ✅ Monitor costs for first week
2. ✅ Adjust model routing based on usage patterns
3. ✅ Set up channel integrations (WhatsApp, Telegram, etc.)
4. ✅ Configure skills and tools as needed
5. ✅ Implement backup and disaster recovery
6. ✅ Document any custom configurations
7. ✅ Train team on model switching commands
8. ✅ Schedule monthly cost reviews

---

**Deployment Date**: _____________  
**Deployed By**: _____________  
**VPS Host**: _____________  
**Configuration Version**: 1.0  

**Last Updated**: 2026-02-07
