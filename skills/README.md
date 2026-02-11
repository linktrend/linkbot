# Skills Library

Central repository for all bot skills in the LiNKbot ecosystem.

## Directory Structure

### `shared/`
**Type 1: Universal Skills** - Used by every bot regardless of specialization
- Research & Deep Search
- Memory Management
- Systematic Reflection
- Core utilities needed by all bots

### `coding/`
**Type 3: Shared by Coding Bots** - Common skills for all coding-related bots
- Version Control Lifecycle Management
- Systematic Debugging & Error Handling
- Code Review & Security Auditing
- Used by frontend, backend, and full-stack bots

### `specialized/`
**Type 2: Bot-Specific Skills** - Specialized skills for individual bots
- UI & UX Design (frontend bots)
- Database Management (backend bots)
- SEO Optimization (marketing bots)
- Each bot may have unique skills here

## Adding New Skills

1. Determine skill type (universal, coding, or specialized)
2. Create folder in appropriate directory: `skills/{type}/{skill-name}/`
3. Add `SKILL.md` with required frontmatter
4. Include any scripts/tools the skill needs
5. Update bot's `openclaw.json` to enable the skill

## Deployment

Skills are deployed selectively based on each bot's configuration. Only enabled skills are copied to deployment targets (VPS, Mac Mini, etc.).
