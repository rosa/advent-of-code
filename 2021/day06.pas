// --- Day 6: Lanternfish ---

program Day06; {$MODE OBJFPC} {$COPERATORS ON}

uses
 Sysutils,
 StrUtils,
 Types;

const
  FILE_NAME = 'inputs/input06.txt';

type
  FishCounts = Array[0..8] of Int64;

var
  fish: TIntegerDynArray;
  counts: FishCounts;
  i, f: Integer;


function StartingFish(filename: String): TIntegerDynArray;
var
  line: AnsiString;
  input: TextFile;
  stringFish: TStringDynArray;
  integerFish: TIntegerDynArray;
  i: Integer;

begin
  Assign (input,filename);
  Reset (input);
  line := '';
  while not Eof(input) and (line<>'\n') do
    Readln (input,line);
  Close (input);

  stringFish := SplitString (line,',');
  SetLength (integerFish,Length(stringFish));

  for i := 0 to Length(stringFish) - 1 do
    integerFish[i] := StrToInt(stringFish[i]);

  StartingFish := integerFish;
end;


procedure SimulateDay(var current: FishCounts);
var
  next: FishCounts;
  i: Integer;

begin
  for i := 0 to Length(current) - 1 do
    next[i] := current[(i + 1) mod Length (current)];
  next[6] := next[6] + next[8];

  current := next;
end;

function Simulate(current: FishCounts; days: Integer): Int64;
var
  i, sum: Int64;

begin
  for i := 1 to days do
    SimulateDay (current);

  sum := 0;
  for i in current do
    sum := sum + i;

  Simulate := sum;
end;


begin
  for i := 0 to Length(counts) - 1 do
    counts[i] := 0;

  fish := StartingFish (FILE_NAME);
  for f in fish do
    counts[f] := counts[f] + 1;

  writeln (Simulate (counts, 80));
  writeln (Simulate (counts, 256));
end.

// fpc day06.pas
// ./day06
// 354564
// 1609058859115
