
class Assignment {
    const left: (int, int);
    const right: (int, int);

    proc init(boundsString: string) {
        var values : [{1..4}]int;
        values = getBoundsValues(boundsString);
        this.left = (values(1), values(2));
        this.right = (values(3), values(4));
    }

    proc isContained(): bool {
        return encloses(left,   right) || encloses(right, left);
    }

    proc hasOverlap(): bool {
        return !(left[1] < right[0] || right[1] < left[0]);
    }
}

proc contains(x: int, interval: (int, int)): bool {
    return x >= interval[0] && x <= interval[1];
}

proc encloses(left: (int, int), right: (int, int)): bool {
    if left[0] < right[0] then return encloses(right, left);
    return contains(left[0], right) && contains(left[1], right);

}

iter getBoundsValues(src: string): int {
    for rangeStr in src.split(",") {
        for bound in rangeStr.split("-") {
            yield bound : int;
        }
    }
}

proc main() {
    use Utils;
    var containedAssignments = 0;
    var overlappingAssignments = 0;
    for line in Utils.lines("./input.txt") {
        if line == "\n" then break;
        const a = new Assignment(line);
        if a.isContained() then containedAssignments += 1;
        if a.hasOverlap() then overlappingAssignments += 1;
    }
    writeln("Contained Assignments: ", containedAssignments);
    writeln("Overlapping Assignments: ", overlappingAssignments);
}   
