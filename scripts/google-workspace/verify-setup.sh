#!/bin/bash

################################################################################
# Google Workspace Setup Verification Script
# 
# This script verifies that OAuth and Service Account credentials are properly
# configured and ready for deployment.
#
# What it checks:
# - Secrets directory exists with correct permissions
# - OAuth credentials file exists and is valid
# - Service account file exists and is valid
# - File permissions are secure (600)
# - JSON structure is correct
# - Required fields are present
#
# Run this after completing both setup scripts.
################################################################################

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Project paths
PROJECT_ROOT="/Users/linktrend/Projects/LiNKbot"
SECRETS_DIR="${PROJECT_ROOT}/config/business-partner/secrets"
OAUTH_FILE="${SECRETS_DIR}/google-oauth-credentials.json"
SERVICE_ACCOUNT_FILE="${SECRETS_DIR}/google-service-account.json"

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BOLD}${CYAN}▶ $1${NC}"
    echo ""
}

print_check() {
    echo -n "  Checking: $1 ... "
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

print_pass() {
    echo -e "${GREEN}✓ PASS${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
}

print_fail() {
    echo -e "${RED}✗ FAIL${NC}"
    if [[ -n "$1" ]]; then
        echo -e "    ${RED}→ $1${NC}"
    fi
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING${NC}"
    if [[ -n "$1" ]]; then
        echo -e "    ${YELLOW}→ $1${NC}"
    fi
    WARNING_CHECKS=$((WARNING_CHECKS + 1))
}

print_info() {
    echo -e "${BLUE}    ℹ $1${NC}"
}

validate_json() {
    local file="$1"
    
    if ! command -v python3 &> /dev/null; then
        return 2  # Python3 not available
    fi
    
    python3 -c "import json; json.load(open('$file'))" 2>/dev/null
    return $?
}

check_oauth_structure() {
    local file="$1"
    
    if ! command -v python3 &> /dev/null; then
        return 2  # Python3 not available
    fi
    
    python3 << 'EOF'
import json
import sys

try:
    with open(sys.argv[1], 'r') as f:
        data = json.load(f)
    
    # Check for web or installed client
    if 'web' in data:
        client = data['web']
    elif 'installed' in data:
        client = data['installed']
    else:
        sys.exit(1)
    
    # Check required fields
    required = ['client_id', 'client_secret', 'auth_uri', 'token_uri']
    if not all(field in client for field in required):
        sys.exit(1)
    
    sys.exit(0)
    
except:
    sys.exit(1)
EOF
"$file"
    return $?
}

check_service_account_structure() {
    local file="$1"
    
    if ! command -v python3 &> /dev/null; then
        return 2  # Python3 not available
    fi
    
    python3 << 'EOF'
import json
import sys

try:
    with open(sys.argv[1], 'r') as f:
        data = json.load(f)
    
    # Check type
    if data.get('type') != 'service_account':
        sys.exit(1)
    
    # Check required fields
    required = ['project_id', 'private_key_id', 'private_key', 'client_email', 'client_id']
    if not all(field in data for field in required):
        sys.exit(1)
    
    sys.exit(0)
    
except:
    sys.exit(1)
EOF
"$file"
    return $?
}

extract_info() {
    local file="$1"
    local field="$2"
    
    if ! command -v python3 &> /dev/null; then
        echo "N/A"
        return
    fi
    
    python3 << EOF
import json
try:
    with open('$file', 'r') as f:
        data = json.load(f)
    
    # Handle nested OAuth structure
    if '$field' in data:
        print(data['$field'])
    elif 'web' in data and '$field' in data['web']:
        print(data['web']['$field'])
    elif 'installed' in data and '$field' in data['installed']:
        print(data['installed']['$field'])
    else:
        print('N/A')
except:
    print('N/A')
EOF
}

################################################################################
# Main Verification
################################################################################

clear
print_header "Google Workspace Setup Verification"

echo -e "${BOLD}This script verifies:${NC}"
echo "  • Secrets directory and permissions"
echo "  • OAuth credentials file and structure"
echo "  • Service account file and structure"
echo "  • File security (permissions)"
echo "  • JSON validity"
echo ""

################################################################################
# Check 1: Secrets Directory
################################################################################

print_section "1. Secrets Directory"

print_check "Secrets directory exists"
if [[ -d "$SECRETS_DIR" ]]; then
    print_pass
else
    print_fail "Directory not found: $SECRETS_DIR"
fi

print_check "Secrets directory permissions (should be 700)"
if [[ -d "$SECRETS_DIR" ]]; then
    perms=$(stat -f "%Lp" "$SECRETS_DIR" 2>/dev/null || stat -c "%a" "$SECRETS_DIR" 2>/dev/null)
    if [[ "$perms" == "700" ]]; then
        print_pass
    else
        print_warning "Permissions are $perms (recommended: 700)"
        print_info "Fix: chmod 700 $SECRETS_DIR"
    fi
else
    print_fail "Directory does not exist"
fi

################################################################################
# Check 2: OAuth Credentials
################################################################################

print_section "2. OAuth Credentials"

print_check "OAuth credentials file exists"
if [[ -f "$OAUTH_FILE" ]]; then
    print_pass
else
    print_fail "File not found: $OAUTH_FILE"
    print_info "Run: ./setup-oauth.sh"
fi

if [[ -f "$OAUTH_FILE" ]]; then
    print_check "OAuth file permissions (should be 600)"
    perms=$(stat -f "%Lp" "$OAUTH_FILE" 2>/dev/null || stat -c "%a" "$OAUTH_FILE" 2>/dev/null)
    if [[ "$perms" == "600" ]]; then
        print_pass
    else
        print_warning "Permissions are $perms (recommended: 600)"
        print_info "Fix: chmod 600 $OAUTH_FILE"
    fi
    
    print_check "OAuth file is valid JSON"
    validate_json "$OAUTH_FILE"
    result=$?
    if [[ $result -eq 0 ]]; then
        print_pass
    elif [[ $result -eq 2 ]]; then
        print_warning "Cannot validate (Python3 not found)"
    else
        print_fail "Invalid JSON syntax"
    fi
    
    print_check "OAuth file has correct structure"
    check_oauth_structure "$OAUTH_FILE"
    result=$?
    if [[ $result -eq 0 ]]; then
        print_pass
    elif [[ $result -eq 2 ]]; then
        print_warning "Cannot validate (Python3 not found)"
    else
        print_fail "Missing required OAuth fields"
    fi
    
    # Display OAuth info
    if command -v python3 &> /dev/null; then
        client_id=$(extract_info "$OAUTH_FILE" "client_id")
        if [[ "$client_id" != "N/A" ]]; then
            print_info "Client ID: ${client_id:0:20}...${client_id: -10}"
        fi
    fi
fi

################################################################################
# Check 3: Service Account
################################################################################

print_section "3. Service Account Credentials"

print_check "Service account file exists"
if [[ -f "$SERVICE_ACCOUNT_FILE" ]]; then
    print_pass
else
    print_fail "File not found: $SERVICE_ACCOUNT_FILE"
    print_info "Run: ./setup-service-account.sh"
fi

if [[ -f "$SERVICE_ACCOUNT_FILE" ]]; then
    print_check "Service account file permissions (should be 600)"
    perms=$(stat -f "%Lp" "$SERVICE_ACCOUNT_FILE" 2>/dev/null || stat -c "%a" "$SERVICE_ACCOUNT_FILE" 2>/dev/null)
    if [[ "$perms" == "600" ]]; then
        print_pass
    else
        print_warning "Permissions are $perms (recommended: 600)"
        print_info "Fix: chmod 600 $SERVICE_ACCOUNT_FILE"
    fi
    
    print_check "Service account file is valid JSON"
    validate_json "$SERVICE_ACCOUNT_FILE"
    result=$?
    if [[ $result -eq 0 ]]; then
        print_pass
    elif [[ $result -eq 2 ]]; then
        print_warning "Cannot validate (Python3 not found)"
    else
        print_fail "Invalid JSON syntax"
    fi
    
    print_check "Service account file has correct structure"
    check_service_account_structure "$SERVICE_ACCOUNT_FILE"
    result=$?
    if [[ $result -eq 0 ]]; then
        print_pass
    elif [[ $result -eq 2 ]]; then
        print_warning "Cannot validate (Python3 not found)"
    else
        print_fail "Missing required service account fields"
    fi
    
    # Display service account info
    if command -v python3 &> /dev/null; then
        project_id=$(extract_info "$SERVICE_ACCOUNT_FILE" "project_id")
        client_email=$(extract_info "$SERVICE_ACCOUNT_FILE" "client_email")
        client_id=$(extract_info "$SERVICE_ACCOUNT_FILE" "client_id")
        
        if [[ "$project_id" != "N/A" ]]; then
            print_info "Project ID: $project_id"
        fi
        if [[ "$client_email" != "N/A" ]]; then
            print_info "Client Email: $client_email"
        fi
        if [[ "$client_id" != "N/A" ]]; then
            print_info "Client ID: $client_id"
        fi
    fi
fi

################################################################################
# Check 4: File Sizes
################################################################################

print_section "4. File Sizes"

if [[ -f "$OAUTH_FILE" ]]; then
    print_check "OAuth file size is reasonable"
    size=$(wc -c < "$OAUTH_FILE")
    if [[ $size -gt 100 && $size -lt 10000 ]]; then
        print_pass
        print_info "Size: $(du -h "$OAUTH_FILE" | cut -f1)"
    else
        print_warning "Unusual file size: $size bytes"
    fi
fi

if [[ -f "$SERVICE_ACCOUNT_FILE" ]]; then
    print_check "Service account file size is reasonable"
    size=$(wc -c < "$SERVICE_ACCOUNT_FILE")
    if [[ $size -gt 1000 && $size -lt 10000 ]]; then
        print_pass
        print_info "Size: $(du -h "$SERVICE_ACCOUNT_FILE" | cut -f1)"
    else
        print_warning "Unusual file size: $size bytes"
    fi
fi

################################################################################
# Summary
################################################################################

print_header "Verification Summary"

echo -e "${BOLD}Results:${NC}"
echo -e "  Total checks: ${BOLD}$TOTAL_CHECKS${NC}"
echo -e "  ${GREEN}Passed: $PASSED_CHECKS${NC}"
echo -e "  ${RED}Failed: $FAILED_CHECKS${NC}"
echo -e "  ${YELLOW}Warnings: $WARNING_CHECKS${NC}"
echo ""

if [[ $FAILED_CHECKS -eq 0 ]]; then
    if [[ $WARNING_CHECKS -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}✓ All checks passed! Setup is complete.${NC}"
        echo ""
        echo -e "${BOLD}Next steps:${NC}"
        echo "  1. Transfer credentials to VPS"
        echo "  2. Configure OpenClaw integration"
        echo "  3. Test Google Workspace access"
        echo ""
    else
        echo -e "${YELLOW}${BOLD}⚠ Setup complete with warnings.${NC}"
        echo ""
        echo "Review warnings above and fix if necessary."
        echo ""
    fi
    exit 0
else
    echo -e "${RED}${BOLD}✗ Setup incomplete or has errors.${NC}"
    echo ""
    echo -e "${BOLD}Action required:${NC}"
    if [[ ! -f "$OAUTH_FILE" ]]; then
        echo "  • Run: ./setup-oauth.sh"
    fi
    if [[ ! -f "$SERVICE_ACCOUNT_FILE" ]]; then
        echo "  • Run: ./setup-service-account.sh"
    fi
    echo ""
    exit 1
fi
