#!/bin/bash
#
# Google Workspace MCP Skills OAuth Setup Script
# Authenticates google-docs, google-sheets, and gmail-integration skills
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
log_error() { echo -e "${RED}✗${NC}  $1"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$MONOREPO_ROOT/skills/shared"

log_info "Google Workspace MCP Skills OAuth Setup"
echo ""

# Check if running on VPS or locally
if [ -d "/root/linkbot" ]; then
    SKILLS_DIR="/root/linkbot/skills/shared"
    log_info "Detected VPS environment"
else
    log_info "Detected local environment"
fi

# Authenticate Google Docs MCP Skill (Node.js)
log_info "Setting up google-docs skill..."
cd "$SKILLS_DIR/google-docs"

if [ ! -f "credentials.json" ]; then
    log_error "credentials.json not found in google-docs/\nPlease create it first."
fi

log_info "Starting OAuth flow for google-docs..."
log_warn "This will open an authorization URL. Please:"
log_warn "1. Open the URL in your browser"
log_warn "2. Log in with Lisa's Google account (lisa@linktrend.media)"
log_warn "3. Approve the permissions"
log_warn "4. Copy the authorization code"
echo ""

# Run the MCP server's built-in auth (if available) or use Node.js auth
if [ -f "auth-helper.js" ]; then
    node auth-helper.js
elif command -v node &> /dev/null; then
    # Try to run the server once to trigger auth
    log_info "Attempting automatic OAuth flow..."
    timeout 60 node index.js || true
fi

if [ -f "token.json" ]; then
    log_success "google-docs authenticated successfully!"
else
    log_warn "token.json not created. Manual authentication may be required."
fi

echo ""
echo "---"
echo ""

# Authenticate Google Sheets MCP Skill (Python)
log_info "Setting up google-sheets skill..."
cd "$SKILLS_DIR/google-sheets"

if [ ! -f "credentials.json" ]; then
    log_error "credentials.json not found in google-sheets/\nPlease create it first."
fi

# For Python MCP, set environment variables
export CREDENTIALS_PATH="$(pwd)/credentials.json"
export TOKEN_PATH="$(pwd)/token.json"

log_info "Google Sheets can use service account OR OAuth."
log_info "Using OAuth credentials from credentials.json"

# Try to run a quick auth check
if command -v python3 &> /dev/null; then
    log_info "Running Python OAuth flow..."
    python3 << 'EOPY' || true
import os
import sys
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

SCOPES = [
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/drive'
]

try:
    creds = None
    token_path = 'token.json'
    creds_path = 'credentials.json'
    
    if os.path.exists(token_path):
        print("Token already exists, skipping auth")
        sys.exit(0)
    
    if not os.path.exists(creds_path):
        print(f"ERROR: {creds_path} not found")
        sys.exit(1)
    
    flow = InstalledAppFlow.from_client_secrets_file(creds_path, SCOPES)
    
    # Use run_local_server which handles the OAuth flow automatically
    creds = flow.run_local_server(port=0, open_browser=False, authorization_prompt_message='')
    
    with open(token_path, 'w') as token_file:
        token_file.write(creds.to_json())
    
    print(f"Token saved to {token_path}")
    sys.exit(0)
    
except Exception as e:
    print(f"Auth error: {e}")
    sys.exit(1)
EOPY
fi

if [ -f "token.json" ]; then
    log_success "google-sheets authenticated successfully!"
else
    log_warn "token.json not created. Manual authentication may be required."
fi

echo ""
echo "---"
echo ""

# Authenticate Gmail Integration MCP Skill (Python)
log_info "Setting up gmail-integration skill..."
cd "$SKILLS_DIR/gmail-integration"

log_info "Gmail integration uses different auth method (config-based)"
log_info "Credentials will be passed via OpenClaw environment variables"

# Create token storage directory
TOKEN_DIR="$HOME/gmail_mcp_tokens"
mkdir -p "$TOKEN_DIR"

log_info "Gmail MCP token storage: $TOKEN_DIR"

if [ -f "$TOKEN_DIR/tokens.json" ]; then
    log_success "gmail-integration tokens already exist!"
else
    log_warn "gmail-integration tokens not yet created."
    log_warn "They will be created when the skill first runs via OpenClaw."
fi

echo ""
echo "---"
echo ""

# Summary
log_success "OAuth Setup Complete!"
echo ""
log_info "Status Summary:"
echo ""

if [ -f "$SKILLS_DIR/google-docs/token.json" ]; then
    echo -e "  ${GREEN}✓${NC} google-docs: Authenticated"
else
    echo -e "  ${YELLOW}⚠${NC} google-docs: Needs manual auth"
fi

if [ -f "$SKILLS_DIR/google-sheets/token.json" ]; then
    echo -e "  ${GREEN}✓${NC} google-sheets: Authenticated"
else
    echo -e "  ${YELLOW}⚠${NC} google-sheets: Needs manual auth"
fi

if [ -f "$HOME/gmail_mcp_tokens/tokens.json" ]; then
    echo -e "  ${GREEN}✓${NC} gmail-integration: Authenticated"
else
    echo -e "  ${YELLOW}⚠${NC} gmail-integration: Will auth on first run"
fi

echo ""
log_info "Next Steps:"
echo "  1. Restart OpenClaw service: systemctl restart openclaw"
echo "  2. Test via Telegram: 'Lisa, create a Google Doc titled Test'"
echo "  3. Monitor logs: tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log"
echo ""
