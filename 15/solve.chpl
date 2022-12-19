use IO, FileSystem, FormattedIO, List;

type Point = (int, int);

type Beacons = [{0..25}] Beacon;

record Beacon {
    const location: Point, signal: Point;

    proc init(location: Point, signal: Point) {
        this.location = location;
        this.signal = signal;
    }

    proc manhattan_radius(): int {
        const dx = abs(this.location[0] - this.signal[0]),
              dy = abs(this.location[1] - this.signal[1]);
        return dx + dy;
    }

    proc in_range(p: Point): bool {
        const dx = abs(this.location[0] - p[0]),
              dy = abs(this.location[1] - p[1]);
        return this.manhattan_radius() >= dx + dy;
    }

    proc excludesX(xcoord: int): range(int) {
        const separation = abs(xcoord - this.location[0]),
              radius = this.manhattan_radius();
        if separation > radius {
            return 1..0;
        }
        const remaining = radius - separation;
        return (this.location[1]-remaining)..(this.location[1]+remaining);
    }

    proc excludesY(ycoord: int): range(int) {
        const separation = abs(ycoord - this.location[1]),
              radius = this.manhattan_radius();
        if separation > radius {
            return 1..0;
        }
        const remaining = radius - separation;
        return (this.location[0]-remaining)..(this.location[0]+remaining);
    }
}

iter blocked_intervals_x(xcoord: int, beacons): range(int) {
    for bcn in beacons {
        const interval = bcn.excludesX(xcoord);
        if  interval.size > 0 {
            yield interval;
        }
    }
}

iter blocked_intervals_y(ycoord: int, beacons): range(int) {
    for bcn in beacons {
        const interval = bcn.excludesY(ycoord);
        if interval.size > 0 {
            yield interval;
        }
    }
}

record RangeComparator {}

proc RangeComparator.key(r) {
    return -r.low;  // sort in ascending order
}

var rangeComparator: RangeComparator;

iter consolidate_intervals(in intervals: List.list(range(int))) {
    intervals.sort(comparator=rangeComparator);
    var current = intervals.pop();
    while intervals.size > 0 {
        if current[intervals.last()].size == 0 {
            yield current;
            current = intervals.pop();
        } else {
            const newmax = max(current.high, intervals.last().high);
            current = (current.low)..newmax;
            intervals.pop();
        }
    }
    yield current;
}

config const inf = "input.txt";
config const part1Y = 2000000;

iter loadInput(): Beacon {
    var a, b, c, d: int;
    const f = open(inf, iomode.r).reader();
    while f.readf("Sensor at x=%i, y=%i: closest beacon is at x=%i, y=%i\n", a, b, c, d) {
        yield new Beacon((a, b), (c, d));
    }
}


proc part1(bcns: Beacons) {
    var excluded = new List.list(range(int));
    for excl in blocked_intervals_y(part1Y, bcns) {
        excluded.append(excl);
    }
    var blocked = 0;
    for ivl in consolidate_intervals(excluded) {
        blocked += ivl.size;
    }
    return blocked - 1;
}

proc clamp(x, l, h) {
    return max(l, min(x, h));
}

proc restrict(rng: range(int)): range(int) {
    param l = 0;
    param h = 4000000;
    return clamp(rng.low, l, h)..clamp(rng.high, l, h);
}

proc excludedX(xcoord: int, bcns: Beacons) {
    var excluded = new List.list(range(int));
    for excl in blocked_intervals_x(xcoord, bcns) {
        excluded.append(restrict(excl));
    }
    var blocked = 0;
    for ivl in consolidate_intervals(excluded) {
        blocked += ivl.size;
    }
    return blocked - 1;
}

proc excludedY(ycoord: int, bcns: Beacons) {
    var excluded = new List.list(range(int));
    for excl in blocked_intervals_y(ycoord, bcns) {
        excluded.append(restrict(excl));
    }
    var blocked = 0;
    for ivl in consolidate_intervals(excluded) {
        blocked += ivl.size;
    }
    return blocked - 1;
}

proc part2(bcns: Beacons) {
    var answerx = -1;
    var answery = -1;
    forall x in 0..4_000_000 with (ref answerx) {
        if answerx > 0 then continue;
        if excludedX(x, bcns) < 4_000_000 {
            answerx = x;
        }
    }
    forall y in 0..4_000_000  with (ref answery) {
        if answery > 0 then continue;
        if excludedY(y, bcns) < 4_000_000 {
            answery = y;
        }
    }
    writeln("Part 2:");
    writeln("  x: ", answerx, " (expect 3403960)");
    writeln("  y: ", answery, " (expect 3289729)");
    writeln("  answer: ", answerx * 4_000_000 + answery, " (expect 13615843289729)");
}

proc main() {
    var bcns: Beacons = loadInput();

    writeln("Part 1: ", part1(bcns), " (expect 5299855)");
    part2(bcns);

    // part2(bcns);

    // part 2 should be 13615843289729
}
