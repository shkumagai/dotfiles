#!/usr/bin/env python
# -*- coding: utf-8 -*-
import re
import urllib
from lxml import etree
from datetime import datetime

class TowerInstoreEvent(object):
    """TOWER RECORDS instore event information"""

    def __init__(self):
        self.INSTORE_URL = 'http://www.towerrecords.jp/store/instore.html'
        self.TARGET_STORE_LIST = [unicode('新宿店', 'utf-8')]
        self.r_for_store = re.compile(r'store\d+\.html')
        self.r_for_date  = re.compile(r'(\d+?)/(\d+?)[^\d]')
        self.r_for_time  = re.compile(r'(\d+?):(\d{2})')
    
    def get_datetime(self, date_elem, time_elem):
        today = datetime.today()
        year = today.year
        m = self.r_for_date.match(date_elem.text)
        mm, dd = map(int, m.group(1, 2))
        m = self.r_for_time.match(time_elem.text)
        if m != None:
            hh, mi = map(int, m.group(1, 2))
        else:
            hh, mi = 0, 0
        d = datetime(year, mm, dd, hh, mi)
        if d < today:
            return datetime(year+1, mm, dd, hh, mi)
        else:
            return d
    
    def get_events(self):
        parser = etree.HTMLParser()
        proxy = {'http': self.PROXY_URL}
        et = etree.parse(urllib.urlopen(self.INSTORE_URL, proxies=proxy), parser)
        ts = et.xpath('//tr/td/a')
        ts = [ e for e in ts if self.r_for_store.match( e.values()[0] ) ]
        if self.TARGET_STORE_LIST:
            ts = [ e for e in ts if e.text in self.TARGET_STORE_LIST ]
        results = list()
        for e in ts:
            tr = e.getparent().getparent()
            date, time, title, type, self.store = tr.findall('td')
            results.append({'event_dt'  : self.get_datetime(date, time),
                            'title'     : title.text,
                            'type'      : type.text,
                            'store'     : unicode('タワレコ','utf-8') + e.text})
        return results

if __name__=='__main__':
    te = TowerInstoreEvent()
    events = te.get_events()
    for i in events:
        print i.get('event_dt'),
        print i.get('title').replace('\n', ' '),
        print i.get('type'), i.get('store')
