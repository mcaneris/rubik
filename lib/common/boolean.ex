defmodule Rubik.Common.Boolean do
  @moduledoc false
  def ensure_boolean(boolean) when is_boolean(boolean), do: boolean
  def ensure_boolean(nil), do: false
  def ensure_boolean(""), do: false
  def ensure_boolean(string) when is_binary(string), do: true
  def ensure_boolean(0), do: false
  def ensure_boolean(integer) when is_integer(integer), do: true
end
