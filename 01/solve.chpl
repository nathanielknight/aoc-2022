config var inputfile = "input.txt";

use FileSystem;
use IO;


var I: domain(1) = {1..3};
var maxes: [I] int;

proc sendMax(v:int) {
  if v > maxes[1] {
    maxes[2..3] = maxes[1..2];
    maxes[1] = v;
    return;
  }
  if v > maxes[2] {
    maxes[3] = maxes[2];
    maxes[2] = v;
    return;
  }
  if v > maxes[3] {
    maxes[3] = v;
    return;
  }
}

proc maxSum(): int {
  var acc: int = 0;
  for m in maxes {
    acc += m;
  }
  return acc;
}


var inf = open(inputfile, iomode.r);
var rdr = inf.reader();
var line:string;
var acc:int = 0;

while (rdr.readLine(line)) {
  if (line == "\n") {
    sendMax(acc);
    acc = 0;
  } else {
    acc += line : int;
  }
}

writeln("Max: ", maxes[1]);
writeln("Max 3: ", maxSum(), " (", maxes, ")");

