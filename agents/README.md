# Agents Library

Central repository for all specialist AI agents that can be orchestrated by bots.

## Directory Structure

### `antigravity/`
**Antigravity Kit 2.0 Agents** - Specialist agents from Google's Antigravity platform
- 40+ skills and 16+ specialized agents
- Examples: frontend-specialist, seo-specialist, database-specialist, security-auditor
- Each agent is self-contained with skills, tools, and configuration
- Auto-activated based on context or explicitly invoked

### `custom/`
**Custom Agents** - Specialized agents built specifically for LiNKbot ecosystem
- Domain-specific agents tailored to your business needs
- Integration agents for specific platforms/services
- Experimental or prototype agents

## Agent Structure

Each agent folder contains:
```
agent-name/
├── AGENT.md          # Agent definition and capabilities
├── skills/           # Agent-specific skills
├── tools/            # Agent-specific tools
└── config.json       # Agent configuration
```

## Using Agents

Bots can invoke agents to handle specialized tasks:
- Lisa orchestrates agents by delegating tasks
- Agents have their own skills and tools
- Results are returned to the orchestrating bot

Enable agents in bot's `openclaw.json`:
```json
"agents": {
  "enabled": ["seo-specialist", "frontend-specialist"]
}
```

## Deployment

Like skills, agents are deployed selectively. Only enabled agents are copied to each bot's deployment target.
