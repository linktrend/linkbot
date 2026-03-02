# Git Strategy: Main Branch + Daily Sync

**Document Version:** 3.0
**Last Updated:** March 2, 2026
**Status:** Active

## Purpose

This document defines the active Git strategy for LiNKbot.

LiNKbot is a monorepo in `linktrend/linkbot`. OpenClaw upstream updates are synchronized automatically through GitHub Actions using a daily snapshot model, so local day-to-day work is just:

1. pull `main`
2. create or resume a task branch
3. push WIP before moving machines
4. merge tested work into `main`
5. deploy from `main`

## Source of Truth

- Primary repo: `https://github.com/linktrend/linkbot`
- Primary branch: `main`
- Deploy script: `scripts/deploy-bot.sh`
- Deploy target config: `scripts/deploy-config.sh`

If documentation conflicts with `scripts/deploy-bot.sh`, the script is authoritative for deployment behavior.

## Automated Sync Chain

OpenClaw updates no longer require a manual operator command in this repo.

The active automation chain is:

1. `openclaw/openclaw` is mirrored daily into `linktrend/openclaw:upstream-main`
2. `linktrend/openclaw:main` records the verified snapshot metadata for that mirror
3. `linktrend/linkbot` imports daily from `linktrend/openclaw:upstream-main`
4. `linktrend/linkbot` records the imported fork SHA, upstream SHA, and snapshot timestamps in `config/automation/openclaw-sync-state.env`
5. LiNKbot-specific overrides listed in `config/automation/openclaw-overrides.paths` are restored
6. install, build, and test run before the sync commit is pushed

Because the sync happens in GitHub, `openclaw synced` is retired.

### Snapshot timing

The daily cutoff is designed for your 8:00 AM Taipei check:

1. fork mirror snapshot: `07:05` Taipei time
2. linkbot import snapshot: `07:35` Taipei time

This keeps the snapshot age under 24 hours when you ask each morning at `08:00` Taipei time.

## Non-Negotiable Rules

1. All production deployments come from `main`.
2. Do not do feature work directly on `main`.
3. Remote deployment repos must be clean.
4. Remote repo updates are fast-forward only.
5. No manual hotfix edits on server working trees.
6. Do not commit secrets.
7. Push branch state before moving between machines.

## Required Local Workflow

### 1. Start from current `main`

```bash
cd /Users/linktrend/Projects/LiNKbot
git checkout main
git pull --ff-only origin main
```

### 2. Create a task branch

```bash
git checkout -b your-branch-name
git push -u origin your-branch-name
```

### 3. Resume work on any machine

```bash
git checkout your-branch-name
git pull --ff-only origin your-branch-name
```

### 4. Save progress before moving machines

```bash
git add .
git commit -m "wip: saving progress"
git push
```

### 5. Finish the task

When the task is ready:

1. push the final branch state
2. merge the task branch into `main`
3. push `main`
4. delete the task branch locally and on GitHub

## Deployment Procedure

For remote targets (`vps`, `vps1`, `vps2`), `scripts/deploy-bot.sh` executes this sequence:

1. Validate bot and config paths.
2. Connect to the remote host from `scripts/deploy-config.sh`.
3. If the remote repo exists:
   - fail if the working tree is dirty
   - run `git fetch origin main`
   - run `git pull --ff-only origin main`
4. If the remote repo does not exist:
   - clone `https://github.com/linktrend/linkbot.git`
5. Install dependencies with `pnpm install --frozen-lockfile`
6. Build with `pnpm build`
7. Sync runtime config and workspace templates
8. Refresh curated skills symlinks
9. Restart the `openclaw` service and print status

## Optional Local Helper

`linkbot deploy` remains available as a local convenience wrapper for:

1. staging and committing local changes
2. running validation
3. fast-forwarding the branch into `main`
4. pushing `main`
5. deploying

It is optional. The canonical workflow is still the explicit branch-based process above.

## Rollback Procedure

Rollback by Git history, not by editing server files:

```bash
git checkout main
git revert <bad-commit-sha>
git push origin main
./scripts/deploy-bot.sh lisa vps
```

## Related Docs

- `MONOREPO_COMPLETE.md`
- `docs/deployment/MONOREPO_MIGRATION.md`
- `docs/deployment/GITHUB_CLEANUP.md`
- `docs/deployment/AUTOMATED_WORKFLOW.md`
- `scripts/deploy-bot.sh`
