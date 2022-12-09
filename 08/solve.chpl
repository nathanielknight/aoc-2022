param exampleInput = "30373\
25512\
65332\
33549\
35390";

config param gridSize: int = 99;

const D: domain(2) = {0..<gridSize,0..<gridSize};
const G: range = 0..<gridSize;

proc parseInput(input: [G] string): [D] int {
    var nums: [D] int;
    for (i, j) in D {
        nums[i,j] = input[i][j] :int;
    }
    return nums;
}

proc treesVisible(map: [D] int): int {
    use Set;
    var visibles = new Set.set((int, int));
    // rows
    var maxSeen = -1;
    for row in G {
        maxSeen = -1;
        label rowLeft for col in G {
            if map[row,col] > maxSeen {
                visibles.add((row, col));
                maxSeen = map[row, col];
            } 
        }
        maxSeen = -1;
        label rowRight for col in G by -1 {
            if map[row,col] > maxSeen {
                visibles.add((row, col));
                maxSeen = map[row, col];
            } 
        }
    }
    // columns
    for col in G {
        maxSeen = -1;
        label colLeft for row in G {
            if map[row,col] > maxSeen {
                visibles.add((row, col));
                maxSeen = map[row, col];
            } 
        }
        maxSeen = -1;
        label colRight for row in G by -1 {
            if map[row,col] > maxSeen {
                visibles.add((row, col));
                maxSeen = map[row, col];
            } 
        }
    }
    return visibles.size;
}

proc visionScore(map: [D] int, (x, y): (int, int)): int {
    var scores: [{1..4}]int = 0;
    const baseHeight = map[x,y];
    for i in (x+1)..<gridSize {
        scores[1] += 1;
        if map[i, y] >= baseHeight then break;
    }
    for i in 0..(x-1) by -1 {
        scores[2] += 1;
        if map[i, y] >= baseHeight then break;
    }
    for j in (y+1)..<gridSize {
        scores[3] += 1;
        if map[x, j] >= baseHeight then break;
    }
    for j in 0..(y-1) by -1 {
        scores[4] += 1;
        if map[x,j] >= baseHeight then break;
    }
    return scores[1] * scores[2] * scores[3] * scores[4];
}

iter scores(map: [D] int): int {
    for i in 1..<(gridSize -1) {
        for j in 1..<(gridSize -1) {
            yield visionScore(map, (i,j));
        }
    }
}

proc maxScore(map: [D]int): int {
    var maxSeen = -1;
    for score in scores(map) {
        if score > maxSeen then maxSeen = score;
    }
    return maxSeen;
}

proc main() {
    use Utils;
    // writeln("Example input: ", treesVisible(parseInput(exampleInput)), "  visible");
    const input: [G]string = Utils.lines("input.txt");
    const map = parseInput(input);
    writeln("Part 1: ", treesVisible(map), " trees visible");
    writeln("Part 2: max score = ", maxScore(map));

}