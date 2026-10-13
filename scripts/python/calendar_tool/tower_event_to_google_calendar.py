#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "google-api-python-client",
#     "google-auth-oauthlib",
#     "lxml",
# ]
# ///
"""Post TOWER RECORDS instore events to Google Calendar."""

import os

from gcalendar import GoogleCalendar
from TowerInstoreEvent import TowerInstoreEvent

# calendar ID ('primary' or 'xxxx@group.calendar.google.com'); list them by running gcalendar.py
CALENDAR_ID = os.environ.get('TOWER_CALENDAR_ID', 'primary')
# title prefix
TITLE_PREFIX = '[タワレコ]'


def main():
    calendar = GoogleCalendar(prefix=TITLE_PREFIX)
    for e in TowerInstoreEvent().get_events():
        calendar.post(e.get('event_dt'),
                      e.get('title'),
                      e.get('store'),
                      e.get('type'),
                      CALENDAR_ID)
        print('Registered : %s : %s (%s) @ %s' % (e.get('event_dt'),
                                                 e.get('title'),
                                                 e.get('type'),
                                                 e.get('store')))


if __name__ == '__main__':
    main()
