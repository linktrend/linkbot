#!/bin/bash
# Google Workspace OAuth Setup Script for Lisa (VPS)
# This script guides you through setting up Google Workspace authentication

set -e

echo "=========================================="
echo "Google Workspace OAuth Setup for Lisa"
echo "=========================================="
echo ""
echo "This script will help you authenticate Lisa with your Google Workspace account."
echo ""
echo "Prerequisites:"
echo "  - You must be on your LOCAL machine (not the VPS)"
echo "  - You need access to info@linktrend.media Google account"
echo "  - Port 8080 must be available on your local machine"
echo ""
echo "Press Enter to continue..."
read

# Step 1: Create SSH tunnel
echo ""
echo "STEP 1: Creating SSH tunnel to VPS..."
echo "=========================================="
echo ""
echo "Opening SSH tunnel on port 8080..."
echo "This terminal will stay connected. DO NOT CLOSE IT."
echo ""
echo "In a NEW terminal window, you'll run the OAuth command."
echo ""

# Open SSH tunnel in background
ssh -L 8080:localhost:8080 root@178.128.77.125 -N &
SSH_PID=$!

echo "✓ SSH tunnel established (PID: $SSH_PID)"
echo ""
echo "Press Enter when you're ready to continue in a NEW terminal..."
read

# Step 2: Instructions for OAuth
echo ""
echo "STEP 2: Run OAuth Authentication"
echo "=========================================="
echo ""
echo "In a NEW terminal window, run this command:"
echo ""
echo "ssh root@178.128.77.125 \"gog auth add info@linktrend.media --services gmail,calendar,drive,contacts,docs,sheets --port 8080\""
echo ""
echo "This will:"
echo "  1. Start OAuth flow"
echo "  2. Display a URL like: http://localhost:8080/auth/..."
echo "  3. Open that URL in your browser"
echo "  4. Sign in with info@linktrend.media"
echo "  5. Grant all requested permissions"
echo "  6. Return to terminal when complete"
echo ""
echo "Press Enter after you've completed the OAuth flow..."
read

# Step 3: Verify
echo ""
echo "STEP 3: Verifying Authentication"
echo "=========================================="
echo ""

echo "Checking authenticated accounts..."
ssh root@178.128.77.125 "gog auth list"

echo ""
echo "Testing Gmail access..."
ssh root@178.128.77.125 "gog gmail list --account info@linktrend.media --max 3" || echo "⚠ Gmail test failed"

echo ""
echo "Testing Calendar access..."
ssh root@178.128.77.125 "gog calendar list-calendars --account info@linktrend.media" || echo "⚠ Calendar test failed"

echo ""
echo "Testing Drive access..."
ssh root@178.128.77.125 "gog drive list --account info@linktrend.media --max 3" || echo "⚠ Drive test failed"

# Step 4: Restart OpenClaw
echo ""
echo "STEP 4: Restarting OpenClaw"
echo "=========================================="
echo ""

ssh root@178.128.77.125 "sudo systemctl restart openclaw"
sleep 5
ssh root@178.128.77.125 "sudo systemctl status openclaw | head -15"

# Step 5: Final verification
echo ""
echo "STEP 5: Final Verification"
echo "=========================================="
echo ""

echo "Checking gog skill status..."
ssh root@178.128.77.125 "cd /root/openclaw-bot && node openclaw.mjs skills list | grep gog"

echo ""
echo "=========================================="
echo "✓ Setup Complete!"
echo "=========================================="
echo ""
echo "Google Workspace is now connected to Lisa."
echo "You can now use Gmail, Calendar, Drive, Docs, Sheets, and Contacts."
echo ""

# Cleanup
kill $SSH_PID 2>/dev/null || true

echo "SSH tunnel closed."
echo ""
