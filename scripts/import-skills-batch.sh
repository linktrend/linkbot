#!/bin/bash
#
# Batch Skills Importer with Security Scanning
# Imports skills from awesome-openclaw-skills with full security validation
#
# Usage: ./import-skills-batch.sh [--test-mode] [--category <category>]
#
# Modes:
#   --test-mode         Only process 10 sample skills for testing
#   --category <name>   Only process specific category
#   (no flags)          Process all skills from all categories
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
log_error() { echo -e "${RED}✗${NC}  $1"; }
log_section() { echo -e "\n${MAGENTA}${BOLD}▓▓▓ $1 ▓▓▓${NC}\n"; }

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(dirname "$SCRIPT_DIR")"
TEMP_DIR="/tmp/linkbot-import-$$"
AWESOME_REPO="https://github.com/linktrend/awesome-openclaw-skills.git"
TARGET_DIR="$MONOREPO_ROOT/skills/awesome-openclaw"
REPORTS_DIR="$MONOREPO_ROOT/skills/scan-reports"
SUMMARY_FILE="$REPORTS_DIR/import-summary-$(date +%Y%m%d-%H%M%S).json"

# Tracking
TOTAL_SKILLS=0
SCANNED_SKILLS=0
APPROVED_SKILLS=0
REJECTED_SKILLS=0
BORDERLINE_SKILLS=0
SKIPPED_SKILLS=0
declare -a APPROVED_LIST
declare -a REJECTED_LIST
declare -a BORDERLINE_LIST

# Parse arguments
TEST_MODE=false
SPECIFIC_CATEGORY=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --test-mode)
            TEST_MODE=true
            shift
            ;;
        --category)
            SPECIFIC_CATEGORY="$2"
            shift 2
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Create directories
mkdir -p "$TEMP_DIR" "$TARGET_DIR" "$REPORTS_DIR"

log_section "Batch Skills Import - Security Scanning"

if [ "$TEST_MODE" = true ]; then
    log_warn "TEST MODE: Processing only 10 sample skills"
fi

if [ -n "$SPECIFIC_CATEGORY" ]; then
    log_info "Processing only category: $SPECIFIC_CATEGORY"
fi

# Step 1: Clone awesome-openclaw-skills
log_section "Step 1: Cloning awesome-openclaw-skills"
log_info "Cloning to: $TEMP_DIR"

git clone --depth 1 "$AWESOME_REPO" "$TEMP_DIR/awesome-openclaw-skills" 2>&1 | grep -v "^Cloning" || true
cd "$TEMP_DIR/awesome-openclaw-skills"

log_success "Repository cloned"

# Step 2: Identify categories and skills
log_section "Step 2: Discovering Skills"

# Note: awesome-openclaw-skills is just a README with links
# We need to parse the README and clone individual skills
# For now, let's handle the common case where skills are already in a directory structure

# Check if there's a skills directory or if it's just documentation
if [ ! -d "skills" ] && [ ! -d "src" ]; then
    log_warn "awesome-openclaw-skills appears to be documentation only"
    log_info "This repo contains skill links, not actual skill code"
    log_info "Will need to fetch individual skills from ClawHub or GitHub"
    
    # For Phase 1 testing, let's create a placeholder
    log_warn "Switching to test existing skills in monorepo for Phase 1"
    
    # Use existing skills as test subjects
    TEST_SKILLS=(
        "$MONOREPO_ROOT/skills/shared/gmail-integration"
        "$MONOREPO_ROOT/skills/shared/google-docs"
        "$MONOREPO_ROOT/skills/shared/google-sheets"
        "$MONOREPO_ROOT/skills/coding/python-coding"
        "$MONOREPO_ROOT/skills/coding/typescript-coding"
        "$MONOREPO_ROOT/skills/specialized/document-generator"
        "$MONOREPO_ROOT/skills/specialized/financial-calculator"
        "$MONOREPO_ROOT/skills/specialized/meeting-scheduler"
        "$MONOREPO_ROOT/skills/specialized/task-management"
        "$MONOREPO_ROOT/skills/test-safe-skill"
    )
    
    TOTAL_SKILLS=${#TEST_SKILLS[@]}
    log_info "Using $TOTAL_SKILLS existing skills for security validation"
    
    # Step 3: Scan each skill
    log_section "Step 3: Security Scanning"
    
    for skill_path in "${TEST_SKILLS[@]}"; do
        if [ ! -d "$skill_path" ]; then
            log_warn "Skill not found: $skill_path"
            ((SKIPPED_SKILLS++))
            continue
        fi
        
        SKILL=$(basename "$skill_path")
        ((SCANNED_SKILLS++))
        
        log_info "[$SCANNED_SKILLS/$TOTAL_SKILLS] Scanning: $SKILL"
        
        # Run full security scan
        if "$SCRIPT_DIR/full-security-scan.sh" "$skill_path" 2>&1 | tee "$REPORTS_DIR/${SKILL}-scan.log"; then
            EXIT_CODE=$?
            
            case $EXIT_CODE in
                0)
                    log_success "$SKILL: APPROVED"
                    ((APPROVED_SKILLS++))
                    APPROVED_LIST+=("$SKILL")
                    ;;
                2)
                    log_warn "$SKILL: BORDERLINE - needs review"
                    ((BORDERLINE_SKILLS++))
                    BORDERLINE_LIST+=("$SKILL")
                    ;;
                *)
                    log_error "$SKILL: REJECTED"
                    ((REJECTED_SKILLS++))
                    REJECTED_LIST+=("$SKILL")
                    ;;
            esac
        else
            log_error "Scan failed for $SKILL"
            ((REJECTED_SKILLS++))
            REJECTED_LIST+=("$SKILL")
        fi
        
        # Test mode: stop after 10
        if [ "$TEST_MODE" = true ] && [ $SCANNED_SKILLS -ge 10 ]; then
            log_warn "Test mode: Stopping after 10 skills"
            break
        fi
        
        # Small delay to avoid rate limits
        sleep 0.5
    done
fi

# Step 4: Generate summary report
log_section "Step 4: Generating Summary"

cat > "$SUMMARY_FILE" << EOF
{
  "import_session": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "mode": "$([ "$TEST_MODE" = true ] && echo "test" || echo "full")",
    "category_filter": "${SPECIFIC_CATEGORY:-all}"
  },
  "statistics": {
    "total_skills": $TOTAL_SKILLS,
    "scanned": $SCANNED_SKILLS,
    "approved": $APPROVED_SKILLS,
    "rejected": $REJECTED_SKILLS,
    "borderline": $BORDERLINE_SKILLS,
    "skipped": $SKIPPED_SKILLS
  },
  "approved_skills": $(printf '%s\n' "${APPROVED_LIST[@]}" | jq -R . | jq -s .),
  "rejected_skills": $(printf '%s\n' "${REJECTED_LIST[@]}" | jq -R . | jq -s .),
  "borderline_skills": $(printf '%s\n' "${BORDERLINE_LIST[@]}" | jq -R . | jq -s .),
  "success_rate": $(echo "scale=1; $APPROVED_SKILLS * 100 / $SCANNED_SKILLS" | bc 2>/dev/null || echo "0"),
  "reports_directory": "$REPORTS_DIR"
}
EOF

# Print summary
echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                  IMPORT SUMMARY                            ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Total Skills:      ${BOLD}$TOTAL_SKILLS${NC}"
echo -e "  Scanned:           ${BOLD}$SCANNED_SKILLS${NC}"
echo ""
echo -e "  ${GREEN}✓ Approved:${NC}        $APPROVED_SKILLS"
echo -e "  ${RED}✗ Rejected:${NC}        $REJECTED_SKILLS"
echo -e "  ${YELLOW}⚠ Borderline:${NC}      $BORDERLINE_SKILLS"
echo -e "  ${BLUE}○ Skipped:${NC}         $SKIPPED_SKILLS"
echo ""
echo -e "  Success Rate:      $(echo "scale=1; $APPROVED_SKILLS * 100 / $SCANNED_SKILLS" | bc 2>/dev/null || echo "0")%"
echo ""
echo -e "  Summary Report:    ${CYAN}$SUMMARY_FILE${NC}"
echo ""

# List borderline skills for review
if [ $BORDERLINE_SKILLS -gt 0 ]; then
    echo -e "${YELLOW}${BOLD}Borderline Skills Requiring Manual Review:${NC}"
    for skill in "${BORDERLINE_LIST[@]}"; do
        echo -e "  ${YELLOW}⚠${NC} $skill"
    done
    echo ""
fi

# Cleanup
log_info "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"
log_success "Cleanup complete"

log_success "Import process complete!"

# Exit based on overall success
if [ $REJECTED_SKILLS -eq 0 ] && [ $BORDERLINE_SKILLS -eq 0 ]; then
    exit 0
elif [ $BORDERLINE_SKILLS -gt 0 ]; then
    exit 2
else
    exit 1
fi
