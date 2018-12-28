# --- Day 24: Immune System Simulator 20XX ---

defmodule ImmuneSystemSimulator do
  alias ImmuneSystemSimulator.Group

  def search_for_boost(set = {immune_system_army, infection_army}, boost) do
    IO.puts(boost)
    combat = combat({boost(immune_system_army, boost), infection_army})
    winner = winner(combat)

    if winner == :immune, do: combat_result(combat), else: search_for_boost(set, boost + 1)
  end

  def combat_result(army), do: Enum.map(army, fn group -> group.units end) |> Enum.sum()

  def combat({immune_system_army, []}), do: immune_system_army
  def combat({[], infection_army}), do: infection_army
  def combat(set) do
    fight(set)
    |> combat()
  end

  defp winner(army), do: hd(army).type

  def fight({immune_system_army, infection_army}) do
    target_selection(immune_system_army, infection_army)
    |> attack(immune_system_army ++ infection_army)
  end

  defp boost(army, boost), do: Enum.map(army, fn group -> Group.boost(group, boost) end)

  defp target_selection(immune_system_army, infection_army) do
    # During the target selection phase, each group attempts to choose one target.
    Map.merge(choose_targets(immune_system_army, infection_army), choose_targets(infection_army, immune_system_army))
  end

  # During the target selection phase, each group attempts to choose one target.
  defp choose_targets(choosing_army, target_army) do
    Enum.sort(choosing_army, fn g1, g2 -> Group.gt_for_choosing(g1, g2) end)
    |> choose_targets(target_army, Enum.reduce(choosing_army, %{}, fn group, acc -> Map.put(acc, group.id, nil) end))
  end
  defp choose_targets([], _, choices), do: choices
  defp choose_targets(_, [], choices), do: choices
  defp choose_targets([group | choosing_army], target_army, choices) do
    choice = Group.best_target(group, target_army)
    if choice do
      choose_targets(choosing_army, List.delete(target_army, choice), Map.put(choices, group.id, choice.id))
    else
      choose_targets(choosing_army, target_army, choices)
    end
  end

  # During the attacking phase, each group deals damage to the target it selected, if any.
  # Groups attack in decreasing order of initiative, regardless of whether they are part of the infection or the immune system.
  # (If a group contains no units, it cannot attack.)
  defp attack(choices, groups), do: attack(Enum.sort(groups, fn(g1, g2) -> g1.initiative > g2.initiative end), choices, map_by_id(groups))
  defp attack([], _choices, all_groups), do: split_and_filter(Map.values(all_groups))
  defp attack([%{id: id} | groups], choices, all_groups) do
    choice = all_groups[choices[id]]
    group = all_groups[id]
    if group && choice do
      attacked = Group.attack(group, choice)
      attack(groups, choices, update(all_groups, attacked))
    else
      attack(groups, choices, all_groups)
    end
  end

  defp split_and_filter(groups), do: split_and_filter(groups, {[], []})
  defp split_and_filter([], filtered), do: filtered
  defp split_and_filter([group | groups], filtered = {immune_system_army, infection_army}) do
    cond do
      Group.dead?(group) -> split_and_filter(groups, filtered)
      group.type == :infection -> split_and_filter(groups, {immune_system_army, infection_army ++ [group]})
      group.type == :immune -> split_and_filter(groups, {immune_system_army ++ [group], infection_army})
    end
  end

  defp map_by_id(groups), do: Enum.reduce(groups, %{}, fn group, acc -> Map.put(acc, group.id, group) end)

  defp update(all_groups, attacked) do
    if Group.dead?(attacked) do
      Map.delete(all_groups, attacked.id)
    else
      Map.put(all_groups, attacked.id, attacked)
    end
  end
end

defmodule ImmuneSystemSimulator.Group do
  # Units within a group all have the same hit points (amount of damage a unit can take before it is destroyed),
  # attack damage (the amount of damage each unit deals), an attack type,
  # an initiative (higher initiative units attack first and win ties),
  # and sometimes weaknesses or immunities
  defstruct(
    id: nil,
    type: nil,
    units: 0,
    hp: 0,
    attack_type: nil,
    attack_damage: 0,
    initiative: 0,
    weaknesses: [],
    immunities: []
  )

  def new(attributes) do
    %ImmuneSystemSimulator.Group{
      type: Keyword.get(attributes, :type),
      id: Keyword.get(attributes, :id),
      units: Keyword.get(attributes, :units),
      hp: Keyword.get(attributes, :hp),
      immunities: Keyword.get(attributes, :immunities) || [],
      weaknesses: Keyword.get(attributes, :weaknesses) || [],
      attack_type: Keyword.get(attributes, :attack_type),
      attack_damage: Keyword.get(attributes, :attack_damage),
      initiative: Keyword.get(attributes, :initiative)
    }
  end

  def boost(group = %{attack_damage: attack_damage}, boost), do: %{group | attack_damage: attack_damage + boost}

  # Each group also has an effective power: the number of units in that group multiplied by their attack damage.
  def effective_power(group), do: group.units * group.attack_damage

  def attack(attacking, defending), do: take_hit(defending, damage(attacking, defending))

  def damage(attacking = %{attack_type: attack_type}, defending) do
    # By default, an attacking group would deal damage equal to its effective power to the defending group.
    # However, if the defending group is immune to the attacking group's attack type, the defending group instead takes no damage;
    # if the defending group is weak to the attacking group's attack type, the defending group instead takes double damage.
    cond do
      attack_type in defending.immunities -> 0
      attack_type in defending.weaknesses -> effective_power(attacking)*2
      true -> effective_power(attacking)
    end
  end

  def take_hit(defending = %{units: units, hp: hp}, damage) do
    units_lost = div(damage, hp)
    %{defending | units: units - units_lost}
  end

  def dead?(%{units: units}), do: units <= 0

  # In decreasing order of effective power, groups choose their targets;
  # in a tie, the group with the higher initiative chooses first.
  def gt_for_choosing(g1, g2), do: effective_power(g1) > effective_power(g2) || (effective_power(g1) == effective_power(g2) && g1.initiative > g2.initiative)

  # The attacking group chooses to target the group in the enemy army to which it would deal the most damage
  # (after accounting for weaknesses and immunities, but not accounting for whether the defending group
  # has enough units to actually receive all of that damage).
  # If an attacking group is considering two defending groups to which it would deal equal damage,
  # it chooses to target the defending group with the largest effective power; if there is still a tie,
  # it chooses the defending group with the highest initiative.
  # If it cannot deal any defending groups damage, it does not choose a target. 
  # Defending groups can only be chosen as a target by one attacking group.
  def best_target(attacking, possible_targets) do
    if Enum.any?(possible_targets, fn target -> damage(attacking, target) > 0 end) do
      Enum.sort(possible_targets, fn g1, g2 -> gt_as_target(g1, g2, attacking) end) |> hd()
    end
  end

  def gt_as_target(g1, g2, attacking) do
    damage(attacking, g1) > damage(attacking, g2) ||
    (damage(attacking, g1) == damage(attacking, g2) && effective_power(g1) > effective_power(g2)) ||
    (effective_power(g1) == effective_power(g2) && g1.initiative > g2.initiative)
  end
end

# Immune System:
immune_system_army = [
  ImmuneSystemSimulator.Group.new(type: :immune,  id: 0, units: 1193, hp: 4200, immunities: [:slashing, :radiation, :fire], attack_type: :bludgeoning, attack_damage: 33, initiative: 2),
  ImmuneSystemSimulator.Group.new(type: :immune,  id: 1, units: 151,  hp: 9047, immunities: [:slashing, :cold], weaknesses: [:fire], attack_type: :slashing, attack_damage: 525, initiative: 1),
  ImmuneSystemSimulator.Group.new(type: :immune,  id: 2, units: 218,  hp: 4056, immunities: [:fire, :slashing], weaknesses: [:radiation], attack_type: :fire, attack_damage: 176, initiative: 9),
  ImmuneSystemSimulator.Group.new(type: :immune,  id: 3, units: 5066, hp: 4687, weaknesses: [:slashing, :fire], attack_type: :slashing, attack_damage: 8, initiative: 8),
  ImmuneSystemSimulator.Group.new(type: :immune,  id: 4, units: 2023, hp: 5427, weaknesses: [:slashing], attack_type: :slashing, attack_damage: 22, initiative: 3),
  ImmuneSystemSimulator.Group.new(type: :immune,  id: 5, units: 3427, hp: 5532, weaknesses: [:slashing], attack_type: :cold, attack_damage: 15, initiative: 13),
  ImmuneSystemSimulator.Group.new(type: :immune,  id: 6, units: 1524, hp: 8584, immunities: [:fire], attack_type: :fire, attack_damage: 49, initiative: 7),
  ImmuneSystemSimulator.Group.new(type: :immune,  id: 7, units: 82,   hp: 2975, weaknesses: [:cold, :fire], attack_type: :bludgeoning, attack_damage: 359, initiative: 5),
  ImmuneSystemSimulator.Group.new(type: :immune,  id: 8, units: 5628, hp: 9925, immunities: [:cold], weaknesses: [:fire], attack_type: :radiation, attack_damage: 17, initiative: 11),
  ImmuneSystemSimulator.Group.new(type: :immune,  id: 9, units: 1410, hp: 9872, immunities: [:fire], weaknesses: [:cold], attack_type: :slashing, attack_damage: 60, initiative: 10)
]

# Infection:
infection_army = [
 ImmuneSystemSimulator.Group.new(type: :infection, id: 10, units: 5184, hp: 12832, weaknesses: [:fire, :cold], attack_type: :fire, attack_damage: 4, initiative: 4),
 ImmuneSystemSimulator.Group.new(type: :infection, id: 11, units: 2267, hp: 13159, immunities: [:bludgeoning], weaknesses: [:fire], attack_type: :fire, attack_damage: 10, initiative: 4),
 ImmuneSystemSimulator.Group.new(type: :infection, id: 12, units: 3927, hp: 50031, immunities: [:fire, :radiation], weaknesses: [:slashing, :cold], attack_type: :cold, attack_damage: 23, initiative: 17),
 ImmuneSystemSimulator.Group.new(type: :infection, id: 13, units: 9435, hp: 23735, immunities: [:cold], attack_type: :cold, attack_damage: 4, initiative: 12),
 ImmuneSystemSimulator.Group.new(type: :infection, id: 14, units: 3263, hp: 26487, weaknesses: [:fire], attack_type: :fire, attack_damage: 11, initiative: 14),
 ImmuneSystemSimulator.Group.new(type: :infection, id: 15, units: 222, hp: 15916, weaknesses: [:fire], attack_type: :fire, attack_damage: 135, initiative: 18),
 ImmuneSystemSimulator.Group.new(type: :infection, id: 16, units: 972, hp: 45332, weaknesses: [:bludgeoning, :slashing], attack_type: :cold, attack_damage: 86, initiative: 19),
 ImmuneSystemSimulator.Group.new(type: :infection, id: 17, units: 1456, hp: 39583, immunities: [:radiation], weaknesses: [:cold, :fire], attack_type: :bludgeoning, attack_damage: 53, initiative: 16),
 ImmuneSystemSimulator.Group.new(type: :infection, id: 18, units: 2813, hp: 28251, attack_type: :cold, attack_damage: 17, initiative: 15),
 ImmuneSystemSimulator.Group.new(type: :infection, id: 19, units: 1179, hp: 42431, immunities: [:fire, :slashing], attack_type: :fire, attack_damage: 55, initiative: 6)
]

ImmuneSystemSimulator.combat({immune_system_army, infection_army})
|> ImmuneSystemSimulator.combat_result()
|> IO.puts()

# --- Part Two ---

# Boost 60 stays in a deadlock, and 61 makes the immune system win
ImmuneSystemSimulator.search_for_boost({immune_system_army, infection_army}, 61)
|> IO.puts()
