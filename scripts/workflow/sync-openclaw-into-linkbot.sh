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
repo_git fetch "${SOURCE_REMOTE_NAME}" "${SOURCE_REMOTE_BRANCH}" "${SOURCE_REMOTE_METADATA_BRANCH}"

NEW_FORK_SHA="$(repo_git rev-parse "${SOURCE_REMOTE_NAME}/${SOURCE_REMOTE_BRANCH}")"
PREVIOUS_IMPORTED_SHA="$(read_state_var LAST_LINKBOT_IMPORTED_FORK_SHA)"
PREVIOUS_IMPORTED_AT="$(read_state_var LAST_LINKBOT_IMPORTED_AT_UTC)"

if [[ -z "${PREVIOUS_IMPORTED_SHA}" ]]; then
  PREVIOUS_IMPORTED_SHA="$(read_state_var LAST_SYNCED_OPENCLAW_SHA)"
fi

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

SOURCE_EXPORT_DIR="${TMP_DIR}/source"
OVERRIDE_BACKUP_DIR="${TMP_DIR}/overrides"
SOURCE_SNAPSHOT_FILE="${TMP_DIR}/source-upstream-snapshot.env"
VERIFIED_AT_UTC="$(utc_now)"

mkdir -p "${SOURCE_EXPORT_DIR}"

repo_git show "${SOURCE_REMOTE_NAME}/${SOURCE_REMOTE_METADATA_BRANCH}:${SOURCE_REMOTE_SNAPSHOT_FILE}" > "${SOURCE_SNAPSHOT_FILE}"
# shellcheck disable=SC1090
source "${SOURCE_SNAPSHOT_FILE}"

[[ "${LAST_UPSTREAM_STATUS:-}" == "exact" ]] || die "Source snapshot status is not exact."
[[ "${LAST_UPSTREAM_MIRROR_BRANCH:-}" == "${SOURCE_REMOTE_BRANCH}" ]] || die "Source mirror branch mismatch."
[[ "${LAST_UPSTREAM_MIRROR_SHA:-}" == "${NEW_FORK_SHA}" ]] || die "Source mirror SHA does not match fetched fork branch."
[[ "${LAST_UPSTREAM_SOURCE_SHA:-}" == "${NEW_FORK_SHA}" ]] || die "Source upstream SHA does not match exact mirror SHA."

UPSTREAM_SHA="${LAST_UPSTREAM_SOURCE_SHA}"
UPSTREAM_SNAPSHOT_AT_UTC="${LAST_UPSTREAM_CHECKED_AT_UTC}"
IMPORTED_FORK_SHA="${PREVIOUS_IMPORTED_SHA}"
IMPORTED_AT_UTC="${PREVIOUS_IMPORTED_AT}"
SYNC_STATUS="up_to_date"

if [[ -n "${PREVIOUS_IMPORTED_SHA}" && "${PREVIOUS_IMPORTED_SHA}" == "${NEW_FORK_SHA}" ]]; then
  write_linkbot_sync_state "${NEW_FORK_SHA}" "${UPSTREAM_SHA}" "${UPSTREAM_SNAPSHOT_AT_UTC}" "${VERIFIED_AT_UTC}" "${PREVIOUS_IMPORTED_SHA}" "${PREVIOUS_IMPORTED_AT}" "${SYNC_STATUS}"
  repo_git add -A -- "$(state_file_rel)"
  if repo_git diff --cached --quiet; then
    log_info "Linkbot already matches ${SOURCE_REMOTE_NAME}/${SOURCE_REMOTE_BRANCH} at ${NEW_FORK_SHA}."
    exit 0
  fi
  repo_git commit -m "ci: record verified openclaw snapshot ${UPSTREAM_SHA:0:12}"
  repo_git pull --rebase origin "${MAIN_BRANCH}"
  repo_git push origin "${MAIN_BRANCH}"
  log_info "Recorded verified snapshot without source import."
  exit 0
fi

log_info "Exporting ${SOURCE_REMOTE_NAME}/${SOURCE_REMOTE_BRANCH} (${NEW_FORK_SHA})"
repo_git archive --format=tar "${NEW_FORK_SHA}" | tar -xf - -C "${SOURCE_EXPORT_DIR}"

read_overrides
backup_overrides "${OVERRIDE_BACKUP_DIR}"

log_info "Syncing ${BOT_PATH} from ${SOURCE_REMOTE_NAME}/${SOURCE_REMOTE_BRANCH}"
rsync -a --delete \
  --exclude '.git' \
  "${SOURCE_EXPORT_DIR}/" "${BOT_DIR_ABS}/"
restore_overrides "${OVERRIDE_BACKUP_DIR}"
IMPORTED_FORK_SHA="${NEW_FORK_SHA}"
IMPORTED_AT_UTC="${VERIFIED_AT_UTC}"
SYNC_STATUS="imported"
write_linkbot_sync_state "${NEW_FORK_SHA}" "${UPSTREAM_SHA}" "${UPSTREAM_SNAPSHOT_AT_UTC}" "${VERIFIED_AT_UTC}" "${IMPORTED_FORK_SHA}" "${IMPORTED_AT_UTC}" "${SYNC_STATUS}"

repo_git add -A -- "$(bot_path_rel)" "$(state_file_rel)"

if repo_git diff --cached --quiet; then
  log_info "No material changes after sync."
  exit 0
fi

run_validation_suite 0

COMMIT_MESSAGE="chore(sync): import openclaw snapshot ${UPSTREAM_SHA:0:12}"
repo_git commit -m "${COMMIT_MESSAGE}"
repo_git pull --rebase origin "${MAIN_BRANCH}"
repo_git push origin "${MAIN_BRANCH}"

log_info "Completed sync to ${MAIN_BRANCH} at upstream snapshot ${UPSTREAM_SHA}"
