#!/bin/bash

################################################################################
# SSH Hardening Script
################################################################################
# Description: Secures SSH access on a VPS droplet by configuring key-based
#              authentication and disabling password authentication.
#
# Usage: ./01-ssh-hardening.sh <droplet_ip> [ssh_user]
#
# Parameters:
#   droplet_ip  - IP address of the VPS droplet (required)
#   ssh_user    - SSH username (optional, defaults to 'root')
#
# Example:
#   ./01-ssh-hardening.sh 192.168.1.100
#   ./01-ssh-hardening.sh 192.168.1.100 ubuntu
#
# Features:
#   - Checks for existing SSH key, generates if needed
#   - Copies SSH key to droplet
#   - Configures sshd_config with secure settings
#   - Tests connection before committing changes
#   - Automatic rollback on failure
#   - Idempotent execution (safe to run multiple times)
#
# Exit Codes:
#   0 - Success
#   1 - Invalid parameters
#   2 - SSH key generation failed
#   3 - SSH key copy failed
#   4 - SSH configuration failed
#   5 - Connection test failed
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
SSH_KEY_TYPE="ed25519"
BACKUP_SUFFIX=".backup.$(date +%Y%m%d_%H%M%S)"
LOG_FILE="/tmp/ssh-hardening-$(date +%Y%m%d_%H%M%S).log"

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
Usage: $0 <droplet_ip> [ssh_user]

Parameters:
  droplet_ip  - IP address of the VPS droplet (required)
  ssh_user    - SSH username (optional, defaults to 'root')

Example:
  $0 192.168.1.100
  $0 192.168.1.100 ubuntu
EOF
    exit 1
}

check_prerequisites() {
    log "Checking prerequisites..."
    
    local missing_tools=()
    
    for tool in ssh ssh-keygen ssh-copy-id; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_error "Please install OpenSSH client tools"
        exit 2
    fi
    
    log_success "All prerequisites met"
}

check_or_generate_ssh_key() {
    log "Checking for SSH key at $SSH_KEY_PATH..."
    
    if [ -f "$SSH_KEY_PATH" ]; then
        log_success "SSH key already exists"
        return 0
    fi
    
    log_warning "SSH key not found, generating new $SSH_KEY_TYPE key..."
    
    if ssh-keygen -t "$SSH_KEY_TYPE" -f "$SSH_KEY_PATH" -N "" -C "vps-access-$(hostname)-$(date +%Y%m%d)"; then
        log_success "SSH key generated successfully"
        chmod 600 "$SSH_KEY_PATH"
        chmod 644 "${SSH_KEY_PATH}.pub"
        
        log "Public key:"
        cat "${SSH_KEY_PATH}.pub"
    else
        log_error "Failed to generate SSH key"
        exit 2
    fi
}

test_ssh_connection() {
    local user=$1
    local host=$2
    local key_path=$3
    
    log "Testing SSH connection to ${user}@${host}..."
    
    if ssh -i "$key_path" -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new "${user}@${host}" "echo 'Connection test successful'" >> "$LOG_FILE" 2>&1; then
        log_success "SSH connection test passed"
        return 0
    else
        log_error "SSH connection test failed"
        return 1
    fi
}

copy_ssh_key() {
    local user=$1
    local host=$2
    
    log "Copying SSH key to ${user}@${host}..."
    
    # Check if key is already authorized (idempotent check)
    if ssh -i "$SSH_KEY_PATH" -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new "${user}@${host}" "exit" >> "$LOG_FILE"; then
        log_success "SSH key already authorized, skipping copy"
        return 0
    fi
    
    log "SSH key not yet authorized, copying..."
    
    if ssh-copy-id -i "$SSH_KEY_PATH" "${user}@${host}" >> "$LOG_FILE"; then
        log_success "SSH key copied successfully"
        
        # Test the connection
        if test_ssh_connection "$user" "$host" "$SSH_KEY_PATH"; then
            return 0
        else
            log_error "Connection test failed after copying key"
            exit 3
        fi
    else
        log_error "Failed to copy SSH key"
        log_error "You may need to enter the password manually"
        exit 3
    fi
}

backup_remote_config() {
    local user=$1
    local host=$2
    local config_file=$3
    
    log "Creating backup of $config_file..."
    
    ssh -i "$SSH_KEY_PATH" "${user}@${host}" "sudo cp $config_file ${config_file}${BACKUP_SUFFIX}" >> "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        log_success "Backup created: ${config_file}${BACKUP_SUFFIX}"
        return 0
    else
        log_error "Failed to create backup"
        return 1
    fi
}

configure_sshd() {
    local user=$1
    local host=$2
    
    log "Configuring SSH daemon with secure settings..."
    
    # Backup current configuration
    if ! backup_remote_config "$user" "$host" "/etc/ssh/sshd_config"; then
        log_error "Failed to backup sshd_config"
        exit 4
    fi
    
    # Create secure sshd configuration
    local sshd_config=$(cat <<'EOF'
# Secure SSH Configuration
# Generated by ssh-hardening script

# Network
Port 22
AddressFamily any
ListenAddress 0.0.0.0
ListenAddress ::

# Authentication
PermitRootLogin prohibit-password
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes

# Kerberos options
KerberosAuthentication no
GSSAPIAuthentication no

# Security
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
MaxAuthTries 3
MaxSessions 10
LoginGraceTime 60

# Subsystem
Subsystem sftp /usr/lib/openssh/sftp-server

# Logging
SyslogFacility AUTH
LogLevel VERBOSE
EOF
)
    
    log "Applying SSH configuration..."
    
    # Apply configuration
    if ssh -i "$SSH_KEY_PATH" "${user}@${host}" "echo '$sshd_config' | sudo tee /etc/ssh/sshd_config.new > /dev/null" >> "$LOG_FILE"; then
        log_success "Configuration file created"
    else
        log_error "Failed to create configuration file"
        exit 4
    fi
    
    # Test configuration
    log "Testing SSH configuration..."
    if ssh -i "$SSH_KEY_PATH" "${user}@${host}" "sudo sshd -t -f /etc/ssh/sshd_config.new" >> "$LOG_FILE"; then
        log_success "SSH configuration is valid"
    else
        log_error "SSH configuration test failed"
        ssh -i "$SSH_KEY_PATH" "${user}@${host}" "sudo rm /etc/ssh/sshd_config.new" >> "$LOG_FILE"
        exit 4
    fi
    
    # Move new configuration into place
    log "Activating new SSH configuration..."
    if ssh -i "$SSH_KEY_PATH" "${user}@${host}" "sudo mv /etc/ssh/sshd_config.new /etc/ssh/sshd_config" >> "$LOG_FILE"; then
        log_success "Configuration activated"
    else
        log_error "Failed to activate configuration"
        exit 4
    fi
    
    # Reload SSH daemon
    log "Reloading SSH daemon..."
    if ssh -i "$SSH_KEY_PATH" "${user}@${host}" "sudo systemctl reload sshd || sudo systemctl reload ssh" >> "$LOG_FILE"; then
        log_success "SSH daemon reloaded"
    else
        log_error "Failed to reload SSH daemon"
        rollback_sshd_config "$user" "$host"
        exit 4
    fi
    
    # Final connection test
    log "Performing final connection test..."
    sleep 2  # Give SSH daemon time to fully reload
    
    if test_ssh_connection "$user" "$host" "$SSH_KEY_PATH"; then
        log_success "SSH hardening completed successfully"
        return 0
    else
        log_error "Final connection test failed, rolling back..."
        rollback_sshd_config "$user" "$host"
        exit 5
    fi
}

rollback_sshd_config() {
    local user=$1
    local host=$2
    
    log_warning "Attempting to rollback SSH configuration..."
    
    if ssh -i "$SSH_KEY_PATH" "${user}@${host}" "sudo cp /etc/ssh/sshd_config${BACKUP_SUFFIX} /etc/ssh/sshd_config && sudo systemctl reload sshd || sudo systemctl reload ssh" >> "$LOG_FILE"; then
        log_success "Rollback successful"
    else
        log_error "Rollback failed - manual intervention required!"
        log_error "Backup file: /etc/ssh/sshd_config${BACKUP_SUFFIX}"
    fi
}

show_summary() {
    local user=$1
    local host=$2
    
    cat << EOF

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${GREEN}                    SSH Hardening Complete                          ${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${BLUE}Server:${NC}        ${user}@${host}
${BLUE}SSH Key:${NC}       $SSH_KEY_PATH
${BLUE}Log File:${NC}      $LOG_FILE

${YELLOW}Security Changes Applied:${NC}
  ✓ Password authentication disabled
  ✓ Root login restricted to key-based auth
  ✓ SSH key authentication enabled
  ✓ Maximum auth tries set to 3
  ✓ X11 forwarding disabled

${YELLOW}Connection Command:${NC}
  ssh -i $SSH_KEY_PATH ${user}@${host}

${YELLOW}Backup Location:${NC}
  /etc/ssh/sshd_config${BACKUP_SUFFIX}

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

EOF
}

################################################################################
# Main Script
################################################################################

main() {
    log "=== SSH Hardening Script Started ==="
    log "Log file: $LOG_FILE"
    
    # Parse arguments
    if [ $# -lt 1 ]; then
        log_error "Missing required parameter: droplet_ip"
        usage
    fi
    
    local DROPLET_IP=$1
    local SSH_USER=${2:-root}
    
    log "Target: ${SSH_USER}@${DROPLET_IP}"
    
    # Validate IP address format
    if ! [[ $DROPLET_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        log_error "Invalid IP address format: $DROPLET_IP"
        exit 1
    fi
    
    # Execute hardening steps
    check_prerequisites
    check_or_generate_ssh_key
    copy_ssh_key "$SSH_USER" "$DROPLET_IP"
    configure_sshd "$SSH_USER" "$DROPLET_IP"
    
    # Show summary
    show_summary "$SSH_USER" "$DROPLET_IP"
    
    log_success "=== SSH Hardening Script Completed ==="
}

# Run main function
main "$@"
