---
name: google-slides
description: Create and edit Google Slides presentations through mcporter and the google-slides MCP server.
metadata:
  {
    "openclaw":
      {
        "emoji": "📽️",
        "requires": { "bins": ["mcporter"] },
      },
  }
---

# Google Slides MCP Wrapper

Use this wrapper for presentation creation, reading, and updates in Google Slides.

## Core Commands

```bash
# Inspect available tools
mcporter --config /root/linkbot/config/mcporter.json list google-slides --schema

# Example: create a presentation
mcporter --config /root/linkbot/config/mcporter.json call google-slides.create_presentation title="Quarterly Update"
```

## Notes

- Uses OAuth credentials from `/root/linkbot/skills/shared/google-slides/credentials.json` and `/root/linkbot/skills/shared/google-slides/token.json`.
- If schema fails, check build logs:
  - `/tmp/google-slides-npm-install.log`
  - `/tmp/google-slides-build.log`
