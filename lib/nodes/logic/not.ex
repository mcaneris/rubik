defmodule Rubik.Nodes.Logic.Not do
  @moduledoc """
  Documentation for `Rubik.Nodes.Logic.Not`.
  """

  @node_type :executable
  @output :boolean
  @pins [
    %{name: :input, type: :input, data_type: :boolean},
  ]

  use Rubik.Node

  defimpl Rubik.Node.Executable do
    def morph(node), do: node

    def execute(node, args) do
      input = Keyword.fetch!(args, :input)
      result = !input

      result
      |> Rubik.Data.new(:boolean)
      |> Rubik.Result.new(Node.get_pin_address(node, :on_execute))
    end
  end
end
