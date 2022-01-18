defmodule Rubik.Algorithm.Solver do
  @moduledoc """
  Documentation for `Rubik.Algorithm.Solver`.
  """

  alias Rubik.Algorithm
  alias Rubik.Node
  alias Rubik.Pin
  alias Rubik.Result
  alias Rubik.Yield

  @spec solve(Algorithm.t(), Node.Executable.t()) :: Algorithm.t()
  def solve(algorithm, node) do
    {algorithm, args} =
      Node.input_pins(node)
      |> Enum.map(&{&1.name, Pin.address(&1)})
      |> Enum.reduce({algorithm, Keyword.new()}, fn {name, address}, {algorithm, args} ->
        {algorithm, data} = maybe_get_from_state(algorithm, node, address)
        args = Keyword.put(args, name, data)
        {algorithm, args}
      end)

    solve(algorithm, node, args)
  end

  @spec solve(Algorithm.t(), Node.Executable.t(), list(any())) :: Algorithm.t()
  def solve(algorithm, node, args) do
    case Node.Executable.execute(node, args) do
      %Yield{results: results, next: next} ->
        state = update_with_yield(algorithm, results)

        %{to: to} = Algorithm.find_outgoing(algorithm, next)

        algorithm
        |> Map.put(:state, state)
        |> Algorithm.next(to)

      %Result{result: :none, next: next} when not is_atom(next) ->
        %{to: to} = Algorithm.find_outgoing(algorithm, next)
        Algorithm.next(algorithm, to)

      %Result{result: _result, next: :end} ->
        algorithm
        |> Algorithm.next(:end)

      %Result{result: result, next: :none} ->
        output_address = Node.get_output_address(node)

        state =
          Algorithm.find_all_outgoing(algorithm, output_address)
          |> Enum.reduce(algorithm.state, fn %{to: target_address}, state ->
            Algorithm.State.write(state, target_address, result)
          end)

        Map.put(algorithm, :state, state)

      %Result{result: result, next: next} when not is_atom(next) ->
        output_address = Node.get_output_address(node)

        state =
          Algorithm.find_all_outgoing(algorithm, output_address)
          |> Enum.reduce(algorithm.state, fn %{to: target_address}, state ->
            Algorithm.State.write(state, target_address, result)
          end)

        Map.put(algorithm, :state, state)

        %{to: to} = Algorithm.find_outgoing(algorithm, next)

        algorithm
        |> Map.put(:state, state)
        |> Algorithm.next(to)
    end
  end

  defp update_with_yield(algorithm, results) do
    results
    |> Enum.map(fn {address, value} ->
      targets =
        Algorithm.find_all_outgoing(algorithm, address)
        |> Enum.map(& &1.to)

      {targets, value}
    end)
    |> Enum.reduce(algorithm.state, fn {targets, value}, state ->
      Enum.reduce(targets, state, fn target, state ->
        Algorithm.State.write(state, target, value)
      end)
    end)
  end

  defp maybe_get_from_state(%Algorithm{state: state} = algorithm, call_node, address) do
    case Algorithm.State.read(state, address) do
      :not_found ->
        %{from: from} = Algorithm.find_incoming(algorithm, address)
        node = Algorithm.find_node(algorithm, from)
        algorithm = Algorithm.yield(algorithm, call_node.id)

        solve(algorithm, node)
        |> maybe_get_from_state(call_node, address)

      data ->
        {algorithm, data}
    end
  end
end
