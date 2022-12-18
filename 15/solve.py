import dataclasses
import re
import typing as ty
import unittest


@dataclasses.dataclass
class Beacon:
    location: ty.Tuple[int, int]
    signal: ty.Tuple[int, int]

    def manhattan_radius(self) -> int:
        dx = abs(self.location[0] - self.signal[0])
        dy = abs(self.location[1] - self.signal[1])
        return dx + dy

    def in_range(self, p):
        dx = abs(p[0] - self.location[0])
        dy = abs(p[1] - self.location[1])
        return self.manhattan_radius() >= (dx + dy)

    @classmethod
    def load_file(cls, fname: str) -> ty.Iterable["Beacon"]:
        with open(fname) as inf:
            lines = (ln for line in inf.readlines() if (ln := line.strip()))
            yield from map(parse_input_line, lines)


PATTERN = r"Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)"


def parse_input_line(line: str) -> Beacon:
    match = re.match(PATTERN, line)
    if match is None:
        raise Exception(f"Invalid input line: {line}")
    a, b, c, d = match.groups()
    return Beacon(location=(int(a), int(b)), signal=(int(c), int(d)))


Interval = ty.Tuple[int, int]


def overlap(i1: Interval, i2: Interval) -> bool:
    x1, y1 = i1
    x2, y2 = i2
    if x1 > x2:
        return overlap(i2, i1)
    if y1 < x2:
        return False
    return True


def size(interval: Interval) -> int:
    return (interval[1] - interval[0]) + 1


def consolidate(i1: Interval, i2: Interval) -> Interval:
    # assert overlap(i1, i2)
    return (min(i1[0], i2[0]), max(i1[1], i2[1]))


def clamp(n, lower, upper):
    return max(lower, min(n, upper))


def restrict(interval: Interval, min=0, max=4_000_000) -> Interval:
    return (clamp(interval[0], min, max), clamp(interval[1], min, max))


class TestInverval(unittest.TestCase):
    def test_overlap(self):
        should_overlap = [
            ((0, 1), (1, 2)),
            ((0, 1), (0, 2)),
            ((0, 3), (2, 3)),
            ((1, 2), (0, 1)),
            ((1, 4), (0, 2)),
        ]
        assert all(overlap(a, b) for a, b in should_overlap)
        shouldnt_overlap = [
            ((0, 1), (2, 3)),
            ((2, 3), (0, 1)),
        ]
        assert not any(overlap(a, b) for a, b in shouldnt_overlap)

    def test_size(self):
        cases = [
            (1, (0, 0)),
            (2, (0, 1)),
            (3, (0, 2)),
            (5, (-1, 3)),
            (3, (-5, -3)),
        ]
        for length, i in cases:
            self.assertEqual(length, size(i))

    def test_consolidate(self):
        cases = [
            (((0, 1), (1, 2)), (0, 2)),
            (((0, 1), (0, 3)), (0, 3)),
            (((1, 2), (0, 1)), (0, 2)),
        ]
        for intervals, expected in cases:
            self.assertEqual(expected, consolidate(*intervals))


def blocked_interval_y(ycoord: int, beacon: Beacon) -> ty.Optional[Interval]:
    x, y = beacon.location
    radius = beacon.manhattan_radius()
    separation = abs(y - ycoord)
    if separation > radius:
        return None
    remaining = radius - separation
    return (x - remaining, x + remaining)


def blocked_interval_x(xcoord: int, beacon: Beacon) -> ty.Optional[Interval]:
    x, y = beacon.location
    radius = beacon.manhattan_radius()
    separation = abs(x - xcoord)
    if separation > radius:
        return None
    remaining = radius - separation
    return (y - remaining, y + remaining)


def blocked_intervals_y(
    ycoord: int,
    beacons: ty.Iterable[Beacon],
) -> ty.Iterable[Interval]:
    for beacon in beacons:
        i = blocked_interval_y(ycoord, beacon)
        if i is not None:
            yield i


def blocked_intervals_x(
    xcoord: int,
    beacons: ty.Iterable[Beacon],
) -> ty.Iterable[Interval]:
    for beacon in beacons:
        i = blocked_interval_x(xcoord, beacon)
        if i is not None:
            yield i


def consolidate_intervals(intervals: ty.Iterable[Interval]) -> ty.Iterable[Interval]:
    intervals = sorted(intervals)
    ivl = intervals[0]
    intervals = intervals[1:]
    while len(intervals) > 0:
        if overlap(ivl, intervals[0]):
            ivl = consolidate(ivl, intervals[0])
            intervals = intervals[1:]
        else:
            yield ivl
            ivl = intervals[0]
            intervals = intervals[1:]
    yield ivl


def debug(ycoord: int, beacons: ty.List[Beacon]):
    from pprint import pprint

    print_example(beacons)
    intervals = list(blocked_intervals_y(ycoord, beacons))
    print("Intervals")
    pprint(intervals)
    consolidated = list(consolidate_intervals(intervals))
    print("Consolidated")
    pprint(consolidated)
    blocked = sum(size(c) for c in consolidated)
    print("Blocked: ", blocked)


def print_example(beacons: ty.List[Beacon]):
    bns = {b.location: b for b in beacons}
    for y in range(-10, 30):
        for x in range(-10, 30):
            if (x, y) in bns:
                print("B", end="")
            elif any(b.in_range((x, y)) for b in beacons):
                print("#", end="")
            else:
                if y == 10:
                    print("-", end="")
                else:
                    print(".", end="")
        print()


def blocked_points(ycoord: int, beacons: ty.List[Beacon]) -> int:
    intervals = blocked_intervals_y(ycoord, beacons)
    consolidated = consolidate_intervals(intervals)
    blocked = sum(size(c) for c in consolidated) - 1
    return blocked


def part1():
    beacons = list(Beacon.load_file("input.txt"))
    blocked = blocked_points(2_000_000, beacons)
    print("Part 1: ", blocked)


def blocked_points_x(xcoord: int, beacons: ty.List[Beacon]) -> int:
    intervals = [restrict(i) for i in blocked_intervals_x(xcoord, beacons)]
    consolidated = consolidate_intervals(intervals)
    blocked = sum(size(c) for c in consolidated) - 1
    return blocked


def blocked_points_y(ycoord: int, beacons: ty.List[Beacon]) -> int:
    intervals = [restrict(i) for i in blocked_intervals_y(ycoord, beacons)]
    consolidated = consolidate_intervals(intervals)
    blocked = sum(size(c) for c in consolidated) - 1
    return blocked


def part2():
    beacons = list(Beacon.load_file("input.txt"))
    answer_x, answer_y = 0, 0
    for x in range(0, 4_000_001):
        blkd = blocked_points_x(x, beacons)
        if blkd < 4_000_000:
            answer_x = x
            break
    for y in range(0, 4_000_001):
        blkd = blocked_points_y(y, beacons)
        if blkd < 4_000_000:
            answer_y = y
            break
    print("Part 2:", (answer_x * 4000000) + answer_y)
    for b in beacons:
        assert not b.in_range((answer_x, answer_y))


if __name__ == "__main__":
    part1()
    part2()
