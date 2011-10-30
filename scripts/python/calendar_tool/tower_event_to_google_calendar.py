#!/usr/bin/env python
# -*- coding: utf-8 -*-
import datetime
import gdata.calendar.service
import gdata.calendar
import atom

# google account email address
google_email = 'account.of.yourself@gmail.com'
# google account password
google_password = 'password'

# calendar
# cal_url = ''
cal_url = 'http://www.google.com/calendar/feeds/account.of.yourself%40gmail.com/private/full'
# title prefix
title_prefix = unicode('[タワレコ]', 'utf-8')

def post(event_dt, title, store, type, calendar_url):
    """post TOWER RECORDS insotre event to Google Calendar"""
    
    if calendar_url == '':
        calendar_url = '/calendar/feeds/default/private/full'

    # considering timezone (JST -> UTC)
    dt_start = event_dt + datetime.timedelta(hours=-9)
    dt_end   = dt_start + datetime.timedelta(hours=1)

    event = gdata.calendar.CalendarEventEntry()
    event.title = atom.Title(text=title_prefix + title)
    event.where.append(gdata.calendar.Where(value_string=store))
    event.content = atom.Content(text=type)
    event.when.append(gdata.calendar.When(
        start_time=dt_start.isoformat() + '.000Z'),
        ent_time = dt_end.isoformat() + '.000Z'))
    new_event = cal_client.InsertEvent(event, calendar_url)

# create gcalendar-service instance
cal_client = gdata.calendar.service.CalendarService()
cal_client.email = google_email
cal_client.password = google_password
cal_client.ProgrammaticLogin()

# create TowerInstoreEvent instance
te = TowerInstoreEvent()
tower_events = te.get_events()

for e in tower_events:
    post(e.get('event_dt'),
         e.get('title'),
         e.get('store'),
         e.get('type'),
         cal_url)
    print 'Registered : %s : %s (%s) @ %s' % (e.get('event_dt'),
                                              e.get('title'),
                                              e.get('type'),
                                              e.get('store'))

# __EOF__
