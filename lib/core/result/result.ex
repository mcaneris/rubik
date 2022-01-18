defmodule Rubik.Result do
  @moduledoc """
  Documentation for `Rubik.Result`.
  """

  alias Rubik.Address
  alias Rubik.Data

  @type t :: %__MODULE__{
          result: :none | Data.t(),
          next: :none | :end | Address.t()
        }

  defstruct result: :none, next: :none

  @spec new(:none | Data.t(), :none | :end | Address.t()) :: t()
  def new(result, next) do
    %__MODULE__{result: result, next: next}
  end
end
