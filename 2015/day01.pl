% --- Day 1: Not Quite Lisp ---

floor(N) :-
  read_instructions(Text),
  string_chars(Text, Instructions),
  count_floors(Instructions, N).

read_instructions(Text) :-
  open('inputs/input01.txt', read, Str),
  peek_string(Str, 8000, Text),
  close(Str).

count_floors([], 0).
count_floors(['('|Instructions], N) :-
  count_floors(Instructions, M),
  N is M + 1.
count_floors([')'|Instructions], N) :-
  count_floors(Instructions, M),
  N is M - 1.


% ?- floor(N).
% N = 232 .

% --- Part Two ---

basement_index(Index) :-
  read_instructions(Text),
  string_chars(Text, Instructions),
  until_basement(Instructions, 0, Index, 0).

until_basement(_, Index, Index, -1).
until_basement(['('|Instructions], Index, BasementIndex, N) :-
  M is N + 1,
  Next is Index + 1,
  until_basement(Instructions, Next, BasementIndex, M).
until_basement([')'|Instructions], Index, BasementIndex, N) :-
  M is N - 1,
  Next is Index + 1,
  until_basement(Instructions, Next, BasementIndex, M).

% ?- basement_index(Index).
% Index = 1783 .
