#!/bin/bash
#
# Universal Bot Deployment Script for LiNKbot Monorepo
# Handles both remote (VPS) and local (Mac Mini) deployments
#
# Usage:
#   ./deploy-bot.sh <bot-name> <target>
#
# Examples:
#   ./deploy-bot.sh lisa vps        # Deploy Lisa to VPS (remote)
#   ./deploy-bot.sh bob local       # Deploy Bob to Mac Mini (local)
#   ./deploy-bot.sh kate vps2       # Deploy Kate to VPS 2 (remote)
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
log_success() { echo -e "${GREEN}✓${NC}  $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
log_error() { echo -e "${RED}✗${NC}  $1"; exit 1; }

# Check arguments
if [ $# -ne 2 ]; then
    log_error "Usage: $0 <bot-name> <target>\n  Examples:\n    $0 lisa vps\n    $0 bob local"
fi

BOT_NAME=$1
TARGET=$2
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(dirname "$SCRIPT_DIR")"
BOT_DIR="$MONOREPO_ROOT/bots/$BOT_NAME"
BOT_CONFIG="$BOT_DIR/config/$BOT_NAME/openclaw.json"

# Validate bot exists
if [ ! -d "$BOT_DIR" ]; then
    log_error "Bot '$BOT_NAME' not found at $BOT_DIR"
fi

if [ ! -f "$BOT_CONFIG" ]; then
    log_error "Bot config not found at $BOT_CONFIG"
fi

log_info "Deploying bot: $BOT_NAME to target: $TARGET"

# Load deployment configuration
DEPLOY_CONFIG="$MONOREPO_ROOT/scripts/deploy-config.sh"
if [ ! -f "$DEPLOY_CONFIG" ]; then
    log_error "Deploy config not found at $DEPLOY_CONFIG\nCreate it with deployment targets (VPS IPs, SSH hosts, etc.)"
fi

source "$DEPLOY_CONFIG"

# Determine deployment type and target details
case "$TARGET" in
    vps|vps1)
        DEPLOY_TYPE="remote"
        DEPLOY_HOST="${VPS1_HOST:-root@178.128.77.125}"
        DEPLOY_PATH="${VPS1_PATH:-/root/linkbot}"
        ;;
    vps2)
        DEPLOY_TYPE="remote"
        DEPLOY_HOST="${VPS2_HOST:-root@vps2.example.com}"
        DEPLOY_PATH="${VPS2_PATH:-/root/linkbot}"
        ;;
    local|mac)
        DEPLOY_TYPE="local"
        DEPLOY_PATH="${LOCAL_PATH:-$HOME/linkbot}"
        ;;
    *)
        log_error "Unknown target: $TARGET\nSupported: vps, vps1, vps2, local, mac"
        ;;
esac

log_info "Deployment type: $DEPLOY_TYPE"

# Function to get enabled skills from config
get_enabled_skills() {
    local config="$1"
    # Parse openclaw.json for enabled skills
    # This is a simple grep-based parser; could be improved with jq
    grep -A 2 '"enabled": true' "$config" | grep -B 1 "enabled" | grep -oP '"\K[^"]+(?=":)' || echo ""
}

# Function to get enabled agents from config
get_enabled_agents() {
    local config="$1"
    # Parse openclaw.json for enabled agents
    grep -A 5 '"agents"' "$config" | grep '"enabled"' | grep -oP '\[\K[^\]]+' | tr -d '",' || echo ""
}

# Deploy to remote (VPS)
deploy_remote() {
    log_info "Deploying to remote: $DEPLOY_HOST:$DEPLOY_PATH"
    
    # Step 1: Clone or pull monorepo on remote
    log_info "Step 1/7: Syncing monorepo to remote..."
    ssh "$DEPLOY_HOST" "
        if [ -d $DEPLOY_PATH/.git ]; then
            cd $DEPLOY_PATH &&
            if [ -n \"\$(git status --porcelain)\" ]; then
              echo \"Remote repo has local changes (must be clean for deploy).\" >&2
              git status --porcelain >&2
              exit 2
            fi &&
            git fetch origin main &&
            git pull --ff-only origin main
        else
            git clone https://github.com/linktrend/linkbot.git $DEPLOY_PATH
        fi
    "
    log_success "Monorepo synced"
    
    # Step 2: Install dependencies on remote
    log_info "Step 2/7: Installing dependencies..."
    ssh "$DEPLOY_HOST" "cd $DEPLOY_PATH/bots/$BOT_NAME && npm ci"
    log_success "Dependencies installed"
    
    # Step 3: Build OpenClaw on remote
    log_info "Step 3/7: Building OpenClaw..."
    ssh "$DEPLOY_HOST" "cd $DEPLOY_PATH/bots/$BOT_NAME && npm run build"
    log_success "Build complete"
    
    # Step 4: Update runtime configuration
    log_info "Step 4/7: Updating runtime config..."
    ssh "$DEPLOY_HOST" "
        mkdir -p /root/.openclaw &&
        cp $DEPLOY_PATH/bots/$BOT_NAME/config/$BOT_NAME/openclaw.json /root/.openclaw/openclaw.json &&
        cd $DEPLOY_PATH/bots/$BOT_NAME &&
        OPENCLAW_CONFIG_PATH=/root/.openclaw/openclaw.json ./openclaw.mjs doctor --non-interactive --no-workspace-suggestions >/tmp/openclaw-doctor.log 2>&1 || true
    "
    log_success "Runtime config updated"
    
    # Step 5: Sync workspace templates to runtime directory
    log_info "Step 5/7: Syncing workspace templates..."
    ssh "$DEPLOY_HOST" "
        mkdir -p /root/.openclaw/workspace /root/.openclaw/workspace/config &&
        cp -f $DEPLOY_PATH/bots/$BOT_NAME/docs/reference/templates/TOOLS.md /root/.openclaw/workspace/TOOLS.md &&
        cp -f $DEPLOY_PATH/config/mcporter.json /root/.openclaw/workspace/config/mcporter.json &&
        python3 - <<'PY' >/root/.openclaw/workspace/CAPABILITIES.yaml
import datetime, json, subprocess

def sh(cmd):
    return subprocess.check_output(cmd, text=True)

skills = json.loads(sh(['/root/openclaw-bot/openclaw.mjs','skills','list','--json']))
agents = json.loads(sh(['/root/openclaw-bot/openclaw.mjs','agents','list','--json']))
mcp = json.loads(sh(['bash','-lc','cd /root/linkbot && mcporter --config config/mcporter.json list --json']))

now = datetime.datetime.utcnow().isoformat() + 'Z'
print(f'generated_at: \"{now}\"')
print('runtime_host: \"'+sh(['bash','-lc','hostname']).strip()+'\"')
print('skills:')
for s in skills.get('skills', []):
    name = s.get('name','')
    disabled = bool(s.get('disabled'))
    eligible = bool(s.get('eligible'))
    blocked = bool(s.get('blockedByAllowlist'))
    missing = s.get('missing') or {}
    bins = missing.get('bins') or []
    env = missing.get('env') or []
    os_ = missing.get('os') or []
    print(f'  - name: \"{name}\"')
    print(f'    enabled: {str(not disabled).lower()}')
    print(f'    eligible: {str(eligible).lower()}')
    print(f'    blocked_by_exec_allowlist: {str(blocked).lower()}')
    if bins or env or os_:
        print('    missing:')
        if bins: print('      bins: [' + ', '.join([json.dumps(b) for b in bins]) + ']')
        if env:  print('      env: [' + ', '.join([json.dumps(e) for e in env]) + ']')
        if os_:  print('      os: [' + ', '.join([json.dumps(o) for o in os_]) + ']')
print('agents:')
for a in agents:
    aid = a.get('id','')
    ws = a.get('workspace','')
    model = a.get('model','')
    print(f'  - id: \"{aid}\"')
    if ws: print(f'    workspace: \"{ws}\"')
    if model: print(f'    model: \"{model}\"')
print('mcp_servers:')
for s in mcp.get('servers', []):
    name = s.get('name','')
    status = s.get('status','')
    tool_count = len(s.get('tools') or [])
    print(f'  - name: \"{name}\"')
    print(f'    status: \"{status}\"')
    print(f'    tools_count: {tool_count}')
PY
    "
    log_success "Workspace templates + mcporter config synced"

    # Step 6: Deploy skills to runtime directory
    log_info "Step 6/7: Deploying skills..."
    ssh "$DEPLOY_HOST" "
        rm -rf /root/.openclaw/skills &&
        mkdir -p /root/.openclaw/skills &&
        ln -sfn $DEPLOY_PATH/skills/mcp-wrappers /root/.openclaw/skills/mcp-wrappers &&
        ln -sfn $DEPLOY_PATH/skills/specialized /root/.openclaw/skills/specialized &&
        ln -sfn $DEPLOY_PATH/skills/coding /root/.openclaw/skills/coding &&
        ln -sfn $DEPLOY_PATH/skills/antigravity /root/.openclaw/skills/antigravity
    "
    log_success "Skills deployed (curated symlinks)"
    
    # Step 7: Restart bot service
    log_info "Step 7/7: Restarting bot..."
    ssh "$DEPLOY_HOST" "systemctl restart openclaw"
    sleep 5
    ssh "$DEPLOY_HOST" "systemctl status openclaw --no-pager | head -15"
    log_success "Bot restarted"
    
    log_success "Remote deployment complete!"
    echo ""
    log_info "View logs: ssh $DEPLOY_HOST 'journalctl -u openclaw -f'"
    log_info "Access UI: ssh -L 18789:localhost:18789 $DEPLOY_HOST"
}

# Deploy to local (Mac Mini)
deploy_local() {
    log_info "Deploying to local: $DEPLOY_PATH"
    
    # Step 1: Create local deployment directory
    log_info "Step 1/5: Setting up local deployment..."
    mkdir -p "$DEPLOY_PATH"
    
    # Step 2: Symlink bot directory
    log_info "Step 2/5: Linking bot..."
    ln -sfn "$BOT_DIR" "$DEPLOY_PATH/$BOT_NAME"
    log_success "Bot linked"
    
    # Step 3: Symlink skills
    log_info "Step 3/5: Linking skills..."
    mkdir -p "$HOME/.openclaw"
    ln -sfn "$MONOREPO_ROOT/skills" "$HOME/.openclaw/skills"
    log_success "Skills linked"
    
    # Step 4: Symlink agents
    log_info "Step 4/5: Linking agents..."
    ln -sfn "$MONOREPO_ROOT/agents" "$HOME/.openclaw/agents"
    log_success "Agents linked"
    
    # Step 5: Install dependencies and build
    log_info "Step 5/5: Building bot..."
    cd "$BOT_DIR"
    npm install
    npm run build
    log_success "Build complete"
    
    log_success "Local deployment complete!"
    echo ""
    log_info "Start bot: cd $BOT_DIR && ./openclaw.mjs"
    log_info "Skills are auto-updated via symlink"
}

# Execute deployment
case "$DEPLOY_TYPE" in
    remote)
        deploy_remote
        ;;
    local)
        deploy_local
        ;;
esac

log_success "✨ Deployment of $BOT_NAME to $TARGET complete!"
