# Document Generator Skill Info

## Quick Reference

- **Name**: document-generator
- **Version**: 1.0.0
- **License**: Proprietary (Anthropic) - Source-available
- **Source**: https://github.com/anthropics/skills
- **Last Updated**: 2026-02-09
- **Stars**: 66,000+

## Status

- ⚠️ **NOT SCANNED** - Must scan with Cisco Skill Scanner before use
- ✅ Documented
- ⚠️ Not tested
- ⚠️ Not deployed

## Sub-Agent Execution

**✅ SUPPORTED**

This skill supports multi-agent execution:
- PDF Operations Agent
- DOCX Creation Agent
- Spreadsheet Agent
- Template Generation Agent

## Environment Variables

**None required** - All operations use local libraries

## Quick Install

```bash
# Install Python dependencies
pip install pypdf pdfplumber reportlab python-docx openpyxl python-pptx

# Install Node.js dependencies (for advanced DOCX)
npm install -g docx

# Install command-line tools (Linux/Mac)
sudo apt-get install poppler-utils qpdf libreoffice

# Or on macOS with Homebrew
brew install poppler qpdf
brew install --cask libreoffice
```

## OpenClaw Model

```json
{
  "document-generator": "claude-3-5-haiku-20241022"
}
```

## Cost Estimate

~$0.76/month for 50 operations

## Features

### PDF Operations
- Extract text and tables
- Merge and split PDFs
- Add watermarks
- Password protection
- Fill PDF forms
- OCR scanned documents

### Word Documents (DOCX)
- Create professional documents
- Headers, footers, tables
- Images and page breaks
- Table of contents
- Track changes and comments

### Excel Spreadsheets (XLSX)
- Create workbooks
- Formulas and calculations
- Charts and graphs
- Formatting and styling

### PowerPoint (PPTX)
- Create presentations
- Text, images, shapes
- Slide transitions
- Speaker notes

## Files

- `SKILL.md` - Complete documentation
- `SKILL_INFO.md` - This quick reference

## Security Notes

- All document processing happens locally
- No data sent to external services
- Validate user-provided content
- Ensure proper file path sandboxing
- No hardcoded secrets

## Source Files

This skill combines Anthropic's official skills:
- `skills/pdf/SKILL.md`
- `skills/docx/SKILL.md`
- `skills/xlsx/SKILL.md`
- `skills/pptx/SKILL.md`

## Next Steps

1. ⚠️ Scan with Cisco Skill Scanner
2. Install Python dependencies
3. Install Node.js dependencies (docx)
4. Install command-line tools (poppler, qpdf, libreoffice)
5. Test PDF extraction
6. Test DOCX creation
7. Deploy to VPS
