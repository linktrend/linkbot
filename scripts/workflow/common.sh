#!/usr/bin/env bash
set -euo pipefail

WORKFLOW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${WORKFLOW_DIR}/../.." && pwd)"

WORKFLOW_CONFIG_FILE="${REPO_ROOT}/config/automation/workflow.env"
OVERRIDES_FILE="${REPO_ROOT}/config/automation/openclaw-overrides.paths"
STATE_FILE="${REPO_ROOT}/config/automation/openclaw-sync-state.env"

log_info() {
  printf '[INFO] %s\n' "$*"
}

log_warn() {
  printf '[WARN] %s\n' "$*" >&2
}

log_error() {
  printf '[ERROR] %s\n' "$*" >&2
}

die() {
  log_error "$*"
  exit 1
}

require_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || die "Required command not found: $cmd"
}

load_workflow_config() {
  [[ -f "${WORKFLOW_CONFIG_FILE}" ]] || die "Missing config file: ${WORKFLOW_CONFIG_FILE}"
  # shellcheck disable=SC1090
  source "${WORKFLOW_CONFIG_FILE}"

  : "${BOT_NAME:=lisa}"
  : "${BOT_PATH:=bots/${BOT_NAME}}"
  : "${MAIN_BRANCH:=main}"
  : "${SOURCE_REMOTE_NAME:=openclaw-fork}"
  : "${SOURCE_REMOTE_URL:=https://github.com/linktrend/openclaw.git}"
  : "${SOURCE_REMOTE_BRANCH:=upstream-main}"
  : "${SOURCE_REMOTE_METADATA_BRANCH:=main}"
  : "${SOURCE_REMOTE_SNAPSHOT_FILE:=.sync/upstream-snapshot.env}"
  : "${SYNC_BRANCH_PREFIX:=automation/openclaw-sync}"
  : "${DEPLOY_BRANCH_PREFIX:=automation/linkbot-deploy}"
  : "${DEPLOY_TARGET:=vps}"
  : "${RUN_INSTALL:=1}"
  : "${INSTALL_COMMAND:=pnpm install --frozen-lockfile}"
  : "${RUN_BUILD:=1}"
  : "${BUILD_COMMAND:=pnpm build}"
  : "${RUN_TESTS:=1}"
  : "${TEST_COMMAND:=pnpm test}"
  : "${RUN_EXTRA_CHECKS:=0}"
  : "${EXTRA_CHECKS_COMMAND:=}"
  : "${AUTO_PUSH_BRANCH:=1}"
  : "${AUTO_MERGE_TO_MAIN:=1}"
  : "${AUTO_PUSH_MAIN:=1}"
  : "${AUTO_DEPLOY:=1}"

  BOT_DIR_ABS="${REPO_ROOT}/${BOT_PATH}"
  [[ -d "${BOT_DIR_ABS}" ]] || die "Bot path not found: ${BOT_DIR_ABS}"
}

repo_git() {
  git -C "${REPO_ROOT}" "$@"
}

ensure_repo_root() {
  repo_git rev-parse --is-inside-work-tree >/dev/null
}

ensure_clean_worktree() {
  local status
  status="$(repo_git status --porcelain)"
  [[ -z "${status}" ]] || die "Working tree is not clean. Commit/stash changes first."
}

ensure_remote_exists() {
  local name="$1"
  local url="$2"

  if repo_git remote get-url "${name}" >/dev/null 2>&1; then
    local current
    current="$(repo_git remote get-url "${name}")"
    if [[ "${current}" != "${url}" ]]; then
      log_warn "Remote ${name} URL differs from config. Updating to ${url}"
      repo_git remote set-url "${name}" "${url}"
    fi
  else
    log_info "Adding remote ${name} -> ${url}"
    repo_git remote add "${name}" "${url}"
  fi
}

utc_now() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

ts_now() {
  date -u +"%Y%m%d-%H%M%S"
}

run_in_bot_dir() {
  local command="$1"
  (
    cd "${BOT_DIR_ABS}"
    bash -lc "${command}"
  )
}

run_validation_suite() {
  local skip_tests="${1:-0}"

  if [[ "${RUN_INSTALL}" == "1" ]]; then
    log_info "Running install step: ${INSTALL_COMMAND}"
    run_in_bot_dir "${INSTALL_COMMAND}"
  fi

  if [[ "${RUN_BUILD}" == "1" ]]; then
    log_info "Running build step: ${BUILD_COMMAND}"
    run_in_bot_dir "${BUILD_COMMAND}"
  fi

  if [[ "${RUN_TESTS}" == "1" && "${skip_tests}" != "1" ]]; then
    log_info "Running test step: ${TEST_COMMAND}"
    run_in_bot_dir "${TEST_COMMAND}"
  elif [[ "${RUN_TESTS}" == "1" && "${skip_tests}" == "1" ]]; then
    log_warn "Skipping tests by request."
  fi

  if [[ "${RUN_EXTRA_CHECKS}" == "1" && -n "${EXTRA_CHECKS_COMMAND}" ]]; then
    log_info "Running extra checks: ${EXTRA_CHECKS_COMMAND}"
    run_in_bot_dir "${EXTRA_CHECKS_COMMAND}"
  fi
}

git_checkout_main_and_update() {
  repo_git checkout "${MAIN_BRANCH}"
  repo_git pull --ff-only origin "${MAIN_BRANCH}"
}

create_branch_from_main() {
  local branch="$1"
  git_checkout_main_and_update
  repo_git checkout -b "${branch}"
}

read_state_var() {
  local key="$1"
  [[ -f "${STATE_FILE}" ]] || return 0
  awk -F= -v key="${key}" '$1 == key { print substr($0, index($0, "=") + 1) }' "${STATE_FILE}" | tail -n 1
}

write_linkbot_sync_state() {
  local fork_sha="$1"
  local upstream_sha="$2"
  local upstream_at_utc="$3"
  local verified_at_utc="$4"
  local imported_fork_sha="$5"
  local imported_at_utc="$6"
  local status="$7"
  mkdir -p "$(dirname "${STATE_FILE}")"
  cat >"${STATE_FILE}" <<EOF
# Snapshot verification for the daily linkbot import pipeline.
# Updated automatically by the linkbot sync workflow.

SNAPSHOT_MAX_AGE_HOURS=24
SOURCE_REMOTE_NAME=${SOURCE_REMOTE_NAME}
SOURCE_REMOTE_BRANCH=${SOURCE_REMOTE_BRANCH}
LAST_FORK_SNAPSHOT_SHA=${fork_sha}
LAST_UPSTREAM_SNAPSHOT_SHA=${upstream_sha}
LAST_UPSTREAM_SNAPSHOT_AT_UTC=${upstream_at_utc}
LAST_LINKBOT_VERIFIED_AT_UTC=${verified_at_utc}
LAST_LINKBOT_IMPORTED_FORK_SHA=${imported_fork_sha}
LAST_LINKBOT_IMPORTED_AT_UTC=${imported_at_utc}
LAST_LINKBOT_STATUS=${status}
EOF
}

read_overrides() {
  local line
  OVERRIDES=()
  [[ -f "${OVERRIDES_FILE}" ]] || die "Missing overrides file: ${OVERRIDES_FILE}"
  while IFS= read -r line || [[ -n "${line}" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "${line}" ]] && continue
    [[ "${line:0:1}" == "#" ]] && continue
    OVERRIDES+=("${line}")
  done < "${OVERRIDES_FILE}"
}

path_matches_override() {
  local changed="$1"
  local override="$2"
  if [[ "${override}" == */ ]]; then
    [[ "${changed}" == "${override}"* ]]
    return
  fi
  if [[ "${override}" == *"*"* || "${override}" == *"?"* ]]; then
    [[ "${changed}" == ${override} ]]
    return
  fi
  [[ "${changed}" == "${override}" || "${changed}" == "${override}/"* ]]
}

backup_overrides() {
  local backup_dir="$1"
  mkdir -p "${backup_dir}"
  local rel src dst
  BACKED_UP_OVERRIDES=()
  for rel in "${OVERRIDES[@]}"; do
    src="${BOT_DIR_ABS}/${rel}"
    [[ -e "${src}" ]] || continue
    dst="${backup_dir}/${rel}"
    mkdir -p "$(dirname "${dst}")"
    cp -a "${src}" "${dst}"
    BACKED_UP_OVERRIDES+=("${rel}")
  done
}

restore_overrides() {
  local backup_dir="$1"
  local rel src dst
  for rel in "${BACKED_UP_OVERRIDES[@]}"; do
    src="${backup_dir}/${rel}"
    dst="${BOT_DIR_ABS}/${rel}"
    [[ -e "${src}" ]] || continue
    rm -rf "${dst}"
    mkdir -p "$(dirname "${dst}")"
    cp -a "${src}" "${dst}"
  done
}

commit_if_staged() {
  local commit_message="$1"
  if repo_git diff --cached --quiet; then
    return 1
  fi
  repo_git commit -m "${commit_message}"
  return 0
}

promote_branch_to_main() {
  local branch="$1"

  repo_git fetch origin "${MAIN_BRANCH}"
  repo_git checkout "${branch}"
  repo_git rebase "origin/${MAIN_BRANCH}"

  repo_git checkout "${MAIN_BRANCH}"
  repo_git pull --ff-only origin "${MAIN_BRANCH}"
  repo_git merge --ff-only "${branch}"

  if [[ "${AUTO_PUSH_MAIN}" == "1" ]]; then
    repo_git push origin "${MAIN_BRANCH}"
  fi
}

deploy_bot() {
  local deploy_script="${REPO_ROOT}/scripts/deploy-bot.sh"
  [[ -x "${deploy_script}" ]] || die "Missing executable deploy script: ${deploy_script}"
  log_info "Deploying ${BOT_NAME} to ${DEPLOY_TARGET}"
  "${deploy_script}" "${BOT_NAME}" "${DEPLOY_TARGET}"
}

state_file_rel() {
  printf '%s' "${STATE_FILE#${REPO_ROOT}/}"
}

bot_path_rel() {
  printf '%s' "${BOT_PATH}"
}

ensure_logs_dir() {
  mkdir -p "${REPO_ROOT}/logs/workflows"
}
