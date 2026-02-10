# 🤖 Interactive Telegram Bot Setup Guide

## Lisa - Business Partner Bot Configuration

**Estimated Time**: 15-20 minutes  
**Prerequisites**: None (this is standalone)  
**Result**: Fully configured Telegram bot ready for notifications

---

## 📋 Setup Checklist

Use this checklist to track your progress:

- [ ] **Phase 1**: Create bot via BotFather (5 min)
- [ ] **Phase 2**: Get your Telegram chat ID (3 min)
- [ ] **Phase 3**: Configure bot settings (5 min)
- [ ] **Phase 4**: Update .env file (3 min)
- [ ] **Phase 5**: Test bot connection (4 min)

**Total**: ~20 minutes

---

## Phase 1: Create Your Bot via BotFather (5 min)

### Step 1.1: Start Chat with BotFather

1. Open Telegram on your phone or desktop
2. In the search bar, type: `@BotFather`
3. Tap on the verified **BotFather** account (blue checkmark)
4. Tap **START** or send this command:

```
/start
```

**Expected Response**: Welcome message from BotFather with available commands

---

### Step 1.2: Create New Bot

**Send this command** to BotFather:

```
/newbot
```

**BotFather will ask for the bot name**. Copy and send:

```
Lisa - Business Partner
```

> 💡 **Note**: This is the display name users will see in chats

---

### Step 1.3: Choose Bot Username

**BotFather will ask for username**. Choose one of these:

**Option 1** (Recommended):
```
LisaBusinessPartnerBot
```

**Option 2** (Alternative):
```
LiNKtrend_Lisa_Bot
```

> ⚠️ **Important**: Username MUST end in `bot` and be unique across all Telegram bots

---

### Step 1.4: Save Your Bot Token

**BotFather will respond with**:

```
Done! Congratulations on your new bot.

Use this token to access the HTTP API:
1234567890:ABCdefGHIjklMNOpqrsTUVwxyz1234567890

Keep your token secure and store it safely, 
it can be used by anyone to control your bot.
```

**🔐 CRITICAL: Copy your bot token NOW!**

Your token format: `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz1234567890`

**Save it somewhere safe** (you'll need it in Phase 4)

---

### ✅ Phase 1 Checkpoint

You should now have:
- [x] Bot created via BotFather
- [x] Bot name: "Lisa - Business Partner"
- [x] Bot username: `@LisaBusinessPartnerBot` (or your chosen username)
- [x] Bot token saved securely

**Proceed to Phase 2 →**

---

## Phase 2: Get Your Telegram Chat ID (3 min)

Your bot needs your **Chat ID** to send you messages. Choose one of these methods:

---

### Method 1: Using @userinfobot (Easiest) ⭐

**Step 2.1**: In Telegram, search for: `@userinfobot`

**Step 2.2**: Start chat and send:

```
/start
```

**Step 2.3**: The bot will reply with your info:

```
Id: 123456789
First name: Carlos
Username: @carloslinktme
Language: en
```

**Step 2.4**: Copy your numeric ID (e.g., `123456789`)

**Your Chat ID**: `_______________` ← Write it here!

---

### Method 2: Using curl with Your Bot Token (Alternative)

**Step 2.1**: Open your new bot chat (`@LisaBusinessPartnerBot`)

**Step 2.2**: Send any message to your bot:

```
Hello Lisa!
```

**Step 2.3**: Open Terminal on your Mac and run this command:

**⚠️ Replace `YOUR_BOT_TOKEN` with your actual token from Phase 1**

```bash
curl https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates
```

**Example** (with placeholder token):
```bash
curl https://api.telegram.org/bot1234567890:ABCdefGHIjklMNOpqrsTUVwxyz/getUpdates
```

**Step 2.4**: The response will look like this:

```json
{
  "ok": true,
  "result": [{
    "update_id": 123456789,
    "message": {
      "message_id": 1,
      "from": {
        "id": 987654321,  ← This is your CHAT_ID!
        "is_bot": false,
        "first_name": "Carlos",
        "username": "carloslinktme"
      },
      "chat": {
        "id": 987654321,  ← Same number here
        "first_name": "Carlos",
        "username": "carloslinktme",
        "type": "private"
      },
      "text": "Hello Lisa!"
    }
  }]
}
```

**Step 2.5**: Copy the numeric ID from `"from": { "id": 987654321 }`

**Your Chat ID**: `_______________` ← Write it here!

---

### ✅ Phase 2 Checkpoint

You should now have:
- [x] Bot token from Phase 1: `1234567890:ABC...`
- [x] Your Telegram chat ID: `123456789`

**Proceed to Phase 3 →**

---

## Phase 3: Configure Bot Settings (5 min)

Let's customize your bot's profile and description!

---

### Step 3.1: Set Bot Description

This message appears when users **first start** a chat with your bot.

**Send to BotFather**:

```
/setdescription
```

**BotFather will ask**: "Choose a bot"

**Reply with your bot username**:

```
@LisaBusinessPartnerBot
```

(Or whatever username you chose in Phase 1)

**BotFather will ask for the description**. Copy and send:

```
I'm Lisa, your Strategic Operations & Execution Lead. I help with:
• Business planning & execution
• Email & calendar management
• Document creation (Docs, Sheets, Slides)
• Research & task management
• Strategic decision support

For urgent matters and quick updates only. Use email for detailed communications.
```

**Expected Response**: "Success! Description updated."

---

### Step 3.2: Set About Text

This text appears in your bot's **profile page**.

**Send to BotFather**:

```
/setabouttext
```

**BotFather will ask**: "Choose a bot"

**Reply with your bot username**:

```
@LisaBusinessPartnerBot
```

**BotFather will ask for the about text**. Copy and send:

```
Strategic Operations & Execution Lead for LiNKtrend Venture Studio. AI-powered business partner bot.
```

**Expected Response**: "Success! About text updated."

---

### Step 3.3: Set Bot Commands (Optional but Recommended)

This creates a menu of commands users can select.

**Send to BotFather**:

```
/setcommands
```

**BotFather will ask**: "Choose a bot"

**Reply with your bot username**:

```
@LisaBusinessPartnerBot
```

**BotFather will ask for the command list**. Copy and send this **entire block**:

```
start - Initialize bot and show welcome
status - Check urgent items and status
today - Today's calendar and tasks summary
urgent - Show only high-priority items
email - Check for urgent emails
calendar - Show upcoming calendar events
tasks - List pending tasks
help - Show all available commands
```

**Expected Response**: "Success! Command list updated."

---

### Step 3.4: Set Bot Profile Picture (Optional)

If you have a logo or avatar for Lisa:

**Send to BotFather**:

```
/setuserpic
```

**BotFather will ask**: "Choose a bot"

**Reply with your bot username**:

```
@LisaBusinessPartnerBot
```

**Then**: Upload an image (square format, 512x512 px recommended)

**Skip this if you don't have an image ready** ✓

---

### ✅ Phase 3 Checkpoint

Your bot profile is now configured:
- [x] Description set (first chat message)
- [x] About text set (profile)
- [x] Commands menu configured
- [x] Profile picture (optional)

**Proceed to Phase 4 →**

---

## Phase 4: Update .env File (3 min)

Now let's add your bot credentials to your configuration file.

---

### Step 4.1: Locate Your .env File

**Check if .env exists**:

```bash
ls -la /Users/linktrend/Projects/LiNKbot/.env
```

**If file doesn't exist**, create it:

```bash
touch /Users/linktrend/Projects/LiNKbot/.env
chmod 600 /Users/linktrend/Projects/LiNKbot/.env
```

---

### Step 4.2: Add Telegram Configuration

**Open .env file**:

```bash
nano /Users/linktrend/Projects/LiNKbot/.env
```

**Scroll to the bottom** and add these lines:

**⚠️ Replace the placeholder values with YOUR actual token and chat ID**

```bash
# ============================================================================
# TELEGRAM BOT CONFIGURATION
# ============================================================================

# Bot token from BotFather (Phase 1)
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz1234567890

# Your Telegram user ID (Phase 2)
TELEGRAM_CHAT_ID=987654321

# Admin user ID (same as chat ID if you're the only admin)
TELEGRAM_ADMIN_ID=987654321
```

**Example** (with actual values):
```bash
TELEGRAM_BOT_TOKEN=9876543210:XYZabcDEFghiJKLmnoPQRstuVWXyz9876543
TELEGRAM_CHAT_ID=123456789
TELEGRAM_ADMIN_ID=123456789
```

**Save the file**:
- Press `Ctrl+O` (save)
- Press `Enter` (confirm)
- Press `Ctrl+X` (exit)

---

### Step 4.3: Verify File Permissions

**Ensure .env is secure** (only you can read/write):

```bash
chmod 600 /Users/linktrend/Projects/LiNKbot/.env
ls -la /Users/linktrend/Projects/LiNKbot/.env
```

**Expected output**:

```
-rw-------  1 linktrend  staff  1234 Feb  9 10:30 .env
```

The `-rw-------` means only you can read/write. ✓

---

### ✅ Phase 4 Checkpoint

Your .env file now contains:
- [x] `TELEGRAM_BOT_TOKEN` configured
- [x] `TELEGRAM_CHAT_ID` configured
- [x] `TELEGRAM_ADMIN_ID` configured
- [x] File permissions set to 600 (secure)

**Proceed to Phase 5 →**

---

## Phase 5: Test Bot Connection (4 min)

Let's verify everything works!

---

### Step 5.1: Test Bot Token (via API)

**Load your .env variables**:

```bash
cd /Users/linktrend/Projects/LiNKbot
source .env
```

**Test bot token with curl**:

```bash
curl https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe
```

**Expected response** (JSON):

```json
{
  "ok": true,
  "result": {
    "id": 1234567890,
    "is_bot": true,
    "first_name": "Lisa - Business Partner",
    "username": "LisaBusinessPartnerBot",
    "can_join_groups": true,
    "can_read_all_group_messages": false,
    "supports_inline_queries": false
  }
}
```

**✅ If you see this**: Token is valid!  
**❌ If you see "Unauthorized"**: Check your token in .env file

---

### Step 5.2: Test Bot in Telegram App

**Open Telegram** and search for your bot: `@LisaBusinessPartnerBot`

**Start chat** and send:

```
/start
```

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

**✅ If bot responds**: Connection works!  
**❌ If bot doesn't respond**: See Troubleshooting section below

---

### Step 5.3: Test Commands

**Test the /help command**:

```
/help
```

**Expected**: Bot lists all available commands

**Test the /status command**:

```
/status
```

**Expected**: Bot responds (may say "No urgent items" if not connected to other services yet)

---

### Step 5.4: Test Message Sending (via API)

**Send a test message from your Terminal**:

```bash
curl -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -H "Content-Type: application/json" \
  -d "{
    \"chat_id\": \"${TELEGRAM_CHAT_ID}\",
    \"text\": \"✅ TEST: Bot connection successful! Your Telegram integration is working.\"
  }"
```

**Check your Telegram chat**. You should receive this message from Lisa.

**✅ If message arrives**: Full integration works!  
**❌ If no message**: Check chat ID in .env file

---

### ✅ Phase 5 Checkpoint - SETUP COMPLETE! 🎉

Your Telegram bot is fully configured and tested:
- [x] Bot token validated via API
- [x] Bot responds to /start command
- [x] Bot responds to /help command
- [x] Bot can send messages to your chat
- [x] All credentials stored securely in .env

**Your bot is ready to use!** 🚀

---

## 🔍 Troubleshooting Guide

### Issue 1: "Unauthorized" Error (Invalid Token)

**Problem**: API returns `{"ok":false,"error_code":401,"description":"Unauthorized"}`

**Solutions**:

1. **Check token format** - Should be: `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz`
   ```bash
   cat /Users/linktrend/Projects/LiNKbot/.env | grep TELEGRAM_BOT_TOKEN
   ```

2. **Verify no extra spaces** in .env file:
   ```bash
   # Wrong: TELEGRAM_BOT_TOKEN= 123456...
   # Wrong: TELEGRAM_BOT_TOKEN=123456... (with trailing space)
   # Correct: TELEGRAM_BOT_TOKEN=123456...
   ```

3. **Get a fresh token** from BotFather:
   ```
   /token
   @LisaBusinessPartnerBot
   ```

---

### Issue 2: Can't Find Chat ID

**Problem**: `getUpdates` returns empty result `{"ok":true,"result":[]}`

**Solution**:

1. **Send a message to your bot first** (in Telegram app):
   ```
   Hello!
   ```

2. **Then run** the curl command:
   ```bash
   curl https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates
   ```

3. **If still empty**, use Method 1 instead:
   - Search for `@userinfobot`
   - Send `/start`
   - Copy your ID

---

### Issue 3: Bot Doesn't Respond to /start

**Problem**: Send `/start` in Telegram, but bot doesn't reply

**Possible Causes**:

1. **Bot not running** - Currently, the bot needs a backend service
   - This guide only creates the bot
   - You'll connect it to OpenClaw later in deployment

2. **Bot blocked** - Check if you accidentally blocked the bot
   - Go to bot chat → Menu (three dots) → Unblock

3. **Commands not set correctly** - Re-run Phase 3 steps

---

### Issue 4: "Forbidden" Error When Sending Messages

**Problem**: API returns `{"ok":false,"error_code":403,"description":"Forbidden"}`

**Solutions**:

1. **Start the bot first** - Send `/start` to your bot in Telegram app

2. **Verify chat ID** matches your user ID:
   ```bash
   # Check what's in .env
   grep TELEGRAM_CHAT_ID /Users/linktrend/Projects/LiNKbot/.env
   
   # Verify with @userinfobot
   ```

3. **Check for typos** - Chat ID should be ONLY numbers (no letters)

---

### Issue 5: Bot Responds Slowly or Not at All

**Problem**: Bot takes >10 seconds to respond, or times out

**Causes**:

1. **Telegram servers slow** - Rare, but happens
   - Wait 5 minutes and try again

2. **No backend connected yet** - Bot needs OpenClaw to respond intelligently
   - This is expected if you haven't deployed yet

3. **Network issues** - Check your internet connection

---

### Issue 6: .env File Permissions Error

**Problem**: Error reading .env file or "permission denied"

**Solution**:

```bash
# Fix ownership
sudo chown linktrend:staff /Users/linktrend/Projects/LiNKbot/.env

# Fix permissions
chmod 600 /Users/linktrend/Projects/LiNKbot/.env

# Verify
ls -la /Users/linktrend/Projects/LiNKbot/.env
```

**Expected**: `-rw------- 1 linktrend staff ...`

---

## 📚 Quick Reference

### Essential URLs

- **BotFather**: https://t.me/BotFather
- **UserInfoBot**: https://t.me/userinfobot
- **Your Bot**: `https://t.me/YourBotUsername`
- **Telegram API Docs**: https://core.telegram.org/bots/api

---

### Useful curl Commands

**Test bot token**:
```bash
curl https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe
```

**Get chat updates**:
```bash
curl https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates
```

**Send test message**:
```bash
curl -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -H "Content-Type: application/json" \
  -d '{"chat_id":"YOUR_CHAT_ID","text":"Test message"}'
```

**Get bot info**:
```bash
curl https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe
```

---

### BotFather Commands Reference

| Command | Purpose |
|---------|---------|
| `/newbot` | Create a new bot |
| `/mybots` | List your bots |
| `/setname` | Change bot name |
| `/setdescription` | Change bot description |
| `/setabouttext` | Change bot about text |
| `/setuserpic` | Change bot profile picture |
| `/setcommands` | Set bot commands menu |
| `/deletebot` | Delete a bot |
| `/token` | Get bot token (if you lost it) |
| `/revoke` | Revoke bot token (generate new one) |

---

## 🔒 Security Best Practices

### ✅ DO

- ✅ Store bot token in .env file with 600 permissions
- ✅ Add .env to .gitignore (never commit to git)
- ✅ Use HTTPS for all API calls (Telegram enforces this)
- ✅ Restrict admin access to your chat ID only
- ✅ Revoke token immediately if compromised (`/revoke` in BotFather)
- ✅ Test bot in private chat first (not groups)

### ❌ DON'T

- ❌ Share your bot token publicly (Discord, GitHub, Slack)
- ❌ Use the same bot token in multiple projects
- ❌ Store token in plaintext files without permissions
- ❌ Give admin access to multiple people (one bot = one admin)
- ❌ Add bot to public groups without rate limiting
- ❌ Hardcode token in code files

---

### Token Compromise Response Plan

**If your token is leaked** (e.g., committed to GitHub):

1. **Immediately revoke** the token:
   ```
   /revoke
   @LisaBusinessPartnerBot
   ```

2. **Get new token** from BotFather response

3. **Update .env** with new token:
   ```bash
   nano /Users/linktrend/Projects/LiNKbot/.env
   # Update TELEGRAM_BOT_TOKEN line
   ```

4. **Verify old token doesn't work**:
   ```bash
   curl https://api.telegram.org/botOLD_TOKEN/getMe
   # Should return: Unauthorized
   ```

5. **Test new token**:
   ```bash
   curl https://api.telegram.org/botNEW_TOKEN/getMe
   # Should return: bot info
   ```

---

## 📖 What's Next?

Now that your Telegram bot is configured, here are your next steps:

### Immediate Next Steps

1. **Save your credentials** somewhere secure (password manager):
   - Bot username: `@LisaBusinessPartnerBot`
   - Bot token: `1234567890:ABC...`
   - Chat ID: `123456789`

2. **Test all commands** in Telegram:
   - `/start`
   - `/help`
   - `/status`

3. **Bookmark your bot** in Telegram for quick access

---

### Integration Steps (Later)

When you're ready to connect Lisa to your bot:

1. **Deploy OpenClaw** (see: `/docs/guides/VPS_DEPLOYMENT.md`)
2. **Configure Telegram channel** in OpenClaw config
3. **Set up notification rules** (urgent emails, calendar reminders)
4. **Configure quiet hours** (suppress notifications at night)
5. **Test end-to-end** (send test notification from Lisa)

---

### Advanced Configuration (Optional)

After basic setup works:

- **Webhooks** instead of polling (faster, more efficient)
- **Custom keyboards** (quick reply buttons)
- **Inline queries** (use bot in any chat with `@mention`)
- **Group chat support** (add Lisa to team groups)
- **Rate limiting** (prevent spam/abuse)

---

## ✅ Verification Checklist

Before marking this guide as complete:

- [ ] Bot created via BotFather
- [ ] Bot token saved securely
- [ ] Chat ID obtained (via @userinfobot or getUpdates)
- [ ] Bot description set (first chat message)
- [ ] Bot about text set (profile)
- [ ] Bot commands menu configured
- [ ] .env file updated with credentials
- [ ] .env file permissions set to 600
- [ ] Bot token validated via curl
- [ ] Bot responds to /start command
- [ ] Bot responds to /help command
- [ ] Test message sent successfully via API
- [ ] Credentials backed up (password manager)

**If all checked**: Your Telegram bot setup is COMPLETE! 🎉

---

## 📞 Need Help?

### Common Questions

**Q: Can I change my bot username later?**  
A: Yes, use `/setusername` in BotFather. But choose wisely—changing username breaks existing links.

**Q: Can I have multiple bots?**  
A: Yes! Just repeat this guide with a different bot name/username.

**Q: Is my bot private?**  
A: Yes, only people who know the username can find it. Add admin ID restrictions for security.

**Q: What if I lose my bot token?**  
A: Use `/token` command in BotFather to retrieve it.

**Q: Can I delete a bot?**  
A: Yes, use `/deletebot` in BotFather. This is permanent!

**Q: Do I need to pay for Telegram bots?**  
A: No! Telegram bots are 100% free, forever.

---

### Resources

- **Official Telegram Bot API**: https://core.telegram.org/bots/api
- **BotFather Guide**: https://core.telegram.org/bots#botfather
- **Telegram Bot Examples**: https://core.telegram.org/bots/samples

---

**Setup Time**: ~15-20 minutes  
**Difficulty**: ⭐ Easy  
**Status**: ✅ Complete  
**Last Updated**: February 9, 2026

---

**🎉 Congratulations! Your Telegram bot is ready to use!**
