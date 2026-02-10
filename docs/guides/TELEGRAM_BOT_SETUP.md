# Telegram Bot Setup Guide - Business Partner Bot

## Overview

Configure Lisa to send you urgent notifications and respond to quick commands via Telegram. This provides a fast, secure channel for time-sensitive updates while reserving email for longer communications.

**Estimated Time**: 20-30 minutes  
**Prerequisites**: OpenClaw deployed on VPS

**Security Note**: Telegram is the most secure messaging platform for AI bots (more secure than Slack/Discord), with MTProto 2.0 encryption and GDPR compliance.

---

## Phase 1: Create Telegram Bot (10 minutes)

### 1.1 Start Chat with BotFather

1. Open Telegram app on your phone or desktop
2. Search for `@BotFather` (official Telegram bot for creating bots)
3. Start a chat with BotFather
4. Send command: `/start`

---

### 1.2 Create New Bot

**Send command**: `/newbot`

**BotFather will ask for**:

**Bot Name** (display name):
```
Lisa - Business Partner
```
(Users will see this name in chats)

**Bot Username** (must end in 'bot'):
```
LisaBusinessPartnerBot
```
or
```
LiNKtrend_Lisa_Bot
```
(Must be unique across all Telegram bots)

**Success Message**:
```
Done! Congratulations on your new bot. You will find it at t.me/LisaBusinessPartnerBot.

Use this token to access the HTTP API:
1234567890:ABCdefGHIjklMNOpqrsTUVwxyz1234567890

Keep your token secure and store it safely, it can be used by anyone to control your bot.
```

**CRITICAL**: Copy the bot token immediately!
- Format: `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz1234567890`
- This is your `TELEGRAM_BOT_TOKEN`

---

### 1.3 Configure Bot Settings

**Set bot description** (shown when users first start chat):
```
/setdescription @LisaBusinessPartnerBot
```
Then send:
```
I'm Lisa, your Strategic Operations & Execution Lead. I help with:
• Business planning & execution
• Email & calendar management
• Document creation (Docs, Sheets, Slides)
• Research & task management
• Strategic decision support

For urgent matters and quick updates only. Use email for detailed communications.
```

**Set bot about** (shown in bot profile):
```
/setabouttext @LisaBusinessPartnerBot
```
Then send:
```
Strategic Operations & Execution Lead for LiNKtrend Venture Studio. AI-powered business partner bot.
```

**Set bot profile photo** (optional):
```
/setuserpic @LisaBusinessPartnerBot
```
Then upload an image (if you have a logo/avatar for Lisa)

---

### 1.4 Configure Bot Privacy

**Disable group privacy** (only if you plan to add Lisa to groups):
```
/setprivacy @LisaBusinessPartnerBot
```
Choose: `Disable` (allows bot to read all messages in groups)

**Note**: For security, we recommend keeping this enabled (default) if Lisa only chats with you 1-on-1.

---

### 1.5 Get Your Chat ID

**Why**: OpenClaw needs your Telegram user ID to send you messages.

**Method 1: Using IDBot** (easiest):
1. Search for `@userinfobot` in Telegram
2. Start chat and send `/start`
3. Bot replies with your user info
4. Copy your numeric ID (e.g., `123456789`)

**Method 2: Using your bot**:
1. Open chat with your new bot (`@LisaBusinessPartnerBot`)
2. Send any message (e.g., "Hello")
3. Run this curl command on Mac:
```bash
curl https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates
```
Replace `<YOUR_BOT_TOKEN>` with your actual token.

4. Response will show:
```json
{
  "ok": true,
  "result": [{
    "update_id": 123456789,
    "message": {
      "message_id": 1,
      "from": {
        "id": 987654321,  <-- This is your CHAT_ID
        "is_bot": false,
        "first_name": "Carlos",
        ...
      }
    }
  }]
}
```

**Save both**:
- `TELEGRAM_BOT_TOKEN`: `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz1234567890`
- `TELEGRAM_CHAT_ID`: `987654321`

---

## Phase 2: Configure OpenClaw Integration (15 minutes)

### 2.1 Add Telegram Credentials to .env

**On Mac**:
```bash
# Edit local .env file
cd /Users/linktrend/Projects/LiNKbot/bots/business-partner/config/business-partner
nano .env
```

**Add these lines**:
```bash
# Telegram Bot Configuration
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz1234567890
TELEGRAM_CHAT_ID=987654321
TELEGRAM_ADMIN_ID=987654321  # Same as chat ID if you're the only admin
```

**Save**: `Ctrl+O`, Enter, `Ctrl+X`

**Transfer to VPS**:
```bash
# Backup existing .env on VPS first
ssh root@YOUR_DROPLET_IP "cp ~/.openclaw/.env ~/.openclaw/.env.backup-$(date +%Y%m%d)"

# Transfer updated .env
scp .env root@YOUR_DROPLET_IP:~/.openclaw/.env

# Verify permissions on VPS
ssh root@YOUR_DROPLET_IP "chmod 600 ~/.openclaw/.env && ls -la ~/.openclaw/.env"
```

---

### 2.2 Update OpenClaw Configuration

**SSH into VPS**:
```bash
ssh root@YOUR_DROPLET_IP
nano ~/.openclaw/openclaw.json
```

**Add Telegram channel configuration** (after `integrations:` section, or in `channels:` section if it exists):

```json5
  // ============================================================================
  // TELEGRAM CHANNEL CONFIGURATION
  // ============================================================================
  channels: {
    telegram: {
      enabled: true,
      
      // Bot credentials (from .env)
      token: "${TELEGRAM_BOT_TOKEN}",
      adminChatId: "${TELEGRAM_ADMIN_ID}",
      
      // Notification settings
      notifications: {
        enabled: true,
        priority: "high", // Only send urgent/high-priority messages
        
        // What types of events trigger Telegram notifications
        events: [
          "high_priority_email",     // Emails marked priority
          "meeting_reminder_urgent", // Meetings within 1 hour
          "task_deadline_urgent",    // Tasks due within 24 hours
          "error_critical",          // Critical system errors
          "user_mention",            // When you're mentioned in documents
          "manual_alert",            // When Lisa manually sends alert
        ],
        
        // Quiet hours (no notifications)
        quietHours: {
          enabled: true,
          start: "22:00", // 10 PM
          end: "07:00",   // 7 AM
          timezone: "America/New_York", // Your timezone
        },
      },
      
      // Bot behavior
      commands: {
        enabled: true,
        
        // Custom commands
        aliases: {
          "/status": "What's my status? Any urgent items?",
          "/today": "Summarize my calendar and tasks for today",
          "/urgent": "Show me all high-priority items",
          "/email": "Check my email for anything urgent",
          "/help": "What can you help me with via Telegram?",
        },
      },
      
      // Rate limiting (prevent spam)
      rateLimit: {
        messagesPerMinute: 10,
        burstSize: 3,
      },
    },
  },
```

**Save**: `Ctrl+O`, Enter, `Ctrl+X`

---

### 2.3 Restart OpenClaw

```bash
# Restart service to load new configuration
sudo systemctl restart openclaw

# Monitor logs for Telegram connection
sudo journalctl -u openclaw -f | grep -i telegram
```

**Expected log output**:
```
[INFO] Telegram channel initialized
[INFO] Connected to Telegram bot: @LisaBusinessPartnerBot
[INFO] Listening for commands from admin: 987654321
```

**If you see errors**, check:
1. Token format is correct (no extra spaces/newlines)
2. .env file has correct variables
3. Firewall allows outbound HTTPS (port 443) for Telegram API

---

## Phase 3: Testing & Verification (10 minutes)

### 3.1 Test Bot Connection

**From Telegram app**:
1. Open chat with your bot (`@LisaBusinessPartnerBot`)
2. Send: `/start`

**Expected response** from Lisa:
```
Hello! I'm Lisa, your Strategic Operations & Execution Lead.

I'm here to send you urgent updates and respond to quick commands. 

For detailed work, please use email or the web interface.

Available commands:
/status - Check urgent items
/today - Today's calendar and tasks
/urgent - High-priority items only
/email - Check for urgent emails
/help - See all commands
```

---

### 3.2 Test Commands

**Test /status**:
```
/status
```

**Expected**: Lisa responds with current status summary (calendar, tasks, emails)

**Test /today**:
```
/today
```

**Expected**: Summary of today's calendar events and tasks

**Test /help**:
```
/help
```

**Expected**: List of available commands and capabilities

---

### 3.3 Test Notification (Manual Alert)

**From Mac, send test notification**:
```bash
openclaw chat --gateway lisa-production "Send me a Telegram notification that says: 'TEST ALERT: This is a test of the Telegram notification system. If you receive this, the integration is working correctly.'"
```

**Expected**: Message appears in your Telegram chat with Lisa

---

### 3.4 Test Natural Language Commands

**In Telegram, send**:
```
What's on my calendar for tomorrow?
```

**Expected**: Lisa responds with calendar summary for tomorrow

**Send**:
```
Remind me to review the Q1 budget in 30 minutes
```

**Expected**: Lisa confirms reminder is set and sends notification in 30 min

---

## Phase 4: Advanced Configuration (Optional)

### 4.1 Configure Priority Email Alerts

**Edit `openclaw.json`** on VPS to send Telegram alerts for priority emails:

```json5
gmail: {
  enabled: true,
  defaultSender: "lisa@yourdomain.com",
  
  // Telegram integration for priority emails
  notifications: {
    telegram: {
      enabled: true,
      priority: ["high", "urgent"],
      
      // What triggers Telegram notification
      rules: [
        {
          condition: "from:important-client@example.com",
          action: "telegram_alert",
          message: "📧 High-priority email from Important Client",
        },
        {
          condition: "subject:[URGENT]",
          action: "telegram_alert",
          message: "🚨 Urgent email received",
        },
        {
          condition: "label:priority",
          action: "telegram_alert",
          message: "⚠️ Priority email needs attention",
        },
      ],
    },
  },
},
```

**Restart OpenClaw**:
```bash
sudo systemctl restart openclaw
```

---

### 4.2 Configure Meeting Reminders

**Add to calendar configuration**:

```json5
calendar: {
  enabled: true,
  defaultCalendar: "primary",
  
  // Telegram reminders
  telegramReminders: {
    enabled: true,
    
    // When to send Telegram notifications
    beforeMeeting: [
      60,  // 1 hour before
      15,  // 15 minutes before
    ],
    
    // Message format
    messageTemplate: "📅 Meeting in {time}: {title}\nLocation: {location}\nJoin: {link}",
  },
},
```

---

### 4.3 Set Up Webhook (Advanced)

**For instant message delivery instead of polling**:

```bash
# SSH into VPS
ssh root@YOUR_DROPLET_IP

# Set webhook URL (requires SSL/TLS)
curl -X POST "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://YOUR_DOMAIN_OR_IP:18789/webhooks/telegram",
    "allowed_updates": ["message", "callback_query"]
  }'
```

**Note**: This requires:
1. Valid SSL certificate (Let's Encrypt)
2. Domain name pointing to your VPS
3. Webhook endpoint configured in OpenClaw

**For now, polling is sufficient**. We can set up webhooks later if needed.

---

## Troubleshooting

### Bot doesn't respond to /start

**Check logs**:
```bash
ssh root@YOUR_DROPLET_IP
sudo journalctl -u openclaw -n 50 | grep -i telegram
```

**Common issues**:
1. **Wrong token**: Verify `TELEGRAM_BOT_TOKEN` in `.env` matches BotFather token
2. **Firewall blocking outbound**: VPS needs HTTPS (443) access to api.telegram.org
3. **Service not restarted**: Run `sudo systemctl restart openclaw`

**Test token manually**:
```bash
curl https://api.telegram.org/bot<YOUR_TOKEN>/getMe
```
Expected: JSON with bot info

---

### Notifications not arriving

**Check notification settings**:
```bash
# Verify notifications are enabled
grep -A 10 "telegram:" ~/.openclaw/openclaw.json
```

**Check quiet hours**:
- If it's between 22:00 and 07:00 (your configured quiet hours), notifications are suppressed
- Test during daytime hours

**Force test notification**:
```bash
curl -X POST "https://api.telegram.org/bot<YOUR_TOKEN>/sendMessage" \
  -H "Content-Type: application/json" \
  -d '{
    "chat_id": "<YOUR_CHAT_ID>",
    "text": "Test notification from curl"
  }'
```

If this works but OpenClaw notifications don't, check OpenClaw's Telegram integration logs.

---

### "Unauthorized" or "Forbidden" errors

**Problem**: Chat ID mismatch or bot blocked.

**Solutions**:
1. **Verify chat ID**: Re-run `/getUpdates` to confirm your chat ID
2. **Unblock bot**: If you blocked the bot, unblock it in Telegram settings
3. **Start bot**: Send `/start` in Telegram to re-establish connection

---

## Security Best Practices

✅ **Keep token secret**:
```bash
# Verify .env permissions on VPS
ssh root@YOUR_DROPLET_IP "ls -la ~/.openclaw/.env"
# Expected: -rw------- (600)
```

✅ **Restrict admin access**:
- Only you (admin chat ID) can send commands
- Configure `TELEGRAM_ADMIN_ID` to your personal Telegram user ID

✅ **Enable quiet hours**:
- Prevents notification spam during sleep hours
- Configure in `openclaw.json`

✅ **Rate limiting**:
- Prevents abuse if token is compromised
- Default: 10 messages/minute, burst of 3

---

## Usage Guidelines

### When to Use Telegram

✅ **Use Telegram for**:
- Urgent alerts requiring immediate attention
- Quick status checks while mobile
- Meeting reminders
- Critical email notifications
- System error alerts

❌ **Don't use Telegram for**:
- Long-form communications (use email)
- Document creation/editing (use web interface)
- Complex multi-step tasks (use email or web)
- Detailed strategic planning (use email)

---

### Command Quick Reference

```
/start         - Initialize bot and show welcome
/status        - Check urgent items and status
/today         - Today's calendar and tasks summary
/urgent        - Show only high-priority items
/email         - Check for urgent emails
/calendar      - Show upcoming calendar events
/tasks         - List pending tasks
/help          - Show all available commands
```

**Natural language also works**:
- "What's my next meeting?"
- "Any urgent emails?"
- "Remind me to..."
- "What's on my calendar tomorrow?"

---

## Success Criteria

✅ Telegram bot created via BotFather  
✅ Bot token and chat ID obtained  
✅ OpenClaw configured with Telegram channel  
✅ Bot responds to `/start` and `/help`  
✅ Commands work (`/status`, `/today`, etc.)  
✅ Test notification received successfully  
✅ Natural language queries work  
✅ Quiet hours configured (optional)  
✅ Priority email alerts configured (optional)  

---

## Next Steps

1. ✅ Telegram integration complete
2. ➡️ **Proceed to**: Skills Installation Guide
3. ➡️ **Final**: End-to-End Testing

---

**Setup Time**: 20-30 minutes  
**Status**: Ready to configure  
**Security**: Most secure messaging platform for AI bots ✅
