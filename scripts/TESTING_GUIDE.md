# OpenClaw Gateway Testing Guide

## Overview

The `test-lisa-gateway.sh` script provides comprehensive automated testing for your OpenClaw gateway deployment. It validates connectivity, authentication, model configuration, skills, integrations, and performance metrics.

---

## Quick Start

### Basic Usage

```bash
cd /Users/linktrend/Projects/LiNKbot/scripts

# Method 1: Pass parameters directly
./test-lisa-gateway.sh <VPS_IP> <AUTH_TOKEN>

# Method 2: Use environment variables
export VPS_IP="143.198.123.45"
export OPENCLAW_TOKEN="your_gateway_token_here"
./test-lisa-gateway.sh
```

### Example

```bash
./test-lisa-gateway.sh 143.198.123.45 abc123xyz789def456
```

---

## Prerequisites

### Required Tools

The script requires the following command-line tools:

- `curl` - HTTP requests
- `jq` - JSON parsing
- `bc` - Calculations
- `timeout` - Command timeouts

### Installation (macOS)

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install coreutils jq
```

### Installation (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install curl jq bc coreutils
```

---

## Test Coverage

The script performs **10 comprehensive tests**:

### 1. Gateway Connectivity
- **Purpose**: Verify gateway is reachable on port 18789
- **Method**: HTTP health check
- **Pass Criteria**: HTTP 200, 401, or 404 response
- **Metrics**: Response time

### 2. Authentication
- **Purpose**: Validate authentication token
- **Method**: Access dashboard with token
- **Pass Criteria**: HTTP 200 with OpenClaw content
- **Metrics**: Response time

### 3. Primary Model (Kimi K2.5)
- **Purpose**: Test primary AI model via OpenRouter
- **Method**: POST request to chat API
- **Pass Criteria**: Response indicates Kimi/K2.5/Moonshot
- **Metrics**: Response time, token usage
- **Cost**: ~$0.001-0.01 per test

### 4. Heartbeat Model (Gemini Flash Lite)
- **Purpose**: Verify FREE heartbeat model
- **Method**: Health endpoint check
- **Pass Criteria**: Response indicates Gemini or healthy status
- **Metrics**: Response time
- **Cost**: FREE

### 5. Simple Skill Execution
- **Purpose**: Check if skills are loaded
- **Method**: Query skills endpoint
- **Pass Criteria**: Skills list returned
- **Metrics**: Number of skills, response time

### 6. Sub-agent Spawn Test
- **Purpose**: Verify sub-agent configuration (Devstral 2)
- **Method**: Check config endpoint
- **Pass Criteria**: Sub-agent settings detected
- **Metrics**: Response time

### 7. Telegram Notification
- **Purpose**: Check Telegram integration
- **Method**: Query channels endpoint
- **Pass Criteria**: Telegram channel detected
- **Metrics**: Response time

### 8. Session Creation
- **Purpose**: Test /new command and session management
- **Method**: POST to session endpoint
- **Pass Criteria**: New session created
- **Metrics**: Response time

### 9. Memory Persistence
- **Purpose**: Verify memory management
- **Method**: Interactive test (manual)
- **Pass Criteria**: Skipped (requires manual testing)

### 10. Rate Limit Handling
- **Purpose**: Test rate limiting configuration
- **Method**: 5 rapid requests
- **Pass Criteria**: Requests succeed without blocking
- **Metrics**: Success rate, total time

---

## Output & Results

### Console Output

The script provides color-coded real-time feedback:

- 🔵 **Blue (▸)**: Test starting
- 🟢 **Green (✓)**: Test passed
- 🔴 **Red (✗)**: Test failed
- 🟡 **Yellow (⊘)**: Test skipped
- 🔵 **Cyan (ℹ)**: Information

### Log File

All results are saved to:
```
/Users/linktrend/Projects/LiNKbot/logs/gateway-tests-<timestamp>.log
```

Example: `gateway-tests-20260209-143052.log`

### Summary Report

At completion, the script generates:

```
╔════════════════════════════════════════════════════════════════╗
║  Test Summary Report                                           ║
╚════════════════════════════════════════════════════════════════╝

Test Results:
  Total Tests Run:    10
  Passed:            8
  Failed:            0
  Skipped:           2

Success Rate: 80.0% (excluding skips)

Performance Metrics:
  Avg Response Time:  0.85s
  Total Requests:     12

Cost Estimate (this test session):
  Input Tokens:       150
  Output Tokens:      75
  Estimated Cost:     $0.0002
  Note: Most tests use FREE models (Gemini, Devstral)
```

---

## Interpreting Results

### All Tests Passed (Green)
✅ **Gateway is fully operational**

**Next steps:**
1. Install skills via ClawHub
2. Complete Telegram setup
3. Configure Google Workspace
4. Run production tests

### Some Tests Failed (Red)
⚠️ **Review failures and troubleshoot**

**Common issues:**

#### "Cannot reach gateway"
- Gateway not fully initialized (wait 5-10 minutes)
- Firewall blocking port 18789
- Wrong VPS IP address

**Fix:**
```bash
# Check if service is running
ssh root@VPS_IP 'systemctl status openclaw'

# Check firewall
ssh root@VPS_IP 'sudo ufw status'

# Restart gateway
ssh root@VPS_IP 'systemctl restart openclaw'
```

#### "Authentication failed"
- Invalid or expired token
- Token not configured

**Fix:**
```bash
# Get fresh token
ssh root@VPS_IP 'openclaw dashboard'
# Use the token from the generated URL
```

#### "API endpoint not accessible"
- Gateway configured but API not enabled
- OpenClaw version mismatch

**Fix:**
```bash
# Check OpenClaw version
ssh root@VPS_IP 'openclaw --version'

# View logs for errors
ssh root@VPS_IP 'journalctl -u openclaw -n 100'
```

### All Tests Skipped (Yellow)
⚠️ **Gateway accessible but not configured**

**This indicates:**
- Basic connectivity works
- Configuration incomplete
- Skills/integrations not installed

**Next steps:**
1. Access dashboard: `http://VPS_IP:18789/?token=TOKEN`
2. Complete configuration wizard
3. Install skills
4. Re-run tests

---

## Cost Analysis

### Test Session Costs

**Typical test run:**
- Duration: 15-30 seconds
- API calls: 2-5 (most use FREE models)
- Estimated cost: **$0.0001-0.005**

**Cost breakdown:**
- Gateway connectivity: FREE (HTTP only)
- Authentication: FREE (HTTP only)
- Primary model test: ~$0.001 (Kimi K2.5)
- Heartbeat: FREE (Gemini Flash Lite)
- Skills check: FREE (HTTP only)
- Sub-agent: FREE (config check)
- Telegram: FREE (HTTP only)
- Session: FREE (HTTP only)
- Rate limit: FREE (HTTP only)

**Total per test run: <$0.01**

### Recommended Testing Frequency

| Phase | Frequency | Monthly Cost |
|-------|-----------|--------------|
| Initial deployment | 5-10 runs/day | ~$0.50 |
| Testing period (Week 1) | 3-5 runs/day | ~$0.30 |
| Normal operation | 1 run/day | ~$0.10 |
| Maintenance | 1 run/week | ~$0.02 |

---

## Advanced Usage

### Run Specific Tests Only

Modify the script to comment out tests you don't need:

```bash
# Edit the script
nano test-lisa-gateway.sh

# Comment out unwanted tests in main()
# test_skill_execution  # Skip this test
```

### Custom Timeout Values

Increase timeouts for slow connections:

```bash
# Edit timeout values in the script
# Default: timeout 10 curl ...
# Change to: timeout 30 curl ...
```

### Verbose Logging

Enable verbose curl output for debugging:

```bash
# Add -v flag to curl commands
curl -v -s "http://${VPS_IP}:18789/health"
```

### Run from Cron

Automate daily testing:

```bash
# Add to crontab
crontab -e

# Run daily at 9 AM
0 9 * * * /Users/linktrend/Projects/LiNKbot/scripts/test-lisa-gateway.sh $VPS_IP $TOKEN >> /tmp/openclaw-tests.log 2>&1
```

---

## Troubleshooting

### Script Won't Run

**Error: Permission denied**
```bash
chmod +x test-lisa-gateway.sh
```

**Error: Command not found (jq, bc)**
```bash
# macOS
brew install jq

# Ubuntu
sudo apt install jq bc
```

### Network Issues

**Error: Connection timeout**
```bash
# Test connectivity manually
ping YOUR_VPS_IP

# Test port access
nc -zv YOUR_VPS_IP 18789

# Or use telnet
telnet YOUR_VPS_IP 18789
```

**Error: Connection refused**
```bash
# Check if OpenClaw is running
ssh root@VPS_IP 'docker ps'

# Check if port is listening
ssh root@VPS_IP 'netstat -tuln | grep 18789'
```

### Authentication Issues

**Error: 401 Unauthorized**
```bash
# Regenerate token
ssh root@VPS_IP 'openclaw dashboard'

# Copy new token from output
# Re-run test with new token
```

### Slow Response Times

**Avg response time >5 seconds**

Possible causes:
1. High server load
2. Network latency
3. Gateway processing backlog

**Check:**
```bash
# Check server resources
ssh root@VPS_IP 'htop'

# Check gateway load
ssh root@VPS_IP 'journalctl -u openclaw -n 50'
```

---

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Gateway Tests

on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y curl jq bc
      
      - name: Run gateway tests
        env:
          VPS_IP: ${{ secrets.VPS_IP }}
          OPENCLAW_TOKEN: ${{ secrets.OPENCLAW_TOKEN }}
        run: |
          cd scripts
          chmod +x test-lisa-gateway.sh
          ./test-lisa-gateway.sh
      
      - name: Upload logs
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-logs
          path: logs/gateway-tests-*.log
```

---

## Best Practices

### Before Running Tests

1. ✅ Ensure VPS is powered on
2. ✅ Verify OpenClaw service is running
3. ✅ Have valid authentication token
4. ✅ Check firewall allows port 18789
5. ✅ Confirm you have active API keys

### During Testing

1. ✅ Don't interrupt tests mid-run
2. ✅ Monitor output for warnings
3. ✅ Save timestamps for correlation
4. ✅ Take screenshots of failures

### After Testing

1. ✅ Review log file completely
2. ✅ Compare with previous test runs
3. ✅ Document any anomalies
4. ✅ Update configurations as needed
5. ✅ Archive logs for reference

---

## Performance Benchmarks

### Expected Response Times

| Test | Target | Good | Warning | Critical |
|------|--------|------|---------|----------|
| Connectivity | <1s | <2s | 2-5s | >5s |
| Authentication | <2s | <3s | 3-7s | >7s |
| Primary Model | <3s | <5s | 5-10s | >10s |
| Heartbeat | <1s | <2s | 2-5s | >5s |
| Skills | <2s | <3s | 3-7s | >7s |
| Rate Limit | <2s | <3s | 3-7s | >7s |

### Success Rate Targets

| Deployment Phase | Target | Action if Below |
|------------------|--------|-----------------|
| Initial setup | 60%+ | Complete configuration |
| Testing (Week 1) | 80%+ | Troubleshoot failures |
| Production | 90%+ | Investigate degradation |
| Stable operation | 95%+ | Minor issues only |

---

## Security Considerations

### Token Protection

⚠️ **Never commit tokens to git**

```bash
# Add to .gitignore
echo "*.token" >> .gitignore
echo ".env" >> .gitignore
```

### Secure Token Storage

```bash
# Store token securely
echo "export OPENCLAW_TOKEN='your_token'" >> ~/.bash_profile_private
chmod 600 ~/.bash_profile_private

# Source it
source ~/.bash_profile_private
```

### Rotate Tokens Regularly

```bash
# Generate new token monthly
ssh root@VPS_IP 'openssl rand -hex 32'

# Update environment variable
# Re-run tests to verify
```

---

## Support & Resources

### Official Documentation
- **OpenClaw Docs**: https://docs.openclaw.com
- **ClawHub**: https://clawhub.ai
- **Deployment Guide**: `/docs/deployment/OPENCLAW_DEPLOYMENT_GUIDE.md`

### Project Documentation
- **Master Checklist**: `/docs/MASTER_DEPLOYMENT_CHECKLIST.md`
- **Quick Reference**: `/docs/deployment/OPENCLAW_QUICK_REFERENCE.md`
- **Cost Analysis**: `/docs/deployment/OPENCLAW_COST_ANALYSIS.md`

### Getting Help

**Issues with this script:**
1. Check logs in `/logs/` directory
2. Review troubleshooting section above
3. Consult OpenClaw documentation
4. Check VPS system logs

**OpenClaw Issues:**
```bash
# View detailed logs
ssh root@VPS_IP 'journalctl -u openclaw -n 200'

# Check Docker containers
ssh root@VPS_IP 'docker ps -a'

# Check gateway health
ssh root@VPS_IP 'openclaw gateway health --url ws://127.0.0.1:18789'
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Feb 9, 2026 | Initial release with 10 comprehensive tests |

---

## License

This testing script is part of the LiNKbot project and follows the same license as the parent repository.

---

**Document Version**: 1.0  
**Last Updated**: February 9, 2026  
**Status**: Production Ready ✅

For deployment questions, consult the main deployment guide at `/docs/MASTER_DEPLOYMENT_CHECKLIST.md`.
