# Automated Workflow

This document defines the standard LiNKbot workflow across:

- two machines (`Mac Mini`, `MacBook`)
- multiple AI IDEs (`Cursor`, `Antigravity`, `Codex App`)
- one primary repo: `linktrend/linkbot`

## Core Model

- GitHub is the source of truth.
- `main` is the stable integration branch and the deployment branch.
- All local work starts on a task branch.
- Move between machines only after pushing your current task branch.
- OpenClaw imports are automated in GitHub; `openclaw synced` is retired.

## Automated Daily Sync

The OpenClaw update chain is now automatic:

1. `linktrend/openclaw:upstream-main` is mirrored daily from `openclaw/openclaw:main`.
2. `linktrend/openclaw:main` records the verified mirror snapshot metadata.
3. `linktrend/linkbot` syncs daily from `linktrend/openclaw:upstream-main`.
4. The `linkbot` sync updates `bots/lisa`, preserves LiNKbot-specific overrides from `config/automation/openclaw-overrides.paths`, records snapshot metadata in `config/automation/openclaw-sync-state.env`, runs install/build/test, and pushes to `main` if validation passes.

No manual upstream-import command is part of the normal operator workflow anymore.

### Snapshot timing

The automation is scheduled so you can ask at `08:00` Taipei time whether `linkbot` has the latest OpenClaw updates for the current snapshot day:

1. fork snapshot target: `07:05` Taipei time
2. linkbot snapshot target: `07:35` Taipei time

The operational definition of "latest" is therefore:

- the most recent verified upstream snapshot no older than 24 hours
- successfully imported into `linktrend/linkbot`

## Task Start

On whichever machine you are using:

```bash
git checkout main
git pull --ff-only origin main
git checkout -b your-branch-name
git push -u origin your-branch-name
```

Use short descriptive branch names such as:

- `feat-auth-system`
- `fix-navbar-css`
- `test-ai-prompting`

## Session Start

Before writing code or asking an IDE agent to make changes:

```bash
git checkout your-branch-name
git pull --ff-only origin your-branch-name
```

If dependencies changed on the other machine, install them before continuing.

## During Development

Work normally on the task branch. Since you are the only developer, conflict risk stays low if you keep the branch pushed before moving machines.

## Session End

When pausing work or moving to the other machine:

```bash
git add .
git commit -m "wip: saving progress"
git push
```

Do not switch machines until the push succeeds.

## Task Completion

When a task is ready:

1. Push the final task-branch state.
2. Merge the task branch into `main`.
3. Push `main`.
4. Delete the task branch locally and on GitHub.

You can do the merge through GitHub, your IDE, or local Git commands.

## Deployment

Deployments still come from `main` only.

Manual deployment:

```bash
git checkout main
git pull --ff-only origin main
./scripts/deploy-bot.sh lisa vps
```

Optional local helper:

```bash
linkbot deploy
```

`linkbot deploy` is a convenience wrapper for staging, validating, fast-forwarding to `main`, pushing, and deploying. It is optional; the branch-based workflow above is the canonical process.

## One-Time Command Setup

You can run the local wrapper directly from repo root:

```bash
./linkbot deploy
```

To enable the shell command in IDE terminals:

```bash
./scripts/workflow/install-shell-commands.sh
source ~/.linkbot-workflow-commands.sh
```

## Safety Rules

1. Do not do normal development work on `main`.
2. Do not move between machines without pushing your current branch.
3. Do not hotfix server working trees manually.
4. Keep `main` deployable.
5. Preserve only intentional LiNKbot-specific overrides in `config/automation/openclaw-overrides.paths`.
