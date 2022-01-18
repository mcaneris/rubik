defmodule Rubik.Common.String do
  @moduledoc false
  def ensure_string(t) when is_binary(t), do: t
  def ensure_string(t) when is_atom(t), do: Atom.to_string(t)
  def ensure_string(t), do: "#{t}"

  def to_title(t) when is_binary(t), do: String.capitalize(t)

  def to_title(t) when is_atom(t) do
    Atom.to_string(t)
    |> to_title()
  end
end
