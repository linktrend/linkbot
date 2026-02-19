#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

usage() {
  cat <<'EOF'
Usage: openclaw synced [options]

Options:
  --message "<commit message>"  Custom commit message
  --skip-tests                  Skip test step (build/install still run unless disabled in config)
  --no-push                     Do not push sync branch or main
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
ensure_clean_worktree
require_command git
require_command rsync
require_command tar
require_command bash

if [[ "${NO_PUSH}" == "1" ]]; then
  AUTO_PUSH_BRANCH=0
  AUTO_PUSH_MAIN=0
fi

if [[ "${NO_DEPLOY}" == "1" ]]; then
  AUTO_DEPLOY=0
fi

ensure_remote_exists "${SOURCE_REMOTE_NAME}" "${SOURCE_REMOTE_URL}"
repo_git fetch "${SOURCE_REMOTE_NAME}" "${SOURCE_REMOTE_BRANCH}"

NEW_SHA="$(repo_git rev-parse "${SOURCE_REMOTE_NAME}/${SOURCE_REMOTE_BRANCH}")"
LAST_SHA="$(read_last_synced_sha)"

if [[ -n "${LAST_SHA}" && "${LAST_SHA}" == "${NEW_SHA}" ]]; then
  log_info "No new upstream commit to import (already at ${NEW_SHA})."
  exit 0
fi

TS="$(ts_now)"
SYNC_BRANCH="${SYNC_BRANCH_PREFIX}-${TS}"
REPORT_FILE="${REPO_ROOT}/logs/workflows/openclaw-sync-${TS}.md"

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

SOURCE_EXPORT_DIR="${TMP_DIR}/source"
OVERRIDE_BACKUP_DIR="${TMP_DIR}/overrides"
UPSTREAM_CHANGED_FILE="${TMP_DIR}/upstream-changed.txt"
OVERRIDE_COLLISIONS_FILE="${TMP_DIR}/override-collisions.txt"

mkdir -p "${SOURCE_EXPORT_DIR}"

create_branch_from_main "${SYNC_BRANCH}"

log_info "Exporting ${SOURCE_REMOTE_NAME}/${SOURCE_REMOTE_BRANCH} (${NEW_SHA})"
repo_git archive --format=tar "${NEW_SHA}" | tar -xf - -C "${SOURCE_EXPORT_DIR}"

if [[ -n "${LAST_SHA}" ]] && repo_git cat-file -e "${LAST_SHA}^{commit}" 2>/dev/null; then
  repo_git diff --name-only "${LAST_SHA}" "${NEW_SHA}" > "${UPSTREAM_CHANGED_FILE}"
else
  repo_git ls-tree -r --name-only "${NEW_SHA}" > "${UPSTREAM_CHANGED_FILE}"
fi

read_overrides
backup_overrides "${OVERRIDE_BACKUP_DIR}"

: > "${OVERRIDE_COLLISIONS_FILE}"
while IFS= read -r changed || [[ -n "${changed}" ]]; do
  [[ -n "${changed}" ]] || continue
  for override in "${OVERRIDES[@]}"; do
    if path_matches_override "${changed}" "${override}"; then
      printf '%s\n' "${changed}" >> "${OVERRIDE_COLLISIONS_FILE}"
      break
    fi
  done
done < "${UPSTREAM_CHANGED_FILE}"

sort -u "${OVERRIDE_COLLISIONS_FILE}" -o "${OVERRIDE_COLLISIONS_FILE}"

log_info "Syncing upstream tree into ${BOT_PATH}"
rsync -a --delete --exclude '.git' "${SOURCE_EXPORT_DIR}/" "${BOT_DIR_ABS}/"
restore_overrides "${OVERRIDE_BACKUP_DIR}"
write_last_synced_sha "${NEW_SHA}"

ensure_logs_dir
{
  printf '# OpenClaw Sync Report\n\n'
  printf -- '- Timestamp (UTC): %s\n' "$(utc_now)"
  printf -- '- Last synced SHA: %s\n' "${LAST_SHA:-<none>}"
  printf -- '- New synced SHA: %s\n' "${NEW_SHA}"
  printf -- '- Branch: %s\n\n' "${SYNC_BRANCH}"

  printf '## Upstream changed files\n\n'
  printf 'Count: %s\n\n' "$(wc -l < "${UPSTREAM_CHANGED_FILE}" | tr -d ' ')"
  head -n 200 "${UPSTREAM_CHANGED_FILE}" | sed 's/^/- /'
  printf '\n'

  printf '## Override collisions\n\n'
  if [[ -s "${OVERRIDE_COLLISIONS_FILE}" ]]; then
    printf 'Upstream changed files that are also marked as LiNKbot overrides:\n\n'
    sed 's/^/- /' "${OVERRIDE_COLLISIONS_FILE}"
  else
    printf 'No override collisions detected.\n'
  fi
  printf '\n'

  printf '## Working tree diffstat\n\n'
  repo_git diff --stat -- "$(bot_path_rel)" "$(state_file_rel)"
  printf '\n'
} > "${REPORT_FILE}"

if [[ -s "${OVERRIDE_COLLISIONS_FILE}" ]]; then
  log_warn "Override collisions detected. Preserving local override files."
  log_warn "Review ${REPORT_FILE} for details."
else
  log_info "No override collisions detected."
fi

repo_git add -A -- "$(bot_path_rel)" "$(state_file_rel)"

if [[ -z "${COMMIT_MESSAGE}" ]]; then
  COMMIT_MESSAGE="chore(sync): import openclaw ${NEW_SHA:0:12} into ${BOT_PATH}"
fi

if commit_if_staged "${COMMIT_MESSAGE}"; then
  log_info "Created sync commit on ${SYNC_BRANCH}"
else
  log_info "No material changes after sync. Exiting without commit."
  repo_git checkout "${MAIN_BRANCH}"
  repo_git branch -D "${SYNC_BRANCH}" >/dev/null 2>&1 || true
  exit 0
fi

run_validation_suite "${SKIP_TESTS}"

if [[ "${AUTO_PUSH_BRANCH}" == "1" ]]; then
  repo_git push -u origin "${SYNC_BRANCH}"
fi

if [[ "${AUTO_MERGE_TO_MAIN}" == "1" ]]; then
  promote_branch_to_main "${SYNC_BRANCH}"
fi

if [[ "${AUTO_DEPLOY}" == "1" ]]; then
  deploy_bot
fi

log_info "Completed openclaw synced workflow."
log_info "Diff/conflict report: ${REPORT_FILE}"

