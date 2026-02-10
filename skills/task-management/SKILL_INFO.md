# Task Management Skill Info

## Quick Reference

- **Name**: task-management
- **Version**: 1.0.0
- **License**: MIT
- **Source**: OpenClaw Community (pndr, idea-coach, quests)
- **Last Updated**: 2026-02-09

## Status

- ⚠️ **NOT SCANNED** - Must scan with Cisco Skill Scanner before use
- ✅ Documented
- ⚠️ Not tested
- ⚠️ Not deployed

## Sub-Agent Execution

**✅ SUPPORTED**

This skill supports multi-agent execution patterns:
- Inbox Agent
- Prioritization Agent
- Scheduling Agent
- Execution Agent
- Review Agent

## Environment Variables

```bash
export TASKS_DB_PATH=~/.openclaw/data/tasks.json  # Optional
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxx            # Optional
```

## Quick Install

```bash
# Install dependencies
pip install python-dateutil pyyaml PyGithub

# Create data directory
mkdir -p ~/.openclaw/data
touch ~/.openclaw/data/tasks.json

# Initialize database
cat > ~/.openclaw/data/tasks.json << 'EOF'
{"tasks": [], "projects": [], "tags": [], "metadata": {}}
EOF
```

## OpenClaw Model

```json
{
  "task-management": "claude-3-5-haiku-20241022"
}
```

## Cost Estimate

~$0.28/month for 200 operations

## Files

- `SKILL.md` - Complete documentation
- `SKILL_INFO.md` - This quick reference

## Security Notes

- Task database stored locally
- No hardcoded secrets
- GitHub token optional (only for issues integration)

## Next Steps

1. ⚠️ Scan with Cisco Skill Scanner
2. Install dependencies
3. Configure environment variables
4. Test task creation and retrieval
5. Deploy to VPS
