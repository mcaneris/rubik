defmodule Rubik.Common.Atom do
  @moduledoc false
  def ensure_atom(atom) when is_atom(atom), do: atom
  def ensure_atom(string) when is_binary(string), do: String.to_atom(string)

  def to_title(atom) do
    atom
    |> Atom.to_string()
    |> Rubik.Common.String.to_title()
  end
end
