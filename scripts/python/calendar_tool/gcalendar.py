#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "google-api-python-client",
#     "google-auth-oauthlib",
# ]
# ///
"""Thin wrapper of Google Calendar API v3.

OAuth client secrets (Desktop app) are read from
``$XDG_CONFIG_HOME/calendar_tool/credentials.json`` and the issued token is
cached to ``token.json`` in the same directory. Override the directory with
``CALENDAR_TOOL_CONFIG_DIR``.

Run this module directly to authorize and list calendar IDs.
"""

import os
from datetime import datetime, timedelta
from pathlib import Path
from zoneinfo import ZoneInfo

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

SCOPES = [
    'https://www.googleapis.com/auth/calendar.events',
    'https://www.googleapis.com/auth/calendar.calendarlist.readonly',
]
TIMEZONE = 'Asia/Tokyo'


def config_dir():
    """Directory that holds credentials.json and token.json."""
    if 'CALENDAR_TOOL_CONFIG_DIR' in os.environ:
        return Path(os.environ['CALENDAR_TOOL_CONFIG_DIR'])
    xdg = os.environ.get('XDG_CONFIG_HOME') or Path.home() / '.config'
    return Path(xdg) / 'calendar_tool'


def get_service():
    """Authorize with OAuth and return a Calendar API v3 service."""
    directory = config_dir()
    token = directory / 'token.json'
    creds = None
    if token.exists():
        creds = Credentials.from_authorized_user_file(str(token), SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            secrets = directory / 'credentials.json'
            if not secrets.exists():
                raise SystemExit(f'OAuth client secrets not found: {secrets}')
            flow = InstalledAppFlow.from_client_secrets_file(str(secrets), SCOPES)
            creds = flow.run_local_server(port=0)
        directory.mkdir(parents=True, exist_ok=True)
        token.write_text(creds.to_json())
        token.chmod(0o600)
    return build('calendar', 'v3', credentials=creds)


class GoogleCalendar:
    """Post events to Google Calendar."""

    def __init__(self, prefix='', timezone=TIMEZONE, duration=timedelta(hours=1), service=None):
        self.prefix = prefix
        self.timezone = timezone
        self.duration = duration
        self._service = service

    @property
    def service(self):
        if self._service is None:
            self._service = get_service()
        return self._service

    @staticmethod
    def datetime_from_string(dt='1970-01-01'):
        """Convert 'YYYY-MM-DD' (or ISO 8601 datetime) string to datetime object."""
        if not isinstance(dt, str):
            raise TypeError('Type of argument is invalid: datetime')
        return datetime.fromisoformat(dt)

    def build_event(self, dt, title, place, content):
        """Build an event resource. Naive datetimes are treated as self.timezone."""
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=ZoneInfo(self.timezone))
        return {
            'summary': self.prefix + title,
            'location': place,
            'description': content,
            'start': {'dateTime': dt.isoformat(), 'timeZone': self.timezone},
            'end': {'dateTime': (dt + self.duration).isoformat(), 'timeZone': self.timezone},
        }

    def post(self, dt, title, place, content, calendar_id='primary'):
        """Insert an event and return the created resource."""
        event = self.build_event(dt, title, place, content)
        return self.service.events().insert(calendarId=calendar_id or 'primary', body=event).execute()


if __name__ == '__main__':
    calendars = get_service().calendarList().list().execute()
    for c in calendars.get('items', []):
        print(f"{c['id']}\t{c.get('summary', '')}")
