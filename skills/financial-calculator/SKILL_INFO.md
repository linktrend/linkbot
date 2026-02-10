# Financial Calculator Skill Info

## Quick Reference

- **Name**: financial-calculator
- **Version**: 1.0.0
- **License**: MIT
- **Source**: Community Python (cashflows, numpy-financial)
- **Last Updated**: 2026-02-09

## Status

- ⚠️ **NOT SCANNED** - Must scan with Cisco Skill Scanner before use
- ✅ Documented
- ⚠️ Not tested
- ⚠️ Not deployed

## Sub-Agent Execution

**✅ SUPPORTED**

This skill supports multi-agent execution patterns:
- Data Collection Agent
- Calculation Agent
- Analysis Agent
- Reporting Agent
- Scenario Agent

## Environment Variables

```bash
export DEFAULT_CURRENCY=USD          # Optional
export DEFAULT_TAX_RATE=0.21         # Optional
export DEFAULT_DISCOUNT_RATE=0.10    # Optional
```

## Quick Install

```bash
# Install dependencies
pip install numpy pandas numpy-financial openpyxl matplotlib seaborn

# Create data directory
mkdir -p ~/.openclaw/data/financial-models
```

## OpenClaw Model

```json
{
  "financial-calculator": "claude-3-5-haiku-20241022",
  "financial-calculator:analysis": "claude-3-5-sonnet-20241022"
}
```

## Cost Estimate

~$0.52/month for 50 operations

## Features

- ROI calculations
- NPV and IRR
- Budget variance analysis
- Financial projections
- Break-even analysis
- Loan/mortgage calculations
- Scenario analysis

## Files

- `SKILL.md` - Complete documentation
- `SKILL_INFO.md` - This quick reference

## Security Notes

- All calculations performed locally
- No external API calls
- No hardcoded secrets
- Financial data should be encrypted at rest

## Next Steps

1. ⚠️ Scan with Cisco Skill Scanner
2. Install dependencies
3. Test ROI calculation
4. Test NPV/IRR functions
5. Deploy to VPS
