use List;

use Utils;

config param inputFile = "input.txt";
config param stacks = 9;


proc main() {
    cobegin {
        part1();
        part2();
    }
}

proc part1() {
    var (stacskSrc, movesSrc) = parseInput(inputFile);
    var stacks = parseStacks(stacskSrc);
    for moveSrc in movesSrc {
        const move = parseMove(moveSrc);
        stacks.move(move.amount, move.src, move.dest);
    }
    writeln("Part 1 solution: ", stacks.tops());
}

proc part2() {
    var (stacskSrc, movesSrc) = parseInput(inputFile);
    var stacks = parseStacks(stacskSrc);
    for moveSrc in movesSrc {
        const move = parseMove(moveSrc);
        stacks.move2(move.amount, move.src, move.dest);
    }
    writeln("Part 2 solution: ", stacks.tops());
}

proc parseInput(inputFile: string): (List.list(string), List.list(string)) {
    var stacks = new List.list(string);
    var moves = new List.list(string);
    for line in Utils.lines(inputFile) {
        if line.find("[") >= 0 then stacks.append(line);
        if line.find("move") >= 0 then moves.append(line);
    }
    return (stacks, moves);
}

// -------------------------------------------------
// Stacks
const StackIds: domain(1) = {1..stacks};

class Stacks {
    var stacks: [StackIds] List.list(string);

    proc init(stacks: [StackIds] List.list(string)) {
        this.stacks = stacks;
    }

    proc move(amount: int, from: int, to: int) {
        for ir in 0..<amount {
            const x = this.stacks[from].pop();
            this.stacks[to].append(x);
        }
    }

    proc move2(amount: int, from: int, to: int) {
        var tmp = new List.list(string);
        for i in 0..<amount {
            tmp.append(this.stacks[from].pop());
        }
        while tmp.size > 0 {
            this.stacks[to].append(tmp.pop());
        }
    }

    proc tops(): string {
        var s = "";
        for stack in this.stacks do s += stack.last();
        return s;
    }
}

proc parseStacks(ref inputs: List.list(string)): Stacks{
    var stacks: [StackIds] List.list(string);
    for id in StackIds {
        stacks[id] = new List.list(string);
    }
    while inputs.size > 0 {
        var line = inputs.pop();
        for idx in StackIds {
            const pos = 1 + 4 * (idx - 1);
            if line.size > pos && !line.this(pos).isSpace() {
                const s: string = line.this(pos);
                stacks[idx].append(s);
            }
        }
    }
    return new Stacks(stacks);
}

// -------------------------------------------------
// Moves

record Move {
    const src: int; 
    const dest: int; 
    const amount: int;
}

proc parseMove(src: string): Move {
    var parts: [0..5] string = src.split();
    return new Move(src=parts[3]:int, dest=parts[5]:int, amount=parts[1]:int);
}
