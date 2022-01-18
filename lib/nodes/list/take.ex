defmodule Rubik.Nodes.List.Take do
  @moduledoc """
  Documentation for `Rubik.Nodes.List.Take`.
  """

  @node_type :executable
  @output :list
  @pins [
    %{name: :list, type: :input, data_type: :list},
    %{name: :count, type: :input, data_type: :integer}
  ]

  use Rubik.Node

  defimpl Rubik.Node.Executable do
    def morph(node), do: node

    def execute(node, args) do
      list = Keyword.fetch!(args, :list)
      count = Keyword.fetch!(args, :count) |> Rubik.Common.cast(:integer)

      result = Enum.take(list, count)

      on_execute_address = Rubik.Node.get_on_execute_address(node)

      result
      |> Rubik.Data.new(:list)
      |> Rubik.Result.new(on_execute_address)
    end
  end
end
