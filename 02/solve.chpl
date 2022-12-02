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

record Game {
    var opponent:Move;
    var player:Move;

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
              throw new Error("Invalid game state");
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

proc main() {
    use Utils;
    var totalScore = 0;
    for line in Utils.lines("./input.txt") {
        if line == "\n" then break;
        var game = parseGame(line);
        totalScore += game.score();
    }
    writeln("Total score: ", totalScore);


}