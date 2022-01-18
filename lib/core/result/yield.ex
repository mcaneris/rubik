defmodule Rubik.Yield do
  @moduledoc """
  Documentation for `Rubik.Yield`.
  """

  alias Rubik.Address

  @type mapping :: tuple()
  @type results :: list(mapping())
  @type next :: :none | :end | Address.t()
  @type t :: %__MODULE__{
          results: results(),
          next: next()
        }

  defstruct [:results, :next]

  @spec new(results(), next()) :: t()
  def new(results, next) do
    %__MODULE__{results: results, next: next}
  end
end
