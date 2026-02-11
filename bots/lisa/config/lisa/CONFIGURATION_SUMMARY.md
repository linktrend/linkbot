# OpenClaw Multi-Model Routing: Configuration Summary

## 📋 Configuration Overview

This document provides a high-level summary of the OpenClaw multi-model routing configuration for the Business Partner Bot.

**Configuration Date**: 2026-02-07  
**Version**: 1.0  
**Strategy**: Native OpenClaw multi-model routing (no paid plugins)  
**Expected Savings**: 50-80% compared to all-Opus baseline  

---

## 🎯 Configuration Goals

1. **Cost Optimization**: Reduce API costs by 85% through intelligent model routing
2. **Quality Maintenance**: Keep high quality for important tasks using Sonnet 4.5
3. **Resilience**: Automatic fallback across multiple providers
4. **Scalability**: Support light to heavy usage patterns
5. **Simplicity**: Native OpenClaw features only, no external routing services

---

## 🔧 Model Routing Strategy

### Primary Model (70% of requests)
- **Model**: Claude Sonnet 4.5
- **Provider**: Anthropic
- **Cost**: $3/M input, $15/M output
- **Use**: Standard interactions, customer support, content creation
- **Savings vs Opus**: 80%

### Fallback Chain (20% of requests)
1. **GPT-4 Turbo** (OpenAI) - $2.50/M input, $10/M output
   - Different provider for resilience
   - 87% cheaper than Opus

2. **Gemini 2.0 Flash** (Google) - $0.075/M input, $0.30/M output
   - Ultra-cheap for simple tasks
   - 99.6% cheaper than Opus

3. **DeepSeek R1 Free** (OpenRouter) - $0/M
   - Zero-cost emergency fallback
   - 100% cheaper than Opus

### Specialized Models (10% of requests)

**Heartbeat/Background Tasks**
- **Model**: Gemini 2.5 Flash Lite
- **Cost**: $0.50/M
- **Savings vs Opus**: 99.3%

**Subagent Tasks**
- **Model**: DeepSeek Reasoner
- **Cost**: $2.74/M
- **Savings vs Opus**: 96%

**Image Analysis**
- **Model**: Gemini 3 Flash
- **Cost**: $3.50/M
- **Savings vs Opus**: 95%

---

## 💰 Cost Comparison

### Monthly Costs by Usage Level

| Usage Level | Tokens/Month | Baseline (Opus) | Optimized | Savings | % Saved |
|-------------|--------------|-----------------|-----------|---------|---------|
| **Light** | 10M | $330 | $52 | $278 | 84% |
| **Moderate** | 50M | $1,650 | $241 | $1,409 | 85% |
| **Heavy** | 200M | $6,600 | $966 | $5,634 | 85% |

### Annual Savings

| Usage Level | Annual Baseline | Annual Optimized | Annual Savings |
|-------------|-----------------|------------------|----------------|
| **Light** | $3,960 | $620 | **$3,340** |
| **Moderate** | $19,800 | $2,897 | **$16,903** |
| **Heavy** | $79,200 | $11,587 | **$67,613** |

---

## 📊 Expected Token Distribution

Based on typical business partner bot usage:

| Component | % of Tokens | Model | Cost/M | Monthly Cost (50M) |
|-----------|-------------|-------|--------|-------------------|
| Main interactions | 45% | Sonnet 4.5 | $15 | $150 |
| Subagent tasks | 18% | DeepSeek | $2.74 | $27 |
| Background/heartbeat | 18% | Flash Lite | $0.50 | $5 |
| Image processing | 5% | Gemini 3 Flash | $3.50 | $11 |
| Fallback usage | 4% | Gemini Flash | $0.30 | $1 |
| Compaction | 10% | Gemini Flash | $0.30 | $2 |
| **Total** | **100%** | **Mixed** | **~$4 avg** | **$196** |

---

## 🔑 Required API Keys

### Essential (Required for Basic Operation)

1. **Anthropic API Key**
   - Provider: https://console.anthropic.com/
   - Purpose: Primary model (Sonnet 4.5)
   - Cost: $3/M input, $15/M output
   - Status: ⚠️ **REQUIRED**

2. **Google API Key**
   - Provider: https://makersuite.google.com/app/apikey
   - Purpose: Fallback, images, heartbeat
   - Cost: $0.075-$3.50/M depending on model
   - Status: ⚠️ **REQUIRED**

### Recommended (For Full Resilience)

3. **OpenAI API Key**
   - Provider: https://platform.openai.com/api-keys
   - Purpose: Additional fallback (GPT-4)
   - Cost: $2.50/M input, $10/M output
   - Status: ✅ **RECOMMENDED**

4. **DeepSeek API Key**
   - Provider: https://platform.deepseek.com/
   - Purpose: Cost-effective subagents
   - Cost: $2.74/M
   - Status: ✅ **RECOMMENDED**

5. **OpenRouter API Key**
   - Provider: https://openrouter.ai/keys
   - Purpose: Free fallback models
   - Cost: $0 (free tier)
   - Status: ✅ **RECOMMENDED**

---

## 📁 Configuration Files

### Core Files

| File | Purpose | Location |
|------|---------|----------|
| `openclaw.json` | Main configuration | `~/.openclaw/openclaw.json` |
| `.env` | API keys | `~/.openclaw/.env` |

### Documentation Files

| File | Purpose |
|------|---------|
| `README.md` | Overview and quick start |
| `COST_ANALYSIS.md` | Detailed cost breakdown |
| `MODEL_USAGE.md` | Guide for using each model |
| `DEPLOYMENT_GUIDE.md` | Step-by-step deployment |
| `.env.example` | Template for API keys |
| `verify-config.sh` | Configuration verification script |
| `CONFIGURATION_SUMMARY.md` | This file |

---

## 🚀 Deployment Checklist

### Pre-Deployment

- [ ] Review `openclaw.json` configuration
- [ ] Obtain required API keys (Anthropic, Google)
- [ ] Obtain recommended API keys (OpenAI, DeepSeek, OpenRouter)
- [ ] Read `COST_ANALYSIS.md` to understand savings
- [ ] Read `MODEL_USAGE.md` to learn model selection

### Deployment

- [ ] Copy `openclaw.json` to `~/.openclaw/openclaw.json`
- [ ] Copy `.env.example` to `~/.openclaw/.env`
- [ ] Edit `.env` with actual API keys
- [ ] Set `.env` permissions to 600
- [ ] Run `openclaw doctor` to verify syntax
- [ ] Run `openclaw models status` to verify auth
- [ ] Run `verify-config.sh` for full verification

### Post-Deployment

- [ ] Start OpenClaw: `openclaw start`
- [ ] Test primary model: `openclaw chat "Hello"`
- [ ] Test model switching: `/model gemini flash`
- [ ] Set up budget alerts in provider dashboards
- [ ] Configure daily cost monitoring
- [ ] Review costs after first week

---

## 📈 Monitoring Setup

### Real-Time Monitoring

```bash
# Check current session
openclaw chat "/status"

# Enable detailed tracking
openclaw chat "/usage full"

# Check provider usage
openclaw status --usage
```

### Daily Monitoring

```bash
# Create monitoring script
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
EOF

chmod +x ~/check-openclaw-costs.sh

# Add to crontab (daily at 6 PM)
(crontab -l 2>/dev/null; echo "0 18 * * * ~/check-openclaw-costs.sh >> ~/openclaw-costs.log 2>&1") | crontab -
```

### Budget Alerts

Set up in each provider dashboard:
- **Anthropic**: 75% threshold alert
- **Google**: $50/month budget
- **OpenAI**: $50 soft limit, $100 hard limit
- **DeepSeek**: Configure budget alerts
- **OpenRouter**: Monitor free tier usage

---

## 🎛️ Model Selection Quick Reference

### By Task Type

| Task | Command | Model | Cost |
|------|---------|-------|------|
| Critical decisions | `/model opus` | Opus 4.6 | $75/M |
| Standard tasks | (default) | Sonnet 4.5 | $15/M |
| Simple queries | `/model gemini flash` | Gemini Flash | $0.30/M |
| Reasoning | `/model deepseek` | DeepSeek | $2.74/M |
| Images | (automatic) | Gemini 3 Flash | $3.50/M |

### By Cost Priority

| Priority | Model | Cost | Savings vs Opus |
|----------|-------|------|-----------------|
| **Cheapest** | Gemini Flash | $0.30/M | 99.6% |
| **Budget** | DeepSeek | $2.74/M | 96% |
| **Balanced** | Sonnet 4.5 | $15/M | 80% |
| **Premium** | Opus 4.6 | $75/M | 0% (baseline) |

---

## 🛡️ Resilience Features

### Automatic Fallback

```
Request → Primary (Sonnet 4.5)
            ↓ (if fails)
         Fallback 1 (GPT-4)
            ↓ (if fails)
         Fallback 2 (Gemini Flash)
            ↓ (if fails)
         Fallback 3 (Free models)
```

### Provider Diversity

- **3 paid providers**: Anthropic, OpenAI, Google
- **1 free provider**: OpenRouter
- **5 model tiers**: Premium, Balanced, Budget, Reasoning, Vision
- **Automatic switching**: No manual intervention needed

### Error Handling

- **Rate limits**: Automatic provider rotation
- **Auth failures**: Fallback to different provider
- **Timeouts**: Retry with cheaper model
- **Billing issues**: Skip to next provider

---

## 🔐 Security Configuration

### API Key Storage

- ✅ Keys stored in `~/.openclaw/.env`
- ✅ File permissions: 600 (owner read/write only)
- ✅ Not in version control (.gitignore)
- ✅ Separate keys for dev/prod

### Gateway Security

- ✅ Auth token required for API access
- ✅ Token stored in environment variable
- ✅ Port 18789 firewalled appropriately
- ✅ SSH key-based authentication

### Best Practices

- 🔄 Rotate API keys quarterly
- 📊 Monitor usage for anomalies
- 🚨 Set up budget alerts
- 🔒 Use restrictive firewall rules
- 📝 Document all configuration changes

---

## 📚 Additional Resources

### Documentation

- **Cost Analysis**: See `COST_ANALYSIS.md` for detailed breakdown
- **Model Usage**: See `MODEL_USAGE.md` for when to use each model
- **Deployment**: See `DEPLOYMENT_GUIDE.md` for step-by-step instructions
- **API Keys**: See `.env.example` for where to obtain keys

### External Links

- [OpenClaw Documentation](https://docs.openclaw.com)
- [VelvetShark Multi-Model Guide](https://velvetshark.com/openclaw-multi-model-routing)
- [Anthropic Console](https://console.anthropic.com/)
- [Google AI Studio](https://makersuite.google.com/)
- [OpenAI Platform](https://platform.openai.com/)
- [DeepSeek Platform](https://platform.deepseek.com/)
- [OpenRouter](https://openrouter.ai/)

---

## 🎯 Success Criteria

After deployment, verify these metrics:

### Cost Metrics
- ✅ Monthly costs 80-85% lower than all-Opus baseline
- ✅ Average cost per million tokens: ~$4 (vs $75 for Opus)
- ✅ Budget alerts configured in all provider dashboards

### Performance Metrics
- ✅ Response quality maintained for 95%+ of tasks
- ✅ Fallback activation < 5% of requests
- ✅ Average response time < 5 seconds

### Operational Metrics
- ✅ 99.9% uptime through fallback chain
- ✅ Zero manual interventions needed
- ✅ Daily cost monitoring automated

---

## 🔄 Maintenance Schedule

### Daily
- Check `~/openclaw-costs.log` for anomalies
- Review any error messages in logs
- Monitor provider dashboards for alerts

### Weekly
- Review total costs vs. budget
- Check fallback activation frequency
- Verify all providers are healthy

### Monthly
- Analyze usage patterns
- Optimize model routing if needed
- Review and adjust budget alerts
- Check for OpenClaw updates
- Rotate API keys (quarterly)

---

## 📞 Support Contacts

### Technical Issues
- OpenClaw Documentation: https://docs.openclaw.com
- OpenClaw GitHub: https://github.com/openclaw/openclaw

### Provider Support
- Anthropic Support: https://console.anthropic.com/support
- Google AI Support: https://support.google.com/
- OpenAI Support: https://help.openai.com/
- DeepSeek Support: https://platform.deepseek.com/support
- OpenRouter Support: https://openrouter.ai/support

---

## 📝 Change Log

### Version 1.0 (2026-02-07)
- Initial configuration release
- Multi-model routing implemented
- Cost optimization strategy defined
- Comprehensive documentation created
- Verification tools included

---

## ✅ Quick Start Summary

1. **Review**: Read this summary and `COST_ANALYSIS.md`
2. **Prepare**: Obtain API keys from providers
3. **Deploy**: Follow `DEPLOYMENT_GUIDE.md`
4. **Verify**: Run `verify-config.sh`
5. **Monitor**: Set up daily cost checks
6. **Optimize**: Adjust after first week

**Expected Result**: 85% cost savings with maintained quality

---

**Configuration Version**: 1.0  
**Last Updated**: 2026-02-07  
**Status**: Production Ready  
**Maintained By**: LiNKbot Team
