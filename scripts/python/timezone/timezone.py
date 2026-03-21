from datetime import datetime
from typing import TypeAlias
from zoneinfo import ZoneInfo, available_timezones


fmt = '%Y-%m-%d %H:%M:%S(%Z)'

TzOffset: TypeAlias = float
TzMap: TypeAlias = dict[TzOffset, set[tuple[str, str]]]


def _dump(tz_map: TzMap) -> None:
    for offset in sorted(tz_map.keys()):
        # print(f"{offset}")
        h = offset // 3600.0
        m = (offset % 3600.0) / 60
        print(f"UTC{h:-3.0f}:{m:02.0f}")
        for zone, timestamp in sorted(tz_map[offset]):
            print(f"\t{zone:<32} {timestamp:<30}")


def main() -> None:
    ambiguous_dt = datetime(2018, 10, 28, 1, 59, tzinfo=ZoneInfo("UTC"))

    tz_map: TzMap = dict()

    for zone in available_timezones():
        tz = ZoneInfo(zone)
        new_dt = ambiguous_dt.astimezone(tz=tz)
        timestamp = new_dt.strftime(fmt)
        if utcoffset := new_dt.utcoffset():
            offset = utcoffset.total_seconds()
        else:
            offset = 0.0

        items = tz_map.setdefault(offset, set())
        items.add((zone, timestamp))

    _dump(tz_map=tz_map)


if __name__ == "__main__":
    main()
