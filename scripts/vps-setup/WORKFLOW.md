# VPS Setup Workflow Diagram

## 🔄 Complete Setup Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         INITIAL STATE                                   │
│  • Fresh VPS with password SSH access                                   │
│  • No firewall configured                                               │
│  • All ports open to internet                                           │
│  • No OpenClaw installed                                                │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    STEP 1: SSH HARDENING                                │
│                  ./01-ssh-hardening.sh                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. Check Prerequisites                                                 │
│     └─→ Verify ssh, ssh-keygen, ssh-copy-id available                  │
│                                                                         │
│  2. SSH Key Management                                                  │
│     ├─→ Check for existing key (~/.ssh/id_ed25519)                     │
│     └─→ Generate new ED25519 key if needed                             │
│                                                                         │
│  3. Copy Key to VPS                                                     │
│     ├─→ Use ssh-copy-id to transfer public key                         │
│     └─→ Test key-based connection                                      │
│                                                                         │
│  4. Backup Current Config                                               │
│     └─→ Create timestamped backup of sshd_config                       │
│                                                                         │
│  5. Apply Secure Configuration                                          │
│     ├─→ PasswordAuthentication no                                      │
│     ├─→ PermitRootLogin prohibit-password                              │
│     ├─→ PubkeyAuthentication yes                                       │
│     ├─→ MaxAuthTries 3                                                 │
│     └─→ X11Forwarding no                                               │
│                                                                         │
│  6. Test & Validate                                                     │
│     ├─→ Test sshd configuration syntax                                 │
│     ├─→ Reload SSH daemon                                              │
│     ├─→ Test connection with new config                                │
│     └─→ Rollback if test fails                                         │
│                                                                         │
│  ✅ Result: Key-based SSH only, passwords disabled                      │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    STEP 2: FIREWALL SETUP                               │
│                  ./02-firewall-setup.sh                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. Validate Parameters                                                 │
│     ├─→ Check home IP format                                           │
│     └─→ Check droplet IP format                                        │
│                                                                         │
│  2. Install UFW (if needed)                                             │
│     └─→ apt-get install ufw                                            │
│                                                                         │
│  3. Backup Existing Rules                                               │
│     └─→ Create timestamped backup directory                            │
│                                                                         │
│  4. Reset UFW to Clean State                                            │
│     ├─→ Disable UFW                                                    │
│     └─→ Reset all rules                                                │
│                                                                         │
│  5. Configure Default Policies                                          │
│     ├─→ Default: DENY incoming                                         │
│     ├─→ Default: ALLOW outgoing                                        │
│     └─→ Default: DENY routed                                           │
│                                                                         │
│  6. Add Firewall Rules                                                  │
│     ├─→ Allow port 22 (SSH) from anywhere                              │
│     ├─→ Allow port 18789 from <home_ip> only                           │
│     └─→ Allow ICMP (ping)                                              │
│                                                                         │
│  7. Enable & Verify                                                     │
│     ├─→ Enable UFW                                                     │
│     ├─→ Verify SSH still works                                         │
│     └─→ Display status                                                 │
│                                                                         │
│  ✅ Result: Firewall active, ports restricted                           │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                  STEP 3: OPENCLAW INSTALLATION                          │
│                ./03-install-openclaw.sh                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. Check System Requirements                                           │
│     ├─→ Verify Linux OS                                                │
│     └─→ Check sudo access                                              │
│                                                                         │
│  2. Update System                                                       │
│     ├─→ apt-get update                                                 │
│     ├─→ apt-get upgrade                                                │
│     └─→ Install essential tools                                        │
│                                                                         │
│  3. Install Node.js 20 LTS                                              │
│     ├─→ Add NodeSource repository                                      │
│     ├─→ Install nodejs package                                         │
│     └─→ Verify node and npm versions                                   │
│                                                                         │
│  4. Create Directory Structure                                          │
│     ├─→ ~/.openclaw/                                                   │
│     ├─→ ~/.openclaw/logs/                                              │
│     ├─→ ~/.openclaw/config/                                            │
│     ├─→ ~/.openclaw/data/                                              │
│     └─→ ~/.openclaw/backups/                                           │
│                                                                         │
│  5. Install OpenClaw                                                    │
│     ├─→ npm install -g openclaw                                        │
│     └─→ Verify openclaw command available                              │
│                                                                         │
│  6. Create Systemd Service                                              │
│     ├─→ Generate service file                                          │
│     ├─→ Configure auto-restart                                         │
│     ├─→ Set security options                                           │
│     └─→ Reload systemd daemon                                          │
│                                                                         │
│  7. Enable & Start Service                                              │
│     ├─→ systemctl enable openclaw                                      │
│     ├─→ systemctl start openclaw                                       │
│     └─→ Wait for service to stabilize                                  │
│                                                                         │
│  8. Verify Installation                                                 │
│     ├─→ Check service status                                           │
│     ├─→ Test health endpoint                                           │
│     └─→ Verify logs being written                                      │
│                                                                         │
│  ✅ Result: OpenClaw running as systemd service                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         FINAL STATE                                     │
│  ✅ SSH: Key-based authentication only                                  │
│  ✅ Firewall: Active with restrictive rules                             │
│  ✅ Port 22: Open to all (SSH)                                          │
│  ✅ Port 18789: Restricted to your IP (OpenClaw)                        │
│  ✅ OpenClaw: Running and auto-starting on boot                         │
│  ✅ Logs: Centralized in ~/.openclaw/logs/                              │
│  ✅ Service: Managed by systemd with auto-restart                       │
└─────────────────────────────────────────────────────────────────────────┘
```

## 🔐 Security Layers Applied

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SECURITY LAYERS                                 │
└─────────────────────────────────────────────────────────────────────────┘

Layer 1: Network Firewall (UFW)
├─→ Default deny incoming
├─→ Default allow outgoing
├─→ Port 22: SSH access from anywhere
└─→ Port 18789: OpenClaw access from your IP only

Layer 2: SSH Authentication
├─→ Key-based authentication required
├─→ Password authentication disabled
├─→ Root login restricted to keys only
└─→ Maximum 3 authentication attempts

Layer 3: Application Security
├─→ Non-root service execution
├─→ Systemd security features
├─→ Read-only system protection
└─→ Private temporary directories

Layer 4: Monitoring & Logging
├─→ Centralized application logs
├─→ Systemd journal integration
├─→ Error tracking
└─→ Service status monitoring
```

## 🔄 Error Handling Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      ERROR HANDLING FLOW                                │
└─────────────────────────────────────────────────────────────────────────┘

For Each Script:
    │
    ├─→ Validate Input Parameters
    │   ├─→ Valid? Continue
    │   └─→ Invalid? Show usage & exit
    │
    ├─→ Execute Main Operation
    │   ├─→ Success? Continue
    │   └─→ Failure? Log error & check rollback
    │
    ├─→ Test Configuration
    │   ├─→ Test passed? Commit changes
    │   └─→ Test failed? Rollback & exit
    │
    └─→ Verify Final State
        ├─→ Verified? Show success summary
        └─→ Failed? Show error & recovery steps

Rollback Mechanisms:
├─→ SSH: Restore backup sshd_config
├─→ Firewall: Backup rules available
└─→ OpenClaw: Service can be stopped/removed
```

## 📊 Data Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          DATA FLOW                                      │
└─────────────────────────────────────────────────────────────────────────┘

Local Machine                    VPS Droplet
─────────────                    ───────────

[SSH Key]  ─────────────────────→ [~/.ssh/authorized_keys]
                                  (Key-based auth enabled)

[Script 1] ─────────────────────→ [/etc/ssh/sshd_config]
                                  (Secure SSH config)

[Script 2] ─────────────────────→ [/etc/ufw/]
                                  (Firewall rules)

[Script 3] ─────────────────────→ [/usr/bin/openclaw]
                                  (OpenClaw binary)
                                  
                                  [/etc/systemd/system/openclaw.service]
                                  (Service definition)
                                  
                                  [~/.openclaw/]
                                  (Application data)

Logs Flow:
─────────
[Application] ──→ [~/.openclaw/logs/openclaw.log]
                  [~/.openclaw/logs/openclaw-error.log]
                  
[Systemd] ────→ [journalctl -u openclaw]

[Scripts] ────→ [/tmp/*-setup-*.log]
```

## 🧪 Testing Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        TESTING FLOW                                     │
└─────────────────────────────────────────────────────────────────────────┘

./test-scripts.sh
    │
    ├─→ File Structure Tests
    │   ├─→ Check all required files exist
    │   └─→ Verify file permissions
    │
    ├─→ Syntax Tests
    │   ├─→ bash -n for each script
    │   └─→ ShellCheck (if available)
    │
    ├─→ Header Tests
    │   ├─→ Check for Description
    │   ├─→ Check for Usage
    │   └─→ Check for Examples
    │
    ├─→ Usage Tests
    │   ├─→ Run with no args
    │   └─→ Verify usage output
    │
    ├─→ Parameter Validation Tests
    │   ├─→ Test invalid IP addresses
    │   └─→ Test missing parameters
    │
    └─→ Documentation Tests
        ├─→ Check README exists
        ├─→ Check QUICK_START exists
        └─→ Verify required sections

Result: ✅ PASS or ❌ FAIL with details
```

## 🔄 Idempotency Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      IDEMPOTENCY DESIGN                                 │
└─────────────────────────────────────────────────────────────────────────┘

All scripts can be run multiple times safely:

Script 1 (SSH Hardening):
├─→ Check if key exists ──→ Skip generation if present
├─→ Check if key authorized ──→ Skip copy if already there
└─→ Apply config ──→ Always safe (idempotent config)

Script 2 (Firewall):
├─→ Reset UFW ──→ Clean slate each time
├─→ Apply rules ──→ Same rules each time
└─→ Enable UFW ──→ Safe if already enabled

Script 3 (OpenClaw):
├─→ Check Node.js version ──→ Skip if sufficient
├─→ Check OpenClaw installed ──→ Reinstall to latest
├─→ Create directories ──→ Skip if exist
└─→ Service config ──→ Overwrite with latest

Result: Safe to re-run for updates or fixes
```

## 🎯 Success Verification Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    SUCCESS VERIFICATION                                 │
└─────────────────────────────────────────────────────────────────────────┘

After All Scripts Complete:

1. SSH Verification
   └─→ ssh -i ~/.ssh/id_ed25519 user@droplet
       ├─→ Success? ✅ SSH hardening worked
       └─→ Failed? ❌ Check logs & rollback

2. Firewall Verification
   └─→ ssh user@droplet "sudo ufw status"
       ├─→ Active? ✅ Firewall configured
       └─→ Inactive? ❌ Re-run script 2

3. OpenClaw Verification
   └─→ curl http://droplet:18789/health
       ├─→ 200 OK? ✅ OpenClaw running
       └─→ Failed? ❌ Check service status

4. Service Verification
   └─→ ssh user@droplet "systemctl status openclaw"
       ├─→ Active? ✅ Service running
       └─→ Failed? ❌ Check logs

All Checks Pass? 🎉 Setup Complete!
```

## 📈 Timeline

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       SETUP TIMELINE                                    │
└─────────────────────────────────────────────────────────────────────────┘

T+0:00  Start
        │
T+0:30  ├─→ Script 1: SSH Hardening starts
T+1:00  ├─→ Script 1: SSH Hardening completes ✅
        │
T+1:00  ├─→ Script 2: Firewall Setup starts
T+2:00  ├─→ Script 2: Firewall Setup completes ✅
        │
T+2:00  ├─→ Script 3: OpenClaw Installation starts
T+2:30  │   ├─→ System update
T+3:30  │   ├─→ Node.js installation
T+4:00  │   ├─→ OpenClaw installation
T+4:30  │   └─→ Service configuration
T+5:00  ├─→ Script 3: OpenClaw Installation completes ✅
        │
T+5:00  Complete! 🎉

Total Time: ~5 minutes
```

---

## 🎓 Understanding the Architecture

### Component Relationships

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    COMPONENT ARCHITECTURE                               │
└─────────────────────────────────────────────────────────────────────────┘

Internet
    │
    ├─→ Port 22 (SSH)
    │   └─→ sshd (SSH Daemon)
    │       └─→ Requires SSH Key
    │           └─→ Grants Shell Access
    │
    └─→ Port 18789 (OpenClaw)
        └─→ UFW Firewall
            └─→ Checks Source IP
                ├─→ Allowed IP? Pass to OpenClaw
                └─→ Other IP? Drop packet

VPS Internal:
    │
    ├─→ systemd (Init System)
    │   └─→ openclaw.service
    │       ├─→ Starts OpenClaw on boot
    │       ├─→ Restarts on failure
    │       └─→ Manages logging
    │
    └─→ OpenClaw Application
        ├─→ Listens on port 18789
        ├─→ Writes logs to ~/.openclaw/logs/
        └─→ Stores data in ~/.openclaw/data/
```

---

**This workflow document provides a visual understanding of the complete VPS setup process.**
