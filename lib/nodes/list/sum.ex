defmodule Rubik.Nodes.List.Sum do
  @moduledoc """
  Documentation for `Rubik.Nodes.List.Sum`.
  """

  @node_type :executable
  @output :none
  @pins [
    %{name: :list, type: :input, data_type: :list},
    %{name: :sum, type: :output, data_type: :decimal}
  ]

  use Rubik.Node
  require Decimal

  defimpl Rubik.Node.Executable do
    def morph(node), do: node

    def execute(node, args) do
      on_execute_address = Rubik.Node.get_on_execute_address(node)

      list =
        Keyword.fetch!(args, :list)
        |> Enum.map(&Rubik.Data.cast/1)

      result =
        case list do
          [decimal] when Decimal.is_decimal(decimal) ->
            Rubik.Data.new(decimal, :decimal)

          [decimal | _tail] when Decimal.is_decimal(decimal) ->
            Enum.reduce(list, Decimal.new("0"), fn decimal, sum ->
              Decimal.add(sum, decimal)
            end)
            |> Rubik.Data.new(:decimal)

          _ ->
            :none
        end

      pairs = [
        {Rubik.Node.get_pin_address(node, :sum), result}
      ]

      Rubik.Yield.new(pairs, on_execute_address)
    end
  end
end
