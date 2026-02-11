---
name: meeting-scheduler
description: Meeting and calendar scheduling skill with timezone support, availability checking, conflict resolution, and integration with Google Calendar and other calendar services.
license: MIT
source: Community aggregation (calendar skills, scheduling patterns)
version: 1.0.0
last_updated: 2026-02-09
supports_subagent: true
environment_variables:
  - name: GOOGLE_CALENDAR_CREDENTIALS
    description: Path to Google Calendar OAuth credentials JSON
    required: false
    default: ~/.openclaw/credentials/google-calendar.json
  - name: DEFAULT_TIMEZONE
    description: Default timezone for scheduling
    required: false
    default: America/New_York
  - name: CALENDAR_ID
    description: Primary calendar ID for scheduling
    required: false
    default: primary
---

# Meeting Scheduler Skill

## Overview

This skill provides comprehensive meeting and calendar scheduling capabilities:
- Find available meeting times across multiple calendars
- Schedule meetings with automatic invitations
- Manage recurring meetings
- Handle timezone conversions
- Resolve scheduling conflicts
- Send meeting reminders
- Integrate with Google Calendar, Outlook, iCal
- Support for virtual meeting links (Zoom, Google Meet)

## Installation

### 1. Install Dependencies

```bash
# Python dependencies
pip install google-auth google-auth-oauthlib google-auth-httplib2 google-api-python-client
pip install pytz python-dateutil icalendar

# Optional: Email notifications
pip install sendgrid
```

### 2. Set Up Google Calendar API

```bash
# Run the Google Workspace setup script
cd /Users/linktrend/Projects/LiNKbot/scripts/google-workspace
./setup-oauth.sh

# Or manually:
# 1. Go to https://console.cloud.google.com/
# 2. Create project and enable Google Calendar API
# 3. Create OAuth 2.0 credentials
# 4. Download credentials JSON
# 5. Save to ~/.openclaw/credentials/google-calendar.json
```

### 3. Initialize Calendar Configuration

```bash
mkdir -p ~/.openclaw/data/calendar
cat > ~/.openclaw/data/calendar/config.json << 'EOF'
{
  "default_timezone": "America/New_York",
  "default_duration_minutes": 30,
  "working_hours": {
    "start": "09:00",
    "end": "17:00"
  },
  "working_days": [1, 2, 3, 4, 5],
  "buffer_minutes": 15,
  "meeting_types": {
    "quick_call": 15,
    "standard": 30,
    "extended": 60,
    "workshop": 120
  }
}
EOF
```

## Key Features

### Availability Checking
- Find free time slots across calendars
- Respect working hours and timezones
- Account for travel time and buffers
- Multi-participant availability

### Meeting Scheduling
- Create calendar events
- Send invitations automatically
- Add video conferencing links
- Set reminders and notifications

### Recurring Meetings
- Daily, weekly, monthly patterns
- Custom recurrence rules
- Exception handling (skip dates)

### Timezone Management
- Automatic timezone conversion
- Display in participant's local time
- DST awareness

### Conflict Resolution
- Detect double-bookings
- Suggest alternative times
- Priority-based scheduling

## Usage Examples

### Find Available Time Slots

```python
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from datetime import datetime, timedelta
import pytz

def find_available_slots(start_date, end_date, duration_minutes=30, timezone='America/New_York'):
    """
    Find available time slots in calendar.
    
    Args:
        start_date: Start of search period
        end_date: End of search period
        duration_minutes: Required duration for meeting
        timezone: Timezone for results
    
    Returns:
        List of available time slots
    """
    creds = Credentials.from_authorized_user_file(
        '~/.openclaw/credentials/google-calendar.json',
        ['https://www.googleapis.com/auth/calendar.readonly']
    )
    service = build('calendar', 'v3', credentials=creds)
    
    # Get busy times
    body = {
        "timeMin": start_date.isoformat(),
        "timeMax": end_date.isoformat(),
        "timeZone": timezone,
        "items": [{"id": "primary"}]
    }
    
    freebusy = service.freebusy().query(body=body).execute()
    busy_times = freebusy['calendars']['primary']['busy']
    
    # Find free slots
    tz = pytz.timezone(timezone)
    free_slots = []
    current_time = start_date
    
    while current_time < end_date:
        slot_end = current_time + timedelta(minutes=duration_minutes)
        
        # Check if slot is free
        is_free = True
        for busy in busy_times:
            busy_start = datetime.fromisoformat(busy['start'].replace('Z', '+00:00'))
            busy_end = datetime.fromisoformat(busy['end'].replace('Z', '+00:00'))
            
            if (current_time < busy_end and slot_end > busy_start):
                is_free = False
                break
        
        # Check working hours
        if is_free and is_within_working_hours(current_time):
            free_slots.append({
                'start': current_time.isoformat(),
                'end': slot_end.isoformat(),
                'duration_minutes': duration_minutes
            })
        
        current_time += timedelta(minutes=15)  # Check every 15 minutes
    
    return free_slots

# Example usage
start = datetime.now()
end = start + timedelta(days=7)

available = find_available_slots(start, end, duration_minutes=60)
print(f"Found {len(available)} available slots:")
for slot in available[:5]:  # Show first 5
    print(f"  {slot['start']} - {slot['end']}")
```

### Schedule a Meeting

```python
def schedule_meeting(title, start_time, duration_minutes, attendees, description="", location="", meeting_link=None):
    """
    Schedule a meeting in Google Calendar.
    
    Args:
        title: Meeting title
        start_time: Start datetime
        duration_minutes: Meeting duration
        attendees: List of email addresses
        description: Meeting description
        location: Physical location or "Virtual"
        meeting_link: Optional video conference link
    
    Returns:
        Created event details
    """
    creds = Credentials.from_authorized_user_file(
        '~/.openclaw/credentials/google-calendar.json',
        ['https://www.googleapis.com/auth/calendar']
    )
    service = build('calendar', 'v3', credentials=creds)
    
    end_time = start_time + timedelta(minutes=duration_minutes)
    
    event = {
        'summary': title,
        'description': description,
        'start': {
            'dateTime': start_time.isoformat(),
            'timeZone': 'America/New_York',
        },
        'end': {
            'dateTime': end_time.isoformat(),
            'timeZone': 'America/New_York',
        },
        'attendees': [{'email': email} for email in attendees],
        'reminders': {
            'useDefault': False,
            'overrides': [
                {'method': 'email', 'minutes': 24 * 60},  # 1 day before
                {'method': 'popup', 'minutes': 30},  # 30 min before
            ],
        },
    }
    
    if location:
        event['location'] = location
    
    if meeting_link:
        event['description'] += f"\n\nJoin meeting: {meeting_link}"
        event['conferenceData'] = {
            'entryPoints': [{
                'entryPointType': 'video',
                'uri': meeting_link
            }]
        }
    
    created_event = service.events().insert(
        calendarId='primary',
        body=event,
        sendUpdates='all'  # Send email invitations
    ).execute()
    
    return {
        'event_id': created_event['id'],
        'html_link': created_event['htmlLink'],
        'meeting_link': meeting_link
    }

# Example usage
meeting_time = datetime(2026, 2, 15, 14, 0)  # Feb 15, 2026 at 2 PM

result = schedule_meeting(
    title="LiNKbot Project Review",
    start_time=meeting_time,
    duration_minutes=60,
    attendees=["team@example.com", "manager@example.com"],
    description="Quarterly review of LiNKbot deployment and performance metrics.",
    location="Virtual",
    meeting_link="https://meet.google.com/abc-defg-hij"
)

print(f"Meeting scheduled: {result['html_link']}")
```

### Find Mutual Availability

```python
def find_mutual_availability(attendee_emails, start_date, end_date, duration_minutes=30):
    """
    Find times when all attendees are available.
    
    Args:
        attendee_emails: List of attendee email addresses
        start_date: Start of search period
        end_date: End of search period
        duration_minutes: Required duration
    
    Returns:
        List of time slots when all are available
    """
    creds = Credentials.from_authorized_user_file(
        '~/.openclaw/credentials/google-calendar.json',
        ['https://www.googleapis.com/auth/calendar.readonly']
    )
    service = build('calendar', 'v3', credentials=creds)
    
    # Query freebusy for all attendees
    body = {
        "timeMin": start_date.isoformat(),
        "timeMax": end_date.isoformat(),
        "items": [{"id": email} for email in attendee_emails]
    }
    
    freebusy = service.freebusy().query(body=body).execute()
    
    # Collect all busy times
    all_busy_times = []
    for email in attendee_emails:
        if email in freebusy['calendars']:
            all_busy_times.extend(freebusy['calendars'][email].get('busy', []))
    
    # Sort and merge overlapping busy times
    all_busy_times.sort(key=lambda x: x['start'])
    merged_busy = merge_busy_times(all_busy_times)
    
    # Find free slots
    free_slots = []
    current_time = start_date
    
    while current_time < end_date:
        slot_end = current_time + timedelta(minutes=duration_minutes)
        
        # Check if slot is free for everyone
        is_free = True
        for busy in merged_busy:
            busy_start = datetime.fromisoformat(busy['start'].replace('Z', '+00:00'))
            busy_end = datetime.fromisoformat(busy['end'].replace('Z', '+00:00'))
            
            if current_time < busy_end and slot_end > busy_start:
                is_free = False
                current_time = busy_end  # Skip to end of busy period
                break
        
        if is_free and is_within_working_hours(current_time):
            free_slots.append({
                'start': current_time.isoformat(),
                'end': slot_end.isoformat(),
                'all_available': True
            })
        
        current_time += timedelta(minutes=15)
    
    return free_slots

# Example usage
attendees = ["alice@example.com", "bob@example.com", "carol@example.com"]
start = datetime.now()
end = start + timedelta(days=3)

mutual_slots = find_mutual_availability(attendees, start, end, duration_minutes=60)
print(f"Found {len(mutual_slots)} slots when all attendees are available:")
for slot in mutual_slots[:3]:
    print(f"  {slot['start']}")
```

### Create Recurring Meeting

```python
def schedule_recurring_meeting(title, start_time, duration_minutes, recurrence_rule, attendees, end_date=None):
    """
    Schedule a recurring meeting.
    
    Args:
        title: Meeting title
        start_time: First occurrence start time
        duration_minutes: Meeting duration
        recurrence_rule: RRULE string (e.g., "FREQ=WEEKLY;BYDAY=MO,WE,FR")
        attendees: List of attendee emails
        end_date: Optional recurrence end date
    
    Returns:
        Created event details
    """
    creds = Credentials.from_authorized_user_file(
        '~/.openclaw/credentials/google-calendar.json',
        ['https://www.googleapis.com/auth/calendar']
    )
    service = build('calendar', 'v3', credentials=creds)
    
    end_time = start_time + timedelta(minutes=duration_minutes)
    
    recurrence = [f"RRULE:{recurrence_rule}"]
    if end_date:
        recurrence[0] += f";UNTIL={end_date.strftime('%Y%m%dT%H%M%SZ')}"
    
    event = {
        'summary': title,
        'start': {
            'dateTime': start_time.isoformat(),
            'timeZone': 'America/New_York',
        },
        'end': {
            'dateTime': end_time.isoformat(),
            'timeZone': 'America/New_York',
        },
        'attendees': [{'email': email} for email in attendees],
        'recurrence': recurrence,
        'reminders': {
            'useDefault': False,
            'overrides': [
                {'method': 'popup', 'minutes': 10},
            ],
        },
    }
    
    created_event = service.events().insert(
        calendarId='primary',
        body=event,
        sendUpdates='all'
    ).execute()
    
    return created_event

# Example usage: Weekly standup every Monday at 9 AM
first_meeting = datetime(2026, 2, 17, 9, 0)  # Monday
end_date = datetime(2026, 12, 31)  # End of year

recurring_event = schedule_recurring_meeting(
    title="Weekly Team Standup",
    start_time=first_meeting,
    duration_minutes=15,
    recurrence_rule="FREQ=WEEKLY;BYDAY=MO",
    attendees=["team@example.com"],
    end_date=end_date
)

print(f"Recurring meeting created: {recurring_event['id']}")
```

### Timezone Conversion

```python
import pytz

def convert_meeting_time(meeting_time, from_timezone, to_timezone):
    """
    Convert meeting time between timezones.
    
    Args:
        meeting_time: datetime object
        from_timezone: Source timezone string
        to_timezone: Target timezone string
    
    Returns:
        Converted datetime and formatted string
    """
    from_tz = pytz.timezone(from_timezone)
    to_tz = pytz.timezone(to_timezone)
    
    # Localize to source timezone
    localized_time = from_tz.localize(meeting_time)
    
    # Convert to target timezone
    converted_time = localized_time.astimezone(to_tz)
    
    return {
        'datetime': converted_time,
        'formatted': converted_time.strftime('%Y-%m-%d %I:%M %p %Z'),
        'iso': converted_time.isoformat()
    }

# Example usage
meeting = datetime(2026, 2, 15, 14, 0)  # 2 PM Eastern

converted = convert_meeting_time(meeting, 'America/New_York', 'Asia/Tokyo')
print(f"Meeting time in Tokyo: {converted['formatted']}")
```

## Sub-Agent Execution Support

**YES** - This skill strongly supports sub-agent execution:

### Multi-Agent Scheduling Workflow

1. **Availability Agent**: Checks calendars for free times
2. **Preference Agent**: Considers participant preferences
3. **Optimization Agent**: Finds optimal meeting times
4. **Invitation Agent**: Sends invitations and reminders
5. **Conflict Agent**: Resolves scheduling conflicts

### Example Multi-Agent Workflow

```python
# Agent 1: Check Availability
available_slots = availability_agent.find_free_slots(
    participants=["alice@example.com", "bob@example.com"],
    date_range=next_week,
    duration=60
)

# Agent 2: Apply Preferences
preferred_slots = preference_agent.rank_by_preferences(
    slots=available_slots,
    preferences={
        "avoid_early_morning": True,
        "avoid_late_afternoon": True,
        "preferred_days": ["Tuesday", "Wednesday", "Thursday"]
    }
)

# Agent 3: Optimize Selection
optimal_slot = optimization_agent.select_best_slot(
    slots=preferred_slots,
    criteria=["minimal_conflicts", "maximum_attendance", "timezone_fairness"]
)

# Agent 4: Create Meeting
meeting = scheduling_agent.create_meeting(
    slot=optimal_slot,
    title="Project Review",
    attendees=participants
)

# Agent 5: Send Invitations
invitation_agent.send_invites(
    meeting=meeting,
    include_agenda=True,
    add_video_link=True
)
```

## Configuration

### Environment Variables

```bash
# Required for Google Calendar
export GOOGLE_CALENDAR_CREDENTIALS=~/.openclaw/credentials/google-calendar.json

# Optional configuration
export DEFAULT_TIMEZONE=America/New_York
export CALENDAR_ID=primary
export DEFAULT_MEETING_DURATION=30
export WORKING_HOURS_START=09:00
export WORKING_HOURS_END=17:00
```

### OpenClaw Configuration

Add to `~/.openclaw/skills/meeting-scheduler/config.json`:

```json
{
  "name": "meeting-scheduler",
  "enabled": true,
  "calendar_service": "google",
  "credentials_path": "~/.openclaw/credentials/google-calendar.json",
  "default_settings": {
    "timezone": "America/New_York",
    "duration_minutes": 30,
    "buffer_minutes": 15,
    "working_hours": {
      "start": "09:00",
      "end": "17:00",
      "days": [1, 2, 3, 4, 5]
    }
  },
  "meeting_defaults": {
    "send_invitations": true,
    "set_reminders": true,
    "reminder_minutes": [1440, 30],
    "auto_add_video_link": false
  },
  "integrations": {
    "zoom": {
      "enabled": false,
      "api_key": null
    },
    "google_meet": {
      "enabled": true,
      "auto_create": true
    }
  }
}
```

## Best Practices

1. **Timezone Awareness**: Always specify timezones explicitly
2. **Buffer Time**: Add 10-15 min buffers between meetings
3. **Working Hours**: Respect participants' working hours
4. **Confirmation**: Always send calendar invitations
5. **Reminders**: Set reminders 24 hours and 30 minutes before
6. **Meeting Notes**: Include agenda in description
7. **Virtual Links**: Always include video conference links
8. **Recurring Review**: Periodically review recurring meetings

## Security Considerations

- Store OAuth credentials securely
- Use service accounts for automated scheduling
- Limit calendar access permissions
- Encrypt sensitive meeting information
- Audit meeting access logs

## Performance Considerations

- Cache availability lookups for 5-10 minutes
- Batch calendar operations when possible
- Use freebusy queries instead of full event listing
- Implement rate limiting for API calls
- Optimize timezone calculations

## Troubleshooting

### OAuth Token Expired

```bash
# Re-authenticate
python scripts/google-workspace/setup-oauth.sh

# Or manually refresh token
python -c "from google.auth.transport.requests import Request; creds.refresh(Request())"
```

### Calendar Not Found

```bash
# List available calendars
python -c "
from googleapiclient.discovery import build
service = build('calendar', 'v3', credentials=creds)
calendars = service.calendarList().list().execute()
for cal in calendars['items']:
    print(f\"{cal['id']}: {cal['summary']}\")
"
```

### Timezone Issues

```python
# Verify timezone
import pytz
print(pytz.all_timezones)  # List all valid timezones
print(pytz.timezone('America/New_York'))  # Test specific timezone
```

## Integration with OpenClaw Model Routing

```json
{
  "skills": {
    "meeting-scheduler": {
      "model": "claude-3-5-haiku-20241022",
      "reason": "Cost-effective for scheduling operations"
    },
    "meeting-scheduler:conflict-resolution": {
      "model": "claude-3-5-sonnet-20241022",
      "reason": "Better reasoning for complex conflicts"
    }
  }
}
```

## Source References

- Google Calendar API: https://developers.google.com/calendar
- Python timezone handling: https://pytz.sourceforge.net/
- iCalendar RFC: https://datatracker.ietf.org/doc/html/rfc5545
- Scheduling best practices: https://calendly.com/blog/scheduling-best-practices

## Additional Resources

- Google Calendar API Documentation: https://developers.google.com/calendar/api/guides/overview
- Working with Timezones: https://docs.python.org/3/library/datetime.html#timezone-objects
- Recurrence Rules: https://datatracker.ietf.org/doc/html/rfc5545#section-3.3.10
- OAuth 2.0: https://developers.google.com/identity/protocols/oauth2
