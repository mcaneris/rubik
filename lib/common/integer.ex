defmodule Rubik.Common.Integer do
  @moduledoc false
  def ensure_integer(integer) when is_integer(integer), do: integer
  def ensure_integer(string) when is_binary(string), do: String.to_integer(string)
end
