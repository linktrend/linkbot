# Antigravity Kit - Skills Library

**Source:** [Google Labs Antigravity Kit](https://github.com/linktrend/antigravity-kit)  
**Scanned:** February 11, 2026  
**Security Status:** ✅ All approved (100% pass rate)  
**Total Skills:** 37

---

## About Antigravity Skills

Professional-grade AI skills from Google Labs' Antigravity Kit. All skills have passed comprehensive security scanning and are ready for use in the LiNKbot ecosystem.

**Security Validation:**
- ✅ Cisco Skill Scanner
- ✅ Semgrep SAST
- ✅ TruffleHog secrets detection
- ✅ Provenance verification
- Risk Score: 0/100 (all skills)

---

## Skills by Category

### Architecture & Patterns (4 skills)

- **api-patterns/** - RESTful API design patterns
- **architecture/** - Software architecture patterns
- **python-patterns/** - Python design patterns
- **nodejs-best-practices/** - Node.js best practices

### Frontend Development (5 skills)

- **frontend-design/** - UI/UX design patterns
- **nextjs-react-expert/** - Next.js & React expertise
- **tailwind-patterns/** - Tailwind CSS patterns
- **web-design-guidelines/** - Web design standards
- **mobile-design/** - Mobile UI/UX patterns

### Backend & Database (4 skills)

- **database-design/** - Database schema design
- **server-management/** - Server administration
- **deployment-procedures/** - Deployment workflows
- **performance-profiling/** - Performance analysis

### Testing & Quality (4 skills)

- **tdd-workflow/** - Test-driven development
- **testing-patterns/** - Testing strategies
- **webapp-testing/** - Web app testing
- **code-review-checklist/** - Code review standards

### Security & DevOps (4 skills)

- **red-team-tactics/** - Security testing
- **vulnerability-scanner/** - Vulnerability detection
- **lint-and-validate/** - Code linting & validation
- **systematic-debugging/** - Debugging methodologies

### Development Tools (7 skills)

- **bash-linux/** - Bash scripting & Linux
- **powershell-windows/** - PowerShell scripting
- **rust-pro/** - Rust programming
- **app-builder/** - Application scaffolding
- **parallel-agents/** - Multi-agent workflows
- **mcp-builder/** - MCP server development
- **intelligent-routing/** - Request routing

### Documentation & Planning (5 skills)

- **documentation-templates/** - Documentation standards
- **plan-writing/** - Project planning
- **brainstorming/** - Ideation techniques
- **behavioral-modes/** - AI behavior modes
- **clean-code/** - Clean code principles

### Specialized (4 skills)

- **game-development/** - Game dev patterns
- **i18n-localization/** - Internationalization
- **geo-fundamentals/** - Geospatial programming
- **seo-fundamentals/** - SEO optimization

---

## Usage

All skills are **disabled by default**. To enable a skill:

1. Add to `bots/<bot-name>/config/<bot-name>/openclaw.json`:

```json
{
  "skills": {
    "antigravity": {
      "api-patterns": { "enabled": true },
      "database-design": { "enabled": true }
    }
  }
}
```

2. The bot will automatically load enabled skills on startup.

---

## Skill Structure

Each skill directory contains:

```
skill-name/
├── SKILL.md          # Skill documentation
├── examples/         # Example implementations
├── templates/        # Code templates
└── guidelines/       # Best practice guidelines
```

---

## Security Scan Results

- **Scan Date:** 2026-02-11
- **Items Scanned:** 37 skills
- **Approved:** 37 (100%)
- **Rejected:** 0
- **Borderline:** 0
- **Cost:** $0.00 (4-layer scan)

**Detailed Reports:** `skills/scan-reports/antigravity/`

---

## Deployment

Skills are deployed selectively based on bot configuration. Only enabled skills are copied to deployment targets (VPS, Mac Mini, etc.).

**Deployment Script:** `scripts/deploy-bot.sh`

---

## Support

- **Source Repository:** https://github.com/linktrend/antigravity-kit
- **Security Reports:** `/skills/scan-reports/antigravity/`
- **Documentation:** Each skill has a `SKILL.md` file

**Note:** Abandoned Google Labs project. Use at your own discretion.
