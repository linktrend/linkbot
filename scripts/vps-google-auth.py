#!/usr/bin/env python3
"""
VPS-friendly OAuth bootstrap for Google Workspace MCP servers.

Runs one OAuth consent flow and writes token artifacts for:
- google-docs
- google-sheets
- google-slides (future use)
- gmail-integration
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from urllib.parse import parse_qs, unquote, urlparse

try:
    from google_auth_oauthlib.flow import InstalledAppFlow
except Exception as exc:
    print(f"ERROR: missing dependency google-auth-oauthlib: {exc}", file=sys.stderr)
    print("Install with: pip install google-auth-oauthlib", file=sys.stderr)
    sys.exit(1)


ROOT = Path("/root/linkbot")
GOOGLE_DOCS_DIR = ROOT / "skills/shared/google-docs"
GOOGLE_SHEETS_DIR = ROOT / "skills/shared/google-sheets"
GOOGLE_SLIDES_DIR = ROOT / "skills/shared/google-slides"
GMAIL_DIR = ROOT / "skills/shared/gmail-integration"
HOME_GMAIL_TOKENS = Path.home() / "gmail_mcp_tokens" / "tokens.json"

DEFAULT_CREDENTIALS = GOOGLE_DOCS_DIR / "credentials.json"
PREFERRED_CREDENTIALS = Path("/root/.openclaw/secrets/google-oauth.json")

TOKEN_TARGETS = {
    "google-docs": GOOGLE_DOCS_DIR / "token.json",
    "google-sheets": GOOGLE_SHEETS_DIR / "token.json",
    "google-slides": GOOGLE_SLIDES_DIR / "token.json",
    "gmail-integration-project": GMAIL_DIR / "tokens.json",
    "gmail-integration-home": HOME_GMAIL_TOKENS,
}

SCOPES = [
    "https://www.googleapis.com/auth/gmail.readonly",
    "https://www.googleapis.com/auth/gmail.send",
    "https://www.googleapis.com/auth/gmail.modify",
    "https://www.googleapis.com/auth/calendar",
    "https://www.googleapis.com/auth/calendar.events",
    "https://www.googleapis.com/auth/drive.file",
    "https://www.googleapis.com/auth/documents",
    "https://www.googleapis.com/auth/spreadsheets",
    "https://www.googleapis.com/auth/presentations",
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/userinfo.profile",
    "openid",
]


def write_json(path: Path, payload: dict, mode: int = 0o600) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    path.chmod(mode)


def reset_existing_tokens() -> None:
    for _, token_path in TOKEN_TARGETS.items():
        if token_path.exists():
            token_path.unlink()


def parse_auth_code(redirect_url: str) -> str:
    parsed = urlparse(redirect_url)
    query = parse_qs(parsed.query)
    raw_code = query.get("code", [None])[0]
    if not raw_code:
        raise ValueError("No 'code' parameter found in redirect URL.")
    return unquote(raw_code)


def run_oauth_flow(credentials_path: Path, redirect_url_override: str | None = None):
    creds_blob = json.loads(credentials_path.read_text(encoding="utf-8"))
    key = creds_blob.get("installed") or creds_blob.get("web") or {}
    redirect_uris = key.get("redirect_uris") or ["http://localhost"]
    redirect_uri = redirect_uris[0]

    flow = InstalledAppFlow.from_client_secrets_file(
        str(credentials_path),
        SCOPES,
        redirect_uri=redirect_uri,
    )
    auth_url, _ = flow.authorization_url(
        access_type="offline",
        prompt="consent",
    )

    print("\n" + "=" * 72)
    print("OPEN THIS URL IN YOUR LOCAL BROWSER")
    print("=" * 72)
    print(f"redirect_uri={redirect_uri}")
    print(auth_url)
    print("\nAfter approval, copy the FULL redirect URL and paste it below.")
    print("It usually looks like: http://localhost/?code=...&scope=...")
    print("=" * 72 + "\n")

    if redirect_url_override:
        redirect_url = redirect_url_override.strip()
    else:
        redirect_url = input("Paste redirect URL: ").strip()
    code = parse_auth_code(redirect_url)
    flow.fetch_token(code=code)
    return flow.credentials


def save_tokens(credentials) -> None:
    oauth_token = json.loads(credentials.to_json())

    # Docs / Sheets / Slides servers can consume standard OAuth authorized-user token JSON.
    write_json(TOKEN_TARGETS["google-docs"], oauth_token)
    write_json(TOKEN_TARGETS["google-sheets"], oauth_token)
    write_json(TOKEN_TARGETS["google-slides"], oauth_token)

    # Gmail MCP expects this field layout in tokens.json.
    gmail_token = {
        "token": credentials.token,
        "refresh_token": credentials.refresh_token,
        "token_uri": credentials.token_uri,
        "client_id": credentials.client_id,
        "client_secret": credentials.client_secret,
        "scopes": credentials.scopes,
        "expiry": credentials.expiry.isoformat() if credentials.expiry else None,
    }
    write_json(TOKEN_TARGETS["gmail-integration-project"], gmail_token)
    write_json(TOKEN_TARGETS["gmail-integration-home"], gmail_token)


def print_summary() -> None:
    print("\n" + "=" * 72)
    print("TOKEN WRITE SUMMARY")
    print("=" * 72)
    for name, path in TOKEN_TARGETS.items():
        status = "OK" if path.exists() else "MISSING"
        print(f"{name:26s} {status:8s} {path}")
    print("=" * 72)


def parse_args() -> argparse.Namespace:
    default_credentials = str(PREFERRED_CREDENTIALS if PREFERRED_CREDENTIALS.exists() else DEFAULT_CREDENTIALS)
    parser = argparse.ArgumentParser(description="Bootstrap Google OAuth tokens for MCP servers.")
    parser.add_argument(
        "--credentials",
        default=default_credentials,
        help=f"OAuth client credentials JSON path (default: {default_credentials})",
    )
    parser.add_argument(
        "--reset",
        action="store_true",
        help="Delete existing token artifacts before running OAuth.",
    )
    parser.add_argument(
        "--redirect-url",
        default="",
        help="Optional full redirect URL to run non-interactively.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    credentials_path = Path(args.credentials)

    if not credentials_path.exists():
        print(f"ERROR: credentials file not found: {credentials_path}", file=sys.stderr)
        return 1

    if args.reset:
        reset_existing_tokens()

    try:
        creds = run_oauth_flow(credentials_path, args.redirect_url or None)
    except KeyboardInterrupt:
        print("\nInterrupted by user.")
        return 1
    except Exception as exc:
        print(f"\nERROR: OAuth flow failed: {exc}", file=sys.stderr)
        return 1

    if not creds.refresh_token:
        print(
            "ERROR: refresh_token was not returned. Re-run with --reset and ensure prompt=consent.",
            file=sys.stderr,
        )
        return 1

    save_tokens(creds)
    print_summary()

    print("\nNext steps:")
    print("1. Validate server registration: mcporter --config /root/linkbot/config/mcporter.json list")
    print("2. Restart bot runtime: systemctl restart openclaw")
    print("3. Smoke test docs/sheets/gmail through Telegram prompts.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
