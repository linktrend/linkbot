# OpenClaw Multi-Model Routing Configuration

## 🎯 Overview

This directory contains a complete, production-ready OpenClaw configuration that implements native multi-model routing to achieve **50-80% cost savings** on API usage without sacrificing quality.

**Key Benefits:**
- ✅ 85% cost reduction compared to using Claude Opus for everything
- ✅ Intelligent routing based on task complexity
- ✅ Automatic fallback across multiple providers for resilience
- ✅ Zero paid plugins - all routing is native to OpenClaw
- ✅ Production-tested configuration with extensive documentation

## 📁 Files in This Directory

| File | Purpose |
|------|---------|
| `openclaw.json` | Main configuration file with multi-model routing |
| `.env.example` | Template for API keys and environment variables |
| `COST_ANALYSIS.md` | Detailed cost breakdown and savings calculations |
| `MODEL_USAGE.md` | Guide for when to use each model tier |
| `DEPLOYMENT_GUIDE.md` | Step-by-step deployment instructions |
| `README.md` | This file - overview and quick start |

## 🚀 Quick Start

### 1. Review the Configuration

```bash
# Read the main config to understand the routing strategy
cat openclaw.json
```

**Key Configuration Highlights:**
- **Primary Model**: Claude Sonnet 4.5 ($3/M input, $15/M output)
- **Fallback Chain**: GPT-4 → Gemini Flash → Free models
- **Heartbeat**: Gemini 2.5 Flash Lite ($0.50/M) - 99% cheaper
- **Subagents**: DeepSeek Reasoner ($2.74/M) - 96% cheaper
- **Images**: Gemini 3 Flash ($3.50/M) - affordable vision

### 2. Obtain API Keys

You'll need API keys from these providers:

**Required:**
- [Anthropic](https://console.anthropic.com/) - Primary model
- [Google AI Studio](https://makersuite.google.com/app/apikey) - Fallback & images

**Recommended:**
- [OpenAI](https://platform.openai.com/api-keys) - Additional fallback
- [DeepSeek](https://platform.deepseek.com/) - Cost-effective subagents
- [OpenRouter](https://openrouter.ai/keys) - Free fallback models

See `.env.example` for detailed instructions on obtaining each key.

### 3. Deploy to VPS

```bash
# Copy configuration to VPS
scp openclaw.json user@your-vps:~/.openclaw/
scp .env.example user@your-vps:~/.openclaw/.env

# SSH into VPS
ssh user@your-vps

# Edit .env with your actual API keys
nano ~/.openclaw/.env

# Verify configuration
openclaw doctor

# Restart OpenClaw
openclaw restart

# Verify models are working
openclaw models status
```

For detailed deployment steps, see `DEPLOYMENT_GUIDE.md`.

## 💰 Cost Savings Summary

### Baseline (All Claude Opus)
- Input: $15/M tokens
- Output: $75/M tokens
- **Monthly cost (50M tokens): $1,650**

### Optimized (Multi-Model Routing)
- Blended average: ~$4/M tokens
- **Monthly cost (50M tokens): $241**
- **Savings: $1,409/month (85%)**

See `COST_ANALYSIS.md` for detailed breakdowns and scenarios.

## 🎛️ Model Tiers

### When to Use Each Model

| Tier | Model | Cost | Use Case |
|------|-------|------|----------|
| 🏆 Premium | Claude Opus 4.6 | $75/M | Critical decisions only |
| ⭐ Default | Claude Sonnet 4.5 | $15/M | Most tasks (80%) |
| 💰 Budget | Gemini Flash | $0.30/M | Simple queries |
| 🧠 Reasoning | DeepSeek | $2.74/M | Math, logic, analysis |
| 👁️ Vision | Gemini 3 Flash | $3.50/M | Image analysis |
| 🆓 Free | OpenRouter | $0 | Emergency fallback |

### Switching Models in Chat

```bash
/model opus          # Premium quality
/model sonnet        # Default (already active)
/model gemini flash  # Budget option
/model deepseek      # Reasoning tasks
```

See `MODEL_USAGE.md` for comprehensive guide.

## 📊 Expected Usage Patterns

### Light Usage (10M tokens/month)
- **Cost**: $50-100/month
- **Savings**: $280/month vs. Opus
- **Use case**: Small business, personal assistant

### Moderate Usage (50M tokens/month)
- **Cost**: $200-1,000/month
- **Savings**: $1,400/month vs. Opus
- **Use case**: Growing business, customer support

### Heavy Usage (200M tokens/month)
- **Cost**: $1,000-5,000/month
- **Savings**: $5,600/month vs. Opus
- **Use case**: Enterprise, high-volume operations

## 🔧 Configuration Highlights

### Intelligent Routing

```json5
// Primary model for quality
model: {
  primary: "anthropic/claude-sonnet-4-5",
  
  // Automatic fallbacks for resilience
  fallbacks: [
    "openai/gpt-4-turbo",      // Different provider
    "google/gemini-2.0-flash",  // Much cheaper
    "openrouter/deepseek/deepseek-r1:free", // Zero cost
  ],
}
```

### Cost-Optimized Background Tasks

```json5
// Heartbeat uses ultra-cheap model
heartbeat: {
  model: "google/gemini-2.5-flash-lite", // $0.50/M
  thinking: "off", // Faster, cheaper
}

// Subagents use cost-effective reasoning
subagents: {
  model: "deepseek/deepseek-reasoner", // $2.74/M
}
```

### Image Handling

```json5
// Affordable vision model
imageModel: {
  primary: "google/gemini-3-flash", // $3.50/M
  fallbacks: ["google/gemini-2.0-flash-vision"],
}
```

## 📈 Monitoring & Optimization

### Real-Time Monitoring

```bash
# Check current costs
openclaw chat "/status"

# Enable detailed tracking
openclaw chat "/usage full"

# Check provider usage
openclaw status --usage
```

### Daily Cost Check

```bash
# Create monitoring script (see DEPLOYMENT_GUIDE.md)
~/check-openclaw-costs.sh

# View logs
tail -f ~/openclaw-costs.log
```

### Budget Alerts

Set up alerts in provider dashboards:
- Anthropic Console: 75% threshold
- Google Cloud: $50/month budget
- OpenAI Platform: $50 soft limit, $100 hard limit

## 🛡️ Resilience Features

### Automatic Fallback Chain

```
Primary fails (rate limit/error)
    ↓
Fallback 1: GPT-4 (different provider)
    ↓
Fallback 2: Gemini Flash (much cheaper)
    ↓
Fallback 3: Free models (zero cost)
```

### Provider Diversity

- **Anthropic**: Primary model
- **OpenAI**: Fallback resilience
- **Google**: Cost-effective fallback & images
- **DeepSeek**: Reasoning tasks
- **OpenRouter**: Free emergency fallback

### Session Stickiness

OpenClaw pins auth profiles per session to keep provider caches warm, improving performance and reducing costs.

## 🔐 Security Best Practices

- ✅ API keys stored in `~/.openclaw/.env` (not in config)
- ✅ `.env` file has 600 permissions
- ✅ Never commit `.env` to version control
- ✅ Generate secure auth token for gateway
- ✅ Rotate API keys periodically
- ✅ Use separate keys for dev/prod

## 📚 Documentation

### Quick Reference

- **Cost Analysis**: See `COST_ANALYSIS.md`
- **Model Usage**: See `MODEL_USAGE.md`
- **Deployment**: See `DEPLOYMENT_GUIDE.md`
- **API Keys**: See `.env.example`

### External Resources

- [OpenClaw Documentation](https://docs.openclaw.com)
- [VelvetShark Multi-Model Guide](https://velvetshark.com/openclaw-multi-model-routing)
- [Model Providers](../../docs/concepts/model-providers.md)
- [Configuration Reference](../../docs/gateway/configuration.md)

## 🎓 Learning Path

### For New Users

1. Read `COST_ANALYSIS.md` to understand savings potential
2. Review `openclaw.json` to see how routing works
3. Follow `DEPLOYMENT_GUIDE.md` step-by-step
4. Study `MODEL_USAGE.md` to learn when to use each model
5. Monitor costs for first week and adjust as needed

### For Experienced Users

1. Review `openclaw.json` configuration
2. Customize model tiers based on your needs
3. Deploy using `DEPLOYMENT_GUIDE.md` as reference
4. Set up monitoring and budget alerts
5. Optimize based on usage patterns

## 🤝 Support

### Common Issues

**"Model is not allowed"**
- Check `agents.defaults.models` in `openclaw.json`
- Ensure model is in allowlist

**"No API key found"**
- Verify `~/.openclaw/.env` has correct keys
- Run `openclaw models status` to check auth

**High costs**
- Check which models are being used: `openclaw status --usage`
- Switch to cheaper models: `/model gemini flash`
- Review `MODEL_USAGE.md` for optimization tips

### Getting Help

1. Check `DEPLOYMENT_GUIDE.md` troubleshooting section
2. Review OpenClaw documentation
3. Check provider dashboards for API issues
4. Verify configuration with `openclaw doctor`

## 🎯 Success Metrics

After deployment, you should see:

- ✅ **85% cost reduction** vs. all-Opus baseline
- ✅ **High availability** through fallback chain
- ✅ **Quality maintained** for most tasks
- ✅ **Fast responses** with optimized models
- ✅ **Predictable costs** with budget alerts

## 🚦 Next Steps

1. **Deploy**: Follow `DEPLOYMENT_GUIDE.md`
2. **Monitor**: Track costs for first week
3. **Optimize**: Adjust based on usage patterns
4. **Scale**: Add channels and integrations as needed
5. **Maintain**: Review monthly and adjust as needed

## 📝 Version History

- **v1.0** (2026-02-07): Initial release
  - Multi-model routing configuration
  - Cost analysis and savings calculations
  - Comprehensive documentation
  - Deployment guide and monitoring tools

## 📄 License

This configuration is part of the LiNKbot project. Use and modify as needed for your deployment.

---

**Configuration Version**: 1.0  
**Last Updated**: 2026-02-07  
**Maintained By**: LiNKbot Team  
**Reference**: https://velvetshark.com/openclaw-multi-model-routing
