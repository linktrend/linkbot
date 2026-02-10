# Sourced Skills for LiNKbot

**Date**: 2026-02-09  
**Status**: Sourced and Documented (NOT YET SCANNED)  
**Total Skills**: 6 core skills

---

## ⚠️ IMPORTANT: Security Scanning Required

**DO NOT use these skills until they have been scanned with Cisco Skill Scanner!**

All skills must be scanned for:
- Security vulnerabilities
- Credential leaks
- Malicious code
- API key exposure
- Privacy violations

See: `/Users/linktrend/Projects/LiNKbot/docs/guides/SKILLS_INSTALLATION.md`

---

## Skills Overview

| Skill | Source | License | Sub-Agent Support | Priority |
|-------|--------|---------|-------------------|----------|
| [Task Management](#1-task-management) | OpenClaw Community | MIT | ✅ Yes | HIGH |
| [Financial Calculator](#2-financial-calculator) | Community Python | MIT | ✅ Yes | HIGH |
| [Meeting Scheduler](#3-meeting-scheduler) | Google Calendar API | MIT | ✅ Yes | HIGH |
| [Python Coding](#4-python-coding) | MarcusJellinghaus MCP | MIT | ✅ Yes | CRITICAL |
| [TypeScript Coding](#5-typescript-coding) | GitHub/Microsoft | MIT | ✅ Yes | CRITICAL |
| [Document Generator](#6-document-generator) | Anthropic Official | Proprietary | ✅ Yes | HIGH |

---

## 1. Task Management

### Overview
Comprehensive task and project management with to-do lists, project tracking, GTD workflows, and GitHub issues integration.

### Source Information
- **Primary Sources**: 
  - OpenClaw skills: pndr, idea-coach, quests
  - GTD (Getting Things Done) methodology
  - Community task management patterns
- **Repository**: Multiple community sources aggregated
- **License**: MIT
- **Last Updated**: 2026-02-09

### Key Features
- Create, read, update, delete tasks
- Project organization with tags and priorities
- GTD, Kanban, Eisenhower Matrix workflows
- GitHub issues integration
- Export to Markdown, JSON, iCal
- Due dates and reminders

### Sub-Agent Support
**YES** - Strongly supported:
- Inbox Agent: Captures and categorizes new tasks
- Prioritization Agent: Assigns priorities
- Scheduling Agent: Sets due dates
- Execution Agent: Tracks progress
- Review Agent: Analyzes completed tasks

### Configuration Required
```bash
export TASKS_DB_PATH=~/.openclaw/data/tasks.json
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxx  # Optional
```

### Environment Variables
- `TASKS_DB_PATH`: Path to local tasks database (default: `~/.openclaw/data/tasks.json`)
- `GITHUB_TOKEN`: GitHub token for issues integration (optional)

### OpenClaw Model Routing
```json
{
  "task-management": "claude-3-5-haiku-20241022",
  "task-management:prioritization": "claude-3-5-sonnet-20241022"
}
```

### Security Notes
- Task database stored locally (no cloud sync by default)
- GitHub token required only for issues integration
- No hardcoded secrets

### Installation Path
`/Users/linktrend/Projects/LiNKbot/skills/task-management/`

### Documentation
See: `skills/task-management/SKILL.md`

---

## 2. Financial Calculator

### Overview
Advanced financial calculations for ROI analysis, budget planning, financial projections, NPV, IRR, payback period, and cash flow analysis.

### Source Information
- **Primary Sources**:
  - Python cashflows library
  - numpy-financial
  - Community financial calculators
- **Repository**: Multiple Python financial libraries
- **License**: MIT
- **Last Updated**: 2026-02-09

### Key Features
- ROI (Return on Investment) calculations
- NPV (Net Present Value) and IRR (Internal Rate of Return)
- Budget planning and variance analysis
- Financial projections and forecasting
- Break-even analysis
- Loan/mortgage calculations
- Scenario analysis (best/worst/likely cases)

### Sub-Agent Support
**YES** - Strongly supported:
- Data Collection Agent: Gathers financial data
- Calculation Agent: Performs complex calculations
- Analysis Agent: Interprets results
- Reporting Agent: Generates formatted reports
- Scenario Agent: Runs what-if analyses

### Configuration Required
```bash
export DEFAULT_CURRENCY=USD
export DEFAULT_TAX_RATE=0.21
export DEFAULT_DISCOUNT_RATE=0.10
```

### Environment Variables
- `DEFAULT_CURRENCY`: Default currency for calculations (default: USD)
- `DEFAULT_TAX_RATE`: Default tax rate (decimal, default: 0.21)
- `DEFAULT_DISCOUNT_RATE`: Default discount rate for NPV (default: 0.10)

### OpenClaw Model Routing
```json
{
  "financial-calculator": "claude-3-5-haiku-20241022",
  "financial-calculator:analysis": "claude-3-5-sonnet-20241022"
}
```

### Security Notes
- All calculations performed locally
- No external API calls
- Financial data should be encrypted at rest
- No hardcoded secrets

### Installation Path
`/Users/linktrend/Projects/LiNKbot/skills/financial-calculator/`

### Documentation
See: `skills/financial-calculator/SKILL.md`

---

## 3. Meeting Scheduler

### Overview
Meeting and calendar scheduling with timezone support, availability checking, conflict resolution, and Google Calendar integration.

### Source Information
- **Primary Sources**:
  - Google Calendar API
  - Community calendar skills
  - Scheduling best practices
- **Repository**: Google Calendar API Python library
- **License**: MIT
- **Last Updated**: 2026-02-09

### Key Features
- Find available meeting times across calendars
- Schedule meetings with automatic invitations
- Manage recurring meetings
- Timezone conversions
- Conflict resolution
- Integration with Google Calendar
- Virtual meeting links (Google Meet, Zoom)

### Sub-Agent Support
**YES** - Strongly supported:
- Availability Agent: Checks calendars for free times
- Preference Agent: Considers participant preferences
- Optimization Agent: Finds optimal meeting times
- Invitation Agent: Sends invitations and reminders
- Conflict Agent: Resolves scheduling conflicts

### Configuration Required
```bash
export GOOGLE_CALENDAR_CREDENTIALS=~/.openclaw/credentials/google-calendar.json
export DEFAULT_TIMEZONE=America/New_York
export CALENDAR_ID=primary
```

### Environment Variables
- `GOOGLE_CALENDAR_CREDENTIALS`: Path to Google Calendar OAuth credentials (required)
- `DEFAULT_TIMEZONE`: Default timezone for scheduling (default: America/New_York)
- `CALENDAR_ID`: Primary calendar ID (default: primary)

### OpenClaw Model Routing
```json
{
  "meeting-scheduler": "claude-3-5-haiku-20241022",
  "meeting-scheduler:conflict-resolution": "claude-3-5-sonnet-20241022"
}
```

### Security Notes
- OAuth credentials stored securely in `~/.openclaw/credentials/`
- Use service accounts for automated scheduling
- Limited calendar access permissions
- No hardcoded secrets

### Installation Path
`/Users/linktrend/Projects/LiNKbot/skills/meeting-scheduler/`

### Documentation
See: `skills/meeting-scheduler/SKILL.md`

---

## 4. Python Coding

### Overview
Python coding skill for file operations, code generation, script creation, and data processing using MCP filesystem server.

### Source Information
- **Primary Source**: https://github.com/MarcusJellinghaus/mcp_server_filesystem
- **Stars**: 42
- **License**: MIT
- **Language**: Python
- **Last Updated**: 2026-02

### Key Features
- Secure file operations (read, write, edit, delete)
- Code generation and refactoring
- Data processing and analysis
- Script automation
- Path validation and security controls
- Structured logging

### Sub-Agent Support
**YES** - Strongly supported:
- Code Review Agent: Analyzes Python code
- Testing Agent: Generates and runs unit tests
- Refactoring Agent: Improves code structure
- Documentation Agent: Creates docstrings and README
- Data Analysis Agent: Processes files and generates insights

### Configuration Required
```bash
export PROJECT_DIRECTORY=/Users/username/projects
```

### Environment Variables
- `PROJECT_DIRECTORY`: Root directory for file operations (REQUIRED - security boundary)
- `LOG_LEVEL`: Logging level (default: INFO)
- `MAX_FILE_SIZE`: Maximum file size in bytes (default: 10485760)

### OpenClaw Model Routing
```json
{
  "python-coding": "claude-3-5-haiku-20241022"
}
```

### Security Notes
- All operations contained within PROJECT_DIRECTORY
- Path validation prevents directory traversal
- Atomic file writes prevent corruption
- Structured logging tracks all operations
- **CRITICAL**: Always set PROJECT_DIRECTORY

### Installation Path
`/Users/linktrend/Projects/LiNKbot/skills/python-coding/`

### Documentation
See: `skills/python-coding/SKILL.md`

---

## 5. TypeScript Coding

### Overview
TypeScript and JavaScript coding skill for web development, MCP server creation, Node.js applications, React, Next.js, and modern tooling.

### Source Information
- **Primary Sources**:
  - https://github.com/github/github-mcp-server
  - https://github.com/stephencme/create-mcp-ts
  - https://github.com/microsoft/TypeScript
  - VoltAgent TypeScript skills
- **License**: MIT
- **Last Updated**: 2026-02-09

### Key Features
- TypeScript/JavaScript code generation
- React and Next.js development
- MCP server creation (zero-config with create-mcp-ts)
- Node.js backend development
- GitHub repository operations
- Modern tooling (ESLint, Prettier, TypeScript compiler)

### Sub-Agent Support
**YES** - Strongly supported:
- Frontend Agent: React component development
- Backend Agent: API route creation
- Testing Agent: Jest/Vitest test generation
- DevOps Agent: Docker and deployment configs
- Documentation Agent: TypeDoc and README generation

### Configuration Required
```bash
# Optional
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxx
export NODE_ENV=development
```

### Environment Variables
- `GITHUB_TOKEN`: GitHub personal access token (optional, for repo operations)
- `NODE_ENV`: Node environment (default: development)
- `API_BASE_URL`: API base URL (optional)
- `DATABASE_URL`: Database connection string (optional)

### OpenClaw Model Routing
```json
{
  "typescript-coding": "claude-3-5-haiku-20241022",
  "typescript-coding:complex": "claude-3-5-sonnet-20241022"
}
```

### Security Notes
- Never commit secrets to git
- Use environment variables for API keys
- Validate all user inputs
- Implement CORS restrictions
- Use npm audit regularly
- No hardcoded secrets

### Installation Path
`/Users/linktrend/Projects/LiNKbot/skills/typescript-coding/`

### Documentation
See: `skills/typescript-coding/SKILL.md`

---

## 6. Document Generator

### Overview
Create, edit, and analyze professional documents including Word (.docx), Excel (.xlsx), PowerPoint (.pptx), and PDF files.

### Source Information
- **Primary Source**: https://github.com/anthropics/skills
- **Stars**: 66,000+
- **License**: Proprietary (Anthropic) - Source-available for reference
- **Last Updated**: 2026-02-09

### Key Features
- **PDF**: Extract text, create PDFs, handle forms, add watermarks, OCR
- **DOCX**: Create and edit Word documents with formatting, tables, images
- **XLSX**: Create and manipulate Excel spreadsheets with formulas and charts
- **PPTX**: Create and edit PowerPoint presentations
- All operations use local libraries (no cloud services)

### Sub-Agent Support
**YES** - Strongly supported:
- PDF Operations Agent: Specialized PDF processing
- DOCX Creation Agent: Document formatting
- Spreadsheet Agent: Data analysis and calculations
- Template Agent: Generate templates across formats

### Configuration Required
```bash
# No environment variables required
# All operations use local libraries
```

### Environment Variables
- None required (all local operations)

### OpenClaw Model Routing
```json
{
  "document-generator": "claude-3-5-haiku-20241022"
}
```

### Security Notes
- All document processing happens locally
- No data sent to external services
- Validate user-provided content
- Ensure proper file path sandboxing
- No hardcoded secrets

### Installation Path
`/Users/linktrend/Projects/LiNKbot/skills/document-generator/`

### Documentation
See: `skills/document-generator/SKILL.md`

---

## Installation Instructions

### Prerequisites

1. **Python 3.8+** and **Node.js 22+** installed
2. **OpenClaw** installed and configured
3. **Cisco Skill Scanner** installed (for security scanning)

### Installation Steps

```bash
# 1. Navigate to skills directory
cd /Users/linktrend/Projects/LiNKbot/skills

# 2. Install Python dependencies
pip install -r requirements.txt

# 3. Install Node.js dependencies
npm install -g typescript docx

# 4. Set up environment variables
export PROJECT_DIRECTORY=/Users/linktrend/Projects
export TASKS_DB_PATH=~/.openclaw/data/tasks.json
export GOOGLE_CALENDAR_CREDENTIALS=~/.openclaw/credentials/google-calendar.json
export DEFAULT_TIMEZONE=America/New_York

# 5. Create data directories
mkdir -p ~/.openclaw/data/{tasks,financial-models,calendar}
mkdir -p ~/.openclaw/credentials

# 6. MANDATORY: Scan all skills with Cisco Skill Scanner
cd /Users/linktrend/Projects/LiNKbot/skills/skill-scanner
python scan_skill.py ../task-management
python scan_skill.py ../financial-calculator
python scan_skill.py ../meeting-scheduler
python scan_skill.py ../python-coding
python scan_skill.py ../typescript-coding
python scan_skill.py ../document-generator

# 7. Review scan results (MANDATORY before use)
cat ~/.openclaw/data/skill-scanner/reports/*.json

# 8. Only proceed if all scans are clean
# If any critical issues found, DO NOT USE that skill
```

### Python Dependencies

```bash
# Task Management
pip install python-dateutil pyyaml PyGithub

# Financial Calculator
pip install numpy pandas numpy-financial openpyxl matplotlib

# Meeting Scheduler
pip install google-auth google-auth-oauthlib google-api-python-client pytz icalendar

# Python Coding (MCP Server)
# Clone: git clone https://github.com/MarcusJellinghaus/mcp_server_filesystem.git
pip install -r mcp_server_filesystem/requirements.txt

# Document Generator
pip install pypdf pdfplumber reportlab python-docx openpyxl python-pptx
```

### Node.js Dependencies

```bash
# TypeScript Coding
npm install -g typescript ts-node tsx prettier eslint
npm install -g @github/github-mcp-server

# Document Generator (advanced DOCX)
npm install -g docx
```

---

## Security Scanning Results

**Status**: ⚠️ NOT YET SCANNED

All skills MUST be scanned before use. Update this section after scanning:

### Scan Results Template

```markdown
### [Skill Name]
- **Scan Date**: YYYY-MM-DD
- **Scanner Version**: X.X.X
- **Result**: ✅ PASS / ⚠️ WARNING / ❌ FAIL
- **Critical Issues**: 0
- **Warnings**: 0
- **Notes**: [Any relevant notes]
- **Approved By**: [Your name]
- **Approved Date**: YYYY-MM-DD
```

---

## OpenClaw Configuration

Add to `~/.openclaw/config.json`:

```json
{
  "skills": {
    "task-management": {
      "enabled": true,
      "model": "claude-3-5-haiku-20241022",
      "config": {
        "database": "~/.openclaw/data/tasks.json"
      }
    },
    "financial-calculator": {
      "enabled": true,
      "model": "claude-3-5-haiku-20241022",
      "config": {
        "currency": "USD",
        "tax_rate": 0.21
      }
    },
    "meeting-scheduler": {
      "enabled": true,
      "model": "claude-3-5-haiku-20241022",
      "config": {
        "calendar_service": "google",
        "timezone": "America/New_York"
      }
    },
    "python-coding": {
      "enabled": true,
      "model": "claude-3-5-haiku-20241022",
      "config": {
        "project_directory": "/Users/linktrend/Projects"
      }
    },
    "typescript-coding": {
      "enabled": true,
      "model": "claude-3-5-haiku-20241022",
      "config": {
        "typescript_version": "5.x"
      }
    },
    "document-generator": {
      "enabled": true,
      "model": "claude-3-5-haiku-20241022"
    }
  },
  "mcpServers": {
    "filesystem": {
      "command": "python",
      "args": [
        "/path/to/mcp_server_filesystem/server.py",
        "--project-dir",
        "/Users/linktrend/Projects"
      ]
    },
    "github": {
      "command": "npx",
      "args": ["@github/github-mcp-server"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

---

## Cost Optimization

All skills configured to use **claude-3-5-haiku-20241022** for cost efficiency:
- **Cost**: $0.80/million input tokens, $4.00/million output tokens
- **Performance**: Fast responses for standard operations
- **Fallback**: claude-3-5-sonnet-20241022 for complex reasoning

### Estimated Monthly Costs

Based on typical usage patterns:

| Skill | Estimated Monthly Calls | Input Tokens | Output Tokens | Cost/Month |
|-------|-------------------------|--------------|---------------|------------|
| Task Management | 200 | 100K | 50K | $0.28 |
| Financial Calculator | 50 | 150K | 100K | $0.52 |
| Meeting Scheduler | 100 | 80K | 40K | $0.22 |
| Python Coding | 300 | 500K | 300K | $1.60 |
| TypeScript Coding | 300 | 500K | 300K | $1.60 |
| Document Generator | 50 | 200K | 150K | $0.76 |
| **TOTAL** | **1,000** | **1.53M** | **940K** | **$4.98** |

**Note**: Actual costs will vary based on usage. Monitor via OpenClaw dashboard.

---

## Next Steps

1. ✅ **COMPLETED**: Skills sourced and documented
2. ⚠️ **PENDING**: Install Cisco Skill Scanner
3. ⚠️ **PENDING**: Scan all skills for security issues
4. ⚠️ **PENDING**: Review scan results
5. ⚠️ **PENDING**: Install dependencies
6. ⚠️ **PENDING**: Configure environment variables
7. ⚠️ **PENDING**: Test each skill individually
8. ⚠️ **PENDING**: Deploy to VPS
9. ⚠️ **PENDING**: Monitor usage and costs

---

## References

### Official Documentation
- OpenClaw Skills: https://docs.clawd.bot/tools/skills
- ClawHub Registry: https://clawdhub.com/skills
- Anthropic Skills: https://github.com/anthropics/skills
- Agent Skills Standard: https://agentskills.io

### Source Repositories
- Python MCP Filesystem: https://github.com/MarcusJellinghaus/mcp_server_filesystem
- GitHub MCP Server: https://github.com/github/github-mcp-server
- Anthropic Skills: https://github.com/anthropics/skills
- VoltAgent Skills: https://github.com/VoltAgent/awesome-agent-skills
- OpenClaw Skills: https://github.com/openclaw/skills

### Community Resources
- VoltAgent Awesome Skills: https://github.com/VoltAgent/awesome-agent-skills
- Awesome OpenClaw Skills: https://github.com/VoltAgent/awesome-openclaw-skills
- Agent Skills Specification: https://docs.anthropic.com/en/docs/agents-and-tools/agent-skills

---

**Last Updated**: 2026-02-09  
**Maintained By**: LiNKbot Project  
**Status**: Ready for Security Scanning
