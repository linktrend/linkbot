#!/bin/bash
#
# Antigravity Kit Security Scanner
# Scans all agents and skills from the Antigravity Kit
#
# Usage: ./scan-antigravity-kit.sh
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
TEMP_DIR="/tmp/linkbot-antigravity"
ANTIGRAVITY_REPO="https://github.com/linktrend/antigravity-kit.git"
SOURCE_DIR="$TEMP_DIR/antigravity-kit/.agent"
TARGET_AGENTS="$MONOREPO_ROOT/agents/antigravity"
TARGET_SKILLS="$MONOREPO_ROOT/skills/antigravity"
REPORTS_DIR="$MONOREPO_ROOT/skills/scan-reports/antigravity"
SUMMARY_FILE="$REPORTS_DIR/antigravity-scan-summary-$(date +%Y%m%d-%H%M%S).json"

# Tracking
TOTAL_ITEMS=0
SCANNED_ITEMS=0
APPROVED_AGENTS=0
APPROVED_SKILLS=0
REJECTED_AGENTS=0
REJECTED_SKILLS=0
BORDERLINE_ITEMS=0
declare -a APPROVED_LIST
declare -a REJECTED_LIST
declare -a BORDERLINE_LIST

# Create directories
mkdir -p "$TEMP_DIR" "$TARGET_AGENTS" "$TARGET_SKILLS" "$REPORTS_DIR"

log_section "Antigravity Kit Security Scan"

# Clone if needed
if [ ! -d "$SOURCE_DIR" ]; then
    log_info "Cloning Antigravity Kit..."
    cd "$TEMP_DIR"
    git clone --depth 1 "$ANTIGRAVITY_REPO" 2>&1 | grep -v "^Cloning" || true
    log_success "Repository cloned"
else
    log_info "Using existing clone at $SOURCE_DIR"
fi

cd "$SOURCE_DIR"

# Count items
AGENT_COUNT=$(find agents -type f -name "*.md" | wc -l | tr -d ' ')
SKILL_DIRS=$(find skills -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')

TOTAL_ITEMS=$((AGENT_COUNT + SKILL_DIRS))

log_info "Found $AGENT_COUNT agents and $SKILL_DIRS skill directories"
log_info "Total items to scan: $TOTAL_ITEMS"

# Function to scan an item
scan_item() {
    local item_path="$1"
    local item_type="$2"  # "agent" or "skill"
    local item_name=$(basename "$item_path" .md)
    
    ((SCANNED_ITEMS++))
    
    log_info "[$SCANNED_ITEMS/$TOTAL_ITEMS] Scanning $item_type: $item_name"
    
    # Create temp directory for this item
    local temp_scan_dir="$TEMP_DIR/scan-$item_type-$item_name"
    mkdir -p "$temp_scan_dir"
    
    # Copy item for scanning
    if [ "$item_type" = "agent" ]; then
        cp "$item_path" "$temp_scan_dir/"
    else
        # For skills, copy entire directory
        cp -r "$item_path"/* "$temp_scan_dir/" 2>/dev/null || cp "$item_path"/*.md "$temp_scan_dir/" 2>/dev/null || true
    fi
    
    # Run security scan (skip AI analysis - no API key)
    if "$SCRIPT_DIR/full-security-scan.sh" "$temp_scan_dir" "https://github.com/linktrend/antigravity-kit" 2>&1 | tee "$REPORTS_DIR/${item_type}-${item_name}-scan.log" | tail -5; then
        EXIT_CODE=$?
        
        case $EXIT_CODE in
            0)
                log_success "$item_name: APPROVED"
                APPROVED_LIST+=("$item_type/$item_name")
                
                if [ "$item_type" = "agent" ]; then
                    ((APPROVED_AGENTS++))
                    # Copy to agents/antigravity/
                    cp "$item_path" "$TARGET_AGENTS/"
                else
                    ((APPROVED_SKILLS++))
                    # Copy to skills/antigravity/
                    mkdir -p "$TARGET_SKILLS/$item_name"
                    cp -r "$item_path"/* "$TARGET_SKILLS/$item_name/" 2>/dev/null || true
                fi
                ;;
            2)
                log_warn "$item_name: BORDERLINE - needs review"
                ((BORDERLINE_ITEMS++))
                BORDERLINE_LIST+=("$item_type/$item_name")
                ;;
            *)
                log_error "$item_name: REJECTED"
                REJECTED_LIST+=("$item_type/$item_name")
                
                if [ "$item_type" = "agent" ]; then
                    ((REJECTED_AGENTS++))
                else
                    ((REJECTED_SKILLS++))
                fi
                ;;
        esac
    else
        log_error "Scan failed for $item_name"
        REJECTED_LIST+=("$item_type/$item_name")
        
        if [ "$item_type" = "agent" ]; then
            ((REJECTED_AGENTS++))
        else
            ((REJECTED_SKILLS++))
        fi
    fi
    
    # Cleanup temp scan dir
    rm -rf "$temp_scan_dir"
    
    # Small delay
    sleep 0.3
}

# Scan all agents
log_section "Scanning Agents"
for agent_file in agents/*.md; do
    [ -f "$agent_file" ] || continue
    scan_item "$agent_file" "agent"
done

# Scan all skills
log_section "Scanning Skills"
for skill_dir in skills/*/; do
    [ -d "$skill_dir" ] || continue
    scan_item "$skill_dir" "skill"
done

# Generate summary
log_section "Generating Summary"

cat > "$SUMMARY_FILE" << EOF
{
  "scan_session": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "source": "antigravity-kit",
    "repository": "$ANTIGRAVITY_REPO"
  },
  "statistics": {
    "total_items": $TOTAL_ITEMS,
    "scanned": $SCANNED_ITEMS,
    "agents": {
      "total": $AGENT_COUNT,
      "approved": $APPROVED_AGENTS,
      "rejected": $REJECTED_AGENTS
    },
    "skills": {
      "total": $SKILL_DIRS,
      "approved": $APPROVED_SKILLS,
      "rejected": $REJECTED_SKILLS
    },
    "borderline": $BORDERLINE_ITEMS
  },
  "approved_items": $(printf '%s\n' "${APPROVED_LIST[@]}" | jq -R . | jq -s .),
  "rejected_items": $(printf '%s\n' "${REJECTED_LIST[@]}" | jq -R . | jq -s .),
  "borderline_items": $(printf '%s\n' "${BORDERLINE_LIST[@]}" | jq -R . | jq -s .),
  "approval_rate": $(echo "scale=1; ($APPROVED_AGENTS + $APPROVED_SKILLS) * 100 / $TOTAL_ITEMS" | bc 2>/dev/null || echo "0"),
  "cost_incurred": 0.00,
  "reports_directory": "$REPORTS_DIR"
}
EOF

# Print summary
echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║          ANTIGRAVITY KIT SCAN COMPLETE                     ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Total Items:       ${BOLD}$TOTAL_ITEMS${NC}"
echo -e "  Scanned:           ${BOLD}$SCANNED_ITEMS${NC}"
echo ""
echo -e "  ${MAGENTA}Agents:${NC}"
echo -e "    ${GREEN}✓ Approved:${NC}      $APPROVED_AGENTS / $AGENT_COUNT"
echo -e "    ${RED}✗ Rejected:${NC}      $REJECTED_AGENTS / $AGENT_COUNT"
echo ""
echo -e "  ${MAGENTA}Skills:${NC}"
echo -e "    ${GREEN}✓ Approved:${NC}      $APPROVED_SKILLS / $SKILL_DIRS"
echo -e "    ${RED}✗ Rejected:${NC}      $REJECTED_SKILLS / $SKILL_DIRS"
echo ""
echo -e "  ${YELLOW}⚠ Borderline:${NC}      $BORDERLINE_ITEMS"
echo ""
echo -e "  Approval Rate:     $(echo "scale=1; ($APPROVED_AGENTS + $APPROVED_SKILLS) * 100 / $TOTAL_ITEMS" | bc 2>/dev/null || echo "0")%"
echo -e "  Cost:              ${GREEN}\$0.00${NC} (4-layer scan, no AI)"
echo ""
echo -e "  Summary Report:    ${CYAN}$SUMMARY_FILE${NC}"
echo ""

# List borderline for review
if [ $BORDERLINE_ITEMS -gt 0 ]; then
    echo -e "${YELLOW}${BOLD}Items Requiring Manual Review:${NC}"
    for item in "${BORDERLINE_LIST[@]}"; do
        echo -e "  ${YELLOW}⚠${NC} $item"
    done
    echo ""
fi

log_success "Antigravity Kit scan complete!"
log_info "Approved items copied to:"
log_info "  Agents: $TARGET_AGENTS"
log_info "  Skills: $TARGET_SKILLS"

# Don't cleanup - keep for review
log_info "Source files preserved at: $TEMP_DIR"

# Exit based on results
if [ $REJECTED_AGENTS -eq 0 ] && [ $REJECTED_SKILLS -eq 0 ] && [ $BORDERLINE_ITEMS -eq 0 ]; then
    exit 0
elif [ $BORDERLINE_ITEMS -gt 0 ]; then
    exit 2
else
    exit 1
fi
