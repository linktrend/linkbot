#!/bin/bash

################################################################################
# VPS Setup Scripts Test Suite
################################################################################
# Description: Tests the VPS setup scripts for syntax errors and basic
#              functionality without making actual changes.
#
# Usage: ./test-scripts.sh
#
# This script performs:
#   - Syntax validation (bash -n)
#   - ShellCheck linting (if available)
#   - Help/usage output tests
#   - Parameter validation tests
################################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

################################################################################
# Test Functions
################################################################################

log_test() {
    echo -e "${BLUE}[TEST]${NC} $*"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $*"
    ((TESTS_PASSED++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $*"
    ((TESTS_FAILED++))
}

log_skip() {
    echo -e "${YELLOW}[SKIP]${NC} $*"
}

run_test() {
    ((TESTS_RUN++))
    log_test "$1"
}

################################################################################
# Syntax Tests
################################################################################

test_syntax() {
    local script=$1
    run_test "Syntax check: $script"
    
    if bash -n "$script" 2>/dev/null; then
        log_pass "Syntax is valid"
        return 0
    else
        log_fail "Syntax errors found"
        bash -n "$script"
        return 1
    fi
}

################################################################################
# ShellCheck Tests
################################################################################

test_shellcheck() {
    local script=$1
    
    if ! command -v shellcheck &> /dev/null; then
        log_skip "ShellCheck not installed (optional)"
        return 0
    fi
    
    run_test "ShellCheck: $script"
    
    # Run shellcheck with common exclusions
    if shellcheck -x -e SC2317 -e SC2181 "$script" 2>&1 | grep -v "^$"; then
        log_fail "ShellCheck found issues (review above)"
        return 1
    else
        log_pass "ShellCheck passed"
        return 0
    fi
}

################################################################################
# Executable Tests
################################################################################

test_executable() {
    local script=$1
    run_test "Executable check: $script"
    
    if [ -x "$script" ]; then
        log_pass "Script is executable"
        return 0
    else
        log_fail "Script is not executable (run: chmod +x $script)"
        return 1
    fi
}

################################################################################
# Usage Tests
################################################################################

test_usage() {
    local script=$1
    run_test "Usage output: $script"
    
    # Run script with no args and capture exit code
    set +e
    output=$(./"$script" 2>&1)
    exit_code=$?
    set -e
    
    # Should exit with error code
    if [ $exit_code -ne 0 ]; then
        # Should print usage information
        if echo "$output" | grep -qi "usage\|example"; then
            log_pass "Usage information displayed"
            return 0
        else
            log_fail "No usage information found in output"
            return 1
        fi
    else
        log_fail "Script should exit with error when no args provided"
        return 1
    fi
}

################################################################################
# Parameter Validation Tests
################################################################################

test_invalid_ip() {
    local script=$1
    local invalid_ip="999.999.999.999"
    
    run_test "Invalid IP handling: $script"
    
    set +e
    output=$(./"$script" "$invalid_ip" 2>&1)
    exit_code=$?
    set -e
    
    if [ $exit_code -ne 0 ] && echo "$output" | grep -qi "invalid.*ip"; then
        log_pass "Invalid IP rejected correctly"
        return 0
    else
        log_fail "Invalid IP not properly rejected"
        return 1
    fi
}

################################################################################
# Script-Specific Tests
################################################################################

test_01_ssh_hardening() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Testing: 01-ssh-hardening.sh"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local script="01-ssh-hardening.sh"
    
    test_syntax "$script"
    test_executable "$script"
    test_shellcheck "$script"
    test_usage "$script"
    test_invalid_ip "$script"
}

test_02_firewall_setup() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Testing: 02-firewall-setup.sh"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local script="02-firewall-setup.sh"
    
    test_syntax "$script"
    test_executable "$script"
    test_shellcheck "$script"
    test_usage "$script"
    test_invalid_ip "$script"
}

test_03_install_openclaw() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Testing: 03-install-openclaw.sh"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local script="03-install-openclaw.sh"
    
    test_syntax "$script"
    test_executable "$script"
    test_shellcheck "$script"
    
    # This script accepts no required args, so skip usage test
    run_test "No-args execution: $script"
    
    # Should work with no args (local mode) but will fail on prerequisites
    # We just want to make sure it doesn't crash immediately
    set +e
    timeout 5 ./"$script" 2>&1 | head -20 > /dev/null
    exit_code=$?
    set -e
    
    # Exit code 124 means timeout (script is running), which is fine
    # Exit code 0 means it completed (also fine for testing)
    # Any other exit code is expected (missing prerequisites)
    if [ $exit_code -eq 124 ] || [ $exit_code -eq 0 ] || [ $exit_code -eq 2 ]; then
        log_pass "Script starts without crashing"
    else
        log_fail "Script crashed immediately (exit code: $exit_code)"
    fi
}

################################################################################
# Documentation Tests
################################################################################

test_documentation() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Testing: Documentation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    run_test "README.md exists"
    if [ -f "README.md" ]; then
        log_pass "README.md found"
    else
        log_fail "README.md not found"
    fi
    
    run_test "QUICK_START.md exists"
    if [ -f "QUICK_START.md" ]; then
        log_pass "QUICK_START.md found"
    else
        log_fail "QUICK_START.md not found"
    fi
    
    run_test "README.md completeness"
    local required_sections=("Quick Start" "Usage" "Troubleshooting" "Security")
    local missing_sections=()
    
    for section in "${required_sections[@]}"; do
        if ! grep -qi "$section" README.md; then
            missing_sections+=("$section")
        fi
    done
    
    if [ ${#missing_sections[@]} -eq 0 ]; then
        log_pass "All required sections present"
    else
        log_fail "Missing sections: ${missing_sections[*]}"
    fi
}

################################################################################
# File Structure Tests
################################################################################

test_file_structure() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Testing: File Structure"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local required_files=(
        "01-ssh-hardening.sh"
        "02-firewall-setup.sh"
        "03-install-openclaw.sh"
        "README.md"
        "QUICK_START.md"
    )
    
    for file in "${required_files[@]}"; do
        run_test "File exists: $file"
        if [ -f "$file" ]; then
            log_pass "$file exists"
        else
            log_fail "$file not found"
        fi
    done
}

################################################################################
# Header Comment Tests
################################################################################

test_headers() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Testing: Script Headers"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local scripts=("01-ssh-hardening.sh" "02-firewall-setup.sh" "03-install-openclaw.sh")
    local required_headers=("Description:" "Usage:" "Example:")
    
    for script in "${scripts[@]}"; do
        for header in "${required_headers[@]}"; do
            run_test "$script has $header"
            if head -30 "$script" | grep -q "# $header"; then
                log_pass "$header found"
            else
                log_fail "$header not found"
            fi
        done
    done
}

################################################################################
# Main Test Runner
################################################################################

main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════════╗"
    echo "║                  VPS Setup Scripts Test Suite                         ║"
    echo "╚════════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Check if we're in the right directory
    if [ ! -f "01-ssh-hardening.sh" ]; then
        echo -e "${RED}Error: Must run from scripts/vps-setup directory${NC}"
        exit 1
    fi
    
    # Run all tests
    test_file_structure
    test_headers
    test_documentation
    test_01_ssh_hardening
    test_02_firewall_setup
    test_03_install_openclaw
    
    # Summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Test Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Total Tests:  $TESTS_RUN"
    echo -e "${GREEN}Passed:       $TESTS_PASSED${NC}"
    echo -e "${RED}Failed:       $TESTS_FAILED${NC}"
    echo ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                        ALL TESTS PASSED ✓                              ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo "Scripts are ready to use!"
        echo ""
        exit 0
    else
        echo -e "${RED}╔════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║                      SOME TESTS FAILED ✗                               ║${NC}"
        echo -e "${RED}╚════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo "Please review the failures above and fix the issues."
        echo ""
        exit 1
    fi
}

# Run tests
main "$@"
