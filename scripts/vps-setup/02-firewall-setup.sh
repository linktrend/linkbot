#!/bin/bash

################################################################################
# UFW Firewall Setup Script
################################################################################
# Description: Configures UFW (Uncomplicated Firewall) on a VPS with secure
#              default rules and custom access controls.
#
# Usage: ./02-firewall-setup.sh <home_ip> [droplet_ip] [ssh_user]
#
# Parameters:
#   home_ip     - Your home/office IP address for restricted access (required)
#   droplet_ip  - IP address of the VPS droplet (optional, for remote execution)
#   ssh_user    - SSH username (optional, defaults to 'root')
#
# Example:
#   ./02-firewall-setup.sh 203.0.113.50                    # Local execution
#   ./02-firewall-setup.sh 203.0.113.50 192.168.1.100      # Remote execution
#   ./02-firewall-setup.sh 203.0.113.50 192.168.1.100 ubuntu
#
# Features:
#   - Sets default deny incoming, allow outgoing
#   - Allows SSH (port 22) from anywhere
#   - Restricts port 18789 to specified IP only
#   - Enables UFW with confirmation
#   - Shows status and saves rules
#   - Idempotent execution (safe to run multiple times)
#
# Exit Codes:
#   0 - Success
#   1 - Invalid parameters
#   2 - UFW not installed
#   3 - Firewall configuration failed
#   4 - Remote execution failed
################################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SSH_KEY_PATH="${HOME}/.ssh/id_ed25519"
LOG_FILE="/tmp/firewall-setup-$(date +%Y%m%d_%H%M%S).log"
BACKUP_DIR="/etc/ufw/backup-$(date +%Y%m%d_%H%M%S)"

################################################################################
# Logging Functions
################################################################################

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✓${NC} $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ✗${NC} $*" | tee -a "$LOG_FILE" >&2
}

log_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ⚠${NC} $*" | tee -a "$LOG_FILE"
}

################################################################################
# Helper Functions
################################################################################

usage() {
    cat << EOF
Usage: $0 <home_ip> [droplet_ip] [ssh_user]

Parameters:
  home_ip     - Your home/office IP address for restricted access (required)
  droplet_ip  - IP address of the VPS droplet (optional, for remote execution)
  ssh_user    - SSH username (optional, defaults to 'root')

Examples:
  $0 203.0.113.50                    # Local execution
  $0 203.0.113.50 192.168.1.100      # Remote execution
  $0 203.0.113.50 192.168.1.100 ubuntu

Ports configured:
  - 22 (SSH): Allowed from anywhere
  - 18789 (OpenClaw): Allowed only from home_ip
EOF
    exit 1
}

validate_ip() {
    local ip=$1
    local name=$2
    
    if ! [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        log_error "Invalid IP address format for $name: $ip"
        exit 1
    fi
    
    # Validate each octet
    IFS='.' read -ra OCTETS <<< "$ip"
    for octet in "${OCTETS[@]}"; do
        if [ "$octet" -gt 255 ]; then
            log_error "Invalid IP address for $name: $ip (octet > 255)"
            exit 1
        fi
    done
    
    log_success "Valid IP address: $ip"
}

check_ufw_installed() {
    log "Checking if UFW is installed..."
    
    if command -v ufw &> /dev/null; then
        log_success "UFW is installed"
        return 0
    else
        log_error "UFW is not installed"
        log "Installing UFW..."
        
        if sudo apt-get update && sudo apt-get install -y ufw >> "$LOG_FILE"; then
            log_success "UFW installed successfully"
            return 0
        else
            log_error "Failed to install UFW"
            exit 2
        fi
    fi
}

backup_ufw_rules() {
    log "Backing up current UFW rules..."
    
    if sudo mkdir -p "$BACKUP_DIR" >> "$LOG_FILE"; then
        sudo cp -r /etc/ufw/*.rules "$BACKUP_DIR/" >> "$LOG_FILE" || true
        sudo ufw status numbered > "${BACKUP_DIR}/status.txt" 2>&1 || true
        log_success "Backup created at $BACKUP_DIR"
    else
        log_warning "Could not create backup directory"
    fi
}

reset_ufw_rules() {
    log "Resetting UFW to default state..."
    
    # Disable UFW first
    echo "y" | sudo ufw --force disable >> "$LOG_FILE" || true
    
    # Reset to defaults
    echo "y" | sudo ufw --force reset >> "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        log_success "UFW reset to defaults"
    else
        log_error "Failed to reset UFW"
        exit 3
    fi
}

configure_ufw_defaults() {
    log "Configuring UFW default policies..."
    
    # Set default policies
    sudo ufw default deny incoming >> "$LOG_FILE"
    sudo ufw default allow outgoing >> "$LOG_FILE"
    sudo ufw default deny routed >> "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        log_success "Default policies configured (deny incoming, allow outgoing)"
    else
        log_error "Failed to set default policies"
        exit 3
    fi
}

add_ufw_rules() {
    local home_ip=$1
    
    log "Adding UFW rules..."
    
    # Allow SSH from anywhere (critical - don't lock yourself out!)
    log "Adding rule: Allow SSH (port 22) from anywhere..."
    if sudo ufw allow 22/tcp comment 'SSH access' >> "$LOG_FILE"; then
        log_success "SSH rule added"
    else
        log_error "Failed to add SSH rule"
        exit 3
    fi
    
    # Allow port 18789 only from home IP
    log "Adding rule: Allow port 18789 from $home_ip only..."
    if sudo ufw allow from "$home_ip" to any port 18789 proto tcp comment 'OpenClaw access' >> "$LOG_FILE"; then
        log_success "OpenClaw rule added (restricted to $home_ip)"
    else
        log_error "Failed to add OpenClaw rule"
        exit 3
    fi
    
    # Optional: Allow ping (ICMP) - UFW handles this differently
    log "Adding rule: Allow ping (ICMP)..."
    if sudo ufw allow proto icmp comment 'Allow ping' >> "$LOG_FILE" 2>&1; then
        log_success "Ping rule added"
    else
        log_warning "Failed to add ping rule (non-critical)"
    fi
}

enable_ufw() {
    log "Enabling UFW..."
    
    log_warning "About to enable firewall. SSH access will remain available."
    
    # Enable UFW with force flag (non-interactive)
    if echo "y" | sudo ufw --force enable >> "$LOG_FILE"; then
        log_success "UFW enabled successfully"
    else
        log_error "Failed to enable UFW"
        exit 3
    fi
    
    # Verify UFW is active
    if sudo ufw status | grep -q "Status: active"; then
        log_success "UFW is active and running"
    else
        log_error "UFW is not active"
        exit 3
    fi
}

show_ufw_status() {
    log "Current UFW status:"
    echo ""
    sudo ufw status verbose | tee -a "$LOG_FILE"
    echo ""
    
    log "Numbered rules:"
    echo ""
    sudo ufw status numbered | tee -a "$LOG_FILE"
    echo ""
}

configure_firewall_local() {
    local home_ip=$1
    
    check_ufw_installed
    backup_ufw_rules
    reset_ufw_rules
    configure_ufw_defaults
    add_ufw_rules "$home_ip"
    enable_ufw
    show_ufw_status
    
    log_success "Firewall configuration completed"
}

configure_firewall_remote() {
    local home_ip=$1
    local droplet_ip=$2
    local ssh_user=$3
    
    log "Configuring firewall on remote server ${ssh_user}@${droplet_ip}..."
    
    # Check SSH connection
    if ! ssh -i "$SSH_KEY_PATH" -o BatchMode=yes -o ConnectTimeout=10 "${ssh_user}@${droplet_ip}" "exit" >> "$LOG_FILE"; then
        log_error "Cannot connect to ${ssh_user}@${droplet_ip}"
        log_error "Please run 01-ssh-hardening.sh first"
        exit 4
    fi
    
    # Create remote script
    local remote_script=$(cat << 'REMOTE_SCRIPT_EOF'
#!/bin/bash
set -euo pipefail

HOME_IP=$1
LOG_FILE="/tmp/firewall-setup-remote-$(date +%Y%m%d_%H%M%S).log"

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
log_error() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$LOG_FILE" >&2; }

# Install UFW if needed
if ! command -v ufw &> /dev/null; then
    log "Installing UFW..."
    sudo apt-get update && sudo apt-get install -y ufw >> "$LOG_FILE"
fi

# Backup
BACKUP_DIR="/etc/ufw/backup-$(date +%Y%m%d_%H%M%S)"
sudo mkdir -p "$BACKUP_DIR"
sudo cp -r /etc/ufw/*.rules "$BACKUP_DIR/" 2>/dev/null || true

# Reset UFW
log "Resetting UFW..."
echo "y" | sudo ufw --force disable >> "$LOG_FILE" || true
echo "y" | sudo ufw --force reset >> "$LOG_FILE"

# Configure defaults
log "Setting default policies..."
sudo ufw default deny incoming >> "$LOG_FILE"
sudo ufw default allow outgoing >> "$LOG_FILE"
sudo ufw default deny routed >> "$LOG_FILE"

# Add rules
log "Adding firewall rules..."
sudo ufw allow 22/tcp comment 'SSH access' >> "$LOG_FILE"
sudo ufw allow from "$HOME_IP" to any port 18789 proto tcp comment 'OpenClaw access' >> "$LOG_FILE"
sudo ufw allow proto icmp comment 'Allow ping' >> "$LOG_FILE" 2>&1 || true

# Enable UFW
log "Enabling UFW..."
echo "y" | sudo ufw --force enable >> "$LOG_FILE"

# Show status
log "UFW Status:"
sudo ufw status verbose

log "Firewall configuration completed"
echo "LOG_FILE=$LOG_FILE"
REMOTE_SCRIPT_EOF
)
    
    log "Uploading and executing firewall configuration script..."
    
    # Execute remote script
    if ssh -i "$SSH_KEY_PATH" "${ssh_user}@${droplet_ip}" "bash -s $home_ip" <<< "$remote_script" | tee -a "$LOG_FILE"; then
        log_success "Remote firewall configuration completed"
    else
        log_error "Remote firewall configuration failed"
        exit 4
    fi
    
    # Verify SSH still works
    log "Verifying SSH access after firewall configuration..."
    if ssh -i "$SSH_KEY_PATH" -o ConnectTimeout=10 "${ssh_user}@${droplet_ip}" "echo 'SSH access verified'" >> "$LOG_FILE"; then
        log_success "SSH access verified"
    else
        log_error "SSH access failed after firewall configuration!"
        log_error "You may need to access the server console to fix the firewall"
        exit 4
    fi
}

show_summary() {
    local home_ip=$1
    local droplet_ip=${2:-"localhost"}
    
    cat << EOF

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${GREEN}                   Firewall Setup Complete                          ${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${BLUE}Server:${NC}           $droplet_ip
${BLUE}Authorized IP:${NC}    $home_ip
${BLUE}Log File:${NC}         $LOG_FILE

${YELLOW}Firewall Rules:${NC}
  ✓ Default: Deny all incoming traffic
  ✓ Default: Allow all outgoing traffic
  ✓ Port 22 (SSH): Open to all IPs
  ✓ Port 18789 (OpenClaw): Restricted to $home_ip only
  ✓ ICMP (Ping): Allowed

${YELLOW}Testing Access:${NC}
  # Test SSH (should work from anywhere)
  ssh ${droplet_ip}
  
  # Test OpenClaw (should only work from $home_ip)
  curl http://${droplet_ip}:18789/health

${YELLOW}Managing UFW:${NC}
  sudo ufw status verbose          # Show detailed status
  sudo ufw status numbered         # Show numbered rules
  sudo ufw delete [number]         # Delete a rule
  sudo ufw allow from [ip]         # Add IP to whitelist
  sudo ufw disable                 # Disable firewall
  sudo ufw enable                  # Enable firewall

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

EOF
}

################################################################################
# Main Script
################################################################################

main() {
    log "=== UFW Firewall Setup Script Started ==="
    log "Log file: $LOG_FILE"
    
    # Parse arguments
    if [ $# -lt 1 ]; then
        log_error "Missing required parameter: home_ip"
        usage
    fi
    
    local HOME_IP=$1
    local DROPLET_IP=${2:-""}
    local SSH_USER=${3:-root}
    
    # Validate home IP
    validate_ip "$HOME_IP" "home_ip"
    
    # Determine execution mode
    if [ -z "$DROPLET_IP" ]; then
        log "Mode: Local execution"
        configure_firewall_local "$HOME_IP"
        show_summary "$HOME_IP" "localhost"
    else
        validate_ip "$DROPLET_IP" "droplet_ip"
        log "Mode: Remote execution on ${SSH_USER}@${DROPLET_IP}"
        configure_firewall_remote "$HOME_IP" "$DROPLET_IP" "$SSH_USER"
        show_summary "$HOME_IP" "$DROPLET_IP"
    fi
    
    log_success "=== UFW Firewall Setup Script Completed ==="
}

# Run main function
main "$@"
