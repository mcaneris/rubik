defmodule Rubik.Common.ID do
  @moduledoc """
  Documentation for `Rubik.Common.ID`.
  """

  @doc """
  Generates an alphanumeric random id.
  """
  @spec generate() :: binary
  def generate() do
    min = String.to_integer("100000", 36)
    max = String.to_integer("ZZZZZZ", 36)

    max
    |> Kernel.-(min)
    |> :rand.uniform()
    |> Kernel.+(min)
    |> Integer.to_string(36)
  end
end
