# Google Calendar MCP Server - Skill Information

## Source Information
- **Source URL**: https://github.com/nspady/google-calendar-mcp
- **Author**: Nate Spady (@nspady)
- **License**: MIT
- **Repository Type**: Official MCP Server (Third-party, highly popular)
- **GitHub Stars**: 964+ stars
- **Installation Method**: Git Clone

## Version Information
- **Package Version**: 2.4.1
- **NPM Package**: @cocal/google-calendar-mcp
- **Commit Hash**: a26140ce19b93d08dbbada70e768bd9ba8fa9463
- **Commit Date**: 2026-01-27 14:57:02 -0800
- **Last Commit**: fix: detect recurring event instances via recurringEventId (#164)
- **Date Downloaded**: 2026-02-09

## Description
A comprehensive Model Context Protocol (MCP) server that provides Google Calendar integration for AI assistants like Claude. This is a feature-rich, production-ready calendar management solution with multi-account support, advanced recurring event handling, and intelligent scheduling capabilities.

## Key Features
- **Multi-Account Support**: Connect and query multiple Google accounts simultaneously (work, personal, etc.)
- **Multi-Calendar Support**: List events from multiple calendars in a single request
- **Cross-Account Conflict Detection**: Detect overlapping events across any combination of calendars
- **Advanced Event Management**: Create, update, delete, and search calendar events
- **Recurring Events**: Advanced modification capabilities for recurring events (modify single instance or all future)
- **Free/Busy Queries**: Check availability across calendars including external calendars
- **Smart Scheduling**: Natural language understanding for dates and times
- **Intelligent Import**: Add calendar events from images, PDFs, or web links
- **Event Invitation Management**: Accept, decline, or mark as tentative for event invitations

## Technology Stack
- **Language**: TypeScript/Node.js
- **Framework**: Model Context Protocol (MCP) SDK
- **Build Tool**: esbuild
- **Testing**: Vitest
- **APIs**: Google Calendar API

## Required API Keys and Credentials

### Google Cloud Platform Setup
1. **Google Calendar API**: Must be enabled
2. **OAuth 2.0 Credentials**: Desktop app type required
   - Download JSON credentials file (gcp-oauth.keys.json)
   - Must include project_id in credentials

### OAuth Setup Steps
1. Create or select Google Cloud project
2. Enable Google Calendar API
3. Configure OAuth consent screen:
   - Select "External" user type
   - Add your email as test user
   - Add required scopes:
     - https://www.googleapis.com/auth/calendar.events
     - https://www.googleapis.com/auth/calendar
4. Create OAuth 2.0 credentials (Desktop app type)
5. Download credentials JSON file

### Environment Variables
- `GOOGLE_OAUTH_CREDENTIALS`: Path to gcp-oauth.keys.json file (REQUIRED for npx usage)
- `GOOGLE_CALENDAR_MCP_TOKEN_PATH`: Custom token storage location (optional)
- `ENABLED_TOOLS`: Comma-separated list of tools to enable (optional, for filtering)

## Configuration Options

### Installation Options
1. **npx (Recommended)**: No local installation, runs directly via npm
2. **Local Installation**: Clone and build locally for development
3. **Docker**: Containerized deployment with stdio and HTTP modes

### Authentication Modes
- **Single Account**: Default mode, authenticates one Google account
- **Multi-Account**: Manage multiple accounts with nicknames (work, personal, etc.)
- **CLI Management**: Use `npm run account auth <nickname>` for account setup
- **In-Chat Management**: Use `manage-accounts` tool within Claude

### Token Management
- **Storage**: System config directory (~/.config or equivalent)
- **Expiration**: 7 days in test mode (configurable by publishing OAuth app)
- **Re-authentication**: Automatic prompt or manual via CLI
- **Multi-account tokens**: Stored separately with nicknames

### Tool Filtering
Limit exposed tools to reduce context usage or restrict functionality:
- Via `ENABLED_TOOLS` environment variable
- Via `--enable-tools` command line flag
- Useful for security, simplicity, or token optimization

## Dependencies
Core dependencies from package.json:
- @google-cloud/local-auth: ^3.0.1
- @modelcontextprotocol/sdk: ^1.12.1
- gaxios: ^6.7.1
- google-auth-library: ^9.15.0
- googleapis: ^144.0.0
- open: ^7.4.2
- zod: ^3.22.4
- zod-to-json-schema: ^3.24.5

Dev dependencies:
- typescript: ^5.3.3
- esbuild: ^0.27.2
- vitest: ^3.1.1
- @vitest/coverage-v8: ^3.1.1

## Installation Steps

### Option 1: NPX (Recommended for LiNKbot)
```bash
# No installation needed, configure Claude Desktop directly
# Edit ~/Library/Application Support/Claude/claude_desktop_config.json
```

```json
{
  "mcpServers": {
    "google-calendar": {
      "command": "npx",
      "args": ["@cocal/google-calendar-mcp"],
      "env": {
        "GOOGLE_OAUTH_CREDENTIALS": "/path/to/your/gcp-oauth.keys.json"
      }
    }
  }
}
```

### Option 2: Local Installation (For Development)
```bash
cd /Users/linktrend/Projects/LiNKbot/skills/calendar-integration

# Install dependencies
npm install

# Build the project
npm run build

# Configure Claude Desktop with local path
```

### Option 3: Docker Deployment
```bash
cd /Users/linktrend/Projects/LiNKbot/skills/calendar-integration

# Copy credentials
cp /path/to/gcp-oauth.keys.json .

# Start with Docker Compose
docker compose up
```

## Available Tools

| Tool | Description |
|------|-------------|
| `list-calendars` | List all available calendars across all accounts |
| `list-events` | List events with date filtering and multi-calendar support |
| `get-event` | Get details of a specific event by ID |
| `search-events` | Search events by text query across calendars |
| `create-event` | Create new calendar events with natural language time support |
| `update-event` | Update existing events (single or recurring) |
| `delete-event` | Delete events (single or recurring) |
| `respond-to-event` | Respond to event invitations (Accept, Decline, Maybe, No Response) |
| `get-freebusy` | Check availability across calendars, including external calendars |
| `get-current-time` | Get current date and time in calendar's timezone |
| `list-colors` | List available event colors |
| `manage-accounts` | Add, list, or remove connected Google accounts |

## Advanced Features

### Multi-Account Operations
- **Read Operations**: Automatically merge results from all accounts
- **Write Operations**: Auto-select account with appropriate permissions
- **Account Filtering**: Specify account for targeted operations
- **Cross-Account Conflicts**: Detect scheduling conflicts across accounts

### Recurring Event Handling
- Modify single instance or all future instances
- Advanced recurrence rule (RRULE) support
- Recurring event instance detection
- Flexible response handling (accept this instance, decline all future, etc.)

### Intelligent Scheduling
- Natural language date/time parsing
- Image-based event creation (screenshots, photos)
- PDF event extraction
- Web link event detection
- Availability checking across multiple calendars

### HTTP Transport Mode (Optional)
- Remote access via HTTP instead of stdio
- Useful for Docker deployments
- Account management via web interface
- Port configuration: default 3000

## Security Notes
- OAuth tokens stored securely in system config directory
- Credentials never leave local machine
- All calendar operations require explicit user consent
- Multi-account tokens isolated and secure
- Desktop app OAuth type prevents unauthorized access

## Known Issues / Limitations
- OAuth tokens expire after 7 days in test mode (publish app to extend)
- Requires Chromium-based browser for OAuth in test mode
- Port 3000-3004 must be available for OAuth callback
- "User Rate Limit Exceeded" if credentials missing project_id
- Test users must be added to OAuth consent screen

## Troubleshooting Resources
- Extensive documentation in `/docs` directory:
  - authentication.md - OAuth setup and troubleshooting
  - advanced-usage.md - Multi-account and batch operations
  - deployment.md - HTTP transport and remote access
  - docker.md - Container deployment
  - architecture.md - Technical implementation details
  - testing.md - Unit and integration testing

## Performance Optimization
- Tool filtering to reduce context token usage
- Batch operations for multiple events
- Efficient multi-calendar queries
- Caching for repeated requests

## Additional Resources
- [NPM Package](https://www.npmjs.com/package/@cocal/google-calendar-mcp)
- [GitHub Issues](https://github.com/nspady/google-calendar-mcp/issues)
- [Sponsorship](https://github.com/sponsors/nspady)
- Comprehensive test suite in `/src/tests`
- Example configurations in `/examples`

## Compatibility
- **MCP Protocol Version**: 1.12.1+
- **Tested with**: Claude Desktop, Cursor, other MCP clients
- **Operating Systems**: macOS, Linux, Windows
- **Node.js Version**: LTS (v20+)
- **Transport Modes**: stdio (default), HTTP (optional)

## Example Use Cases
1. **Cross-Calendar Availability**: Check free time across work and personal calendars
2. **Image-Based Scheduling**: Add events from screenshots or photos
3. **Recurring Event Management**: Accept this week's standup, decline future instances
4. **Invitation Management**: Respond to meeting invites with custom notes
5. **Calendar Analysis**: Identify non-routine events, check attendance status
6. **Smart Coordination**: Match availability against provided time slots

## Notes for LiNKbot Integration
- This is a dedicated, production-ready calendar solution
- Excellent choice for primary calendar integration
- Multi-account support ideal for business/personal calendar separation
- Can be used alongside gmail-integration or as standalone calendar solution
- npx installation method simplifies deployment and updates
- Consider enabling tool filtering to optimize context usage
- HTTP transport mode useful for remote VPS deployment
- Comprehensive documentation makes troubleshooting easier
- Active maintenance (last commit Jan 2026) and strong community support
- 964+ GitHub stars indicate reliability and popularity

## Recommended Configuration for LiNKbot
- Use npx installation for easy updates
- Enable multi-account support for business partner contexts
- Configure tool filtering based on primary use cases
- Set up automatic re-authentication for production deployment
- Consider HTTP mode if deploying on VPS
- Integrate with gmail-integration for email-calendar coordination
