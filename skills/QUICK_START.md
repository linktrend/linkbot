# Cisco Skill Scanner - Quick Start Guide

## 🚀 Quick Start (TL;DR)

```bash
# Scan a single skill
./scan-skill.sh my-skill

# Scan all skills
./batch-scan.sh

# Scan all skills (summary only)
./batch-scan.sh --summary-only
```

## 📋 Common Commands

### Individual Scan
```bash
./scan-skill.sh <skill-name>
```

### Batch Scan (All Skills)
```bash
./batch-scan.sh                    # Default: 4 concurrent scans
./batch-scan.sh -c 8              # 8 concurrent scans
./batch-scan.sh --summary-only     # Summary only
./batch-scan.sh -e "test-*"       # Exclude test skills
```

## 📊 Understanding Results

### Exit Codes
- `0` = ✓ PASS (safe to use)
- `1` = ✗ FAIL (security concerns)
- `2` = ⚠ ERROR (scan error)

### Risk Scores
- **0-60**: ✓ PASS (Low to Medium risk)
- **61-100**: ✗ FAIL (High to Critical risk)

## 📁 Where to Find Results

```bash
# Individual scan reports
ls -la scan-reports/*.json

# Approved skills
cat scan-reports/approved-skills.txt

# Rejected skills
cat scan-reports/rejected-skills.txt

# Batch summaries
ls -la scan-reports/batch-summary-*.txt
```

## 🔍 Quick Check Script Status

```bash
# Verify scanner is installed
ls -la skill-scanner/venv/bin/skill-scanner

# Check if scripts are executable
ls -la *.sh

# View recent scan results
tail scan-reports/approved-skills.txt
tail scan-reports/rejected-skills.txt
```

## 🛠 Advanced Usage

### Manual Scanner (Direct CLI)
```bash
cd skill-scanner
source venv/bin/activate
skill-scanner scan /path/to/skill --format json --detailed
```

### With LLM Analysis (More Thorough)
```bash
export ANTHROPIC_API_KEY="your-key-here"
cd skill-scanner
source venv/bin/activate
skill-scanner scan /path/to/skill --use-llm --use-behavioral
```

### Custom Output Location
```bash
cd skill-scanner
source venv/bin/activate
skill-scanner scan /path/to/skill -o /custom/path/report.json
```

## 🎯 Use Cases

### Before Deploying a New Skill
```bash
./scan-skill.sh new-skill || echo "Failed security check!"
```

### Audit All Skills
```bash
./batch-scan.sh --summary-only > audit-report.txt
```

### CI/CD Integration
```bash
# In your CI pipeline
./scan-skill.sh $SKILL_NAME
exit_code=$?
if [ $exit_code -eq 0 ]; then
    echo "✓ Security scan passed - deploying..."
else
    echo "✗ Security scan failed - blocking deployment"
    exit 1
fi
```

### Check Single Skill Fast
```bash
./scan-skill.sh my-skill 2>&1 | grep -E "PASS|FAIL|Risk Score"
```

## 🐛 Quick Troubleshooting

### "Skill directory not found"
```bash
# List available skills
ls -d */ | grep -v "skill-scanner\|scan-reports"
```

### "Virtual environment not found"
```bash
# Check if venv exists
ls -la skill-scanner/venv/bin/python
# Reinstall if needed (see README.md)
```

### "Permission denied"
```bash
chmod +x scan-skill.sh batch-scan.sh
```

### "Python 3 not found"
```bash
which python3
# Make sure Python 3.10+ is installed
```

## 📈 Interpreting Summary

```
═══════════════════════════════════════════════════════════════════
CISCO SKILL SCANNER - SCAN SUMMARY
═══════════════════════════════════════════════════════════════════

Skill Name:     example-skill
Risk Score:     35 / 100

Result:         ✓ PASS (Score ≤ 60)
Status:         Skill approved for use

Report:         scan-reports/example-skill-20260209-143022.json

═══════════════════════════════════════════════════════════════════
```

- **Risk Score < 60**: Safe to deploy
- **Risk Score > 60**: Review report before deploying
- **Risk Score > 80**: High risk - do not deploy without remediation

## 🔐 Security Best Practices

1. ✅ **Always scan before deployment**
2. ✅ **Review detailed JSON reports for failed scans**
3. ✅ **Run batch scans regularly (weekly recommended)**
4. ✅ **Keep scanner updated** (`cd skill-scanner && git pull`)
5. ✅ **Use LLM analysis for critical skills**
6. ✅ **Monitor approval/rejection logs**

## 📞 Need Help?

- Full documentation: `README.md`
- Scanner docs: `skill-scanner/README.md`
- Examples: `skill-scanner/examples/`
- Issues: https://github.com/cisco-ai-defense/skill-scanner/issues

---

**Last Updated**: 2026-02-09  
**Version**: 1.0.0
