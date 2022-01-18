defmodule Rubik.Common.Map do
  @moduledoc """
  Documentation for `Rubik.Common.Map`.
  """

  @spec atomize(map :: map()) :: map()
  def atomize(map) do
    Map.new(map, fn {k, v} -> {String.to_existing_atom(k), v} end)
  end
end
