# Automated Workflow Commands

This document defines the operator workflow for LiNKbot across:

- two machines (`Mac Mini`, `MacBook`)
- multiple AI IDEs (`Cursor`, `Antigravity`, `Codex App`)
- the two automation commands defined in this repo:
  - `openclaw synced`
  - `linkbot deploy`

The workflow below is the standard operating procedure.

## Core Model

- GitHub is the source of truth.
- `main` is the stable integration and deployment branch.
- All feature work, bug fixes, and experiments start on a task branch.
- When moving between machines, always push current branch state before switching devices.
- `openclaw synced` is for importing updates from the synced `linktrend/openclaw` fork.
- `linkbot deploy` is for finishing local development work, promoting it to `main`, and deploying.

## Section 1: Task Initiation and Branch Creation

Do this on whichever machine you are starting from.

### 1. Sync `main`

Make sure local `main` is fully current before creating a task branch.

```bash
git checkout main
git pull origin main
```

### 2. Create a task branch

Use a short descriptive branch name.

Examples:

- `feat-auth-system`
- `fix-navbar-css`
- `test-ai-prompting`

```bash
git checkout -b your-branch-name
```

### 3. Publish the branch immediately

Push the new branch to GitHub right away so the other machine can see it.

```bash
git push -u origin your-branch-name
```

## Section 2: The Roaming Session Workflow

This is the repeatable loop for working across both machines.

### 2.1 Session Start: Pull first

Before writing code or asking any IDE agent to generate code:

```bash
git checkout your-branch-name
git pull origin your-branch-name
```

If dependencies changed on the other machine, install them before continuing.

Examples:

```bash
npm install
```

or

```bash
pip install -r requirements.txt
```

### 2.2 During development

Work normally in Cursor, Antigravity, or Codex.

If you follow the pull-first and push-before-you-move habits, cross-machine conflict risk stays low.

### 2.3 Session End: WIP push

When pausing work or changing machines:

```bash
git add .
git commit -m "wip: saving progress"
git push
```

Do not switch machines until the push succeeds.

## Section 3: Task Completion and Cleanup

When the task is fully tested and ready:

1. Push the final task-branch state.
2. Merge the task branch into `main`.
3. Push `main`.
4. Delete the task branch locally and on GitHub.

If using repo automation, `linkbot deploy` handles the promote-to-`main` and deploy steps.

## Section 4: When to Use `openclaw synced`

Use `openclaw synced` only after you have manually synced:

- `openclaw/openclaw` -> `linktrend/openclaw`

This command is not for normal feature work. It is specifically for pulling updated OpenClaw framework code from the synced fork into this repo.

### Recommended procedure

1. Make sure the repo is clean.
2. Start from `main`.
3. Run:

```bash
openclaw synced
```

### What it does

1. Verifies local working tree is clean.
2. Fetches `linktrend/openclaw`.
3. Detects whether there is a new upstream commit to import.
4. Imports the updated OpenClaw tree into `bots/lisa`.
5. Preserves LiNKbot-specific overrides from `config/automation/openclaw-overrides.paths`.
6. Writes a sync report to `logs/workflows/openclaw-sync-<timestamp>.md`.
7. Runs install, build, and test steps.
8. Commits the imported changes.
9. Merges them into `main`.
10. Pushes `main`.
11. Deploys, unless `--no-deploy` is used.

### Typical use

```bash
git checkout main
git pull origin main
openclaw synced
```

If you want to import into GitHub but not deploy yet:

```bash
openclaw synced --no-deploy
```

## Section 5: When to Use `linkbot deploy`

Use `linkbot deploy` after local development work on a task branch is complete and you want that work promoted to `main` and deployed.

This is the finalization command, not the roaming-session command.

For normal in-progress work, keep using:

```bash
git add .
git commit -m "wip: saving progress"
git push
```

Use `linkbot deploy` when the branch is ready to land.

### Recommended procedure

1. Finish development on your task branch.
2. Make sure the working tree contains the final intended changes.
3. Run:

```bash
linkbot deploy
```

### What it does

1. Stages and commits local changes.
2. Runs install, build, and test steps.
3. Rebases the current branch onto the latest `origin/main`.
4. Fast-forward merges the work into local `main`.
5. Pushes `main`.
6. Deploys via `scripts/deploy-bot.sh`.

### Typical use

```bash
git checkout your-branch-name
git pull origin your-branch-name
linkbot deploy
```

## Section 6: One-Time Command Setup

You can run wrappers directly from repo root:

```bash
./openclaw synced
./linkbot deploy
```

To enable exact shell commands in IDE terminals:

```bash
./scripts/workflow/install-shell-commands.sh
source ~/.linkbot-workflow-commands.sh
```

## Section 7: Optional Flags

Both commands support:

- `--message "<commit message>"`
- `--skip-tests`
- `--no-push`
- `--no-deploy`

## Section 8: Safety Rules

1. Do not do normal feature work on `main`.
2. Do not move between machines without pushing your current branch.
3. Do not hotfix server working trees manually.
4. Keep `main` deployable.
5. Preserve only intentional LiNKbot-specific overrides in `config/automation/openclaw-overrides.paths`.
6. Review generated sync reports when importing from OpenClaw.

## Section 9: Short Version

### Normal feature work

```bash
git checkout main
git pull origin main
git checkout -b your-branch-name
git push -u origin your-branch-name
```

Then on every machine switch:

```bash
git checkout your-branch-name
git pull origin your-branch-name
```

And when pausing:

```bash
git add .
git commit -m "wip: saving progress"
git push
```

When finished:

```bash
linkbot deploy
```

### OpenClaw upstream import

After manually syncing the fork:

```bash
git checkout main
git pull origin main
openclaw synced
```

