defmodule BranchTest do
  use ExUnit.Case

  alias Rubik.Node
  alias Rubik.Nodes

  doctest Nodes.Flow.Branch

  test "executes" do
    cases = [
      true,
      false
    ]

    for {condition} <- cases do
      node = Nodes.Flow.Branch.new()

      expected_next =
        if condition === false,
          do: Node.get_pin_address(node, :on_false),
          else: Node.get_pin_address(node, :on_true)

      %{result: result, next: next} = Node.Executable.execute(node, condition: condition)

      assert result === :none
      assert next === expected_next
    end
  end
end
