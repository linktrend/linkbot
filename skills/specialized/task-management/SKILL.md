---
name: task-management
description: Comprehensive task and project management skill for to-do lists, project tracking, task prioritization, and productivity workflows. Supports local storage and integration with external services.
license: MIT
source: Community aggregation (OpenClaw skills: pndr, idea-coach, quests)
version: 1.0.0
last_updated: 2026-02-09
supports_subagent: true
environment_variables:
  - name: TASKS_DB_PATH
    description: Path to local tasks database file
    required: false
    default: ~/.openclaw/data/tasks.json
  - name: GITHUB_TOKEN
    description: GitHub token for GitHub issues integration (optional)
    required: false
---

# Task Management Skill

## Overview

This skill provides comprehensive task and project management capabilities:
- Create, read, update, and delete tasks
- Organize tasks with projects, tags, and priorities
- Track progress and completion
- Set due dates and reminders
- Integrate with GitHub issues (optional)
- Export tasks to various formats
- Support for GTD (Getting Things Done) methodology

## Installation

### 1. Install Dependencies

```bash
# Python dependencies
pip install python-dateutil pyyaml

# Optional: GitHub integration
pip install PyGithub

# Create data directory
mkdir -p ~/.openclaw/data
```

### 2. Initialize Task Database

```bash
# Create initial tasks.json
cat > ~/.openclaw/data/tasks.json << 'EOF'
{
  "tasks": [],
  "projects": [],
  "tags": [],
  "metadata": {
    "version": "1.0.0",
    "created": "2026-02-09",
    "last_modified": "2026-02-09"
  }
}
EOF
```

## Key Features

### Task Operations
- **Create**: Add new tasks with title, description, priority
- **Read**: List tasks with filters (status, project, tag, priority)
- **Update**: Modify task properties
- **Delete**: Remove completed or obsolete tasks
- **Complete**: Mark tasks as done

### Organization
- **Projects**: Group related tasks
- **Tags**: Categorize tasks (#work, #personal, #urgent)
- **Priorities**: High, Medium, Low, Critical
- **Due Dates**: Set deadlines with reminders
- **Dependencies**: Link tasks with prerequisites

### Workflows
- **GTD (Getting Things Done)**: Inbox, Next Actions, Waiting For, Someday
- **Kanban**: To Do, In Progress, Done
- **Eisenhower Matrix**: Urgent/Important quadrants
- **SMART Goals**: Specific, Measurable, Achievable, Relevant, Time-bound

### Integrations
- **GitHub Issues**: Sync tasks with GitHub
- **Markdown**: Export to TODO.md files
- **JSON**: Programmatic access
- **Calendar**: Export to iCal format

## Usage Examples

### Create a Task

```python
import json
from datetime import datetime, timedelta

def create_task(title, description="", priority="medium", project=None, tags=None, due_date=None):
    """Create a new task."""
    with open(os.path.expanduser("~/.openclaw/data/tasks.json"), "r+") as f:
        data = json.load(f)
        
        task = {
            "id": str(uuid.uuid4()),
            "title": title,
            "description": description,
            "priority": priority,
            "status": "todo",
            "project": project,
            "tags": tags or [],
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat(),
            "due_date": due_date,
            "completed_at": None
        }
        
        data["tasks"].append(task)
        data["metadata"]["last_modified"] = datetime.now().isoformat()
        
        f.seek(0)
        json.dump(data, f, indent=2)
        f.truncate()
    
    return task

# Example usage
task = create_task(
    title="Research OpenClaw skills",
    description="Find and document task management skills from ClawHub",
    priority="high",
    project="LiNKbot",
    tags=["research", "documentation"],
    due_date=(datetime.now() + timedelta(days=2)).isoformat()
)
```

### List Tasks with Filters

```python
def list_tasks(status=None, project=None, tag=None, priority=None):
    """List tasks with optional filters."""
    with open(os.path.expanduser("~/.openclaw/data/tasks.json"), "r") as f:
        data = json.load(f)
        tasks = data["tasks"]
    
    # Apply filters
    if status:
        tasks = [t for t in tasks if t["status"] == status]
    if project:
        tasks = [t for t in tasks if t.get("project") == project]
    if tag:
        tasks = [t for t in tasks if tag in t.get("tags", [])]
    if priority:
        tasks = [t for t in tasks if t.get("priority") == priority]
    
    # Sort by priority and due date
    priority_order = {"critical": 0, "high": 1, "medium": 2, "low": 3}
    tasks.sort(key=lambda t: (
        priority_order.get(t.get("priority", "medium"), 2),
        t.get("due_date") or "9999-12-31"
    ))
    
    return tasks

# Example usage
high_priority_tasks = list_tasks(priority="high", status="todo")
for task in high_priority_tasks:
    print(f"- [{task['priority'].upper()}] {task['title']}")
```

### Update Task Status

```python
def update_task_status(task_id, new_status):
    """Update task status (todo, in_progress, waiting, done)."""
    with open(os.path.expanduser("~/.openclaw/data/tasks.json"), "r+") as f:
        data = json.load(f)
        
        for task in data["tasks"]:
            if task["id"] == task_id:
                task["status"] = new_status
                task["updated_at"] = datetime.now().isoformat()
                
                if new_status == "done":
                    task["completed_at"] = datetime.now().isoformat()
                
                break
        
        data["metadata"]["last_modified"] = datetime.now().isoformat()
        
        f.seek(0)
        json.dump(data, f, indent=2)
        f.truncate()
    
    return True

# Example usage
update_task_status("task-123", "in_progress")
```

### Complete a Task

```python
def complete_task(task_id):
    """Mark a task as complete."""
    return update_task_status(task_id, "done")

# Example usage
complete_task("task-123")
```

### Export to Markdown

```python
def export_to_markdown(output_path):
    """Export tasks to a Markdown TODO file."""
    with open(os.path.expanduser("~/.openclaw/data/tasks.json"), "r") as f:
        data = json.load(f)
    
    tasks_by_project = {}
    for task in data["tasks"]:
        project = task.get("project") or "Inbox"
        if project not in tasks_by_project:
            tasks_by_project[project] = []
        tasks_by_project[project].append(task)
    
    with open(output_path, "w") as f:
        f.write("# Tasks\n\n")
        f.write(f"Last updated: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n\n")
        
        for project, tasks in sorted(tasks_by_project.items()):
            f.write(f"## {project}\n\n")
            
            for task in tasks:
                checkbox = "x" if task["status"] == "done" else " "
                priority_emoji = {
                    "critical": "🔴",
                    "high": "🟠",
                    "medium": "🟡",
                    "low": "🟢"
                }.get(task.get("priority", "medium"), "")
                
                f.write(f"- [{checkbox}] {priority_emoji} {task['title']}")
                
                if task.get("due_date"):
                    f.write(f" (due: {task['due_date'][:10]})")
                
                f.write("\n")
                
                if task.get("description"):
                    f.write(f"  {task['description']}\n")
                
                if task.get("tags"):
                    f.write(f"  Tags: {', '.join(task['tags'])}\n")
                
                f.write("\n")

# Example usage
export_to_markdown("~/Documents/tasks.md")
```

### GitHub Issues Integration

```python
from github import Github

def sync_with_github(repo_name, github_token):
    """Sync tasks with GitHub issues."""
    g = Github(github_token)
    repo = g.get_repo(repo_name)
    
    with open(os.path.expanduser("~/.openclaw/data/tasks.json"), "r+") as f:
        data = json.load(f)
        
        for task in data["tasks"]:
            if task.get("github_issue_id"):
                # Update existing issue
                issue = repo.get_issue(task["github_issue_id"])
                issue.edit(
                    title=task["title"],
                    body=task["description"],
                    state="closed" if task["status"] == "done" else "open"
                )
            else:
                # Create new issue
                issue = repo.create_issue(
                    title=task["title"],
                    body=task["description"],
                    labels=[task["priority"]] + task.get("tags", [])
                )
                task["github_issue_id"] = issue.number
        
        f.seek(0)
        json.dump(data, f, indent=2)
        f.truncate()

# Example usage (requires GITHUB_TOKEN)
sync_with_github("username/repo", os.getenv("GITHUB_TOKEN"))
```

## Sub-Agent Execution Support

**YES** - This skill strongly supports sub-agent execution:

### Multi-Agent Task Management

1. **Inbox Agent**: Captures and categorizes new tasks
2. **Prioritization Agent**: Assigns priorities based on urgency/importance
3. **Scheduling Agent**: Sets due dates and creates reminders
4. **Execution Agent**: Tracks progress and updates status
5. **Review Agent**: Analyzes completed tasks and generates insights

### Example Multi-Agent Workflow

```python
# Agent 1: Task Capture
captured_tasks = inbox_agent.capture_from_email()

# Agent 2: Prioritization
prioritized_tasks = prioritization_agent.analyze(captured_tasks)

# Agent 3: Scheduling
scheduled_tasks = scheduling_agent.assign_dates(prioritized_tasks)

# Agent 4: Delegation
delegated_tasks = delegation_agent.assign_to_agents(scheduled_tasks)

# Agent 5: Tracking
tracking_agent.monitor_progress(delegated_tasks)

# Agent 6: Completion
completion_agent.verify_and_close(delegated_tasks)
```

## Configuration

### Environment Variables

```bash
# Required
export TASKS_DB_PATH=~/.openclaw/data/tasks.json

# Optional: GitHub integration
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxx
export GITHUB_REPO=username/repo

# Optional: Notification settings
export ENABLE_REMINDERS=true
export REMINDER_LEAD_TIME_HOURS=24
```

### OpenClaw Configuration

Add to `~/.openclaw/skills/task-management/config.json`:

```json
{
  "name": "task-management",
  "enabled": true,
  "database": {
    "path": "~/.openclaw/data/tasks.json",
    "backup_enabled": true,
    "backup_interval_hours": 24
  },
  "integrations": {
    "github": {
      "enabled": false,
      "repo": null,
      "sync_interval_minutes": 30
    }
  },
  "workflows": {
    "default": "gtd",
    "auto_archive_completed_days": 30
  },
  "notifications": {
    "enabled": true,
    "channels": ["telegram"],
    "remind_before_hours": 24
  }
}
```

## Workflow Methodologies

### GTD (Getting Things Done)

```python
# GTD contexts
CONTEXTS = ["inbox", "next_actions", "waiting_for", "someday_maybe", "projects"]

def gtd_process_inbox():
    """Process inbox items using GTD methodology."""
    inbox_tasks = list_tasks(project="inbox")
    
    for task in inbox_tasks:
        print(f"\nTask: {task['title']}")
        print("Options:")
        print("1. Do it now (< 2 min)")
        print("2. Delegate")
        print("3. Defer (schedule)")
        print("4. Delete")
        
        # Process based on user input or AI decision
```

### Eisenhower Matrix

```python
def categorize_by_eisenhower(task):
    """Categorize task into Eisenhower Matrix quadrant."""
    is_urgent = task.get("due_date") and \
                datetime.fromisoformat(task["due_date"]) < datetime.now() + timedelta(days=2)
    is_important = task.get("priority") in ["high", "critical"]
    
    if is_urgent and is_important:
        return "Q1: Do First"
    elif not is_urgent and is_important:
        return "Q2: Schedule"
    elif is_urgent and not is_important:
        return "Q3: Delegate"
    else:
        return "Q4: Eliminate"
```

## Best Practices

1. **Single Source of Truth**: Maintain one task database
2. **Regular Reviews**: Weekly and daily task reviews
3. **Clear Titles**: Use actionable verb phrases
4. **Proper Tagging**: Consistent tag taxonomy
5. **Due Dates**: Only for tasks with real deadlines
6. **Dependencies**: Track blocking relationships
7. **Archive Completed**: Regular cleanup of old tasks

## Security Considerations

- Task database stored locally (no cloud by default)
- GitHub token stored in environment variables only
- Sensitive task information can be encrypted
- Backup tasks regularly to prevent data loss

## Performance Considerations

- JSON database suitable for <10,000 tasks
- For larger datasets, consider SQLite or PostgreSQL
- Index by status, project, and due_date for fast queries
- Implement pagination for large task lists

## Troubleshooting

### Database Corruption

```bash
# Restore from backup
cp ~/.openclaw/data/tasks.json.backup ~/.openclaw/data/tasks.json

# Validate JSON
python -m json.tool ~/.openclaw/data/tasks.json
```

### GitHub Sync Issues

```bash
# Verify GitHub token
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# Check rate limits
gh api rate_limit
```

## Integration with OpenClaw Model Routing

```json
{
  "skills": {
    "task-management": {
      "model": "claude-3-5-haiku-20241022",
      "reason": "Cost-effective for task CRUD operations"
    },
    "task-management:prioritization": {
      "model": "claude-3-5-sonnet-20241022",
      "reason": "Better reasoning for priority decisions"
    }
  }
}
```

## Source References

- **pndr**: Personal productivity app with tasks, journal, habits
- **idea-coach**: AI-powered idea/problem manager with GitHub integration
- **quests**: Track and guide humans through multi-step processes
- **productivity-tasks**: General productivity and task tracking

## Additional Resources

- Getting Things Done: https://gettingthingsdone.com/
- Eisenhower Matrix: https://www.eisenhower.me/
- GitHub Issues API: https://docs.github.com/en/rest/issues
- Task Management Best Practices: https://todoist.com/productivity-methods
