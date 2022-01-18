defmodule AlgorithmTest do
  use ExUnit.Case
  doctest Rubik.Algorithm

  alias Rubik.{Algorithm, Connection, Node, Nodes}

  test "executes with a singular flow" do
    x1_node =
      Nodes.Data.Decimal.new()
      |> Node.save(:value, Decimal.new("20.0"))

    x2_node =
      Nodes.Data.Decimal.new()
      |> Node.save(:value, Decimal.new("10.0"))

    add_node = Nodes.Arithmetic.Add.new()

    output = Rubik.Output.new("Result", :decimal)

    algorithm =
      Algorithm.new(%{
        nodes: [x1_node, x2_node, add_node]
      })
      |> Algorithm.add_output(output)

    start_node = Algorithm.start_node(algorithm)
    end_node = Algorithm.end_node(algorithm)

    connections =
      Connection.bind_many([
        Node.get_on_execute_address(start_node),
        Node.get_execute_address(add_node),
        Node.get_on_execute_address(add_node),
        Node.get_execute_address(end_node),
        Node.get_output_address(x1_node),
        Node.get_pin_address(add_node, :x1),
        Node.get_output_address(x2_node),
        Node.get_pin_address(add_node, :x2),
        Node.get_output_address(add_node),
        Node.get_pin_address(end_node, :result)
      ])

    algorithm = Algorithm.set_connections(algorithm, connections)

    %{result: result} = Rubik.Algorithm.execute(algorithm)

    assert Decimal.eq?(result, Decimal.new("30.0"))
  end

  test "executes with a branching flow" do
    cases = [
      {false, Decimal.new("30.0")},
      {true, Decimal.new("200.0")}
    ]

    x1_node =
      Nodes.Data.Decimal.new()
      |> Node.save(:value, Decimal.new("20.0"))

    x2_node =
      Nodes.Data.Decimal.new()
      |> Node.save(:value, Decimal.new("10.0"))

    condition_node = Nodes.Data.Boolean.new()

    add_node = Nodes.Arithmetic.Add.new()
    multiply_node = Nodes.Arithmetic.Multiply.new()

    branch_node = Nodes.Flow.Branch.new()

    output = Rubik.Output.new("Result", :decimal)

    algorithm =
      Algorithm.new(%{
        nodes: [x1_node, x2_node, condition_node, branch_node, add_node, multiply_node]
      })
      |> Algorithm.add_output(output)

    start_node = Algorithm.start_node(algorithm)
    end_node = Algorithm.end_node(algorithm)

    connections =
      Connection.bind_many([
        Node.get_on_execute_address(start_node),
        Node.get_execute_address(branch_node),
        Node.get_pin_address(branch_node, :if_true),
        Node.get_execute_address(multiply_node),
        Node.get_pin_address(branch_node, :if_false),
        Node.get_execute_address(add_node),
        Node.get_on_execute_address(add_node),
        Node.get_execute_address(end_node),
        Node.get_on_execute_address(multiply_node),
        Node.get_execute_address(end_node),
        Node.get_output_address(condition_node),
        Node.get_pin_address(branch_node, :condition),
        Node.get_output_address(x1_node),
        Node.get_pin_address(add_node, :x1),
        Node.get_output_address(x1_node),
        Node.get_pin_address(multiply_node, :x1),
        Node.get_output_address(x2_node),
        Node.get_pin_address(add_node, :x2),
        Node.get_output_address(x2_node),
        Node.get_pin_address(multiply_node, :x2),
        Node.get_output_address(add_node),
        Node.get_pin_address(end_node, :result),
        Node.get_output_address(multiply_node),
        Node.get_pin_address(end_node, :result)
      ])

    algorithm = Algorithm.set_connections(algorithm, connections)

    for {condition, expected} <- cases do
      algorithm = Algorithm.node_data(algorithm, condition_node.id, :value, condition)
      %{result: result} = Rubik.Algorithm.execute(algorithm)
      assert Decimal.eq?(result, expected)
    end
  end
end
