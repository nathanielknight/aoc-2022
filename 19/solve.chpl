proc main() {
    const blueprints = loadBlueprints();
    for b in blueprints {
        writeln(b);
    }
}

enum Resources {ore=0, clay, obsidian}

record Blueprint {
    const id: int,
        oreBotCost: (int, int, int),
        clayBotCost: (int, int, int),
        obsidianBotCost: (int, int, int),
        geodeBotCost: (int, int, int);

    // proc init() {}

    proc init(id, oreCost, clayCost, obsOreCost, obsClayCost, geodeOreCost, geodeObsCost) {
        this.id = id;
        this.oreBotCost = (oreCost, 0, 0);
        this.clayBotCost = (clayCost, 0, 0);
        this.obsidianBotCost = (obsOreCost, obsClayCost, 0);
        this.geodeBotCost = (geodeOreCost, 0, geodeObsCost);
    }
}

config const inf = "input.txt";

iter loadBlueprints() {
    use FileSystem, IO, FormattedIO;

    var id: int;
    var oreCost: int;
    var clayCost: int;
    var obsOreCost: int;
    var obsClayCost: int;
    var geodeOreCost: int;
    var geodeObsCost: int;
    var f = open(inf, iomode.r).reader();
    while f.readf("Blueprint %i: Each ore robot costs %i ore. Each clay robot costs %i ore. Each obsidian robot costs %i ore and %i clay. Each geode robot costs %i ore and %i obsidian.\n",
        id, oreCost, clayCost, obsOreCost, obsClayCost, geodeOreCost, geodeObsCost) {
        writeln({id, oreCost, clayCost, obsOreCost, obsClayCost, geodeOreCost, geodeObsCost});
        yield new Blueprint(id, oreCost, clayCost, obsOreCost, obsClayCost, geodeOreCost, geodeObsCost);
    }
}

param resourceCollectionRate = 1;
param constructionTime = 1;

