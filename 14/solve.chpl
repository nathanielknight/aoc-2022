use List;
use Utils;

proc main() {
    findBounds();
    part1();
    part2();
}

type Point = (int, int);

// Based on my input; might need to be bigger for other inputs.
config const arenaWidth = 400, arenaHeight = 162;
const sandStart = (500, 0);
const arenaLeft = (sandStart[0] - arenaWidth / 2),
    arenaRight = (sandStart[0] + arenaWidth / 2),
    arenaTop = 0,
    arenaBottom = arenaHeight;

var Arena: domain(2) = {arenaLeft..arenaRight, arenaTop..arenaBottom};
enum Contents {empty=0, wall=1, sand=2};

// -------------------------------------------------------------
// Parsing input

proc parsePoint(src: string): Point {
    const xys = src.split(",");
    return (xys[0]: int, xys[1]: int);
}

proc parseLine(line: string): list(Point) {
    var points = new List.list(Point);
    for src in line.split(" -> ") {
        points.append(parsePoint(src));
    }
    return points;
}

iter loadPoints(): list(Point) {
    for line in Utils.lines("input.txt") {
        if line.strip().isEmpty() then continue;
        yield parseLine(line);
    }
}

proc findBounds() {
    var maxX, maxY = 0;
    var minX, minY = 9999;
    for pts in loadPoints()  {
        for (x, y) in pts {
            if x > maxX then maxX = x;
            if x < minX then minX = x;
            if y > maxY then maxY = y;
            if y < minY then minY = y;
        }
    }
    writeln("x in ", minX, "...", maxX);
    writeln("y in ", minY, "...", maxY);
}

proc loadArena(): [Arena] Contents {
    var arena: [Arena] Contents = Contents.empty;
    for pts in loadPoints() {
        if pts.size < 2 then halt("Need at least two points.");
        const prange = 0..<pts.size;
        const ps: [prange]Point = pts;
        for (p1, p2) in zip(ps[prange.first..<prange.last], ps[(prange.first+1)..prange.last]) {
            const (x1, y1) = p1, (x2, y2) = p2;
            if x1 == x2 {
                for y in min(y1, y2)..max(y1,y2) {
                    arena[x1,y] = Contents.wall;
                }
            } else {
                for x in min(x1, x2)..max(x1, x2) {
                    arena[x, y1] = Contents.wall;
                }
            }
        }
    }
    return arena;
}

// for debugging
proc printArena(a: [Arena] Contents) {
    writeln("--------------------------------------------------------------------------");
    for y in 0..<arenaBottom {
        for x in (arenaLeft+1)..<arenaRight {
            if x == 500 && a[x,y]  == Contents.empty {
                write("|");
                continue;
            }
            if a[x,y] == Contents.empty then write(".");
            if a[x,y] == Contents.wall then write("#");
            if a[x,y] == Contents.sand then write("o");
        }
        writeln();
    }
}


// -------------------------------------------------------------
// Part 1

proc part1() {
    writeln("Part 1: ", insertSandBottomless());
}

proc insertSandBottomless(): int {
    var arena = loadArena();
    var restingSand = 0;
    var (x, y) = sandStart;
    do {
        if y >= arenaBottom then return restingSand;
        if arena[x,y+1] == Contents.empty {
            y += 1;
            continue;
        }
        if arena[x-1, y+1] == Contents.empty {
            (x, y) = (x-1, y+1);
            continue;
        }
        if arena[x+1, y+1] == Contents.empty {
            (x, y) = (x+1, y+1);
            continue;
        }
        arena[x,y] = Contents.sand;
        restingSand += 1;
        (x, y) = sandStart;
    } while true;
    halt("unreachable");
}


// -------------------------------------------------------------
// Part 2

proc part2() {
    var arena = loadArena();
    writeln("Part 2: ", insertSandBottom());
}

proc insertSandBottom(): int {
    var arena = loadArena();
    var restingSand = 0;
        var (x, y) = sandStart;
    do {
        if y >= arenaBottom {
            arena[x,y] = Contents.sand;
            restingSand += 1;
            (x, y) = sandStart;
        };
        if arena[x,y+1] == Contents.empty {
            y += 1;
            continue;
        }
        if arena[x-1, y+1] == Contents.empty {
            (x, y) = (x-1, y+1);
            continue;
        }
        if arena[x+1, y+1] == Contents.empty {
            (x, y) = (x+1, y+1);
            continue;
        }
        arena[x,y] = Contents.sand;
        restingSand += 1;
        if (x,y) == sandStart {
            return restingSand;
        }
        (x, y) = sandStart;
    } while true;
    halt("unreachable");
}