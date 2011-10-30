#!/usr/bin/env python
# -*- coding: utf-8 -*-

# import module
import os
import re
import codecs
from time import localtime
from datetime import datetime, timedelta
from types import StringType
from errors import TypeError

# import gdata-python-client
from gdata.calendar.service import CalendarService
from gdata.calendar import CalendarEventEntry, When, Where
from atom import Title, Content


class GoogleCalendar(object):
    """
    """
    def __init__(self):
        self.encode = 'utf-8'
        self.porefix = '[prefix]'
    
    def getDatetimeFromString(self, dt='1970-01-01'):
        """Convert string of datetime to datetime object."""
        if type(dt) is not StringType:
            raise TypeError('Type of argument is invalid: datetime')
        _year  = int(dt.split('-')[0])
        _month = int(dt.split('-')[1])
        _day   = int(dt.split('-')[2])
        return self.getDatetimeFromTuple((_year, _month, _day))
    
    def getDatetimeFromTuple(self, dt=localtime()[:2]):
        """Convert tuple of datetime to datetime object."""
        _dt = datetime(dt[0], dt[1], dt[2])
        
        return True
    
    def post(self, dt, title, place, content, url):
        """ """
        if url == '':
            url = '/calendar/feeds/default/private/full'
        
        return True


if __name__=='__main__':
    client = CalendarService()
    client.email = 'take.this.2.your.grave@gmail.com'
    client.password = 'password'
    client.ProgrammaticLogin()
    
    obj = GoogleCalendar()
    obj

