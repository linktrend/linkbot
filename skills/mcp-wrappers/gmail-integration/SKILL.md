---
name: gmail-integration
description: Access Gmail and Calendar actions through mcporter and the gmail-integration MCP server.
metadata:
  {
    "openclaw":
      {
        "emoji": "📬",
        "requires": { "bins": ["mcporter"] },
      },
  }
---

# Gmail Integration MCP Wrapper

Use this wrapper for mailbox search, email context retrieval, and Gmail/Calendar automation.

## Core Commands

```bash
# Inspect tools exposed by the server
mcporter --config /root/linkbot/config/mcporter.json list gmail-integration --schema

# Example tool invocation (replace tool name with one listed by --schema)
mcporter --config /root/linkbot/config/mcporter.json call gmail-integration.get_inbox_overview
```

## Notes

- Ensure OAuth is completed for `gmail-integration` before calling tools.
- First auth run creates `tokens.json` using the Gmail MCP server's token manager.
