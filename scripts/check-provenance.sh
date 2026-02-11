#!/bin/bash
#
# Automated Provenance Checker
# Analyzes GitHub repository metadata and commit patterns
#
# Usage: ./check-provenance.sh <repo-url> [local-path]
# Output: provenance-report.json
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
log_error() { echo -e "${RED}✗${NC}  $1"; exit 1; }

# Check arguments
if [ $# -lt 1 ]; then
    log_error "Usage: $0 <repo-url> [local-path]"
fi

REPO_URL="$1"
LOCAL_PATH="${2:-}"

# Extract owner/repo from URL
REPO_FULL=$(echo "$REPO_URL" | sed -E 's#.*github\.com[:/]([^/]+/[^/\.]+).*#\1#')
OWNER=$(echo "$REPO_FULL" | cut -d/ -f1)
REPO=$(echo "$REPO_FULL" | cut -d/ -f2)

log_info "Checking provenance for: $OWNER/$REPO"

# Initialize result variables
STARS=0
FORKS=0
CREATED_DATE=""
LAST_PUSH=""
CONTRIBUTORS=0
COMMIT_COUNT=0
RISK_SCORE=0

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    log_warn "GitHub CLI (gh) not found - limited analysis"
    USE_GH=false
else
    USE_GH=true
fi

# Function: Analyze using GitHub API
analyze_github_api() {
    log_info "Fetching GitHub metadata..."
    
    # Get repository info
    REPO_INFO=$(gh api "repos/$OWNER/$REPO" 2>/dev/null || echo '{}')
    
    STARS=$(echo "$REPO_INFO" | jq -r '.stargazers_count // 0')
    FORKS=$(echo "$REPO_INFO" | jq -r '.forks_count // 0')
    CREATED_DATE=$(echo "$REPO_INFO" | jq -r '.created_at // "unknown"')
    LAST_PUSH=$(echo "$REPO_INFO" | jq -r '.pushed_at // "unknown"')
    
    log_info "Stars: $STARS | Forks: $FORKS"
    
    # Get contributor count
    CONTRIBUTORS=$(gh api "repos/$OWNER/$REPO/contributors?per_page=1" --paginate 2>/dev/null | jq -s 'length')
    log_info "Contributors: $CONTRIBUTORS"
    
    # Check for security advisories
    ADVISORIES=$(gh api "repos/$OWNER/$REPO/security-advisories" 2>/dev/null | jq 'length' || echo 0)
    if [ "$ADVISORIES" -gt 0 ]; then
        log_warn "Found $ADVISORIES security advisories"
        RISK_SCORE=$((RISK_SCORE + 20))
    fi
}

# Function: Analyze commit patterns (if local repo available)
analyze_commit_patterns() {
    if [ -z "$LOCAL_PATH" ] || [ ! -d "$LOCAL_PATH/.git" ]; then
        log_info "Skipping commit analysis (no local repo)"
        return
    fi
    
    log_info "Analyzing commit patterns..."
    cd "$LOCAL_PATH"
    
    # Get commit count
    COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo 0)
    log_info "Total commits: $COMMIT_COUNT"
    
    # Check for suspicious commit patterns
    RECENT_COMMITS=$(git log --since="30 days ago" --oneline | wc -l | tr -d ' ')
    
    if [ "$RECENT_COMMITS" -gt 100 ]; then
        log_warn "Very high commit velocity ($RECENT_COMMITS in 30 days)"
        RISK_SCORE=$((RISK_SCORE + 10))
    fi
    
    # Check commit authors diversity
    AUTHOR_COUNT=$(git log --format='%an' | sort -u | wc -l | tr -d ' ')
    
    if [ "$AUTHOR_COUNT" -eq 1 ] && [ "$COMMIT_COUNT" -gt 50 ]; then
        log_warn "Single author with many commits - possible automation"
        RISK_SCORE=$((RISK_SCORE + 5))
    fi
}

# Function: Calculate reputation score
calculate_reputation() {
    local reputation=0
    
    # Stars factor (max 30 points)
    if [ "$STARS" -gt 1000 ]; then
        reputation=$((reputation + 30))
    elif [ "$STARS" -gt 100 ]; then
        reputation=$((reputation + 20))
    elif [ "$STARS" -gt 10 ]; then
        reputation=$((reputation + 10))
    fi
    
    # Contributor diversity (max 20 points)
    if [ "$CONTRIBUTORS" -gt 10 ]; then
        reputation=$((reputation + 20))
    elif [ "$CONTRIBUTORS" -gt 5 ]; then
        reputation=$((reputation + 15))
    elif [ "$CONTRIBUTORS" -gt 2 ]; then
        reputation=$((reputation + 10))
    fi
    
    # Age and activity (max 10 points)
    if [ -n "$CREATED_DATE" ] && [ "$CREATED_DATE" != "unknown" ]; then
        DAYS_OLD=$(( ( $(date +%s) - $(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$CREATED_DATE" +%s 2>/dev/null || date +%s) ) / 86400 ))
        
        if [ "$DAYS_OLD" -gt 365 ]; then
            reputation=$((reputation + 10))
        elif [ "$DAYS_OLD" -gt 90 ]; then
            reputation=$((reputation + 5))
        fi
    fi
    
    echo $reputation
}

# Execute analysis
if [ "$USE_GH" = true ]; then
    analyze_github_api
else
    log_warn "Using limited analysis without GitHub CLI"
fi

analyze_commit_patterns

# Calculate reputation
REPUTATION=$(calculate_reputation)
log_info "Reputation score: $REPUTATION/60"

# Adjust risk based on reputation
if [ "$REPUTATION" -lt 20 ]; then
    RISK_SCORE=$((RISK_SCORE + 25))
    log_warn "Low reputation - adding +25 to risk score"
elif [ "$REPUTATION" -lt 40 ]; then
    RISK_SCORE=$((RISK_SCORE + 10))
    log_warn "Medium reputation - adding +10 to risk score"
fi

# Generate report
cat > "$OUTPUT_FILE" << EOF
{
  "repo_url": "$REPO_URL",
  "owner": "$OWNER",
  "repo": "$REPO",
  "github_stats": {
    "stars": $STARS,
    "forks": $FORKS,
    "contributors": $CONTRIBUTORS,
    "created_at": "$CREATED_DATE",
    "last_push": "$LAST_PUSH",
    "commit_count": $COMMIT_COUNT
  },
  "reputation_score": $REPUTATION,
  "risk_score": $RISK_SCORE,
  "analysis_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "recommendation": "$([ $RISK_SCORE -le 30 ] && echo "LOW_RISK" || echo "REVIEW_REQUIRED")"
}
EOF

log_success "Provenance check complete"
log_info "Risk Score: $RISK_SCORE"
log_info "Report: $OUTPUT_FILE"

# Exit code based on risk
if [ "$RISK_SCORE" -le 30 ]; then
    exit 0
else
    exit 1
fi
