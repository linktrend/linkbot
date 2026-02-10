#!/bin/bash

################################################################################
# Cisco Skill Scanner - Batch Scanning Script
#
# Description:
#   Batch scanning automation for multiple skills using Cisco Skill Scanner.
#   Scans all skills in the skills directory in parallel with configurable
#   concurrency limits. Generates individual reports and aggregate summary.
#
# Usage:
#   ./batch-scan.sh [options]
#
# Options:
#   -h, --help              Show this help message
#   -c, --concurrency N     Maximum concurrent scans (default: 4)
#   -s, --skills DIR        Skills directory to scan (default: ../skills)
#   -e, --exclude PATTERN   Exclude directories matching pattern (can use multiple)
#   --summary-only          Only show final summary, suppress individual scan output
#
# Output:
#   - Individual JSON reports per skill in scan-reports/
#   - Aggregate summary report: scan-reports/batch-summary-<timestamp>.txt
#   - Approved/Rejected logs updated
#
# Exit Codes:
#   0 - All scans completed (may have FAILs)
#   1 - One or more critical errors occurred
#
# Author: LiNKbot Automation
# Date: $(date +%Y-%m-%d)
################################################################################

set -o pipefail

# Color codes for terminal output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'

# Default configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly DEFAULT_SKILLS_DIR="${PROJECT_ROOT}/skills"
readonly REPORTS_DIR="${DEFAULT_SKILLS_DIR}/scan-reports"
readonly SCAN_SCRIPT="${DEFAULT_SKILLS_DIR}/scan-skill.sh"

# Default settings
DEFAULT_CONCURRENCY=4
SUMMARY_ONLY=false
EXCLUDE_PATTERNS=()

################################################################################
# Function: print_usage
# Description: Display script usage information
################################################################################
print_usage() {
    cat << EOF
${BOLD}Cisco Skill Scanner - Batch Security Analysis${NC}

${BOLD}USAGE:${NC}
    $(basename "$0") [options]

${BOLD}OPTIONS:${NC}
    -h, --help              Show this help message
    -c, --concurrency N     Maximum concurrent scans (default: 4)
    -s, --skills DIR        Skills directory to scan (default: ${DEFAULT_SKILLS_DIR})
    -e, --exclude PATTERN   Exclude directories matching pattern (can use multiple)
    --summary-only          Only show final summary, suppress individual scan output

${BOLD}EXAMPLES:${NC}
    # Scan all skills with default settings
    $(basename "$0")
    
    # Scan with 8 concurrent jobs
    $(basename "$0") -c 8
    
    # Scan and exclude specific directories
    $(basename "$0") -e "skill-scanner" -e "test-*"
    
    # Show summary only
    $(basename "$0") --summary-only

${BOLD}OUTPUT:${NC}
    Individual Reports:  ${REPORTS_DIR}/<skill>-<timestamp>.json
    Batch Summary:       ${REPORTS_DIR}/batch-summary-<timestamp>.txt
    Approved Log:        ${REPORTS_DIR}/approved-skills.txt
    Rejected Log:        ${REPORTS_DIR}/rejected-skills.txt

EOF
}

################################################################################
# Function: log_message
# Description: Print formatted log message with timestamp
# Parameters:
#   $1 - Message type (INFO, WARN, ERROR, SUCCESS)
#   $2 - Message text
################################################################################
log_message() {
    local type="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$type" in
        INFO)
            echo -e "${BLUE}[INFO]${NC} ${timestamp} - ${message}"
            ;;
        WARN)
            echo -e "${YELLOW}[WARN]${NC} ${timestamp} - ${message}"
            ;;
        ERROR)
            echo -e "${RED}[ERROR]${NC} ${timestamp} - ${message}" >&2
            ;;
        SUCCESS)
            echo -e "${GREEN}[SUCCESS]${NC} ${timestamp} - ${message}"
            ;;
        *)
            echo "${timestamp} - ${message}"
            ;;
    esac
}

################################################################################
# Function: validate_environment
# Description: Validate required scripts and directories
################################################################################
validate_environment() {
    log_message "INFO" "Validating environment..."
    
    # Check if scan script exists
    if [[ ! -f "${SCAN_SCRIPT}" ]]; then
        log_message "ERROR" "Scan script not found: ${SCAN_SCRIPT}"
        return 1
    fi
    
    # Make sure scan script is executable
    if [[ ! -x "${SCAN_SCRIPT}" ]]; then
        log_message "WARN" "Scan script is not executable, fixing permissions..."
        chmod +x "${SCAN_SCRIPT}"
    fi
    
    # Create reports directory if it doesn't exist
    if [[ ! -d "${REPORTS_DIR}" ]]; then
        log_message "INFO" "Creating reports directory: ${REPORTS_DIR}"
        mkdir -p "${REPORTS_DIR}" || return 1
    fi
    
    log_message "SUCCESS" "Environment validation complete"
    return 0
}

################################################################################
# Function: find_skills
# Description: Find all skill directories to scan
# Parameters:
#   $1 - Skills base directory
################################################################################
find_skills() {
    local skills_dir="$1"
    local skills=()
    
    log_message "INFO" "Discovering skills in: ${skills_dir}"
    
    # Find all directories (1 level deep)
    while IFS= read -r -d '' dir; do
        local skill_name
        skill_name=$(basename "${dir}")
        
        # Check if should be excluded
        local should_exclude=false
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            if [[ "${skill_name}" == ${pattern} ]]; then
                should_exclude=true
                break
            fi
        done
        
        # Skip excluded directories
        if [[ ${should_exclude} == true ]]; then
            log_message "INFO" "Excluding: ${skill_name} (matches exclusion pattern)"
            continue
        fi
        
        # Skip hidden directories and specific system directories
        if [[ "${skill_name}" == .* ]] || \
           [[ "${skill_name}" == "scan-reports" ]] || \
           [[ "${skill_name}" == "skill-scanner" ]]; then
            continue
        fi
        
        skills+=("${skill_name}")
    done < <(find "${skills_dir}" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
    
    echo "${skills[@]}"
}

################################################################################
# Function: run_parallel_scans
# Description: Execute scans in parallel with concurrency control
# Parameters:
#   $1 - Maximum concurrency
#   $2 - Summary only flag
#   $@ - Array of skill names
################################################################################
run_parallel_scans() {
    local max_concurrency="$1"
    shift
    local summary_only="$1"
    shift
    local skills=("$@")
    
    local total_skills=${#skills[@]}
    
    log_message "INFO" "Starting batch scan: ${total_skills} skills, max ${max_concurrency} concurrent"
    echo ""
    
    # Temporary files for tracking results
    local temp_dir
    temp_dir=$(mktemp -d)
    local results_file="${temp_dir}/results.txt"
    touch "${results_file}"
    
    log_message "INFO" "Using bash background jobs for concurrent execution"
    
    local active_jobs=0
    for skill in "${skills[@]}"; do
        # Wait if we've reached max concurrency
        while [[ ${active_jobs} -ge ${max_concurrency} ]]; do
            # Wait for any job to complete
            wait -n 2>/dev/null || wait
            active_jobs=$((active_jobs - 1))
        done
        
        # Start new scan in background
        (
            if [[ "${summary_only}" == "true" ]]; then
                # Redirect output to temporary file
                local temp_output
                temp_output=$(mktemp)
                "${SCAN_SCRIPT}" "${skill}" > "${temp_output}" 2>&1
                local exit_code=$?
                rm -f "${temp_output}"
            else
                # Run with full output
                "${SCAN_SCRIPT}" "${skill}"
                local exit_code=$?
            fi
            
            # Record result
            echo "${skill}:${exit_code}" >> "${results_file}"
        ) &
        
        active_jobs=$((active_jobs + 1))
        
        if [[ "${summary_only}" == "false" ]]; then
            sleep 0.5  # Small delay to prevent output interleaving
        fi
    done
    
    # Wait for all remaining jobs
    log_message "INFO" "Waiting for all scans to complete..."
    wait
    
    # Parse results
    local completed=0
    local passed=0
    local failed=0
    local errors=0
    
    if [[ -f "${results_file}" ]]; then
        while IFS=: read -r skill exit_code; do
            [[ -z "${skill}" ]] && continue
            completed=$((completed + 1))
            case ${exit_code} in
                0)
                    passed=$((passed + 1))
                    ;;
                1)
                    failed=$((failed + 1))
                    ;;
                *)
                    errors=$((errors + 1))
                    ;;
            esac
        done < "${results_file}"
    fi
    
    # Cleanup
    rm -rf "${temp_dir}"
    
    # Store results in global variables for summary
    TOTAL_SCANNED=${total_skills}
    TOTAL_PASSED=${passed}
    TOTAL_FAILED=${failed}
    TOTAL_ERRORS=${errors}
    
    return 0
}

################################################################################
# Function: generate_batch_summary
# Description: Generate and display aggregate summary report
################################################################################
generate_batch_summary() {
    local timestamp
    timestamp=$(date '+%Y%m%d-%H%M%S')
    local summary_file="${REPORTS_DIR}/batch-summary-${timestamp}.txt"
    
    # Create summary content
    {
        echo "═══════════════════════════════════════════════════════════════════"
        echo "CISCO SKILL SCANNER - BATCH SCAN SUMMARY"
        echo "═══════════════════════════════════════════════════════════════════"
        echo ""
        echo "Timestamp:        $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Total Scanned:    ${TOTAL_SCANNED}"
        echo ""
        echo "Results:"
        echo "  ✓ Passed:       ${TOTAL_PASSED}"
        echo "  ✗ Failed:       ${TOTAL_FAILED}"
        echo "  ⚠ Errors:       ${TOTAL_ERRORS}"
        echo ""
        local batch_pass_rate
        if [[ ${TOTAL_SCANNED} -gt 0 ]]; then
            batch_pass_rate=$(python3 -c "print(f'{(${TOTAL_PASSED}/${TOTAL_SCANNED})*100:.1f}')" 2>/dev/null || echo "0.0")
        else
            batch_pass_rate="0.0"
        fi
        echo "Pass Rate:        ${batch_pass_rate}%"
        echo ""
        echo "═══════════════════════════════════════════════════════════════════"
        echo ""
        
        # List approved skills
        if [[ ${TOTAL_PASSED} -gt 0 ]] && [[ -f "${REPORTS_DIR}/approved-skills.txt" ]]; then
            echo "APPROVED SKILLS:"
            tail -n "${TOTAL_PASSED}" "${REPORTS_DIR}/approved-skills.txt" | \
                awk -F' \\| ' '{print "  ✓ " $2 " (Score: " $3 ")"}'
            echo ""
        fi
        
        # List rejected skills
        if [[ ${TOTAL_FAILED} -gt 0 ]] && [[ -f "${REPORTS_DIR}/rejected-skills.txt" ]]; then
            echo "REJECTED SKILLS:"
            tail -n "${TOTAL_FAILED}" "${REPORTS_DIR}/rejected-skills.txt" | \
                awk -F' \\| ' '{print "  ✗ " $2 " (Score: " $3 ")"}'
            echo ""
        fi
        
        echo "═══════════════════════════════════════════════════════════════════"
        echo ""
        echo "Reports Directory: ${REPORTS_DIR}"
        echo "Summary File:      ${summary_file}"
        echo ""
        
    } | tee "${summary_file}"
    
    log_message "SUCCESS" "Batch summary saved to: ${summary_file}"
}

################################################################################
# Function: print_colored_summary
# Description: Print color-coded summary to terminal
################################################################################
print_colored_summary() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo -e "${BOLD}${CYAN}CISCO SKILL SCANNER - BATCH SCAN SUMMARY${NC}"
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""
    echo -e "${BOLD}Timestamp:${NC}        $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${BOLD}Total Scanned:${NC}    ${TOTAL_SCANNED}"
    echo ""
    echo -e "${BOLD}Results:${NC}"
    echo -e "  ${GREEN}✓ Passed:${NC}       ${TOTAL_PASSED}"
    echo -e "  ${RED}✗ Failed:${NC}       ${TOTAL_FAILED}"
    echo -e "  ${YELLOW}⚠ Errors:${NC}       ${TOTAL_ERRORS}"
    echo ""
    
    local pass_rate
    if [[ ${TOTAL_SCANNED} -gt 0 ]]; then
        pass_rate=$(python3 -c "print(f'{(${TOTAL_PASSED}/${TOTAL_SCANNED})*100:.1f}')" 2>/dev/null || echo "0.0")
    else
        pass_rate="0.0"
    fi
    echo -e "${BOLD}Pass Rate:${NC}        ${pass_rate}%"
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""
}

################################################################################
# Main Script Execution
################################################################################
main() {
    local concurrency="${DEFAULT_CONCURRENCY}"
    local skills_dir="${DEFAULT_SKILLS_DIR}"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                print_usage
                exit 0
                ;;
            -c|--concurrency)
                concurrency="$2"
                shift 2
                ;;
            -s|--skills)
                skills_dir="$2"
                shift 2
                ;;
            -e|--exclude)
                EXCLUDE_PATTERNS+=("$2")
                shift 2
                ;;
            --summary-only)
                SUMMARY_ONLY=true
                shift
                ;;
            *)
                log_message "ERROR" "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done
    
    # Validate concurrency value
    if ! [[ "${concurrency}" =~ ^[0-9]+$ ]] || [[ ${concurrency} -lt 1 ]]; then
        log_message "ERROR" "Invalid concurrency value: ${concurrency}"
        exit 1
    fi
    
    echo ""
    log_message "INFO" "Cisco Skill Scanner - Starting batch scan process"
    echo ""
    
    # Validate environment
    validate_environment || exit 1
    
    # Find skills to scan
    local skills_array=()
    while IFS= read -r skill; do
        [[ -n "$skill" ]] && skills_array+=("$skill")
    done < <(find_skills "${skills_dir}" | tr ' ' '\n')
    
    if [[ ${#skills_array[@]} -eq 0 ]]; then
        log_message "WARN" "No skills found to scan in: ${skills_dir}"
        exit 0
    fi
    
    log_message "INFO" "Found ${#skills_array[@]} skill(s) to scan"
    echo ""
    
    # Run parallel scans
    run_parallel_scans "${concurrency}" "${SUMMARY_ONLY}" "${skills_array[@]}"
    
    echo ""
    log_message "INFO" "All scans completed"
    echo ""
    
    # Print colored summary
    print_colored_summary
    
    # Generate summary file
    generate_batch_summary
    
    # Return success (individual failures are tracked but don't fail the batch)
    exit 0
}

# Execute main function
main "$@"
