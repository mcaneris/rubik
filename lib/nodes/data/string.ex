defmodule Rubik.Nodes.Data.String do
  @moduledoc """
  Documentation for `Rubik.Nodes.Data.String`.
  """

  @node_type :data
  @output :string
  @pins [
    %{name: :value, type: :data, data_type: :string}
  ]

  use Rubik.Node

  defimpl Rubik.Node.Executable do
    def morph(node), do: node

    def execute(%{data: %{value: value}} = _node, []) do
      result = Rubik.Data.new(value, :string)

      Rubik.Result.new(result, :none)
    end
  end
end
