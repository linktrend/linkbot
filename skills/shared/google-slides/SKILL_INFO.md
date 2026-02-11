# Google Slides MCP Server - Skill Information

## Source
- **Repository**: https://github.com/matteoantoci/google-slides-mcp
- **Author**: matteoantoci
- **Stars**: 148+ (as of Feb 2026)
- **License**: ISC

## Version Information
- **Version**: 0.1.0
- **Downloaded**: February 9, 2026
- **Last Updated**: Active repository with recent commits

## Description
MCP Server for Google Slides integration that provides tools for creating, reading, and modifying Google Slides presentations programmatically via the Model Context Protocol.

## Key Features

### Presentation Management
- Create new presentations with custom titles
- Retrieve presentation details and metadata
- Get specific page/slide information
- Batch update presentations with multiple operations

### Content Extraction
- Summarize presentation content
- Extract all text from slides
- Include/exclude speaker notes in summaries
- Get slide count and last modified information

### Slide Manipulation
- Add text to slides
- Insert shapes and images
- Create new slides
- Apply formatting and styling
- Multiple operations in single batch request

### Integration
- OAuth 2.0 authentication with Google
- Compatible with Claude Desktop and other MCP clients
- Standard MCP protocol implementation

## Requirements

### System Requirements
- Node.js v18+ or later
- npm

### Dependencies
- @modelcontextprotocol/sdk: ^1.9.0
- googleapis: ^148.0.0
- open: ^10.1.1
- server-destroy: ^1.0.1
- zod: ^3.24.3

### Google Cloud Setup
1. Google Cloud Project with enabled APIs:
   - Google Slides API
2. OAuth 2.0 Client Credentials (Desktop app type)
3. OAuth consent screen configured with scopes:
   - `https://www.googleapis.com/auth/presentations` (required)
   - Optional: `https://www.googleapis.com/auth/drive.readonly` (for listing files)

### Environment Variables
- `GOOGLE_CLIENT_ID`: OAuth 2.0 Client ID (required)
- `GOOGLE_CLIENT_SECRET`: OAuth 2.0 Client Secret (required)
- `GOOGLE_REFRESH_TOKEN`: OAuth refresh token (required)

## Installation

```bash
cd /Users/linktrend/Projects/LiNKbot/skills/google-slides
npm install
npm run build
```

## OAuth Token Setup

### Option 1: Use Google OAuth 2.0 Playground
1. Go to https://developers.google.com/oauthplayground/
2. Click gear icon → Check "Use your own OAuth credentials"
3. Enter your Client ID and Client Secret
4. Select scope: `https://www.googleapis.com/auth/presentations`
5. Authorize APIs → Sign in with Google account
6. Copy the Refresh token from Step 2

### Option 2: Use Built-in Script
```bash
npm run get-token
```

Follow the prompts to authorize and obtain refresh token.

## Usage

### MCP Configuration
Add to MCP settings (e.g., Claude Desktop config):

```json
{
  "mcpServers": {
    "google-slides-mcp": {
      "transportType": "stdio",
      "command": "node",
      "args": ["/Users/linktrend/Projects/LiNKbot/skills/google-slides/build/index.js"],
      "env": {
        "GOOGLE_CLIENT_ID": "your_client_id",
        "GOOGLE_CLIENT_SECRET": "your_client_secret",
        "GOOGLE_REFRESH_TOKEN": "your_refresh_token"
      }
    }
  }
}
```

### Running Standalone
```bash
npm run start
```

The server will listen on stdio for MCP requests.

## Available Tools

### create_presentation
Creates a new Google Slides presentation.

**Input:**
- `title` (string, required): Title for the new presentation

**Output:** JSON object with presentation details (ID, title, etc.)

### get_presentation
Retrieves details about an existing presentation.

**Input:**
- `presentationId` (string, required): ID of the presentation
- `fields` (string, optional): Field mask to limit returned data (e.g., "slides,pageSize")

**Output:** JSON object with presentation details

### batch_update_presentation
Applies multiple updates to a presentation in a single request.

**Input:**
- `presentationId` (string, required): ID of the presentation
- `requests` (array, required): Array of update request objects
- `writeControl` (object, optional): Write request execution controls

**Output:** JSON object with batch update results

Refer to [Google Slides API batchUpdate documentation](https://developers.google.com/slides/api/reference/rest/v1/presentations/batchUpdate#requestbody) for request object structure.

### get_page
Retrieves details about a specific slide/page.

**Input:**
- `presentationId` (string, required): ID of the presentation
- `pageObjectId` (string, required): Object ID of the page/slide

**Output:** JSON object with page details

### summarize_presentation
Extracts and formats all text content from a presentation.

**Input:**
- `presentationId` (string, required): ID of the presentation
- `include_notes` (boolean, optional): Include speaker notes (default: false)

**Output:**
```json
{
  "title": "Presentation Title",
  "slideCount": 10,
  "lastModified": "revision info",
  "slides": [
    {
      "slideNumber": 1,
      "slideId": "slide_id",
      "content": "All text from slide",
      "notes": "Speaker notes (if requested)"
    }
  ]
}
```

## Per-Skill Model Configuration
**Status**: Not Supported

This MCP server does not have built-in per-skill model configuration. It acts as a tool provider for MCP clients, and AI model selection is handled at the client level.

## Known Limitations
- Requires manual OAuth token generation process
- Token refresh is handled automatically by the googleapis library
- No built-in service account support (OAuth only)

## Security Notes
- Never commit `GOOGLE_CLIENT_SECRET` or `GOOGLE_REFRESH_TOKEN` to git
- Store credentials securely (environment variables, secret management)
- Refresh tokens have long expiration but can be revoked
- OAuth consent screen should list all required scopes

## Example Use Cases
- Create presentation decks from AI-generated content
- Extract presentation content for summarization
- Automate slide creation for reports
- Batch update multiple slides with formatted content
- Generate presentations from templates

## Documentation
- Full README: `/Users/linktrend/Projects/LiNKbot/skills/google-slides/README.md`
- Google Slides API Reference: https://developers.google.com/slides/api/reference/rest
