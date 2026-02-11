# Lisa Local Testing Guide

**Status:** ✅ Running  
**URL:** http://localhost:18789  
**Port:** 18789  
**Process:** Started in background  

---

## 🎯 Lisa is Running!

Your browser should have opened to Lisa's control UI. If not, visit:
```
http://localhost:18789
```

---

## ✅ What's Loaded

Lisa is running with **16 skills** and **5 agents** enabled:

### Skills (16)
- ✅ gmail-integration
- ✅ google-docs  
- ✅ google-sheets
- ✅ python-coding
- ✅ typescript-coding
- ✅ document-generator
- ✅ financial-calculator
- ✅ meeting-scheduler
- ✅ task-management
- ✅ behavioral-modes
- ✅ brainstorming
- ✅ clean-code
- ✅ code-review-checklist
- ✅ parallel-agents
- ✅ plan-writing
- ✅ web-design-guidelines

### Agents (5)
- ✅ orchestrator
- ✅ performance-optimizer
- ✅ product-manager
- ✅ product-owner
- ✅ project-planner

---

## 🧪 How to Test

### Option 1: Web UI (Easiest)

1. **Control UI is already open** at http://localhost:18789
2. Click around the interface
3. Try creating a chat session
4. Test asking Lisa to use a skill

### Option 2: API Calls (Terminal)

Test individual skills via curl:

```bash
# Test Gmail skill status
curl -X POST http://localhost:18789/api/gateway \
  -H "Content-Type: application/json" \
  -d '{
    "skill": "gmail-integration",
    "action": "status"
  }'

# Test Python coding skill
curl -X POST http://localhost:18789/api/gateway \
  -H "Content-Type: application/json" \
  -d '{
    "skill": "python-coding",
    "action": "execute",
    "params": {"code": "print(\"Hello from Lisa!\")"}
  }'

# Test behavioral modes skill
curl -X POST http://localhost:18789/api/gateway \
  -H "Content-Type: application/json" \
  -d '{
    "skill": "behavioral-modes",
    "action": "info"
  }'
```

### Option 3: Chat API

Send a chat message:

```bash
curl -X POST http://localhost:18789/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hi Lisa! Can you list your available skills?",
    "session_id": "test-session-1"
  }'
```

---

## 📊 Check Status

### View Running Process

```bash
# Check if Lisa is running
ps aux | grep openclaw | grep -v grep

# Expected output:
# linktrend  14463  ...  openclaw
```

### Check Logs

The startup logs are in:
```
/Users/linktrend/.cursor/projects/Users-linktrend-Projects-LiNKbot/terminals/906697.txt
```

View in real-time:
```bash
tail -f /Users/linktrend/.cursor/projects/Users-linktrend-Projects-LiNKbot/terminals/906697.txt
```

---

## 🛑 Stop Lisa

When you're done testing:

```bash
# Find the process ID
ps aux | grep openclaw | grep -v grep

# Kill the process (replace PID with actual number)
kill 14463
```

Or use:
```bash
pkill -f openclaw
```

---

## ⚠️ Troubleshooting

### Port Already in Use

If port 18789 is busy:

```bash
# Find what's using the port
lsof -i :18789

# Kill it
kill -9 <PID>
```

### Can't Connect to Gateway

```bash
# Check if Lisa is actually running
ps aux | grep openclaw

# Check the logs for errors
tail -50 /Users/linktrend/.cursor/projects/Users-linktrend-Projects-LiNKbot/terminals/906697.txt
```

### Skills Not Loading

The skills configuration is in:
```
bots/lisa/config/lisa/openclaw.json
```

Verify the skills section exists and has `enabled: true`.

---

## 📝 What to Test

### Priority Tests:

1. **Control UI** - Does it load? Can you navigate?
2. **Behavioral Modes** - Try asking Lisa to switch modes
3. **Planning Skills** - Ask Lisa to help plan a project
4. **Code Skills** - Ask Lisa to write some Python code

### Test Scenarios:

**Scenario 1: Project Planning**
```
"Lisa, I need to plan a new feature for my app. 
Can you help me brainstorm ideas?"
```
*Expected: Uses brainstorming + plan-writing skills*

**Scenario 2: Code Review**
```
"Lisa, can you review this code for best practices?"
[paste some code]
```
*Expected: Uses clean-code + code-review-checklist skills*

**Scenario 3: Task Delegation**
```
"Lisa, I need to optimize the performance of my app. 
Can you create a plan?"
```
*Expected: Delegates to performance-optimizer agent*

---

## ✅ Success Criteria

Lisa is working correctly if:

- ✅ Control UI loads at http://localhost:18789
- ✅ Can create a chat session
- ✅ Lisa responds to messages
- ✅ Skills are accessible (check via API or chat)
- ✅ No errors in console/logs

---

## 🚀 Next Step: Deploy to VPS

Once local testing is successful:

```bash
cd /Users/linktrend/Projects/LiNKbot
./scripts/deploy-bot.sh lisa vps1
```

This will:
1. Sync code to VPS
2. Copy configuration with enabled skills
3. Restart Lisa on VPS
4. Lisa will be accessible via Telegram

---

## 📍 Quick Links

- **Control UI:** http://localhost:18789
- **API Gateway:** http://localhost:18789/api/gateway
- **Health Check:** http://localhost:18789/health
- **Skills Config:** `bots/lisa/config/lisa/openclaw.json`
- **Process Logs:** Terminal 906697

---

**Happy Testing!** 🎉

If you encounter any issues, check the logs first, then let me know!
