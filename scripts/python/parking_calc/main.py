from datetime import datetime, timedelta
from zoneinfo import ZoneInfo


jst = ZoneInfo("Asia/Tokyo")


hnd_busy_period = [
    (datetime(2025, 4, 25, 0, tzinfo=jst),  datetime(2025, 5, 7, 0, tzinfo=jst)),
    (datetime(2025, 7, 11, 0, tzinfo=jst),  datetime(2025, 9, 1, 0, tzinfo=jst)),
    (datetime(2025, 12, 19, 0, tzinfo=jst), datetime(2026, 1, 5, 0, tzinfo=jst)),
]


class Parking:
    def __init__(self, since: datetime, until: datetime):
        self.since = since
        self.until = until

        if self.total_seconds() <= (3600 * 7.0):
            self.slots_per_day = 48
            self.seconds_per_slot = 1800
        else:
            self.slots_per_day = 24
            self.seconds_per_slot = 3600

    def __str__(self) -> str:
        return (
            "<Parking "
            f"since:{self.since} - until:{self.until}, "
            f"duration:{self.term_of_use()}"
            ">"
        )

    def term_of_use(self) -> timedelta:
        return self.until - self.since

    def total_seconds(self) -> float:
        return int(self.term_of_use().total_seconds())

    def _get_slots_by_day(self) -> list[list[int]]:
        total = self.total_seconds()
        slots = ([0] * (int(total / self.seconds_per_slot) + (1 if total % self.seconds_per_slot > 0 else 0)))

        # 24時間毎に分割
        return [slots[i:i + self.slots_per_day] for i in range(0, len(slots), self.slots_per_day)]

    def _belongs_busy_period(
        self,
        busy_period: list[tuple[datetime, datetime]],
        testee: datetime,
    ) -> bool:
        return any([since <= testee < until for since, until in busy_period])

    def calculate(self) -> int:
        slots_by_day = self._get_slots_by_day()

        charge_by_day: list[int] = [0] * len(slots_by_day)
        for day, sub_slots in enumerate(slots_by_day):
            for loc, _ in enumerate(sub_slots):
                slot_time = self.since + timedelta(seconds=self.seconds_per_slot * (day * self.slots_per_day + loc))
                # 多客期間判定
                if self._belongs_busy_period(hnd_busy_period, slot_time):
                    sub_slots[loc] = 1

            # 料金計算
            is_busy = any(sub_slots)
            sub_total = sum([300 if self.seconds_per_slot == 3600 else 150 for unit in sub_slots])
            charge_by_day[day] = min(sub_total, 2140 if is_busy and charge_by_day.count(2140) < 3 else 1530)

        return sum(charge_by_day)


def main():
    # since = datetime(2025, 5, 1, 12, 0, tzinfo=jst)
    # until = datetime(2025, 5, 1, 19, 0, tzinfo=jst)
    since = datetime(2025, 6, 24, 12, 0, tzinfo=jst)
    until = datetime(2025, 6, 28, 19, 0, tzinfo=jst)

    parking = Parking(since, until)
    print(parking)
    print(f"駐車場利用期間: {parking.term_of_use()}")
    print(f"駐車場利用期間(秒): {parking.total_seconds()}")
    print(f"駐車場利用料金: {parking.calculate()}円")


if __name__ == "__main__":
    main()
