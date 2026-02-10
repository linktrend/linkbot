# API Keys Setup Guide - Business Partner Bot

## Overview

This guide walks you through obtaining all API keys required for the Business Partner Bot (Lisa). Follow these steps in order to set up your AI model providers and integrations.

**Estimated Time**: 30-45 minutes  
**Cost**: Most keys are free to obtain; billing happens on usage

---

## Required API Keys (Critical)

### 1. OpenRouter API Key (Multi-Model Access)

**Purpose**: Access to Kimi K2.5 (primary model), Devstral 2 (FREE coding), and other models  
**Cost**: 5.5% platform fee + model costs  
**Free Tier**: 25+ free models available (including Devstral 2)

**Steps**:
1. Visit: https://openrouter.ai/
2. Sign up with email or GitHub
3. Navigate to "Keys" section
4. Click "Create Key"
5. Copy the key (starts with `sk-or-...`)
6. **Optional**: Add credits ($10 minimum for paid models)

**Environment Variable**:
```bash
OPENROUTER_API_KEY=sk-or-your-key-here
```

**Important**: You'll primarily use FREE models (Devstral 2) and Kimi K2.5 ($0.45/$2.25 per 1M via OpenRouter)

---

### 2. Google AI API Key (Gemini Models) - CRITICAL FOR FREE TIER

**Purpose**: Heartbeat, image analysis, and 60-70% of skills (FREE!)  
**Cost**: **$0** for up to 1,500 requests/day (45,000/month)  
**Free Tier**: Gemini 2.5 Flash, Flash-Lite, 3 Flash Preview all FREE

**Steps**:
1. Visit: https://aistudio.google.com/apikey
2. Sign in with Google account
3. Click "Create API Key"
4. Select "Create API key in new project" or use existing project
5. Copy the key (starts with `AIza...`)

**Environment Variable**:
```bash
GOOGLE_API_KEY=AIzaSy...your-key-here
```

**Important**: This same key is used for:
- Gemini 2.0 Flash (fallback model)
- Gemini 2.5 Flash Lite (heartbeat)
- Gemini 3 Flash (image analysis)

---

## Optional API Keys (Recommended for Antigravity Coding)

### 3. Anthropic API Key (Claude - Fallback Only)

**Purpose**: Emergency fallback if OpenRouter unavailable  
**Cost**: $3/M input, $15/M output (Sonnet 4.5)  
**Free Tier**: $5 credit for new accounts

**Steps**:
1. Visit: https://console.anthropic.com/
2. Sign up or log in
3. Navigate to "API Keys"
4. Click "Create Key"
5. Copy the key (starts with `sk-ant-...`)
6. Set usage limits (recommended: $50/month)

**Environment Variable**:
```bash
ANTHROPIC_API_KEY=sk-ant-your-key-here
```

**Note**: With your optimized configuration, you likely won't use this much (maybe $0-5/month)

---

### 4. Google OAuth (Antigravity Integration)

**Purpose**: FREE access to Opus 4.5 + Gemini via Antigravity for coding  
**Cost**: **$0** (uses Google's Cloud Code Assist quota)  
**Setup**: Done during Antigravity plugin installation (Phase 2)

**Note**: This is separate from Google AI API key. Antigravity uses OAuth to access Google's coding models for free.

---

### 5. Brave Search API Key (Web Research)

**Purpose**: Web search for skills (research, fact-checking)  
**Cost**: Free tier 2,000 requests/month  
**Free Tier**: Generous free quota

**Steps**:
1. Visit: https://brave.com/search/api/
2. Sign up for Brave Search API
3. Navigate to "API Keys"
4. Click "Create API Key"
5. Copy the key

**Environment Variable**:
```bash
BRAVE_API_KEY=your-brave-key-here
```

---

## Summary: Required Keys for Week 1

**Must Have** (Phase 1 deployment):
1. ✅ OpenRouter API Key (Kimi K2.5 + FREE Devstral 2)
2. ✅ Google AI API Key (FREE Gemini models - heartbeat, skills, fallback)
3. ✅ Brave Search API Key (FREE tier for web research)

**Nice to Have** (Phase 1):
4. ⭕ Anthropic API Key (emergency fallback only - likely $0-5/month usage)

**Set Up Later** (Phase 2):
5. 🔜 Google OAuth for Antigravity (during Antigravity plugin installation)

**Estimated Monthly Cost with These Keys**:
- OpenRouter (Kimi K2.5): $12-20/month
- Google Gemini (direct): **$0** (free tier)
- Devstral 2 (OpenRouter): **$0** (free)
- Brave Search: **$0** (free tier)
- Anthropic fallback: $0-5/month
- **Total: $12-25/month** (vs. $1,300 baseline = 98% savings)

---

## Integration Keys (Set Up Later in Phase 2)

### 7. Google Workspace OAuth (Gmail, Calendar, Docs)

**Purpose**: Email, calendar, document management  
**Cost**: Free (uses your existing Google Workspace)  
**Setup**: Requires OAuth 2.0 configuration (detailed in Phase 2)

**Placeholder**:
```bash
GOOGLE_OAUTH_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_OAUTH_CLIENT_SECRET=your-client-secret
GOOGLE_OAUTH_REFRESH_TOKEN=your-refresh-token
```

**Note**: We'll set this up in Phase 2 (Google Workspace API Setup)

---

### 8. Telegram Bot Token

**Purpose**: Urgent notifications and quick commands  
**Cost**: Free  
**Setup**: Create bot via BotFather (detailed in Phase 2)

**Placeholder**:
```bash
TELEGRAM_BOT_TOKEN=1234567890:ABC...your-bot-token
TELEGRAM_CHAT_ID=your-chat-id
```

**Note**: We'll set this up in Phase 2 (Telegram Bot Setup)

---

## Security Best Practices

### Immediate Security Checklist

✅ **Store keys securely**:
```bash
# Create .env file
cd /Users/linktrend/Projects/LiNKbot/bots/business-partner/config/business-partner
cp .env.example .env

# Restrict permissions (owner read/write only)
chmod 600 .env

# Edit file with API keys
open .env
```

✅ **Set usage limits** on each provider dashboard:
- Anthropic: $100/month limit
- OpenAI: $50/month limit
- Google: 60 requests/minute (default)
- DeepSeek: $25/month limit

✅ **Enable billing alerts**:
- Anthropic Console → Settings → Billing → Set alert at 75%
- OpenAI Platform → Organization → Billing → Set monthly cap
- Google Cloud Console → Billing → Budgets & Alerts

✅ **Never commit .env to git**:
```bash
# Verify .env is in .gitignore
grep ".env" /Users/linktrend/Projects/LiNKbot/.gitignore
# Should show: .env (already configured)
```

---

## Cost Monitoring Setup

### Recommended Budget Alerts

| Provider | Recommended Limit | Alert Threshold |
|----------|------------------|----------------|
| Anthropic | $100/month | $75 (75%) |
| OpenAI | $50/month | $37.50 (75%) |
| Google | Free tier sufficient | N/A |
| DeepSeek | $25/month | $18.75 (75%) |
| OpenRouter | $10 credit | $7.50 (75%) |

**Total Monthly Budget**: ~$175-200/month (moderate usage)  
**Expected Actual Cost**: ~$50-75/month with optimized routing

---

## Verification Checklist

After obtaining all keys, verify each one works:

### Quick Test Commands

**Test Anthropic**:
```bash
curl -X POST https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-sonnet-4-5",
    "max_tokens": 50,
    "messages": [{"role": "user", "content": "Hi"}]
  }'
```

**Test Google AI**:
```bash
curl "https://generativelanguage.googleapis.com/v1/models?key=$GOOGLE_API_KEY"
```

**Test OpenAI**:
```bash
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY"
```

**Test OpenRouter**:
```bash
curl https://openrouter.ai/api/v1/models \
  -H "Authorization: Bearer $OPENROUTER_API_KEY"
```

**Test Brave Search**:
```bash
curl "https://api.search.brave.com/res/v1/web/search?q=test" \
  -H "X-Subscription-Token: $BRAVE_API_KEY"
```

---

## Common Issues & Solutions

### "Invalid API Key"
- **Check**: Key copied completely (no spaces/newlines)
- **Check**: Key is activated (some providers require email verification)
- **Check**: Billing account set up (some providers require payment method)

### "Rate Limit Exceeded"
- **Check**: Free tier quota limits
- **Wait**: Most providers reset limits hourly or daily
- **Upgrade**: Add payment method to increase limits

### "Insufficient Credits"
- **Add funds**: Most providers require $5-10 minimum deposit
- **Set up billing**: Add credit card to provider dashboard

---

## Next Steps

Once you have all required API keys:

1. ✅ Store keys in `.env` file
2. ✅ Set `chmod 600 .env` permissions
3. ✅ Set usage limits on provider dashboards
4. ✅ Enable billing alerts
5. ✅ Test each key with curl commands above
6. ➡️ **Proceed to**: VPS Deployment Guide

---

**Estimated Completion Time**: 30-45 minutes  
**Status**: Ready to start  
**Next Guide**: `/docs/guides/VPS_DEPLOYMENT.md`
