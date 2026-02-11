# Google Sheets MCP Server - Skill Information

## Source
- **Repository**: https://github.com/xing5/mcp-google-sheets
- **Author**: Xing Wu (xing5)
- **Stars**: 664+ (as of Feb 2026)
- **License**: MIT

## Version Information
- **Version**: Dynamic versioning (using uv-dynamic-versioning)
- **Downloaded**: February 9, 2026
- **Last Updated**: Active repository with recent commits

## Description
Python-based MCP server that acts as a bridge between MCP-compatible clients (like Claude Desktop) and the Google Sheets API. Enables powerful automation and data manipulation workflows driven by AI.

## Key Features

### Core Spreadsheet Operations
- Read sheet data with flexible range support
- Update individual cells
- Batch update multiple cells efficiently
- List all sheets/tabs in a spreadsheet
- List accessible spreadsheets
- Create new spreadsheets
- Create new sheets/tabs

### Advanced Operations
- Add rows at specific positions
- Add columns at specific positions
- Copy sheets between spreadsheets
- Rename sheets
- Find content in spreadsheets
- Search across spreadsheets
- Get formulas from cells
- Batch operations for efficiency

### Multi-Spreadsheet Support
- Get data from multiple sheets simultaneously
- Get summaries for multiple spreadsheets
- Share spreadsheets with specific permissions

### Folder Management
- List Google Drive folders
- Organize spreadsheets by folder

### Tool Filtering (Context Optimization)
- Enable only needed tools to reduce token usage
- Default: ~13,000 tokens for all 19 tools
- Configurable via `--include-tools` or `ENABLED_TOOLS` environment variable

## Requirements

### System Requirements
- Python 3.10+
- uv (fast Python package installer) or pip

### Dependencies
- mcp: >=1.8.0
- google-auth: >=2.28.1
- google-auth-oauthlib: >=1.2.0
- google-api-python-client: >=2.117.0

### Google Cloud Setup
1. Google Cloud Project with enabled APIs:
   - Google Sheets API
   - Google Drive API
2. OAuth 2.0 credentials OR Service Account credentials
3. OAuth consent screen with scopes:
   - `https://www.googleapis.com/auth/spreadsheets`
   - `https://www.googleapis.com/auth/drive`

### Authentication Methods (Priority Order)
1. **CREDENTIALS_CONFIG**: Base64-encoded credentials (for containerized environments)
2. **SERVICE_ACCOUNT_PATH**: Service account JSON key (recommended for automation)
3. **CREDENTIALS_PATH**: OAuth 2.0 credentials (interactive, for personal use)
4. **Application Default Credentials (ADC)**: Automatic discovery from gcloud or metadata server

### Environment Variables

#### Service Account (Recommended)
- `SERVICE_ACCOUNT_PATH`: Path to service account JSON key
- `DRIVE_FOLDER_ID`: Google Drive folder ID (shared with service account)

#### OAuth 2.0
- `CREDENTIALS_PATH`: Path to OAuth credentials JSON (default: `credentials.json`)
- `TOKEN_PATH`: Path to store OAuth token (default: `token.json`)

#### Direct Credential Injection (Docker/K8s)
- `CREDENTIALS_CONFIG`: Base64-encoded credentials JSON

#### ADC (Google Cloud environments)
- `GOOGLE_APPLICATION_CREDENTIALS`: Path to service account key (Google's standard)
- No env vars needed if using `gcloud auth application-default login`

#### Tool Filtering
- `ENABLED_TOOLS`: Comma-separated list of tool names to enable

## Installation

### Quick Start with uvx (Recommended)
```bash
# Install uv first
curl -LsSf https://astral.sh/uv/install.sh | sh  # macOS/Linux
# Or: pip install uv

# Run directly (always use @latest)
uvx mcp-google-sheets@latest
```

### Development Installation
```bash
cd /Users/linktrend/Projects/LiNKbot/skills/google-sheets
uv run mcp-google-sheets
```

### Docker
```bash
docker build -t mcp-google-sheets .
docker run --rm -p 8000:8000 \
  -e CREDENTIALS_CONFIG=YOUR_BASE64_CREDENTIALS \
  -e DRIVE_FOLDER_ID=YOUR_FOLDER_ID \
  mcp-google-sheets
```

## Usage

### MCP Configuration

#### Service Account (Recommended)
```json
{
  "mcpServers": {
    "google-sheets": {
      "command": "uvx",
      "args": ["mcp-google-sheets@latest"],
      "env": {
        "SERVICE_ACCOUNT_PATH": "/path/to/service-account-key.json",
        "DRIVE_FOLDER_ID": "your_folder_id"
      }
    }
  }
}
```

#### With Tool Filtering (Reduce Tokens)
```json
{
  "mcpServers": {
    "google-sheets": {
      "command": "uvx",
      "args": [
        "mcp-google-sheets@latest",
        "--include-tools",
        "get_sheet_data,update_cells,list_spreadsheets,list_sheets"
      ],
      "env": {
        "SERVICE_ACCOUNT_PATH": "/path/to/credentials.json"
      }
    }
  }
}
```

## Available Tools

### Most Common (Recommended Subset)
- `get_sheet_data` - Read from spreadsheets
- `update_cells` - Write to spreadsheets
- `list_spreadsheets` - Find spreadsheets
- `list_sheets` - Navigate tabs

### All Available Tools
- `add_columns` - Insert empty columns
- `add_rows` - Insert empty rows
- `batch_update` - Batch spreadsheet operations
- `batch_update_cells` - Update multiple ranges
- `copy_sheet` - Duplicate sheet to another spreadsheet
- `create_sheet` - Add new sheet/tab
- `create_spreadsheet` - Create new spreadsheet
- `find_in_spreadsheet` - Search for content
- `get_multiple_sheet_data` - Fetch multiple ranges at once
- `get_multiple_spreadsheet_summary` - Get summaries for multiple spreadsheets
- `get_sheet_data` - Read sheet data
- `get_sheet_formulas` - Read cell formulas
- `list_folders` - List Drive folders
- `list_sheets` - List all tabs in spreadsheet
- `list_spreadsheets` - List accessible spreadsheets
- `rename_sheet` - Rename sheet/tab
- `search_spreadsheets` - Search across spreadsheets
- `share_spreadsheet` - Share with specific users/roles
- `update_cells` - Write data to range

## A1 Notation Support
- Single cell: `A1`
- Range: `A1:B10`
- Specific sheet: `Sheet1!A1:B10`
- Entire column: `A:A`
- Entire row: `1:1`

## Value Input Options
- **USER_ENTERED** (default): Parsed as if typed (formulas work)
- **RAW**: Stored exactly as provided

## Per-Skill Model Configuration
**Status**: Not Supported

This MCP server does not have built-in per-skill model configuration. It acts as a tool provider for MCP clients, and AI model selection is handled at the client level.

## ID Reference Guide

### Google Cloud Project ID
```
https://console.cloud.google.com/apis/dashboard?project=sheets-mcp-server-123456
                                                         └── Project ID ──┘
```

### Google Drive Folder ID
```
https://drive.google.com/drive/u/0/folders/1xcRQCU9xrNVBPTeNzHqx4hrG7yR91WIa
                                            └────── Folder ID ──────┘
```

### Google Sheets Spreadsheet ID
```
https://docs.google.com/spreadsheets/d/25_-_raTaKjaVxu9nJzA7-FCrNhnkd3cXC54BPAOXemI/edit
                                        └─────────── Spreadsheet ID ─────────┘
```

## Known Limitations
- None reported in documentation

## Security Notes
- Credentials files should never be committed to git
- Use Base64 CREDENTIALS_CONFIG for containerized deployments
- Service accounts require folder sharing for access
- ADC provides automatic credential discovery in Google Cloud environments

## Testing
- Built with FastMCP framework
- Actively maintained with community contributions

## Documentation
- Full README: `/Users/linktrend/Projects/LiNKbot/skills/google-sheets/README.md`
- PyPI Package: `mcp-google-sheets`
