defmodule Rubik.Data do
  @moduledoc """
  Documentation for `Rubik.Data`.
  """
  require Decimal

  @data_types [:string, :boolean, :decimal, :list, :map, nil]

  @type data_type ::
          unquote(
            @data_types
            |> Enum.map_join(" | ", &inspect/1)
            |> Code.string_to_quoted!()
          )

  @type t :: %__MODULE__{
          value: any(),
          type: data_type()
        }

  defstruct [:type, :value]

  def typeof(a) do
    cond do
      is_float(a) -> :float
      is_number(a) -> :integer
      is_atom(a) -> :atom
      is_boolean(a) -> :boolean
      is_binary(a) -> :string
      is_list(a) -> :list
      is_tuple(a) -> :tuple
      is_map(a) -> :map
    end
  end

  @spec new(any, any) :: t()

  def new(value, :any) do
    new(value, typeof(value))
  end

  def new(value, type) do
    %__MODULE__{value: value, type: type}
  end

  @spec cast(t()) :: any()
  def cast(%__MODULE__{} = data, _), do: data

  def cast(%{type: :decimal, value: value}) do
    Rubik.Common.Decimal.ensure_decimal(value)
  end

  def cast(%{type: :integer, value: value}) when is_integer(value), do: value
  def cast(%{type: :integer, value: value}) when is_binary(value), do: String.to_integer(value)

  def cast(%{type: :list, value: value}), do: value
  def cast(%{type: :map, value: value}), do: value

  def cast(%{type: :any, value: value}) when is_boolean(value),
    do: cast(__MODULE__.new(value, :boolean))

  def cast(%{type: :any, value: value}) when is_binary(value),
    do: cast(__MODULE__.new(value, :string))

  def cast(%{type: :any, value: value}) when Decimal.is_decimal(value),
    do: cast(__MODULE__.new(value, :decimal))

  def cast(%{type: :any, value: value}) when is_boolean(value), do: value
  def cast(%{type: :boolean, value: value}) when is_boolean(value), do: value

  def cast(%{type: :boolean, value: value}) when is_binary(value) do
    case value do
      "true" -> true
      _ -> false
    end
  end

  def cast(%{type: :string, value: value}) when is_binary(value), do: value

  @spec data_types() :: list()
  def data_types() do
    @data_types
  end

  @spec from_spec(map()) :: Node.Executable.t()
  def from_spec(%{"type" => type, "value" => value}) do
    struct(__MODULE__, %{
      type: String.to_atom(type),
      value: value
    })
  end
end
