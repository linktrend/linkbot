# VPS Security Hardening Scripts - Index

## 🚀 Quick Navigation

### For First-Time Users
👉 **Start here**: [`QUICK_START.md`](QUICK_START.md) - 5-minute setup guide

### For Detailed Information
📖 **Read this**: [`README.md`](README.md) - Comprehensive documentation

### For Package Overview
📦 **Check this**: [`PACKAGE_SUMMARY.md`](PACKAGE_SUMMARY.md) - Complete package details

---

## 📁 File Structure

```
scripts/vps-setup/
│
├── 🔧 EXECUTABLE SCRIPTS
│   ├── 01-ssh-hardening.sh       (387 lines) - SSH security configuration
│   ├── 02-firewall-setup.sh      (427 lines) - UFW firewall setup
│   ├── 03-install-openclaw.sh    (539 lines) - OpenClaw installation
│   └── test-scripts.sh           (388 lines) - Test suite
│
├── 📚 DOCUMENTATION
│   ├── INDEX.md                  (this file) - Navigation guide
│   ├── QUICK_START.md            (224 lines) - Quick setup guide
│   ├── README.md                 (514 lines) - Full documentation
│   └── PACKAGE_SUMMARY.md        (403 lines) - Package overview
│
└── ⚙️ CONFIGURATION
    └── .gitignore                - Git ignore rules
```

---

## 🎯 Choose Your Path

### Path 1: I want to set up a VPS quickly
1. Read [`QUICK_START.md`](QUICK_START.md)
2. Run the three scripts in order
3. Done in 5 minutes!

### Path 2: I want to understand everything first
1. Read [`README.md`](README.md) - Full documentation
2. Read [`PACKAGE_SUMMARY.md`](PACKAGE_SUMMARY.md) - Package details
3. Run [`test-scripts.sh`](test-scripts.sh) - Validate scripts
4. Run the three setup scripts

### Path 3: I want to customize the scripts
1. Read [`README.md`](README.md) - See "Customization Points"
2. Edit the scripts as needed
3. Run [`test-scripts.sh`](test-scripts.sh) - Validate changes
4. Run your customized scripts

---

## 📋 Script Execution Order

```
┌─────────────────────────────────────────────────────────────┐
│                    VPS Setup Workflow                       │
└─────────────────────────────────────────────────────────────┘

  Step 1: SSH Hardening
  ┌───────────────────────────────────────┐
  │  ./01-ssh-hardening.sh <droplet_ip>   │
  │                                       │
  │  ✓ Generates SSH key                  │
  │  ✓ Copies key to VPS                  │
  │  ✓ Disables password auth             │
  │  ✓ Secures SSH config                 │
  └───────────────────────────────────────┘
                    ↓
  Step 2: Firewall Setup
  ┌───────────────────────────────────────┐
  │  ./02-firewall-setup.sh <home_ip>     │
  │                         <droplet_ip>  │
  │                                       │
  │  ✓ Installs UFW                       │
  │  ✓ Sets default deny                  │
  │  ✓ Opens SSH (port 22)                │
  │  ✓ Restricts OpenClaw (port 18789)    │
  └───────────────────────────────────────┘
                    ↓
  Step 3: OpenClaw Installation
  ┌───────────────────────────────────────┐
  │  ./03-install-openclaw.sh             │
  │                       <droplet_ip>    │
  │                                       │
  │  ✓ Installs Node.js 20 LTS            │
  │  ✓ Installs OpenClaw                  │
  │  ✓ Creates systemd service            │
  │  ✓ Starts and enables service         │
  └───────────────────────────────────────┘
                    ↓
              ✅ Complete!
```

---

## 🔍 Quick Reference

### Script 1: SSH Hardening

**Command:**
```bash
./01-ssh-hardening.sh 192.168.1.100 [root]
```

**What it does:**
- Generates ED25519 SSH key
- Copies key to VPS
- Disables password authentication
- Secures sshd_config

**Time:** ~1 minute

---

### Script 2: Firewall Setup

**Command:**
```bash
./02-firewall-setup.sh 203.0.113.50 192.168.1.100 [root]
```

**What it does:**
- Installs and configures UFW
- Sets default deny incoming
- Opens SSH (port 22) to all
- Restricts OpenClaw (port 18789) to your IP

**Time:** ~1 minute

---

### Script 3: OpenClaw Installation

**Command:**
```bash
./03-install-openclaw.sh 192.168.1.100 [root]
```

**What it does:**
- Updates system packages
- Installs Node.js 20 LTS
- Installs OpenClaw globally
- Creates systemd service
- Starts and enables service

**Time:** ~3 minutes

---

## 🧪 Testing

**Run the test suite:**
```bash
./test-scripts.sh
```

**Tests performed:**
- ✅ Syntax validation
- ✅ Executable permissions
- ✅ Usage output
- ✅ Parameter validation
- ✅ Documentation completeness
- ✅ File structure

---

## 🆘 Troubleshooting

### Quick Fixes

**Problem: Can't connect via SSH after hardening**
```bash
# Access VPS console and restore backup
sudo cp /etc/ssh/sshd_config.backup.* /etc/ssh/sshd_config
sudo systemctl restart sshd
```

**Problem: Locked out by firewall**
```bash
# Access VPS console and disable firewall
sudo ufw disable
sudo ufw allow 22/tcp
sudo ufw enable
```

**Problem: OpenClaw won't start**
```bash
# Check service status
sudo systemctl status openclaw
sudo journalctl -u openclaw -n 50
```

**Full troubleshooting guide:** See [`README.md`](README.md) → Troubleshooting section

---

## 📊 Package Statistics

| Metric | Value |
|--------|-------|
| Total Scripts | 4 (3 setup + 1 test) |
| Total Documentation | 4 files |
| Total Lines of Code | 1,741 lines |
| Total Documentation | 1,141 lines |
| Total Package Size | ~75 KB |
| Estimated Setup Time | 5-10 minutes |
| Platforms Supported | Ubuntu 20.04+, Debian 10+ |

---

## 🎓 Learning Resources

### Understanding SSH Security
- Why ED25519 keys? (More secure than RSA)
- Why disable password auth? (Prevents brute force)
- What is key-based authentication?

### Understanding Firewalls
- What is UFW? (Uncomplicated Firewall)
- Why default deny? (Security by default)
- What are firewall rules?

### Understanding Systemd
- What is a systemd service?
- How does auto-restart work?
- Where are logs stored?

**Learn more:** [`README.md`](README.md) → Additional Resources

---

## ✅ Pre-Flight Checklist

Before running the scripts, ensure you have:

- [ ] Fresh Ubuntu/Debian VPS
- [ ] VPS IP address
- [ ] Your home/office IP (`curl ifconfig.me`)
- [ ] Initial SSH access working
- [ ] Scripts downloaded and executable
- [ ] VPS console access (backup)
- [ ] 10 minutes of time

---

## 🎯 Success Criteria

After running all scripts, you should have:

- ✅ SSH key-based authentication working
- ✅ Password authentication disabled
- ✅ UFW firewall active and configured
- ✅ Port 22 (SSH) accessible from anywhere
- ✅ Port 18789 (OpenClaw) restricted to your IP
- ✅ OpenClaw service running
- ✅ Systemd service enabled for auto-start
- ✅ Health check endpoint responding

**Verify with:**
```bash
# Test SSH
ssh -i ~/.ssh/id_ed25519 root@192.168.1.100

# Check OpenClaw
curl http://192.168.1.100:18789/health
```

---

## 🔗 Related Documentation

- **Main Project**: [`../../README.md`](../../README.md)
- **Deployment Guide**: [`../../docs/deployment/OPENCLAW_DEPLOYMENT_GUIDE.md`](../../docs/deployment/OPENCLAW_DEPLOYMENT_GUIDE.md)
- **VPS Deployment**: [`../../docs/guides/VPS_DEPLOYMENT.md`](../../docs/guides/VPS_DEPLOYMENT.md)

---

## 📝 Version Information

- **Package Version**: 1.0.0
- **Last Updated**: February 9, 2026
- **Compatibility**: Ubuntu 20.04+, Debian 10+
- **Node.js Version**: 20 LTS
- **OpenClaw Version**: Latest (via npm)

---

## 🤝 Contributing

Found an issue or want to improve the scripts?

1. Test on a fresh VPS
2. Ensure idempotency
3. Add error handling
4. Update documentation
5. Run test suite

---

## 📞 Getting Help

1. **Quick issues**: Check [`QUICK_START.md`](QUICK_START.md)
2. **Detailed issues**: Check [`README.md`](README.md) → Troubleshooting
3. **Understanding**: Read [`PACKAGE_SUMMARY.md`](PACKAGE_SUMMARY.md)
4. **Logs**: Check `/tmp/*-setup-*.log` files

---

## 🎉 Ready to Start?

👉 **Go to [`QUICK_START.md`](QUICK_START.md) and begin your VPS setup!**

---

*This package is part of the LiNKbot project.*
