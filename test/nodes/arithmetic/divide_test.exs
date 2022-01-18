defmodule Rubik.Nodes.Arithmetic.DivideTest do
  use ExUnit.Case

  alias Rubik.Data
  alias Rubik.Node
  alias Rubik.Nodes

  doctest Nodes.Arithmetic.Divide

  test "executes" do
    cases = [
      {Decimal.new("8.0"), Decimal.new("2.0"), Decimal.new("4.0")},
      {"8.0", "2.0", Decimal.new("4.0")},
      {8.0, 2.0, Decimal.new("4.0")},
      {8, 2, Decimal.new("4.0")}
    ]

    for {x1, x2, expected} <- cases do
      %{result: result} =
        Nodes.Arithmetic.Divide.new()
        |> Node.Executable.execute(x1: x1, x2: x2)

      result = Data.cast(result)

      assert Decimal.eq?(result, expected)
    end
  end
end
