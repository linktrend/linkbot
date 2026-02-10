# Brave Search MCP Server - Skill Information

## Source
- **Repository**: https://github.com/brave/brave-search-mcp-server
- **Author**: Brave Software, Inc.
- **Stars**: 606+ (as of Feb 2026)
- **License**: MIT

## Version Information
- **Version**: 2.0.72
- **Package Name**: @brave/brave-search-mcp-server
- **Downloaded**: February 9, 2026
- **Last Updated**: Active official repository from Brave

## Description
Official MCP server implementation from Brave that integrates the Brave Search API, providing comprehensive search capabilities including web search, local business search, image search, video search, news search, and AI-powered summarization. Supports both STDIO and HTTP transports.

## Key Features

### Search Types
- **Web Search**: Comprehensive results with rich filtering options
- **Local Search**: Business and location searches with ratings/hours (Pro plans)
- **Image Search**: Image results with metadata
- **Video Search**: Video results with thumbnails and metadata
- **News Search**: Current news with freshness controls and breaking news indicators
- **AI Summarizer**: AI-powered summaries from web search results

### Advanced Capabilities
- Custom re-ranking with Goggles
- Freshness filters (past day, week, month, year, date ranges)
- SafeSearch content filtering
- Result type filtering
- Spell checking
- Text highlighting/decorations
- Country and language customization
- Extra snippets for enhanced context (Pro plans)

### Deployment Options
- STDIO transport (default, for MCP clients)
- HTTP transport (for REST API usage)
- Docker support
- NPX quick installation
- Smithery.ai integration

### Tool Filtering
- Enable/disable specific tools via whitelist or blacklist
- Reduce context usage by limiting tool exposure

## Requirements

### System Requirements
- Node.js 22.x+ or higher
- npm

### Dependencies
- @modelcontextprotocol/sdk: 1.26.0
- commander: 14.0.2
- dotenv: 17.2.3
- express: 5.2.1
- zod: 4.3.5

### Brave Search API Key
- Sign up at https://brave.com/search/api/
- Free tier: 2,000 queries/month, 1 query/second
- Pro tier: $9 per 1,000 requests, 50 queries/second, enhanced features

### Environment Variables
- `BRAVE_API_KEY`: Your Brave Search API key (required)
- `BRAVE_MCP_TRANSPORT`: Transport mode ("stdio" or "http", default: "stdio")
- `BRAVE_MCP_PORT`: HTTP server port (default: 8000)
- `BRAVE_MCP_HOST`: HTTP server host (default: "0.0.0.0")
- `BRAVE_MCP_LOG_LEVEL`: Logging level (default: "info")
- `BRAVE_MCP_ENABLED_TOOLS`: Comma-separated whitelist of tools
- `BRAVE_MCP_DISABLED_TOOLS`: Comma-separated blacklist of tools
- `BRAVE_MCP_STATELESS`: HTTP stateless mode (default: "true")

## Installation

### Via Smithery (Recommended)
```bash
npx -y @smithery/cli install brave
```

### Via NPX
```bash
npx -y @brave/brave-search-mcp-server
```

### Docker
```bash
docker pull mcp/brave-search
docker run -i --rm -e BRAVE_API_KEY mcp/brave-search
```

### Development
```bash
cd /Users/linktrend/Projects/LiNKbot/skills/web-research
npm install
npm run build
node dist/index.js
```

## Usage

### MCP Configuration

#### Docker
```json
{
  "mcpServers": {
    "brave-search": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "-e", "BRAVE_API_KEY", "mcp/brave-search"],
      "env": {
        "BRAVE_API_KEY": "YOUR_API_KEY"
      }
    }
  }
}
```

#### NPX
```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@brave/brave-search-mcp-server", "--transport", "stdio"],
      "env": {
        "BRAVE_API_KEY": "YOUR_API_KEY"
      }
    }
  }
}
```

#### VS Code MCP Extension
```json
{
  "inputs": [
    {
      "password": true,
      "id": "brave-api-key",
      "type": "promptString",
      "description": "Brave Search API Key"
    }
  ],
  "servers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@brave/brave-search-mcp-server", "--transport", "stdio"],
      "env": {
        "BRAVE_API_KEY": "${input:brave-api-key}"
      }
    }
  }
}
```

### Command Line Options
```bash
node dist/index.js [options]

Options:
  --brave-api-key <key>      Brave API key
  --transport <type>         Transport type (default: stdio)
  --port <number>            HTTP server port (default: 8080)
  --host <host>              HTTP server host (default: 0.0.0.0)
  --logging-level <level>    Logging level (default: info)
  --enabled-tools <tools>    Comma-separated tool whitelist
  --disabled-tools <tools>   Comma-separated tool blacklist
  --stateless               HTTP stateless flag
```

## Available Tools

### brave_web_search
Comprehensive web search with advanced filtering.

**Parameters:**
- `query` (string, required): Search terms (max 400 chars, 50 words)
- `country` (string, optional): Country code (default: "US")
- `search_lang` (string, optional): Search language (default: "en")
- `ui_lang` (string, optional): UI language (default: "en-US")
- `count` (number, optional): Results per page (1-20, default: 10)
- `offset` (number, optional): Pagination offset (max 9, default: 0)
- `safesearch` (string, optional): "off", "moderate", "strict" (default: "moderate")
- `freshness` (string, optional): "pd", "pw", "pm", "py", or date range
- `text_decorations` (boolean, optional): Include highlighting (default: true)
- `spellcheck` (boolean, optional): Enable spell checking (default: true)
- `result_filter` (array, optional): Filter result types (default: ["web", "query"])
- `goggles` (array, optional): Custom re-ranking definitions
- `units` (string, optional): "metric" or "imperial"
- `extra_snippets` (boolean, optional): Get additional excerpts (Pro only)
- `summary` (boolean, optional): Enable AI summarization key generation

### brave_local_search
Search for local businesses and places (Pro plans only).

**Parameters:** Same as `brave_web_search` with automatic location filtering

### brave_video_search
Search for videos with comprehensive metadata.

**Parameters:**
- `query` (string, required): Search terms
- `country`, `search_lang`, `ui_lang` (optional)
- `count` (number, optional): 1-50, default: 20
- `offset`, `spellcheck`, `safesearch`, `freshness` (optional)

### brave_image_search
Search for images with metadata.

**Parameters:**
- `query` (string, required): Search terms
- `country`, `search_lang` (optional)
- `count` (number, optional): 1-200, default: 50
- `safesearch` (string, optional): "off", "strict" (default: "strict")
- `spellcheck` (boolean, optional)

### brave_news_search
Search for current news articles.

**Parameters:**
- `query` (string, required): Search terms
- `country`, `search_lang`, `ui_lang` (optional)
- `count` (number, optional): 1-50, default: 20
- `offset`, `spellcheck`, `safesearch` (optional)
- `freshness` (string, optional): Default: "pd" (last 24 hours)
- `extra_snippets` (boolean, optional): Pro only
- `goggles` (array, optional)

### brave_summarizer
Generate AI-powered summaries from web search results.

**Parameters:**
- `key` (string, required): Summary key from web search (use `summary: true`)
- `entity_info` (boolean, optional): Include entity information (default: false)
- `inline_references` (boolean, optional): Add source URL references (default: false)

**Usage:** First perform web search with `summary: true`, then use returned key with this tool.

## Brave Search API Pricing
- **Free**: 2,000 queries/month, 1 query/second, basic features
- **Pro**: $9 per 1,000 requests, 50 queries/second, enhanced features
  - Local search
  - AI summaries
  - Extra snippets

## Per-Skill Model Configuration
**Status**: Not Supported

This MCP server does not have built-in per-skill model configuration. It provides search tools to MCP clients, and AI model selection is handled at the client level.

## Migration Notes (v1.x to v2.x)
- Default transport changed from HTTP to STDIO
- Set `BRAVE_MCP_TRANSPORT=http` to continue using HTTP
- `brave_image_search` response structure changed (removed base64 data)

## Known Limitations
- Free tier has rate limits (1 query/second)
- Local search requires Pro plan
- AI summarization requires Pro plan
- Extra snippets require Pro plan
- Date range freshness uses specific format

## Security Notes
- Store `BRAVE_API_KEY` securely (never commit to git)
- Use environment variables or secret management
- API key usage is tracked and billed by Brave

## Testing
Included test utilities:
- MCP Inspector support: `npm run inspector`
- Smithery.ai dev environment: `npm run smithery:dev`

## Documentation
- Full README: `/Users/linktrend/Projects/LiNKbot/skills/web-research/README.md`
- Brave Search API Docs: https://brave.com/search/api/
- Official GitHub: https://github.com/brave/brave-search-mcp-server
