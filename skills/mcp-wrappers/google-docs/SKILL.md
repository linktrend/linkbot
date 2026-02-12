---
name: google-docs
description: Create, read, and edit Google Docs content through mcporter and the google-docs MCP server.
metadata:
  {
    "openclaw":
      {
        "emoji": "📝",
        "requires": { "bins": ["mcporter"] },
      },
  }
---

# Google Docs MCP Wrapper

Use this wrapper when you need to create documents, read content, or write formatted text in Google Docs.

## Core Commands

```bash
# Create a document
mcporter --config /root/linkbot/config/mcporter.json call google-docs.createDocument title="Quarterly Update"

# Read a document as markdown
mcporter --config /root/linkbot/config/mcporter.json call google-docs.readGoogleDoc documentId="DOC_ID" format="markdown"

# Replace content using markdown
mcporter --config /root/linkbot/config/mcporter.json call google-docs.replaceDocumentWithMarkdown documentId="DOC_ID" markdown="# Title\n\nBody text"
```

## Notes

- Ensure OAuth is completed for `google-docs` before calling tools.
- `documentId` is the ID in the Google Docs URL.
