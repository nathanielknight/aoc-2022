
config const inf = "input.txt";
// Iterate over duration & register change of input
iter commands(): (int, int) {
    use Utils;
    for line in Utils.lines(inf) {
        if line.strip() == "" then continue;
        if line.strip() == "noop" {
            yield (1, 0);
        } else {
            const parts = line.strip().split(' ');
            const dx: int = parts[1]: int;
            yield (2, dx);
        }
    }
}

// Get the value of the register at each clock cycle
iter clockValues(): (int, int) {
    var cycle = 0, register = 1;
    for (duration, change) in commands() {
        var left = duration;
        while left  > 0 {
            cycle += 1;
            yield (cycle, register);
            left -= 1;
        }
        register += change;
    }
}

proc signalCycle(c: int): bool {
    return (c - 20) % 40 == 0;
}

iter signalValues(): (int, int) {
    for (c, x) in clockValues() {
        if signalCycle(c) then yield (c, x);
    }
}

proc shouldDraw(c, x) {
    const cursorLocation = (c - 1) % 40;
    return abs(x - cursorLocation) <= 1;
}

proc drawSignal() {
    for (c, x) in clockValues() {
        if shouldDraw(c, x) then write("#"); else write(".");
        if c % 40 == 0 then write("\n");
    }
}   

proc main() {
    var total = 0;
    for (c, s) in signalValues() {
        total += c * s;
    }
    writeln("Total signal value: ", total);
    drawSignal();
}