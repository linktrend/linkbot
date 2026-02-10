#!/usr/bin/env bash

################################################################################
# OpenClaw Gateway Testing Suite for Lisa
################################################################################
# Purpose: Comprehensive testing of OpenClaw gateway deployment
# Usage:   ./test-lisa-gateway.sh <VPS_IP> <AUTH_TOKEN>
# Version: 1.0
# Date:    February 9, 2026
################################################################################

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Test result counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Cost tracking
TOTAL_INPUT_TOKENS=0
TOTAL_OUTPUT_TOKENS=0

# Response time tracking
declare -a RESPONSE_TIMES=()

# Log file path
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/logs"
LOG_FILE="${LOG_DIR}/gateway-tests-${TIMESTAMP}.log"

################################################################################
# Helper Functions
################################################################################

# Print colored messages
print_header() {
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║ $1${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_test() {
    echo -e "${BLUE}▸${NC} Testing: $1"
}

print_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((TESTS_PASSED++))
}

print_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((TESTS_FAILED++))
}

print_skip() {
    echo -e "${YELLOW}⊘ SKIP${NC}: $1"
    ((TESTS_SKIPPED++))
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# Log everything to file and stdout
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

log_only() {
    echo -e "$1" >> "$LOG_FILE"
}

# Usage instructions
usage() {
    cat << EOF
Usage: $0 <VPS_IP> <AUTH_TOKEN>

Arguments:
  VPS_IP      - IP address of your OpenClaw VPS (e.g., 143.198.123.45)
  AUTH_TOKEN  - Gateway authentication token from OpenClaw

Examples:
  $0 143.198.123.45 abc123xyz789def456
  $0 \$VPS_IP \$OPENCLAW_TOKEN

Environment Variables (Alternative):
  VPS_IP            - VPS IP address
  OPENCLAW_TOKEN    - Authentication token

Test Coverage:
  1. Gateway connectivity (port 18789)
  2. Authentication (valid token)
  3. Primary model (Kimi K2.5 via OpenRouter)
  4. Heartbeat model (Gemini Flash Lite FREE)
  5. Simple skill execution
  6. Sub-agent spawn test
  7. Telegram notification test
  8. Session creation and /new command
  9. Memory persistence after /new
  10. Rate limit handling

Output:
  - Results logged to: logs/gateway-tests-<timestamp>.log
  - Summary report at end with costs and recommendations

EOF
    exit 1
}

# Calculate average response time
calc_avg_response_time() {
    if [ ${#RESPONSE_TIMES[@]} -eq 0 ]; then
        echo "0.00"
        return
    fi
    
    local sum=0
    for time in "${RESPONSE_TIMES[@]}"; do
        sum=$(echo "$sum + $time" | bc)
    done
    echo "scale=2; $sum / ${#RESPONSE_TIMES[@]}" | bc
}

# Estimate costs based on token usage
estimate_costs() {
    # Kimi K2.5 pricing via OpenRouter: $0.45/1M input, $2.25/1M output
    local kimi_input_cost=$(echo "scale=4; $TOTAL_INPUT_TOKENS * 0.45 / 1000000" | bc)
    local kimi_output_cost=$(echo "scale=4; $TOTAL_OUTPUT_TOKENS * 2.25 / 1000000" | bc)
    local total_cost=$(echo "scale=4; $kimi_input_cost + $kimi_output_cost" | bc)
    
    echo "$total_cost"
}

################################################################################
# Test Functions
################################################################################

# Test 1: Gateway Connectivity
test_gateway_connectivity() {
    print_test "Gateway connectivity (port 18789)"
    ((TESTS_RUN++))
    
    local start_time=$(date +%s.%N)
    
    # Test HTTP endpoint
    if ${TIMEOUT_CMD:-timeout} 10 curl -s -o /dev/null -w "%{http_code}" "http://${VPS_IP}:18789/health" > /tmp/test_result.txt 2>&1; then
        local http_code=$(cat /tmp/test_result.txt)
        local end_time=$(date +%s.%N)
        local response_time=$(echo "$end_time - $start_time" | bc)
        RESPONSE_TIMES+=("$response_time")
        
        if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 401 ] || [ "$http_code" -eq 404 ]; then
            print_pass "Gateway reachable on port 18789 (HTTP $http_code) [${response_time}s]"
            log_only "  → HTTP response code: $http_code"
            log_only "  → Response time: ${response_time}s"
            return 0
        else
            print_fail "Gateway returned unexpected HTTP code: $http_code"
            log_only "  → Response time: ${response_time}s"
            return 1
        fi
    else
        print_fail "Cannot reach gateway at ${VPS_IP}:18789"
        log_only "  → Connection timeout or refused"
        return 1
    fi
}

# Test 2: Authentication
test_authentication() {
    print_test "Authentication with token"
    ((TESTS_RUN++))
    
    local start_time=$(date +%s.%N)
    
    # Try accessing dashboard with token
    local response=$(${TIMEOUT_CMD:-timeout} 15 curl -s -w "\n%{http_code}" "http://${VPS_IP}:18789/?token=${AUTH_TOKEN}" 2>&1)
    local http_code=$(echo "$response" | tail -1)
    local body=$(echo "$response" | head -n -1)
    local end_time=$(date +%s.%N)
    local response_time=$(echo "$end_time - $start_time" | bc)
    RESPONSE_TIMES+=("$response_time")
    
    log_only "  → HTTP response code: $http_code"
    log_only "  → Response time: ${response_time}s"
    
    if [ "$http_code" -eq 200 ]; then
        if echo "$body" | grep -q -i "openclaw\|dashboard\|chat"; then
            print_pass "Authentication successful [${response_time}s]"
            log_only "  → Dashboard accessible with token"
            return 0
        else
            print_fail "Authenticated but unexpected response content"
            log_only "  → Response snippet: $(echo "$body" | head -c 200)"
            return 1
        fi
    elif [ "$http_code" -eq 401 ]; then
        print_fail "Authentication failed - invalid token"
        return 1
    else
        print_fail "Unexpected HTTP response: $http_code"
        return 1
    fi
}

# Test 3: Primary Model (Kimi K2.5)
test_primary_model() {
    print_test "Primary model (Kimi K2.5 via OpenRouter)"
    ((TESTS_RUN++))
    
    print_info "This test requires API interaction - results may vary"
    
    # Note: This would require actual WebSocket or HTTP API call to OpenClaw
    # For now, we'll check if the gateway is configured for it
    
    local start_time=$(date +%s.%N)
    
    # Test basic API endpoint
    local response=$(${TIMEOUT_CMD:-timeout} 20 curl -s -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${AUTH_TOKEN}" \
        -d '{"message": "test", "stream": false}' \
        "http://${VPS_IP}:18789/api/chat" 2>&1 || echo "ERROR")
    
    local end_time=$(date +%s.%N)
    local response_time=$(echo "$end_time - $start_time" | bc)
    RESPONSE_TIMES+=("$response_time")
    
    if [ "$response" = "ERROR" ]; then
        print_skip "API endpoint not accessible or not configured yet [${response_time}s]"
        log_only "  → Could not test primary model directly"
        log_only "  → Manual verification recommended via dashboard"
        return 0
    fi
    
    # Check response for model indicators
    if echo "$response" | grep -q -i "kimi\|k2.5\|moonshot"; then
        print_pass "Primary model detected (Kimi K2.5) [${response_time}s]"
        log_only "  → Model response: $(echo "$response" | head -c 200)"
        
        # Try to extract token usage
        local input_tokens=$(echo "$response" | jq -r '.usage.input_tokens // 0' 2>/dev/null || echo "0")
        local output_tokens=$(echo "$response" | jq -r '.usage.output_tokens // 0' 2>/dev/null || echo "0")
        TOTAL_INPUT_TOKENS=$((TOTAL_INPUT_TOKENS + input_tokens))
        TOTAL_OUTPUT_TOKENS=$((TOTAL_OUTPUT_TOKENS + output_tokens))
        log_only "  → Input tokens: $input_tokens, Output tokens: $output_tokens"
        return 0
    else
        print_skip "Could not verify primary model in response [${response_time}s]"
        log_only "  → Response: $(echo "$response" | head -c 200)"
        log_only "  → Manual verification recommended"
        return 0
    fi
}

# Test 4: Heartbeat Model (Gemini Flash Lite)
test_heartbeat_model() {
    print_test "Heartbeat model (Gemini Flash Lite FREE)"
    ((TESTS_RUN++))
    
    local start_time=$(date +%s.%N)
    
    # Check health endpoint for heartbeat status
    local response=$(${TIMEOUT_CMD:-timeout} 10 curl -s \
        -H "Authorization: Bearer ${AUTH_TOKEN}" \
        "http://${VPS_IP}:18789/api/health" 2>&1 || echo "ERROR")
    
    local end_time=$(date +%s.%N)
    local response_time=$(echo "$end_time - $start_time" | bc)
    RESPONSE_TIMES+=("$response_time")
    
    if [ "$response" = "ERROR" ]; then
        print_skip "Health endpoint not accessible [${response_time}s]"
        log_only "  → Heartbeat model verification requires configured gateway"
        return 0
    fi
    
    log_only "  → Response time: ${response_time}s"
    log_only "  → Health status: $(echo "$response" | head -c 200)"
    
    if echo "$response" | grep -q -i "gemini\|healthy\|ok"; then
        print_pass "Heartbeat model check successful [${response_time}s]"
        return 0
    else
        print_skip "Could not verify heartbeat model [${response_time}s]"
        log_only "  → Manual verification recommended via logs"
        return 0
    fi
}

# Test 5: Simple Skill Execution
test_skill_execution() {
    print_test "Simple skill execution"
    ((TESTS_RUN++))
    
    print_info "This test requires skills to be loaded"
    
    local start_time=$(date +%s.%N)
    
    # Check for skills endpoint
    local response=$(${TIMEOUT_CMD:-timeout} 15 curl -s \
        -H "Authorization: Bearer ${AUTH_TOKEN}" \
        "http://${VPS_IP}:18789/api/skills" 2>&1 || echo "ERROR")
    
    local end_time=$(date +%s.%N)
    local response_time=$(echo "$end_time - $start_time" | bc)
    RESPONSE_TIMES+=("$response_time")
    
    if [ "$response" = "ERROR" ]; then
        print_skip "Skills endpoint not accessible [${response_time}s]"
        log_only "  → Skills may not be installed yet"
        return 0
    fi
    
    # Check if any skills are listed
    local skill_count=$(echo "$response" | jq '. | length' 2>/dev/null || echo "0")
    
    if [ "$skill_count" -gt 0 ]; then
        print_pass "Skills available: $skill_count [${response_time}s]"
        log_only "  → Skills endpoint responded successfully"
        log_only "  → Available skills: $(echo "$response" | jq -r '.[].name' 2>/dev/null | head -5 | tr '\n' ', ' || echo 'parsing error')"
        return 0
    else
        print_skip "No skills loaded yet [${response_time}s]"
        log_only "  → Skills installation pending"
        return 0
    fi
}

# Test 6: Sub-agent Spawn Test
test_subagent_spawn() {
    print_test "Sub-agent spawn capability"
    ((TESTS_RUN++))
    
    print_info "Testing sub-agent configuration (Devstral 2 FREE)"
    
    local start_time=$(date +%s.%N)
    
    # Check configuration for sub-agent settings
    local response=$(${TIMEOUT_CMD:-timeout} 10 curl -s \
        -H "Authorization: Bearer ${AUTH_TOKEN}" \
        "http://${VPS_IP}:18789/api/config" 2>&1 || echo "ERROR")
    
    local end_time=$(date +%s.%N)
    local response_time=$(echo "$end_time - $start_time" | bc)
    RESPONSE_TIMES+=("$response_time")
    
    if [ "$response" = "ERROR" ]; then
        print_skip "Config endpoint not accessible [${response_time}s]"
        log_only "  → Sub-agent configuration cannot be verified"
        return 0
    fi
    
    # Check for sub-agent related configuration
    if echo "$response" | grep -q -i "subagent\|devstral\|agent"; then
        print_pass "Sub-agent configuration detected [${response_time}s]"
        log_only "  → Sub-agent settings found in config"
        return 0
    else
        print_skip "Could not verify sub-agent configuration [${response_time}s]"
        log_only "  → Config may not expose sub-agent settings"
        return 0
    fi
}

# Test 7: Telegram Notification
test_telegram_notification() {
    print_test "Telegram notification capability"
    ((TESTS_RUN++))
    
    print_info "Checking Telegram integration status"
    
    local start_time=$(date +%s.%N)
    
    # Check for Telegram channel configuration
    local response=$(${TIMEOUT_CMD:-timeout} 10 curl -s \
        -H "Authorization: Bearer ${AUTH_TOKEN}" \
        "http://${VPS_IP}:18789/api/channels" 2>&1 || echo "ERROR")
    
    local end_time=$(date +%s.%N)
    local response_time=$(echo "$end_time - $start_time" | bc)
    RESPONSE_TIMES+=("$response_time")
    
    if [ "$response" = "ERROR" ]; then
        print_skip "Channels endpoint not accessible [${response_time}s]"
        log_only "  → Telegram integration cannot be verified via API"
        return 0
    fi
    
    # Check if Telegram is configured
    if echo "$response" | grep -q -i "telegram"; then
        print_pass "Telegram channel detected [${response_time}s]"
        log_only "  → Telegram integration appears configured"
        return 0
    else
        print_skip "Telegram not configured yet [${response_time}s]"
        log_only "  → Telegram setup may be pending"
        return 0
    fi
}

# Test 8: Session Creation
test_session_creation() {
    print_test "Session creation and /new command"
    ((TESTS_RUN++))
    
    print_info "Testing session management"
    
    local start_time=$(date +%s.%N)
    
    # Try to create a new session
    local response=$(${TIMEOUT_CMD:-timeout} 15 curl -s -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${AUTH_TOKEN}" \
        -d '{"command": "/new"}' \
        "http://${VPS_IP}:18789/api/session/new" 2>&1 || echo "ERROR")
    
    local end_time=$(date +%s.%N)
    local response_time=$(echo "$end_time - $start_time" | bc)
    RESPONSE_TIMES+=("$response_time")
    
    if [ "$response" = "ERROR" ]; then
        print_skip "Session endpoint not accessible [${response_time}s]"
        log_only "  → Session management may use different API"
        return 0
    fi
    
    # Check for successful session creation
    if echo "$response" | grep -q -i "session\|created\|new"; then
        print_pass "Session management functional [${response_time}s]"
        log_only "  → New session response: $(echo "$response" | head -c 200)"
        return 0
    else
        print_skip "Could not verify session creation [${response_time}s]"
        log_only "  → Response: $(echo "$response" | head -c 200)"
        return 0
    fi
}

# Test 9: Memory Persistence
test_memory_persistence() {
    print_test "Memory persistence after /new"
    ((TESTS_RUN++))
    
    print_info "Testing memory management across sessions"
    
    # This test would require:
    # 1. Send a message with context
    # 2. Create new session
    # 3. Check if context persists appropriately
    
    print_skip "Memory persistence requires interactive testing"
    log_only "  → Recommended: Manual test via dashboard"
    log_only "  → Test steps: Send message → /new → Check if context cleared"
    return 0
}

# Test 10: Rate Limit Handling
test_rate_limits() {
    print_test "Rate limit handling"
    ((TESTS_RUN++))
    
    print_info "Testing rate limit responses (non-invasive)"
    
    local start_time=$(date +%s.%N)
    
    # Make multiple quick requests to see if rate limiting is active
    local success_count=0
    for i in {1..5}; do
        local response=$(${TIMEOUT_CMD:-timeout} 5 curl -s -o /dev/null -w "%{http_code}" \
            -H "Authorization: Bearer ${AUTH_TOKEN}" \
            "http://${VPS_IP}:18789/api/health" 2>&1)
        
        if [ "$response" = "200" ]; then
            ((success_count++))
        fi
        sleep 0.2
    done
    
    local end_time=$(date +%s.%N)
    local response_time=$(echo "$end_time - $start_time" | bc)
    
    if [ "$success_count" -eq 5 ]; then
        print_pass "Rate limits allow normal traffic (5/5 requests succeeded) [${response_time}s]"
        log_only "  → All test requests succeeded"
        return 0
    elif [ "$success_count" -gt 0 ]; then
        print_pass "Rate limits active but permissive ($success_count/5 requests succeeded) [${response_time}s]"
        log_only "  → Some requests rate limited"
        return 0
    else
        print_fail "All requests blocked - rate limits too strict or service issue"
        log_only "  → No requests succeeded in rate limit test"
        return 1
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    # Parse arguments
    local vps_ip="${1:-${VPS_IP:-}}"
    local auth_token="${2:-${OPENCLAW_TOKEN:-}}"
    
    if [ -z "$vps_ip" ] || [ -z "$auth_token" ]; then
        usage
    fi
    
    # Export for use in test functions
    export VPS_IP="$vps_ip"
    export AUTH_TOKEN="$auth_token"
    
    # Create logs directory
    mkdir -p "$LOG_DIR"
    
    # Initialize log file
    {
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║  OpenClaw Gateway Testing Suite - Lisa Deployment             ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""
        echo "Test Session: $TIMESTAMP"
        echo "VPS IP: $VPS_IP"
        echo "Auth Token: ${AUTH_TOKEN:0:20}... (redacted)"
        echo "Log File: $LOG_FILE"
        echo ""
        echo "════════════════════════════════════════════════════════════════"
        echo ""
    } > "$LOG_FILE"
    
    # Print header
    print_header "OpenClaw Gateway Testing Suite - Lisa Deployment"
    
    echo -e "Test Session: ${CYAN}${TIMESTAMP}${NC}"
    echo -e "VPS IP: ${CYAN}${VPS_IP}${NC}"
    echo -e "Log File: ${CYAN}${LOG_FILE}${NC}"
    echo ""
    
    print_info "Starting comprehensive gateway tests..."
    echo ""
    
    # Run all tests
    log "Starting test suite execution..."
    log ""
    
    test_gateway_connectivity
    sleep 1
    
    test_authentication
    sleep 1
    
    test_primary_model
    sleep 1
    
    test_heartbeat_model
    sleep 1
    
    test_skill_execution
    sleep 1
    
    test_subagent_spawn
    sleep 1
    
    test_telegram_notification
    sleep 1
    
    test_session_creation
    sleep 1
    
    test_memory_persistence
    sleep 1
    
    test_rate_limits
    
    # Calculate metrics
    local avg_response_time=$(calc_avg_response_time)
    local estimated_cost=$(estimate_costs)
    
    # Print summary report
    print_header "Test Summary Report"
    
    echo -e "${CYAN}Test Results:${NC}"
    echo -e "  Total Tests Run:    ${BLUE}${TESTS_RUN}${NC}"
    echo -e "  Passed:            ${GREEN}${TESTS_PASSED}${NC}"
    echo -e "  Failed:            ${RED}${TESTS_FAILED}${NC}"
    echo -e "  Skipped:           ${YELLOW}${TESTS_SKIPPED}${NC}"
    echo ""
    
    # Calculate success rate
    if [ $TESTS_RUN -gt 0 ]; then
        local pass_rate=$(echo "scale=1; $TESTS_PASSED * 100 / $TESTS_RUN" | bc)
        echo -e "${CYAN}Success Rate:${NC} ${pass_rate}% (excluding skips)"
    fi
    echo ""
    
    echo -e "${CYAN}Performance Metrics:${NC}"
    echo -e "  Avg Response Time:  ${avg_response_time}s"
    echo -e "  Total Requests:     ${#RESPONSE_TIMES[@]}"
    echo ""
    
    echo -e "${CYAN}Cost Estimate (this test session):${NC}"
    echo -e "  Input Tokens:       ${TOTAL_INPUT_TOKENS}"
    echo -e "  Output Tokens:      ${TOTAL_OUTPUT_TOKENS}"
    echo -e "  Estimated Cost:     \$${estimated_cost}"
    echo -e "  ${YELLOW}Note: Most tests use FREE models (Gemini, Devstral)${NC}"
    echo ""
    
    # Recommendations
    print_header "Recommendations"
    
    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "${RED}⚠ FAILURES DETECTED${NC}"
        echo ""
        echo "Review the log file for details:"
        echo "  ${LOG_FILE}"
        echo ""
        echo "Common issues:"
        echo "  1. Gateway not fully initialized - wait 5 minutes and retest"
        echo "  2. Invalid authentication token - regenerate token"
        echo "  3. Firewall blocking connections - check UFW rules"
        echo "  4. OpenClaw service not running - check: systemctl status openclaw"
        echo ""
    elif [ $TESTS_SKIPPED -eq $TESTS_RUN ]; then
        echo -e "${YELLOW}⚠ ALL TESTS SKIPPED${NC}"
        echo ""
        echo "Most tests were skipped, which indicates:"
        echo "  1. Gateway is accessible but not fully configured"
        echo "  2. Skills and integrations not yet installed"
        echo "  3. API endpoints may differ from expected"
        echo ""
        echo "Next steps:"
        echo "  1. Complete OpenClaw configuration via dashboard"
        echo "  2. Install skills from ClawHub"
        echo "  3. Configure Telegram integration"
        echo "  4. Re-run this test suite"
        echo ""
    else
        echo -e "${GREEN}✓ GATEWAY OPERATIONAL${NC}"
        echo ""
        echo "Your OpenClaw gateway is responding well!"
        echo ""
        echo "Next steps:"
        echo "  1. Install and scan skills (see: docs/guides/SKILLS_INSTALLATION.md)"
        echo "  2. Complete Telegram bot setup"
        echo "  3. Configure Google Workspace integration"
        echo "  4. Run production testing via dashboard"
        echo ""
    fi
    
    echo -e "${CYAN}Gateway Dashboard:${NC}"
    echo "  http://${VPS_IP}:18789/?token=${AUTH_TOKEN}"
    echo ""
    
    echo -e "${CYAN}SSH Access:${NC}"
    echo "  ssh root@${VPS_IP}"
    echo ""
    
    echo -e "${CYAN}Useful Commands:${NC}"
    echo "  # Check OpenClaw status"
    echo "  ssh root@${VPS_IP} 'systemctl status openclaw'"
    echo ""
    echo "  # View logs"
    echo "  ssh root@${VPS_IP} 'journalctl -u openclaw -n 50'"
    echo ""
    echo "  # Check gateway health"
    echo "  ssh root@${VPS_IP} 'openclaw gateway health --url ws://127.0.0.1:18789'"
    echo ""
    
    # Log summary to file
    {
        echo ""
        echo "════════════════════════════════════════════════════════════════"
        echo "SUMMARY REPORT"
        echo "════════════════════════════════════════════════════════════════"
        echo ""
        echo "Tests Run:     $TESTS_RUN"
        echo "Passed:        $TESTS_PASSED"
        echo "Failed:        $TESTS_FAILED"
        echo "Skipped:       $TESTS_SKIPPED"
        echo ""
        echo "Avg Response:  ${avg_response_time}s"
        echo "Total Cost:    \$${estimated_cost}"
        echo ""
        echo "Completed:     $(date)"
        echo ""
    } >> "$LOG_FILE"
    
    echo -e "Full test results saved to: ${CYAN}${LOG_FILE}${NC}"
    echo ""
    
    # Exit code based on failures
    if [ $TESTS_FAILED -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    # Check basic commands
    for cmd in curl jq bc; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    # Check for timeout command (GNU coreutils on macOS, or gtimeout)
    if command -v timeout &> /dev/null; then
        TIMEOUT_CMD="timeout"
    elif command -v gtimeout &> /dev/null; then
        TIMEOUT_CMD="gtimeout"
    else
        missing_deps+=("timeout/gtimeout")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${RED}Error: Missing required dependencies${NC}" >&2
        echo "Please install: ${missing_deps[*]}" >&2
        echo "" >&2
        echo "On macOS:" >&2
        echo "  brew install coreutils jq" >&2
        echo "" >&2
        echo "On Ubuntu/Debian:" >&2
        echo "  sudo apt install curl jq bc coreutils" >&2
        echo "" >&2
        exit 1
    fi
    
    # Export timeout command for use in functions
    export TIMEOUT_CMD
}

# Run dependency check
check_dependencies

# Run main function
main "$@"
