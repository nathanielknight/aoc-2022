use Set;
use Map;

use Utils;

config param inputfile = "input.txt";

proc main() {
    part1();
    part2();
}

proc initializePriorities(): Map.map(string, int) {
    var itemPriorities = new Map.map(string, int);
    const items = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    var priority = 1;
    for c in items.items() {
        itemPriorities.add(c, priority);
        priority += 1;
    }
    return itemPriorities;
}

const priorities = initializePriorities();

// ----------------------------------------

proc parseBag(input:string): (Set.set(string), Set.set(string)) {
    const bagSize = input.size / 2;
    var left = letters(input.this(0..<bagSize));
    var right =letters(input.this(bagSize..<input.size));
    return (left, right);
}

proc part1() throws {
    var totalPriority = 0;
    for line in Utils.lines(inputfile) {
        var (left, right) = parseBag(line);
        const intersection = left & right;
        if intersection.size != 1 then throw new Error("More than one item in intersection");
        for c in intersection.these() {
            totalPriority += priorities.getValue(c);
        }
    }
    writeln("Part 1 total priority: ", totalPriority);
}

// -------------------------------

var G = {0..2};

iter groups(): [G] string {
    var idx = 0;
    var group: [G] string;
    for line in lines(inputfile) {
        group[idx] = line.strip();
        idx += 1;
        if idx == 3 {
            const item = group;
            idx = 0;
            yield item;
        }
    }
}

proc groupBadgePriority(group: [G] string): int {
    var l = Utils.letters(group[0]);
    l &= Utils.letters(group[1]);
    l &= Utils.letters(group[2]);
    for c in l.these() {
        return priorities.getValue(c);
    }
    return 0;
}

proc part2() {
    var totalPriority = 0;
    for g in groups() {
        totalPriority += groupBadgePriority(g);
    }
    writeln("Part 2 total priority: ", totalPriority);
}