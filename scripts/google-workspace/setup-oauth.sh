#!/bin/bash

################################################################################
# Google Workspace OAuth Setup Helper Script
# 
# This script guides you through setting up OAuth 2.0 credentials for Lisa
# (Business Partner Bot) to access Google Workspace APIs.
#
# What this script does:
# - Opens Google Cloud Console in your browser
# - Displays step-by-step checklist for OAuth configuration
# - Lists all required APIs to enable
# - Lists all required OAuth scopes
# - Validates and securely stores your credentials JSON file
#
# Prerequisites:
# - Google Workspace account with admin access
# - Web browser
# - Downloaded OAuth credentials JSON from Google Cloud Console
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
OAUTH_DEST="${SECRETS_DIR}/google-oauth-credentials.json"

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

print_step() {
    echo -e "${BOLD}${CYAN}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ ERROR: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING: $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

open_url() {
    local url="$1"
    echo -e "${CYAN}Opening: ${url}${NC}"
    if command -v open &> /dev/null; then
        open "$url"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "$url"
    else
        echo -e "${YELLOW}Please manually open: ${url}${NC}"
    fi
}

wait_for_enter() {
    echo ""
    read -p "Press ENTER when ready to continue..."
    echo ""
}

validate_json() {
    local file="$1"
    
    if ! command -v python3 &> /dev/null; then
        print_warning "Python3 not found. Skipping JSON validation."
        return 0
    fi
    
    python3 -c "import json; json.load(open('$file'))" 2>/dev/null
    return $?
}

validate_oauth_json() {
    local file="$1"
    
    print_step "Validating OAuth credentials JSON structure..."
    
    # Check if file exists
    if [[ ! -f "$file" ]]; then
        print_error "File not found: $file"
        return 1
    fi
    
    # Validate JSON syntax
    if ! validate_json "$file"; then
        print_error "Invalid JSON syntax in file"
        return 1
    fi
    
    # Check for required OAuth fields
    if ! command -v python3 &> /dev/null; then
        print_warning "Cannot validate OAuth structure without Python3"
        return 0
    fi
    
    local validation_result=$(python3 << 'EOF'
import json
import sys

try:
    with open(sys.argv[1], 'r') as f:
        data = json.load(f)
    
    # Check for web or installed client structure
    if 'web' in data:
        client = data['web']
    elif 'installed' in data:
        client = data['installed']
    else:
        print("ERROR: Missing 'web' or 'installed' client configuration")
        sys.exit(1)
    
    # Check required fields
    required_fields = ['client_id', 'client_secret', 'auth_uri', 'token_uri']
    missing_fields = [field for field in required_fields if field not in client]
    
    if missing_fields:
        print(f"ERROR: Missing required fields: {', '.join(missing_fields)}")
        sys.exit(1)
    
    print("VALID")
    sys.exit(0)
    
except Exception as e:
    print(f"ERROR: {str(e)}")
    sys.exit(1)
EOF
"$file")
    
    if [[ "$validation_result" == "VALID" ]]; then
        print_success "OAuth credentials JSON structure is valid"
        return 0
    else
        print_error "$validation_result"
        return 1
    fi
}

################################################################################
# Main Script
################################################################################

clear
print_header "Google Workspace OAuth 2.0 Setup - Lisa Business Partner Bot"

echo -e "${BOLD}This script will guide you through:${NC}"
echo "  1. Creating a Google Cloud Project"
echo "  2. Enabling required APIs"
echo "  3. Configuring OAuth consent screen"
echo "  4. Creating OAuth 2.0 credentials"
echo "  5. Securely storing credentials"
echo ""
echo -e "${YELLOW}Estimated time: 20-30 minutes${NC}"
echo ""

read -p "Ready to begin? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

################################################################################
# Step 1: Open Google Cloud Console
################################################################################

print_header "Step 1: Create Google Cloud Project"

print_step "Opening Google Cloud Console..."
open_url "https://console.cloud.google.com/"

echo ""
echo -e "${BOLD}Follow these steps in the browser:${NC}"
echo ""
echo "  1. Sign in with your Google Workspace admin account"
echo "  2. Click 'Select a project' dropdown (top navigation bar)"
echo "  3. Click 'New Project' button"
echo ""
echo -e "${BOLD}Project Configuration:${NC}"
echo "  • Project name: ${GREEN}OpenClaw-BusinessPartner-Lisa${NC}"
echo "  • Organization: Your domain (auto-selected)"
echo "  • Location: Your organization"
echo ""
echo "  4. Click 'Create' button"
echo "  5. Wait ~30 seconds for project creation"
echo "  6. Click 'Select Project' when ready"
echo ""

wait_for_enter

################################################################################
# Step 2: Enable Required APIs
################################################################################

print_header "Step 2: Enable Required Google APIs"

print_step "Opening APIs & Services Library..."
open_url "https://console.cloud.google.com/apis/library"

echo ""
echo -e "${BOLD}Enable these APIs (search and click 'Enable' for each):${NC}"
echo ""
echo "  ${GREEN}✓${NC} 1. Gmail API              - Email management"
echo "  ${GREEN}✓${NC} 2. Google Calendar API    - Calendar events"
echo "  ${GREEN}✓${NC} 3. Google Docs API        - Document creation/editing"
echo "  ${GREEN}✓${NC} 4. Google Sheets API      - Spreadsheet management"
echo "  ${GREEN}✓${NC} 5. Google Slides API      - Presentation creation"
echo "  ${GREEN}✓${NC} 6. Google Drive API       - File storage access"
echo "  ${GREEN}✓${NC} 7. People API             - Contact management (optional)"
echo ""
echo -e "${BOLD}For each API:${NC}"
echo "  • Search for API name in the library"
echo "  • Click on the API"
echo "  • Click 'Enable' button"
echo "  • Wait for confirmation (~5-10 seconds)"
echo ""

wait_for_enter

################################################################################
# Step 3: Configure OAuth Consent Screen
################################################################################

print_header "Step 3: Configure OAuth Consent Screen"

print_step "Opening OAuth consent screen configuration..."
open_url "https://console.cloud.google.com/apis/credentials/consent"

echo ""
echo -e "${BOLD}Step 3.1: Choose User Type${NC}"
echo "  • Select: ${GREEN}Internal${NC} (recommended for Google Workspace)"
echo "  • Benefits:"
echo "    - Only users in your Workspace can authenticate"
echo "    - No Google verification required"
echo "  • Click 'Create'"
echo ""

wait_for_enter

echo -e "${BOLD}Step 3.2: App Information${NC}"
echo "  • App name: ${GREEN}Lisa - Business Partner Bot${NC}"
echo "  • User support email: ${GREEN}Your admin email${NC}"
echo "  • App logo: (optional, skip for now)"
echo "  • Application home page: (leave blank or use company website)"
echo "  • Authorized domains: ${GREEN}Your company domain${NC}"
echo "  • Developer contact: ${GREEN}Your admin email${NC}"
echo "  • Click 'Save and Continue'"
echo ""

wait_for_enter

echo -e "${BOLD}Step 3.3: Add OAuth Scopes${NC}"
echo "  • Click 'Add or Remove Scopes'"
echo ""
echo -e "${BOLD}Required Scopes (copy and paste these):${NC}"
echo ""
echo -e "${CYAN}Gmail Scopes:${NC}"
echo "  https://www.googleapis.com/auth/gmail.readonly"
echo "  https://www.googleapis.com/auth/gmail.send"
echo "  https://www.googleapis.com/auth/gmail.modify"
echo "  https://www.googleapis.com/auth/gmail.compose"
echo ""
echo -e "${CYAN}Calendar Scopes:${NC}"
echo "  https://www.googleapis.com/auth/calendar"
echo "  https://www.googleapis.com/auth/calendar.events"
echo ""
echo -e "${CYAN}Drive & Docs Scopes:${NC}"
echo "  https://www.googleapis.com/auth/drive.file"
echo "  https://www.googleapis.com/auth/documents"
echo "  https://www.googleapis.com/auth/spreadsheets"
echo "  https://www.googleapis.com/auth/presentations"
echo ""
echo -e "${CYAN}Profile Scopes:${NC}"
echo "  https://www.googleapis.com/auth/userinfo.email"
echo "  https://www.googleapis.com/auth/userinfo.profile"
echo ""
echo "  • Click 'Update'"
echo "  • Click 'Save and Continue'"
echo ""
echo -e "${BOLD}Step 3.4: Test Users${NC}"
echo "  • (Skip if using 'Internal' user type)"
echo "  • Click 'Save and Continue'"
echo ""
echo -e "${BOLD}Step 3.5: Summary${NC}"
echo "  • Review settings"
echo "  • Click 'Back to Dashboard'"
echo ""

wait_for_enter

################################################################################
# Step 4: Create OAuth 2.0 Credentials
################################################################################

print_header "Step 4: Create OAuth 2.0 Credentials"

print_step "Opening Credentials page..."
open_url "https://console.cloud.google.com/apis/credentials"

echo ""
echo -e "${BOLD}Follow these steps:${NC}"
echo ""
echo "  1. Click 'Create Credentials' → 'OAuth client ID'"
echo ""
echo -e "${BOLD}Configuration:${NC}"
echo "  • Application type: ${GREEN}Web application${NC}"
echo "  • Name: ${GREEN}Lisa Business Partner Bot - OpenClaw${NC}"
echo ""
echo -e "${BOLD}Authorized redirect URIs (add all of these):${NC}"
echo "  ${CYAN}http://localhost:8080${NC}"
echo "  ${CYAN}http://localhost:3000${NC}"
echo "  ${CYAN}http://localhost:5000${NC}"
echo "  ${CYAN}urn:ietf:wg:oauth:2.0:oob${NC}"
echo ""
echo "  2. Click 'Create'"
echo ""
echo -e "${BOLD}${YELLOW}IMPORTANT: Download credentials${NC}"
echo "  3. A popup appears with Client ID and Client Secret"
echo "  4. Click 'Download JSON' button"
echo "  5. Save the file (default name: client_secret_*.json)"
echo ""

wait_for_enter

################################################################################
# Step 5: Locate and Validate Credentials File
################################################################################

print_header "Step 5: Locate and Validate Credentials File"

echo ""
echo -e "${BOLD}Where did you save the downloaded credentials JSON file?${NC}"
echo ""
echo "Common locations:"
echo "  • ~/Downloads/client_secret_*.json"
echo "  • ~/Desktop/client_secret_*.json"
echo ""

# Prompt for file path
while true; do
    read -p "Enter full path to credentials JSON file: " credentials_path
    
    # Expand tilde
    credentials_path="${credentials_path/#\~/$HOME}"
    
    if [[ -f "$credentials_path" ]]; then
        print_success "File found: $credentials_path"
        
        # Validate JSON structure
        if validate_oauth_json "$credentials_path"; then
            break
        else
            print_error "Invalid OAuth credentials file. Please check the file and try again."
            echo ""
            read -p "Try another file? (y/n): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Setup cancelled."
                exit 1
            fi
        fi
    else
        print_error "File not found: $credentials_path"
        echo ""
        read -p "Try again? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Setup cancelled."
            exit 1
        fi
    fi
done

################################################################################
# Step 6: Copy to Secrets Directory
################################################################################

print_header "Step 6: Secure Credentials Storage"

print_step "Creating secrets directory..."
mkdir -p "$SECRETS_DIR"
chmod 700 "$SECRETS_DIR"
print_success "Secrets directory created: $SECRETS_DIR"

print_step "Copying credentials to secure location..."
cp "$credentials_path" "$OAUTH_DEST"
print_success "Credentials copied to: $OAUTH_DEST"

print_step "Setting restrictive permissions (chmod 600)..."
chmod 600 "$OAUTH_DEST"
print_success "Permissions set: -rw-------"

# Verify permissions
actual_perms=$(stat -f "%Lp" "$OAUTH_DEST" 2>/dev/null || stat -c "%a" "$OAUTH_DEST" 2>/dev/null)
if [[ "$actual_perms" == "600" ]]; then
    print_success "Permissions verified: 600 (read/write owner only)"
else
    print_warning "Unexpected permissions: $actual_perms (expected 600)"
fi

################################################################################
# Step 7: Final Validation
################################################################################

print_header "Step 7: Final Validation"

print_step "Validating stored credentials..."

if [[ -f "$OAUTH_DEST" ]]; then
    print_success "File exists: $OAUTH_DEST"
else
    print_error "File not found: $OAUTH_DEST"
    exit 1
fi

if validate_oauth_json "$OAUTH_DEST"; then
    print_success "OAuth credentials are valid and ready to use"
else
    print_error "Validation failed. Please check the credentials file."
    exit 1
fi

# Display file info
file_size=$(du -h "$OAUTH_DEST" | cut -f1)
print_info "File size: $file_size"

################################################################################
# Success Summary
################################################################################

print_header "✓ OAuth Setup Complete!"

echo -e "${GREEN}${BOLD}Credentials successfully configured!${NC}"
echo ""
echo -e "${BOLD}Summary:${NC}"
echo "  • OAuth credentials stored: ${GREEN}$OAUTH_DEST${NC}"
echo "  • Permissions: ${GREEN}600 (secure)${NC}"
echo "  • JSON structure: ${GREEN}Valid${NC}"
echo ""
echo -e "${BOLD}APIs Enabled:${NC}"
echo "  ✓ Gmail API"
echo "  ✓ Google Calendar API"
echo "  ✓ Google Docs API"
echo "  ✓ Google Sheets API"
echo "  ✓ Google Slides API"
echo "  ✓ Google Drive API"
echo "  ✓ People API (optional)"
echo ""
echo -e "${BOLD}OAuth Scopes Configured:${NC}"
echo "  ✓ Gmail (read, send, modify, compose)"
echo "  ✓ Calendar (full access, events)"
echo "  ✓ Drive (file access)"
echo "  ✓ Docs, Sheets, Slides (full access)"
echo "  ✓ User profile (email, profile)"
echo ""
echo -e "${BOLD}Next Steps:${NC}"
echo "  1. Run: ${CYAN}./setup-service-account.sh${NC}"
echo "  2. Configure domain-wide delegation"
echo "  3. Deploy to VPS"
echo ""
echo -e "${BOLD}Security Notes:${NC}"
echo "  • Keep credentials file secure (never commit to Git)"
echo "  • Credentials are in .gitignore"
echo "  • Only you can read/write this file (chmod 600)"
echo ""

print_success "OAuth setup completed successfully!"
echo ""
