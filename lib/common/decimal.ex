defmodule Rubik.Common.Decimal do
  @moduledoc """
  Documentation for `Rubik.Common.Decimal`.
  """

  require Decimal

  @spec ensure_decimal(Decimal.t() | binary | number | map) :: Decimal.t()
  def ensure_decimal(value) when Decimal.is_decimal(value), do: value
  def ensure_decimal(value) when is_binary(value) or is_integer(value), do: Decimal.new(value)
  def ensure_decimal(value) when is_float(value), do: Decimal.from_float(value)
end
