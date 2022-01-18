defmodule Rubik.Canvas do
  @moduledoc """
  Documentation for `Rubik.Canvas`.
  """

  defmodule State do
    @moduledoc false

    alias Rubik.{Algorithm, Common}

    defstruct positions: %{}

    @type t :: %__MODULE__{}

    def positions(%Algorithm{canvas: canvas}), do: positions(canvas)
    def positions(%__MODULE__{positions: positions}), do: positions

    def position(%Algorithm{canvas: canvas}, node_id), do: position(canvas, node_id)
    def position(%__MODULE__{positions: positions}, node_id), do: Map.get(positions, node_id, nil)

    def position(%Algorithm{canvas: canvas} = algorithm, node_id, x, y),
      do: Map.put(algorithm, :canvas, position(canvas, node_id, x, y))

    def position(%__MODULE__{positions: positions} = canvas, node_id, x, y),
      do: Map.put(canvas, :positions, position(positions, node_id, x, y))

    def position(positions, node_id, x, y) when is_map(positions),
      do: Map.put(positions, node_id, %{x: x, y: y})

    @spec from_spec(map()) :: t()
    def from_spec(%{"positions" => positions}) do
      positions =
        positions
        |> Map.to_list()
        |> Enum.map(fn {k, v} -> {k, Common.Map.atomize(v)} end)
        |> Map.new()

      struct(__MODULE__, %{positions: positions})
    end

    defimpl Jason.Encoder do
      def encode(value, opts) do
        Jason.Encode.map(Map.take(value, [:positions]), opts)
      end
    end
  end
end
