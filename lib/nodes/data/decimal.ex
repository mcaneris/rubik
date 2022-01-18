defmodule Rubik.Nodes.Data.Decimal do
  @moduledoc """
  Documentation for `Rubik.Nodes.Data.Decimal`.
  """

  @node_type :data
  @output :decimal
  @pins [
    %{name: :value, type: :data, data_type: :decimal}
  ]

  use Rubik.Node

  defimpl Rubik.Node.Executable do
    def morph(node), do: node

    def execute(%{data: %{value: value}} = _node, _) do
      result = Rubik.Data.new(value, :decimal)
      Rubik.Result.new(result, :none)
    end
  end
end
