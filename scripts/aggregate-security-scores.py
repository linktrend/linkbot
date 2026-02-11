#!/usr/bin/env python3
"""
Security Score Aggregator
Combines results from multiple security scanners into a single risk score

Usage: python3 aggregate-security-scores.py --skill-path <path> --output <file>
"""

import json
import sys
import argparse
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any

# Severity weights
SEVERITY_WEIGHTS = {
    "CRITICAL": 25,
    "HIGH": 15,
    "MEDIUM": 8,
    "LOW": 3,
    "INFO": 1,
    "SAFE": 0
}

class SecurityAggregator:
    def __init__(self, skill_path: str):
        self.skill_path = Path(skill_path)
        self.skill_name = self.skill_path.name
        self.reports = {}
        self.total_risk = 0
        self.all_findings = []
        
    def load_report(self, report_name: str, filepath: Path) -> Dict[str, Any]:
        """Load a JSON report file"""
        try:
            if not filepath.exists():
                return {"status": "not_found", "risk_score": 0, "findings": []}
            
            with open(filepath, 'r') as f:
                data = json.load(f)
                return data
        except Exception as e:
            print(f"Warning: Could not load {report_name}: {e}", file=sys.stderr)
            return {"status": "error", "risk_score": 0, "findings": [], "error": str(e)}
    
    def load_all_reports(self):
        """Load all available security reports"""
        # Cisco Skill Scanner report
        cisco_report = self.find_cisco_report()
        if cisco_report:
            self.reports['cisco'] = self.load_report('cisco', cisco_report)
        
        # Semgrep report
        semgrep_file = self.skill_path / "semgrep-report.json"
        self.reports['semgrep'] = self.load_report('semgrep', semgrep_file)
        
        # TruffleHog report
        trufflehog_file = self.skill_path / "trufflehog-report.json"
        self.reports['trufflehog'] = self.load_report('trufflehog', trufflehog_file)
        
        # AI Analysis report
        ai_file = self.skill_path / "ai-security-analysis.json"
        self.reports['ai_analysis'] = self.load_report('ai_analysis', ai_file)
        
        # Provenance report
        provenance_file = self.skill_path / "provenance-report.json"
        self.reports['provenance'] = self.load_report('provenance', provenance_file)
    
    def find_cisco_report(self) -> Path:
        """Find the most recent Cisco scanner report"""
        scan_reports_dir = self.skill_path.parent.parent / "skills" / "scan-reports"
        if not scan_reports_dir.exists():
            return None
        
        # Find reports matching this skill
        pattern = f"{self.skill_name}-*.json"
        reports = list(scan_reports_dir.glob(pattern))
        
        if not reports:
            return None
        
        # Return most recent
        return max(reports, key=lambda p: p.stat().st_mtime)
    
    def calculate_cisco_risk(self) -> int:
        """Calculate risk from Cisco scanner"""
        cisco = self.reports.get('cisco', {})
        
        # Try to extract risk score
        risk = cisco.get('risk_score', 0)
        if risk:
            return int(risk)
        
        # Calculate from findings
        findings = cisco.get('findings', [])
        score = 0
        for finding in findings:
            severity = finding.get('severity', 'LOW').upper()
            score += SEVERITY_WEIGHTS.get(severity, 3)
        
        return min(score, 100)
    
    def calculate_semgrep_risk(self) -> int:
        """Calculate risk from Semgrep SAST"""
        semgrep = self.reports.get('semgrep', {})
        
        if semgrep.get('status') == 'not_found':
            return 0
        
        results = semgrep.get('results', [])
        score = 0
        
        for result in results:
            # Semgrep severity mapping
            severity = result.get('extra', {}).get('severity', 'WARNING').upper()
            
            if severity == 'ERROR':
                score += 15
            elif severity == 'WARNING':
                score += 8
            else:
                score += 3
        
        return min(score, 50)
    
    def calculate_trufflehog_risk(self) -> int:
        """Calculate risk from TruffleHog secrets scan"""
        trufflehog = self.reports.get('trufflehog', {})
        
        if trufflehog.get('status') == 'not_found':
            return 0
        
        # TruffleHog findings are critical (hardcoded secrets)
        detectors = trufflehog.get('DetectorResults', [])
        
        if detectors and len(detectors) > 0:
            # Any secret = automatic high risk
            return min(len(detectors) * 20, 100)
        
        return 0
    
    def calculate_ai_risk(self) -> int:
        """Calculate risk from AI analysis"""
        ai = self.reports.get('ai_analysis', {})
        
        return ai.get('risk_score', 0)
    
    def calculate_provenance_risk(self) -> int:
        """Calculate risk from provenance check"""
        prov = self.reports.get('provenance', {})
        
        return prov.get('risk_score', 0)
    
    def aggregate_all(self) -> Dict[str, Any]:
        """Aggregate all security scores"""
        self.load_all_reports()
        
        # Calculate individual risks
        cisco_risk = self.calculate_cisco_risk()
        semgrep_risk = self.calculate_semgrep_risk()
        trufflehog_risk = self.calculate_trufflehog_risk()
        ai_risk = self.calculate_ai_risk()
        provenance_risk = self.calculate_provenance_risk()
        
        # Weighted aggregation
        # Cisco (40%) + AI (25%) + TruffleHog (20%) + Semgrep (10%) + Provenance (5%)
        total_risk = int(
            cisco_risk * 0.40 +
            ai_risk * 0.25 +
            trufflehog_risk * 0.20 +
            semgrep_risk * 0.10 +
            provenance_risk * 0.05
        )
        
        # Determine verdict
        if total_risk <= 60:
            verdict = "APPROVED"
            color = "green"
        elif total_risk <= 80:
            verdict = "BORDERLINE"
            color = "yellow"
        else:
            verdict = "REJECTED"
            color = "red"
        
        # Collect all findings
        all_findings = []
        for scanner, report in self.reports.items():
            findings = report.get('findings', [])
            for finding in findings:
                finding['source_scanner'] = scanner
                all_findings.append(finding)
        
        return {
            "skill_name": self.skill_name,
            "skill_path": str(self.skill_path),
            "scan_timestamp": datetime.utcnow().isoformat() + "Z",
            "verdict": verdict,
            "total_risk_score": total_risk,
            "risk_breakdown": {
                "cisco_scanner": cisco_risk,
                "ai_analysis": ai_risk,
                "trufflehog_secrets": trufflehog_risk,
                "semgrep_sast": semgrep_risk,
                "provenance": provenance_risk
            },
            "findings_count": len(all_findings),
            "findings": all_findings,
            "scanners_run": list(self.reports.keys()),
            "recommendation": self._get_recommendation(verdict, total_risk)
        }
    
    def _get_recommendation(self, verdict: str, risk: int) -> str:
        """Get human-readable recommendation"""
        if verdict == "APPROVED":
            return f"Safe to use - Risk score {risk}/100"
        elif verdict == "BORDERLINE":
            return f"Manual review recommended - Risk score {risk}/100"
        else:
            return f"Do not use - Risk score {risk}/100"


def main():
    parser = argparse.ArgumentParser(description='Aggregate security scan results')
    parser.add_argument('--skill-path', required=True, help='Path to skill directory')
    parser.add_argument('--output', required=True, help='Output JSON file')
    
    args = parser.parse_args()
    
    # Run aggregation
    aggregator = SecurityAggregator(args.skill_path)
    result = aggregator.aggregate_all()
    
    # Save result
    with open(args.output, 'w') as f:
        json.dump(result, f, indent=2)
    
    # Print summary
    print(f"\nSkill: {result['skill_name']}")
    print(f"Verdict: {result['verdict']}")
    print(f"Risk Score: {result['total_risk_score']}/100")
    print(f"Findings: {result['findings_count']}")
    print(f"Recommendation: {result['recommendation']}")
    print(f"\nReport saved: {args.output}\n")
    
    # Exit code based on verdict
    if result['verdict'] == "APPROVED":
        sys.exit(0)
    elif result['verdict'] == "BORDERLINE":
        sys.exit(2)  # Special exit code for borderline
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
