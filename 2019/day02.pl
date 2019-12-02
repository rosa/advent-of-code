% --- Day 2: 1202 Program Alarm ---

run(R) :-
  read_program(Program),
  replace_at(Program, 1, 12, Program2), % Replace position 1 with the value 12 
  replace_at(Program2, 2, 2, Program3), % and replace position 2 with the value 2
  execute(Program3, Program3, 0, R).

read_program(Intcodes) :-
  open('inputs/input02.txt', read, Stream),
  peek_string(Stream, 8000, Program),
  close(Stream),
  split_string(Program, ",", "\n", Stringcodes),
  maplist(number_codes, Intcodes, Stringcodes).

% 99         : halt
% 1 P1 P2 P3 : P3 <- P1 + P2
% 2 P1 P2 P3 : P3 <- P1 * P2
execute([99|_], [R|_], _, R).
execute([Opcode, P1, P2, P3|_], Program, Ip, Result) :-
  apply_intcode(Opcode, P1, P2, Program, R),
  replace_at(Program, P3, R, Changed),
  Jp is Ip + 4,
  drop(Changed, Jp, Rest),
  execute(Rest, Changed, Jp, Result).

apply_intcode(Opcode, P1, P2, Program, R) :-
  nth0(P1, Program, I1),
  nth0(P2, Program, I2),
  apply_intcode(Opcode, I1, I2, R).
apply_intcode(1, I1, I2, R) :- R is I1 + I2.
apply_intcode(2, I1, I2, R) :- R is I1 * I2.

replace_at([_|T], 0, X, [X|T]).
replace_at([H|T], I, X, [H|R]) :-
  I > 0,
  J is I - 1,
  replace_at(T, J, X, R).

drop(L, 0, L).
drop([_|T], I, R) :- 
  J is I - 1,
  drop(T, J, R).

% ?- run(R).
% R = 2692315

% --- Part Two ---

% Find the input noun and verb that cause the program to
% produce the output 19690720. What is 100 * noun + verb?
find_input(R) :-
  noun_and_verb(N, V),
  R is 100 * N + V.

noun_and_verb(N, V) :-
  read_program(Program),
  noun_and_verb(Program, 0, 0, 19690720, N, V).

noun_and_verb(Program, N, V, R, N, V) :- run(Program, N, V, R), !.
noun_and_verb(Program, N, V, R, N1, V1) :-
  V =< 99,
  V2 is V + 1,
  noun_and_verb(Program, N, V2, R, N1, V1).
noun_and_verb(Program, N, 100, R, N1, V1) :-
  N2 is N + 1,
  noun_and_verb(Program, N2, 0, R, N1, V1).

run(Program, N, V, R) :-
  replace_at(Program, 1, N, Program2), % Replace position 1 with the noun
  replace_at(Program2, 2, V, Program3), % and replace position 2 with the verb
  execute(Program3, Program3, 0, R).

% ?- noun_and_verb(N, V).
% N = 95,
% V = 7
