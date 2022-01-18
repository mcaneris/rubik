defmodule Rubik.Algorithm.Outputs do
  @moduledoc """
  Documentation for `Rubik.Algorithm.Outputs`.
  """

  alias Rubik.Algorithm
  alias Rubik.Output
  alias Rubik.Node
  alias Rubik.Pin

  @spec add_output(Algorithm.t(), Output.t()) :: Algorithm.t()
  def add_output(%{outputs: outputs} = algorithm, output) do
    end_node = Algorithm.end_node(algorithm)

    name =
      Rubik.Common.String.ensure_string(output.name)
      |> String.downcase()
      |> String.replace(" ", "_")
      |> String.to_atom()

    pin =
      %{name: name, type: :input, data_type: output.type}
      |> Pin.from_definition(end_node.id, output.id)

    end_node = Node.add_pin(end_node, pin)

    algorithm
    |> Map.put(:outputs, outputs ++ [output])
    |> Algorithm.update_node(end_node)
  end

  @spec remove_output(Algorithm.t(), binary()) :: Algorithm.t()
  def remove_output(%{outputs: outputs} = algorithm, output_id) do
    end_node =
      Algorithm.end_node(algorithm)
      |> Node.remove_pin(output_id)

    outputs = Enum.reject(outputs, &(&1.id === output_id))

    algorithm
    |> Map.put(:outputs, outputs)
    |> Algorithm.update_node(end_node)
  end
end
