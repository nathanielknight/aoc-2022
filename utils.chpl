module Utils {
    use IO;
    use FileSystem;

    iter lines(path: string): string throws {
        var inf = open(path, iomode.r);
        var rdr = inf.reader();
        var line: string;
        while (rdr.readLine(line)) {
            yield line;
        }
    }
}
