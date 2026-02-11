# OpenClaw Model Usage Guide

## Overview

This guide explains when to use each model tier, how to switch models during conversations, and how to monitor your API costs effectively.

## Model Tiers & When to Use Them

### 🏆 Tier 1: Premium (Claude Opus 4.6)

**Cost**: $15/M input, $75/M output  
**When to use**:
- Critical business decisions requiring highest accuracy
- Complex legal or financial analysis
- Multi-step reasoning with high stakes
- When quality is more important than cost

**How to activate**:
```
/model opus
```

**Example tasks**:
- "Analyze this contract for potential legal risks"
- "Create a comprehensive business strategy for Q2"
- "Review and critique this financial model"

---

### ⭐ Tier 2: Balanced (Claude Sonnet 4.5) - DEFAULT

**Cost**: $3/M input, $15/M output  
**When to use**:
- Most day-to-day interactions (80% of tasks)
- Standard customer support queries
- Content creation and editing
- Code generation and review
- Research and summarization

**How to activate**:
```
/model sonnet
(or it's already active by default)
```

**Example tasks**:
- "Help me draft a customer email"
- "Explain this technical concept"
- "Generate a Python script for data processing"
- "Summarize this article"

---

### 💰 Tier 3: Cost-Effective (Google Gemini 2.0 Flash)

**Cost**: $0.075/M input, $0.30/M output  
**When to use**:
- Simple queries and quick questions
- Bulk processing of similar tasks
- Draft generation (to be refined later)
- Testing and experimentation
- When speed matters more than perfection

**How to activate**:
```
/model gemini flash
```

**Example tasks**:
- "What's the weather like today?"
- "Generate 10 blog post title ideas"
- "Quick translation of this text"
- "Simple data formatting"

---

### 🧠 Tier 4: Reasoning (DeepSeek Reasoner)

**Cost**: $2.74/M input and output  
**When to use**:
- Mathematical problem solving
- Logical reasoning tasks
- Algorithm design
- Scientific analysis
- When you need step-by-step thinking

**How to activate**:
```
/model deepseek
```

**Example tasks**:
- "Solve this complex math problem step by step"
- "Design an algorithm for route optimization"
- "Analyze this dataset for patterns"

---

### 👁️ Tier 5: Vision (Google Gemini 3 Flash)

**Cost**: $3.50/M  
**When to use**:
- Image analysis and description
- Chart and graph interpretation
- Screenshot analysis
- Visual content understanding
- OCR and text extraction from images

**How to activate**:
```
(Automatically used when you send an image)
```

**Example tasks**:
- "What's in this image?"
- "Extract text from this screenshot"
- "Analyze this chart and explain the trends"

---

### 🆓 Tier 6: Free Fallback (OpenRouter Free Models)

**Cost**: $0 (free tier)  
**When to use**:
- Emergency fallback when primary models fail
- Budget testing and experimentation
- Non-critical tasks with zero budget
- Learning and exploration

**How to activate**:
```
/model deepseek free
/model llama free
```

**Example tasks**:
- Testing new prompts
- Casual experimentation
- Non-critical queries

---

## Model Switching Commands

### View Available Models

```
/model
/model list
```

This shows all configured models with their aliases and costs.

### Switch to Specific Model

```
/model <alias>
/model <provider/model>
```

**Examples**:
```
/model opus              # Switch to Claude Opus 4.6
/model sonnet            # Switch to Claude Sonnet 4.5
/model gemini flash      # Switch to Gemini 2.0 Flash
/model deepseek          # Switch to DeepSeek Reasoner
/model gpt-4             # Switch to GPT-4 Turbo
```

### Check Current Model

```
/model status
/status
```

Shows your current model, token usage, and estimated cost.

### Reset to Default

```
/new
/reset
```

Starts a new session with the default model (Sonnet 4.5).

---

## Cost Monitoring

### Real-Time Cost Tracking

**Check current session cost**:
```
/status
```

Shows:
- Current model
- Tokens used (input/output)
- Estimated cost for last response
- Total session tokens

**Enable detailed usage tracking**:
```
/usage full
```

Appends cost information to every response.

**Token-only tracking**:
```
/usage tokens
```

Shows token counts without dollar amounts.

**Disable usage tracking**:
```
/usage off
```

### Provider-Level Monitoring

**Check provider quotas and usage**:
```bash
openclaw status --usage
```

Shows usage windows and quota information from each provider.

**Check model authentication status**:
```bash
openclaw models status
```

Displays auth profiles, expiry status, and available models.

---

## Task-Based Model Selection Guide

### Content Creation

| Task | Recommended Model | Reasoning |
|------|------------------|-----------|
| Blog posts | Sonnet 4.5 | Good quality, reasonable cost |
| Social media | Gemini Flash | Fast, cheap, good enough |
| Marketing copy | Sonnet 4.5 | Quality matters for conversion |
| Email drafts | Gemini Flash | Simple, fast |
| Technical docs | Sonnet 4.5 | Accuracy important |

### Customer Support

| Task | Recommended Model | Reasoning |
|------|------------------|-----------|
| Simple FAQs | Gemini Flash | Fast, cheap, handles basics |
| Complex issues | Sonnet 4.5 | Better understanding |
| Escalations | Opus 4.6 | Critical situations |
| Bulk responses | Gemini Flash | Cost-effective at scale |

### Development

| Task | Recommended Model | Reasoning |
|------|------------------|-----------|
| Code generation | Sonnet 4.5 | Good balance |
| Code review | Sonnet 4.5 | Catches most issues |
| Critical review | Opus 4.6 | Security/production code |
| Quick scripts | Gemini Flash | Fast prototyping |
| Algorithm design | DeepSeek | Strong reasoning |

### Analysis

| Task | Recommended Model | Reasoning |
|------|------------------|-----------|
| Data analysis | DeepSeek | Strong analytical skills |
| Financial analysis | Opus 4.6 | High stakes, need accuracy |
| Market research | Sonnet 4.5 | Good balance |
| Quick summaries | Gemini Flash | Fast and cheap |
| Image analysis | Gemini 3 Flash | Vision capability |

### Research

| Task | Recommended Model | Reasoning |
|------|------------------|-----------|
| Deep research | Sonnet 4.5 | Comprehensive |
| Quick lookups | Gemini Flash | Fast facts |
| Academic papers | Opus 4.6 | Complex reasoning |
| Summarization | Gemini Flash | Cost-effective |

---

## Budget Management Tips

### 1. Start Cheap, Escalate When Needed

```
Strategy: Begin with Gemini Flash, switch to Sonnet if quality isn't sufficient.

Example workflow:
1. /model gemini flash
2. "Draft a customer response email"
3. (Review output - if not good enough)
4. /model sonnet
5. "Improve this draft with better tone and clarity"
```

### 2. Use Appropriate Models for Batch Tasks

```
For 100 similar tasks:
- Gemini Flash: $0.30 for 1M output tokens
- Sonnet 4.5: $15 for 1M output tokens
- Savings: $14.70 per million tokens (98%)
```

### 3. Reserve Opus for Critical Decisions

```
Rule of thumb:
- Use Opus for < 5% of tasks
- Use Sonnet for ~70% of tasks
- Use Gemini Flash for ~25% of tasks

This maintains quality while achieving 80%+ cost savings.
```

### 4. Monitor Daily Costs

```bash
# Check costs at end of each day
openclaw status --usage

# Review provider dashboards weekly
- Anthropic Console: https://console.anthropic.com/
- Google AI Studio: https://makersuite.google.com/
- OpenAI Platform: https://platform.openai.com/usage
```

### 5. Set Budget Alerts

Configure alerts in each provider dashboard:
- **Warning threshold**: 75% of monthly budget
- **Critical threshold**: 90% of monthly budget
- **Hard limit**: 100% of monthly budget (if supported)

---

## Advanced Techniques

### Model Override for Specific Tasks

You can temporarily switch models for a single query:

```
/model gemini flash
"Quick question: what's 2+2?"

/model sonnet
"Now help me with this complex analysis..."
```

### Subagent Model Control

Subagents automatically use DeepSeek Reasoner (configured in openclaw.json), but you can override:

```json5
// In openclaw.json
subagents: {
  model: {
    primary: "deepseek/deepseek-reasoner",
    fallbacks: ["google/gemini-2.0-flash"],
  },
}
```

### Session-Specific Model Preferences

Models persist within a session until you switch or reset:

```
Session 1:
/model opus
(All subsequent queries use Opus until /new or /reset)

Session 2:
/new
(Resets to default: Sonnet 4.5)
```

---

## Troubleshooting

### "Model is not allowed"

**Problem**: Selected model isn't in the allowlist.

**Solution**:
```bash
# Check available models
/model list

# Or add model to openclaw.json
agents: {
  defaults: {
    models: {
      "provider/model": { alias: "MyModel" }
    }
  }
}
```

### "No API key found for provider"

**Problem**: Missing API key for selected provider.

**Solution**:
```bash
# Check auth status
openclaw models status

# Add API key to ~/.openclaw/.env
PROVIDER_API_KEY=your-key-here
```

### Rate Limiting

**Problem**: "Rate limit exceeded" errors.

**Solution**: Fallback chain automatically activates:
1. Primary model fails
2. Tries first fallback (different provider)
3. Tries second fallback
4. Tries free fallback

No action needed - it's automatic!

### High Costs

**Problem**: Monthly costs higher than expected.

**Solution**:
```bash
# Check usage breakdown
openclaw status --usage

# Review which models are being used most
/usage full

# Switch to cheaper models for routine tasks
/model gemini flash
```

---

## Quick Reference

### Most Common Commands

```bash
/model                    # List available models
/model sonnet            # Switch to Sonnet 4.5 (default)
/model opus              # Switch to Opus 4.6 (premium)
/model gemini flash      # Switch to Gemini Flash (cheap)
/model deepseek          # Switch to DeepSeek (reasoning)
/status                  # Check current model and costs
/usage full              # Enable cost tracking
/new                     # Start fresh with default model
```

### Cost Comparison (per 1M output tokens)

```
Opus:         $75.00  (Premium)
Sonnet:       $15.00  (Default - 80% savings)
GPT-4:        $10.00  (Fallback - 87% savings)
DeepSeek:     $2.74   (Reasoning - 96% savings)
Gemini Flash: $0.30   (Budget - 99.6% savings)
Free Models:  $0.00   (Emergency - 100% savings)
```

---

## Best Practices Summary

1. ✅ **Use Sonnet 4.5 as default** - Best balance of quality and cost
2. ✅ **Reserve Opus for critical tasks** - Only when quality is paramount
3. ✅ **Use Gemini Flash for simple queries** - 99% cheaper than Opus
4. ✅ **Let subagents use DeepSeek** - Automatic cost optimization
5. ✅ **Monitor costs weekly** - Catch issues early
6. ✅ **Set budget alerts** - Prevent surprises
7. ✅ **Start cheap, escalate if needed** - Optimize as you go
8. ✅ **Use /status frequently** - Stay aware of costs
9. ✅ **Trust the fallback chain** - Automatic resilience
10. ✅ **Review monthly usage** - Identify optimization opportunities

---

**Last Updated**: 2026-02-07  
**Configuration Version**: 1.0  
**For questions**: Refer to OpenClaw documentation at https://docs.openclaw.com
