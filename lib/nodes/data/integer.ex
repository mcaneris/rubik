defmodule Rubik.Nodes.Data.Integer do
  @moduledoc """
  Documentation for `Rubik.Nodes.Data.Integer`.
  """

  @node_type :data
  @output :integer
  @pins [
    %{name: :value, type: :data, data_type: :integer}
  ]

  use Rubik.Node

  defimpl Rubik.Node.Executable do
    def morph(node), do: node

    def execute(%{data: %{value: value}} = _node, _) do
      Rubik.Data.new(value, :integer)
      |> Rubik.Result.new(:none)
    end
  end
end
