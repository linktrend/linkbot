#!/bin/bash

################################################################################
# VPS Configuration Deployment Script
################################################################################
# Description: Transfers OpenClaw configuration files from local machine to VPS
#              and restarts the OpenClaw service with proper verification.
#
# Usage: ./deploy-config-to-vps.sh <VPS_IP> [ssh_user]
#
# Parameters:
#   VPS_IP      - IP address of the VPS (required)
#   ssh_user    - SSH username (optional, defaults to 'root')
#
# Example:
#   ./deploy-config-to-vps.sh 192.168.1.100
#   ./deploy-config-to-vps.sh 192.168.1.100 ubuntu
#
# Features:
#   - SSH connection verification
#   - Automatic backup of existing configuration
#   - Creates necessary directories on VPS
#   - Transfers all required configuration files
#   - Sets proper file permissions (600 for .env, 644 for others)
#   - Verifies file transfers
#   - Restarts OpenClaw service
#   - Monitors logs for errors
#   - Provides rollback capability
#   - Comprehensive error handling
#
# Exit Codes:
#   0 - Success
#   1 - Invalid parameters or missing files
#   2 - SSH connection failed
#   3 - File transfer failed
#   4 - Service restart failed
#   5 - Verification failed
################################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SSH_KEY_PATH="${HOME}/.ssh/id_ed25519"
LOG_FILE="/tmp/vps-deploy-$(date +%Y%m%d_%H%M%S).log"
BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# VPS Configuration
VPS_OPENCLAW_DIR="~/.openclaw"
VPS_WORKSPACE_DIR="~/.openclaw/workspace"
SERVICE_NAME="openclaw"
LOG_TAIL_DURATION=30

# Local file paths
LOCAL_CONFIG_DIR="${PROJECT_ROOT}/bots/business-partner/config/business-partner"
LOCAL_WORKSPACE_DIR="${PROJECT_ROOT}/config/business-partner/workspace"

# Files to transfer (source -> destination)
declare -A FILES_TO_TRANSFER=(
    ["${LOCAL_CONFIG_DIR}/openclaw.json"]="${VPS_OPENCLAW_DIR}/openclaw.json"
    ["${LOCAL_CONFIG_DIR}/.env"]="${VPS_OPENCLAW_DIR}/.env"
    ["${LOCAL_WORKSPACE_DIR}/IDENTITY.md"]="${VPS_WORKSPACE_DIR}/IDENTITY.md"
    ["${LOCAL_WORKSPACE_DIR}/SOUL.md"]="${VPS_WORKSPACE_DIR}/SOUL.md"
    ["${LOCAL_WORKSPACE_DIR}/USER.md"]="${VPS_WORKSPACE_DIR}/USER.md"
)

# Track deployment state
DEPLOYMENT_STATE="NOT_STARTED"
BACKUP_CREATED=false
FILES_TRANSFERRED=false

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

log_info() {
    echo -e "${CYAN}[$(date +'%Y-%m-%d %H:%M:%S')] ℹ${NC} $*" | tee -a "$LOG_FILE"
}

log_step() {
    echo -e "${MAGENTA}[$(date +'%Y-%m-%d %H:%M:%S')] ➜${NC} $*" | tee -a "$LOG_FILE"
}

print_header() {
    local title="$1"
    local width=80
    echo "" | tee -a "$LOG_FILE"
    echo -e "${CYAN}$(printf '━%.0s' $(seq 1 $width))${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}  $title${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}$(printf '━%.0s' $(seq 1 $width))${NC}" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}

################################################################################
# Helper Functions
################################################################################

usage() {
    cat << EOF
${GREEN}VPS Configuration Deployment Script${NC}

${YELLOW}Usage:${NC}
  $0 <VPS_IP> [ssh_user]

${YELLOW}Parameters:${NC}
  VPS_IP      IP address of the VPS (required)
  ssh_user    SSH username (optional, defaults to 'root')

${YELLOW}Examples:${NC}
  $0 192.168.1.100
  $0 192.168.1.100 ubuntu

${YELLOW}Features:${NC}
  ✓ Automatic backup of existing configuration
  ✓ SSH connection verification
  ✓ Creates necessary directories on VPS
  ✓ Transfers configuration files securely
  ✓ Sets proper file permissions
  ✓ Verifies all transfers
  ✓ Restarts OpenClaw service
  ✓ Monitors logs for errors
  ✓ Rollback capability on failure

${YELLOW}Files Transferred:${NC}
  • openclaw.json  → ~/.openclaw/openclaw.json
  • .env           → ~/.openclaw/.env
  • IDENTITY.md    → ~/.openclaw/workspace/IDENTITY.md
  • SOUL.md        → ~/.openclaw/workspace/SOUL.md
  • USER.md        → ~/.openclaw/workspace/USER.md (if exists)

EOF
    exit 1
}

validate_ip() {
    local ip=$1
    
    if ! [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        log_error "Invalid IP address format: $ip"
        return 1
    fi
    
    # Validate each octet
    IFS='.' read -ra OCTETS <<< "$ip"
    for octet in "${OCTETS[@]}"; do
        if [ "$octet" -gt 255 ]; then
            log_error "Invalid IP address: $ip (octet $octet > 255)"
            return 1
        fi
    done
    
    log_success "Valid IP address: $ip"
    return 0
}

check_local_files() {
    log_step "Checking local configuration files..."
    
    local missing_files=()
    local optional_files=("${LOCAL_WORKSPACE_DIR}/USER.md")
    
    for source_file in "${!FILES_TO_TRANSFER[@]}"; do
        # Check if file is optional
        local is_optional=false
        for optional in "${optional_files[@]}"; do
            if [ "$source_file" = "$optional" ]; then
                is_optional=true
                break
            fi
        done
        
        if [ ! -f "$source_file" ]; then
            if [ "$is_optional" = true ]; then
                log_warning "Optional file not found: $source_file (will skip)"
                unset FILES_TO_TRANSFER["$source_file"]
            else
                log_error "Required file not found: $source_file"
                missing_files+=("$source_file")
            fi
        else
            log_success "Found: $(basename "$source_file")"
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        log_error "Missing required files:"
        for file in "${missing_files[@]}"; do
            echo "  - $file" | tee -a "$LOG_FILE"
        done
        return 1
    fi
    
    log_success "All required local files found"
    return 0
}

check_ssh_connection() {
    local vps_ip=$1
    local ssh_user=$2
    
    log_step "Verifying SSH connection to ${ssh_user}@${vps_ip}..."
    
    # Check if SSH key exists
    if [ ! -f "$SSH_KEY_PATH" ]; then
        log_error "SSH key not found: $SSH_KEY_PATH"
        log_info "Please run ssh-keygen to create an SSH key first"
        return 1
    fi
    
    # Test SSH connection
    if ! ssh -i "$SSH_KEY_PATH" -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=no \
         "${ssh_user}@${vps_ip}" "exit" >> "$LOG_FILE" 2>&1; then
        log_error "Cannot connect to ${ssh_user}@${vps_ip}"
        log_info "Please ensure:"
        log_info "  1. VPS is running and accessible"
        log_info "  2. SSH key is configured on VPS"
        log_info "  3. Firewall allows SSH connections"
        return 1
    fi
    
    log_success "SSH connection verified"
    return 0
}

create_remote_backup() {
    local vps_ip=$1
    local ssh_user=$2
    
    log_step "Creating backup of existing configuration on VPS..."
    
    local backup_dir="~/.openclaw/backups/backup_${BACKUP_TIMESTAMP}"
    
    # Create backup directory
    if ! ssh -i "$SSH_KEY_PATH" "${ssh_user}@${vps_ip}" \
         "mkdir -p $backup_dir" >> "$LOG_FILE" 2>&1; then
        log_warning "Failed to create backup directory (may not exist yet)"
        return 0
    fi
    
    # Backup existing files
    local backup_commands=(
        "[ -f ~/.openclaw/openclaw.json ] && cp ~/.openclaw/openclaw.json $backup_dir/ || true"
        "[ -f ~/.openclaw/.env ] && cp ~/.openclaw/.env $backup_dir/ || true"
        "[ -f ~/.openclaw/workspace/IDENTITY.md ] && cp ~/.openclaw/workspace/IDENTITY.md $backup_dir/ || true"
        "[ -f ~/.openclaw/workspace/SOUL.md ] && cp ~/.openclaw/workspace/SOUL.md $backup_dir/ || true"
        "[ -f ~/.openclaw/workspace/USER.md ] && cp ~/.openclaw/workspace/USER.md $backup_dir/ || true"
    )
    
    for cmd in "${backup_commands[@]}"; do
        ssh -i "$SSH_KEY_PATH" "${ssh_user}@${vps_ip}" "$cmd" >> "$LOG_FILE" 2>&1 || true
    done
    
    BACKUP_CREATED=true
    log_success "Backup created at: $backup_dir"
    return 0
}

create_remote_directories() {
    local vps_ip=$1
    local ssh_user=$2
    
    log_step "Creating necessary directories on VPS..."
    
    local directories=(
        "$VPS_OPENCLAW_DIR"
        "$VPS_WORKSPACE_DIR"
        "${VPS_OPENCLAW_DIR}/logs"
        "${VPS_OPENCLAW_DIR}/backups"
    )
    
    for dir in "${directories[@]}"; do
        if ssh -i "$SSH_KEY_PATH" "${ssh_user}@${vps_ip}" \
           "mkdir -p $dir" >> "$LOG_FILE" 2>&1; then
            log_success "Created/verified: $dir"
        else
            log_error "Failed to create directory: $dir"
            return 1
        fi
    done
    
    log_success "All directories created"
    return 0
}

transfer_files() {
    local vps_ip=$1
    local ssh_user=$2
    
    log_step "Transferring configuration files to VPS..."
    
    local transferred_count=0
    local failed_transfers=()
    
    for source_file in "${!FILES_TO_TRANSFER[@]}"; do
        local dest_file="${FILES_TO_TRANSFER[$source_file]}"
        local filename=$(basename "$source_file")
        
        log_info "Transferring: $filename"
        
        if scp -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no \
           "$source_file" "${ssh_user}@${vps_ip}:${dest_file}" >> "$LOG_FILE" 2>&1; then
            log_success "  ✓ $filename transferred"
            ((transferred_count++))
        else
            log_error "  ✗ Failed to transfer $filename"
            failed_transfers+=("$filename")
        fi
    done
    
    if [ ${#failed_transfers[@]} -gt 0 ]; then
        log_error "Failed to transfer ${#failed_transfers[@]} file(s):"
        for file in "${failed_transfers[@]}"; do
            echo "  - $file" | tee -a "$LOG_FILE"
        done
        return 1
    fi
    
    FILES_TRANSFERRED=true
    log_success "All files transferred successfully ($transferred_count files)"
    return 0
}

set_remote_permissions() {
    local vps_ip=$1
    local ssh_user=$2
    
    log_step "Setting file permissions on VPS..."
    
    # Set strict permissions for .env (600 - owner read/write only)
    if ssh -i "$SSH_KEY_PATH" "${ssh_user}@${vps_ip}" \
       "chmod 600 ${VPS_OPENCLAW_DIR}/.env" >> "$LOG_FILE" 2>&1; then
        log_success "Set permissions 600 on .env"
    else
        log_error "Failed to set permissions on .env"
        return 1
    fi
    
    # Set standard permissions for other files (644 - owner read/write, others read)
    local other_files=(
        "${VPS_OPENCLAW_DIR}/openclaw.json"
        "${VPS_WORKSPACE_DIR}/IDENTITY.md"
        "${VPS_WORKSPACE_DIR}/SOUL.md"
    )
    
    # Add USER.md if it was transferred
    if [ -f "${LOCAL_WORKSPACE_DIR}/USER.md" ]; then
        other_files+=("${VPS_WORKSPACE_DIR}/USER.md")
    fi
    
    for file in "${other_files[@]}"; do
        if ssh -i "$SSH_KEY_PATH" "${ssh_user}@${vps_ip}" \
           "chmod 644 $file" >> "$LOG_FILE" 2>&1; then
            log_success "Set permissions 644 on $(basename "$file")"
        else
            log_warning "Failed to set permissions on $(basename "$file")"
        fi
    done
    
    log_success "File permissions configured"
    return 0
}

verify_remote_files() {
    local vps_ip=$1
    local ssh_user=$2
    
    log_step "Verifying transferred files on VPS..."
    
    local verification_failed=false
    
    for source_file in "${!FILES_TO_TRANSFER[@]}"; do
        local dest_file="${FILES_TO_TRANSFER[$source_file]}"
        local filename=$(basename "$source_file")
        
        # Check if file exists on remote
        if ssh -i "$SSH_KEY_PATH" "${ssh_user}@${vps_ip}" \
           "[ -f $dest_file ]" >> "$LOG_FILE" 2>&1; then
            
            # Get file sizes
            local local_size=$(stat -f%z "$source_file" 2>/dev/null || stat -c%s "$source_file" 2>/dev/null)
            local remote_size=$(ssh -i "$SSH_KEY_PATH" "${ssh_user}@${vps_ip}" \
                              "stat -c%s $dest_file 2>/dev/null || stat -f%z $dest_file 2>/dev/null")
            
            if [ "$local_size" = "$remote_size" ]; then
                log_success "  ✓ $filename verified (${local_size} bytes)"
            else
                log_error "  ✗ $filename size mismatch (local: ${local_size}, remote: ${remote_size})"
                verification_failed=true
            fi
        else
            log_error "  ✗ $filename not found on VPS"
            verification_failed=true
        fi
    done
    
    if [ "$verification_failed" = true ]; then
        log_error "File verification failed"
        return 1
    fi
    
    log_success "All files verified successfully"
    return 0
}

restart_openclaw_service() {
    local vps_ip=$1
    local ssh_user=$2
    
    log_step "Restarting OpenClaw service..."
    
    # Check if service exists
    if ! ssh -i "$SSH_KEY_PATH" "${ssh_user}@${vps_ip}" \
         "sudo systemctl list-unit-files | grep -q ${SERVICE_NAME}.service" >> "$LOG_FILE" 2>&1; then
        log_warning "OpenClaw service not found on VPS"
        log_info "Service may need to be set up manually"
        return 0
    fi
    
    # Restart service
    if ssh -i "$SSH_KEY_PATH" "${ssh_user}@${vps_ip}" \
       "sudo systemctl restart ${SERVICE_NAME}" >> "$LOG_FILE" 2>&1; then
        log_success "Service restart command sent"
    else
        log_error "Failed to restart service"
        return 1
    fi
    
    # Wait for service to stabilize
    log_info "Waiting for service to stabilize..."
    sleep 5
    
    # Check service status
    if ssh -i "$SSH_KEY_PATH" "${ssh_user}@${vps_ip}" \
       "sudo systemctl is-active --quiet ${SERVICE_NAME}" >> "$LOG_FILE" 2>&1; then
        log_success "OpenClaw service is running"
    else
        log_error "OpenClaw service failed to start"
        log_info "Checking service status..."
        ssh -i "$SSH_KEY_PATH" "${ssh_user}@${vps_ip}" \
            "sudo systemctl status ${SERVICE_NAME} --no-pager" | tee -a "$LOG_FILE"
        return 1
    fi
    
    return 0
}

monitor_logs() {
    local vps_ip=$1
    local ssh_user=$2
    local duration=$3
    
    log_step "Monitoring service logs for ${duration} seconds..."
    
    # Tail logs for specified duration
    log_info "Press Ctrl+C to stop monitoring early"
    echo "" | tee -a "$LOG_FILE"
    
    ssh -i "$SSH_KEY_PATH" "${ssh_user}@${vps_ip}" \
        "timeout ${duration} sudo journalctl -u ${SERVICE_NAME} -f --since '30 seconds ago'" 2>&1 | \
        while IFS= read -r line; do
            # Highlight errors in red
            if echo "$line" | grep -qi "error"; then
                echo -e "${RED}$line${NC}" | tee -a "$LOG_FILE"
            # Highlight warnings in yellow
            elif echo "$line" | grep -qi "warning\|warn"; then
                echo -e "${YELLOW}$line${NC}" | tee -a "$LOG_FILE"
            else
                echo "$line" | tee -a "$LOG_FILE"
            fi
        done || true
    
    echo "" | tee -a "$LOG_FILE"
    log_success "Log monitoring complete"
    return 0
}

rollback_deployment() {
    local vps_ip=$1
    local ssh_user=$2
    
    log_warning "Initiating rollback..."
    
    if [ "$BACKUP_CREATED" = false ]; then
        log_error "No backup available for rollback"
        return 1
    fi
    
    local backup_dir="~/.openclaw/backups/backup_${BACKUP_TIMESTAMP}"
    
    log_info "Restoring files from backup: $backup_dir"
    
    # Restore files
    local restore_commands=(
        "[ -f $backup_dir/openclaw.json ] && cp $backup_dir/openclaw.json ~/.openclaw/ || true"
        "[ -f $backup_dir/.env ] && cp $backup_dir/.env ~/.openclaw/ || true"
        "[ -f $backup_dir/IDENTITY.md ] && cp $backup_dir/IDENTITY.md ~/.openclaw/workspace/ || true"
        "[ -f $backup_dir/SOUL.md ] && cp $backup_dir/SOUL.md ~/.openclaw/workspace/ || true"
        "[ -f $backup_dir/USER.md ] && cp $backup_dir/USER.md ~/.openclaw/workspace/ || true"
    )
    
    for cmd in "${restore_commands[@]}"; do
        ssh -i "$SSH_KEY_PATH" "${ssh_user}@${vps_ip}" "$cmd" >> "$LOG_FILE" 2>&1 || true
    done
    
    # Restart service with old configuration
    log_info "Restarting service with previous configuration..."
    ssh -i "$SSH_KEY_PATH" "${ssh_user}@${vps_ip}" \
        "sudo systemctl restart ${SERVICE_NAME}" >> "$LOG_FILE" 2>&1 || true
    
    log_success "Rollback completed"
    log_info "Previous configuration restored from: $backup_dir"
    return 0
}

print_deployment_summary() {
    local vps_ip=$1
    local ssh_user=$2
    local status=$3
    
    print_header "Deployment Summary"
    
    cat << EOF | tee -a "$LOG_FILE"
${BLUE}Target Server:${NC}      ${ssh_user}@${vps_ip}
${BLUE}Timestamp:${NC}          $(date +'%Y-%m-%d %H:%M:%S')
${BLUE}Status:${NC}             $status
${BLUE}Files Transferred:${NC}  ${#FILES_TO_TRANSFER[@]}
${BLUE}Backup Created:${NC}     $BACKUP_CREATED
${BLUE}Service:${NC}            $SERVICE_NAME
${BLUE}Log File:${NC}           $LOG_FILE

EOF

    if [ "$status" = "${GREEN}SUCCESS${NC}" ]; then
        cat << EOF | tee -a "$LOG_FILE"
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${GREEN}  Deployment completed successfully!${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${YELLOW}Next Steps:${NC}
  1. Monitor service: ssh ${ssh_user}@${vps_ip} 'sudo journalctl -u ${SERVICE_NAME} -f'
  2. Check status:    ssh ${ssh_user}@${vps_ip} 'sudo systemctl status ${SERVICE_NAME}'
  3. Test bot:        Send a test message to verify functionality

${YELLOW}Backup Location:${NC}
  ~/.openclaw/backups/backup_${BACKUP_TIMESTAMP}/

${YELLOW}Useful Commands:${NC}
  sudo systemctl status ${SERVICE_NAME}       # Check service status
  sudo systemctl restart ${SERVICE_NAME}      # Restart service
  sudo journalctl -u ${SERVICE_NAME} -f       # Follow logs
  tail -f ~/.openclaw/logs/openclaw.log       # Application logs

EOF
    else
        cat << EOF | tee -a "$LOG_FILE"
${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${RED}  Deployment failed!${NC}
${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${YELLOW}Troubleshooting:${NC}
  1. Check log file:  cat $LOG_FILE
  2. Verify SSH:      ssh ${ssh_user}@${vps_ip}
  3. Check service:   ssh ${ssh_user}@${vps_ip} 'sudo systemctl status ${SERVICE_NAME}'

${YELLOW}Rollback:${NC}
  To rollback to previous configuration:
  ssh ${ssh_user}@${vps_ip} 'cp ~/.openclaw/backups/backup_${BACKUP_TIMESTAMP}/* ~/.openclaw/ && sudo systemctl restart ${SERVICE_NAME}'

EOF
    fi
}

################################################################################
# Main Deployment Function
################################################################################

deploy_to_vps() {
    local vps_ip=$1
    local ssh_user=$2
    
    print_header "VPS Configuration Deployment"
    
    log_info "Target: ${ssh_user}@${vps_ip}"
    log_info "Log file: $LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    
    # Pre-deployment checks
    DEPLOYMENT_STATE="CHECKING"
    check_local_files || { log_error "Local file check failed"; return 1; }
    check_ssh_connection "$vps_ip" "$ssh_user" || { log_error "SSH connection failed"; return 2; }
    
    # Create backup
    DEPLOYMENT_STATE="BACKING_UP"
    create_remote_backup "$vps_ip" "$ssh_user" || log_warning "Backup creation failed (continuing)"
    
    # Prepare VPS
    DEPLOYMENT_STATE="PREPARING"
    create_remote_directories "$vps_ip" "$ssh_user" || { log_error "Directory creation failed"; return 3; }
    
    # Transfer files
    DEPLOYMENT_STATE="TRANSFERRING"
    transfer_files "$vps_ip" "$ssh_user" || { log_error "File transfer failed"; return 3; }
    
    # Set permissions
    DEPLOYMENT_STATE="CONFIGURING"
    set_remote_permissions "$vps_ip" "$ssh_user" || { log_error "Permission setting failed"; return 3; }
    
    # Verify transfers
    DEPLOYMENT_STATE="VERIFYING"
    verify_remote_files "$vps_ip" "$ssh_user" || { log_error "File verification failed"; return 5; }
    
    # Restart service
    DEPLOYMENT_STATE="RESTARTING"
    restart_openclaw_service "$vps_ip" "$ssh_user" || { log_error "Service restart failed"; return 4; }
    
    # Monitor logs
    DEPLOYMENT_STATE="MONITORING"
    monitor_logs "$vps_ip" "$ssh_user" "$LOG_TAIL_DURATION"
    
    DEPLOYMENT_STATE="COMPLETE"
    return 0
}

################################################################################
# Main Script
################################################################################

main() {
    # Parse arguments
    if [ $# -lt 1 ]; then
        usage
    fi
    
    local VPS_IP=$1
    local SSH_USER=${2:-root}
    
    # Validate IP
    if ! validate_ip "$VPS_IP"; then
        log_error "Invalid IP address provided"
        exit 1
    fi
    
    # Start deployment
    log "=== VPS Configuration Deployment Started ==="
    log "Timestamp: $(date +'%Y-%m-%d %H:%M:%S')"
    
    # Run deployment
    if deploy_to_vps "$VPS_IP" "$SSH_USER"; then
        print_deployment_summary "$VPS_IP" "$SSH_USER" "${GREEN}SUCCESS${NC}"
        log_success "=== Deployment Completed Successfully ==="
        exit 0
    else
        local exit_code=$?
        print_deployment_summary "$VPS_IP" "$SSH_USER" "${RED}FAILED${NC}"
        
        # Ask for rollback
        echo "" | tee -a "$LOG_FILE"
        log_warning "Deployment failed at stage: $DEPLOYMENT_STATE"
        
        if [ "$BACKUP_CREATED" = true ] && [ "$FILES_TRANSFERRED" = true ]; then
            read -p "$(echo -e ${YELLOW}Do you want to rollback to previous configuration? [y/N]: ${NC})" -n 1 -r
            echo "" | tee -a "$LOG_FILE"
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rollback_deployment "$VPS_IP" "$SSH_USER"
            fi
        fi
        
        log_error "=== Deployment Failed ==="
        exit $exit_code
    fi
}

# Run main function
main "$@"
