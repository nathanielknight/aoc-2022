proc main() {
    var pts = loadInput();
    getSize(pts);
    part1(pts);
    part2(pts);
}

type Point = (int, int, int);

config const inf = "input.txt";

iter loadInput(): Point {
    use IO, FormattedIO, FileSystem;
    const r = open(inf, iomode.r).reader();
    var x, y, z: int;
    while r.readf("%i,%i,%i", x, y, z) {
        yield (x, y, z);
    }
}

iter neighbors(p): Point {
    const (x, y, z) = p;
    yield (x+1, y, z);
    yield (x-1, y, z);
    yield (x, y+1, z);
    yield (x, y-1, z);
    yield (x, y, z+1);
    yield (x, y, z-1);
}

proc getSize(pts) {
    var hx, hy, hz = 0;
    var lx, ly, lz = 9999;
    for (x, y, z) in pts {
        hx = max(x, hx);
        hy = max(y, hy);
        hz = max(z, hz);
        lx = min(x, lx);
        ly = min(y, ly);
        lz = min(z, lz);
    }
    writeln("Dimensions: ");
    writeln("  X in ", lx, "..", hx);
    writeln("  Y in ", ly, "..", hy);
    writeln("  Z in ", lz, "..", hz);
}

const d: range(int) = -1..20;
const D: domain(3) = {d, d, d};

proc part1(pts) {
    var map: [D] int = 0;
    for p in pts {
        map[p] = 1;
    }
    var surfaceArea = 0;
    forall  (x, y, z) in D with (+ reduce surfaceArea) {
        if x == -1 || y == -1 || z == -1 then continue;
        if x == 20 || y == 20 || z == 20 then continue;
        if map[x, y, z] == 0 then continue;
        for n in neighbors((x, y, z)) {
            if map[n] == 0 then surfaceArea += 1;
        }
    }
    writeln("Part 1: ", surfaceArea);
}

proc part2(pts) {
    use IO, FormattedIO, FileSystem;
    use List;
    var map: [D] int = 0;
    for p in pts {
        map[p] = 1;
    }
    // Flood-fill exterior (won't work on crypts)
    var toscan = new List.list(Point);
    toscan.append((0, 0, 0));
    while toscan.size > 0 {
        const p = toscan.pop();
        map[p] = 2;
        for n in neighbors(p) {
            if ! D.contains(n) then continue;
            if map[n] == 0 {
                toscan.append(n);
            }
        }
    }
    var surfaceArea = 0;
    forall  (x, y, z) in D with (+ reduce surfaceArea) {
        if x == -1 || y == -1 || z == -1 then continue;
        if x == 20 || y == 20 || z == 20 then continue;
        if map[x, y, z] == 0 || map[x, y, z] == 2 then continue;
        for n in neighbors((x, y, z)) {
            if map[n] == 2 then surfaceArea += 1;
        }
    }
    writeln("Part 2: ", surfaceArea);
}
