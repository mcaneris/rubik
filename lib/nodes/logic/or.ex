defmodule Rubik.Nodes.Logic.Or do
  @moduledoc """
  Documentation for `Rubik.Nodes.Logic.Or`.
  """

  @node_type :executable
  @output :boolean
  @pins [
    %{name: :left, type: :input, data_type: :boolean},
    %{name: :right, type: :input, data_type: :boolean}
  ]

  use Rubik.Node

  defimpl Rubik.Node.Executable do
    def morph(node), do: node

    def execute(node, args) do
      left = Keyword.fetch!(args, :left)
      right = Keyword.fetch!(args, :right)
      result = left || right

      on_execute_address = Rubik.Node.get_on_execute_address(node)

      result
      |> Rubik.Data.new(:boolean)
      |> Rubik.Result.new(on_execute_address)
    end
  end
end
