# TypeScript/JavaScript Coding Skill Info

## Quick Reference

- **Name**: typescript-coding
- **Version**: 1.0.0
- **License**: MIT
- **Source**: GitHub MCP Server, Microsoft, VoltAgent
- **Last Updated**: 2026-02-09

## Status

- ⚠️ **NOT SCANNED** - Must scan with Cisco Skill Scanner before use
- ✅ Documented
- ⚠️ Not tested
- ⚠️ Not deployed

## Sub-Agent Execution

**✅ STRONGLY SUPPORTED**

This skill is designed for multi-agent execution:
- Frontend Agent (React)
- Backend Agent (API routes)
- Testing Agent (Jest/Vitest)
- DevOps Agent (Docker)
- Documentation Agent (TypeDoc)

## Environment Variables

```bash
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxx  # Optional
export NODE_ENV=development             # Optional
export API_BASE_URL=http://localhost:3000  # Optional
```

## Quick Install

```bash
# Install Node.js (v22+)
# Download from https://nodejs.org

# Install TypeScript and tools
npm install -g typescript ts-node tsx prettier eslint

# Install GitHub MCP Server (optional)
npm install -g @github/github-mcp-server

# Create TypeScript project
npm init mcp-ts my-project
```

## OpenClaw Model

```json
{
  "typescript-coding": "claude-3-5-haiku-20241022",
  "typescript-coding:complex": "claude-3-5-sonnet-20241022"
}
```

## Cost Estimate

~$1.60/month for 300 operations

## Features

- TypeScript/JavaScript code generation
- React and Next.js development
- MCP server creation (zero-config)
- Node.js backend development
- GitHub operations (via MCP server)
- Modern tooling integration

## Files

- `SKILL.md` - Complete documentation
- `SKILL_INFO.md` - This quick reference

## Security Notes

- Never commit secrets to git
- Use environment variables for API keys
- Validate all user inputs
- Implement CORS restrictions
- Run npm audit regularly
- No hardcoded secrets

## MCP Configuration

Add to `~/.openclaw/config.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["@github/github-mcp-server"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

## Next Steps

1. ⚠️ Scan with Cisco Skill Scanner
2. Install Node.js and TypeScript
3. Install GitHub MCP Server (optional)
4. Configure GITHUB_TOKEN (if using GitHub features)
5. Test code generation
6. Deploy to VPS
