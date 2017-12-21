# --- Day 20: Particle Swarm ---

# Each tick, all particles are updated simultaneously. A particle's properties are updated in the following order:

# Increase the X velocity by the X acceleration.
# Increase the Y velocity by the Y acceleration.
# Increase the Z velocity by the Z acceleration.
# Increase the X position by the X velocity.
# Increase the Y position by the Y velocity.
# Increase the Z position by the Z velocity.

# p=<3,0,0>, v=<2,0,0>, a=<-1,0,0>    -4 -3 -2 -1  0  1  2  3  4
# p=<4,0,0>, v=<0,0,0>, a=<-2,0,0>                         (0)(1)

# p=<4,0,0>, v=<1,0,0>, a=<-1,0,0>    -4 -3 -2 -1  0  1  2  3  4
# p=<2,0,0>, v=<-2,0,0>, a=<-2,0,0>                      (1)   (0)

# p=<4,0,0>, v=<0,0,0>, a=<-1,0,0>    -4 -3 -2 -1  0  1  2  3  4
# p=<-2,0,0>, v=<-4,0,0>, a=<-2,0,0>          (1)               (0)

# p=<3,0,0>, v=<-1,0,0>, a=<-1,0,0>    -4 -3 -2 -1  0  1  2  3  4
# p=<-8,0,0>, v=<-6,0,0>, a=<-2,0,0>                         (0)

defmodule ParticleSwarm do

  def closest(file) do
    particles(file)
    |> Enum.map(fn(particle) -> position_at(1_000_000_000, particle) end)
    |> Enum.map(&distance/1)
    |> min_index()
  end

  def survivors(file), do: run(file, 1_000) |> Enum.count()

  defp run(file, rounds) do
    particles(file)
    |> run_and_solve_collisions(rounds)
  end

  defp with_positions(particles, tick) do
    Enum.zip(particles, Enum.map(particles, fn(particle) -> position_at(tick, particle) end))
  end

  defp run_and_solve_collisions(particles, rounds), do: run_and_solve_collisions(particles, rounds, 0)
  defp run_and_solve_collisions(particles, rounds, rounds), do: particles
  defp run_and_solve_collisions(particles, rounds, tick) do
    with_positions(particles, tick)
    |> delete_duplicates()
    |> Enum.map(fn {particle, _} -> particle end)
    |> run_and_solve_collisions(rounds, tick + 1)
  end

  def delete_duplicates(particles_with_positions) do
    particles_with_positions
    |> Enum.filter(fn(p) -> count(p, particles_with_positions, fn {_, position} -> position end) == 1 end)
  end

  defp count(element, list, transform) do
    Enum.filter(list, fn x -> transform.(x) == transform.(element) end)
    |> Enum.count()
  end

  defp min_index(list) do
    min = Enum.min(list)
    Enum.find_index(list, fn(x) -> x == min end)
  end

  defp position_at(n, [p, v, a]) do
    # pn = p + n*v + (n*(n+1)/2)*a
    Enum.zip(p, v)
    |> Enum.map(fn {p, v} -> p + n*v end)
    |> Enum.zip(a)
    |> Enum.map(fn {p, a} -> p + div(n*(n+1), 2)*a end)
  end

  defp distance(position), do: Enum.map(position, &abs/1) |> Enum.sum

  defp particles(file) do
    lines(file)
    |> Enum.map(&parse/1)    
  end

  defp parse(line) do
    # p=<-3770,-455,1749>, v=<-4,-77,53>, a=<11,7,-9>
    [_|pieces] = Regex.run(~r{p=<(.+)>, v=<(.+)>, a=<(.+)>}, line)
    Enum.map(pieces, fn(x) -> String.split(x, ",") end)
    |> Enum.map(fn(piece) -> Enum.map(piece, &String.to_integer/1) end)
  end

  defp lines(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

ParticleSwarm.closest("input20.txt") |> IO.puts

# --- Part Two ---

ParticleSwarm.survivors("input20.txt") |> IO.puts
