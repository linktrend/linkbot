# Google Docs MCP Server - Skill Information

## Source
- **Repository**: https://github.com/a-bonus/google-docs-mcp
- **Author**: a-bonus
- **Stars**: 291+ (as of Feb 2026)
- **License**: ISC

## Version Information
- **Version**: 1.0.0
- **Downloaded**: February 9, 2026
- **Last Updated**: Active repository with recent commits

## Description
Ultimate Google Docs, Sheets & Drive MCP Server that provides comprehensive access to Google Docs, Google Sheets, and Google Drive. Enables AI assistants like Claude to read, write, format, and manage documents, spreadsheets, and files programmatically.

## Key Features

### Document Access & Editing
- Read documents (plain text, JSON, or markdown)
- Append and insert text at specific positions
- Delete content from documents
- Multi-tab document support

### Markdown Support
- Write using markdown syntax
- Bidirectional markdown conversion
- Supports headings, bold, italic, strikethrough, links, lists

### Formatting & Styling
- Rich text formatting (bold, italic, colors)
- Paragraph formatting (alignment, spacing)
- Format by text content

### Document Structure
- Create and manage tables
- Insert page breaks
- Insert images from URLs or local files

### Comment Management
- List, add, reply to, resolve, and delete comments
- Get comment details with author and date info

### Google Sheets Support
- Read/write data using A1 notation
- Append rows and clear ranges
- Get spreadsheet metadata
- Create spreadsheets and add sheets
- List and search spreadsheets

### Google Drive Integration
- Document discovery and search
- Folder management (create, list, get info)
- File operations (move, copy, rename, delete)
- Document creation from templates

## Requirements

### Dependencies
- Node.js 18+ or higher
- npm
- fastmcp: ^3.24.0
- google-auth-library: ^9.15.1
- googleapis: ^148.0.0
- markdown-it: ^14.1.0
- zod: ^3.24.2

### Google Cloud Setup
1. Google Cloud Project with enabled APIs:
   - Google Docs API
   - Google Sheets API
   - Google Drive API
2. OAuth 2.0 credentials (Desktop app)
3. OAuth consent screen configured with required scopes:
   - `https://www.googleapis.com/auth/documents`
   - `https://www.googleapis.com/auth/spreadsheets`
   - `https://www.googleapis.com/auth/drive.file`

### Authentication Methods
- **OAuth 2.0** (Primary): Interactive browser-based authentication
- **Service Account with Domain-Wide Delegation**: Enterprise/Google Workspace option

### Environment Variables
- `TOKEN_PATH`: Path to OAuth token file (default: `token.json`)
- `CREDENTIALS_PATH`: Path to OAuth credentials JSON (default: `credentials.json`)
- `SERVICE_ACCOUNT_PATH`: Path to service account key (for enterprise)
- `GOOGLE_IMPERSONATE_USER`: Email to impersonate (for service accounts)

## Installation

```bash
cd /Users/linktrend/Projects/LiNKbot/skills/google-docs
npm install
npm run build
```

## Usage

### First-time Setup
1. Place `credentials.json` in the skill directory
2. Run `node ./dist/server.js` to authorize (creates `token.json`)
3. Follow OAuth flow in browser

### MCP Configuration
Add to MCP settings (e.g., Claude Desktop config):

```json
{
  "mcpServers": {
    "google-docs-mcp": {
      "command": "node",
      "args": ["/Users/linktrend/Projects/LiNKbot/skills/google-docs/dist/server.js"],
      "env": {}
    }
  }
}
```

## Available Tools
- `readGoogleDoc` - Read document content
- `appendToGoogleDoc` - Append text
- `insertText` - Insert at position
- `deleteRange` - Remove content
- `listDocumentTabs` - List tabs in document
- `applyTextStyle` - Apply rich formatting
- `applyParagraphStyle` - Format paragraphs
- `insertTable` - Create tables
- `insertPageBreak` - Add page breaks
- `insertImageFromUrl` - Insert image from URL
- `insertLocalImage` - Upload and insert local image
- `listComments` - View all comments
- `addComment` - Create new comment
- `replyToComment` - Reply to comment
- `resolveComment` - Mark comment resolved
- `deleteComment` - Remove comment
- `readSpreadsheet` - Read sheet data
- `writeSpreadsheet` - Write to cells
- `appendSpreadsheetRows` - Add rows
- `clearSpreadsheetRange` - Clear cells
- `createSpreadsheet` - Create new spreadsheet
- `listGoogleDocs` - Find documents
- `createDocument` - Create new doc
- `createFolder` - Create Drive folder
- `moveFile` - Move files
- And more...

## Per-Skill Model Configuration
**Status**: Not Supported

This MCP server does not have built-in per-skill model configuration. It acts as a tool provider for MCP clients (like Claude Desktop), and the AI model selection is handled at the client level, not within the skill itself.

## Known Limitations
1. Programmatically created comments appear in "All Comments" but are not visibly anchored to text
2. Comment resolution status may not persist via API
3. Limited support for documents converted from other formats (e.g., Word)

## Security Notes
- Keep `credentials.json` and `token.json` secure (never commit to git)
- Both files are included in `.gitignore`
- Treat tokens like passwords
- For production, consider using system keychains or secret management services

## Testing
- Comprehensive testing completed for multi-tab support
- All tab-related features validated with real documents
- Tab isolation and backward compatibility confirmed

## Documentation
- Full README: `/Users/linktrend/Projects/LiNKbot/skills/google-docs/README.md`
- Sample tasks: `/Users/linktrend/Projects/LiNKbot/skills/google-docs/SAMPLE_TASKS.md`
- VS Code integration: `/Users/linktrend/Projects/LiNKbot/skills/google-docs/vscode.md`
