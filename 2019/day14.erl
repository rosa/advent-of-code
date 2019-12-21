% --- Day 14: Space Stoichiometry ---

-module(day14).
-export([read_reactions/1, make_fuel/2, find_max_fuel/4]).

find_reaction("ORE", _) -> {{1, "ORE"}, []};
find_reaction(Chemical, [Reaction={{_, Chemical}, _}|_]) ->
  Reaction;
find_reaction(Chemical, [_|Reactions]) ->
  find_reaction(Chemical, Reactions).

calculate_required(Chemical, Quantity, Stock) ->
  case dict:find(Chemical, Stock) of
    {ok, Existing} ->
      if
        Quantity < Existing ->
          % We have more than we need. Return 0 as required and decrement stock
          [0, dict:store(Chemical, Existing - Quantity, Stock)];
        true
          % We need to produce some units. Use all stock and return how many we need
          -> [Quantity - Existing, dict:store(Chemical, 0, Stock)]
      end;
    error ->
      [Quantity, Stock]
  end.

add_to_dictionary(Chemical, Quantity, Dictionary) ->
  case dict:find(Chemical, Dictionary) of
    {ok, Existing} ->
      dict:store(Chemical, Quantity + Existing, Dictionary);
    error ->
      dict:store(Chemical, Quantity, Dictionary)
  end.

state_requirements(_, 0) -> [];
state_requirements(Inputs, Times) ->
  lists:map(fun({Quantity, Chemical}) -> {Times*Quantity, Chemical} end, Inputs).

make(Chemical, Quantity, Reactions, Stock) ->
  {{OutputN, _}, Inputs} = find_reaction(Chemical, Reactions),
  [Required, UpdatedStock] = calculate_required(Chemical, Quantity, Stock),
  Times = math:ceil(Required/OutputN),
  [Times * OutputN, state_requirements(Inputs, Times), add_to_dictionary(Chemical, Times * OutputN - Required, UpdatedStock)].

process_reactions([], _, _, Used) -> dict:find("ORE", Used);
process_reactions([{0, _}|Pending], Reactions, Stock, Used) ->
  process_reactions(Pending, Reactions, Stock, Used);
process_reactions([{Quantity, Chemical}|Pending], Reactions, Stock, Used) ->
  [Obtained, Requirements, UpdatedStock] = make(Chemical, Quantity, Reactions, Stock),
  process_reactions(lists:append(Pending, Requirements), Reactions, UpdatedStock, add_to_dictionary(Chemical, Obtained, Used)).

parse_ingredient(Ingredient) ->
  [Q, Chemical] = lists:map(fun string:trim/1, string:split(string:trim(Ingredient), " ")),
  {Quantity, []} = string:to_integer(Q),
  {Quantity, Chemical}.

parse_reaction(Reaction) ->
  [Inputs, Output] = string:split(Reaction, "=>"),
  {parse_ingredient(Output), lists:map(fun parse_ingredient/1, string:split(Inputs, ",", all))}.

read_reactions(Filename) ->
  {ok, Data} = file:read_file(Filename),
  Lines = string:split(string:chomp(binary_to_list(Data)), "\n", all),
  lists:map(fun parse_reaction/1, Lines).

make_fuel(Reactions, Quantity) ->
  process_reactions([{Quantity, "FUEL"}], Reactions, dict:new(), dict:new()).

% > day14:make_fuel(day14:read_reactions("inputs/input14.txt"), 1).
% {ok,201324.0}

% --- Part Two ---
is_max(_, Ore, _, Required) when Required > Ore -> false;
is_max(Reactions, Ore, Current, _) ->
  {ok, Required} = make_fuel(Reactions, Current + 1),
  Required > Ore.

find_max_fuel(Reactions, Ore, Start, End) ->
  Middle = trunc((Start + End) / 2),
  {ok, Required} = make_fuel(Reactions, Middle),
  Max = is_max(Reactions, Ore, Middle, Required),
  if
    Max ->
      Middle;
    true ->
      if
        Required > Ore ->
          find_max_fuel(Reactions, Ore, Start, Middle - 1);
        true ->
          find_max_fuel(Reactions, Ore, Middle + 1, End)
      end
  end.

% > day14:find_max_fuel(day14:read_reactions("inputs/input14.txt"), 1000000000000, 1, 1000000000000).
% 6326857
