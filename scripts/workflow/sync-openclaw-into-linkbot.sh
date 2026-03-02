#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

load_workflow_config
ensure_repo_root
require_command git
require_command rsync
require_command tar
require_command bash

repo_git checkout "${MAIN_BRANCH}"
repo_git pull --ff-only origin "${MAIN_BRANCH}"

ensure_remote_exists "${SOURCE_REMOTE_NAME}" "${SOURCE_REMOTE_URL}"
repo_git fetch "${SOURCE_REMOTE_NAME}" "${SOURCE_REMOTE_BRANCH}"

NEW_SHA="$(repo_git rev-parse "${SOURCE_REMOTE_NAME}/${SOURCE_REMOTE_BRANCH}")"
LAST_SHA="$(read_last_synced_sha)"

if [[ -n "${LAST_SHA}" && "${LAST_SHA}" == "${NEW_SHA}" ]]; then
  log_info "No new ${SOURCE_REMOTE_NAME}/${SOURCE_REMOTE_BRANCH} commit to import."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

SOURCE_EXPORT_DIR="${TMP_DIR}/source"
OVERRIDE_BACKUP_DIR="${TMP_DIR}/overrides"

mkdir -p "${SOURCE_EXPORT_DIR}"

log_info "Exporting ${SOURCE_REMOTE_NAME}/${SOURCE_REMOTE_BRANCH} (${NEW_SHA})"
repo_git archive --format=tar "${NEW_SHA}" | tar -xf - -C "${SOURCE_EXPORT_DIR}"

read_overrides
backup_overrides "${OVERRIDE_BACKUP_DIR}"

log_info "Syncing ${BOT_PATH} from ${SOURCE_REMOTE_NAME}/${SOURCE_REMOTE_BRANCH}"
rsync -a --delete \
  --exclude '.git' \
  --exclude '.github/workflows/sync-upstream.yml' \
  "${SOURCE_EXPORT_DIR}/" "${BOT_DIR_ABS}/"
restore_overrides "${OVERRIDE_BACKUP_DIR}"
write_last_synced_sha "${NEW_SHA}"

repo_git add -A -- "$(bot_path_rel)" "$(state_file_rel)"

if repo_git diff --cached --quiet; then
  log_info "No material changes after sync."
  exit 0
fi

run_validation_suite 0

COMMIT_MESSAGE="chore(sync): import linktrend/openclaw ${NEW_SHA:0:12}"
repo_git commit -m "${COMMIT_MESSAGE}"
repo_git pull --rebase origin "${MAIN_BRANCH}"
repo_git push origin "${MAIN_BRANCH}"

log_info "Completed sync to ${MAIN_BRANCH} at ${NEW_SHA}"
