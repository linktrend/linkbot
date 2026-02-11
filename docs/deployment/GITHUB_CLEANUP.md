# GitHub Repository Cleanup

## Action Required: Delete Deprecated Repository

### Repository to Delete

**Name:** `linktrend/lisa-linkbot`  
**URL:** https://github.com/linktrend/lisa-linkbot  
**Status:** ⚠️ **Deprecated** - No longer in use

### Why Delete?

This repository was Lisa's standalone repository when we used a Git submodule architecture. After the monorepo migration (February 11, 2026), all of Lisa's code is now integrated into the main `linktrend/linkbot` repository at `bots/lisa/`.

Keeping this repository will cause confusion:
- Developers might clone the wrong repo
- Updates might be pushed to the wrong location
- It's unclear which is the "source of truth"

### How to Delete

1. **Go to Repository Settings:**
   - Navigate to: https://github.com/linktrend/lisa-linkbot/settings

2. **Scroll to Danger Zone:**
   - At the bottom of the settings page

3. **Click "Delete this repository"**

4. **Confirm deletion:**
   - Type: `linktrend/lisa-linkbot`
   - Click "I understand the consequences, delete this repository"

### Backup

Before deleting, confirm you have a local backup (already created):
```bash
~/Projects/LiNKbot-backup-20260211-160219.tar.gz
```

The backup contains the full history of the repository, so nothing is permanently lost.

### After Deletion

**Single Source of Truth:**  
`linktrend/linkbot` - Main monorepo containing:
- `bots/lisa/` - Lisa's code
- `bots/bob/` - Future: Bob's code
- `bots/kate/` - Future: Kate's code
- `skills/` - Centralized skills library
- `agents/` - Centralized agents library

**Deployments:**  
All future deployments will use:
```bash
./scripts/deploy-bot.sh <bot-name> <target>
```

**Git Workflow:**  
```bash
# Development
cd ~/Projects/LiNKbot
git checkout -b feature/my-feature
# ... make changes ...
git add .
git commit -m "Add feature"
git push origin feature/my-feature

# Deployment
git checkout main
git pull origin main
./scripts/deploy-bot.sh lisa vps
```

---

**Migration Date:** February 11, 2026  
**Deprecated Repository:** linktrend/lisa-linkbot  
**Active Repository:** linktrend/linkbot
