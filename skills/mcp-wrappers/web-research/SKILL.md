---
name: web-research
description: Run Brave-powered web, image, video, and news research through mcporter.
metadata:
  {
    "openclaw":
      {
        "emoji": "🔎",
        "requires": { "bins": ["mcporter"] },
      },
  }
---

# Web Research MCP Wrapper

Use this wrapper for web research and summarized search results.

## Core Commands

```bash
# Inspect available tools
mcporter --config /root/linkbot/config/mcporter.json list web-research --schema

# Example: web search
mcporter --config /root/linkbot/config/mcporter.json call web-research.brave_web_search query="AI automation trends 2026"
```

## Notes

- Requires `BRAVE_API_KEY` in runtime environment.
- If schema fails, check build logs:
  - `/tmp/web-research-npm-install.log`
  - `/tmp/web-research-build.log`
