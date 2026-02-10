# Gateway Testing Quick Start

**5-Minute Guide to Testing Your OpenClaw Gateway**

---

## Run the Test

```bash
cd /Users/linktrend/Projects/LiNKbot/scripts
./test-lisa-gateway.sh <VPS_IP> <AUTH_TOKEN>
```

**Example:**
```bash
./test-lisa-gateway.sh 143.198.123.45 abc123xyz789def456
```

---

## Get Your Token

```bash
# SSH into VPS
ssh root@YOUR_VPS_IP

# Get dashboard URL with token
openclaw dashboard

# Copy the token from the URL:
# http://YOUR_IP:18789/?token=THIS_IS_YOUR_TOKEN
```

---

## What Gets Tested (10 Tests)

✅ Gateway connectivity  
✅ Authentication  
✅ Primary AI model (Kimi K2.5)  
✅ Heartbeat model (Gemini FREE)  
✅ Skills loaded  
✅ Sub-agent config  
✅ Telegram integration  
✅ Session management  
⊘ Memory persistence (manual)  
✅ Rate limiting  

---

## Reading Results

### ✓ PASS (Green)
Everything working correctly

### ✗ FAIL (Red)
**Action needed:**
- Check logs: `logs/gateway-tests-*.log`
- Verify OpenClaw running: `ssh root@VPS_IP 'systemctl status openclaw'`
- Restart if needed: `ssh root@VPS_IP 'systemctl restart openclaw'`

### ⊘ SKIP (Yellow)
Test not applicable or requires manual verification

---

## Common Issues

### "Cannot reach gateway"
```bash
# Check if OpenClaw is running
ssh root@VPS_IP 'systemctl status openclaw'

# Check firewall
ssh root@VPS_IP 'sudo ufw status | grep 18789'

# Restart service
ssh root@VPS_IP 'systemctl restart openclaw'
```

### "Authentication failed"
```bash
# Get new token
ssh root@VPS_IP 'openclaw dashboard'
# Use token from output
```

### "Missing dependencies"
```bash
# macOS
brew install coreutils jq

# Ubuntu/Debian
sudo apt install curl jq bc
```

---

## Cost per Test

**~$0.001-0.005** (less than 1 cent)

Most tests use FREE models (Gemini, Devstral)

---

## Useful Commands

```bash
# View latest log
ls -lt logs/gateway-tests-*.log | head -1

# Check OpenClaw health remotely
ssh root@VPS_IP 'openclaw gateway health --url ws://127.0.0.1:18789'

# View OpenClaw logs
ssh root@VPS_IP 'journalctl -u openclaw -n 50'

# Access dashboard
open "http://VPS_IP:18789/?token=YOUR_TOKEN"
```

---

## When to Run Tests

| Phase | Frequency |
|-------|-----------|
| Initial deployment | Every hour |
| Testing (Week 1) | 3-5 times/day |
| Production | Daily or weekly |
| After changes | Immediately |

---

## Success Targets

- **Initial**: 60%+ pass rate
- **Week 1**: 80%+ pass rate  
- **Production**: 90%+ pass rate

---

## Full Documentation

**Detailed guide**: `TESTING_GUIDE.md`

**Project docs**: `/docs/MASTER_DEPLOYMENT_CHECKLIST.md`

---

**Quick Start Version**: 1.0  
**Date**: February 9, 2026
