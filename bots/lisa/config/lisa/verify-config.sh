#!/bin/bash
# ============================================================================
# OpenClaw Configuration Verification Script
# ============================================================================
#
# This script verifies that the OpenClaw multi-model routing configuration
# is correctly set up and all required components are in place.
#
# Usage:
#   chmod +x verify-config.sh
#   ./verify-config.sh
#
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}============================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# ============================================================================
# Verification Steps
# ============================================================================

print_header "OpenClaw Multi-Model Routing Configuration Verification"

# Check 1: Configuration file exists
print_info "Checking configuration file..."
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
    print_success "Configuration file exists: ~/.openclaw/openclaw.json"
else
    print_error "Configuration file not found: ~/.openclaw/openclaw.json"
    echo "  Expected location: ~/.openclaw/openclaw.json"
    echo "  Please copy openclaw.json to this location"
fi

# Check 2: Environment file exists
print_info "Checking environment file..."
if [ -f "$HOME/.openclaw/.env" ]; then
    print_success "Environment file exists: ~/.openclaw/.env"
else
    print_warning "Environment file not found: ~/.openclaw/.env"
    echo "  Create from .env.example and add your API keys"
fi

# Check 3: Environment file permissions
if [ -f "$HOME/.openclaw/.env" ]; then
    PERMS=$(stat -f "%A" "$HOME/.openclaw/.env" 2>/dev/null || stat -c "%a" "$HOME/.openclaw/.env" 2>/dev/null)
    if [ "$PERMS" = "600" ]; then
        print_success "Environment file has secure permissions (600)"
    else
        print_warning "Environment file permissions are $PERMS (should be 600)"
        echo "  Run: chmod 600 ~/.openclaw/.env"
    fi
fi

# Check 4: OpenClaw is installed
print_info "Checking OpenClaw installation..."
if command -v openclaw &> /dev/null; then
    VERSION=$(openclaw --version 2>/dev/null || echo "unknown")
    print_success "OpenClaw is installed: $VERSION"
else
    print_error "OpenClaw command not found"
    echo "  Install OpenClaw first: https://docs.openclaw.com/install"
fi

# Check 5: Configuration syntax
if command -v openclaw &> /dev/null; then
    print_info "Validating configuration syntax..."
    if openclaw doctor &> /dev/null; then
        print_success "Configuration syntax is valid"
    else
        print_error "Configuration has syntax errors"
        echo "  Run: openclaw doctor"
        echo "  Fix: openclaw doctor --fix"
    fi
fi

# Check 6: Required API keys
print_info "Checking required API keys..."
if [ -f "$HOME/.openclaw/.env" ]; then
    # Source the .env file
    set -a
    source "$HOME/.openclaw/.env" 2>/dev/null || true
    set +a
    
    # Check Anthropic
    if [ -n "$ANTHROPIC_API_KEY" ] && [ "$ANTHROPIC_API_KEY" != "sk-ant-your-key-here" ]; then
        print_success "ANTHROPIC_API_KEY is set"
    else
        print_error "ANTHROPIC_API_KEY is not set or is placeholder"
        echo "  Get key from: https://console.anthropic.com/"
    fi
    
    # Check Google
    if [ -n "$GOOGLE_API_KEY" ] && [ "$GOOGLE_API_KEY" != "your-google-api-key-here" ]; then
        print_success "GOOGLE_API_KEY is set"
    else
        print_error "GOOGLE_API_KEY is not set or is placeholder"
        echo "  Get key from: https://makersuite.google.com/app/apikey"
    fi
fi

# Check 7: Optional API keys
print_info "Checking optional API keys..."
if [ -f "$HOME/.openclaw/.env" ]; then
    # Check OpenAI
    if [ -n "$OPENAI_API_KEY" ] && [ "$OPENAI_API_KEY" != "sk-your-openai-key-here" ]; then
        print_success "OPENAI_API_KEY is set (recommended)"
    else
        print_warning "OPENAI_API_KEY is not set (optional but recommended)"
        echo "  Get key from: https://platform.openai.com/api-keys"
    fi
    
    # Check DeepSeek
    if [ -n "$DEEPSEEK_API_KEY" ] && [ "$DEEPSEEK_API_KEY" != "your-deepseek-key-here" ]; then
        print_success "DEEPSEEK_API_KEY is set (recommended)"
    else
        print_warning "DEEPSEEK_API_KEY is not set (optional but recommended)"
        echo "  Get key from: https://platform.deepseek.com/"
    fi
    
    # Check OpenRouter
    if [ -n "$OPENROUTER_API_KEY" ] && [ "$OPENROUTER_API_KEY" != "sk-or-your-key-here" ]; then
        print_success "OPENROUTER_API_KEY is set (recommended)"
    else
        print_warning "OPENROUTER_API_KEY is not set (optional but recommended)"
        echo "  Get key from: https://openrouter.ai/keys"
    fi
fi

# Check 8: Model authentication
if command -v openclaw &> /dev/null && openclaw doctor &> /dev/null; then
    print_info "Checking model authentication..."
    if openclaw models status &> /dev/null; then
        print_success "Model authentication check passed"
        
        # Check specific providers
        if openclaw models status 2>/dev/null | grep -q "anthropic"; then
            print_success "Anthropic provider authenticated"
        else
            print_warning "Anthropic provider not authenticated"
        fi
        
        if openclaw models status 2>/dev/null | grep -q "google"; then
            print_success "Google provider authenticated"
        else
            print_warning "Google provider not authenticated"
        fi
    else
        print_warning "Could not verify model authentication"
        echo "  Run: openclaw models status"
    fi
fi

# Check 9: Primary model configuration
print_info "Checking primary model configuration..."
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
    if grep -q "claude-sonnet-4-5" "$HOME/.openclaw/openclaw.json"; then
        print_success "Primary model set to Claude Sonnet 4.5"
    else
        print_warning "Primary model may not be set to Claude Sonnet 4.5"
        echo "  Check: agents.defaults.model.primary in openclaw.json"
    fi
fi

# Check 10: Fallback chain configuration
print_info "Checking fallback chain configuration..."
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
    if grep -q "fallbacks" "$HOME/.openclaw/openclaw.json"; then
        print_success "Fallback chain is configured"
    else
        print_warning "Fallback chain may not be configured"
        echo "  Check: agents.defaults.model.fallbacks in openclaw.json"
    fi
fi

# Check 11: Heartbeat configuration
print_info "Checking heartbeat configuration..."
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
    if grep -q "heartbeat" "$HOME/.openclaw/openclaw.json"; then
        print_success "Heartbeat is configured"
        
        if grep -q "gemini-2.5-flash-lite" "$HOME/.openclaw/openclaw.json"; then
            print_success "Heartbeat uses cost-optimized model"
        else
            print_warning "Heartbeat may not use cost-optimized model"
        fi
    else
        print_warning "Heartbeat configuration not found"
    fi
fi

# Check 12: Subagent configuration
print_info "Checking subagent configuration..."
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
    if grep -q "subagents" "$HOME/.openclaw/openclaw.json"; then
        print_success "Subagent configuration found"
        
        if grep -q "deepseek" "$HOME/.openclaw/openclaw.json"; then
            print_success "Subagents use cost-optimized model"
        else
            print_warning "Subagents may not use cost-optimized model"
        fi
    else
        print_warning "Subagent configuration not found"
    fi
fi

# Check 13: Image model configuration
print_info "Checking image model configuration..."
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
    if grep -q "imageModel" "$HOME/.openclaw/openclaw.json"; then
        print_success "Image model is configured"
        
        if grep -q "gemini-3-flash" "$HOME/.openclaw/openclaw.json"; then
            print_success "Image model uses cost-optimized option"
        else
            print_warning "Image model may not use cost-optimized option"
        fi
    else
        print_warning "Image model configuration not found"
    fi
fi

# Check 14: Gateway configuration
print_info "Checking gateway configuration..."
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
    if grep -q "gateway" "$HOME/.openclaw/openclaw.json"; then
        print_success "Gateway configuration found"
    else
        print_warning "Gateway configuration not found"
    fi
fi

# Check 15: Documentation files
print_info "Checking documentation files..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/COST_ANALYSIS.md" ]; then
    print_success "COST_ANALYSIS.md found"
else
    print_warning "COST_ANALYSIS.md not found in config directory"
fi

if [ -f "$SCRIPT_DIR/MODEL_USAGE.md" ]; then
    print_success "MODEL_USAGE.md found"
else
    print_warning "MODEL_USAGE.md not found in config directory"
fi

if [ -f "$SCRIPT_DIR/DEPLOYMENT_GUIDE.md" ]; then
    print_success "DEPLOYMENT_GUIDE.md found"
else
    print_warning "DEPLOYMENT_GUIDE.md not found in config directory"
fi

# ============================================================================
# Summary
# ============================================================================

print_header "Verification Summary"

echo "Results:"
echo -e "  ${GREEN}Passed:${NC}   $PASSED"
echo -e "  ${RED}Failed:${NC}   $FAILED"
echo -e "  ${YELLOW}Warnings:${NC} $WARNINGS"
echo ""

if [ $FAILED -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}✓ Configuration is ready for deployment!${NC}"
        echo ""
        echo "Next steps:"
        echo "  1. Review DEPLOYMENT_GUIDE.md for deployment instructions"
        echo "  2. Start OpenClaw: openclaw start"
        echo "  3. Test models: openclaw chat 'Hello'"
        echo "  4. Monitor costs: openclaw status --usage"
    else
        echo -e "${YELLOW}⚠ Configuration is mostly ready, but has some warnings${NC}"
        echo ""
        echo "Recommended actions:"
        echo "  1. Review warnings above and address if needed"
        echo "  2. Optional API keys improve resilience"
        echo "  3. See DEPLOYMENT_GUIDE.md for details"
    fi
else
    echo -e "${RED}✗ Configuration has errors that must be fixed${NC}"
    echo ""
    echo "Required actions:"
    echo "  1. Fix all errors listed above"
    echo "  2. Run this script again to verify"
    echo "  3. See DEPLOYMENT_GUIDE.md for help"
    exit 1
fi

echo ""
print_info "For detailed deployment instructions, see: DEPLOYMENT_GUIDE.md"
print_info "For cost analysis and savings, see: COST_ANALYSIS.md"
print_info "For model usage guide, see: MODEL_USAGE.md"
echo ""
