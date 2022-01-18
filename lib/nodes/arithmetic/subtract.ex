defmodule Rubik.Nodes.Arithmetic.Subtract do
  @moduledoc """
  Documentation for `Rubik.Nodes.Arithmetic.Subtract`.
  """

  @node_type :executable
  @output :decimal
  @pins [
    %{name: :x1, type: :input, data_type: :decimal},
    %{name: :x2, type: :input, data_type: :decimal}
  ]

  use Rubik.Node

  defimpl Rubik.Node.Executable do
    def morph(node), do: node

    def execute(node, args) do
      x1 = Keyword.fetch!(args, :x1) |> Rubik.Common.Decimal.ensure_decimal()
      x2 = Keyword.fetch!(args, :x2) |> Rubik.Common.Decimal.ensure_decimal()

      on_execute_address = Rubik.Node.get_on_execute_address(node)

      Decimal.sub(x1, x2)
      |> Rubik.Data.new(:decimal)
      |> Rubik.Result.new(on_execute_address)
    end
  end
end
