# OpenClaw Quick Reference Guide

**Version:** 1.0  
**Date:** February 7, 2026  
**Purpose:** Fast lookup for common commands and tasks

---

## 🚀 Quick Access

### Essential URLs
```
DigitalOcean Dashboard:     https://cloud.digitalocean.com/
Droplets Page:              https://cloud.digitalocean.com/droplets
OpenClaw Marketplace:       https://marketplace.digitalocean.com/apps/moltbot
Anthropic Console:          https://console.anthropic.com/
OpenClaw Documentation:     https://docs.openclaw.ai/
```

### SSH Access
```bash
# Connect to your droplet
ssh root@YOUR_DROPLET_IP

# Switch to openclaw user
su openclaw

# Go to home directory
cd
```

### Dashboard Access
```bash
# Open dashboard (generates URL with token)
openclaw dashboard

# Dashboard URL format
http://YOUR_DROPLET_IP:18789/?token=YOUR_GATEWAY_TOKEN
```

---

## 💻 Common Commands

### OpenClaw Core Commands

#### Health & Status
```bash
# Check gateway health
openclaw gateway health --url ws://127.0.0.1:18789

# Check version
openclaw --version

# View help
openclaw --help
```

#### Skills Management
```bash
# List all available skills
openclaw skills

# Search for specific skill
openclaw skills | grep calendar

# Install a skill
npx clawhub install <skill_name>

# Example: Install Google Calendar
npx clawhub install google-calendar

# Refresh skill registry
openclaw skills refresh

# List installed skills
openclaw skills list
```

#### Channel Management
```bash
# Connect to WhatsApp
openclaw channels login --channel whatsapp

# Connect to Telegram
openclaw channels login --channel telegram

# Connect to Discord
openclaw channels login --channel discord

# List connected channels
openclaw channels list

# Disconnect a channel
openclaw channels logout --channel whatsapp
```

#### User Interface Access
```bash
# Open text user interface (TUI)
/opt/openclaw-tui.sh

# Alternative path (older versions)
/opt/clawdbot-tui.sh

# Open dashboard in browser
openclaw dashboard
```

### Docker Commands

#### Container Management
```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# View container logs
docker logs <container_id>

# Follow logs in real-time
docker logs -f <container_id>

# Restart a container
docker restart <container_id>

# Stop a container
docker stop <container_id>

# Start a container
docker start <container_id>

# Remove stopped container
docker rm <container_id>
```

#### Container Inspection
```bash
# Inspect container details
docker inspect <container_id>

# Get container IP address
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container_id>

# Execute command in container
docker exec -it <container_id> /bin/bash

# Check container resource usage
docker stats

# View container processes
docker top <container_id>
```

### System Commands

#### Resource Monitoring
```bash
# Check disk space
df -h

# Check memory usage
free -h

# Check CPU and memory (interactive)
htop
# Or if htop not installed:
top

# Check network connections
netstat -tuln

# Check listening ports
ss -tuln

# Monitor bandwidth usage
iftop
# Or:
nload
```

#### Process Management
```bash
# Find OpenClaw processes
ps aux | grep openclaw

# Kill process by PID
kill <PID>

# Force kill
kill -9 <PID>

# View all openclaw services
systemctl list-units | grep openclaw
```

#### Log Viewing
```bash
# View OpenClaw logs
journalctl -u openclaw -n 100

# Follow logs in real-time
journalctl -u openclaw -f

# View logs since yesterday
journalctl -u openclaw --since yesterday

# View logs with specific priority (errors only)
journalctl -u openclaw -p err

# Export logs to file
journalctl -u openclaw > openclaw_logs.txt
```

### Firewall & Security

#### Firewall Commands
```bash
# Check firewall status
sudo ufw status

# Check firewall status verbose
sudo ufw status verbose

# List firewall rules numbered
sudo ufw status numbered

# Allow specific port
sudo ufw allow 8080

# Deny specific port
sudo ufw deny 8080

# Delete rule by number
sudo ufw delete <number>

# Reload firewall
sudo ufw reload
```

#### fail2ban Status
```bash
# Check fail2ban status
sudo systemctl status fail2ban

# View banned IPs
sudo fail2ban-client status

# View banned IPs for specific jail
sudo fail2ban-client status sshd

# Unban IP
sudo fail2ban-client set sshd unbanip <IP_ADDRESS>

# View fail2ban logs
sudo tail -f /var/log/fail2ban.log
```

#### Security Checks
```bash
# List all users
cat /etc/passwd

# Check user permissions
id openclaw

# List sudo users
getent group sudo

# Check SSH configuration
sudo cat /etc/ssh/sshd_config | grep -v "^#"

# List active SSH sessions
who

# View last login attempts
last -n 20

# Check for failed login attempts
sudo grep "Failed password" /var/log/auth.log | tail -20
```

### Backup & Snapshots

#### Manual Backup Commands
```bash
# Create manual backup (via API - requires token)
curl -X POST \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/droplets/$DROPLET_ID/actions" \
  -d '{"type":"snapshot","name":"manual-backup-2026-02-07"}'

# List snapshots
doctl compute snapshot list

# Delete snapshot
doctl compute snapshot delete <SNAPSHOT_ID>
```

#### File-Level Backups
```bash
# Backup OpenClaw config
tar -czf openclaw-config-backup.tar.gz /home/openclaw/.config/openclaw

# Backup entire home directory
tar -czf openclaw-home-backup.tar.gz /home/openclaw

# Copy to local machine (run from your Mac)
scp root@YOUR_DROPLET_IP:/path/to/backup.tar.gz ~/Desktop/

# Restore from backup
tar -xzf openclaw-config-backup.tar.gz -C /
```

---

## 🔧 Troubleshooting

### Quick Diagnostics

#### All-In-One Status Check
```bash
# Create this as a script for quick diagnostics
cat > /usr/local/bin/openclaw-status.sh << 'EOF'
#!/bin/bash
echo "=== OpenClaw Status Check ==="
echo ""
echo "1. Docker Containers:"
docker ps
echo ""
echo "2. Gateway Health:"
openclaw gateway health --url ws://127.0.0.1:18789
echo ""
echo "3. Disk Space:"
df -h | grep -E '^Filesystem|/$'
echo ""
echo "4. Memory Usage:"
free -h
echo ""
echo "5. Recent Logs:"
journalctl -u openclaw -n 10 --no-pager
echo ""
echo "=== Status Check Complete ==="
EOF

chmod +x /usr/local/bin/openclaw-status.sh

# Run it
openclaw-status.sh
```

### Common Issues & Fixes

#### Issue: Dashboard Not Loading
```bash
# 1. Check if containers are running
docker ps

# 2. Check if port is listening
netstat -tuln | grep 18789

# 3. Check firewall
sudo ufw status | grep 18789

# 4. Restart OpenClaw
systemctl restart openclaw

# 5. Check logs for errors
journalctl -u openclaw -n 50

# 6. Generate fresh dashboard URL
openclaw dashboard
```

#### Issue: AI Not Responding
```bash
# 1. Check API key is set
echo $ANTHROPIC_API_KEY

# 2. If empty, set it
export ANTHROPIC_API_KEY="your_key_here"

# 3. Test API key manually
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-3-5-sonnet-20241022","max_tokens":100,"messages":[{"role":"user","content":"test"}]}'

# 4. Check OpenClaw logs for API errors
journalctl -u openclaw -n 50 | grep -i error

# 5. Restart OpenClaw
systemctl restart openclaw
```

#### Issue: High CPU/Memory Usage
```bash
# 1. Check resource usage by container
docker stats --no-stream

# 2. Check for runaway processes
htop

# 3. Check for scheduled jobs running
openclaw cron list

# 4. Review recent activity
openclaw history | tail -20

# 5. Restart if necessary
systemctl restart openclaw
```

#### Issue: Skill Not Working
```bash
# 1. Check if skill is installed
openclaw skills list | grep <skill_name>

# 2. Reinstall skill
npx clawhub uninstall <skill_name>
npx clawhub install <skill_name>

# 3. Check skill logs
journalctl -u openclaw -f
# Then try using the skill

# 4. Check skill requirements
cat ~/skills/<skill_name>/SKILL.md

# 5. Verify environment variables
env | grep -i <skill_name>
```

#### Issue: Cannot SSH
```bash
# From your Mac:

# 1. Check if droplet is powered on
doctl compute droplet list

# 2. Try verbose SSH for more info
ssh -v root@YOUR_DROPLET_IP

# 3. Check SSH key
ssh-add -l

# 4. Try with explicit key
ssh -i ~/.ssh/id_ed25519 root@YOUR_DROPLET_IP

# 5. Check from DigitalOcean console
# Go to Droplet → Access → Launch Console
```

---

## 📊 Monitoring & Maintenance

### Daily Checks (First Week)
```bash
# Quick daily check script
cat > ~/daily-check.sh << 'EOF'
#!/bin/bash
echo "OpenClaw Daily Check - $(date)"
echo "======================================"
echo "Gateway Status:"
openclaw gateway health --url ws://127.0.0.1:18789
echo ""
echo "Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}"
echo ""
echo "Disk Usage:"
df -h / | tail -1 | awk '{print $5 " used"}'
echo ""
echo "Memory Usage:"
free -h | grep Mem | awk '{print $3 "/" $2 " used"}'
echo ""
echo "Recent Errors:"
journalctl -u openclaw --since "24 hours ago" -p err --no-pager | wc -l
EOF

chmod +x ~/daily-check.sh
./daily-check.sh
```

### Weekly Checks
```bash
# Weekly maintenance script
cat > ~/weekly-check.sh << 'EOF'
#!/bin/bash
echo "OpenClaw Weekly Maintenance - $(date)"
echo "=========================================="

echo "1. Checking for updates..."
apt update
apt list --upgradable

echo ""
echo "2. Docker cleanup..."
docker system prune -f

echo ""
echo "3. Log rotation check..."
du -sh /var/log/

echo ""
echo "4. Backup verification..."
# Check last backup date in DO dashboard
echo "Check DigitalOcean dashboard for last backup date"

echo ""
echo "5. Cost monitoring reminder..."
echo "Check Anthropic dashboard for API usage"
EOF

chmod +x ~/weekly-check.sh
./weekly-check.sh
```

### Cost Monitoring Commands
```bash
# View DigitalOcean current usage (requires doctl)
doctl account get

# View bandwidth usage
doctl monitoring metrics --droplet-id $DROPLET_ID

# Check droplet cost
doctl compute droplet get $DROPLET_ID --format ID,Name,Size,Price

# Anthropic API usage - check via web:
# https://console.anthropic.com/settings/usage
```

---

## 🔐 Security Maintenance

### Regular Security Tasks

#### Monthly Security Check
```bash
# Create monthly security script
cat > ~/security-check.sh << 'EOF'
#!/bin/bash
echo "Security Check - $(date)"
echo "=============================="

echo "1. Failed login attempts (last 7 days):"
sudo grep "Failed password" /var/log/auth.log | wc -l

echo ""
echo "2. Banned IPs (fail2ban):"
sudo fail2ban-client status sshd

echo ""
echo "3. Listening ports:"
sudo ss -tuln | grep LISTEN

echo ""
echo "4. User accounts:"
cat /etc/passwd | grep -v nologin | grep -v false

echo ""
echo "5. Sudo users:"
getent group sudo

echo ""
echo "6. Last 10 logins:"
last -n 10

echo ""
echo "7. Gateway token check:"
echo "Current token: ${OPENCLAW_GATEWAY_TOKEN:0:10}..."
EOF

chmod +x ~/security-check.sh
./security-check.sh
```

#### Rotate Gateway Token
```bash
# Generate new token
NEW_TOKEN=$(openssl rand -hex 32)

# Update environment variable
export OPENCLAW_GATEWAY_TOKEN=$NEW_TOKEN

# Save to config
echo "export OPENCLAW_GATEWAY_TOKEN=$NEW_TOKEN" >> ~/.bashrc

# Restart OpenClaw
systemctl restart openclaw

# Get new dashboard URL
openclaw dashboard
```

#### Update System Packages
```bash
# Update package list
sudo apt update

# Show upgradable packages
apt list --upgradable

# Upgrade all packages (do during low usage time)
sudo apt upgrade -y

# Clean up old packages
sudo apt autoremove -y

# Reboot if kernel updated
sudo reboot
```

---

## 📝 Configuration Files

### Important File Locations

```bash
# OpenClaw configuration
/home/openclaw/.config/openclaw/

# Environment variables
/home/openclaw/.bashrc
/home/openclaw/.profile

# Docker compose files
/opt/openclaw/docker-compose.yml

# Systemd service
/etc/systemd/system/openclaw.service

# Nginx config (if used)
/etc/nginx/sites-available/openclaw

# Logs
/var/log/openclaw/
~/.openclaw/logs/

# Skills directory
/home/openclaw/skills/

# Gateway token storage
~/.openclaw/gateway/token
```

### Backup Configuration Files
```bash
# Create config backup
cat > ~/backup-config.sh << 'EOF'
#!/bin/bash
BACKUP_DIR=~/config-backups
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="openclaw-config-$DATE.tar.gz"

mkdir -p $BACKUP_DIR

tar -czf $BACKUP_DIR/$BACKUP_FILE \
  /home/openclaw/.config/openclaw \
  /home/openclaw/.bashrc \
  /home/openclaw/skills \
  /etc/systemd/system/openclaw.service

echo "Backup created: $BACKUP_DIR/$BACKUP_FILE"
ls -lh $BACKUP_DIR/$BACKUP_FILE
EOF

chmod +x ~/backup-config.sh
./backup-config.sh
```

---

## 🚨 Emergency Procedures

### If Something Goes Wrong

#### Emergency Stop
```bash
# Stop OpenClaw immediately
systemctl stop openclaw

# Stop all containers
docker stop $(docker ps -aq)

# Check what's still running
ps aux | grep openclaw
```

#### Emergency Restart
```bash
# Full restart sequence
systemctl stop openclaw
docker stop $(docker ps -aq)
docker system prune -f
systemctl start openclaw
sleep 10
openclaw gateway health --url ws://127.0.0.1:18789
```

#### Restore from Backup
```bash
# 1. From DigitalOcean dashboard:
#    Go to Droplet → Backups → Restore

# 2. Or restore config only:
tar -xzf openclaw-config-backup.tar.gz -C /
systemctl restart openclaw
```

#### Contact Support
```bash
# Gather diagnostic info for support
cat > ~/support-info.txt << 'EOF'
=== OpenClaw Support Information ===
Date: $(date)
Droplet IP: $(curl -s ifconfig.me)
OS Version: $(lsb_release -a)
OpenClaw Version: $(openclaw --version)
Docker Version: $(docker --version)
Gateway Health: $(openclaw gateway health --url ws://127.0.0.1:18789)

Recent Errors:
$(journalctl -u openclaw -n 20 -p err --no-pager)

Container Status:
$(docker ps -a)

Disk Usage:
$(df -h)

Memory Usage:
$(free -h)
EOF

cat ~/support-info.txt
```

---

## 📞 Support Resources

### Getting Help

**DigitalOcean Support**
- Ticket: https://cloud.digitalocean.com/support/tickets
- Community: https://digitalocean.com/community
- Docs: https://docs.digitalocean.com/

**OpenClaw Support**
- Docs: https://docs.openclaw.ai/
- GitHub: https://github.com/OpenClawAI/openclaw
- Tutorial: https://digitalocean.com/community/tutorials/how-to-run-openclaw

**Emergency Contacts**
- DigitalOcean Status: https://status.digitalocean.com/
- Anthropic Status: https://status.anthropic.com/

---

## 🎯 Pro Tips

### Productivity Shortcuts

```bash
# Add to ~/.bashrc for quick access
cat >> ~/.bashrc << 'EOF'

# OpenClaw aliases
alias oc='openclaw'
alias ocd='openclaw dashboard'
alias och='openclaw gateway health --url ws://127.0.0.1:18789'
alias ocs='openclaw skills'
alias ocl='journalctl -u openclaw -f'
alias ocp='docker ps'
alias ocr='systemctl restart openclaw'

# Quick status check
alias ocstat='echo "=== OpenClaw Quick Status ===" && \
  echo "Gateway:" && openclaw gateway health --url ws://127.0.0.1:18789 && \
  echo "" && echo "Containers:" && docker ps --format "{{.Names}}: {{.Status}}"'

# Cost reminder
alias cost='echo "Remember to check:" && \
  echo "1. DigitalOcean: https://cloud.digitalocean.com/billing" && \
  echo "2. Anthropic: https://console.anthropic.com/settings/usage"'
EOF

source ~/.bashrc
```

### Useful One-Liners

```bash
# Get Droplet IP quickly
curl -s ifconfig.me

# Check if OpenClaw is responding
curl -s http://localhost:18789/health

# Count today's interactions
journalctl -u openclaw --since today | grep -c "interaction"

# Find largest log files
du -sh /var/log/* | sort -rh | head -5

# Check API usage pattern
journalctl -u openclaw --since "7 days ago" | grep -i "anthropic" | wc -l

# Automated health email (requires mailutils)
openclaw-status.sh | mail -s "OpenClaw Daily Status" your@email.com
```

---

## 🗑️ Decommissioning

### If You Need to Destroy Droplet

```bash
# 1. Create final backup
./backup-config.sh

# 2. Download backup to local machine (run from Mac)
scp root@YOUR_DROPLET_IP:~/config-backups/*.tar.gz ~/Desktop/

# 3. Create snapshot (in DO dashboard)
# Go to Droplet → Snapshots → Take Snapshot → Wait for completion

# 4. Destroy droplet (in DO dashboard)
# Go to Droplet → Destroy → Type droplet name → Confirm

# Or via CLI:
doctl compute droplet delete $DROPLET_ID
```

---

## 📚 Additional Resources

### Cheat Sheets
- **OpenClaw CLI:** https://docs.openclaw.ai/cli/
- **Docker:** https://docs.docker.com/get-started/docker_cheatsheet.pdf
- **Linux Commands:** https://cheatography.com/davechild/cheat-sheets/linux-command-line/

### Video Tutorials
- **OpenClaw Deployment:** https://youtube.com/watch?v=n2MrUtIT1m4

### Community
- **DigitalOcean Community:** https://digitalocean.com/community
- **OpenClaw Discussions:** Check GitHub repository

---

**Document Version:** 1.0  
**Last Updated:** February 7, 2026  
**Status:** Reference Ready

**Bookmark This Document!** 🔖
