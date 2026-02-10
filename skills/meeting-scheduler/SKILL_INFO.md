# Meeting Scheduler Skill Info

## Quick Reference

- **Name**: meeting-scheduler
- **Version**: 1.0.0
- **License**: MIT
- **Source**: Google Calendar API + Community
- **Last Updated**: 2026-02-09

## Status

- ⚠️ **NOT SCANNED** - Must scan with Cisco Skill Scanner before use
- ✅ Documented
- ⚠️ Not tested
- ⚠️ Not deployed

## Sub-Agent Execution

**✅ SUPPORTED**

This skill supports multi-agent execution patterns:
- Availability Agent
- Preference Agent
- Optimization Agent
- Invitation Agent
- Conflict Resolution Agent

## Environment Variables

```bash
export GOOGLE_CALENDAR_CREDENTIALS=~/.openclaw/credentials/google-calendar.json  # Required
export DEFAULT_TIMEZONE=America/New_York                                         # Optional
export CALENDAR_ID=primary                                                        # Optional
```

## Quick Install

```bash
# Install dependencies
pip install google-auth google-auth-oauthlib google-auth-httplib2
pip install google-api-python-client pytz python-dateutil icalendar

# Create directories
mkdir -p ~/.openclaw/credentials
mkdir -p ~/.openclaw/data/calendar

# Set up Google Calendar OAuth
# Follow: /Users/linktrend/Projects/LiNKbot/docs/guides/GOOGLE_WORKSPACE_SETUP.md
```

## OpenClaw Model

```json
{
  "meeting-scheduler": "claude-3-5-haiku-20241022",
  "meeting-scheduler:conflict-resolution": "claude-3-5-sonnet-20241022"
}
```

## Cost Estimate

~$0.22/month for 100 operations

## Features

- Find available time slots
- Schedule meetings with invitations
- Recurring meetings
- Timezone conversions
- Conflict resolution
- Google Calendar integration
- Virtual meeting links

## Files

- `SKILL.md` - Complete documentation
- `SKILL_INFO.md` - This quick reference

## Security Notes

- OAuth credentials stored in `~/.openclaw/credentials/`
- Use service accounts for automation
- Limited calendar access permissions
- No hardcoded secrets

## Next Steps

1. ⚠️ Scan with Cisco Skill Scanner
2. Set up Google Calendar API (OAuth)
3. Install dependencies
4. Test availability checking
5. Test meeting creation
6. Deploy to VPS
