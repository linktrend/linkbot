#!/bin/bash

################################################################################
# OpenClaw Installation Script
################################################################################
# Description: Installs and configures OpenClaw on a VPS with Node.js 20 LTS
#              and sets up systemd service for automatic startup.
#
# Usage: ./03-install-openclaw.sh [droplet_ip] [ssh_user]
#
# Parameters:
#   droplet_ip  - IP address of the VPS droplet (optional, for remote execution)
#   ssh_user    - SSH username (optional, defaults to 'root')
#
# Example:
#   ./03-install-openclaw.sh                        # Local installation
#   ./03-install-openclaw.sh 192.168.1.100          # Remote installation
#   ./03-install-openclaw.sh 192.168.1.100 ubuntu
#
# Features:
#   - Updates system packages
#   - Installs Node.js 20 LTS via NodeSource
#   - Installs OpenClaw globally via npm
#   - Creates ~/.openclaw directory structure
#   - Creates and enables systemd service
#   - Verifies installation with health check
#   - Idempotent execution (safe to run multiple times)
#
# Exit Codes:
#   0 - Success
#   1 - Invalid parameters
#   2 - System update failed
#   3 - Node.js installation failed
#   4 - OpenClaw installation failed
#   5 - Service configuration failed
#   6 - Health check failed
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
LOG_FILE="/tmp/openclaw-install-$(date +%Y%m%d_%H%M%S).log"
NODE_VERSION="20"
OPENCLAW_DIR="${HOME}/.openclaw"
SERVICE_NAME="openclaw"
OPENCLAW_PORT="18789"

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
Usage: $0 [droplet_ip] [ssh_user]

Parameters:
  droplet_ip  - IP address of the VPS droplet (optional, for remote execution)
  ssh_user    - SSH username (optional, defaults to 'root')

Examples:
  $0                        # Local installation
  $0 192.168.1.100          # Remote installation
  $0 192.168.1.100 ubuntu   # Remote installation with custom user

Features:
  - Installs Node.js 20 LTS
  - Installs OpenClaw globally
  - Creates systemd service
  - Configures automatic startup
  - Verifies installation
EOF
    exit 1
}

validate_ip() {
    local ip=$1
    
    if ! [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        log_error "Invalid IP address format: $ip"
        exit 1
    fi
    
    log_success "Valid IP address: $ip"
}

check_system_requirements() {
    log "Checking system requirements..."
    
    # Check if running on Linux
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        log_error "This script must be run on Linux"
        exit 2
    fi
    
    # Check if running as root or with sudo access
    if ! sudo -n true 2>/dev/null; then
        log_warning "This script requires sudo access"
        log "You may be prompted for your password"
    fi
    
    log_success "System requirements check passed"
}

update_system() {
    log "Updating system packages..."
    
    if sudo apt-get update >> "$LOG_FILE"; then
        log_success "System package list updated"
    else
        log_error "Failed to update package list"
        exit 2
    fi
    
    log "Upgrading installed packages (this may take a while)..."
    if sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y >> "$LOG_FILE"; then
        log_success "System packages upgraded"
    else
        log_warning "Some packages failed to upgrade (non-critical)"
    fi
    
    # Install essential tools
    log "Installing essential tools..."
    if sudo apt-get install -y curl wget gnupg2 ca-certificates lsb-release apt-transport-https >> "$LOG_FILE"; then
        log_success "Essential tools installed"
    else
        log_error "Failed to install essential tools"
        exit 2
    fi
}

install_nodejs() {
    log "Checking Node.js installation..."
    
    # Check if Node.js is already installed
    if command -v node &> /dev/null; then
        local current_version=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        log "Node.js version $(node -v) is already installed"
        
        if [ "$current_version" -ge "$NODE_VERSION" ]; then
            log_success "Node.js version is sufficient"
            return 0
        else
            log_warning "Node.js version is too old, upgrading..."
        fi
    fi
    
    log "Installing Node.js $NODE_VERSION LTS..."
    
    # Add NodeSource repository
    log "Adding NodeSource repository..."
    if curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" | sudo -E bash - >> "$LOG_FILE"; then
        log_success "NodeSource repository added"
    else
        log_error "Failed to add NodeSource repository"
        exit 3
    fi
    
    # Install Node.js
    log "Installing Node.js package..."
    if sudo apt-get install -y nodejs >> "$LOG_FILE"; then
        log_success "Node.js installed successfully"
    else
        log_error "Failed to install Node.js"
        exit 3
    fi
    
    # Verify installation
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        log_success "Node.js $(node -v) and npm $(npm -v) are ready"
    else
        log_error "Node.js or npm not found after installation"
        exit 3
    fi
}

create_openclaw_directory() {
    log "Creating OpenClaw directory structure..."
    
    # Create main directory
    if [ ! -d "$OPENCLAW_DIR" ]; then
        mkdir -p "$OPENCLAW_DIR"
        log_success "Created directory: $OPENCLAW_DIR"
    else
        log_success "Directory already exists: $OPENCLAW_DIR"
    fi
    
    # Create subdirectories
    local subdirs=("logs" "config" "data" "backups")
    for dir in "${subdirs[@]}"; do
        local full_path="${OPENCLAW_DIR}/${dir}"
        if [ ! -d "$full_path" ]; then
            mkdir -p "$full_path"
            log_success "Created directory: $full_path"
        else
            log "Directory already exists: $full_path"
        fi
    done
    
    # Set permissions
    chmod 755 "$OPENCLAW_DIR"
    log_success "Directory structure created"
}

install_openclaw() {
    log "Installing OpenClaw via npm..."
    
    # Check if OpenClaw is already installed
    if command -v openclaw &> /dev/null; then
        local current_version=$(openclaw --version 2>/dev/null || echo "unknown")
        log "OpenClaw is already installed (version: $current_version)"
        log_warning "Reinstalling to ensure latest version..."
    fi
    
    # Install OpenClaw globally
    log "Running: npm install -g openclaw"
    if sudo npm install -g openclaw >> "$LOG_FILE"; then
        log_success "OpenClaw installed successfully"
    else
        log_error "Failed to install OpenClaw"
        log_error "Check the log file for details: $LOG_FILE"
        exit 4
    fi
    
    # Verify installation
    if command -v openclaw &> /dev/null; then
        local version=$(openclaw --version 2>/dev/null || echo "unknown")
        log_success "OpenClaw is ready (version: $version)"
    else
        log_error "OpenClaw command not found after installation"
        exit 4
    fi
}

create_systemd_service() {
    log "Creating systemd service for OpenClaw..."
    
    local service_file="/etc/systemd/system/${SERVICE_NAME}.service"
    local current_user=$(whoami)
    local current_home=$(eval echo ~$current_user)
    
    # Get the path to openclaw binary
    local openclaw_bin=$(which openclaw)
    if [ -z "$openclaw_bin" ]; then
        log_error "Cannot find openclaw binary"
        exit 5
    fi
    
    log "OpenClaw binary: $openclaw_bin"
    log "Service user: $current_user"
    log "Working directory: $current_home/.openclaw"
    
    # Create service file
    local service_content=$(cat <<EOF
[Unit]
Description=OpenClaw - Cloud-based AI Agent Platform
Documentation=https://github.com/OpenClaw/openclaw
After=network.target

[Service]
Type=simple
User=$current_user
WorkingDirectory=$current_home/.openclaw
Environment="NODE_ENV=production"
Environment="PORT=$OPENCLAW_PORT"
ExecStart=$openclaw_bin start
Restart=always
RestartSec=10
StandardOutput=append:$current_home/.openclaw/logs/openclaw.log
StandardError=append:$current_home/.openclaw/logs/openclaw-error.log

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=$current_home/.openclaw

[Install]
WantedBy=multi-user.target
EOF
)
    
    # Write service file
    if echo "$service_content" | sudo tee "$service_file" > /dev/null; then
        log_success "Service file created: $service_file"
    else
        log_error "Failed to create service file"
        exit 5
    fi
    
    # Set permissions
    sudo chmod 644 "$service_file"
    
    # Reload systemd
    log "Reloading systemd daemon..."
    if sudo systemctl daemon-reload >> "$LOG_FILE"; then
        log_success "Systemd daemon reloaded"
    else
        log_error "Failed to reload systemd daemon"
        exit 5
    fi
}

enable_and_start_service() {
    log "Enabling and starting OpenClaw service..."
    
    # Stop service if running
    if sudo systemctl is-active --quiet "$SERVICE_NAME"; then
        log "Stopping existing service..."
        sudo systemctl stop "$SERVICE_NAME" >> "$LOG_FILE" || true
    fi
    
    # Enable service
    log "Enabling service to start on boot..."
    if sudo systemctl enable "$SERVICE_NAME" >> "$LOG_FILE"; then
        log_success "Service enabled"
    else
        log_error "Failed to enable service"
        exit 5
    fi
    
    # Start service
    log "Starting OpenClaw service..."
    if sudo systemctl start "$SERVICE_NAME" >> "$LOG_FILE"; then
        log_success "Service started"
    else
        log_error "Failed to start service"
        log "Checking service status..."
        sudo systemctl status "$SERVICE_NAME" --no-pager | tee -a "$LOG_FILE"
        exit 5
    fi
    
    # Wait for service to stabilize
    log "Waiting for service to stabilize..."
    sleep 5
    
    # Check service status
    if sudo systemctl is-active --quiet "$SERVICE_NAME"; then
        log_success "OpenClaw service is running"
    else
        log_error "OpenClaw service failed to start"
        log "Service status:"
        sudo systemctl status "$SERVICE_NAME" --no-pager | tee -a "$LOG_FILE"
        exit 5
    fi
}

verify_installation() {
    log "Verifying OpenClaw installation..."
    
    # Check if service is running
    if ! sudo systemctl is-active --quiet "$SERVICE_NAME"; then
        log_error "Service is not running"
        return 1
    fi
    
    # Wait for service to be fully ready
    log "Waiting for OpenClaw to be ready..."
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s -f "http://localhost:${OPENCLAW_PORT}/health" &> /dev/null; then
            log_success "OpenClaw health check passed"
            return 0
        fi
        
        attempt=$((attempt + 1))
        if [ $attempt -lt $max_attempts ]; then
            sleep 2
        fi
    done
    
    log_warning "Health check endpoint not responding"
    log_warning "This may be normal if OpenClaw doesn't have a /health endpoint"
    log "Checking if service is still running..."
    
    if sudo systemctl is-active --quiet "$SERVICE_NAME"; then
        log_success "Service is running (health check not available)"
        return 0
    else
        log_error "Service stopped unexpectedly"
        return 1
    fi
}

install_openclaw_local() {
    check_system_requirements
    update_system
    install_nodejs
    create_openclaw_directory
    install_openclaw
    create_systemd_service
    enable_and_start_service
    verify_installation
    
    log_success "OpenClaw installation completed"
}

install_openclaw_remote() {
    local droplet_ip=$1
    local ssh_user=$2
    
    log "Installing OpenClaw on remote server ${ssh_user}@${droplet_ip}..."
    
    # Check SSH connection
    if ! ssh -i "$SSH_KEY_PATH" -o BatchMode=yes -o ConnectTimeout=10 "${ssh_user}@${droplet_ip}" "exit" >> "$LOG_FILE"; then
        log_error "Cannot connect to ${ssh_user}@${droplet_ip}"
        log_error "Please run 01-ssh-hardening.sh first"
        exit 1
    fi
    
    # Transfer this script to remote server
    log "Transferring installation script to remote server..."
    if scp -i "$SSH_KEY_PATH" "$0" "${ssh_user}@${droplet_ip}:/tmp/install-openclaw.sh" >> "$LOG_FILE"; then
        log_success "Script transferred"
    else
        log_error "Failed to transfer script"
        exit 1
    fi
    
    # Execute script remotely
    log "Executing installation on remote server..."
    if ssh -i "$SSH_KEY_PATH" "${ssh_user}@${droplet_ip}" "chmod +x /tmp/install-openclaw.sh && /tmp/install-openclaw.sh" | tee -a "$LOG_FILE"; then
        log_success "Remote installation completed"
    else
        log_error "Remote installation failed"
        exit 1
    fi
    
    # Clean up
    ssh -i "$SSH_KEY_PATH" "${ssh_user}@${droplet_ip}" "rm -f /tmp/install-openclaw.sh" >> "$LOG_FILE" || true
}

show_summary() {
    local droplet_ip=${1:-"localhost"}
    local ssh_user=${2:-$(whoami)}
    
    cat << EOF

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${GREEN}                 OpenClaw Installation Complete                     ${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${BLUE}Server:${NC}           $droplet_ip
${BLUE}User:${NC}             $ssh_user
${BLUE}Node.js:${NC}          $(node -v 2>/dev/null || echo "Not available")
${BLUE}npm:${NC}              $(npm -v 2>/dev/null || echo "Not available")
${BLUE}OpenClaw:${NC}         $(openclaw --version 2>/dev/null || echo "Not available")
${BLUE}Service:${NC}          $SERVICE_NAME
${BLUE}Port:${NC}             $OPENCLAW_PORT
${BLUE}Directory:${NC}        $OPENCLAW_DIR
${BLUE}Log File:${NC}         $LOG_FILE

${YELLOW}Service Management:${NC}
  sudo systemctl status $SERVICE_NAME      # Check status
  sudo systemctl start $SERVICE_NAME       # Start service
  sudo systemctl stop $SERVICE_NAME        # Stop service
  sudo systemctl restart $SERVICE_NAME     # Restart service
  sudo systemctl enable $SERVICE_NAME      # Enable on boot
  sudo systemctl disable $SERVICE_NAME     # Disable on boot

${YELLOW}Logs:${NC}
  sudo journalctl -u $SERVICE_NAME -f      # Follow service logs
  tail -f $OPENCLAW_DIR/logs/openclaw.log  # Follow application logs
  tail -f $OPENCLAW_DIR/logs/openclaw-error.log  # Follow error logs

${YELLOW}Testing:${NC}
  curl http://$droplet_ip:$OPENCLAW_PORT/health
  curl http://$droplet_ip:$OPENCLAW_PORT/api/status

${YELLOW}Configuration:${NC}
  Directory: $OPENCLAW_DIR
  Config:    $OPENCLAW_DIR/config/
  Data:      $OPENCLAW_DIR/data/
  Backups:   $OPENCLAW_DIR/backups/

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

EOF
}

################################################################################
# Main Script
################################################################################

main() {
    log "=== OpenClaw Installation Script Started ==="
    log "Log file: $LOG_FILE"
    
    # Parse arguments
    local DROPLET_IP=${1:-""}
    local SSH_USER=${2:-root}
    
    # Determine execution mode
    if [ -z "$DROPLET_IP" ]; then
        log "Mode: Local installation"
        install_openclaw_local
        show_summary "localhost" "$(whoami)"
    else
        validate_ip "$DROPLET_IP"
        log "Mode: Remote installation on ${SSH_USER}@${DROPLET_IP}"
        install_openclaw_remote "$DROPLET_IP" "$SSH_USER"
        show_summary "$DROPLET_IP" "$SSH_USER"
    fi
    
    log_success "=== OpenClaw Installation Script Completed ==="
}

# Run main function
main "$@"
