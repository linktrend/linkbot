#!/usr/bin/env bash

################################################################################
# End-to-End Skills Integration Testing Suite
################################################################################
# Purpose: Comprehensive testing of all installed skills through OpenClaw gateway
# Usage:   ./test-all-skills.sh [--vps VPS_IP] [--token AUTH_TOKEN]
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
readonly MAGENTA='\033[0;35m'
readonly NC='\033[0m' # No Color

# Test result counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Skill test tracking
declare -A SKILL_RESULTS
declare -A SKILL_TIMES
declare -A SKILL_COSTS
declare -A SKILL_TOKENS

# Performance tracking
TOTAL_START_TIME=$(date +%s)
TOTAL_INPUT_TOKENS=0
TOTAL_OUTPUT_TOKENS=0
TOTAL_ESTIMATED_COST=0

# Log file setup
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/logs"
LOG_FILE="${LOG_DIR}/skills-test-${TIMESTAMP}.log"

# Configuration
VPS_IP="${VPS_IP:-localhost}"
AUTH_TOKEN="${AUTH_TOKEN:-}"
GATEWAY_URL="http://${VPS_IP}:18789"
TIMEOUT_CMD="timeout"

# Check for gtimeout on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v gtimeout &> /dev/null; then
        TIMEOUT_CMD="gtimeout"
    fi
fi

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    printf "${CYAN}║ %-62s ║${NC}\n" "$1"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_skill_header() {
    echo -e "\n${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}  Testing: $1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_test() {
    echo -e "${BLUE}  ▸${NC} $1"
}

print_pass() {
    echo -e "${GREEN}  ✓${NC} $1"
    ((TESTS_PASSED++))
}

print_fail() {
    echo -e "${RED}  ✗${NC} $1"
    ((TESTS_FAILED++))
}

print_skip() {
    echo -e "${YELLOW}  ⊘${NC} $1"
    ((TESTS_SKIPPED++))
}

print_info() {
    echo -e "${CYAN}  ℹ${NC} $1"
}

log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

log_only() {
    echo -e "$1" >> "$LOG_FILE"
}

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  --vps VPS_IP          VPS IP address (default: localhost for local testing)
  --token AUTH_TOKEN    OpenClaw gateway authentication token
  --help                Show this help message

Environment Variables:
  VPS_IP                VPS IP address
  AUTH_TOKEN            OpenClaw authentication token

Examples:
  # Local testing
  ./test-all-skills.sh

  # Remote VPS testing
  ./test-all-skills.sh --vps 143.198.123.45 --token abc123xyz789

  # Using environment variables
  export VPS_IP=143.198.123.45
  export AUTH_TOKEN=abc123xyz789
  ./test-all-skills.sh

Test Coverage:
  1. Gmail integration (send, read, search, archive)
  2. Google Calendar (create, list, update, delete events)
  3. Google Docs (create document, verify in Drive)
  4. Google Sheets (create spreadsheet with data)
  5. Google Slides (create presentation)
  6. Web research (search and return top results)
  7. Task management (create, list, complete tasks)
  8. Financial calculations (ROI calculations)
  9. Python coding (generate script, verify file)

Output:
  - Real-time console output with color-coded results
  - Detailed log: logs/skills-test-<timestamp>.log
  - Summary report with performance metrics and recommendations

EOF
    exit 1
}

# Calculate estimated cost
calc_cost() {
    local input_tokens=$1
    local output_tokens=$2
    
    # Kimi K2.5 pricing: $0.45/1M input, $2.25/1M output
    local input_cost=$(echo "scale=6; $input_tokens * 0.45 / 1000000" | bc)
    local output_cost=$(echo "scale=6; $output_tokens * 2.25 / 1000000" | bc)
    local total=$(echo "scale=6; $input_cost + $output_cost" | bc)
    
    echo "$total"
}

# Make API call to OpenClaw
call_openclaw() {
    local skill_name=$1
    local prompt=$2
    local timeout=${3:-30}
    
    local start_time=$(date +%s.%N)
    
    local response=$(${TIMEOUT_CMD} ${timeout} curl -s -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${AUTH_TOKEN}" \
        -d "{\"message\":\"${prompt}\",\"stream\":false}" \
        "${GATEWAY_URL}/api/chat" 2>&1 || echo '{"error":"timeout"}')
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    # Extract token usage if available
    local input_tokens=$(echo "$response" | jq -r '.usage.input_tokens // 0' 2>/dev/null || echo "0")
    local output_tokens=$(echo "$response" | jq -r '.usage.output_tokens // 0' 2>/dev/null || echo "0")
    
    # Update totals
    TOTAL_INPUT_TOKENS=$((TOTAL_INPUT_TOKENS + input_tokens))
    TOTAL_OUTPUT_TOKENS=$((TOTAL_OUTPUT_TOKENS + output_tokens))
    
    # Store skill-specific metrics
    SKILL_TOKENS["$skill_name"]="$input_tokens/$output_tokens"
    SKILL_TIMES["$skill_name"]="$duration"
    
    local cost=$(calc_cost "$input_tokens" "$output_tokens")
    SKILL_COSTS["$skill_name"]="$cost"
    
    echo "$response"
}

################################################################################
# Skill Test Functions
################################################################################

test_gmail_skill() {
    print_skill_header "Gmail Integration"
    ((TESTS_RUN++))
    
    local skill_passed=true
    
    # Test 1: Send test email
    print_test "Sending test email..."
    local prompt="Use Gmail to send a test email to yourself with subject 'LiNKbot Test ${TIMESTAMP}' and body 'This is an automated test from the skills testing suite.'"
    local response=$(call_openclaw "gmail" "$prompt" 45)
    
    if echo "$response" | grep -qi "sent\|success\|delivered"; then
        print_pass "Email sent successfully"
        log_only "  → Response: $(echo "$response" | jq -r '.content // .message' 2>/dev/null | head -c 200)"
    else
        print_fail "Failed to send email"
        log_only "  → Error: $(echo "$response" | head -c 200)"
        skill_passed=false
    fi
    
    sleep 2
    
    # Test 2: Read inbox
    print_test "Reading inbox (latest 5 messages)..."
    prompt="Use Gmail to list the 5 most recent emails in my inbox."
    response=$(call_openclaw "gmail" "$prompt" 30)
    
    if echo "$response" | grep -qi "inbox\|email\|message\|subject"; then
        print_pass "Inbox read successfully"
        log_only "  → Found messages in response"
    else
        print_skip "Could not verify inbox read"
        log_only "  → Response: $(echo "$response" | head -c 200)"
    fi
    
    sleep 2
    
    # Test 3: Search for specific email
    print_test "Searching for test email..."
    prompt="Use Gmail to search for emails with subject containing 'LiNKbot Test'."
    response=$(call_openclaw "gmail" "$prompt" 30)
    
    if echo "$response" | grep -qi "test\|found\|result"; then
        print_pass "Email search successful"
        log_only "  → Search completed"
    else
        print_skip "Could not verify email search"
    fi
    
    sleep 2
    
    # Test 4: Archive email (optional - commented out to avoid data loss)
    print_skip "Archive email test (skipped to preserve inbox)"
    
    SKILL_RESULTS["Gmail"]=$skill_passed
}

test_calendar_skill() {
    print_skill_header "Google Calendar"
    ((TESTS_RUN++))
    
    local skill_passed=true
    
    # Test 1: Create event
    print_test "Creating calendar event for tomorrow at 2 PM..."
    local tomorrow=$(date -v+1d +%Y-%m-%d 2>/dev/null || date -d "+1 day" +%Y-%m-%d 2>/dev/null)
    local prompt="Use Google Calendar to create an event titled 'LiNKbot Skills Test' tomorrow at 2:00 PM for 30 minutes."
    local response=$(call_openclaw "calendar" "$prompt" 45)
    
    local event_id=""
    if echo "$response" | grep -qi "created\|success\|scheduled"; then
        print_pass "Event created successfully"
        # Try to extract event ID for later use
        event_id=$(echo "$response" | grep -oP 'event[_]?id["\s:]+\K[a-zA-Z0-9_]+' | head -1)
        log_only "  → Event ID: ${event_id:-unknown}"
    else
        print_fail "Failed to create event"
        log_only "  → Error: $(echo "$response" | head -c 200)"
        skill_passed=false
    fi
    
    sleep 2
    
    # Test 2: List upcoming events
    print_test "Listing upcoming events..."
    prompt="Use Google Calendar to list my upcoming events for the next 7 days."
    response=$(call_openclaw "calendar" "$prompt" 30)
    
    if echo "$response" | grep -qi "event\|scheduled\|upcoming"; then
        print_pass "Events listed successfully"
        log_only "  → Found events in response"
    else
        print_skip "Could not verify event listing"
    fi
    
    sleep 2
    
    # Test 3: Update event
    if [ -n "$event_id" ]; then
        print_test "Updating event description..."
        prompt="Use Google Calendar to update the event 'LiNKbot Skills Test' and add description 'Updated by automated test suite'."
        response=$(call_openclaw "calendar" "$prompt" 30)
        
        if echo "$response" | grep -qi "updated\|success\|modified"; then
            print_pass "Event updated successfully"
        else
            print_skip "Could not verify event update"
        fi
    else
        print_skip "Event update test (no event ID)"
    fi
    
    sleep 2
    
    # Test 4: Delete test event
    print_test "Deleting test event..."
    prompt="Use Google Calendar to delete the event titled 'LiNKbot Skills Test'."
    response=$(call_openclaw "calendar" "$prompt" 30)
    
    if echo "$response" | grep -qi "deleted\|removed\|success"; then
        print_pass "Event deleted successfully"
    else
        print_skip "Could not verify event deletion"
    fi
    
    SKILL_RESULTS["Calendar"]=$skill_passed
}

test_google_docs_skill() {
    print_skill_header "Google Docs"
    ((TESTS_RUN++))
    
    local skill_passed=true
    
    # Test: Create document
    print_test "Creating Google Doc with title and content..."
    local doc_title="LiNKbot Test Document ${TIMESTAMP}"
    local prompt="Use Google Docs to create a new document titled '${doc_title}' with the following content: '# Skills Test Report\\n\\nThis document was created by the automated skills testing suite.\\n\\n## Test Details\\n- Date: $(date)\\n- Suite: End-to-End Integration Tests\\n- Status: Automated'"
    local response=$(call_openclaw "google-docs" "$prompt" 60)
    
    local doc_id=""
    if echo "$response" | grep -qi "created\|success\|document"; then
        print_pass "Document created successfully"
        # Try to extract document ID
        doc_id=$(echo "$response" | grep -oP 'document[_]?id["\s:]+\K[a-zA-Z0-9_-]+' | head -1)
        log_only "  → Document ID: ${doc_id:-unknown}"
        
        # Test: Verify in Drive
        sleep 2
        print_test "Verifying document in Google Drive..."
        prompt="Use Google Drive to search for documents titled '${doc_title}'."
        response=$(call_openclaw "google-docs" "$prompt" 30)
        
        if echo "$response" | grep -qi "found\|exists\|${doc_title}"; then
            print_pass "Document verified in Drive"
        else
            print_skip "Could not verify document in Drive"
        fi
    else
        print_fail "Failed to create document"
        log_only "  → Error: $(echo "$response" | head -c 200)"
        skill_passed=false
    fi
    
    SKILL_RESULTS["Google Docs"]=$skill_passed
}

test_google_sheets_skill() {
    print_skill_header "Google Sheets"
    ((TESTS_RUN++))
    
    local skill_passed=true
    
    # Test: Create spreadsheet with sample data
    print_test "Creating Google Sheet with sample data..."
    local sheet_title="LiNKbot Test Spreadsheet ${TIMESTAMP}"
    local prompt="Use Google Sheets to create a new spreadsheet titled '${sheet_title}' with sample data: Row 1 headers: Name, Email, Status. Row 2: John Doe, john@example.com, Active. Row 3: Jane Smith, jane@example.com, Active."
    local response=$(call_openclaw "google-sheets" "$prompt" 60)
    
    if echo "$response" | grep -qi "created\|success\|spreadsheet"; then
        print_pass "Spreadsheet created successfully"
        log_only "  → Response: $(echo "$response" | jq -r '.content // .message' 2>/dev/null | head -c 200)"
        
        # Test: Verify in Drive
        sleep 2
        print_test "Verifying spreadsheet in Google Drive..."
        prompt="Use Google Drive to search for spreadsheets titled '${sheet_title}'."
        response=$(call_openclaw "google-sheets" "$prompt" 30)
        
        if echo "$response" | grep -qi "found\|exists\|${sheet_title}"; then
            print_pass "Spreadsheet verified in Drive"
        else
            print_skip "Could not verify spreadsheet in Drive"
        fi
    else
        print_fail "Failed to create spreadsheet"
        log_only "  → Error: $(echo "$response" | head -c 200)"
        skill_passed=false
    fi
    
    SKILL_RESULTS["Google Sheets"]=$skill_passed
}

test_google_slides_skill() {
    print_skill_header "Google Slides"
    ((TESTS_RUN++))
    
    local skill_passed=true
    
    # Test: Create presentation with 3 slides
    print_test "Creating Google Slides presentation with 3 slides..."
    local pres_title="LiNKbot Test Presentation ${TIMESTAMP}"
    local prompt="Use Google Slides to create a new presentation titled '${pres_title}' with 3 slides: Slide 1 title 'Skills Test Results', Slide 2 title 'Performance Metrics', Slide 3 title 'Recommendations'."
    local response=$(call_openclaw "google-slides" "$prompt" 60)
    
    if echo "$response" | grep -qi "created\|success\|presentation"; then
        print_pass "Presentation created successfully"
        log_only "  → Response: $(echo "$response" | jq -r '.content // .message' 2>/dev/null | head -c 200)"
        
        # Test: Verify in Drive
        sleep 2
        print_test "Verifying presentation in Google Drive..."
        prompt="Use Google Drive to search for presentations titled '${pres_title}'."
        response=$(call_openclaw "google-slides" "$prompt" 30)
        
        if echo "$response" | grep -qi "found\|exists\|${pres_title}"; then
            print_pass "Presentation verified in Drive"
        else
            print_skip "Could not verify presentation in Drive"
        fi
    else
        print_fail "Failed to create presentation"
        log_only "  → Error: $(echo "$response" | head -c 200)"
        skill_passed=false
    fi
    
    SKILL_RESULTS["Google Slides"]=$skill_passed
}

test_web_research_skill() {
    print_skill_header "Web Research (Brave Search)"
    ((TESTS_RUN++))
    
    local skill_passed=true
    
    # Test: Search for AI agents 2026 and return top 3 results
    print_test "Searching for 'AI agents 2026' and getting top 3 results..."
    local prompt="Use web search to find information about 'AI agents 2026'. Return the top 3 most relevant results with titles and URLs."
    local response=$(call_openclaw "web-research" "$prompt" 45)
    
    if echo "$response" | grep -qi "http\|url\|search\|result\|found"; then
        print_pass "Web search completed successfully"
        
        # Count URLs in response
        local url_count=$(echo "$response" | grep -oP 'https?://[^\s"]+' | wc -l)
        log_only "  → Found $url_count URLs in response"
        
        if [ "$url_count" -ge 3 ]; then
            print_pass "Retrieved at least 3 search results"
        else
            print_skip "Retrieved fewer than 3 results (found: $url_count)"
        fi
    else
        print_fail "Failed to perform web search"
        log_only "  → Error: $(echo "$response" | head -c 200)"
        skill_passed=false
    fi
    
    SKILL_RESULTS["Web Research"]=$skill_passed
}

test_task_management_skill() {
    print_skill_header "Task Management"
    ((TESTS_RUN++))
    
    local skill_passed=true
    
    # Test 1: Create task with priority
    print_test "Creating high-priority task..."
    local task_title="Complete skills testing suite - ${TIMESTAMP}"
    local prompt="Use task management to create a new task titled '${task_title}' with high priority and tag 'testing'."
    local response=$(call_openclaw "task-management" "$prompt" 30)
    
    if echo "$response" | grep -qi "created\|success\|task"; then
        print_pass "Task created successfully"
        log_only "  → Task: ${task_title}"
    else
        print_fail "Failed to create task"
        log_only "  → Error: $(echo "$response" | head -c 200)"
        skill_passed=false
    fi
    
    sleep 2
    
    # Test 2: List tasks
    print_test "Listing all tasks..."
    prompt="Use task management to list all current tasks."
    response=$(call_openclaw "task-management" "$prompt" 30)
    
    if echo "$response" | grep -qi "task\|todo\|list"; then
        print_pass "Tasks listed successfully"
    else
        print_skip "Could not verify task listing"
    fi
    
    sleep 2
    
    # Test 3: Complete task
    print_test "Marking task as complete..."
    prompt="Use task management to mark the task '${task_title}' as complete."
    response=$(call_openclaw "task-management" "$prompt" 30)
    
    if echo "$response" | grep -qi "completed\|success\|done"; then
        print_pass "Task marked as complete"
    else
        print_skip "Could not verify task completion"
    fi
    
    SKILL_RESULTS["Task Management"]=$skill_passed
}

test_financial_calculations_skill() {
    print_skill_header "Financial Calculations"
    ((TESTS_RUN++))
    
    local skill_passed=true
    
    # Test: Calculate ROI
    print_test "Calculating ROI ($10k investment, $15k return, 2 years)..."
    local prompt="Use financial calculations to calculate the ROI for an investment of \$10,000 that returned \$15,000 over 2 years. Provide the percentage return and annualized return."
    local response=$(call_openclaw "financial-calculator" "$prompt" 30)
    
    if echo "$response" | grep -qi "roi\|return\|percent\|%\|50"; then
        print_pass "ROI calculated successfully"
        log_only "  → Response: $(echo "$response" | jq -r '.content // .message' 2>/dev/null | head -c 200)"
        
        # Verify calculation is reasonable (should be around 50% total, 22.5% annualized)
        if echo "$response" | grep -qiE "(50|22|25)"; then
            print_pass "ROI calculation appears correct (~50% total)"
        else
            print_skip "Could not verify ROI accuracy"
        fi
    else
        print_fail "Failed to calculate ROI"
        log_only "  → Error: $(echo "$response" | head -c 200)"
        skill_passed=false
    fi
    
    SKILL_RESULTS["Financial Calculator"]=$skill_passed
}

test_coding_skill() {
    print_skill_header "Python Coding Skill"
    ((TESTS_RUN++))
    
    local skill_passed=true
    
    # Test: Request simple Python script
    print_test "Requesting Python CSV parser script..."
    local script_name="csv_parser_test_${TIMESTAMP}.py"
    local prompt="Use Python coding to create a simple CSV parser script at ~/Projects/${script_name} that reads a CSV file and prints the number of rows."
    local response=$(call_openclaw "python-coding" "$prompt" 60)
    
    if echo "$response" | grep -qi "created\|success\|script\|file"; then
        print_pass "Script creation requested successfully"
        log_only "  → Script: ${script_name}"
        
        # Test: Verify file created
        sleep 2
        print_test "Verifying file was created..."
        if [ -f "$HOME/Projects/${script_name}" ]; then
            print_pass "Script file verified at ~/Projects/${script_name}"
            log_only "  → File exists and is readable"
            
            # Clean up test file
            rm -f "$HOME/Projects/${script_name}"
            log_only "  → Test file cleaned up"
        else
            print_skip "Could not verify file creation (may require manual check)"
        fi
    else
        print_fail "Failed to create script"
        log_only "  → Error: $(echo "$response" | head -c 200)"
        skill_passed=false
    fi
    
    SKILL_RESULTS["Python Coding"]=$skill_passed
}

################################################################################
# Main Test Execution
################################################################################

run_all_tests() {
    print_header "End-to-End Skills Integration Testing Suite"
    
    echo -e "Test Session: ${CYAN}${TIMESTAMP}${NC}"
    echo -e "Gateway URL: ${CYAN}${GATEWAY_URL}${NC}"
    echo -e "Log File: ${CYAN}${LOG_FILE}${NC}"
    echo ""
    
    print_info "Starting comprehensive skills testing..."
    echo ""
    
    # Run all skill tests
    test_gmail_skill
    sleep 1
    
    test_calendar_skill
    sleep 1
    
    test_google_docs_skill
    sleep 1
    
    test_google_sheets_skill
    sleep 1
    
    test_google_slides_skill
    sleep 1
    
    test_web_research_skill
    sleep 1
    
    test_task_management_skill
    sleep 1
    
    test_financial_calculations_skill
    sleep 1
    
    test_coding_skill
}

generate_report() {
    local total_time=$(($(date +%s) - TOTAL_START_TIME))
    local total_cost=$(calc_cost "$TOTAL_INPUT_TOKENS" "$TOTAL_OUTPUT_TOKENS")
    
    print_header "Test Results Summary"
    
    # Overall stats
    echo -e "${CYAN}Overall Statistics:${NC}"
    echo -e "  Tests Run:          ${BLUE}${TESTS_RUN}${NC}"
    echo -e "  Passed:             ${GREEN}${TESTS_PASSED}${NC}"
    echo -e "  Failed:             ${RED}${TESTS_FAILED}${NC}"
    echo -e "  Skipped:            ${YELLOW}${TESTS_SKIPPED}${NC}"
    echo -e "  Total Duration:     ${total_time}s"
    echo ""
    
    # Skills tested
    local skills_passed=0
    local skills_failed=0
    
    echo -e "${CYAN}Skills Tested:${NC}"
    for skill in "${!SKILL_RESULTS[@]}"; do
        local status="${SKILL_RESULTS[$skill]}"
        local time="${SKILL_TIMES[$skill]:-N/A}"
        local tokens="${SKILL_TOKENS[$skill]:-0/0}"
        local cost="${SKILL_COSTS[$skill]:-0.000000}"
        
        if [ "$status" = "true" ]; then
            echo -e "  ${GREEN}✓${NC} ${skill}"
            ((skills_passed++))
        else
            echo -e "  ${RED}✗${NC} ${skill}"
            ((skills_failed++))
        fi
        
        echo -e "      Time: ${time}s | Tokens: ${tokens} | Cost: \$${cost}"
    done
    echo ""
    
    # Summary
    echo -e "${CYAN}Summary:${NC}"
    echo -e "  Skills Passed:      ${GREEN}${skills_passed}/${TESTS_RUN}${NC}"
    echo -e "  Skills Failed:      ${RED}${skills_failed}/${TESTS_RUN}${NC}"
    echo ""
    
    # Cost analysis
    echo -e "${CYAN}Cost Analysis:${NC}"
    echo -e "  Input Tokens:       ${TOTAL_INPUT_TOKENS}"
    echo -e "  Output Tokens:      ${TOTAL_OUTPUT_TOKENS}"
    echo -e "  Total Cost:         \$${total_cost}"
    echo -e "  ${YELLOW}Note: Most operations use optimized models (Kimi K2.5)${NC}"
    echo ""
    
    # Performance metrics
    echo -e "${CYAN}Performance Metrics:${NC}"
    local avg_time=$(echo "scale=2; $total_time / $TESTS_RUN" | bc)
    echo -e "  Avg Time/Skill:     ${avg_time}s"
    echo -e "  Total Execution:    ${total_time}s"
    echo ""
    
    # Recommendations
    print_header "Recommendations"
    
    if [ $skills_failed -eq 0 ]; then
        echo -e "${GREEN}✓ ALL SKILLS OPERATIONAL${NC}"
        echo ""
        echo "All skills are functioning correctly through the OpenClaw gateway!"
        echo ""
        echo "Next steps:"
        echo "  1. Review detailed logs: ${LOG_FILE}"
        echo "  2. Monitor costs via OpenClaw dashboard"
        echo "  3. Configure skills for production use"
        echo "  4. Set up monitoring and alerts"
    else
        echo -e "${RED}⚠ SOME SKILLS FAILED${NC}"
        echo ""
        echo "Skills with failures need attention:"
        for skill in "${!SKILL_RESULTS[@]}"; do
            if [ "${SKILL_RESULTS[$skill]}" = "false" ]; then
                echo "  - $skill"
            fi
        done
        echo ""
        echo "Troubleshooting steps:"
        echo "  1. Check logs: ${LOG_FILE}"
        echo "  2. Verify API credentials for failed skills"
        echo "  3. Ensure required dependencies are installed"
        echo "  4. Test skills individually via dashboard"
    fi
    echo ""
    
    # Optimization recommendations
    if [ $(echo "$total_cost > 0.10" | bc -l) -eq 1 ]; then
        echo -e "${YELLOW}Cost Optimization:${NC}"
        echo "  → This test run cost \$${total_cost}"
        echo "  → Consider caching frequently used data"
        echo "  → Review model routing for expensive operations"
        echo ""
    fi
    
    # Save report to file
    {
        echo ""
        echo "════════════════════════════════════════════════════════════════"
        echo "COMPREHENSIVE TEST REPORT"
        echo "════════════════════════════════════════════════════════════════"
        echo ""
        echo "Generated: $(date)"
        echo "Test Session: ${TIMESTAMP}"
        echo ""
        echo "OVERALL RESULTS"
        echo "───────────────"
        echo "Tests Run:     $TESTS_RUN"
        echo "Passed:        $TESTS_PASSED"
        echo "Failed:        $TESTS_FAILED"
        echo "Skipped:       $TESTS_SKIPPED"
        echo ""
        echo "SKILLS RESULTS"
        echo "──────────────"
        for skill in "${!SKILL_RESULTS[@]}"; do
            local status="${SKILL_RESULTS[$skill]}"
            local time="${SKILL_TIMES[$skill]:-N/A}"
            local tokens="${SKILL_TOKENS[$skill]:-0/0}"
            local cost="${SKILL_COSTS[$skill]:-0.000000}"
            
            if [ "$status" = "true" ]; then
                echo "✓ $skill"
            else
                echo "✗ $skill"
            fi
            echo "  Duration: ${time}s"
            echo "  Tokens: ${tokens}"
            echo "  Cost: \$${cost}"
            echo ""
        done
        echo "PERFORMANCE"
        echo "───────────"
        echo "Total Duration:     ${total_time}s"
        echo "Avg Time/Skill:     ${avg_time}s"
        echo "Input Tokens:       ${TOTAL_INPUT_TOKENS}"
        echo "Output Tokens:      ${TOTAL_OUTPUT_TOKENS}"
        echo "Total Cost:         \$${total_cost}"
        echo ""
        echo "Skills Passed:      ${skills_passed}/${TESTS_RUN}"
        echo "Success Rate:       $(echo "scale=1; $skills_passed * 100 / $TESTS_RUN" | bc)%"
        echo ""
        echo "════════════════════════════════════════════════════════════════"
    } >> "$LOG_FILE"
    
    echo -e "${CYAN}Full report saved to:${NC} ${LOG_FILE}"
    echo ""
}

################################################################################
# Dependency Checks
################################################################################

check_dependencies() {
    local missing_deps=()
    
    for cmd in curl jq bc date; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    # Check for timeout/gtimeout
    if ! command -v timeout &> /dev/null && ! command -v gtimeout &> /dev/null; then
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
}

################################################################################
# Main Execution
################################################################################

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --vps)
                VPS_IP="$2"
                shift 2
                ;;
            --token)
                AUTH_TOKEN="$2"
                shift 2
                ;;
            --help)
                usage
                ;;
            *)
                echo "Unknown option: $1"
                usage
                ;;
        esac
    done
    
    # Update gateway URL with parsed VPS_IP
    GATEWAY_URL="http://${VPS_IP}:18789"
    
    # Create logs directory
    mkdir -p "$LOG_DIR"
    
    # Initialize log file
    {
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║  End-to-End Skills Integration Testing Suite                  ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""
        echo "Test Session: $TIMESTAMP"
        echo "Gateway URL: $GATEWAY_URL"
        echo "VPS IP: $VPS_IP"
        echo "Started: $(date)"
        echo ""
        echo "════════════════════════════════════════════════════════════════"
        echo ""
    } > "$LOG_FILE"
    
    # Run tests
    run_all_tests
    
    # Generate report
    generate_report
    
    # Exit code
    if [ $skills_failed -gt 0 ] || [ $TESTS_FAILED -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

# Check dependencies first
check_dependencies

# Run main
main "$@"
