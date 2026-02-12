---
name: google-docs-mcp
description: Create, read, write, and format Google Docs using the MCP server
homepage: https://github.com/a-bonus/google-docs-mcp
metadata:
  {
    "openclaw":
      {
        "emoji": "📝",
        "requires": { "bins": ["mcporter"] },
      },
  }
---

# Google Docs MCP Skill

This skill provides access to Google Docs via the MCP server, allowing you to create, read, write, and format documents programmatically.

## Available Tools

### Document Creation & Management

```bash
# Create a new Google Doc
mcporter --config /root/linkbot/config/mcporter.json call google-docs.createDocument title="Document Title"

# List Google Docs (with optional search)
mcporter --config /root/linkbot/config/mcporter.json call google-docs.listGoogleDocs maxResults:10

# Get document information
mcporter --config /root/linkbot/config/mcporter.json call google-docs.getDocumentInfo documentId="YOUR_DOC_ID"
```

### Reading Documents

```bash
# Read document as text
mcporter --config /root/linkbot/config/mcporter.json call google-docs.readGoogleDoc documentId="YOUR_DOC_ID" format="text"

# Read document as markdown
mcporter --config /root/linkbot/config/mcporter.json call google-docs.readGoogleDoc documentId="YOUR_DOC_ID" format="markdown"
```

### Writing Content

```bash
# Append text to document
mcporter --config /root/linkbot/config/mcporter.json call google-docs.appendToGoogleDoc documentId="YOUR_DOC_ID" textToAppend="Your content here"

# Replace document content with markdown
mcporter --config /root/linkbot/config/mcporter.json call google-docs.replaceDocumentWithMarkdown documentId="YOUR_DOC_ID" markdown="# Title\n\nYour content"

# Append markdown to document
mcporter --config /root/linkbot/config/mcporter.json call google-docs.appendMarkdownToGoogleDoc documentId="YOUR_DOC_ID" markdown="## Section\n\nContent"

# Insert text at specific position
mcporter --config /root/linkbot/config/mcporter.json call google-docs.insertText documentId="YOUR_DOC_ID" textToInsert="Text" index:1
```

### Formatting

```bash
# Apply text style (bold, italic, color, etc.)
mcporter --config /root/linkbot/config/mcporter.json call google-docs.applyTextStyle documentId="YOUR_DOC_ID" target.startIndex:1 target.endIndex:10 style.bold:true

# Apply paragraph style (heading, alignment)
mcporter --config /root/linkbot/config/mcporter.json call google-docs.applyParagraphStyle documentId="YOUR_DOC_ID" target.index:1 style.namedStyleType="HEADING_1"
```

### Document Structure

```bash
# Insert table
mcporter --config /root/linkbot/config/mcporter.json call google-docs.insertTable documentId="YOUR_DOC_ID" rows:3 columns:2 index:1

# Insert page break
mcporter --config /root/linkbot/config/mcporter.json call google-docs.insertPageBreak documentId="YOUR_DOC_ID" index:100

# Insert image from URL
mcporter --config /root/linkbot/config/mcporter.json call google-docs.insertImageFromUrl documentId="YOUR_DOC_ID" imageUrl="https://example.com/image.jpg" index:1
```

## Usage Tips

- Document IDs can be extracted from Google Docs URLs
- Use markdown for easy formatting when creating content
- Always specify index positions when inserting content
- Index 1 is the beginning of the document (after title)

## Authentication

This skill uses the service account configured at:
`/root/.openclaw/secrets/google-service-account.json`

No additional authentication is required.
