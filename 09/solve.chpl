use Set;

use Utils;

config var infileName = "exampleInput.txt";

type Point = (int, int);

proc assert(pred: bool, msg: string) throws {
    if !bool {
        throw new Error(msg);
    }
}

proc diagPoint(p: Point): Point {
    var q: Point = (0, 0);
    if p[0] > 0 then q[0] = 1; else q[0] = -1;
    if p[1] > 0 then q[1] = 1; else q[1] = -1;
    return q;

}

proc rectDistance((x1, y1): Point, (x2, y2): Point): int {
    return abs(x2 - x1) + abs(y2 - y1);
}

proc differences((x1, y1): Point, (x2, y2): Point): Point {
    return (x2 - x1, y2 - y1);
}

proc baseMove(c: string): Point throws {
    select c {
        when "L" do return (-1, 0);
        when "R" do return (1, 0);
        when "U" do return (0, 1);
        when "D" do return (0, -1);
        otherwise throw new Error("invalid move");
    }
}

proc parseMove(c: string): (Point, int) throws {
    const parts = c.split(" ");
    return (baseMove(parts[0]),  (parts[1]: int));
}

iter moves(): Point throws {
    for line in Utils.lines(infileName) {
        if line.strip() == "" then continue;
        const (move, count) = parseMove(line.strip());
        for i in 0..<count {
            yield move;
        }
    }
}

class Rope {
    var head: Point;
    var tail: Point;
    var visited: Set.set(Point);

    proc move(m: Point) {
        this.moveHead(m);
        this.moveTail(m);
        this.visited.add(this.tail);
    }

    proc moveHead(m: Point) {
        this.head += m;
    }

    proc moveTail(headMove: Point) {
        var (dx, dy) = differences(this.tail, this.head);
        if abs(dx) <= 1 && abs(dy) <= 1 then return;
        if this.head[0] == this.tail[0] || this.head[1] == this.tail[1] {
            this.tail += headMove;
            return;
        }
        this.tail = this.head - headMove;
    }
}

param ROPE_SIZE = 10;
const RopeDomain = {0..<ROPE_SIZE};
const TailDomain = {1..<ROPE_SIZE};

class LongRope {
    var knots: [RopeDomain] Point;
    var visited: Set.set(Point);

    proc move(m: Point) {
        this.moveHead(m);
        // Need to let knots do individual moves & get move.
        this.moveTail(m);
    }

    proc moveHead(m: Point) {
        this.knots[0] += m;
    }

    proc moveTail(m: Point) {
        var prevMove = m;
        for knotIdx in TailDomain {
            prevMove = this.moveTailKnot(prevMove, knotIdx);
        }
        this.visited.add(this.knots[this.knots.size - 1]);
    }

    proc moveTailKnot(prevMove: Point, knotIdx: int): Point {
        const prev = this.knots[knotIdx - 1];
        var knot = this.knots[knotIdx];
            
        var (dx, dy) = differences(knot, prev);
        if abs(dx) <= 1 && abs(dy) <= 1 then return (0, 0);
        // follow directly
        if prev[0] == knot[0] {
            const move = (0, sgn(dy));
            this.knots[knotIdx] += move;
            return move;
        }
        if prev[1] == knot[1] {
            const move = (sgn(dx), 0);
            this.knots[knotIdx] += move;
            return move;
        }
        const dp = diagPoint(prev - knot);
        this.knots[knotIdx] += dp;
        // writeln(prev, knot, "->", this.knots[knotIdx]);
        return dp;
    }
    
}

proc anyEq(p: Point, ps: [RopeDomain] Point): (bool, int) {
    for i in ps.domain {
        if p == ps[i] then return (true, i);
    }
    return (false, 0);
}

proc printRope(rope: LongRope) {
    const d: domain(1) = {-20..20};
    for j in d by -1 {
        for i in d {
            const (p, x) = anyEq((i, j), rope.knots);
            if p then write(x); else if (i, j) == (0, 0) then write("s"); else write(".");
        }
        // writeln();
    }
    writeln("--------------------");
}

proc main() {
    var rope = new Rope();
    var longRope = new LongRope();
    for move in moves() {
        rope.move(move);
        longRope.move(move);
        // printRope(longRope);
    }
    writeln("Short rope visited ", rope.visited.size, " spaces");
    writeln("Long rope visited ", longRope.visited.size, " spaces");
}
