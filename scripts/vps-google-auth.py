#!/usr/bin/env python3
"""
VPS-Friendly Google OAuth Authentication Script
Authenticates Google Docs and Google Sheets MCP skills without browser
"""

import os
import sys
import json
from pathlib import Path

def setup_google_docs():
    """Setup OAuth for google-docs MCP skill"""
    print("\n" + "="*60)
    print("  GOOGLE DOCS MCP - OAuth Setup")
    print("="*60)
    
    skills_dir = "/root/linkbot/skills/shared/google-docs"
    creds_file = Path(skills_dir) / "credentials.json"
    token_file = Path(skills_dir) / "token.json"
    
    if not creds_file.exists():
        print(f"❌ ERROR: {creds_file} not found")
        return False
    
    if token_file.exists():
        print("✅ google-docs already authenticated (token.json exists)")
        return True
    
    print("\n📋 Manual OAuth Setup Required:\n")
    print("1. Install dependencies locally:")
    print(f"   cd {skills_dir} && npm install")
    print("\n2. Run the MCP server once:")
    print(f"   cd {skills_dir} && node index.js")
    print("\n3. It will display an OAuth URL - open it in your browser")
    print("4. Authorize with lisa@linktrend.media")
    print("5. The token.json will be created automatically")
    print("\nPress Ctrl+C and run these commands manually.")
    
    return False

def setup_google_sheets():
    """Setup OAuth for google-sheets MCP skill (Python-based)"""
    print("\n" + "="*60)
    print("  GOOGLE SHEETS MCP - OAuth Setup")
    print("="*60)
    
    try:
        from google.oauth2.credentials import Credentials
        from google_auth_oauthlib.flow import InstalledAppFlow
        import pickle
    except ImportError:
        print("❌ ERROR: Missing dependencies")
        print("Run: pip install google-auth-oauthlib google-api-python-client")
        return False
    
    skills_dir = "/root/linkbot/skills/shared/google-sheets"
    creds_file = Path(skills_dir) / "credentials.json"
    token_file = Path(skills_dir) / "token.json"
    
    if not creds_file.exists():
        print(f"❌ ERROR: {creds_file} not found")
        return False
    
    if token_file.exists():
        print("✅ google-sheets already authenticated (token.json exists)")
        return True
    
    SCOPES = [
        'https://www.googleapis.com/auth/spreadsheets',
        'https://www.googleapis.com/auth/drive'
    ]
    
    try:
        print("\n🔐 Starting OAuth Flow...\n")
        flow = InstalledAppFlow.from_client_secrets_file(str(creds_file), SCOPES)
        
        # Generate the auth URL
        auth_url, _ = flow.authorization_url(prompt='consent', access_type='offline')
        
        print("="*60)
        print("  AUTHORIZATION REQUIRED")
        print("="*60)
        print("\n1. Open this URL in your browser:\n")
        print(f"   {auth_url}\n")
        print("2. Log in with: lisa@linktrend.media")
        print("3. Approve the permissions")
        print("4. You'll be redirected to localhost (this will fail - that's ok)")
        print("5. Copy the ENTIRE redirect URL from your browser address bar")
        print("   (It starts with: http://localhost/?code=...)\n")
        
        redirect_url = input("Paste the redirect URL here: ").strip()
        
        # Extract the code from the redirect URL
        if "code=" in redirect_url:
            code = redirect_url.split("code=")[1].split("&")[0]
        else:
            print("❌ ERROR: Invalid redirect URL")
            return False
        
        # Exchange code for credentials
        flow.fetch_token(code=code)
        creds = flow.credentials
        
        # Save the credentials
        with open(token_file, 'w') as f:
            f.write(creds.to_json())
        
        print(f"\n✅ Token saved to {token_file}")
        print("✅ google-sheets authenticated successfully!")
        return True
        
    except Exception as e:
        print(f"\n❌ ERROR during OAuth: {e}")
        return False

def setup_gmail_integration():
    """Setup OAuth for gmail-integration MCP skill"""
    print("\n" + "="*60)
    print("  GMAIL INTEGRATION MCP - OAuth Setup")
    print("="*60)
    
    token_dir = Path.home() / "gmail_mcp_tokens"
    token_dir.mkdir(parents=True, exist_ok=True)
    
    token_file = token_dir / "tokens.json"
    
    if token_file.exists():
        print("✅ gmail-integration already authenticated")
        return True
    
    print("\n📋 Gmail integration will authenticate automatically")
    print("   when first started by OpenClaw.")
    print(f"\n   Token storage: {token_dir}")
    print("\n✅ Ready for first-run authentication")
    return True

def main():
    """Main setup flow"""
    print("\n" + "="*60)
    print("  GOOGLE WORKSPACE MCP SKILLS - OAuth Setup")
    print("  VPS-Friendly Authentication Script")
    print("="*60)
    
    results = {}
    
    # Setup each skill
    results['google-docs'] = setup_google_docs()
    results['google-sheets'] = setup_google_sheets()
    results['gmail-integration'] = setup_gmail_integration()
    
    # Summary
    print("\n" + "="*60)
    print("  SETUP SUMMARY")
    print("="*60 + "\n")
    
    for skill, success in results.items():
        status = "✅ Ready" if success else "⚠️  Needs Manual Setup"
        print(f"  {skill:20s} {status}")
    
    print("\n" + "="*60)
    print("\n📋 Next Steps:")
    print("   1. Restart OpenClaw: systemctl restart openclaw")
    print("   2. Test via Telegram: 'Lisa, create a Google Doc'")
    print("   3. Monitor logs: tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log")
    print("\n" + "="*60 + "\n")
    
    # Exit with appropriate code
    sys.exit(0 if all(results.values()) else 1)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  Setup interrupted by user")
        sys.exit(1)
