#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "google-api-python-client",
#     "google-auth-oauthlib",
# ]
# ///
"""Post Boy Scout events to Google Calendar."""

import os
from datetime import datetime

from gcalendar import GoogleCalendar


class BoyScout:
    """ """
    def __init__(self, calendar=None):
        """ """
        self.prefix = '[BS]'
        self.calendar = calendar or GoogleCalendar(prefix=self.prefix)

    def post(self, dt, title, place, event_type, calendar_id):
        """ """
        return self.calendar.post(dt, title, place, event_type, calendar_id)


if __name__ == '__main__':
    calendar_id = os.environ.get('BOYSCOUT_CALENDAR_ID', 'random_string@group.calendar.google.com')
    bs5 = BoyScout()

    dt = datetime(2009, 1, 20, 15, 00, 00)

    bs5.post(dt,
             '隊集会テスト',
             '大田ふれあいセンター',
             'ハイキング',
             calendar_id)
