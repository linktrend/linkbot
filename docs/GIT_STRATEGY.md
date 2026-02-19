# Git Strategy: Monorepo + Mainline Deploy

**Document Version:** 2.0  
**Last Updated:** February 19, 2026  
**Status:** Active (Current Strategy)

---

## Purpose

This document is the canonical Git workflow for LiNKbot.

Current architecture is a **single monorepo** (`linktrend/linkbot`) with deployment from `main`.  
The older "Fork -> Configure -> Deploy" model (with separate nested OpenClaw repos) was retired during the monorepo migration on February 11, 2026.

---

## Source of Truth

- **Primary repo:** `https://github.com/linktrend/linkbot`
- **Primary branch:** `main`
- **Deploy script:** `scripts/deploy-bot.sh`
- **Deploy target config:** `scripts/deploy-config.sh`

If any documentation conflicts with script behavior, **`scripts/deploy-bot.sh` is authoritative for deployment execution**.

---

## Repository Model (Current)

All bot code, skills, agents, scripts, and docs live in one repository.

```text
LiNKbot/
|-- bots/
|   `-- lisa/                  # Tracked in this repo (no nested .git)
|-- skills/                    # Shared and curated skill sets
|-- agents/                    # Agent packs
|-- scripts/
|   |-- deploy-bot.sh          # Canonical deployment procedure
|   `-- deploy-config.sh       # Target hosts and paths
`-- docs/
```

There are no active submodules for bot source in this strategy.

---

## Non-Negotiable Rules (Must Follow)

1. **All production deployments come from `main`.**
2. **Do not deploy from feature branches.**
3. **Remote deployment repo must be clean.**  
   `deploy-bot.sh` fails if `git status --porcelain` is not empty on target.
4. **Remote updates are fast-forward only.**  
   `deploy-bot.sh` uses `git fetch origin main` + `git pull --ff-only origin main`.
5. **No manual hotfix edits on server working trees.**  
   Fixes must be committed to Git, merged to `main`, then redeployed.
6. **Do not commit secrets.**  
   Keep credentials in approved runtime locations/env files, not in Git.

---

## Required Day-to-Day Workflow

### 1) Start from an up-to-date `main`

```bash
cd /Users/linktrend/Projects/LiNKbot
git checkout main
git pull --ff-only origin main
```

### 2) Create a feature branch

```bash
git checkout -b feature/<short-description>
```

### 3) Make and validate changes locally

Run relevant checks before pushing (build/tests/lint as applicable to changed scope).

### 4) Commit and push branch

```bash
git add <files>
git commit -m "<clear, scoped message>"
git push -u origin feature/<short-description>
```

### 5) Merge to `main`

Use PR review flow when available. After merge:

```bash
git checkout main
git pull --ff-only origin main
```

### 6) Deploy from `main` only

```bash
./scripts/deploy-bot.sh lisa vps
```

---

## Deployment Procedure (Must Follow)

For remote targets (`vps`, `vps1`, `vps2`), `scripts/deploy-bot.sh` executes this sequence:

1. Validate bot/config paths in monorepo.
2. Connect to remote host defined in `scripts/deploy-config.sh`.
3. If remote repo exists:
   - Fail if remote working tree is dirty.
   - Run `git fetch origin main`.
   - Run `git pull --ff-only origin main`.
4. If remote repo does not exist:
   - Clone `https://github.com/linktrend/linkbot.git` to target path.
5. Build bot (`npm ci`, `npm run build`).
6. Sync runtime config and workspace templates.
7. Refresh curated skills symlinks.
8. Restart `openclaw` systemd service and print status.

This guarantees deployed code is an auditable `main` commit.

---

## Rollback Procedure

Rollback by Git history, not ad-hoc server edits:

1. Revert offending commit(s) on a branch.
2. Merge revert to `main`.
3. Redeploy with `./scripts/deploy-bot.sh <bot> <target>`.

If emergency rollback is required immediately:

```bash
git checkout main
git revert <bad-commit-sha>
git push origin main
./scripts/deploy-bot.sh lisa vps
```

---

## Multi-Bot Expansion in Monorepo

To add another bot:

1. Create `bots/<bot-name>/`.
2. Add bot config at `bots/<bot-name>/config/<bot-name>/openclaw.json`.
3. Commit changes in this same repository.
4. Deploy via:

```bash
./scripts/deploy-bot.sh <bot-name> <target>
```

No separate per-bot source repository is required in this strategy.

---

## Troubleshooting

### Remote deploy fails with "repo has local changes"

Cause: manual edits or drift on server.

Action:
1. Inspect remote diff.
2. Preserve any needed change by committing to Git locally.
3. Reset remote deployment repo to clean state through approved ops process.
4. Redeploy from `main`.

### `--ff-only` pull fails

Cause: remote/local branch divergence.

Action:
1. Ensure intended commit is merged on `origin/main`.
2. Bring remote repo back to expected `main` lineage.
3. Redeploy.

---

## Related Docs

- `MONOREPO_COMPLETE.md`
- `docs/deployment/MONOREPO_MIGRATION.md`
- `docs/deployment/GITHUB_CLEANUP.md`
- `docs/deployment/AUTOMATED_WORKFLOW.md`
- `scripts/deploy-bot.sh`

---

## Changelog

| Date | Version | Changes |
|------|---------|---------|
| 2026-02-19 | 2.0 | Replaced legacy fork-based strategy with active monorepo + mainline deploy procedure |
| 2026-02-07 | 1.0 | Initial fork-based strategy (retired) |
