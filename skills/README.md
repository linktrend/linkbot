# LiNKbot Skills Directory

**Last Updated**: 2026-02-09  
**Status**: Sourcing Complete ✅ | Scanning Pending ⚠️

---

## Quick Start

```bash
# 1. Read the completion report
cat SKILLS_SOURCING_COMPLETE.md

# 2. Review the master index
cat SOURCED_SKILLS.md

# 3. Check individual skills
ls -la */SKILL.md

# 4. ⚠️ MANDATORY: Scan skills before use
cd skill-scanner
python scan_skill.py ../task-management
```

---

## Directory Structure

```
/skills/
│
├── README.md                           # This file
├── SOURCED_SKILLS.md                   # Master index of all skills
├── SKILLS_SOURCING_COMPLETE.md         # Completion report
│
├── task-management/                    # To-do lists, project tracking
│   ├── SKILL.md                        # Full documentation
│   └── SKILL_INFO.md                   # Quick reference
│
├── financial-calculator/               # ROI, budgets, projections
│   ├── SKILL.md
│   └── SKILL_INFO.md
│
├── meeting-scheduler/                  # Calendar scheduling
│   ├── SKILL.md
│   └── SKILL_INFO.md
│
├── python-coding/                      # Python + MCP server
│   ├── SKILL.md
│   └── SKILL_INFO.md
│
├── typescript-coding/                  # TypeScript/JavaScript
│   ├── SKILL.md
│   └── SKILL_INFO.md
│
├── document-generator/                 # PDF, DOCX, XLSX, PPTX
│   ├── SKILL.md
│   └── SKILL_INFO.md
│
└── skill-scanner/                      # Cisco Skill Scanner
    └── [382MB of security tools]
```

---

## Skills Summary

| # | Skill | Size | License | Sub-Agent | Cost/Mo |
|---|-------|------|---------|-----------|---------|
| 1 | Task Management | 20KB | MIT | ✅ | $0.28 |
| 2 | Financial Calculator | 24KB | MIT | ✅ | $0.52 |
| 3 | Meeting Scheduler | 24KB | MIT | ✅ | $0.22 |
| 4 | Python Coding | 12KB | MIT | ✅ | $1.60 |
| 5 | TypeScript Coding | 16KB | MIT | ✅ | $1.60 |
| 6 | Document Generator | 12KB | Proprietary | ✅ | $0.76 |
| **TOTAL** | **6 skills** | **108KB** | **Mixed** | **All** | **$4.98** |

---

## Documentation Files

### Master Documents

- **SOURCED_SKILLS.md** (646 lines)
  - Comprehensive overview of all 6 skills
  - Installation instructions
  - Security analysis
  - Cost breakdown
  - Configuration examples

- **SKILLS_SOURCING_COMPLETE.md** (579 lines)
  - Executive summary
  - Completion report
  - Success metrics
  - Next steps checklist

### Individual Skills

Each skill has two files:

- **SKILL.md**: Complete technical documentation
  - Overview and features
  - Installation instructions
  - Usage examples with code
  - Sub-agent execution patterns
  - Configuration and environment variables
  - Security best practices
  - Troubleshooting guide
  - Source references

- **SKILL_INFO.md**: Quick reference card
  - Status indicators
  - Quick install commands
  - Environment variables
  - Cost estimates
  - Next steps

---

## Key Features

### 🤖 Sub-Agent Execution

**All 6 skills support multi-agent execution:**

```
Task Management:      Inbox → Prioritize → Schedule → Execute → Review
Financial Calculator: Collect → Calculate → Analyze → Report → Scenario
Meeting Scheduler:    Availability → Preference → Optimize → Invite → Resolve
Python Coding:        Review → Test → Refactor → Document → Analyze
TypeScript Coding:    Frontend → Backend → Test → DevOps → Document
Document Generator:   PDF → DOCX → Spreadsheet → Template
```

### 🔒 Security

- ✅ No hardcoded secrets
- ✅ Environment variables for sensitive data
- ✅ OAuth 2.0 for Google Calendar
- ✅ Path validation for file operations
- ✅ Local-first data storage
- ⚠️ **MANDATORY**: Security scanning required before use

### 💰 Cost Optimization

All skills configured for **claude-3-5-haiku-20241022**:
- Input: $0.80 per million tokens
- Output: $4.00 per million tokens
- Total: ~$4.98/month for 1,000 operations
- 85% cost savings vs claude-3-5-sonnet

### 🌐 Environment Variables

```bash
# Python Coding (REQUIRED)
export PROJECT_DIRECTORY=/Users/linktrend/Projects

# Task Management (optional)
export TASKS_DB_PATH=~/.openclaw/data/tasks.json
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxx

# Meeting Scheduler (required)
export GOOGLE_CALENDAR_CREDENTIALS=~/.openclaw/credentials/google-calendar.json
export DEFAULT_TIMEZONE=America/New_York
export CALENDAR_ID=primary

# Financial Calculator (optional)
export DEFAULT_CURRENCY=USD
export DEFAULT_TAX_RATE=0.21
export DEFAULT_DISCOUNT_RATE=0.10

# TypeScript Coding (optional)
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxx
export NODE_ENV=development
```

---

## Installation

### Prerequisites

- Python 3.8+
- Node.js 22+
- OpenClaw installed
- Cisco Skill Scanner installed

### Quick Install

```bash
# 1. Install Python dependencies
pip install python-dateutil pyyaml PyGithub numpy pandas numpy-financial \
    google-auth google-auth-oauthlib google-api-python-client pytz \
    pypdf pdfplumber reportlab python-docx openpyxl python-pptx

# 2. Install Node.js dependencies
npm install -g typescript ts-node tsx prettier eslint docx \
    @github/github-mcp-server

# 3. Create directories
mkdir -p ~/.openclaw/data/{tasks,financial-models,calendar}
mkdir -p ~/.openclaw/credentials

# 4. Set environment variables
export PROJECT_DIRECTORY=/Users/linktrend/Projects
export TASKS_DB_PATH=~/.openclaw/data/tasks.json

# 5. ⚠️ MANDATORY: Scan all skills
cd skill-scanner
python scan_skill.py ../task-management
python scan_skill.py ../financial-calculator
python scan_skill.py ../meeting-scheduler
python scan_skill.py ../python-coding
python scan_skill.py ../typescript-coding
python scan_skill.py ../document-generator

# 6. Review scan reports
cat ~/.openclaw/data/skill-scanner/reports/*.json

# 7. Only proceed if all scans pass
```

---

## Usage

### Task Management

```python
# Create a task
create_task(
    title="Deploy LiNKbot to VPS",
    priority="high",
    project="LiNKbot",
    tags=["deployment", "devops"],
    due_date="2026-02-15"
)

# List high-priority tasks
tasks = list_tasks(priority="high", status="todo")
```

### Financial Calculator

```python
# Calculate ROI
result = calculate_roi(
    initial_investment=10000,
    final_value=15000,
    time_period_years=2
)
print(f"ROI: {result['roi_percent']}%")

# Calculate NPV
npv = calculate_npv(0.10, [-100000, 30000, 35000, 40000, 45000])
print(f"NPV: ${npv:,.2f}")
```

### Meeting Scheduler

```python
# Find available slots
slots = find_available_slots(
    start_date=datetime.now(),
    end_date=datetime.now() + timedelta(days=7),
    duration_minutes=60
)

# Schedule a meeting
schedule_meeting(
    title="Team Sync",
    start_time=datetime(2026, 2, 15, 14, 0),
    duration_minutes=30,
    attendees=["team@example.com"]
)
```

### Python Coding (via MCP)

```python
# List files
{
  "tool": "list_directory",
  "arguments": {"path": "."}
}

# Read file
{
  "tool": "read_file",
  "arguments": {"path": "config.py"}
}

# Write file
{
  "tool": "write_file",
  "arguments": {
    "path": "script.py",
    "content": "print('Hello World')"
  }
}
```

---

## Security Scanning

### ⚠️ MANDATORY BEFORE USE

**All skills MUST be scanned with Cisco Skill Scanner:**

```bash
cd /Users/linktrend/Projects/LiNKbot/skills/skill-scanner

# Scan each skill
python scan_skill.py ../task-management
python scan_skill.py ../financial-calculator
python scan_skill.py ../meeting-scheduler
python scan_skill.py ../python-coding
python scan_skill.py ../typescript-coding
python scan_skill.py ../document-generator

# Review results
cat ~/.openclaw/data/skill-scanner/reports/task-management_*.json
```

### Security Checklist

- [ ] All 6 skills scanned
- [ ] No critical issues found
- [ ] Scan reports reviewed
- [ ] Results documented in SOURCED_SKILLS.md
- [ ] Skills approved for deployment

**DO NOT proceed without scanning!**

---

## Troubleshooting

### Skills Not Loading

```bash
# Check OpenClaw configuration
cat ~/.openclaw/config.json

# Verify environment variables
echo $PROJECT_DIRECTORY
echo $TASKS_DB_PATH
echo $GOOGLE_CALENDAR_CREDENTIALS

# Check skill directories
ls -la /Users/linktrend/Projects/LiNKbot/skills/*/SKILL.md
```

### MCP Server Not Starting

```bash
# Verify Python MCP server
cd /path/to/mcp_server_filesystem
python server.py --project-dir /tmp/test

# Check Node.js MCP server
npx @github/github-mcp-server --help
```

### Google Calendar Auth Issues

```bash
# Re-authenticate
cd /Users/linktrend/Projects/LiNKbot/scripts/google-workspace
./setup-oauth.sh

# Verify credentials
ls -la ~/.openclaw/credentials/google-calendar.json
```

---

## Support

### Documentation

- **Master Index**: `SOURCED_SKILLS.md`
- **Completion Report**: `SKILLS_SOURCING_COMPLETE.md`
- **Installation Guide**: `/docs/guides/SKILLS_INSTALLATION.md`
- **Quick Start**: `/START_HERE.md`

### External Resources

- OpenClaw Docs: https://docs.clawd.bot/tools/skills
- ClawHub: https://clawdhub.com/skills
- Anthropic Skills: https://github.com/anthropics/skills
- VoltAgent: https://github.com/VoltAgent/awesome-agent-skills
- MCP Spec: https://modelcontextprotocol.io

---

## Status

### ✅ Completed

- [x] Research skills from ClawHub, GitHub, VoltAgent
- [x] Document 6 core skills (SKILL.md files)
- [x] Create quick reference cards (SKILL_INFO.md)
- [x] Analyze sub-agent execution support
- [x] Configure OpenClaw model routing
- [x] Document security considerations
- [x] Calculate cost estimates
- [x] Create master index (SOURCED_SKILLS.md)
- [x] Create completion report

### ⚠️ Pending

- [ ] Install Cisco Skill Scanner
- [ ] Scan all 6 skills (MANDATORY)
- [ ] Review scan reports
- [ ] Install dependencies
- [ ] Configure environment variables
- [ ] Test skills locally
- [ ] Deploy to VPS

---

## License

Skills are licensed under various licenses:
- **Task Management**: MIT
- **Financial Calculator**: MIT
- **Meeting Scheduler**: MIT
- **Python Coding**: MIT
- **TypeScript Coding**: MIT
- **Document Generator**: Proprietary (Anthropic) - Source-available

See individual SKILL.md files for details.

---

## Contributing

This is a private project. Skills are sourced from:
- ClawHub community
- GitHub open source projects
- Anthropic official skills
- VoltAgent curated collections

---

**Last Updated**: 2026-02-09  
**Status**: Sourcing Complete ✅ | Scanning Pending ⚠️  
**Next Phase**: Security Scanning (MANDATORY)
