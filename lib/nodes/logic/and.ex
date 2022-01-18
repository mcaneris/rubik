defmodule Rubik.Nodes.Logic.And do
  @moduledoc """
  Documentation for `Rubik.Nodes.Logic.And`.
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
      result = left && right

      result
      |> Rubik.Data.new(:boolean)
      |> Rubik.Result.new(Node.get_pin_address(node, :on_execute))
    end
  end
end
