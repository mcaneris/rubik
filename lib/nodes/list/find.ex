defmodule Rubik.Nodes.List.Find do
  @moduledoc """
  Documentation for `Rubik.Nodes.List.Find`.
  """

  @node_type :executable
  @output :any
  @pins [
    %{name: :list, type: :input, data_type: :list},
    %{name: :key, type: :input, data_type: :string},
    %{name: :value, type: :input, data_type: :string}
  ]

  use Rubik.Node

  defimpl Rubik.Node.Executable do
    def morph(node), do: node

    def execute(node, args) do
      list = Keyword.fetch!(args, :list)
      key = Keyword.fetch!(args, :key)
      value = Keyword.fetch!(args, :value)

      result = Enum.find(list, fn item -> Map.get(item, String.to_atom(key)) == value end)

      on_execute_address = Rubik.Node.get_on_execute_address(node)

      result
      |> Rubik.Data.new(:any)
      |> Rubik.Result.new(on_execute_address)
    end
  end
end
