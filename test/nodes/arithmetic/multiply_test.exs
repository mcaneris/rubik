defmodule Rubik.Nodes.Arithmetic.MultiplyTest do
  use ExUnit.Case

  alias Rubik.Data
  alias Rubik.Node
  alias Rubik.Nodes

  doctest Nodes.Arithmetic.Multiply

  test "executes" do
    cases = [
      {Decimal.new("2.0"), Decimal.new("2.0"), Decimal.new("4.0")},
      {"2.0", "2.0", Decimal.new("4.0")},
      {2.0, 2.0, Decimal.new("4.0")},
      {2, 2, Decimal.new("4.0")}
    ]

    for {x1, x2, expected} <- cases do
      %{result: result} =
        Nodes.Arithmetic.Multiply.new()
        |> Node.Executable.execute(x1: x1, x2: x2)

      result = Data.cast(result)

      assert Decimal.eq?(result, expected)
    end
  end
end
