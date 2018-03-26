# -*- coding: utf-8 -*-
from datetime import datetime

import pytz


fmt = '%Y-%m-%d %H:%M:%S %z(%Z)'


def dump(year, mon, day, hour, min, sec, tz):
    dt = datetime(year, mon, day, hour, min, sec, tzinfo=pytz.utc)
    print(dt.astimezone(tz).strftime(fmt))


def main():
    # pst = pytz.timezone("US/Pacific")
    # pst_ambiguous = datetime(2018, 3, 11, 2, 59)

    # pst_dt1 = pst.localize(pst_ambiguous, is_dst=True)
    # print(pst_dt1.strftime(fmt))
    # pst_dt2 = pst.localize(pst_ambiguous, is_dst=False)
    # print(pst_dt2.strftime(fmt))
    # pst_dt3 = pst.localize(pst_ambiguous, is_dst=None)

    ist = pytz.timezone("Israel")
    ist_ambiguous = datetime(2018, 3, 23, 2, 59)

    ist_dt1 = ist.localize(ist_ambiguous, is_dst=True)
    print(ist.utcoffset(ist_ambiguous, is_dst=True))
    print(ist_dt1.strftime(fmt))
    ist_dt2 = ist.localize(ist_ambiguous, is_dst=False)
    print(ist.utcoffset(ist_ambiguous, is_dst=False))
    print(ist_dt2.strftime(fmt))

    # ist_dt3 = ist.localize(ist_ambiguous, is_dst=None)


if __name__ == "__main__":
    main()
