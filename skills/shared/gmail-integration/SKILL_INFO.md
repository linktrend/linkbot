# Gmail MCP Server - Skill Information

## Source Information
- **Source URL**: https://github.com/bastienchabal/gmail-mcp
- **Author**: Bastien Chabal (@bastienchabal)
- **License**: MIT
- **Repository Type**: Official MCP Server (Third-party)
- **Installation Method**: Git Clone

## Version Information
- **Commit Hash**: 31a59a2e9ac651d23ffd63ba86e4dd7cb56c85c4
- **Commit Date**: 2025-03-17 16:11:24 +0100
- **Last Commit**: Merge pull request #1 from bastienchabal/smithery/config-hla7
- **Date Downloaded**: 2026-02-09

## Description
A Model Context Protocol (MCP) server for Gmail & Google Calendar integration with Claude Desktop, enabling intelligent, context-aware interactions with your email. This server provides deep email analysis with full conversation thread context, intelligent action suggestions, and optional Google Calendar integration.

## Key Features
- **Deep Email Analysis**: Provides comprehensive context from entire conversation threads
- **Context-Aware Responses**: Generates responses considering full communication history
- **Intelligent Action Suggestions**: Analyzes email content for calendar events, tasks, and follow-ups
- **Calendar Integration**: Optional Calendar API integration to detect events in emails and create calendar entries
- **Advanced Search**: Searches across entire email history with semantic understanding
- **Personalization**: Adapts to communication style with specific contacts

## Technology Stack
- **Language**: Python 3.10+
- **Framework**: Model Context Protocol (MCP) SDK
- **APIs**: Gmail API, Google Calendar API (optional)

## Required API Keys and Credentials

### Google Cloud Platform Setup
1. **Gmail API**: Must be enabled
2. **Calendar API**: Optional, can be enabled for calendar features
3. **OAuth 2.0 Credentials**: Desktop app type required
   - Client ID
   - Client Secret

### Environment Variables
Required in Claude Desktop config:
- `GOOGLE_CLIENT_ID`: OAuth 2.0 client ID
- `GOOGLE_CLIENT_SECRET`: OAuth 2.0 client secret
- `TOKEN_ENCRYPTION_KEY`: Random encryption key for token storage (optional but recommended)
- `PYTHONPATH`: Path to gmail-mcp directory
- `CONFIG_FILE_PATH`: Path to config.yaml file

## Configuration Options

### Server Configuration (config.yaml)
- **Server Host**: localhost
- **Server Port**: 8000 (for OAuth callbacks)
- **Debug Mode**: Configurable
- **Log Level**: INFO (default)

### Gmail Configuration
- **Scopes**: 
  - gmail.readonly
  - gmail.send
  - gmail.labels
  - gmail.modify

### Calendar Configuration
- **Enabled**: true/false (toggle Calendar API integration)
- **Scopes**:
  - calendar.readonly
  - calendar.events

### Token Storage
- **Default Path**: ~/gmail_mcp_tokens/tokens.json
- **Encryption**: Optional encryption key for secure token storage

## Dependencies
Core dependencies from pyproject.toml:
- mcp>=1.3.0
- typer>=0.9.0
- pytz>=2023.3
- uvicorn>=0.23.2
- pydantic>=2.4.2
- httpx>=0.25.0
- google-auth>=2.23.3
- google-auth-oauthlib>=1.1.0
- google-api-python-client>=2.105.0
- cryptography>=41.0.4
- python-jose>=3.3.0
- python-dateutil>=2.8.2
- pyyaml>=6.0.1

## Installation Steps

### 1. Prerequisites
```bash
# Python 3.10 or higher required
python --version

# Install uv package manager
pip install uv
```

### 2. Setup Virtual Environment
```bash
cd /Users/linktrend/Projects/LiNKbot/skills/gmail-integration
uv venv
source .venv/bin/activate  # On macOS/Linux
```

### 3. Install Dependencies
```bash
uv pip install -e .
```

### 4. Configure Claude Desktop
Edit `~/Library/Application Support/Claude/claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "gmail-mcp": {
      "command": "/Users/linktrend/Projects/LiNKbot/skills/gmail-integration/.venv/bin/mcp",
      "args": [
        "run",
        "/Users/linktrend/Projects/LiNKbot/skills/gmail-integration/gmail_mcp/main.py:mcp"
      ],
      "cwd": "/Users/linktrend/Projects/LiNKbot/skills/gmail-integration",
      "env": {
        "PYTHONPATH": "/Users/linktrend/Projects/LiNKbot/skills/gmail-integration",
        "CONFIG_FILE_PATH": "/Users/linktrend/Projects/LiNKbot/skills/gmail-integration/config.yaml",
        "GOOGLE_CLIENT_ID": "<your-client-id>",
        "GOOGLE_CLIENT_SECRET": "<your-client-secret>",
        "TOKEN_ENCRYPTION_KEY": "<generate-a-random-key>"
      }
    }
  }
}
```

### 5. First Run Authentication
1. Start Claude Desktop
2. The server will prompt for authentication on first use
3. Complete OAuth flow in browser
4. tokens.json file will be created automatically

## Available Tools
- Email overview and inbox management
- Advanced email search with Gmail syntax
- Detailed email analysis with thread context
- Context-aware email reply preparation
- Email sending and drafting
- Label management (CRUD operations)
- Calendar event creation (when Calendar API enabled)
- Calendar event detection from emails
- Smart scheduling suggestions

## Security Notes
- OAuth tokens are stored securely with optional encryption
- Credentials never leave local machine
- All operations require explicit user consent
- Token storage path is configurable
- Encryption key should be stored securely in Claude Desktop config

## Known Issues / Limitations
- Currently in Beta status (WIP)
- Calendar API integration is optional and must be explicitly enabled
- Requires re-authentication when adding Calendar API scopes
- OAuth tokens in test mode expire after 7 days (publish to production to avoid)

## Additional Resources
- [Smithery Package](https://smithery.ai/server/@bastienchabal/gmail-mcp)
- [Issue Tracker](https://github.com/bastienchabal/gmail-mcp/issues)
- Debug scripts available in `/debug` directory

## Compatibility
- **MCP Protocol Version**: 1.3.0+
- **Tested with**: Claude Desktop
- **Operating Systems**: macOS, Linux, Windows
- **Python Version**: 3.10, 3.11

## Notes for LiNKbot Integration
- This is a comprehensive Gmail solution with optional Calendar integration
- Excellent for context-aware email management
- Consider enabling Calendar API for meeting detection and scheduling
- Token encryption is recommended for production use
- May want to adjust scopes based on required permissions
- Can be used alongside dedicated calendar-integration skill or as primary email/calendar solution
