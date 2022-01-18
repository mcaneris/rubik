defmodule Rubik.Common do
  @moduledoc """
  `Common` module groups a set of helper modules for `Rubik`.
  """

  alias __MODULE__, as: Module

  @type data :: atom() | boolean() | Decimal.t() | integer() | binary()
  @type type :: :atom | :boolean | :decimal | :integer | :string

  @doc """
  Returns the given data as cast to the given type.

  ## Examples

    iex> Rubik.Common.cast(nil, :boolean)
    false

    iex> Rubik.Common.cast("12", :integer)
    12

    iex> Rubik.Common.cast(12, :string)
    "12"

  """
  @spec cast(data :: data(), type :: type()) :: data()
  def cast(data, :atom), do: Module.Atom.ensure_atom(data)
  def cast(data, :boolean), do: Module.Boolean.ensure_boolean(data)
  def cast(data, :decimal), do: Module.Decimal.ensure_decimal(data)
  def cast(data, :integer), do: Module.Integer.ensure_integer(data)
  def cast(data, :string), do: Module.String.ensure_string(data)
end
