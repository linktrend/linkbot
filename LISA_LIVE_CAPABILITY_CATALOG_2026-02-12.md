# Lisa Live Capability Catalog (Updated 2026-02-12)

Generated from live VPS runtime plus repo metadata.

## Summary

- skills_total_runtime: 107
- skills_enabled: 88
- skills_disabled_but_installed: 19
- skills_enabled_and_configured: 55
- skills_unavailable_or_blocked: 33
- agents_total_listed: 22
- agents_enabled_and_configured: 6
- agents_installed_but_disabled: 16
- mcp_total_listed: 5
- mcp_enabled_and_configured: 5

## MCP Servers

| Name | Status | Description | Example | Verification |
|---|---|---|---|---|
| gmail-integration | enabled_and_configured | Access Gmail and Calendar actions through mcporter and the gmail-integration MCP server. | Lisa, use "gmail-integration" to help with this task. | mcporter list status="ok" on VPS (2026-02-12). |
| google-docs | enabled_and_configured | Create, read, and edit Google Docs content through mcporter and the google-docs MCP server. | Lisa, use "google-docs" to help with this task. | mcporter list status="ok" on VPS (2026-02-12). |
| google-sheets | enabled_and_configured | Read and update Google Sheets through mcporter and the google-sheets MCP server. | Lisa, use "google-sheets" to help with this task. | mcporter list status="ok" on VPS (2026-02-12). |
| google-slides | enabled_and_configured | Create and edit Google Slides presentations through mcporter and the google-slides MCP server. | Lisa, use "google-slides" to help with this task. | mcporter list status="ok" on VPS (2026-02-12). |
| web-research | enabled_and_configured | Run Brave-powered web, image, video, and news research through mcporter. | Lisa, use "web-research" to help with this task. | mcporter list status="ok" on VPS (2026-02-12). |

## Agents

| ID | Status | Description | Example | Model |
|---|---|---|---|---|
| main | enabled_and_configured | Lisa runtime agent: main | Lisa, use the "main" agent for this task. | openrouter/moonshotai/kimi-k2.5 |
| README | installed_but_disabled | Agent persona available: README | Lisa, use the "README" agent for this task. |  |
| backend-specialist | installed_but_disabled | Expert backend architect for Node.js, Python, and modern serverless/edge systems. Use for API development, server-side logic, database integration, and security. Triggers on backend, server, api, endpoint, database, auth. | Lisa, use the "backend-specialist" agent for this task. |  |
| code-archaeologist | installed_but_disabled | Expert in legacy code, refactoring, and understanding undocumented systems. Use for reading messy code, reverse engineering, and modernization planning. Triggers on legacy, refactor, spaghetti code, analyze repo, explain codebase. | Lisa, use the "code-archaeologist" agent for this task. |  |
| database-architect | installed_but_disabled | Expert database architect for schema design, query optimization, migrations, and modern serverless databases. Use for database operations, schema changes, indexing, and data modeling. Triggers on database, sql, schema, migration, query, postgres, index, table. | Lisa, use the "database-architect" agent for this task. |  |
| debugger | installed_but_disabled | Expert in systematic debugging, root cause analysis, and crash investigation. Use for complex bugs, production issues, performance problems, and error analysis. Triggers on bug, error, crash, not working, broken, investigate, fix. | Lisa, use the "debugger" agent for this task. |  |
| devops-engineer | installed_but_disabled | Expert in deployment, server management, CI/CD, and production operations. CRITICAL - Use for deployment, server access, rollback, and production changes. HIGH RISK operations. Triggers on deploy, production, server, pm2, ssh, release, rollback, ci/cd. | Lisa, use the "devops-engineer" agent for this task. |  |
| documentation-writer | installed_but_disabled | Expert in technical documentation. Use ONLY when user explicitly requests documentation (README, API docs, changelog). DO NOT auto-invoke during normal development. | Lisa, use the "documentation-writer" agent for this task. |  |
| explorer-agent | enabled_and_configured | Advanced codebase discovery, deep architectural analysis, and proactive research agent. The eyes and ears of the framework. Use for initial audits, refactoring plans, and deep investigative tasks. | Lisa, use the "explorer-agent" agent for this task. | openrouter/moonshotai/kimi-k2.5 |
| frontend-specialist | installed_but_disabled | Senior Frontend Architect who builds maintainable React/Next.js systems with performance-first mindset. Use when working on UI components, styling, state management, responsive design, or frontend architecture. Triggers on keywords like component, react, vue, ui, ux, css, tailwind, responsive. | Lisa, use the "frontend-specialist" agent for this task. |  |
| game-developer | installed_but_disabled | Game development across all platforms (PC, Web, Mobile, VR/AR). Use when building games with Unity, Godot, Unreal, Phaser, Three.js, or any game engine. Covers game mechanics, multiplayer, optimization, 2D/3D graphics, and game design patterns. | Lisa, use the "game-developer" agent for this task. |  |
| mobile-developer | installed_but_disabled | Expert in React Native and Flutter mobile development. Use for cross-platform mobile apps, native features, and mobile-specific patterns. Triggers on mobile, react native, flutter, ios, android, app store, expo. | Lisa, use the "mobile-developer" agent for this task. |  |
| orchestrator | enabled_and_configured | Multi-agent coordination and task orchestration. Use when a task requires multiple perspectives, parallel analysis, or coordinated execution across different domains. Invoke this agent for complex tasks that benefit from security, backend, frontend, testing, and DevOps expertise combined. | Lisa, use the "orchestrator" agent for this task. | openrouter/moonshotai/kimi-k2.5 |
| penetration-tester | installed_but_disabled | Expert in offensive security, penetration testing, red team operations, and vulnerability exploitation. Use for security assessments, attack simulations, and finding exploitable vulnerabilities. Triggers on pentest, exploit, attack, hack, breach, pwn, redteam, offensive. | Lisa, use the "penetration-tester" agent for this task. |  |
| performance-optimizer | installed_but_disabled | Expert in performance optimization, profiling, Core Web Vitals, and bundle optimization. Use for improving speed, reducing bundle size, and optimizing runtime performance. Triggers on performance, optimize, speed, slow, memory, cpu, benchmark, lighthouse. | Lisa, use the "performance-optimizer" agent for this task. |  |
| product-manager | enabled_and_configured | Expert in product requirements, user stories, and acceptance criteria. Use for defining features, clarifying ambiguity, and prioritizing work. Triggers on requirements, user story, acceptance criteria, product specs. | Lisa, use the "product-manager" agent for this task. | openrouter/moonshotai/kimi-k2.5 |
| product-owner | enabled_and_configured | Strategic facilitator bridging business needs and technical execution. Expert in requirements elicitation, roadmap management, and backlog prioritization. Triggers on requirements, user story, backlog, MVP, PRD, stakeholder. | Lisa, use the "product-owner" agent for this task. | openrouter/moonshotai/kimi-k2.5 |
| project-planner | enabled_and_configured | Smart project planning agent. Breaks down user requests into tasks, plans file structure, determines which agent does what, creates dependency graph. Use when starting new projects or planning major features. | Lisa, use the "project-planner" agent for this task. | openrouter/moonshotai/kimi-k2.5 |
| qa-automation-engineer | installed_but_disabled | Specialist in test automation infrastructure and E2E testing. Focuses on Playwright, Cypress, CI pipelines, and breaking the system. Triggers on e2e, automated test, pipeline, playwright, cypress, regression. | Lisa, use the "qa-automation-engineer" agent for this task. |  |
| security-auditor | installed_but_disabled | Elite cybersecurity expert. Think like an attacker, defend like an expert. OWASP 2025, supply chain security, zero trust architecture. Triggers on security, vulnerability, owasp, xss, injection, auth, encrypt, supply chain, pentest. | Lisa, use the "security-auditor" agent for this task. |  |
| seo-specialist | installed_but_disabled | SEO and GEO (Generative Engine Optimization) expert. Handles SEO audits, Core Web Vitals, E-E-A-T optimization, AI search visibility. Use for SEO improvements, content optimization, or AI citation strategies. | Lisa, use the "seo-specialist" agent for this task. |  |
| test-engineer | installed_but_disabled | Expert in testing, TDD, and test automation. Use for writing tests, improving coverage, debugging test failures. Triggers on test, spec, coverage, jest, pytest, playwright, e2e, unit test. | Lisa, use the "test-engineer" agent for this task. |  |

## Skills (Runtime)

| Name | Status | Description | Example | Missing |
|---|---|---|---|---|
| 1password | enabled_but_unavailable_missing_prereqs | Set up and use 1Password CLI (op). Use when installing the CLI, enabling desktop app integration, signing in (single or multi-account), or reading/injecting/running secrets via op. | Lisa, use "1password" for this task. | bins:1 |
| 2d-games | disabled_but_installed | 2D game development principles. Sprites, tilemaps, physics, camera. | Lisa, use "2d-games" for this task. |  |
| 3d-games | disabled_but_installed | 3D game development principles. Rendering, shaders, physics, cameras. | Lisa, use "3d-games" for this task. |  |
| api-patterns | enabled_and_configured | API design principles and decision-making. REST vs GraphQL vs tRPC selection, response formats, versioning, pagination. | Lisa, use "api-patterns" for this task. |  |
| app-builder | enabled_and_configured | Main application building orchestrator. Creates full-stack applications from natural language requests. Determines project type, selects tech stack, coordinates agents. | Lisa, use "app-builder" for this task. |  |
| apple-notes | enabled_but_unavailable_missing_prereqs | Manage Apple Notes via the `memo` CLI on macOS (create, view, edit, delete, search, move, and export notes). Use when a user asks OpenClaw to add a note, list notes, search notes, or manage note folders. | Lisa, use "apple-notes" for this task. | bins:1, os:1 |
| apple-reminders | enabled_but_unavailable_missing_prereqs | Manage Apple Reminders via the `remindctl` CLI on macOS (list, add, edit, complete, delete). Supports lists, date filters, and JSON/plain output. | Lisa, use "apple-reminders" for this task. | bins:1, os:1 |
| architecture | enabled_and_configured | Architectural decision-making framework. Requirements analysis, trade-off evaluation, ADR documentation. Use when making architecture decisions or analyzing system design. | Lisa, use "architecture" for this task. |  |
| bash-linux | enabled_and_configured | Bash/Linux terminal patterns. Critical commands, piping, error handling, scripting. Use when working on macOS or Linux systems. | Lisa, use "bash-linux" for this task. |  |
| bear-notes | enabled_but_unavailable_missing_prereqs | Create, search, and manage Bear notes via grizzly CLI. | Lisa, use "bear-notes" for this task. | bins:1, os:1 |
| behavioral-modes | enabled_and_configured | AI operational modes (brainstorm, implement, debug, review, teach, ship, orchestrate). Use to adapt behavior based on task type. | Lisa, use "behavioral-modes" for this task. |  |
| blogwatcher | enabled_but_unavailable_missing_prereqs | Monitor blogs and RSS/Atom feeds for updates using the blogwatcher CLI. | Lisa, use "blogwatcher" for this task. | bins:1 |
| blucli | enabled_but_unavailable_missing_prereqs | BluOS CLI (blu) for discovery, playback, grouping, and volume. | Lisa, use "blucli" for this task. | bins:1 |
| bluebubbles | enabled_but_unavailable_missing_prereqs | Use when you need to send or manage iMessages via BlueBubbles (recommended iMessage integration). Calls go through the generic message tool with channel="bluebubbles". | Lisa, use "bluebubbles" for this task. | config:1 |
| brainstorming | enabled_and_configured | Socratic questioning protocol + user communication. MANDATORY for complex requests, new features, or unclear requirements. Includes progress reporting and error handling. | Lisa, use "brainstorming" for this task. |  |
| camsnap | enabled_but_unavailable_missing_prereqs | Capture frames or clips from RTSP/ONVIF cameras. | Lisa, use "camsnap" for this task. | bins:1 |
| clawhub | enabled_but_unavailable_missing_prereqs | Use the ClawHub CLI to search, install, update, and publish agent skills from clawhub.com. Use when you need to fetch new skills on the fly, sync installed skills to latest or a specific version, or publish new/updated skill folders with the npm-installed clawhub CLI. | Lisa, use "clawhub" for this task. | bins:1 |
| clean-code | enabled_and_configured | Pragmatic coding standards - concise, direct, no over-engineering, no unnecessary comments | Lisa, use "clean-code" for this task. |  |
| code-review-checklist | enabled_and_configured | Code review guidelines covering code quality, security, and best practices. | Lisa, use "code-review-checklist" for this task. |  |
| coding-agent | enabled_but_unavailable_missing_prereqs | Run Codex CLI, Claude Code, OpenCode, or Pi Coding Agent via background process for programmatic control. | Lisa, use "coding-agent" for this task. |  |
| database-design | enabled_and_configured | Database design principles and decision-making. Schema design, indexing strategy, ORM selection, serverless databases. | Lisa, use "database-design" for this task. |  |
| deployment-procedures | enabled_and_configured | Production deployment principles and decision-making. Safe deployment workflows, rollback strategies, and verification. Teaches thinking, not scripts. | Lisa, use "deployment-procedures" for this task. |  |
| document-generator | enabled_and_configured | Create, edit, and analyze professional documents including Word (.docx), Excel (.xlsx), PowerPoint (.pptx), and PDF files. Supports templates, reports, forms, and complex formatting. | Lisa, use "document-generator" for this task. |  |
| documentation-templates | enabled_and_configured | Documentation templates and structure guidelines. README, API docs, code comments, and AI-friendly documentation. | Lisa, use "documentation-templates" for this task. |  |
| eightctl | enabled_but_unavailable_missing_prereqs | Control Eight Sleep pods (status, temperature, alarms, schedules). | Lisa, use "eightctl" for this task. | bins:1 |
| financial-calculator | enabled_and_configured | Advanced financial calculations skill for ROI analysis, budget planning, financial projections, investment analysis, and business financial modeling. Supports NPV, IRR, payback period, and cash flow analysis. | Lisa, use "financial-calculator" for this task. |  |
| frontend-design | enabled_and_configured | Design thinking and decision-making for web UI. Use when designing components, layouts, color schemes, typography, or creating aesthetic interfaces. Teaches principles, not fixed values. | Lisa, use "frontend-design" for this task. |  |
| game-art | disabled_but_installed | Game art principles. Visual style selection, asset pipeline, animation workflow. | Lisa, use "game-art" for this task. |  |
| game-audio | disabled_but_installed | Game audio principles. Sound design, music integration, adaptive audio systems. | Lisa, use "game-audio" for this task. |  |
| game-design | disabled_but_installed | Game design principles. GDD structure, balancing, player psychology, progression. | Lisa, use "game-design" for this task. |  |
| game-development | disabled_but_installed | Game development orchestrator. Routes to platform-specific skills based on project needs. | Lisa, use "game-development" for this task. |  |
| gemini | enabled_but_unavailable_missing_prereqs | Gemini CLI for one-shot Q&A, summaries, and generation. | Lisa, use "gemini" for this task. | bins:1 |
| geo-fundamentals | enabled_and_configured | Generative Engine Optimization for AI search engines (ChatGPT, Claude, Perplexity). | Lisa, use "geo-fundamentals" for this task. |  |
| gifgrep | enabled_but_unavailable_missing_prereqs | Search GIF providers with CLI/TUI, download results, and extract stills/sheets. | Lisa, use "gifgrep" for this task. | bins:1 |
| github | enabled_but_unavailable_missing_prereqs | Interact with GitHub using the `gh` CLI. Use `gh issue`, `gh pr`, `gh run`, and `gh api` for issues, PRs, CI runs, and advanced queries. | Lisa, use "github" for this task. | bins:1 |
| gmail-integration | enabled_and_configured | Access Gmail and Calendar actions through mcporter and the gmail-integration MCP server. | Lisa, use "gmail-integration" for this task. |  |
| gog | disabled_but_installed | Google Workspace CLI for Gmail, Calendar, Drive, Contacts, Sheets, and Docs. | Lisa, use "gog" for this task. | bins:1 |
| google-docs | enabled_and_configured | Create, read, and edit Google Docs content through mcporter and the google-docs MCP server. | Lisa, use "google-docs" for this task. |  |
| google-docs-mcp | enabled_and_configured | Create, read, write, and format Google Docs using the MCP server | Lisa, use "google-docs-mcp" for this task. |  |
| google-sheets | enabled_and_configured | Read and update Google Sheets through mcporter and the google-sheets MCP server. | Lisa, use "google-sheets" for this task. |  |
| google-slides | enabled_and_configured | Create and edit Google Slides presentations through mcporter and the google-slides MCP server. | Lisa, use "google-slides" for this task. |  |
| goplaces | enabled_but_unavailable_missing_prereqs | Query Google Places API (New) via the goplaces CLI for text search, place details, resolve, and reviews. Use for human-friendly place lookup or JSON output for scripts. | Lisa, use "goplaces" for this task. | bins:1, env:1 |
| healthcheck | enabled_and_configured | Host security hardening and risk-tolerance configuration for OpenClaw deployments. Use when a user asks for security audits, firewall/SSH/update hardening, risk posture, exposure review, OpenClaw cron scheduling for periodic checks, or version status checks on a machine running OpenClaw (laptop, workstation, Pi, VPS). | Lisa, use "healthcheck" for this task. |  |
| himalaya | enabled_but_unavailable_missing_prereqs | CLI to manage emails via IMAP/SMTP. Use `himalaya` to list, read, write, reply, forward, search, and organize emails from the terminal. Supports multiple accounts and message composition with MML (MIME Meta Language). | Lisa, use "himalaya" for this task. | bins:1 |
| i18n-localization | enabled_and_configured | Internationalization and localization patterns. Detecting hardcoded strings, managing translations, locale files, RTL support. | Lisa, use "i18n-localization" for this task. |  |
| imsg | enabled_but_unavailable_missing_prereqs | iMessage/SMS CLI for listing chats, history, watch, and sending. | Lisa, use "imsg" for this task. | bins:1, os:1 |
| intelligent-routing | enabled_and_configured | Automatic agent selection and intelligent task routing. Analyzes user requests and automatically selects the best specialist agent(s) without requiring explicit user mentions. | Lisa, use "intelligent-routing" for this task. |  |
| local-places | enabled_but_unavailable_missing_prereqs | Search for places (restaurants, cafes, etc.) via Google Places API proxy on localhost. | Lisa, use "local-places" for this task. | env:1 |
| mcp-builder | enabled_and_configured | MCP (Model Context Protocol) server building principles. Tool design, resource patterns, best practices. | Lisa, use "mcp-builder" for this task. |  |
| mcporter | enabled_and_configured | Use the mcporter CLI to list, configure, auth, and call MCP servers/tools directly (HTTP or stdio), including ad-hoc servers, config edits, and CLI/type generation. | Lisa, use "mcporter" for this task. |  |
| meeting-scheduler | enabled_and_configured | Meeting and calendar scheduling skill with timezone support, availability checking, conflict resolution, and integration with Google Calendar and other calendar services. | Lisa, use "meeting-scheduler" for this task. |  |
| mobile-design | enabled_and_configured | Mobile-first design thinking and decision-making for iOS and Android apps. Touch interaction, performance patterns, platform conventions. Teaches principles, not fixed values. Use when building React Native, Flutter, or native mobile apps. | Lisa, use "mobile-design" for this task. |  |
| mobile-games | disabled_but_installed | Mobile game development principles. Touch input, battery, performance, app stores. | Lisa, use "mobile-games" for this task. |  |
| model-usage | enabled_but_unavailable_missing_prereqs | Use CodexBar CLI local cost usage to summarize per-model usage for Codex or Claude, including the current (most recent) model or a full model breakdown. Trigger when asked for model-level usage/cost data from codexbar, or when you need a scriptable per-model summary from codexbar cost JSON. | Lisa, use "model-usage" for this task. | bins:1, os:1 |
| multiplayer | disabled_but_installed | Multiplayer game development principles. Architecture, networking, synchronization. | Lisa, use "multiplayer" for this task. |  |
| nano-banana-pro | enabled_but_unavailable_missing_prereqs | Generate or edit images via Gemini 3 Pro Image (Nano Banana Pro). | Lisa, use "nano-banana-pro" for this task. | env:1 |
| nano-pdf | enabled_but_unavailable_missing_prereqs | Edit PDFs with natural-language instructions using the nano-pdf CLI. | Lisa, use "nano-pdf" for this task. | bins:1 |
| nodejs-best-practices | enabled_and_configured | Node.js development principles and decision-making. Framework selection, async patterns, security, and architecture. Teaches thinking, not copying. | Lisa, use "nodejs-best-practices" for this task. |  |
| notion | enabled_but_unavailable_missing_prereqs | Notion API for creating and managing pages, databases, and blocks. | Lisa, use "notion" for this task. | env:1 |
| obsidian | enabled_but_unavailable_missing_prereqs | Work with Obsidian vaults (plain Markdown notes) and automate via obsidian-cli. | Lisa, use "obsidian" for this task. | bins:1 |
| openai-image-gen | enabled_but_unavailable_missing_prereqs | Batch-generate images via OpenAI Images API. Random prompt sampler + `index.html` gallery. | Lisa, use "openai-image-gen" for this task. | env:1 |
| openai-whisper | enabled_but_unavailable_missing_prereqs | Local speech-to-text with the Whisper CLI (no API key). | Lisa, use "openai-whisper" for this task. | bins:1 |
| openai-whisper-api | enabled_but_unavailable_missing_prereqs | Transcribe audio via OpenAI Audio Transcriptions API (Whisper). | Lisa, use "openai-whisper-api" for this task. | env:1 |
| openhue | enabled_but_unavailable_missing_prereqs | Control Philips Hue lights/scenes via the OpenHue CLI. | Lisa, use "openhue" for this task. | bins:1 |
| oracle | enabled_but_unavailable_missing_prereqs | Best practices for using the oracle CLI (prompt + file bundling, engines, sessions, and file attachment patterns). | Lisa, use "oracle" for this task. | bins:1 |
| ordercli | enabled_but_unavailable_missing_prereqs | Foodora-only CLI for checking past orders and active order status (Deliveroo WIP). | Lisa, use "ordercli" for this task. | bins:1 |
| parallel-agents | enabled_and_configured | Multi-agent orchestration patterns. Use when multiple independent tasks can run with different domain expertise or when comprehensive analysis requires multiple perspectives. | Lisa, use "parallel-agents" for this task. |  |
| pc-games | disabled_but_installed | PC and console game development principles. Engine selection, platform features, optimization strategies. | Lisa, use "pc-games" for this task. |  |
| peekaboo | enabled_but_unavailable_missing_prereqs | Capture and automate macOS UI with the Peekaboo CLI. | Lisa, use "peekaboo" for this task. | bins:1, os:1 |
| performance-profiling | enabled_and_configured | Performance profiling principles. Measurement, analysis, and optimization techniques. | Lisa, use "performance-profiling" for this task. |  |
| plan-writing | enabled_and_configured | Structured task planning with clear breakdowns, dependencies, and verification criteria. Use when implementing features, refactoring, or any multi-step work. | Lisa, use "plan-writing" for this task. |  |
| powershell-windows | enabled_and_configured | PowerShell Windows patterns. Critical pitfalls, operator syntax, error handling. | Lisa, use "powershell-windows" for this task. |  |
| python-coding | enabled_and_configured | Python coding skill for file operations, code generation, script creation, and data processing. Uses MCP filesystem server for secure file access. | Lisa, use "python-coding" for this task. |  |
| python-patterns | enabled_and_configured | Python development principles and decision-making. Framework selection, async patterns, type hints, project structure. Teaches thinking, not copying. | Lisa, use "python-patterns" for this task. |  |
| react-best-practices | enabled_and_configured | React and Next.js performance optimization from Vercel Engineering. Use when building React components, optimizing performance, eliminating waterfalls, reducing bundle size, reviewing code for performance issues, or implementing server/client-side optimizations. | Lisa, use "react-best-practices" for this task. |  |
| red-team-tactics | enabled_and_configured | Red team tactics principles based on MITRE ATT&CK. Attack phases, detection evasion, reporting. | Lisa, use "red-team-tactics" for this task. |  |
| rust-pro | enabled_and_configured | Master Rust 1.75+ with modern async patterns, advanced type system features, and production-ready systems programming. Expert in the latest Rust ecosystem including Tokio, axum, and cutting-edge crates. Use PROACTIVELY for Rust development, performance optimization, or systems programming. | Lisa, use "rust-pro" for this task. |  |
| sag | enabled_but_unavailable_missing_prereqs | ElevenLabs text-to-speech with mac-style say UX. | Lisa, use "sag" for this task. | bins:1, env:1 |
| seo-fundamentals | enabled_and_configured | SEO fundamentals, E-E-A-T, Core Web Vitals, and Google algorithm principles. | Lisa, use "seo-fundamentals" for this task. |  |
| server-management | enabled_and_configured | Server management principles and decision-making. Process management, monitoring strategy, and scaling decisions. Teaches thinking, not commands. | Lisa, use "server-management" for this task. |  |
| session-logs | enabled_and_configured | Search and analyze your own session logs (older/parent conversations) using jq. | Lisa, use "session-logs" for this task. |  |
| sherpa-onnx-tts | enabled_but_unavailable_missing_prereqs | Local text-to-speech via sherpa-onnx (offline, no cloud) | Lisa, use "sherpa-onnx-tts" for this task. | env:2 |
| skill-creator | enabled_and_configured | Create or update AgentSkills. Use when designing, structuring, or packaging skills with scripts, references, and assets. | Lisa, use "skill-creator" for this task. |  |
| slack | disabled_but_installed | Use when you need to control Slack from OpenClaw via the slack tool, including reacting to messages or pinning/unpinning items in Slack channels or DMs. | Lisa, use "slack" for this task. | config:1 |
| songsee | disabled_but_installed | Generate spectrograms and feature-panel visualizations from audio with the songsee CLI. | Lisa, use "songsee" for this task. | bins:1 |
| sonoscli | disabled_but_installed | Control Sonos speakers (discover/status/play/volume/group). | Lisa, use "sonoscli" for this task. | bins:1 |
| spotify-player | disabled_but_installed | Terminal Spotify playback/search via spogo (preferred) or spotify_player. | Lisa, use "spotify-player" for this task. |  |
| summarize | enabled_and_configured | Summarize or extract text/transcripts from URLs, podcasts, and local files (great fallback for “transcribe this YouTube/video”). | Lisa, use "summarize" for this task. |  |
| systematic-debugging | enabled_and_configured | 4-phase systematic debugging methodology with root cause analysis and evidence-based verification. Use when debugging complex issues. | Lisa, use "systematic-debugging" for this task. |  |
| tailwind-patterns | enabled_and_configured | Tailwind CSS v4 principles. CSS-first configuration, container queries, modern patterns, design token architecture. | Lisa, use "tailwind-patterns" for this task. |  |
| tdd-workflow | enabled_and_configured | Test-Driven Development workflow principles. RED-GREEN-REFACTOR cycle. | Lisa, use "tdd-workflow" for this task. |  |
| templates | enabled_and_configured | Project scaffolding templates for new applications. Use when creating new projects from scratch. Contains 12 templates for various tech stacks. | Lisa, use "templates" for this task. |  |
| testing-patterns | enabled_and_configured | Testing patterns and principles. Unit, integration, mocking strategies. | Lisa, use "testing-patterns" for this task. |  |
| things-mac | disabled_but_installed | Manage Things 3 via the `things` CLI on macOS (add/update projects+todos via URL scheme; read/search/list from the local Things database). Use when a user asks OpenClaw to add a task to Things, list inbox/today/upcoming, search tasks, or inspect projects/areas/tags. | Lisa, use "things-mac" for this task. | bins:1, os:1 |
| tmux | disabled_but_installed | Remote-control tmux sessions for interactive CLIs by sending keystrokes and scraping pane output. | Lisa, use "tmux" for this task. |  |
| trello | enabled_but_unavailable_missing_prereqs | Manage Trello boards, lists, and cards via the Trello REST API. | Lisa, use "trello" for this task. | env:2 |
| typescript-coding | enabled_and_configured | TypeScript and JavaScript coding skill for web development, MCP server creation, Node.js applications, and frontend development. Includes React, Next.js, and modern tooling. | Lisa, use "typescript-coding" for this task. |  |
| video-frames | enabled_and_configured | Extract frames or short clips from videos using ffmpeg. | Lisa, use "video-frames" for this task. |  |
| voice-call | disabled_but_installed | Start voice calls via the OpenClaw voice-call plugin. | Lisa, use "voice-call" for this task. | config:1 |
| vr-ar | enabled_and_configured | VR/AR development principles. Comfort, interaction, performance requirements. | Lisa, use "vr-ar" for this task. |  |
| vulnerability-scanner | enabled_and_configured | Advanced vulnerability analysis principles. OWASP 2025, Supply Chain Security, attack surface mapping, risk prioritization. | Lisa, use "vulnerability-scanner" for this task. |  |
| wacli | disabled_but_installed | Send WhatsApp messages to other people or search/sync WhatsApp history via the wacli CLI (not for normal user chats). | Lisa, use "wacli" for this task. | bins:1 |
| weather | enabled_and_configured | Get current weather and forecasts (no API key required). | Lisa, use "weather" for this task. |  |
| web-design-guidelines | enabled_and_configured | Review UI code for Web Interface Guidelines compliance. Use when asked to "review my UI", "check accessibility", "audit design", "review UX", or "check my site against best practices". | Lisa, use "web-design-guidelines" for this task. |  |
| web-games | disabled_but_installed | Web browser game development principles. Framework selection, WebGPU, optimization, PWA. | Lisa, use "web-games" for this task. |  |
| web-research | enabled_and_configured | Run Brave-powered web, image, video, and news research through mcporter. | Lisa, use "web-research" for this task. |  |
| webapp-testing | enabled_and_configured | Web application testing principles. E2E, Playwright, deep audit strategies. | Lisa, use "webapp-testing" for this task. |  |

