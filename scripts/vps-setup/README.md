# VPS Security Hardening & OpenClaw Installation Scripts

This directory contains three bash scripts for securing and setting up a VPS (Virtual Private Server) for OpenClaw deployment.

## 📋 Overview

| Script | Purpose | Key Features |
|--------|---------|--------------|
| `01-ssh-hardening.sh` | SSH security configuration | Key-based auth, password disable, rollback on failure |
| `02-firewall-setup.sh` | UFW firewall configuration | Default deny, SSH access, restricted OpenClaw port |
| `03-install-openclaw.sh` | OpenClaw installation | Node.js 20 LTS, systemd service, health checks |

## 🚀 Quick Start

### Prerequisites

- A fresh Ubuntu/Debian VPS (DigitalOcean, Linode, AWS, etc.)
- SSH access to the VPS (initially with password or existing key)
- Your home/office IP address for firewall restrictions
- Local machine with bash, ssh, and ssh-copy-id installed

### Step-by-Step Setup

```bash
# 1. SSH Hardening (run from your local machine)
./01-ssh-hardening.sh <DROPLET_IP> [SSH_USER]

# Example:
./01-ssh-hardening.sh 192.168.1.100
./01-ssh-hardening.sh 192.168.1.100 ubuntu

# 2. Firewall Setup (run from your local machine)
./02-firewall-setup.sh <HOME_IP> <DROPLET_IP> [SSH_USER]

# Example:
./02-firewall-setup.sh 203.0.113.50 192.168.1.100
./02-firewall-setup.sh 203.0.113.50 192.168.1.100 ubuntu

# 3. OpenClaw Installation (run from your local machine)
./03-install-openclaw.sh <DROPLET_IP> [SSH_USER]

# Example:
./03-install-openclaw.sh 192.168.1.100
./03-install-openclaw.sh 192.168.1.100 ubuntu
```

## 📖 Detailed Script Documentation

### 01-ssh-hardening.sh

**Purpose:** Secures SSH access by implementing key-based authentication and disabling password logins.

**Usage:**
```bash
./01-ssh-hardening.sh <droplet_ip> [ssh_user]
```

**Parameters:**
- `droplet_ip` (required): IP address of your VPS
- `ssh_user` (optional): SSH username, defaults to `root`

**What it does:**
1. ✅ Checks for existing SSH key (`~/.ssh/id_ed25519`)
2. ✅ Generates new ED25519 key if needed
3. ✅ Copies SSH key to the VPS
4. ✅ Backs up current `sshd_config`
5. ✅ Applies secure SSH configuration:
   - Disables password authentication
   - Restricts root login to key-based only
   - Sets max auth tries to 3
   - Disables X11 forwarding
   - Enables verbose logging
6. ✅ Tests configuration before committing
7. ✅ Automatically rolls back on failure

**Security Settings Applied:**
```
PasswordAuthentication no
PermitRootLogin prohibit-password
PubkeyAuthentication yes
MaxAuthTries 3
X11Forwarding no
```

**Exit Codes:**
- `0`: Success
- `1`: Invalid parameters
- `2`: SSH key generation failed
- `3`: SSH key copy failed
- `4`: SSH configuration failed
- `5`: Connection test failed

**Idempotency:** Safe to run multiple times. Skips key generation and copying if already configured.

---

### 02-firewall-setup.sh

**Purpose:** Configures UFW (Uncomplicated Firewall) with secure defaults and custom access rules.

**Usage:**
```bash
# Local execution (on the VPS itself)
./02-firewall-setup.sh <home_ip>

# Remote execution (from your local machine)
./02-firewall-setup.sh <home_ip> <droplet_ip> [ssh_user]
```

**Parameters:**
- `home_ip` (required): Your home/office IP address for restricted access
- `droplet_ip` (optional): VPS IP address for remote execution
- `ssh_user` (optional): SSH username, defaults to `root`

**What it does:**
1. ✅ Installs UFW if not present
2. ✅ Backs up existing firewall rules
3. ✅ Resets UFW to clean state
4. ✅ Sets default policies:
   - Deny all incoming traffic
   - Allow all outgoing traffic
5. ✅ Adds firewall rules:
   - Port 22 (SSH): Open to all IPs
   - Port 18789 (OpenClaw): Restricted to your IP only
   - ICMP (Ping): Allowed
6. ✅ Enables UFW
7. ✅ Verifies SSH still works after enabling

**Firewall Rules:**
```
Default: Deny incoming, Allow outgoing
Port 22 (SSH): Allow from anywhere
Port 18789 (OpenClaw): Allow from <home_ip> only
ICMP: Allow (ping)
```

**Exit Codes:**
- `0`: Success
- `1`: Invalid parameters
- `2`: UFW not installed
- `3`: Firewall configuration failed
- `4`: Remote execution failed

**Idempotency:** Safe to run multiple times. Resets and reconfigures firewall each time.

**Managing UFW:**
```bash
# Check status
sudo ufw status verbose

# Show numbered rules
sudo ufw status numbered

# Delete a rule
sudo ufw delete [number]

# Add IP to whitelist
sudo ufw allow from [ip] to any port 18789

# Disable/Enable
sudo ufw disable
sudo ufw enable
```

---

### 03-install-openclaw.sh

**Purpose:** Installs OpenClaw with Node.js 20 LTS and configures it as a systemd service.

**Usage:**
```bash
# Local installation (on the VPS itself)
./03-install-openclaw.sh

# Remote installation (from your local machine)
./03-install-openclaw.sh <droplet_ip> [ssh_user]
```

**Parameters:**
- `droplet_ip` (optional): VPS IP address for remote installation
- `ssh_user` (optional): SSH username, defaults to `root`

**What it does:**
1. ✅ Updates system packages
2. ✅ Installs Node.js 20 LTS via NodeSource
3. ✅ Installs OpenClaw globally via npm
4. ✅ Creates directory structure:
   ```
   ~/.openclaw/
   ├── logs/
   ├── config/
   ├── data/
   └── backups/
   ```
5. ✅ Creates systemd service file
6. ✅ Enables service for automatic startup
7. ✅ Starts the service
8. ✅ Verifies installation with health check

**Service Configuration:**
- **Service Name:** `openclaw`
- **Port:** `18789`
- **Working Directory:** `~/.openclaw`
- **Auto-restart:** Enabled
- **Logs:** `~/.openclaw/logs/`

**Exit Codes:**
- `0`: Success
- `1`: Invalid parameters
- `2`: System update failed
- `3`: Node.js installation failed
- `4`: OpenClaw installation failed
- `5`: Service configuration failed
- `6`: Health check failed

**Idempotency:** Safe to run multiple times. Updates packages and reinstalls OpenClaw if already present.

**Service Management:**
```bash
# Check status
sudo systemctl status openclaw

# Start/Stop/Restart
sudo systemctl start openclaw
sudo systemctl stop openclaw
sudo systemctl restart openclaw

# Enable/Disable auto-start
sudo systemctl enable openclaw
sudo systemctl disable openclaw

# View logs
sudo journalctl -u openclaw -f
tail -f ~/.openclaw/logs/openclaw.log
tail -f ~/.openclaw/logs/openclaw-error.log
```

---

## 🔒 Security Best Practices

### SSH Security
- ✅ Use ED25519 keys (more secure than RSA)
- ✅ Disable password authentication
- ✅ Limit authentication attempts
- ✅ Keep backups of SSH configurations
- ✅ Test connections before committing changes

### Firewall Security
- ✅ Default deny incoming traffic
- ✅ Whitelist only necessary ports
- ✅ Restrict sensitive services to specific IPs
- ✅ Keep SSH accessible to avoid lockouts
- ✅ Enable logging for audit trails

### Application Security
- ✅ Run services as non-root users
- ✅ Use systemd security features
- ✅ Enable automatic restarts
- ✅ Centralize logging
- ✅ Regular updates and patches

---

## 🛠️ Troubleshooting

### SSH Issues

**Problem:** Can't connect after hardening
```bash
# Check if SSH service is running
ssh -v user@droplet_ip

# Access via console (DigitalOcean, AWS, etc.) and check:
sudo systemctl status sshd
sudo journalctl -u sshd -n 50

# Restore backup if needed:
sudo cp /etc/ssh/sshd_config.backup.* /etc/ssh/sshd_config
sudo systemctl restart sshd
```

**Problem:** Permission denied (publickey)
```bash
# Check if key is loaded
ssh-add -l

# Add key to agent
ssh-add ~/.ssh/id_ed25519

# Verify key on server
ssh user@droplet_ip "cat ~/.ssh/authorized_keys"
```

### Firewall Issues

**Problem:** Locked out after enabling firewall
```bash
# Access via console and check UFW status
sudo ufw status verbose

# Temporarily disable UFW
sudo ufw disable

# Re-enable SSH
sudo ufw allow 22/tcp
sudo ufw enable

# Check if SSH port is correct
sudo netstat -tlnp | grep sshd
```

**Problem:** Can't access OpenClaw
```bash
# Check if port 18789 is allowed for your IP
sudo ufw status numbered

# Add your current IP
sudo ufw allow from $(curl -s ifconfig.me) to any port 18789

# Check if service is listening
sudo netstat -tlnp | grep 18789
```

### OpenClaw Issues

**Problem:** Service won't start
```bash
# Check service status
sudo systemctl status openclaw

# View detailed logs
sudo journalctl -u openclaw -n 100 --no-pager

# Check if port is in use
sudo lsof -i :18789

# Manually test OpenClaw
openclaw start
```

**Problem:** Health check fails
```bash
# Test locally
curl http://localhost:18789/health

# Check if service is running
ps aux | grep openclaw

# View application logs
tail -f ~/.openclaw/logs/openclaw.log
tail -f ~/.openclaw/logs/openclaw-error.log
```

**Problem:** Node.js version issues
```bash
# Check Node.js version
node -v

# Should be v20.x.x or higher
# If not, reinstall Node.js:
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

---

## 📝 Logging

All scripts create detailed log files in `/tmp/`:

```bash
# SSH Hardening logs
/tmp/ssh-hardening-YYYYMMDD_HHMMSS.log

# Firewall Setup logs
/tmp/firewall-setup-YYYYMMDD_HHMMSS.log

# OpenClaw Installation logs
/tmp/openclaw-install-YYYYMMDD_HHMMSS.log
```

View logs:
```bash
# Find recent logs
ls -lt /tmp/*-setup-*.log /tmp/*-hardening-*.log /tmp/*-install-*.log | head

# View a specific log
less /tmp/ssh-hardening-20260209_143022.log
```

---

## 🔄 Complete Setup Example

Here's a complete example of setting up a fresh VPS:

```bash
# Variables
DROPLET_IP="192.168.1.100"
HOME_IP="203.0.113.50"
SSH_USER="root"

# Step 1: Harden SSH
./01-ssh-hardening.sh $DROPLET_IP $SSH_USER

# Step 2: Configure Firewall
./02-firewall-setup.sh $HOME_IP $DROPLET_IP $SSH_USER

# Step 3: Install OpenClaw
./03-install-openclaw.sh $DROPLET_IP $SSH_USER

# Step 4: Verify Installation
ssh -i ~/.ssh/id_ed25519 $SSH_USER@$DROPLET_IP "sudo systemctl status openclaw"

# Step 5: Test OpenClaw (from your home IP)
curl http://$DROPLET_IP:18789/health
```

---

## 🎯 Features

### Error Handling
- ✅ Comprehensive error checking at each step
- ✅ Automatic rollback on failure
- ✅ Clear error messages with exit codes
- ✅ Detailed logging for troubleshooting

### Idempotency
- ✅ Safe to run multiple times
- ✅ Skips already-configured items
- ✅ Updates existing installations
- ✅ No duplicate configurations

### User Experience
- ✅ Color-coded output (success, warning, error)
- ✅ Progress indicators
- ✅ Summary reports after completion
- ✅ Helpful usage instructions
- ✅ Command examples in output

### Safety
- ✅ Backups before making changes
- ✅ Configuration testing before committing
- ✅ Connection verification after changes
- ✅ Rollback mechanisms
- ✅ Non-destructive operations

---

## 📚 Additional Resources

### SSH
- [OpenSSH Documentation](https://www.openssh.com/manual.html)
- [SSH Key Types Comparison](https://security.stackexchange.com/questions/5096/rsa-vs-dsa-for-ssh-authentication-keys)

### UFW
- [UFW Documentation](https://help.ubuntu.com/community/UFW)
- [UFW Essentials](https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands)

### Node.js
- [Node.js Official Site](https://nodejs.org/)
- [NodeSource Distributions](https://github.com/nodesource/distributions)

### Systemd
- [Systemd Service Documentation](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
- [Systemd Unit Files](https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files)

---

## 🤝 Contributing

If you find issues or have improvements:

1. Test thoroughly on a fresh VPS
2. Ensure idempotency is maintained
3. Add appropriate error handling
4. Update documentation
5. Include examples

---

## ⚠️ Important Notes

1. **Backup First:** Always backup your VPS before running these scripts
2. **Test Environment:** Test on a non-production VPS first
3. **IP Addresses:** Double-check IP addresses before running
4. **Console Access:** Ensure you have console access to your VPS in case of lockout
5. **Firewall Rules:** Adjust port 18789 restrictions based on your needs
6. **SSH Keys:** Keep your private keys secure and backed up

---

## 📄 License

These scripts are provided as-is for the LiNKbot project. Use at your own risk.

---

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review the log files in `/tmp/`
3. Verify your parameters (IP addresses, usernames)
4. Ensure you have console access to your VPS
5. Test each script individually

---

**Last Updated:** February 9, 2026
