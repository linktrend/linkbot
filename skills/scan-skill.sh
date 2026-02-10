#!/bin/bash

################################################################################
# Cisco Skill Scanner Automation Script
#
# Description:
#   Automated scanning script for individual skills using Cisco Skill Scanner.
#   Validates skill directory, runs security analysis, generates JSON reports,
#   and determines PASS/FAIL based on risk score thresholds.
#
# Usage:
#   ./scan-skill.sh <skill-name>
#
# Parameters:
#   skill-name: Name of the skill directory to scan (relative to skills/)
#
# Output:
#   - JSON report: /skills/scan-reports/<skill>-<timestamp>.json
#   - Approved skills logged to: scan-reports/approved-skills.txt
#   - Rejected skills logged to: scan-reports/rejected-skills.txt
#
# Exit Codes:
#   0 - PASS (risk score 0-60)
#   1 - FAIL (risk score 61+)
#   2 - Error (invalid input, missing directory, etc.)
#
# Risk Score Thresholds:
#   0-60  = PASS (Low to Medium risk)
#   61+   = FAIL (High to Critical risk)
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

# Script configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly SKILLS_DIR="${PROJECT_ROOT}/skills"
readonly SCANNER_DIR="${SKILLS_DIR}/skill-scanner"
readonly VENV_PATH="${SCANNER_DIR}/venv"
readonly REPORTS_DIR="${SKILLS_DIR}/scan-reports"
readonly APPROVED_LOG="${REPORTS_DIR}/approved-skills.txt"
readonly REJECTED_LOG="${REPORTS_DIR}/rejected-skills.txt"

# Risk score threshold (0-60 = PASS, 61+ = FAIL)
readonly PASS_THRESHOLD=60

################################################################################
# Function: print_usage
# Description: Display script usage information
################################################################################
print_usage() {
    cat << EOF
${BOLD}Cisco Skill Scanner - Automated Security Analysis${NC}

${BOLD}USAGE:${NC}
    $(basename "$0") <skill-name>

${BOLD}PARAMETERS:${NC}
    skill-name    Name of the skill directory to scan (relative to skills/)

${BOLD}EXAMPLES:${NC}
    $(basename "$0") my-skill
    $(basename "$0") skill-scanner

${BOLD}OUTPUT:${NC}
    JSON Report:     ${REPORTS_DIR}/<skill>-<timestamp>.json
    Approved Log:    ${APPROVED_LOG}
    Rejected Log:    ${REJECTED_LOG}

${BOLD}EXIT CODES:${NC}
    0    PASS (risk score 0-60)
    1    FAIL (risk score 61+)
    2    Error (invalid input, missing directory, etc.)

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
# Description: Validate required directories and virtual environment
################################################################################
validate_environment() {
    log_message "INFO" "Validating environment..."
    
    # Check if scanner directory exists
    if [[ ! -d "${SCANNER_DIR}" ]]; then
        log_message "ERROR" "Skill scanner not found at: ${SCANNER_DIR}"
        log_message "ERROR" "Please run installation first"
        return 2
    fi
    
    # Check if virtual environment exists
    if [[ ! -d "${VENV_PATH}" ]]; then
        log_message "ERROR" "Virtual environment not found at: ${VENV_PATH}"
        log_message "ERROR" "Please run installation first"
        return 2
    fi
    
    # Check if skill-scanner command is available
    if [[ ! -f "${VENV_PATH}/bin/skill-scanner" ]]; then
        log_message "ERROR" "skill-scanner command not found in virtual environment"
        return 2
    fi
    
    # Create reports directory if it doesn't exist
    if [[ ! -d "${REPORTS_DIR}" ]]; then
        log_message "INFO" "Creating reports directory: ${REPORTS_DIR}"
        mkdir -p "${REPORTS_DIR}" || return 2
    fi
    
    log_message "SUCCESS" "Environment validation complete"
    return 0
}

################################################################################
# Function: validate_skill_directory
# Description: Validate that skill directory exists
# Parameters:
#   $1 - Skill name
################################################################################
validate_skill_directory() {
    local skill_name="$1"
    local skill_path="${SKILLS_DIR}/${skill_name}"
    
    log_message "INFO" "Validating skill directory: ${skill_path}"
    
    if [[ ! -d "${skill_path}" ]]; then
        log_message "ERROR" "Skill directory not found: ${skill_path}"
        log_message "ERROR" "Available skills in ${SKILLS_DIR}:"
        if command -v tree &> /dev/null; then
            tree -L 1 -d "${SKILLS_DIR}" | grep -v '^\.' || true
        else
            ls -d "${SKILLS_DIR}"/*/ 2>/dev/null | xargs -n 1 basename || echo "  (no skills found)"
        fi
        return 2
    fi
    
    log_message "SUCCESS" "Skill directory validated: ${skill_path}"
    return 0
}

################################################################################
# Function: run_scan
# Description: Execute skill-scanner and generate JSON report
# Parameters:
#   $1 - Skill name
#   $2 - Output report path
################################################################################
run_scan() {
    local skill_name="$1"
    local report_path="$2"
    local skill_path="${SKILLS_DIR}/${skill_name}"
    
    log_message "INFO" "Starting security scan for: ${skill_name}"
    log_message "INFO" "Target directory: ${skill_path}"
    log_message "INFO" "Report output: ${report_path}"
    
    # Activate virtual environment and run scanner
    (
        source "${VENV_PATH}/bin/activate"
        
        # Run skill-scanner with JSON output
        skill-scanner scan \
            "${skill_path}" \
            --format json \
            --output "${report_path}" \
            --detailed
    )
    
    local scan_exit_code=$?
    
    if [[ ${scan_exit_code} -ne 0 ]]; then
        log_message "ERROR" "Skill scanner failed with exit code: ${scan_exit_code}"
        return 2
    fi
    
    if [[ ! -f "${report_path}" ]]; then
        log_message "ERROR" "Report file was not generated: ${report_path}"
        return 2
    fi
    
    log_message "SUCCESS" "Scan completed successfully"
    return 0
}

################################################################################
# Function: extract_risk_score
# Description: Extract or calculate risk score from JSON report
# Parameters:
#   $1 - Report file path
################################################################################
extract_risk_score() {
    local report_path="$1"
    
    if ! command -v python3 &> /dev/null; then
        log_message "ERROR" "python3 not found - required for JSON parsing"
        return 2
    fi
    
    # Extract risk score using Python
    python3 << EOF
import json
import sys

try:
    with open("${report_path}", "r") as f:
        data = json.load(f)
    
    # Try different possible risk score locations
    risk_score = None
    
    if "risk_score" in data:
        risk_score = data["risk_score"]
    elif "overall_risk_score" in data:
        risk_score = data["overall_risk_score"]
    elif "summary" in data and "risk_score" in data["summary"]:
        risk_score = data["summary"]["risk_score"]
    elif "metadata" in data and "risk_score" in data["metadata"]:
        risk_score = data["metadata"]["risk_score"]
    else:
        # Calculate risk score from findings if not directly available
        # Severity weights: CRITICAL=25, HIGH=15, MEDIUM=8, LOW=3
        severity_weights = {
            "CRITICAL": 25,
            "HIGH": 15,
            "MEDIUM": 8,
            "LOW": 3,
            "INFO": 1
        }
        
        calculated_score = 0
        
        # Check if is_safe flag exists and is true (score = 0)
        if data.get("is_safe") == True and data.get("findings_count", 0) == 0:
            risk_score = 0
        elif "findings" in data and isinstance(data["findings"], list):
            for finding in data["findings"]:
                severity = finding.get("severity", "LOW").upper()
                calculated_score += severity_weights.get(severity, 3)
            
            # Cap at 100
            risk_score = min(calculated_score, 100)
        elif "max_severity" in data:
            # Fallback: estimate based on max severity
            max_sev = data.get("max_severity", "LOW").upper()
            if max_sev == "CRITICAL":
                risk_score = 90
            elif max_sev == "HIGH":
                risk_score = 70
            elif max_sev == "MEDIUM":
                risk_score = 40
            elif max_sev == "LOW":
                risk_score = 20
            else:
                risk_score = 0
    
    if risk_score is not None:
        print(int(risk_score))
        sys.exit(0)
    else:
        print("0", file=sys.stderr)
        sys.exit(1)
        
except Exception as e:
    print(f"Error parsing JSON: {e}", file=sys.stderr)
    sys.exit(2)
EOF
    
    return $?
}

################################################################################
# Function: determine_pass_fail
# Description: Determine PASS/FAIL based on risk score
# Parameters:
#   $1 - Risk score
################################################################################
determine_pass_fail() {
    local risk_score="$1"
    
    if [[ ${risk_score} -le ${PASS_THRESHOLD} ]]; then
        echo "PASS"
        return 0
    else
        echo "FAIL"
        return 1
    fi
}

################################################################################
# Function: log_result
# Description: Log scan result to appropriate file
# Parameters:
#   $1 - Skill name
#   $2 - Result (PASS/FAIL)
#   $3 - Risk score
#   $4 - Report path
################################################################################
log_result() {
    local skill_name="$1"
    local result="$2"
    local risk_score="$3"
    local report_path="$4"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    local log_entry="${timestamp} | ${skill_name} | SCORE: ${risk_score} | REPORT: ${report_path}"
    
    if [[ "${result}" == "PASS" ]]; then
        echo "${log_entry}" >> "${APPROVED_LOG}"
        log_message "SUCCESS" "Logged to approved skills"
    else
        echo "${log_entry}" >> "${REJECTED_LOG}"
        log_message "WARN" "Logged to rejected skills"
    fi
}

################################################################################
# Function: print_summary
# Description: Print color-coded summary of scan results
# Parameters:
#   $1 - Skill name
#   $2 - Result (PASS/FAIL)
#   $3 - Risk score
#   $4 - Report path
################################################################################
print_summary() {
    local skill_name="$1"
    local result="$2"
    local risk_score="$3"
    local report_path="$4"
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo -e "${BOLD}${CYAN}CISCO SKILL SCANNER - SCAN SUMMARY${NC}"
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""
    echo -e "${BOLD}Skill Name:${NC}     ${skill_name}"
    echo -e "${BOLD}Risk Score:${NC}     ${risk_score} / 100"
    echo ""
    
    if [[ "${result}" == "PASS" ]]; then
        echo -e "${BOLD}Result:${NC}         ${GREEN}${BOLD}✓ PASS${NC} (Score ≤ ${PASS_THRESHOLD})"
        echo -e "${BOLD}Status:${NC}         ${GREEN}Skill approved for use${NC}"
    else
        echo -e "${BOLD}Result:${NC}         ${RED}${BOLD}✗ FAIL${NC} (Score > ${PASS_THRESHOLD})"
        echo -e "${BOLD}Status:${NC}         ${RED}Skill rejected - security concerns detected${NC}"
    fi
    
    echo ""
    echo -e "${BOLD}Report:${NC}         ${report_path}"
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""
}

################################################################################
# Main Script Execution
################################################################################
main() {
    # Check for required parameters
    if [[ $# -eq 0 ]]; then
        print_usage
        exit 2
    fi
    
    # Parse command line arguments
    local skill_name="$1"
    
    # Handle help flag
    if [[ "${skill_name}" == "-h" ]] || [[ "${skill_name}" == "--help" ]]; then
        print_usage
        exit 0
    fi
    
    echo ""
    log_message "INFO" "Cisco Skill Scanner - Starting scan process"
    echo ""
    
    # Validate environment
    validate_environment || exit 2
    
    # Validate skill directory
    validate_skill_directory "${skill_name}" || exit 2
    
    # Generate report filename with timestamp
    local timestamp
    timestamp=$(date '+%Y%m%d-%H%M%S')
    local report_filename="${skill_name}-${timestamp}.json"
    local report_path="${REPORTS_DIR}/${report_filename}"
    
    # Run scan
    run_scan "${skill_name}" "${report_path}" || exit 2
    
    # Extract risk score
    log_message "INFO" "Extracting risk score from report..."
    local risk_score
    risk_score=$(extract_risk_score "${report_path}")
    local extract_exit_code=$?
    
    if [[ ${extract_exit_code} -ne 0 ]] || [[ -z "${risk_score}" ]]; then
        log_message "ERROR" "Failed to extract risk score from report"
        log_message "WARN" "Defaulting to FAIL for safety"
        risk_score=100
    fi
    
    log_message "INFO" "Risk score extracted: ${risk_score}"
    
    # Determine PASS/FAIL
    local result
    result=$(determine_pass_fail "${risk_score}")
    local pass_fail_exit_code=$?
    
    # Log result to appropriate file
    log_result "${skill_name}" "${result}" "${risk_score}" "${report_path}"
    
    # Print summary
    print_summary "${skill_name}" "${result}" "${risk_score}" "${report_path}"
    
    # Return appropriate exit code
    if [[ ${pass_fail_exit_code} -eq 0 ]]; then
        exit 0  # PASS
    else
        exit 1  # FAIL
    fi
}

# Execute main function
main "$@"
