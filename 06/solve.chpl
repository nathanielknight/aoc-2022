config param inputfile = "input.txt";
param packetMarkerLength = 4;
param messageMarkerLength = 14;

proc main() {
    use Utils;
    const p = "1234567890asdf";
    writeln("p = ", p, " letters = ", Utils.letters(p).size);
    const input = Utils.readFile(inputfile);
    writeln("Marker afer ", findPacketMarkerEnd(input), " characters");
    writeln("Marker after ", findMessageMarkerEnd(input), " characters");
}

proc findPacketMarkerEnd(input: string): int {
    for i in 0..<(input.size - packetMarkerLength) {
        if isPacketMarker(input[i..<(i+packetMarkerLength)]) {
            return i + packetMarkerLength;
        }
    }
    return -1;
}

proc isPacketMarker(input: string): bool {
    return (
        input[0] != input[1] &&
        input[0] != input[2] &&
        input[0] != input[3] &&
        input[1] != input[2] &&
        input[1] != input[3] &&
        input[2] != input[3]
    );
}

proc findMessageMarkerEnd(input: string): int {
    for i in 0..<(input.size - messageMarkerLength) {
        if isMessageMarker(input[i..<(i+messageMarkerLength)]) {
            return i + messageMarkerLength;
        }
    }
    return -1;

}

proc isMessageMarker(input: string): bool {
    use Utils;
    return Utils.letters(input).size == messageMarkerLength;
}