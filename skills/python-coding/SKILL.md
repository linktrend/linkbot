---
name: python-coding
description: Python coding skill for file operations, code generation, script creation, and data processing. Uses MCP filesystem server for secure file access.
license: MIT
source: https://github.com/MarcusJellinghaus/mcp_server_filesystem
version: 1.0.0
last_updated: 2026-02-09
supports_subagent: true
environment_variables:
  - name: PROJECT_DIRECTORY
    description: Root directory for file operations (security boundary)
    required: true
    example: /Users/username/projects/myproject
---

# Python Coding Skill

## Overview

This skill provides Python coding capabilities with secure filesystem access via the MCP (Model Context Protocol) server. It enables:
- Code generation and refactoring
- File operations (read, write, edit, delete)
- Data processing and analysis
- Script automation
- Secure sandboxed execution

## Installation

### 1. Install MCP Filesystem Server

```bash
# Clone the repository
git clone https://github.com/MarcusJellinghaus/mcp_server_filesystem.git
cd mcp_server_filesystem

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Configure MCP Server

Create or edit `~/.openclaw/config.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "python",
      "args": [
        "/path/to/mcp_server_filesystem/server.py",
        "--project-dir",
        "/Users/username/projects"
      ],
      "env": {
        "PROJECT_DIRECTORY": "/Users/username/projects"
      }
    }
  }
}
```

### 3. Verify Installation

```bash
# Test the MCP server
python server.py --project-dir /tmp/test
```

## Key Features

### File Operations
- **list_directory**: List files and directories
- **read_file**: Read file contents
- **write_file**: Write to files atomically
- **append_file**: Append content to existing files
- **delete_file**: Remove files safely
- **edit_file**: Pattern-based file editing

### Code Generation
- Generate Python scripts for automation
- Create data processing pipelines
- Build CLI tools
- Develop APIs and web services

### Data Processing
- Parse CSV, JSON, XML files
- Transform and clean data
- Generate reports
- Export to various formats

### Security Features
- Path validation (all operations contained in PROJECT_DIRECTORY)
- Atomic file writes
- Structured logging
- Error handling and validation

## Usage Examples

### List Directory Contents

```python
# Via MCP server
{
  "tool": "list_directory",
  "arguments": {
    "path": "."
  }
}
```

### Read and Process File

```python
# Via MCP server
{
  "tool": "read_file",
  "arguments": {
    "path": "data.csv"
  }
}

# Then process in Python
import csv
import io

csv_data = io.StringIO(file_content)
reader = csv.DictReader(csv_data)
for row in reader:
    print(row)
```

### Generate Python Script

```python
# Create a data processing script
script_content = '''
import pandas as pd

def process_data(input_file, output_file):
    """Process CSV data and generate report."""
    df = pd.read_csv(input_file)
    
    # Data transformations
    df['total'] = df['quantity'] * df['price']
    summary = df.groupby('category')['total'].sum()
    
    # Export results
    summary.to_csv(output_file)
    print(f"Report saved to {output_file}")

if __name__ == "__main__":
    process_data("input.csv", "report.csv")
'''

# Write via MCP
{
  "tool": "write_file",
  "arguments": {
    "path": "process_data.py",
    "content": script_content
  }
}
```

### Edit File with Pattern Matching

```python
# Edit configuration file
{
  "tool": "edit_file",
  "arguments": {
    "path": "config.py",
    "pattern": "DEBUG = False",
    "replacement": "DEBUG = True"
  }
}
```

## Sub-Agent Execution Support

**YES** - This skill strongly supports sub-agent execution:

### Use Cases
- **Code Review Agent**: Analyzes Python code for issues
- **Testing Agent**: Generates and runs unit tests
- **Refactoring Agent**: Improves code structure
- **Documentation Agent**: Creates docstrings and README files
- **Data Analysis Agent**: Processes files and generates insights

### Multi-Agent Pattern

```python
# Agent 1: Code Generation
generate_script("data_processor.py")

# Agent 2: Testing
create_tests("test_data_processor.py")

# Agent 3: Documentation
generate_docs("README.md")

# Agent 4: Code Review
review_and_suggest_improvements()
```

## Configuration

### Environment Variables

```bash
# Required
export PROJECT_DIRECTORY=/Users/username/projects

# Optional
export LOG_LEVEL=INFO
export MAX_FILE_SIZE=10485760  # 10MB
export ENABLE_DELETE=true
```

### OpenClaw Configuration

Add to `~/.openclaw/skills/python-coding/config.json`:

```json
{
  "name": "python-coding",
  "enabled": true,
  "mcp_server": "filesystem",
  "project_directory": "/Users/username/projects",
  "allowed_extensions": [".py", ".txt", ".csv", ".json", ".md"],
  "max_file_size_mb": 10
}
```

## Security Best Practices

1. **Always set PROJECT_DIRECTORY** - Restricts operations to specific path
2. **Validate user input** - Never trust file paths from users
3. **Use atomic writes** - Prevents partial file corruption
4. **Enable logging** - Track all file operations
5. **Limit file sizes** - Prevent resource exhaustion
6. **Restrict file types** - Only allow necessary extensions

## Performance Considerations

- **Large files**: Files >10MB may slow operations
- **Concurrent access**: MCP server handles one request at a time
- **Directory listings**: Deep recursion can be expensive
- **Pattern matching**: Complex regex may impact edit_file performance

## Troubleshooting

### MCP Server Not Starting

```bash
# Check Python version (requires 3.8+)
python --version

# Verify dependencies
pip install -r requirements.txt

# Check permissions
chmod +x server.py
```

### Path Validation Errors

```bash
# Ensure path is within PROJECT_DIRECTORY
# Absolute paths: /Users/username/projects/file.py ✓
# Relative paths: file.py ✓
# Outside project: /etc/passwd ✗
```

### File Not Found

```bash
# Check current directory
pwd

# List available files
python -c "from pathlib import Path; print(list(Path('.').glob('*')))"
```

## Integration with OpenClaw Model Routing

This skill works seamlessly with OpenClaw's per-skill model routing:

```json
{
  "skills": {
    "python-coding": {
      "model": "claude-3-5-haiku-20241022",
      "reason": "Cost-effective for code generation"
    }
  }
}
```

## Source Repository

- **GitHub**: https://github.com/MarcusJellinghaus/mcp_server_filesystem
- **Stars**: 42
- **License**: MIT
- **Language**: Python
- **Last Updated**: 2026-02

## Additional Resources

- MCP Specification: https://modelcontextprotocol.io
- Python Best Practices: https://docs.python-guide.org
- Anthropic MCP Guide: https://docs.anthropic.com/en/docs/agents-and-tools/mcp
