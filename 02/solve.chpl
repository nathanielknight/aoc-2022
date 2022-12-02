enum Move {
    Rock = 1, Paper = 2, Scissors = 3
}



proc parseOpponentMove(m: string): Move throws {
    select m {
        when "A" do return Move.Rock;
        when "B" do return Move.Paper;
        when "C" do return Move.Scissors;
        otherwise do
            throw new Error("Invalid opponent move");
    }
}

proc parsePlayerMove(m: string): Move throws {
    select m {
        when "X" do return Move.Rock;
        when "Y" do return Move.Paper;
        when "Z" do return Move.Scissors;
        otherwise do
            throw new Error("Invalid player move");

    }
}

enum Outcome {
    Win = 6, Loss = 0, Draw = 3
}

proc parseDesiredOutcome(src: string): Outcome throws {
    select src {
        when "X" do return Outcome.Loss;
        when "Y" do return Outcome.Draw;
        when "Z" do return Outcome.Win;
        otherwise do
            throw new Error("Invalid desired move");
    }
}

record Game {
    var opponent: Move;
    var player: Move;

    proc init(opponent: Move, player: Move) {
        this.opponent = opponent;
        this.player = player;
    }

    proc outcome(): Outcome throws {
        select (this.player, this.opponent) {
            when (Move.Rock, Move.Rock) do return Outcome.Draw;
            when (Move.Scissors, Move.Scissors) do return Outcome.Draw;
            when (Move.Paper, Move.Paper) do return Outcome.Draw;

            when (Move.Rock, Move.Scissors) do return Outcome.Win;
            when (Move.Scissors, Move.Paper) do return Outcome.Win;
            when (Move.Paper, Move.Rock) do return Outcome.Win;

            when (Move.Rock, Move.Paper) do return Outcome.Loss;
            when (Move.Scissors, Move.Rock) do return Outcome.Loss;
            when (Move.Paper, Move.Scissors) do return Outcome.Loss;

            otherwise do
              throw new Error("Invalid Part 1 game state");
        }
    }

    proc score(): int throws {
        return this.player:int + this.outcome():int;
    }
}

proc parseGame(src: string): Game throws {
    var opponentMove = src[0];
    var playerMove = src[2];
    return new Game(parseOpponentMove(opponentMove), parsePlayerMove(playerMove));
}


record Strategy {
    var opponent: Move;
    var desiredOutcome: Outcome;

    proc init(opponent: Move, desiredOutcome: Outcome) {
        this.opponent = opponent;
        this.desiredOutcome = desiredOutcome;
    }

    proc playerMove(): Move throws {
        select (this.opponent, this.desiredOutcome) {
            when (Move.Rock, Outcome.Win) do return Move.Paper;
            when (Move.Paper, Outcome.Win) do return Move.Scissors;
            when (Move.Scissors, Outcome.Win) do return Move.Rock;

            when (Move.Rock, Outcome.Loss) do return Move.Scissors;
            when (Move.Paper, Outcome.Loss) do return Move.Rock;
            when (Move.Scissors, Outcome.Loss) do return Move.Paper;

            when (Move.Rock, Outcome.Draw) do return Move.Rock;
            when (Move.Paper, Outcome.Draw) do return Move.Paper;
            when (Move.Scissors, Outcome.Draw) do return Move.Scissors;

            otherwise do
                throw new Error("Invalid Part 2 game state");
        }
    }

    proc score(): int throws {
        var game = new Game(this.opponent, this.playerMove());
        return game.score();
    }
}

proc parseStrategy(src: string): Strategy throws {
    var opponentMove = parseOpponentMove(src[0]);
    var desiredOutcome = parseDesiredOutcome(src[2]);
    return new Strategy(opponentMove, desiredOutcome);
}


proc main() throws {
    use Utils;
    var part1Score = 0;
    var part2Score = 0;
    for line in Utils.lines("./input.txt") {
        if line == "\n" then break;
        var game = parseGame(line);
        part1Score += game.score();
        var strategy = parseStrategy(line);
        part2Score += strategy.score();
    }
    writeln("Part 1 Score: ", part1Score);
    writeln("Part 2 Score: ", part2Score);
}