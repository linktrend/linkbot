# VPS Config Deployment - Quick Reference

## One-Line Deployment

```bash
./scripts/deploy-config-to-vps.sh YOUR_VPS_IP
```

## Common Commands

### Deploy to VPS (root user)
```bash
./scripts/deploy-config-to-vps.sh 192.168.1.100
```

### Deploy with custom user
```bash
./scripts/deploy-config-to-vps.sh 192.168.1.100 ubuntu
```

### View help
```bash
./scripts/deploy-config-to-vps.sh
```

## What Gets Deployed

```
Local                                          → VPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
openclaw.json                                  → ~/.openclaw/openclaw.json
.env                                           → ~/.openclaw/.env
IDENTITY.md                                    → ~/.openclaw/workspace/IDENTITY.md
SOUL.md                                        → ~/.openclaw/workspace/SOUL.md
USER.md (optional)                             → ~/.openclaw/workspace/USER.md
```

## Quick Checks

### Before Deployment
```bash
# Check local files exist
ls -la bots/business-partner/config/business-partner/
ls -la config/business-partner/workspace/

# Test SSH connection
ssh root@YOUR_VPS_IP 'echo "Connection OK"'
```

### After Deployment
```bash
# Check service status
ssh root@YOUR_VPS_IP 'sudo systemctl status openclaw'

# View logs
ssh root@YOUR_VPS_IP 'sudo journalctl -u openclaw -n 50'

# Verify files
ssh root@YOUR_VPS_IP 'ls -la ~/.openclaw/'
```

## Troubleshooting

### Connection Failed
```bash
# Test SSH
ssh -v root@YOUR_VPS_IP

# Check firewall
ssh root@YOUR_VPS_IP 'sudo ufw status'
```

### Service Won't Start
```bash
# Check logs
ssh root@YOUR_VPS_IP 'sudo journalctl -u openclaw -n 100'

# Verify config
ssh root@YOUR_VPS_IP 'cat ~/.openclaw/openclaw.json | jq .'

# Restart manually
ssh root@YOUR_VPS_IP 'sudo systemctl restart openclaw'
```

### Rollback
```bash
# List backups
ssh root@YOUR_VPS_IP 'ls -la ~/.openclaw/backups/'

# Restore from backup
ssh root@YOUR_VPS_IP 'cp ~/.openclaw/backups/backup_YYYYMMDD_HHMMSS/* ~/.openclaw/ && sudo systemctl restart openclaw'
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success ✅ |
| 1 | Invalid parameters or missing files ❌ |
| 2 | SSH connection failed ❌ |
| 3 | File transfer failed ❌ |
| 4 | Service restart failed ❌ |
| 5 | Verification failed ❌ |

## Log Files

```bash
# View latest deployment log
ls -t /tmp/vps-deploy-*.log | head -1 | xargs cat

# Follow deployment log
tail -f /tmp/vps-deploy-*.log
```

## Permissions

| File | Permission | Meaning |
|------|------------|---------|
| `.env` | 600 | Owner read/write only (secure) |
| `openclaw.json` | 644 | Owner read/write, others read |
| `*.md` | 644 | Owner read/write, others read |

## Service Management

```bash
# Status
ssh root@YOUR_VPS_IP 'sudo systemctl status openclaw'

# Start
ssh root@YOUR_VPS_IP 'sudo systemctl start openclaw'

# Stop
ssh root@YOUR_VPS_IP 'sudo systemctl stop openclaw'

# Restart
ssh root@YOUR_VPS_IP 'sudo systemctl restart openclaw'

# Enable on boot
ssh root@YOUR_VPS_IP 'sudo systemctl enable openclaw'

# Disable on boot
ssh root@YOUR_VPS_IP 'sudo systemctl disable openclaw'
```

## Useful One-Liners

### Deploy and watch logs
```bash
./scripts/deploy-config-to-vps.sh YOUR_VPS_IP && ssh root@YOUR_VPS_IP 'sudo journalctl -u openclaw -f'
```

### Deploy with backup verification
```bash
./scripts/deploy-config-to-vps.sh YOUR_VPS_IP && ssh root@YOUR_VPS_IP 'ls -la ~/.openclaw/backups/ | tail -1'
```

### Deploy and check status
```bash
./scripts/deploy-config-to-vps.sh YOUR_VPS_IP && ssh root@YOUR_VPS_IP 'sudo systemctl status openclaw --no-pager'
```

### Quick health check
```bash
ssh root@YOUR_VPS_IP 'sudo systemctl is-active openclaw && echo "✅ Service is running" || echo "❌ Service is down"'
```

## Emergency Commands

### Force restart service
```bash
ssh root@YOUR_VPS_IP 'sudo systemctl stop openclaw && sleep 2 && sudo systemctl start openclaw'
```

### View error logs only
```bash
ssh root@YOUR_VPS_IP 'sudo journalctl -u openclaw -p err -n 50'
```

### Check disk space
```bash
ssh root@YOUR_VPS_IP 'df -h | grep -E "Filesystem|/$"'
```

### Check memory usage
```bash
ssh root@YOUR_VPS_IP 'free -h'
```

## Pre-Deployment Checklist

- [ ] Local config files exist and are valid
- [ ] SSH key is configured (`~/.ssh/id_ed25519`)
- [ ] VPS is accessible via SSH
- [ ] OpenClaw service exists on VPS
- [ ] Current configuration is backed up (optional)
- [ ] .env file contains valid API keys

## Post-Deployment Checklist

- [ ] Service is running (`systemctl status openclaw`)
- [ ] No errors in logs (`journalctl -u openclaw -n 50`)
- [ ] Files transferred successfully
- [ ] Permissions are correct (`.env` is 600)
- [ ] Bot responds to test messages
- [ ] Backup was created

## Need More Help?

See full documentation: `scripts/DEPLOY_CONFIG_README.md`

---

**Quick Start:** `./scripts/deploy-config-to-vps.sh YOUR_VPS_IP`
