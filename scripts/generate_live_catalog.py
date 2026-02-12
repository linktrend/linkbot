#!/usr/bin/env python3
"""
Generate a live capability catalog for Lisa from the VPS runtime state.

Outputs (repo root):
  - SKILLS_AND_AGENTS_CATALOG.json
  - LISA_LIVE_CAPABILITY_CATALOG_YYYY-MM-DD.json
  - LISA_LIVE_CAPABILITY_CATALOG_YYYY-MM-DD.md

This intentionally avoids pulling any secret material from the VPS. It reads:
  - openclaw skills list --json
  - openclaw agents list --json
  - mcporter list --json
and combines them with lightweight repo metadata (agent + wrapper descriptions).
"""

from __future__ import annotations

import datetime as _dt
import json
import os
import re
import subprocess
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_VPS_HOST = os.environ.get("LINKBOT_VPS_HOST", "178.128.77.125")
DEFAULT_VPS_USER = os.environ.get("LINKBOT_VPS_USER", "root")


def _run(cmd: List[str]) -> str:
    return subprocess.check_output(cmd, text=True, stderr=subprocess.STDOUT)


def _ssh(host: str, user: str, remote_cmd: str) -> str:
    # BatchMode avoids hanging on password prompts.
    return _run(
        [
            "ssh",
            "-o",
            "BatchMode=yes",
            "-o",
            "ConnectTimeout=10",
            f"{user}@{host}",
            remote_cmd,
        ]
    )


def _parse_frontmatter(md_text: str) -> Dict[str, str]:
    """
    Parse simple YAML-ish frontmatter:
      ---
      key: value
      ---
    Returns only top-level scalar key/value pairs.
    """
    if not md_text.startswith("---"):
        return {}
    parts = md_text.split("\n---\n", 1)
    if len(parts) != 2:
        return {}
    front = parts[0].strip().splitlines()[1:]  # drop first ---
    out: Dict[str, str] = {}
    for line in front:
        line = line.rstrip()
        if not line or line.lstrip().startswith("#"):
            continue
        m = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if not m:
            continue
        k, v = m.group(1), m.group(2).strip()
        # strip quotes if present
        if (v.startswith('"') and v.endswith('"')) or (v.startswith("'") and v.endswith("'")):
            v = v[1:-1]
        out[k] = v
    return out


def _load_repo_agents() -> Dict[str, Dict[str, str]]:
    agents_dir = REPO_ROOT / "agents" / "antigravity"
    out: Dict[str, Dict[str, str]] = {}
    if not agents_dir.exists():
        return out
    for p in sorted(agents_dir.glob("*.md")):
        text = p.read_text(encoding="utf-8", errors="replace")
        fm = _parse_frontmatter(text)
        agent_id = fm.get("name") or p.stem
        out[agent_id] = {
            "id": agent_id,
            "description": fm.get("description", "").strip(),
            "path": str(p.relative_to(REPO_ROOT)),
        }
    return out


def _load_repo_wrapper_descriptions() -> Dict[str, Dict[str, str]]:
    wrappers_dir = REPO_ROOT / "skills" / "mcp-wrappers"
    out: Dict[str, Dict[str, str]] = {}
    if not wrappers_dir.exists():
        return out
    for p in sorted(wrappers_dir.glob("*/SKILL.md")):
        text = p.read_text(encoding="utf-8", errors="replace")
        fm = _parse_frontmatter(text)
        name = fm.get("name") or p.parent.name
        out[name] = {
            "name": name,
            "description": fm.get("description", "").strip(),
            "path": str(p.relative_to(REPO_ROOT)),
        }
    return out


def _missing_is_empty(missing: Dict[str, Any]) -> bool:
    if not isinstance(missing, dict):
        return True
    for k in ["bins", "anyBins", "env", "config", "os"]:
        v = missing.get(k, [])
        if isinstance(v, list) and len(v) > 0:
            return False
    return True


def _skill_status(skill: Dict[str, Any]) -> str:
    disabled = bool(skill.get("disabled"))
    eligible = bool(skill.get("eligible"))
    blocked = bool(skill.get("blockedByAllowlist"))
    missing = skill.get("missing") or {}
    if disabled:
        return "disabled_but_installed"
    if eligible and (not blocked) and _missing_is_empty(missing):
        return "enabled_and_configured"
    if blocked:
        return "enabled_but_blocked_by_exec_allowlist"
    if not _missing_is_empty(missing):
        return "enabled_but_unavailable_missing_prereqs"
    return "enabled_but_unavailable"


def _mcp_status(server: Dict[str, Any]) -> str:
    s = (server.get("status") or "").lower()
    if s == "ok":
        return "enabled_and_configured"
    if s == "auth":
        return "enabled_but_needs_auth"
    if s in {"offline", "http"}:
        return "unavailable"
    if s == "error":
        return "error"
    return "unknown"


def main() -> int:
    host = DEFAULT_VPS_HOST
    user = DEFAULT_VPS_USER

    # Pull live runtime data (no secrets).
    skills_raw = _ssh(host, user, "/root/openclaw-bot/openclaw.mjs skills list --json")
    agents_raw = _ssh(host, user, "/root/openclaw-bot/openclaw.mjs agents list --json")
    mcp_raw = _ssh(host, user, "cd /root/linkbot && mcporter --config config/mcporter.json list --json")

    skills_doc = json.loads(skills_raw)
    agents_doc = json.loads(agents_raw)
    mcp_doc = json.loads(mcp_raw)

    repo_agents = _load_repo_agents()
    wrapper_meta = _load_repo_wrapper_descriptions()

    now = _dt.datetime.now(_dt.timezone.utc)
    date_str = now.date().isoformat()

    # MCP servers catalog
    mcp_servers: List[Dict[str, Any]] = []
    for s in mcp_doc.get("servers", []):
        name = s.get("name", "")
        meta = wrapper_meta.get(name, {})
        status = _mcp_status(s)
        mcp_servers.append(
            {
                "name": name,
                "enabled": status.startswith("enabled"),
                "installed": True,
                "configured": status == "enabled_and_configured",
                "status": status,
                "description": meta.get("description") or f"MCP server: {name}",
                "example": f'Lisa, use "{name}" to help with this task.',
                "verification": f'mcporter list status="{s.get("status")}" on VPS ({date_str}).',
                "tools_count": len(s.get("tools") or []),
            }
        )
    mcp_servers.sort(key=lambda x: x["name"])

    # Agents catalog: union(repo agents, runtime agents)
    runtime_agents_by_id: Dict[str, Dict[str, Any]] = {a.get("id"): a for a in agents_doc}
    agent_ids = sorted(set(repo_agents.keys()) | set(runtime_agents_by_id.keys()))
    agents: List[Dict[str, Any]] = []
    for aid in agent_ids:
        ra = runtime_agents_by_id.get(aid)
        repo = repo_agents.get(aid, {})
        enabled = ra is not None
        agents.append(
            {
                "id": aid,
                "enabled": enabled,
                "installed_in_repo": bool(repo),
                "installed_in_runtime": enabled,
                "configured": enabled,
                "status": "enabled_and_configured" if enabled else "installed_but_disabled",
                "description": (
                    repo.get("description")
                    or (f"Lisa runtime agent: {aid}" if enabled else f"Agent persona available: {aid}")
                ),
                "example": f'Lisa, use the "{aid}" agent for this task.',
                "workspace": ra.get("workspace") if ra else None,
                "model": ra.get("model") if ra else None,
                "repo_path": repo.get("path") or None,
            }
        )
    agents.sort(key=lambda x: (0 if x["id"] == "main" else 1, x["id"]))

    # Skills catalog
    skills: List[Dict[str, Any]] = []
    for sk in skills_doc.get("skills", []):
        status = _skill_status(sk)
        skills.append(
            {
                "name": sk.get("name"),
                "enabled": not bool(sk.get("disabled")),
                "installed": True,
                "configured": status == "enabled_and_configured",
                "status": status,
                "description": sk.get("description", ""),
                "example": f'Lisa, use "{sk.get("name")}" for this task.',
                "emoji": sk.get("emoji"),
                "source": sk.get("source"),
                "bundled": sk.get("bundled"),
                "homepage": sk.get("homepage"),
                "blockedByAllowlist": bool(sk.get("blockedByAllowlist")),
                "missing": sk.get("missing") or {},
            }
        )
    skills.sort(key=lambda x: x["name"])

    # Summary counts
    skills_total = len(skills)
    skills_enabled = sum(1 for s in skills if s["enabled"])
    skills_disabled = sum(1 for s in skills if not s["enabled"])
    skills_enabled_configured = sum(1 for s in skills if s["status"] == "enabled_and_configured")
    skills_unavailable = sum(1 for s in skills if "unavailable" in s["status"] or "blocked" in s["status"])

    agents_total = len(agents)
    agents_enabled = sum(1 for a in agents if a["enabled"])
    agents_disabled = agents_total - agents_enabled

    mcp_total = len(mcp_servers)
    mcp_enabled_configured = sum(1 for s in mcp_servers if s["status"] == "enabled_and_configured")

    catalog: Dict[str, Any] = {
        "catalog_version": "2.1.0-live-runtime",
        "generated_at": now.isoformat(),
        "authoritative_runtime": "/root/.openclaw/openclaw.json",
        "runtime_host": host,
        "summary": {
            "skills_total_runtime": skills_total,
            "skills_enabled": skills_enabled,
            "skills_disabled_but_installed": skills_disabled,
            "skills_enabled_and_configured": skills_enabled_configured,
            "skills_unavailable_or_blocked": skills_unavailable,
            "agents_total_listed": agents_total,
            "agents_enabled_and_configured": agents_enabled,
            "agents_installed_but_disabled": agents_disabled,
            "mcp_total_listed": mcp_total,
            "mcp_enabled_and_configured": mcp_enabled_configured,
        },
        "mcp_servers": mcp_servers,
        "agents": agents,
        "skills": skills,
        "notes": [
            "This catalog is generated from live VPS runtime output. It does not copy secrets.",
            "If a skill is 'blocked_by_exec_allowlist', it exists but OpenClaw is intentionally preventing shell execution until explicitly allowlisted.",
        ],
    }

    # Write JSON outputs
    (REPO_ROOT / "SKILLS_AND_AGENTS_CATALOG.json").write_text(
        json.dumps(catalog, indent=2, sort_keys=False) + "\n", encoding="utf-8"
    )
    (REPO_ROOT / f"LISA_LIVE_CAPABILITY_CATALOG_{date_str}.json").write_text(
        json.dumps(catalog, indent=2, sort_keys=False) + "\n", encoding="utf-8"
    )

    # Write a lightweight Markdown view (human-friendly)
    md_lines: List[str] = []
    md_lines.append(f"# Lisa Live Capability Catalog (Updated {date_str})")
    md_lines.append("")
    md_lines.append("Generated from live VPS runtime plus repo metadata.")
    md_lines.append("")
    md_lines.append("## Summary")
    md_lines.append("")
    for k, v in catalog["summary"].items():
        md_lines.append(f"- {k}: {v}")
    md_lines.append("")
    md_lines.append("## MCP Servers")
    md_lines.append("")
    md_lines.append("| Name | Status | Description | Example | Verification |")
    md_lines.append("|---|---|---|---|---|")
    for s in mcp_servers:
        md_lines.append(
            f'| {s["name"]} | {s["status"]} | {s["description"]} | {s["example"]} | {s["verification"]} |'
        )
    md_lines.append("")
    md_lines.append("## Agents")
    md_lines.append("")
    md_lines.append("| ID | Status | Description | Example | Model |")
    md_lines.append("|---|---|---|---|---|")
    for a in agents:
        model = a.get("model") or ""
        md_lines.append(
            f'| {a["id"]} | {a["status"]} | {a["description"]} | {a["example"]} | {model} |'
        )
    md_lines.append("")
    md_lines.append("## Skills (Runtime)")
    md_lines.append("")
    md_lines.append("| Name | Status | Description | Example | Missing |")
    md_lines.append("|---|---|---|---|---|")
    for s in skills:
        missing = ""
        m = s.get("missing") or {}
        if not _missing_is_empty(m):
            parts = []
            for k in ["bins", "env", "os", "config"]:
                if m.get(k):
                    parts.append(f"{k}:{len(m.get(k))}")
            missing = ", ".join(parts)
        md_lines.append(
            f'| {s["name"]} | {s["status"]} | {s["description"]} | {s["example"]} | {missing} |'
        )
    md_lines.append("")

    (REPO_ROOT / f"LISA_LIVE_CAPABILITY_CATALOG_{date_str}.md").write_text(
        "\n".join(md_lines) + "\n", encoding="utf-8"
    )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

