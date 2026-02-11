#!/bin/bash
#
# Full Security Scan Orchestrator
# Runs all security scanners and aggregates results
#
# Usage: ./full-security-scan.sh <skill-path> [repo-url]
# Exit codes:
#   0 = APPROVED (risk ≤ 60)
#   1 = REJECTED (risk > 80)
#   2 = BORDERLINE (risk 61-80, needs manual review)
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

log_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
log_error() { echo -e "${RED}✗${NC}  $1"; exit 1; }
log_step() { echo -e "\n${CYAN}${BOLD}═══ $1 ═══${NC}\n"; }

# Check arguments
if [ $# -lt 1 ]; then
    log_error "Usage: $0 <skill-path> [repo-url]"
fi

SKILL_PATH="$1"
REPO_URL="${2:-}"
SKILL_NAME=$(basename "$SKILL_PATH")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FINAL_REPORT="$SKILL_PATH/final-security-report.json"

# Validate skill path
if [ ! -d "$SKILL_PATH" ]; then
    log_error "Skill directory not found: $SKILL_PATH"
fi

log_step "Full Security Scan: $SKILL_NAME"

# Initialize tracking
SCANS_RUN=0
SCANS_PASSED=0
SCANS_FAILED=0

# Function to run scan with error handling
run_scan() {
    local scan_name="$1"
    local command="$2"
    
    log_info "Running $scan_name..."
    ((SCANS_RUN++))
    
    if eval "$command"; then
        log_success "$scan_name completed"
        ((SCANS_PASSED++))
        return 0
    else
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 127 ]; then
            log_warn "$scan_name tool not found - skipping"
        else
            log_warn "$scan_name found issues (exit code: $EXIT_CODE)"
        fi
        ((SCANS_FAILED++))
        return $EXIT_CODE
    fi
}

# Step 1: Cisco Skill Scanner
log_step "1/5: Cisco Skill Scanner"
CISCO_SCAN_CMD="cd '$(dirname "$SCRIPT_DIR")' && ./skills/scan-skill.sh '$SKILL_NAME'"
run_scan "Cisco Skill Scanner" "$CISCO_SCAN_CMD" || true

# Step 2: Semgrep SAST
log_step "2/5: Semgrep Static Analysis"
SEMGREP_REPORT="$SKILL_PATH/semgrep-report.json"
SEMGREP_CMD="semgrep --config=auto '$SKILL_PATH' --json --output '$SEMGREP_REPORT' --quiet 2>/dev/null"
run_scan "Semgrep SAST" "$SEMGREP_CMD" || true

# Step 3: TruffleHog Secrets Scan
log_step "3/5: TruffleHog Secrets Detection"
TRUFFLEHOG_REPORT="$SKILL_PATH/trufflehog-report.json"
TRUFFLEHOG_CMD="trufflehog filesystem '$SKILL_PATH' --json --no-update 2>/dev/null | jq -s '{DetectorResults: .}' > '$TRUFFLEHOG_REPORT'"
run_scan "TruffleHog" "$TRUFFLEHOG_CMD" || true

# Step 4: AI Security Analysis
log_step "4/5: AI-Powered Code Analysis"
AI_CMD="'$SCRIPT_DIR/analyze-code-security.sh' '$SKILL_PATH'"
run_scan "AI Analysis" "$AI_CMD" || true

# Step 5: Provenance Check (if repo URL provided)
if [ -n "$REPO_URL" ]; then
    log_step "5/5: Provenance Verification"
    PROV_REPORT="$SKILL_PATH/provenance-report.json"
    PROV_CMD="'$SCRIPT_DIR/check-provenance.sh' '$REPO_URL' '$SKILL_PATH' && mv '$SKILL_PATH/provenance-report.json' '$PROV_REPORT' 2>/dev/null || echo '{}' > '$PROV_REPORT'"
    run_scan "Provenance Check" "$PROV_CMD" || true
else
    log_info "Skipping provenance check (no repo URL provided)"
fi

# Aggregate results
log_step "Aggregating Results"
log_info "Combining all scan results..."

python3 "$SCRIPT_DIR/aggregate-security-scores.py" \
    --skill-path "$SKILL_PATH" \
    --output "$FINAL_REPORT"

AGGREGATOR_EXIT=$?

# Read final verdict
VERDICT=$(jq -r '.verdict' "$FINAL_REPORT" 2>/dev/null || echo "ERROR")
RISK_SCORE=$(jq -r '.total_risk_score' "$FINAL_REPORT" 2>/dev/null || echo "999")
FINDINGS_COUNT=$(jq -r '.findings_count' "$FINAL_REPORT" 2>/dev/null || echo "0")

# Print final summary
log_step "Security Scan Complete"

echo -e "${BOLD}Skill:${NC}          $SKILL_NAME"
echo -e "${BOLD}Risk Score:${NC}     $RISK_SCORE / 100"
echo -e "${BOLD}Findings:${NC}       $FINDINGS_COUNT"

case "$VERDICT" in
    APPROVED)
        echo -e "${BOLD}Verdict:${NC}        ${GREEN}${BOLD}✓ APPROVED${NC}"
        echo -e "${BOLD}Action:${NC}         Safe to install and use"
        EXIT_CODE=0
        ;;
    BORDERLINE)
        echo -e "${BOLD}Verdict:${NC}        ${YELLOW}${BOLD}⚠ BORDERLINE${NC}"
        echo -e "${BOLD}Action:${NC}         ${YELLOW}Manual review required${NC}"
        echo -e "${BOLD}Note:${NC}           Risk score 61-80 requires human judgment"
        EXIT_CODE=2
        ;;
    REJECTED)
        echo -e "${BOLD}Verdict:${NC}        ${RED}${BOLD}✗ REJECTED${NC}"
        echo -e "${BOLD}Action:${NC}         ${RED}Do NOT install - security risks detected${NC}"
        EXIT_CODE=1
        ;;
    *)
        echo -e "${BOLD}Verdict:${NC}        ${RED}ERROR${NC}"
        echo -e "${BOLD}Action:${NC}         Review logs for errors"
        EXIT_CODE=1
        ;;
esac

echo -e "${BOLD}Report:${NC}         $FINAL_REPORT"
echo ""

# Print scan summary
echo -e "${CYAN}Scans Executed:${NC}"
echo -e "  Total:        $SCANS_RUN"
echo -e "  Passed:       $SCANS_PASSED"
echo -e "  Had issues:   $SCANS_FAILED"
echo ""

exit $EXIT_CODE
