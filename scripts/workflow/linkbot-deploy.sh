#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

usage() {
  cat <<'EOF'
Usage: linkbot deploy [options]

Options:
  --message "<commit message>"  Custom commit message
  --skip-tests                  Skip test step (build/install still run unless disabled in config)
  --no-push                     Do not push branch/main
  --no-deploy                   Do not run deployment after merge
  --help                        Show this help
EOF
}

COMMIT_MESSAGE=""
SKIP_TESTS=0
NO_PUSH=0
NO_DEPLOY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --message)
      [[ $# -ge 2 ]] || die "--message requires a value"
      COMMIT_MESSAGE="$2"
      shift 2
      ;;
    --skip-tests)
      SKIP_TESTS=1
      shift
      ;;
    --no-push)
      NO_PUSH=1
      shift
      ;;
    --no-deploy)
      NO_DEPLOY=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

load_workflow_config
ensure_repo_root
require_command git
require_command bash

if [[ "${NO_PUSH}" == "1" ]]; then
  AUTO_PUSH_BRANCH=0
  AUTO_PUSH_MAIN=0
fi

if [[ "${NO_DEPLOY}" == "1" ]]; then
  AUTO_DEPLOY=0
fi

TS="$(ts_now)"
CURRENT_BRANCH="$(repo_git branch --show-current)"
WORK_BRANCH="${CURRENT_BRANCH}"

if [[ "${CURRENT_BRANCH}" == "${MAIN_BRANCH}" ]]; then
  WORK_BRANCH="${DEPLOY_BRANCH_PREFIX}-${TS}"
  log_info "Creating deployment branch ${WORK_BRANCH} from ${MAIN_BRANCH}"
  repo_git checkout -b "${WORK_BRANCH}"
else
  log_info "Using current branch ${CURRENT_BRANCH} for deployment workflow"
fi

repo_git add -A

if ! repo_git diff --cached --quiet; then
  if [[ -z "${COMMIT_MESSAGE}" ]]; then
    COMMIT_MESSAGE="chore(deploy): automated linkbot deploy ${TS}"
  fi
  repo_git commit -m "${COMMIT_MESSAGE}"
  log_info "Created commit on ${WORK_BRANCH}"
else
  log_info "No staged changes to commit."
fi

run_validation_suite "${SKIP_TESTS}"

repo_git fetch origin "${MAIN_BRANCH}"

AHEAD_COUNT="$(repo_git rev-list --count "origin/${MAIN_BRANCH}..${WORK_BRANCH}")"
if [[ "${AHEAD_COUNT}" -eq 0 ]]; then
  log_warn "Branch ${WORK_BRANCH} has no commits ahead of origin/${MAIN_BRANCH}."
  if [[ "${AUTO_DEPLOY}" == "1" ]]; then
    git_checkout_main_and_update
    deploy_bot
    log_info "Completed linkbot deploy workflow (deploy-only path)."
    exit 0
  fi
  die "Nothing to merge or deploy."
fi

if [[ "${AUTO_PUSH_BRANCH}" == "1" ]]; then
  repo_git push -u origin "${WORK_BRANCH}"
fi

if [[ "${AUTO_MERGE_TO_MAIN}" == "1" ]]; then
  promote_branch_to_main "${WORK_BRANCH}"
fi

if [[ "${AUTO_DEPLOY}" == "1" ]]; then
  deploy_bot
fi

log_info "Completed linkbot deploy workflow."

