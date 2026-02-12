---
title: "TOOLS.md Template"
summary: "Workspace template for TOOLS.md"
read_when:
  - Bootstrapping a workspace manually
---

# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

## Google Workspace Access (MCP Only)

- Primary account: `lisa@linktrend.media`
- Use MCP wrappers for Google operations, not `gog` or raw `exec` calls.

Preferred skills:

- `google-docs`
- `google-sheets`
- `google-slides`
- `web-research`
- `gmail-integration`
- `mcporter` (transport)

Runtime references:

- `mcporter` config: `/root/linkbot/config/mcporter.json`
- OAuth credentials: `/root/.openclaw/secrets/google-oauth.json`
- Token files:
  - `/root/linkbot/skills/shared/google-docs/token.json`
  - `/root/linkbot/skills/shared/google-sheets/token.json`
  - `/root/linkbot/skills/shared/gmail-integration/tokens.json`

Execution rule:

- Always call `mcporter` with explicit config:
  - `mcporter --config /root/linkbot/config/mcporter.json ...`
- Use `call <server.tool> key=value` argument style (not `--flag value`).
- Before claiming a Gmail tool is unavailable, always verify live schema:
  - `mcporter --config /root/linkbot/config/mcporter.json list gmail-integration --schema`

Gmail outbound tools:

- `gmail-integration.create_email_draft`
- `gmail-integration.send_new_email`
- If the user explicitly asks to send now, use `gmail-integration.send_new_email`.
