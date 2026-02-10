# VPS Configuration Deployment Script

## Overview

The `deploy-config-to-vps.sh` script automates the deployment of OpenClaw configuration files from your local machine to a VPS. It handles file transfers, permission settings, service restarts, and includes comprehensive error handling with rollback capabilities.

## Features

✅ **Automatic Backup** - Creates timestamped backups before deployment  
✅ **SSH Verification** - Validates connection before starting  
✅ **Directory Creation** - Ensures all required directories exist  
✅ **Secure Transfer** - Uses SCP with SSH key authentication  
✅ **Permission Management** - Sets proper permissions (600 for .env, 644 for others)  
✅ **File Verification** - Confirms successful transfers by comparing file sizes  
✅ **Service Management** - Restarts OpenClaw service automatically  
✅ **Log Monitoring** - Tails logs for 30 seconds to check for errors  
✅ **Rollback Capability** - Can restore previous configuration on failure  
✅ **Comprehensive Logging** - Detailed logs saved to `/tmp/vps-deploy-*.log`

## Prerequisites

### Local Machine Requirements

1. **SSH Key** - Ed25519 SSH key at `~/.ssh/id_ed25519`
   ```bash
   # Generate if needed
   ssh-keygen -t ed25519 -C "vps-deployment"
   ```

2. **Configuration Files** - All required files must exist:
   - `bots/business-partner/config/business-partner/openclaw.json`
   - `bots/business-partner/config/business-partner/.env`
   - `config/business-partner/workspace/IDENTITY.md`
   - `config/business-partner/workspace/SOUL.md`
   - `config/business-partner/workspace/USER.md` (optional)

### VPS Requirements

1. **SSH Access** - SSH key must be configured on VPS
2. **OpenClaw Installed** - OpenClaw should be installed and configured
3. **Systemd Service** - `openclaw.service` should be set up
4. **Sudo Access** - User must have sudo privileges for service management

## Usage

### Basic Usage

```bash
./scripts/deploy-config-to-vps.sh <VPS_IP>
```

**Example:**
```bash
./scripts/deploy-config-to-vps.sh 192.168.1.100
```

### Custom SSH User

```bash
./scripts/deploy-config-to-vps.sh <VPS_IP> <ssh_user>
```

**Example:**
```bash
./scripts/deploy-config-to-vps.sh 192.168.1.100 ubuntu
```

### Display Help

```bash
./scripts/deploy-config-to-vps.sh
```

## Files Transferred

The script transfers the following files:

| Local Path | VPS Path | Permissions |
|------------|----------|-------------|
| `bots/business-partner/config/business-partner/openclaw.json` | `~/.openclaw/openclaw.json` | 644 |
| `bots/business-partner/config/business-partner/.env` | `~/.openclaw/.env` | 600 |
| `config/business-partner/workspace/IDENTITY.md` | `~/.openclaw/workspace/IDENTITY.md` | 644 |
| `config/business-partner/workspace/SOUL.md` | `~/.openclaw/workspace/SOUL.md` | 644 |
| `config/business-partner/workspace/USER.md` | `~/.openclaw/workspace/USER.md` | 644 |

**Note:** `USER.md` is optional and will be skipped if not present.

## Deployment Process

The script follows these steps:

1. **Pre-Deployment Checks**
   - Validates VPS IP address format
   - Checks all local configuration files exist
   - Verifies SSH connection to VPS

2. **Backup Creation**
   - Creates timestamped backup directory on VPS
   - Backs up existing configuration files
   - Location: `~/.openclaw/backups/backup_YYYYMMDD_HHMMSS/`

3. **Directory Preparation**
   - Creates `~/.openclaw/` directory
   - Creates `~/.openclaw/workspace/` directory
   - Creates `~/.openclaw/logs/` directory
   - Creates `~/.openclaw/backups/` directory

4. **File Transfer**
   - Transfers all configuration files via SCP
   - Shows progress for each file
   - Tracks successful and failed transfers

5. **Permission Setting**
   - Sets `.env` to 600 (owner read/write only)
   - Sets other files to 644 (owner read/write, others read)

6. **Verification**
   - Checks each file exists on VPS
   - Compares file sizes (local vs remote)
   - Reports any mismatches

7. **Service Restart**
   - Restarts OpenClaw systemd service
   - Waits for service to stabilize
   - Verifies service is running

8. **Log Monitoring**
   - Tails service logs for 30 seconds
   - Highlights errors in red
   - Highlights warnings in yellow
   - Can be interrupted with Ctrl+C

## Output and Logging

### Console Output

The script provides color-coded output:

- 🔵 **Blue** - Informational messages
- ✅ **Green** - Success messages
- ⚠️ **Yellow** - Warnings
- ❌ **Red** - Errors
- 🔷 **Cyan** - Headers and info
- 🔶 **Magenta** - Step indicators

### Log Files

All output is saved to timestamped log files:

```
/tmp/vps-deploy-YYYYMMDD_HHMMSS.log
```

**View logs:**
```bash
cat /tmp/vps-deploy-*.log | tail -100
```

## Error Handling

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Invalid parameters or missing files |
| 2 | SSH connection failed |
| 3 | File transfer failed |
| 4 | Service restart failed |
| 5 | Verification failed |

### Automatic Rollback

If deployment fails after files are transferred, the script will offer to rollback:

```
Do you want to rollback to previous configuration? [y/N]:
```

**Rollback process:**
1. Restores files from backup directory
2. Restarts service with previous configuration
3. Confirms rollback completion

### Manual Rollback

If you need to rollback manually:

```bash
# SSH into VPS
ssh root@YOUR_VPS_IP

# Find backup directory
ls -la ~/.openclaw/backups/

# Restore from specific backup
cp ~/.openclaw/backups/backup_YYYYMMDD_HHMMSS/* ~/.openclaw/

# Restart service
sudo systemctl restart openclaw
```

## Troubleshooting

### SSH Connection Issues

**Problem:** Cannot connect to VPS

**Solutions:**
1. Verify VPS is running:
   ```bash
   ping YOUR_VPS_IP
   ```

2. Check SSH key is configured:
   ```bash
   ssh -i ~/.ssh/id_ed25519 root@YOUR_VPS_IP
   ```

3. Verify firewall allows SSH:
   ```bash
   # On VPS
   sudo ufw status | grep 22
   ```

### File Transfer Failures

**Problem:** Files fail to transfer

**Solutions:**
1. Check disk space on VPS:
   ```bash
   ssh root@YOUR_VPS_IP 'df -h'
   ```

2. Verify file permissions locally:
   ```bash
   ls -la bots/business-partner/config/business-partner/
   ```

3. Check network connectivity:
   ```bash
   ssh root@YOUR_VPS_IP 'ping -c 3 google.com'
   ```

### Service Restart Failures

**Problem:** OpenClaw service won't start

**Solutions:**
1. Check service logs:
   ```bash
   ssh root@YOUR_VPS_IP 'sudo journalctl -u openclaw -n 50'
   ```

2. Verify configuration syntax:
   ```bash
   ssh root@YOUR_VPS_IP 'cat ~/.openclaw/openclaw.json | jq .'
   ```

3. Check .env file:
   ```bash
   ssh root@YOUR_VPS_IP 'cat ~/.openclaw/.env'
   ```

4. Manually restart service:
   ```bash
   ssh root@YOUR_VPS_IP 'sudo systemctl restart openclaw'
   ```

### Permission Issues

**Problem:** Permission denied errors

**Solutions:**
1. Check file ownership:
   ```bash
   ssh root@YOUR_VPS_IP 'ls -la ~/.openclaw/'
   ```

2. Fix permissions:
   ```bash
   ssh root@YOUR_VPS_IP 'chmod 600 ~/.openclaw/.env'
   ssh root@YOUR_VPS_IP 'chmod 644 ~/.openclaw/openclaw.json'
   ```

3. Check directory permissions:
   ```bash
   ssh root@YOUR_VPS_IP 'chmod 755 ~/.openclaw'
   ```

## Best Practices

### Before Deployment

1. **Test Locally** - Verify configuration files are valid
   ```bash
   cd bots/business-partner/config/business-partner
   ./verify-config.sh
   ```

2. **Backup Current State** - Manual backup before deployment
   ```bash
   ssh root@YOUR_VPS_IP 'tar -czf ~/openclaw-backup-$(date +%Y%m%d).tar.gz ~/.openclaw'
   ```

3. **Check Service Status** - Ensure service is running
   ```bash
   ssh root@YOUR_VPS_IP 'sudo systemctl status openclaw'
   ```

### During Deployment

1. **Monitor Output** - Watch for errors or warnings
2. **Don't Interrupt** - Let the script complete (unless critical error)
3. **Review Logs** - Check the log monitoring output for issues

### After Deployment

1. **Verify Service** - Confirm OpenClaw is running
   ```bash
   ssh root@YOUR_VPS_IP 'sudo systemctl status openclaw'
   ```

2. **Test Functionality** - Send test message to bot
   ```bash
   # Via Telegram or configured interface
   ```

3. **Monitor Logs** - Watch for any errors
   ```bash
   ssh root@YOUR_VPS_IP 'sudo journalctl -u openclaw -f'
   ```

4. **Check Backup** - Verify backup was created
   ```bash
   ssh root@YOUR_VPS_IP 'ls -la ~/.openclaw/backups/'
   ```

## Security Considerations

### File Permissions

- **`.env` file** - Contains sensitive API keys, set to 600 (owner only)
- **Other files** - Set to 644 (owner write, all read)
- **Directories** - Set to 755 (owner write, all read/execute)

### SSH Security

- Uses SSH key authentication (no passwords)
- Supports Ed25519 keys (modern, secure)
- Disables strict host key checking for automation (can be changed)

### Backup Security

- Backups stored on VPS only
- Timestamped to prevent overwrites
- Not automatically cleaned up (manual cleanup recommended)

### Network Security

- Uses SCP for encrypted file transfer
- All communication over SSH tunnel
- No plain-text transmission of secrets

## Advanced Usage

### Custom SSH Key Path

Edit the script to use a different SSH key:

```bash
# In deploy-config-to-vps.sh
SSH_KEY_PATH="${HOME}/.ssh/custom_key"
```

### Custom Log Duration

Change how long logs are monitored:

```bash
# In deploy-config-to-vps.sh
LOG_TAIL_DURATION=60  # Monitor for 60 seconds
```

### Skip Service Restart

Comment out the restart step if needed:

```bash
# In deploy-config-to-vps.sh
# restart_openclaw_service "$vps_ip" "$ssh_user"
```

### Dry Run Mode

Add a dry-run mode by setting:

```bash
# At top of script
DRY_RUN=true
```

Then wrap commands:
```bash
if [ "$DRY_RUN" = true ]; then
    log_info "DRY RUN: Would execute: $command"
else
    $command
fi
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Deploy to VPS

on:
  push:
    branches: [main]
    paths:
      - 'bots/business-partner/config/**'
      - 'config/business-partner/workspace/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup SSH Key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.VPS_SSH_KEY }}" > ~/.ssh/id_ed25519
          chmod 600 ~/.ssh/id_ed25519
      
      - name: Deploy Configuration
        run: |
          ./scripts/deploy-config-to-vps.sh ${{ secrets.VPS_IP }}
```

### GitLab CI Example

```yaml
deploy:
  stage: deploy
  script:
    - mkdir -p ~/.ssh
    - echo "$VPS_SSH_KEY" > ~/.ssh/id_ed25519
    - chmod 600 ~/.ssh/id_ed25519
    - ./scripts/deploy-config-to-vps.sh $VPS_IP
  only:
    - main
```

## Maintenance

### Cleanup Old Backups

Remove backups older than 30 days:

```bash
ssh root@YOUR_VPS_IP 'find ~/.openclaw/backups/ -type d -mtime +30 -exec rm -rf {} +'
```

### Update Script

Pull latest version:

```bash
cd /Users/linktrend/Projects/LiNKbot
git pull origin main
chmod +x scripts/deploy-config-to-vps.sh
```

### View Deployment History

Check log files:

```bash
ls -lht /tmp/vps-deploy-*.log | head -10
```

## Support

### Documentation

- **VPS Deployment Guide**: `docs/guides/VPS_DEPLOYMENT.md`
- **OpenClaw Deployment**: `docs/deployment/OPENCLAW_DEPLOYMENT_GUIDE.md`
- **Quick Start**: `START_HERE.md`

### Common Commands

```bash
# Check service status
ssh root@YOUR_VPS_IP 'sudo systemctl status openclaw'

# View logs
ssh root@YOUR_VPS_IP 'sudo journalctl -u openclaw -f'

# Restart service
ssh root@YOUR_VPS_IP 'sudo systemctl restart openclaw'

# Check configuration
ssh root@YOUR_VPS_IP 'cat ~/.openclaw/openclaw.json | jq .'

# List backups
ssh root@YOUR_VPS_IP 'ls -la ~/.openclaw/backups/'
```

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-09 | Initial release |

## License

This script is part of the LiNKbot project and follows the project's license terms.

---

**Last Updated:** February 9, 2026  
**Maintainer:** LiNKbot Team  
**Status:** Production Ready
