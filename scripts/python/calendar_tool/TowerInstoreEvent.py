#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "lxml",
# ]
# ///
"""TOWER RECORDS instore event scraper."""

import re
import urllib.request
from datetime import datetime

from lxml import etree


class TowerInstoreEvent:
    """TOWER RECORDS instore event information"""

    INSTORE_URL = 'http://www.towerrecords.jp/store/instore.html'

    def __init__(self):
        self.TARGET_STORE_LIST = ['新宿店']
        self.r_for_store = re.compile(r'store\d+\.html')
        self.r_for_date = re.compile(r'(\d+?)/(\d+?)[^\d]')
        self.r_for_time = re.compile(r'(\d+?):(\d{2})')

    def get_datetime(self, date_elem, time_elem, today=None):
        """Build a JST (naive) datetime; dates already past are treated as next year."""
        today = today or datetime.today()
        year = today.year
        m = self.r_for_date.match(date_elem.text)
        mm, dd = map(int, m.group(1, 2))
        m = self.r_for_time.match(time_elem.text or '')
        if m is not None:
            hh, mi = map(int, m.group(1, 2))
        else:
            hh, mi = 0, 0
        d = datetime(year, mm, dd, hh, mi)
        if d < today:
            return datetime(year + 1, mm, dd, hh, mi)
        return d

    def parse(self, source):
        """Parse instore page (file-like object) and return event list."""
        et = etree.parse(source, etree.HTMLParser())
        ts = et.xpath('//tr/td/a')
        ts = [e for e in ts if self.r_for_store.match(e.get('href', ''))]
        if self.TARGET_STORE_LIST:
            ts = [e for e in ts if e.text in self.TARGET_STORE_LIST]
        results = []
        for e in ts:
            tr = e.getparent().getparent()
            date, time, title, event_type, _store = tr.findall('td')
            results.append({'event_dt': self.get_datetime(date, time),
                            'title': title.text,
                            'type': event_type.text,
                            'store': 'タワレコ' + e.text})
        return results

    def get_events(self):
        # proxies are taken from http_proxy / https_proxy environment variables
        with urllib.request.urlopen(self.INSTORE_URL, timeout=30) as res:
            return self.parse(res)


if __name__ == '__main__':
    te = TowerInstoreEvent()
    for i in te.get_events():
        print(i.get('event_dt'), i.get('title').replace('\n', ' '), i.get('type'), i.get('store'))
