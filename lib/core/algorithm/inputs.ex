defmodule Rubik.Algorithm.Inputs do
  @moduledoc """
  Documentation for `Rubik.Algorithm.Inputs`.
  """

  alias Rubik.Address
  alias Rubik.Algorithm
  alias Rubik.Input
  alias Rubik.Node
  alias Rubik.Pin

  @spec add_input(Algorithm.t(), Input.t()) :: Algorithm.t()
  def add_input(%{inputs: inputs} = algorithm, input) do
    start_node = Algorithm.start_node(algorithm)

    name =
      Rubik.Common.String.ensure_string(input.name)
      |> String.downcase()
      |> String.replace(" ", "_")
      |> String.to_atom()

    pin =
      %{name: name, type: :output, data_type: input.type}
      |> Pin.from_definition(start_node.id, input.id)

    start_node = Node.add_pin(start_node, pin)

    algorithm
    |> Map.put(:inputs, inputs ++ [input])
    |> Algorithm.update_node(start_node)
  end

  @spec remove_input(Algorithm.t(), binary()) :: Algorithm.t()
  def remove_input(%{inputs: inputs} = algorithm, input_id) do
    start_node =
      Algorithm.start_node(algorithm)
      |> Node.remove_pin(input_id)

    inputs = Enum.reject(inputs, &(&1.id === input_id))

    algorithm
    |> Map.put(:inputs, inputs)
    |> Algorithm.update_node(start_node)
  end

  def save_inputs(algorithm, inputs) do
    state =
      Algorithm.start_node(algorithm)
      |> Node.output_pins()
      |> Enum.map(&Pin.address/1)
      |> Enum.map(fn address ->
        {Address.pin(address), Algorithm.from_address(algorithm, address)}
      end)
      |> Enum.reduce(algorithm.state, fn {id, targets}, state ->
        targets
        |> Enum.reduce(state, fn target_address, state ->
          Algorithm.State.write(state, target_address, Map.get(inputs, id, nil))
        end)
      end)

    Map.put(algorithm, :state, state)
  end
end
