# VPS Setup Quick Start Guide

## 🎯 One-Command Setup

```bash
# Set your variables
export DROPLET_IP="192.168.1.100"
export HOME_IP="203.0.113.50"
export SSH_USER="root"

# Run all three scripts in sequence
./01-ssh-hardening.sh $DROPLET_IP $SSH_USER && \
./02-firewall-setup.sh $HOME_IP $DROPLET_IP $SSH_USER && \
./03-install-openclaw.sh $DROPLET_IP $SSH_USER
```

## 📋 Prerequisites Checklist

- [ ] Fresh Ubuntu/Debian VPS provisioned
- [ ] VPS IP address noted
- [ ] Your home/office IP address known (run `curl ifconfig.me`)
- [ ] Initial SSH access working
- [ ] Scripts downloaded and executable (`chmod +x *.sh`)

## 🚀 Step-by-Step (5 Minutes)

### 1. Get Your Home IP
```bash
curl ifconfig.me
# Example output: 203.0.113.50
```

### 2. SSH Hardening (1 min)
```bash
./01-ssh-hardening.sh 192.168.1.100 root
```
**What happens:** SSH key created/copied, password auth disabled, config secured

### 3. Firewall Setup (1 min)
```bash
./02-firewall-setup.sh 203.0.113.50 192.168.1.100 root
```
**What happens:** UFW installed, SSH open to all, port 18789 restricted to your IP

### 4. OpenClaw Installation (3 min)
```bash
./03-install-openclaw.sh 192.168.1.100 root
```
**What happens:** Node.js 20 installed, OpenClaw installed, systemd service created

## ✅ Verification

```bash
# Test SSH connection
ssh -i ~/.ssh/id_ed25519 root@192.168.1.100

# Check OpenClaw service
ssh -i ~/.ssh/id_ed25519 root@192.168.1.100 "sudo systemctl status openclaw"

# Test OpenClaw endpoint (from your home IP)
curl http://192.168.1.100:18789/health
```

## 🔧 Common Adjustments

### Change OpenClaw Port
```bash
# On VPS
sudo systemctl stop openclaw
sudo nano /etc/systemd/system/openclaw.service
# Change Environment="PORT=18789" to desired port
sudo systemctl daemon-reload
sudo systemctl start openclaw

# Update firewall
sudo ufw delete allow from YOUR_IP to any port 18789
sudo ufw allow from YOUR_IP to any port NEW_PORT
```

### Add Another IP to Whitelist
```bash
ssh root@192.168.1.100
sudo ufw allow from 203.0.113.100 to any port 18789
sudo ufw status
```

### View Logs
```bash
# SSH to VPS
ssh -i ~/.ssh/id_ed25519 root@192.168.1.100

# OpenClaw service logs
sudo journalctl -u openclaw -f

# Application logs
tail -f ~/.openclaw/logs/openclaw.log
```

## 🆘 Emergency Recovery

### Locked Out of SSH
1. Access VPS console (DigitalOcean, AWS, etc.)
2. Restore SSH config:
   ```bash
   sudo cp /etc/ssh/sshd_config.backup.* /etc/ssh/sshd_config
   sudo systemctl restart sshd
   ```

### Firewall Blocking Everything
1. Access VPS console
2. Disable firewall:
   ```bash
   sudo ufw disable
   sudo ufw allow 22/tcp
   sudo ufw enable
   ```

### OpenClaw Won't Start
1. Check logs:
   ```bash
   sudo journalctl -u openclaw -n 50
   ```
2. Restart service:
   ```bash
   sudo systemctl restart openclaw
   ```
3. Check port conflicts:
   ```bash
   sudo lsof -i :18789
   ```

## 📊 Expected Output

### Script 1: SSH Hardening
```
✓ SSH key already exists
✓ SSH key copied successfully
✓ SSH connection test passed
✓ Backup created: /etc/ssh/sshd_config.backup.20260209_154500
✓ Configuration activated
✓ SSH daemon reloaded
✓ SSH hardening completed successfully
```

### Script 2: Firewall Setup
```
✓ UFW is installed
✓ Backup created at /etc/ufw/backup-20260209_154600
✓ UFW reset to defaults
✓ Default policies configured (deny incoming, allow outgoing)
✓ SSH rule added
✓ OpenClaw rule added (restricted to 203.0.113.50)
✓ UFW enabled successfully
```

### Script 3: OpenClaw Installation
```
✓ System requirements check passed
✓ System packages upgraded
✓ NodeSource repository added
✓ Node.js installed successfully
✓ Node.js v20.11.0 and npm 10.2.4 are ready
✓ Directory structure created
✓ OpenClaw installed successfully
✓ Service file created: /etc/systemd/system/openclaw.service
✓ Service enabled
✓ Service started
✓ OpenClaw service is running
✓ OpenClaw health check passed
```

## 🎓 Understanding the Scripts

### Security Layers Applied

1. **SSH Layer**
   - Key-based authentication only
   - No password logins
   - Limited auth attempts
   - Root login restricted

2. **Network Layer**
   - Default deny all incoming
   - SSH accessible from anywhere
   - OpenClaw restricted to your IP
   - Outgoing traffic allowed

3. **Application Layer**
   - Non-root service user
   - Systemd security features
   - Auto-restart on failure
   - Centralized logging

## 💡 Tips

- **Always test on a non-production VPS first**
- **Keep your SSH private key backed up securely**
- **Note your VPS console access URL before starting**
- **Scripts are idempotent - safe to re-run if needed**
- **Check logs in `/tmp/` if anything fails**

## 🔗 Next Steps

After setup completes:

1. Configure OpenClaw with your API keys
2. Set up monitoring/alerting
3. Configure backups
4. Set up SSL/TLS certificates
5. Configure domain name (optional)

## 📞 Need Help?

1. Check `README.md` for detailed documentation
2. Review logs in `/tmp/`
3. Check the Troubleshooting section in README.md
4. Verify your IP addresses are correct
5. Ensure you have VPS console access

---

**Setup Time:** ~5 minutes  
**Difficulty:** Easy  
**Requirements:** Basic command-line knowledge
