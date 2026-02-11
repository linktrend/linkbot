# Python Coding Skill Info

## Quick Reference

- **Name**: python-coding
- **Version**: 1.0.0
- **License**: MIT
- **Source**: https://github.com/MarcusJellinghaus/mcp_server_filesystem
- **Last Updated**: 2026-02-09
- **Stars**: 42

## Status

- ⚠️ **NOT SCANNED** - Must scan with Cisco Skill Scanner before use
- ✅ Documented
- ⚠️ Not tested
- ⚠️ Not deployed

## Sub-Agent Execution

**✅ STRONGLY SUPPORTED**

This skill is designed for multi-agent execution:
- Code Review Agent
- Testing Agent
- Refactoring Agent
- Documentation Agent
- Data Analysis Agent

## Environment Variables

```bash
export PROJECT_DIRECTORY=/Users/linktrend/Projects  # REQUIRED - Security boundary
export LOG_LEVEL=INFO                               # Optional
export MAX_FILE_SIZE=10485760                       # Optional (10MB)
```

## Quick Install

```bash
# Clone MCP filesystem server
git clone https://github.com/MarcusJellinghaus/mcp_server_filesystem.git
cd mcp_server_filesystem

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Test server
python server.py --project-dir /tmp/test
```

## OpenClaw Model

```json
{
  "python-coding": "claude-3-5-haiku-20241022"
}
```

## Cost Estimate

~$1.60/month for 300 operations

## Features

- Secure file operations (read, write, edit, delete)
- Code generation and refactoring
- Data processing and analysis
- Script automation
- Path validation
- Atomic file writes

## Files

- `SKILL.md` - Complete documentation
- `SKILL_INFO.md` - This quick reference

## Security Notes

- **CRITICAL**: All operations contained within PROJECT_DIRECTORY
- Path validation prevents directory traversal
- Atomic file writes prevent corruption
- Structured logging tracks operations
- No hardcoded secrets

## MCP Configuration

Add to `~/.openclaw/config.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "python",
      "args": [
        "/path/to/mcp_server_filesystem/server.py",
        "--project-dir",
        "/Users/linktrend/Projects"
      ],
      "env": {
        "PROJECT_DIRECTORY": "/Users/linktrend/Projects"
      }
    }
  }
}
```

## Next Steps

1. ⚠️ Scan with Cisco Skill Scanner
2. Clone MCP server repository
3. Install dependencies
4. Configure PROJECT_DIRECTORY
5. Test file operations
6. Deploy to VPS
