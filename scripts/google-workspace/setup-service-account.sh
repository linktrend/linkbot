#!/bin/bash

################################################################################
# Google Workspace Service Account Setup Helper Script
# 
# This script guides you through setting up a Service Account for Lisa
# (Business Partner Bot) with domain-wide delegation for Google Workspace.
#
# What this script does:
# - Opens Google Cloud Console service accounts page
# - Displays step-by-step checklist
# - Validates and securely stores service account JSON file
# - Extracts client ID for domain-wide delegation
# - Generates formatted scope list for Admin Console
# - Opens Admin Console for delegation setup
#
# Prerequisites:
# - Google Cloud Project already created (run setup-oauth.sh first)
# - Google Workspace admin access
# - Web browser
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
SERVICE_ACCOUNT_DEST="${SECRETS_DIR}/google-service-account.json"

# Required OAuth scopes for domain-wide delegation
REQUIRED_SCOPES=(
    "https://www.googleapis.com/auth/gmail.readonly"
    "https://www.googleapis.com/auth/gmail.send"
    "https://www.googleapis.com/auth/gmail.modify"
    "https://www.googleapis.com/auth/gmail.compose"
    "https://www.googleapis.com/auth/calendar"
    "https://www.googleapis.com/auth/calendar.events"
    "https://www.googleapis.com/auth/drive.file"
    "https://www.googleapis.com/auth/documents"
    "https://www.googleapis.com/auth/spreadsheets"
    "https://www.googleapis.com/auth/presentations"
    "https://www.googleapis.com/auth/userinfo.email"
    "https://www.googleapis.com/auth/userinfo.profile"
)

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

validate_service_account_json() {
    local file="$1"
    
    print_step "Validating service account JSON structure..."
    
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
    
    # Check for required service account fields
    if ! command -v python3 &> /dev/null; then
        print_warning "Cannot validate service account structure without Python3"
        return 0
    fi
    
    local validation_result=$(python3 << 'EOF'
import json
import sys

try:
    with open(sys.argv[1], 'r') as f:
        data = json.load(f)
    
    # Check for service account type
    if data.get('type') != 'service_account':
        print("ERROR: Not a service account JSON file (type should be 'service_account')")
        sys.exit(1)
    
    # Check required fields
    required_fields = [
        'project_id',
        'private_key_id',
        'private_key',
        'client_email',
        'client_id',
        'auth_uri',
        'token_uri'
    ]
    
    missing_fields = [field for field in required_fields if field not in data]
    
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
        print_success "Service account JSON structure is valid"
        return 0
    else
        print_error "$validation_result"
        return 1
    fi
}

extract_client_id() {
    local file="$1"
    
    if ! command -v python3 &> /dev/null; then
        print_warning "Python3 not found. Cannot extract client ID."
        return 1
    fi
    
    python3 << EOF
import json
with open('$file', 'r') as f:
    data = json.load(f)
    print(data.get('client_id', ''))
EOF
}

extract_client_email() {
    local file="$1"
    
    if ! command -v python3 &> /dev/null; then
        print_warning "Python3 not found. Cannot extract client email."
        return 1
    fi
    
    python3 << EOF
import json
with open('$file', 'r') as f:
    data = json.load(f)
    print(data.get('client_email', ''))
EOF
}

extract_project_id() {
    local file="$1"
    
    if ! command -v python3 &> /dev/null; then
        print_warning "Python3 not found. Cannot extract project ID."
        return 1
    fi
    
    python3 << EOF
import json
with open('$file', 'r') as f:
    data = json.load(f)
    print(data.get('project_id', ''))
EOF
}

generate_scope_list() {
    local format="$1"  # "comma" or "newline"
    
    if [[ "$format" == "comma" ]]; then
        # Comma-separated for Admin Console
        local IFS=','
        echo "${REQUIRED_SCOPES[*]}"
    else
        # Newline-separated for display
        printf '%s\n' "${REQUIRED_SCOPES[@]}"
    fi
}

copy_to_clipboard() {
    local text="$1"
    
    if command -v pbcopy &> /dev/null; then
        echo -n "$text" | pbcopy
        return 0
    elif command -v xclip &> /dev/null; then
        echo -n "$text" | xclip -selection clipboard
        return 0
    else
        return 1
    fi
}

################################################################################
# Main Script
################################################################################

clear
print_header "Google Workspace Service Account Setup - Lisa Business Partner Bot"

echo -e "${BOLD}This script will guide you through:${NC}"
echo "  1. Creating a service account"
echo "  2. Generating service account key"
echo "  3. Enabling domain-wide delegation"
echo "  4. Configuring delegation in Admin Console"
echo "  5. Securely storing credentials"
echo ""
echo -e "${YELLOW}Estimated time: 15-20 minutes${NC}"
echo ""
echo -e "${BOLD}Prerequisites:${NC}"
echo "  ✓ Google Cloud Project created (run setup-oauth.sh first)"
echo "  ✓ Google Workspace admin access"
echo ""

read -p "Ready to begin? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

################################################################################
# Step 1: Create Service Account
################################################################################

print_header "Step 1: Create Service Account"

print_step "Opening Google Cloud Console - Service Accounts..."
open_url "https://console.cloud.google.com/iam-admin/serviceaccounts"

echo ""
echo -e "${BOLD}Follow these steps in the browser:${NC}"
echo ""
echo "  1. Ensure correct project is selected (top navigation bar)"
echo "     Project: ${GREEN}OpenClaw-BusinessPartner-Lisa${NC}"
echo ""
echo "  2. Click 'Create Service Account' button"
echo ""
echo -e "${BOLD}Service Account Details:${NC}"
echo "  • Name: ${GREEN}lisa-business-partner-sa${NC}"
echo "  • ID: ${GREEN}lisa-business-partner-sa${NC} (auto-generated)"
echo "  • Description: ${GREEN}Service account for Lisa Business Partner Bot to access Gmail, Calendar, Docs, Sheets, Slides on behalf of users${NC}"
echo ""
echo "  3. Click 'Create and Continue'"
echo ""
echo -e "${BOLD}Grant Access (Step 2):${NC}"
echo "  • Skip this step (we'll use domain-wide delegation instead)"
echo "  • Click 'Continue'"
echo ""
echo -e "${BOLD}Grant Users Access (Step 3):${NC}"
echo "  • Skip this step"
echo "  • Click 'Done'"
echo ""

wait_for_enter

################################################################################
# Step 2: Generate Service Account Key
################################################################################

print_header "Step 2: Generate Service Account Key"

echo ""
echo -e "${BOLD}From the Service Accounts page:${NC}"
echo ""
echo "  1. Find your new service account in the list:"
echo "     ${GREEN}lisa-business-partner-sa@PROJECT_ID.iam.gserviceaccount.com${NC}"
echo ""
echo "  2. Click on the service account email to open details"
echo ""
echo "  3. Go to the 'Keys' tab"
echo ""
echo "  4. Click 'Add Key' → 'Create new key'"
echo ""
echo "  5. Choose format: ${GREEN}JSON${NC}"
echo ""
echo "  6. Click 'Create'"
echo ""
echo -e "${BOLD}${YELLOW}IMPORTANT: The JSON key file will download automatically${NC}"
echo "  • Default name: ${CYAN}PROJECT_ID-xxxxx.json${NC}"
echo "  • Keep this file secure - it contains private key"
echo ""

wait_for_enter

################################################################################
# Step 3: Enable Domain-Wide Delegation
################################################################################

print_header "Step 3: Enable Domain-Wide Delegation"

echo ""
echo -e "${BOLD}Still on the service account details page:${NC}"
echo ""
echo "  1. Scroll to 'Advanced settings' section"
echo ""
echo "  2. Check the box: ${GREEN}Enable Google Workspace Domain-wide Delegation${NC}"
echo ""
echo "  3. Product name for consent screen: ${GREEN}Lisa Business Partner Bot${NC}"
echo ""
echo "  4. Click 'Save'"
echo ""
echo -e "${BOLD}${YELLOW}IMPORTANT: Note the 'Unique ID'${NC}"
echo "  • This is a long number (e.g., 112233445566778899000)"
echo "  • You'll need this for Admin Console delegation"
echo "  • It's displayed in the service account details"
echo ""

wait_for_enter

################################################################################
# Step 4: Locate and Validate Service Account Key
################################################################################

print_header "Step 4: Locate and Validate Service Account Key"

echo ""
echo -e "${BOLD}Where did you save the downloaded service account JSON key?${NC}"
echo ""
echo "Common locations:"
echo "  • ~/Downloads/PROJECT_ID-*.json"
echo "  • ~/Desktop/PROJECT_ID-*.json"
echo ""

# Prompt for file path
while true; do
    read -p "Enter full path to service account JSON file: " sa_path
    
    # Expand tilde
    sa_path="${sa_path/#\~/$HOME}"
    
    if [[ -f "$sa_path" ]]; then
        print_success "File found: $sa_path"
        
        # Validate JSON structure
        if validate_service_account_json "$sa_path"; then
            break
        else
            print_error "Invalid service account file. Please check the file and try again."
            echo ""
            read -p "Try another file? (y/n): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Setup cancelled."
                exit 1
            fi
        fi
    else
        print_error "File not found: $sa_path"
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
# Step 5: Extract Service Account Information
################################################################################

print_header "Step 5: Extract Service Account Information"

print_step "Extracting service account details..."

CLIENT_ID=$(extract_client_id "$sa_path")
CLIENT_EMAIL=$(extract_client_email "$sa_path")
PROJECT_ID=$(extract_project_id "$sa_path")

if [[ -n "$CLIENT_ID" ]]; then
    print_success "Client ID: $CLIENT_ID"
else
    print_error "Could not extract Client ID"
    exit 1
fi

if [[ -n "$CLIENT_EMAIL" ]]; then
    print_success "Client Email: $CLIENT_EMAIL"
else
    print_warning "Could not extract Client Email"
fi

if [[ -n "$PROJECT_ID" ]]; then
    print_success "Project ID: $PROJECT_ID"
else
    print_warning "Could not extract Project ID"
fi

################################################################################
# Step 6: Copy to Secrets Directory
################################################################################

print_header "Step 6: Secure Credentials Storage"

print_step "Creating secrets directory (if not exists)..."
mkdir -p "$SECRETS_DIR"
chmod 700 "$SECRETS_DIR"
print_success "Secrets directory ready: $SECRETS_DIR"

print_step "Copying service account key to secure location..."
cp "$sa_path" "$SERVICE_ACCOUNT_DEST"
print_success "Service account key copied to: $SERVICE_ACCOUNT_DEST"

print_step "Setting restrictive permissions (chmod 600)..."
chmod 600 "$SERVICE_ACCOUNT_DEST"
print_success "Permissions set: -rw-------"

# Verify permissions
actual_perms=$(stat -f "%Lp" "$SERVICE_ACCOUNT_DEST" 2>/dev/null || stat -c "%a" "$SERVICE_ACCOUNT_DEST" 2>/dev/null)
if [[ "$actual_perms" == "600" ]]; then
    print_success "Permissions verified: 600 (read/write owner only)"
else
    print_warning "Unexpected permissions: $actual_perms (expected 600)"
fi

################################################################################
# Step 7: Generate Scope List for Admin Console
################################################################################

print_header "Step 7: Prepare Domain-Wide Delegation Scopes"

print_step "Generating formatted scope list..."

SCOPE_LIST_COMMA=$(generate_scope_list "comma")

echo ""
echo -e "${BOLD}${YELLOW}Copy this information for the next step:${NC}"
echo ""
echo -e "${BOLD}Client ID (for Admin Console):${NC}"
echo -e "${GREEN}${CLIENT_ID}${NC}"
echo ""
echo -e "${BOLD}OAuth Scopes (comma-separated):${NC}"
echo -e "${CYAN}${SCOPE_LIST_COMMA}${NC}"
echo ""

# Try to copy to clipboard
if copy_to_clipboard "$CLIENT_ID"; then
    print_success "Client ID copied to clipboard!"
    echo ""
    echo "Press ENTER to copy scopes to clipboard..."
    read -r
    if copy_to_clipboard "$SCOPE_LIST_COMMA"; then
        print_success "OAuth scopes copied to clipboard!"
    fi
else
    print_info "Manual copy required (clipboard not available)"
fi

echo ""
wait_for_enter

################################################################################
# Step 8: Configure Domain-Wide Delegation in Admin Console
################################################################################

print_header "Step 8: Configure Domain-Wide Delegation"

print_step "Opening Google Workspace Admin Console..."
open_url "https://admin.google.com/ac/owl/domainwidedelegation"

echo ""
echo -e "${BOLD}Follow these steps in the Admin Console:${NC}"
echo ""
echo "  1. Sign in with ${GREEN}Google Workspace admin account${NC}"
echo ""
echo "  2. Navigate to: Security → Access and data control → API controls"
echo "     (or use the direct link that just opened)"
echo ""
echo "  3. Click 'Manage Domain Wide Delegation'"
echo ""
echo "  4. Click 'Add new' button"
echo ""
echo -e "${BOLD}Enter the following information:${NC}"
echo ""
echo "  • Client ID: ${GREEN}${CLIENT_ID}${NC}"
echo ""
echo "  • OAuth Scopes (paste all, comma-separated):"
echo -e "    ${CYAN}${SCOPE_LIST_COMMA}${NC}"
echo ""
echo "  5. Click 'Authorize'"
echo ""
echo -e "${BOLD}Verification:${NC}"
echo "  • You should see your client listed with all scopes"
echo "  • Service account email: ${GREEN}${CLIENT_EMAIL}${NC}"
echo ""
echo -e "${YELLOW}Note: Changes may take 10-15 minutes to propagate${NC}"
echo ""

wait_for_enter

################################################################################
# Step 9: Final Validation
################################################################################

print_header "Step 9: Final Validation"

print_step "Validating stored service account key..."

if [[ -f "$SERVICE_ACCOUNT_DEST" ]]; then
    print_success "File exists: $SERVICE_ACCOUNT_DEST"
else
    print_error "File not found: $SERVICE_ACCOUNT_DEST"
    exit 1
fi

if validate_service_account_json "$SERVICE_ACCOUNT_DEST"; then
    print_success "Service account key is valid and ready to use"
else
    print_error "Validation failed. Please check the service account key file."
    exit 1
fi

# Display file info
file_size=$(du -h "$SERVICE_ACCOUNT_DEST" | cut -f1)
print_info "File size: $file_size"

################################################################################
# Success Summary
################################################################################

print_header "✓ Service Account Setup Complete!"

echo -e "${GREEN}${BOLD}Service account successfully configured!${NC}"
echo ""
echo -e "${BOLD}Summary:${NC}"
echo "  • Service account key stored: ${GREEN}$SERVICE_ACCOUNT_DEST${NC}"
echo "  • Permissions: ${GREEN}600 (secure)${NC}"
echo "  • JSON structure: ${GREEN}Valid${NC}"
echo ""
echo -e "${BOLD}Service Account Details:${NC}"
echo "  • Client ID: ${GREEN}${CLIENT_ID}${NC}"
echo "  • Client Email: ${GREEN}${CLIENT_EMAIL}${NC}"
echo "  • Project ID: ${GREEN}${PROJECT_ID}${NC}"
echo ""
echo -e "${BOLD}Domain-Wide Delegation:${NC}"
echo "  ✓ Enabled in Google Cloud Console"
echo "  ✓ Configured in Google Workspace Admin Console"
echo "  ✓ Authorized for all required scopes"
echo ""
echo -e "${BOLD}Authorized Scopes:${NC}"
echo "  ✓ Gmail (read, send, modify, compose)"
echo "  ✓ Calendar (full access, events)"
echo "  ✓ Drive (file access)"
echo "  ✓ Docs, Sheets, Slides (full access)"
echo "  ✓ User profile (email, profile)"
echo ""
echo -e "${BOLD}Next Steps:${NC}"
echo "  1. Wait 10-15 minutes for delegation changes to propagate"
echo "  2. Transfer credentials to VPS:"
echo "     ${CYAN}scp $SERVICE_ACCOUNT_DEST root@YOUR_VPS_IP:~/.openclaw/secrets/${NC}"
echo "  3. Configure OpenClaw integration"
echo "  4. Test Google Workspace access"
echo ""
echo -e "${BOLD}Security Notes:${NC}"
echo "  • Keep service account key secure (never commit to Git)"
echo "  • Key file is in .gitignore"
echo "  • Only you can read/write this file (chmod 600)"
echo "  • Rotate keys annually for security"
echo ""
echo -e "${BOLD}Documentation:${NC}"
echo "  • Full setup guide: ${CYAN}docs/guides/GOOGLE_WORKSPACE_SETUP.md${NC}"
echo "  • Troubleshooting: See guide Phase 6"
echo ""

print_success "Service account setup completed successfully!"
echo ""

# Optional: Display scope list for reference
echo -e "${BOLD}For reference, here are all authorized scopes:${NC}"
echo ""
generate_scope_list "newline" | while read -r scope; do
    echo "  • $scope"
done
echo ""
