defmodule Rubik.Algorithm.State do
  @moduledoc """
  Documentation for `Rubik.Algorithm.State`.
  """

  alias Rubik.Address
  alias Rubik.Data

  @type next :: Address.t() | :init | :end
  @type yield :: list(binary())
  @type t :: %__MODULE__{
          yield: yield(),
          next: next(),
          results: %{binary() => Data.t()}
        }

  defstruct results: %{}, next: :init, yield: []

  @spec next(t()) :: next()
  def next(%__MODULE__{next: next}), do: next

  @spec next(t(), next()) :: t()
  def next(%__MODULE__{} = state, term), do: Map.put(state, :next, term)

  @spec yield(t()) :: yield()
  def yield(%__MODULE__{yield: yield}), do: yield

  @spec yield(t(), binary()) :: t()
  def yield(%__MODULE__{yield: yield} = state, id),
    do: Map.put(state, :yield, yield ++ [id])

  @spec read(t(), Address.t()) :: :not_found | Data.t()
  def read(%__MODULE__{results: results}, address) do
    case Map.get(results, Address.encode(address), :not_found) do
      %Data{} = data ->
        Data.cast(data)

      any ->
        any
    end
  end

  @spec write(t(), Address.t(), Data.t()) :: t()
  def write(%__MODULE__{results: results} = state, address, value) do
    results = Map.put(results, Address.encode(address), value)
    Map.put(state, :results, results)
  end

  @spec from_spec(map()) :: t()
  def from_spec(%{"results" => results, "next" => next}) do
    struct(__MODULE__, %{
      results: results,
      next: String.to_atom(next)
    })
  end

  defimpl Jason.Encoder do
    def encode(value, opts) do
      Jason.Encode.map(Map.take(value, [:results, :next]), opts)
    end
  end
end
