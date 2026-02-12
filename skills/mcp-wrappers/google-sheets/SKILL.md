---
name: google-sheets
description: Read and update Google Sheets through mcporter and the google-sheets MCP server.
metadata:
  {
    "openclaw":
      {
        "emoji": "📊",
        "requires": { "bins": ["mcporter"] },
      },
  }
---

# Google Sheets MCP Wrapper

Use this wrapper for spreadsheet creation, reads, updates, and tab management.

## Core Commands

```bash
# List spreadsheets
mcporter --config /root/linkbot/config/mcporter.json call google-sheets.list_spreadsheets

# Create a spreadsheet
mcporter --config /root/linkbot/config/mcporter.json call google-sheets.create_spreadsheet title="Budget 2026"

# Update a range
mcporter --config /root/linkbot/config/mcporter.json call google-sheets.update_cells spreadsheet_id="SPREADSHEET_ID" sheet="Sheet1" range="A1:B2" data='[["Category","Amount"],["Marketing",1200]]'
```

## Notes

- Ensure OAuth is completed for `google-sheets` before calling tools.
- `spreadsheet_id` is the ID in the Google Sheets URL.
