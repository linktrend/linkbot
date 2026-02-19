# Automated Workflow Commands

This document defines the two operator commands for LiNKbot automation:

- `openclaw synced`
- `linkbot deploy`

Both commands run from this repository and execute a controlled Git -> validate -> merge -> deploy pipeline.

## Command 1: `openclaw synced`

Use this after you manually sync `linktrend/openclaw` with `openclaw/openclaw`.

What it does:

1. Verifies local working tree is clean.
2. Fetches `openclaw-fork/main` (configured in `config/automation/workflow.env`).
3. Creates a sync branch from `main`.
4. Imports upstream tree into `bots/lisa`.
5. Preserves LiNKbot-specific overrides listed in `config/automation/openclaw-overrides.paths`.
6. Scans overlap between upstream-changed files and override paths ("override collisions").
7. Writes a sync report to `logs/workflows/openclaw-sync-<timestamp>.md`.
8. Runs install/build/test checks.
9. Commits, merges into `main`, pushes, and deploys.

## Command 2: `linkbot deploy`

Use this after local development changes.

What it does:

1. Stages and commits local changes (on current branch, or auto-creates one when on `main`).
2. Runs install/build/test checks.
3. Rebases onto latest `origin/main`.
4. Fast-forward merges into local `main`.
5. Pushes `main`.
6. Deploys via `scripts/deploy-bot.sh`.

## Configuration

Primary config file:

- `config/automation/workflow.env`

Override preservation file:

- `config/automation/openclaw-overrides.paths`

Last synced upstream SHA state:

- `config/automation/openclaw-sync-state.env`

## One-time command setup

You can run wrappers directly from repo root:

```bash
./openclaw synced
./linkbot deploy
```

To enable exact shell commands (`openclaw synced`, `linkbot deploy`) in IDE terminals:

```bash
./scripts/workflow/install-shell-commands.sh
source ~/.linkbot-workflow-commands.sh
```

## Safety defaults and best practices

1. Keep deployment server repo clean; do not hotfix on server.
2. Keep `main` deployable at all times.
3. Preserve only intentional overrides in `openclaw-overrides.paths`.
4. Review the generated sync report before/after deployment.
5. Use `--skip-tests` only for emergency situations.

## Optional flags

Both commands support:

- `--message "<commit message>"`
- `--skip-tests`
- `--no-push`
- `--no-deploy`

