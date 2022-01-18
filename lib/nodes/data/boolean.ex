defmodule Rubik.Nodes.Data.Boolean do
  @moduledoc """
  Documentation for `Rubik.Nodes.Data.Boolean`.
  """

  @node_type :data
  @output :boolean
  @pins [
    %{name: :value, type: :data, data_type: :boolean}
  ]

  use Rubik.Node

  defimpl Rubik.Node.Executable do
    def morph(node), do: node

    def execute(%{data: %{value: value}} = _node, _) do
      result = Rubik.Data.new(value, :boolean)
      Rubik.Result.new(result, :none)
    end
  end
end
