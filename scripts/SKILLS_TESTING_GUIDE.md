# End-to-End Skills Testing Guide

**Version**: 1.0  
**Date**: February 9, 2026  
**Script**: `test-all-skills.sh`

---

## Overview

The `test-all-skills.sh` script provides comprehensive end-to-end testing of all installed skills through the OpenClaw gateway. It validates functionality, measures performance, tracks costs, and generates detailed reports.

---

## Quick Start

### Basic Usage

```bash
cd /Users/linktrend/Projects/LiNKbot/scripts

# Local testing (OpenClaw running locally)
./test-all-skills.sh

# Remote VPS testing
./test-all-skills.sh --vps 143.198.123.45 --token your_token_here

# Using environment variables
export VPS_IP=143.198.123.45
export AUTH_TOKEN=your_token_here
./test-all-skills.sh
```

---

## Test Coverage

The script tests **9 major skill categories** with **27+ individual tests**:

### 1. Gmail Integration (4 tests)
- ✅ Send test email with timestamp
- ✅ Read inbox (latest 5 messages)
- ✅ Search for specific email by subject
- ⊘ Archive email (skipped to preserve data)

**Model Used**: Gemini 2.5 Flash (FREE)  
**Estimated Cost**: $0.00

### 2. Google Calendar (4 tests)
- ✅ Create event (tomorrow, 2pm, 30 minutes)
- ✅ List upcoming events (next 7 days)
- ✅ Update event description
- ✅ Delete test event

**Model Used**: Gemini 2.5 Flash (FREE)  
**Estimated Cost**: $0.00

### 3. Google Docs (2 tests)
- ✅ Create document with title and markdown content
- ✅ Verify document exists in Google Drive

**Model Used**: Gemini 2.5 Flash (FREE)  
**Estimated Cost**: $0.00

### 4. Google Sheets (2 tests)
- ✅ Create spreadsheet with sample data (headers + 2 rows)
- ✅ Verify spreadsheet exists in Google Drive

**Model Used**: Gemini 2.5 Flash (FREE)  
**Estimated Cost**: $0.00

### 5. Google Slides (2 tests)
- ✅ Create presentation with 3 slides
- ✅ Verify presentation exists in Google Drive

**Model Used**: Gemini 2.5 Flash (FREE)  
**Estimated Cost**: $0.00

### 6. Web Research (2 tests)
- ✅ Search for "AI agents 2026"
- ✅ Return top 3 results with titles and URLs

**Model Used**: Kimi K2.5 via OpenRouter  
**Estimated Cost**: $0.001-0.003

### 7. Task Management (3 tests)
- ✅ Create task with high priority and tag
- ✅ List all current tasks
- ✅ Mark task as complete

**Model Used**: Kimi K2.5 via OpenRouter  
**Estimated Cost**: $0.001-0.002

### 8. Financial Calculations (2 tests)
- ✅ Calculate ROI ($10k → $15k over 2 years)
- ✅ Verify calculation accuracy (should be ~50% total, ~22.5% annualized)

**Model Used**: Kimi K2.5 via OpenRouter  
**Estimated Cost**: $0.001

### 9. Python Coding (2 tests)
- ✅ Generate CSV parser script at ~/Projects/
- ✅ Verify file was created and is readable

**Model Used**: Devstral 2 (FREE) or Antigravity (FREE)  
**Estimated Cost**: $0.00

---

## Output & Results

### Real-Time Console Output

The script provides color-coded feedback:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Testing: Gmail Integration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ▸ Sending test email...
  ✓ Email sent successfully
  ▸ Reading inbox (latest 5 messages)...
  ✓ Inbox read successfully
  ▸ Searching for test email...
  ✓ Email search successful
  ⊘ Archive email test (skipped to preserve inbox)
```

**Color Legend**:
- 🟣 **Magenta**: Skill category header
- 🔵 **Blue (▸)**: Test in progress
- 🟢 **Green (✓)**: Test passed
- 🔴 **Red (✗)**: Test failed
- 🟡 **Yellow (⊘)**: Test skipped
- 🔵 **Cyan (ℹ)**: Information

### Log File

All results are saved to:
```
/Users/linktrend/Projects/LiNKbot/logs/skills-test-<timestamp>.log
```

Example: `skills-test-20260209-143052.log`

### Summary Report

At completion, generates comprehensive report:

```
╔════════════════════════════════════════════════════════════════╗
║  Test Results Summary                                          ║
╚════════════════════════════════════════════════════════════════╝

Overall Statistics:
  Tests Run:          9
  Passed:             7
  Failed:             0
  Skipped:            2
  Total Duration:     245s

Skills Tested:
  ✓ Gmail
      Time: 25.3s | Tokens: 1200/450 | Cost: $0.001548
  ✓ Calendar
      Time: 32.1s | Tokens: 1500/600 | Cost: $0.002025
  ✓ Google Docs
      Time: 28.7s | Tokens: 0/0 | Cost: $0.000000
  ✓ Google Sheets
      Time: 26.4s | Tokens: 0/0 | Cost: $0.000000
  ✓ Google Slides
      Time: 29.8s | Tokens: 0/0 | Cost: $0.000000
  ✓ Web Research
      Time: 18.2s | Tokens: 800/300 | Cost: $0.001035
  ✓ Task Management
      Time: 22.5s | Tokens: 900/400 | Cost: $0.001305
  ✓ Financial Calculator
      Time: 15.3s | Tokens: 600/250 | Cost: $0.000833
  ✓ Python Coding
      Time: 35.2s | Tokens: 0/0 | Cost: $0.000000

Summary:
  Skills Passed:      9/9
  Skills Failed:      0/9

Cost Analysis:
  Input Tokens:       5000
  Output Tokens:      2000
  Total Cost:         $0.006746
  Note: Most operations use optimized models (Kimi K2.5)

Performance Metrics:
  Avg Time/Skill:     27.2s
  Total Execution:    245s

╔════════════════════════════════════════════════════════════════╗
║  Recommendations                                               ║
╚════════════════════════════════════════════════════════════════╝

✓ ALL SKILLS OPERATIONAL

All skills are functioning correctly through the OpenClaw gateway!

Next steps:
  1. Review detailed logs: logs/skills-test-20260209-143052.log
  2. Monitor costs via OpenClaw dashboard
  3. Configure skills for production use
  4. Set up monitoring and alerts
```

---

## Prerequisites

### Required Tools

- `curl` - HTTP requests
- `jq` - JSON parsing
- `bc` - Mathematical calculations
- `date` - Date/time operations
- `timeout` or `gtimeout` - Command timeouts

### Installation

**macOS**:
```bash
brew install coreutils jq
```

**Ubuntu/Debian**:
```bash
sudo apt update
sudo apt install curl jq bc coreutils
```

### OpenClaw Setup

1. **OpenClaw installed and running**
   ```bash
   # Check status
   systemctl status openclaw
   
   # Or locally
   ps aux | grep openclaw
   ```

2. **Skills installed and configured**
   - Gmail integration configured
   - Google Calendar API enabled
   - Google Docs/Sheets/Slides MCP server running
   - Brave Search API key configured
   - Task management database initialized
   - Python coding environment set up

3. **Authentication token** (for remote testing)
   ```bash
   # Get token from OpenClaw dashboard
   ssh root@VPS_IP 'openclaw dashboard'
   ```

---

## Cost Analysis

### Expected Costs Per Test Run

| Skill | Model | Input Tokens | Output Tokens | Cost |
|-------|-------|--------------|---------------|------|
| Gmail | Gemini Flash (FREE) | 0 | 0 | $0.00 |
| Calendar | Gemini Flash (FREE) | 0 | 0 | $0.00 |
| Google Docs | Gemini Flash (FREE) | 0 | 0 | $0.00 |
| Google Sheets | Gemini Flash (FREE) | 0 | 0 | $0.00 |
| Google Slides | Gemini Flash (FREE) | 0 | 0 | $0.00 |
| Web Research | Kimi K2.5 | ~800 | ~300 | $0.001 |
| Task Management | Kimi K2.5 | ~900 | ~400 | $0.001 |
| Financial Calc | Kimi K2.5 | ~600 | ~250 | $0.001 |
| Python Coding | Devstral (FREE) | 0 | 0 | $0.00 |
| **TOTAL** | **Mixed** | **~2,300** | **~950** | **~$0.003** |

**Total per test run**: ~$0.003 (less than 1 cent)

### Cost Breakdown by Category

- **Google Workspace (60%)**: FREE (Gemini Flash Lite)
- **AI Tasks (30%)**: ~$0.003 (Kimi K2.5)
- **Coding (10%)**: FREE (Devstral/Antigravity)

### Monthly Testing Costs

| Testing Frequency | Runs/Month | Monthly Cost |
|-------------------|------------|--------------|
| Initial testing (daily) | 30 | $0.09 |
| Regular testing (weekly) | 4 | $0.01 |
| Monthly verification | 1 | $0.003 |

**Recommendation**: Daily testing during initial setup, then weekly once stable.

---

## Interpreting Results

### All Skills Passed ✅

**Status**: System fully operational

**Next steps**:
1. Review detailed logs for any warnings
2. Set up production monitoring
3. Configure alerts for skill failures
4. Document any edge cases discovered
5. Schedule regular testing (weekly)

### Some Skills Failed ❌

**Status**: Issues detected, troubleshooting required

**Common failure scenarios**:

#### Gmail Failures
- **OAuth token expired**: Re-authenticate via setup-oauth.sh
- **API quota exceeded**: Check Google Cloud Console quotas
- **Scopes insufficient**: Ensure gmail.modify scope is granted

```bash
# Fix Gmail auth issues
cd scripts/google-workspace
./setup-oauth.sh
```

#### Calendar Failures
- **Time zone issues**: Verify DEFAULT_TIMEZONE environment variable
- **Calendar ID incorrect**: Check CALENDAR_ID setting
- **Permissions**: Ensure calendar write access

```bash
# Verify calendar setup
cd scripts/google-workspace
./verify-setup.sh
```

#### Google Docs/Sheets/Slides Failures
- **MCP server not running**: Check MCP server status
- **Service account issues**: Verify credentials.json
- **API not enabled**: Enable APIs in Google Cloud Console

```bash
# Check MCP server
ps aux | grep mcp_google
```

#### Web Research Failures
- **Brave API key invalid**: Check BRAVE_API_KEY environment variable
- **Rate limits**: Brave Search has monthly quotas
- **Network issues**: Verify internet connectivity

```bash
# Test Brave API directly
curl -H "X-Subscription-Token: YOUR_BRAVE_API_KEY" \
  "https://api.search.brave.com/res/v1/web/search?q=test"
```

#### Task Management Failures
- **Database not initialized**: Create ~/.openclaw/data/tasks.json
- **Write permissions**: Check file permissions

```bash
# Initialize task database
mkdir -p ~/.openclaw/data
echo '{"tasks": []}' > ~/.openclaw/data/tasks.json
```

#### Financial Calculator Failures
- **Calculation logic**: Verify financial formulas
- **Number formatting**: Check locale settings

#### Python Coding Failures
- **PROJECT_DIRECTORY not set**: Export PROJECT_DIRECTORY
- **File permissions**: Ensure write access to ~/Projects/
- **MCP server**: Verify filesystem MCP server is running

```bash
# Fix Python coding environment
export PROJECT_DIRECTORY=~/Projects
mkdir -p ~/Projects
```

### Tests Skipped ⊘

**Status**: Some tests were skipped (expected behavior)

**Skipped tests**:
- Archive email (intentional - preserves user data)
- Update event (if event creation failed)
- File verification (if coding test failed)

Skipped tests are **not failures** - they're either:
1. Intentionally skipped to preserve data
2. Dependent on previous test success
3. Optional functionality

---

## Advanced Usage

### Selective Testing

To test only specific skills, comment out unwanted tests in the script:

```bash
# Edit script
nano test-all-skills.sh

# Comment out unwanted tests in run_all_tests()
# test_gmail_skill          # Skip Gmail
# test_calendar_skill       # Skip Calendar
test_google_docs_skill      # Test only Docs
test_google_sheets_skill    # Test only Sheets
```

### Custom Timeouts

Increase timeouts for slow connections:

```bash
# Edit script and modify timeout values
# Default: call_openclaw "skill" "$prompt" 30
# Change to: call_openclaw "skill" "$prompt" 60
```

### Parallel Testing

⚠️ **Not recommended** - skills may have dependencies or shared resources

### Verbose Logging

All API responses are already logged to the log file. To see more detail:

```bash
# After running test
cat logs/skills-test-*.log | grep "→"
```

### Integration with CI/CD

```yaml
# .github/workflows/test-skills.yml
name: Skills Integration Tests

on:
  schedule:
    - cron: '0 9 * * *'  # Daily at 9 AM
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
      
      - name: Run skills tests
        env:
          VPS_IP: ${{ secrets.VPS_IP }}
          AUTH_TOKEN: ${{ secrets.OPENCLAW_TOKEN }}
        run: |
          cd scripts
          chmod +x test-all-skills.sh
          ./test-all-skills.sh
      
      - name: Upload test logs
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-logs
          path: logs/skills-test-*.log
```

---

## Troubleshooting

### Script Won't Run

**Error**: `Permission denied`
```bash
chmod +x test-all-skills.sh
```

**Error**: `Command not found: jq`
```bash
# macOS
brew install jq

# Ubuntu
sudo apt install jq
```

**Error**: `Command not found: timeout`
```bash
# macOS (uses gtimeout)
brew install coreutils

# Ubuntu
sudo apt install coreutils
```

### Gateway Not Reachable

```bash
# Check if OpenClaw is running
curl http://localhost:18789/health

# Check firewall
sudo ufw status

# Check port
netstat -tuln | grep 18789
```

### Authentication Failures

```bash
# Regenerate token
openclaw dashboard

# Or via SSH
ssh root@VPS_IP 'openclaw dashboard'

# Test token
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:18789/api/health
```

### Slow Test Execution

**Expected duration**: 4-6 minutes for all 9 skills

**If slower**:
1. Check network latency to VPS
2. Verify VPS resources (CPU, RAM)
3. Check for rate limiting
4. Review OpenClaw logs for bottlenecks

```bash
# Check VPS resources
ssh root@VPS_IP 'htop'

# Check OpenClaw logs
ssh root@VPS_IP 'journalctl -u openclaw -n 100'
```

### High Costs

**If costs exceed expectations**:

1. **Check model routing**: Ensure FREE models are used where possible
   ```bash
   # Review OpenClaw config
   cat ~/.openclaw/config.json | grep -A5 '"model"'
   ```

2. **Verify Gemini API**: Google Workspace skills should be FREE
   ```bash
   # Check API calls in Google Cloud Console
   # https://console.cloud.google.com/apis/dashboard
   ```

3. **Review token usage**: Check log file for token counts
   ```bash
   grep "Tokens:" logs/skills-test-*.log
   ```

---

## Best Practices

### Before Running Tests

1. ✅ Ensure VPS is powered on and accessible
2. ✅ Verify OpenClaw service is running
3. ✅ Confirm API keys are valid and current
4. ✅ Check API quotas aren't exhausted
5. ✅ Back up important data (if testing production)
6. ✅ Review firewall rules for port 18789

### During Testing

1. ✅ Don't interrupt the test suite mid-run
2. ✅ Monitor console output for errors
3. ✅ Check system resources if tests are slow
4. ✅ Note any warnings or unusual behavior

### After Testing

1. ✅ Review complete log file
2. ✅ Compare results with previous runs
3. ✅ Document any new issues discovered
4. ✅ Clean up test data (emails, calendar events, files)
5. ✅ Archive logs for historical reference
6. ✅ Update skill configurations if needed

### Testing Schedule

| Environment | Frequency | Purpose |
|-------------|-----------|---------|
| Development | After each change | Verify changes don't break existing functionality |
| Staging | Daily | Catch integration issues early |
| Production | Weekly | Ensure ongoing reliability |
| Pre-deployment | Always | Final verification before releases |

---

## Performance Benchmarks

### Expected Timings

| Skill | Target | Good | Warning | Critical |
|-------|--------|------|---------|----------|
| Gmail | <30s | <40s | 40-60s | >60s |
| Calendar | <35s | <45s | 45-70s | >70s |
| Google Docs | <30s | <40s | 40-60s | >60s |
| Google Sheets | <30s | <40s | 40-60s | >60s |
| Google Slides | <30s | <40s | 40-60s | >60s |
| Web Research | <20s | <30s | 30-50s | >50s |
| Task Management | <25s | <35s | 35-55s | >55s |
| Financial Calc | <20s | <25s | 25-40s | >40s |
| Python Coding | <40s | <50s | 50-80s | >80s |

**Total suite**: Should complete in 4-6 minutes

### Success Rate Targets

| Phase | Target | Action if Below |
|-------|--------|-----------------|
| Initial setup | 70%+ | Complete skill configuration |
| Testing week | 85%+ | Troubleshoot failing skills |
| Production | 95%+ | Investigate all failures |
| Stable operation | 98%+ | Minor issues only |

---

## Security Considerations

### Token Protection

⚠️ **Never commit tokens to git**

```bash
# Add to .gitignore
echo "*.token" >> .gitignore
echo ".env" >> .gitignore
echo "logs/*.log" >> .gitignore
```

### Secure Token Storage

```bash
# Store in secure location
mkdir -p ~/.secrets
echo "export AUTH_TOKEN='your_token'" > ~/.secrets/openclaw
chmod 600 ~/.secrets/openclaw

# Source in shell
echo "source ~/.secrets/openclaw" >> ~/.bashrc
```

### Log File Security

Logs may contain sensitive information:

```bash
# Restrict log file permissions
chmod 600 logs/skills-test-*.log

# Sanitize logs before sharing
sed -i 's/Bearer [a-zA-Z0-9]*/Bearer REDACTED/g' logs/skills-test-*.log
```

### Test Data Cleanup

The script creates test data:
- Emails with "LiNKbot Test" subject
- Calendar events titled "LiNKbot Skills Test"
- Documents with "LiNKbot Test" in title
- Files at ~/Projects/csv_parser_test_*.py

**Cleanup**:
```bash
# Gmail (manual - search and delete)
# Calendar (automatic - deleted by script)
# Google Drive
# - Search for "LiNKbot Test"
# - Delete test files

# Local files (automatic - deleted by script)
```

---

## Support & Resources

### Documentation

- **This Guide**: `scripts/SKILLS_TESTING_GUIDE.md`
- **Gateway Testing**: `scripts/TESTING_GUIDE.md`
- **Skills Installation**: `docs/guides/SKILLS_INSTALLATION.md`
- **Master Checklist**: `docs/MASTER_DEPLOYMENT_CHECKLIST.md`

### External Resources

- OpenClaw Docs: https://docs.openclaw.com
- ClawHub: https://clawhub.ai
- Google Workspace API: https://developers.google.com/workspace
- Brave Search API: https://brave.com/search/api/

### Getting Help

**Script issues**:
1. Check log file for detailed errors
2. Verify all dependencies installed
3. Test gateway connectivity manually
4. Review this troubleshooting guide

**Skill failures**:
1. Test skill individually via dashboard
2. Check API credentials and quotas
3. Verify environment variables
4. Review skill-specific documentation

**OpenClaw issues**:
```bash
# Check service status
systemctl status openclaw

# View logs
journalctl -u openclaw -n 200

# Test gateway health
openclaw gateway health --url ws://127.0.0.1:18789
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Feb 9, 2026 | Initial release with 9 skills, 27 tests |

---

## Future Enhancements

Planned improvements:

- [ ] TypeScript coding skill tests
- [ ] Document quality validation (verify content)
- [ ] Performance regression detection
- [ ] Automated cleanup of test data
- [ ] Slack notification integration
- [ ] Historical trend analysis
- [ ] Parallel skill testing (with safety checks)
- [ ] Custom test scenarios via config file
- [ ] Integration with monitoring systems (Datadog, New Relic)

---

**Document Version**: 1.0  
**Last Updated**: February 9, 2026  
**Maintained By**: LiNKbot Project  
**Status**: Production Ready ✅

For deployment questions, consult `/docs/MASTER_DEPLOYMENT_CHECKLIST.md`.
