---
name: document-generator
description: Create, edit, and analyze professional documents including Word (.docx), Excel (.xlsx), PowerPoint (.pptx), and PDF files. Supports templates, reports, forms, and complex formatting.
license: Proprietary (Anthropic). See LICENSE.txt for complete terms
source: https://github.com/anthropics/skills
version: 1.0.0
last_updated: 2026-02-09
supports_subagent: true
environment_variables:
  - name: NONE
    description: No API keys or secrets required - uses local libraries
    required: false
---

# Document Generator Skill

## Overview

This skill combines Anthropic's official document creation skills for:
- **PDF**: Extract text, create PDFs, handle forms, add watermarks
- **DOCX**: Create and edit Word documents with formatting, tables, images
- **XLSX**: Create and manipulate Excel spreadsheets
- **PPTX**: Create and edit PowerPoint presentations

## Installation

```bash
# Install Python dependencies
pip install pypdf pdfplumber reportlab python-docx openpyxl python-pptx

# Install Node.js dependencies for advanced DOCX
npm install -g docx

# Install command-line tools (Linux/Mac)
sudo apt-get install poppler-utils qpdf libreoffice
```

## Key Features

### PDF Operations
- Extract text and tables from PDFs
- Merge and split PDFs
- Add watermarks and password protection
- Fill PDF forms
- OCR scanned documents

### Word Documents (DOCX)
- Create professional documents with headers/footers
- Tables with borders and shading
- Images and page breaks
- Table of contents
- Track changes and comments

### Excel Spreadsheets (XLSX)
- Create workbooks with multiple sheets
- Formulas and calculations
- Charts and graphs
- Formatting and styling

### PowerPoint (PPTX)
- Create presentations with slides
- Text, images, and shapes
- Slide transitions
- Speaker notes

## Usage Examples

### Create a PDF Report

```python
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph
from reportlab.lib.styles import getSampleStyleSheet

doc = SimpleDocTemplate("report.pdf", pagesize=letter)
styles = getSampleStyleSheet()
story = []

title = Paragraph("Quarterly Report", styles['Title'])
story.append(title)

doc.build(story)
```

### Create a Word Document

```javascript
const { Document, Packer, Paragraph, TextRun } = require('docx');
const fs = require('fs');

const doc = new Document({
  sections: [{
    properties: {
      page: {
        size: { width: 12240, height: 15840 }
      }
    },
    children: [
      new Paragraph({
        children: [new TextRun({ text: "Hello World", bold: true })]
      })
    ]
  }]
});

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync("document.docx", buffer);
});
```

## Sub-Agent Execution Support

**YES** - This skill supports sub-agent execution:
- PDF operations can be delegated to specialized PDF agents
- DOCX creation can be handled by document formatting agents
- Spreadsheet calculations can be performed by data analysis agents
- Template generation can be split across multiple agents

## Configuration

No environment variables or API keys required. All operations use local libraries.

## Security Notes

- All document processing happens locally
- No data sent to external services
- Validate user-provided content before including in documents
- Be cautious with file paths - ensure proper sandboxing

## Performance Considerations

- Large PDFs (>100MB) may take time to process
- OCR operations are CPU-intensive
- DOCX with many images increases file size significantly
- Consider streaming for very large documents

## Troubleshooting

### LibreOffice not found
```bash
# Install LibreOffice for PDF conversion
sudo apt-get install libreoffice
```

### Missing fonts in PDFs
```bash
# Install Microsoft fonts
sudo apt-get install ttf-mscorefonts-installer
```

### Node.js docx module issues
```bash
npm install -g docx --force
```

## Source Files

This skill is sourced from Anthropic's official skills repository:
- PDF: `skills/pdf/SKILL.md`
- DOCX: `skills/docx/SKILL.md`
- XLSX: `skills/xlsx/SKILL.md`
- PPTX: `skills/pptx/SKILL.md`

Repository: https://github.com/anthropics/skills
