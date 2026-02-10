# Skills Testing Quick Start

**Script**: `test-all-skills.sh`  
**Version**: 1.0  
**Date**: February 9, 2026

---

## Run the Tests

```bash
# Navigate to scripts directory
cd /Users/linktrend/Projects/LiNKbot/scripts

# Local testing
./test-all-skills.sh

# Remote VPS testing
./test-all-skills.sh --vps 143.198.123.45 --token your_token_here

# Help
./test-all-skills.sh --help
```

---

## What Gets Tested

| # | Skill | Tests | Cost |
|---|-------|-------|------|
| 1 | Gmail | Send, Read, Search, Archive | FREE |
| 2 | Calendar | Create, List, Update, Delete | FREE |
| 3 | Google Docs | Create document, Verify | FREE |
| 4 | Google Sheets | Create spreadsheet, Verify | FREE |
| 5 | Google Slides | Create presentation, Verify | FREE |
| 6 | Web Research | Search "AI agents 2026", Top 3 | $0.001 |
| 7 | Task Management | Create, List, Complete | $0.001 |
| 8 | Financial Calc | ROI calculation, Verify | $0.001 |
| 9 | Python Coding | Generate script, Verify file | FREE |

**Total**: 27 tests across 9 skills  
**Duration**: 4-6 minutes  
**Cost**: ~$0.003 per run

---

## Output Example

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

---

## Results Summary

```
╔════════════════════════════════════════════════════════════════╗
║  Test Results Summary                                          ║
╚════════════════════════════════════════════════════════════════╝

Overall Statistics:
  Tests Run:          9
  Passed:             9
  Failed:             0
  Skipped:            0
  Total Duration:     245s

Skills Tested:
  ✓ Gmail              | 25.3s | 1200/450  | $0.001548
  ✓ Calendar           | 32.1s | 1500/600  | $0.002025
  ✓ Google Docs        | 28.7s | 0/0       | $0.000000
  ✓ Google Sheets      | 26.4s | 0/0       | $0.000000
  ✓ Google Slides      | 29.8s | 0/0       | $0.000000
  ✓ Web Research       | 18.2s | 800/300   | $0.001035
  ✓ Task Management    | 22.5s | 900/400   | $0.001305
  ✓ Financial Calc     | 15.3s | 600/250   | $0.000833
  ✓ Python Coding      | 35.2s | 0/0       | $0.000000

Summary:
  Skills Passed:      9/9
  Total Cost:         $0.006746
```

---

## Quick Troubleshooting

### Script won't run
```bash
chmod +x test-all-skills.sh
```

### Missing dependencies
```bash
# macOS
brew install coreutils jq

# Ubuntu
sudo apt install curl jq bc coreutils
```

### Gateway not reachable
```bash
# Check if OpenClaw is running
curl http://localhost:18789/health

# Check firewall
sudo ufw status
```

### Authentication failed
```bash
# Get new token
openclaw dashboard

# Or via SSH
ssh root@VPS_IP 'openclaw dashboard'
```

---

## Log File Location

```
/Users/linktrend/Projects/LiNKbot/logs/skills-test-<timestamp>.log
```

Example: `skills-test-20260209-143052.log`

---

## Next Steps After Testing

### All Passed ✅
1. Review logs for warnings
2. Set up production monitoring
3. Schedule weekly testing
4. Document any edge cases

### Some Failed ❌
1. Check log file for errors
2. Verify API credentials
3. Test failed skills individually
4. Review troubleshooting guide

---

## Common Issues

| Issue | Fix |
|-------|-----|
| Gmail fails | Re-run `./google-workspace/setup-oauth.sh` |
| Calendar fails | Check `DEFAULT_TIMEZONE` environment variable |
| Docs/Sheets fails | Verify MCP server is running |
| Web research fails | Check `BRAVE_API_KEY` is set |
| Task management fails | Initialize `~/.openclaw/data/tasks.json` |
| Coding fails | Set `PROJECT_DIRECTORY` environment variable |

---

## Documentation

**Full Guide**: `SKILLS_TESTING_GUIDE.md` (comprehensive documentation)  
**Gateway Tests**: `TESTING_GUIDE.md` (OpenClaw gateway testing)  
**Skills Guide**: `/docs/guides/SKILLS_INSTALLATION.md`

---

## Cost Breakdown

**Google Workspace (60%)**: FREE (Gemini Flash)  
**AI Tasks (30%)**: ~$0.003 (Kimi K2.5)  
**Coding (10%)**: FREE (Devstral/Antigravity)

**Monthly costs** (daily testing): ~$0.09/month

---

## Testing Schedule

| Environment | Frequency |
|-------------|-----------|
| Development | After each change |
| Staging | Daily |
| Production | Weekly |
| Pre-deployment | Always |

---

**For detailed information, see**: `SKILLS_TESTING_GUIDE.md`
