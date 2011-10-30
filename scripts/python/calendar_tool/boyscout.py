#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os, sys, re, codecs
from gdata.calendar.service import CalendarService
from gdata.calendar import CalendarEventEntry, When, Where
import atom
from datetime import datetime, timedelta

class BoyScout(object):
    """ """
    def __init__(self, cal_client):
        """ """
        self.google_email  = 'account.of.yourself@gmail.com'
        self.google_passwd = 'password'
        self.prefix  = '[BS]'
        self.client = cal_client

    def post(self, dt, title, place, type, url):
        """ """
        if url == '':
            url = '/calendar/feeds/default/private/full'

        dt_start = dt + timedelta(hours=-9)
        dt_end   = dt_start + timedelta(hours=1)

        event = CalendarEventEntry()
        event.title = atom.Title(text=self.prefix + title)
        event.where.append(Where(value_string=place))
        event.content = atom.Content(text=type)
        event.when.append(When(
            start_time=dt_start.isoformat() + '.000Z',
            end_time=dt_end.isoformat() + '.000Z'))
        self.client.InsertEvent(event, url)

if __name__=='__main__':
    cal_url = 'http://www.google.com/calendar/feeds/random_string%40group.calendar.google.com/private/full'
    client = CalendarService()
    bs5 = BoyScout(client)

    client.email = bs5.google_email
    client.password = bs5.google_passwd
    client.ProgrammaticLogin()

    dt = datetime(2009, 1, 20, 15, 00, 00)

    bs5.post(dt,
             u'隊集会テスト',
             u'大田ふれあいセンター',
             u'ハイキング',
             cal_url)

# __EOF__
