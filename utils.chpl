module Utils {
    use IO;
    use FileSystem;
    use Set;

    iter lines(path: string): string throws {
        var inf = open(path, iomode.r);
        var rdr = inf.reader();
        var line: string;
        while (rdr.readLine(line)) {
            yield line;
        }
    }

    proc letters(src: string): Set.set(string) {
        var s = new Set.set(string);
        for c in src.items() {
            s.add(c);
        }
        return s;
    }
}
