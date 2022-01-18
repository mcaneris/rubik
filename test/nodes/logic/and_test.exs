defmodule AndTest do
  use ExUnit.Case

  alias Rubik.Data
  alias Rubik.Node
  alias Rubik.Nodes

  doctest Nodes.Logic.And

  test "executes" do
    cases = [
      {false, false, false},
      {true, false, false},
      {false, true, false},
      {true, true, true}
    ]

    for {left, right, expected} <- cases do
      %{result: result} =
        Nodes.Logic.And.new()
        |> Node.Executable.execute(left: left, right: right)

      result = Data.cast(result)

      assert result === expected
    end
  end
end
