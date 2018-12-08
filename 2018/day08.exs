# --- Day 8: Memory Maneuver ---

defmodule LicenseFile.Node do
  # Specifically, a node consists of:
  # - A header, which is always exactly two numbers:
  #   - The quantity of child nodes.
  #   - The quantity of metadata entries.
  # - Zero or more child nodes (as specified in the header).
  # - One or more metadata entries (as specified in the header).
  defstruct(
    nchildren: 0,
    nmetadata: 0,
    children: [],
    parent: nil
  )

  def new_node(nchildren, nmetadata, parent, children \\ []) do
    %LicenseFile.Node{
      nchildren: nchildren,
      nmetadata: nmetadata,
      parent: parent,
      children: children
    }
  end

  def add_child(parent = %{children: children}, child) do
    Map.put(parent, :children, children ++ [child])
  end
end

defmodule LicenseFile do
  alias LicenseFile.Node

  def read(file) do
    File.read!(file)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  def metadata_sum({_structure, metadata}), do: Map.values(metadata) |> List.flatten() |> Enum.sum()

  def value(tree), do: value(tree, 1)
  def value(_tree, nil), do: 0
  def value(tree = {structure, metadata}, id), do: node_value(structure[id], metadata[id], tree)

  defp node_value(%{nchildren: 0}, metadata, _tree), do: Enum.sum(metadata)
  defp node_value(%{children: children}, positions, tree), do: children_values([], children, positions, tree) |> Enum.sum()

  defp children_values(values, _children, [], _tree), do: values
  defp children_values(values, children, [0 | positions], tree), do: children_values(values, children, positions, tree)
  defp children_values(values, children, [position | positions], tree) do
    values ++ [value(tree, Enum.at(children, position - 1))]
    |> children_values(children, positions, tree)
  end

  def tree(entries), do: tree(entries, 0, %{0 => Node.new_node(1, 0, nil)}, %{}, :header)
  def tree([], _current, structure, metadata, :children, 0), do: {structure, metadata}
  # Finish adding children, start adding metadata
  def tree(entries, current, structure, metadata, :children, 0) do
    tree(entries, current, structure, metadata, :metadata)
  end
  # Add children
  def tree(entries, parent, structure, metadata, :children, _nchildren) do
    tree(entries, parent, structure, metadata, :header)
  end
  # New intermediate node
  def tree([nchildren, nmetadata | entries], parent, structure, metadata, :header) do
    current = new_id(structure)
    new_node = Node.new_node(nchildren, nmetadata, parent)
    updated_parent = Node.add_child(structure[parent], current)
    new_structure = Map.put(structure, current, new_node) |> Map.put(parent, updated_parent)

    tree(entries, current, new_structure, metadata, :children, nchildren)
  end
  # Add metadata and go back to parent, to finish or to continue adding siblings
  def tree(entries, current, structure, metadata, :metadata) do
    %{nmetadata: nmetadata, parent: parent} = structure[current]
    {node_metadata, rest} = Enum.split(entries, nmetadata)
    %{nchildren: nsiblings, children: siblings} = structure[parent]

    tree(rest, parent, structure, Map.put(metadata, current, node_metadata), :children, nsiblings - length(siblings))
  end

  defp new_id(tree) when map_size(tree) == 0, do: 0
  defp new_id(tree), do: Enum.max(Map.keys(tree)) + 1
end

LicenseFile.read("./inputs/input08.txt") |> LicenseFile.tree() |> LicenseFile.metadata_sum() |> IO.puts()

# --- Part Two ---

LicenseFile.read("./inputs/input08.txt") |> LicenseFile.tree() |> LicenseFile.value() |> IO.puts()
