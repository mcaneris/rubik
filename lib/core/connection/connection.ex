defmodule Rubik.Connection do
  @moduledoc """
  Documentation for `Rubik.Connection`.
  """

  alias Rubik.Address

  @type t :: %__MODULE__{}

  defstruct from: nil, to: nil

  @spec is_address_in?(t(), Address.t()) :: boolean()
  def is_address_in?(%__MODULE__{from: from, to: to}, address) do
    Enum.any?([from, to], &(&1 === address))
  end

  @spec of_node?(t(), binary()) :: boolean()
  def of_node?(%__MODULE__{from: from, to: to}, node_id) do
    Enum.any?([from, to], &(Address.node(&1) === node_id))
  end

  @spec bind(t(), Address.t()) :: t()
  def bind(%__MODULE__{from: nil, to: nil}, address) do
    %__MODULE__{from: address}
  end

  def bind(%__MODULE__{from: from, to: nil}, address) do
    %__MODULE__{from: from, to: address}
  end

  @spec bind_many(list(Address.t()), list(t())) :: list(t())
  def bind_many(addresses, connections \\ [])

  def bind_many([], connections) do
    connections
  end

  def bind_many(addresses, connections) when is_list(connections) do
    {[first, second], rest} = Enum.split(addresses, 2)

    connection =
      bind(%__MODULE__{}, first)
      |> bind(second)

    bind_many(rest, connections ++ [connection])
  end

  @spec encoded(t()) :: list()
  def encoded(%__MODULE__{from: from, to: to}) do
    [Address.encode(from), Address.encode(to)]
  end

  @spec reverse(t()) :: Rubik.Connection.t()
  def reverse(%__MODULE__{from: from, to: to}) do
    %__MODULE__{from: to, to: from}
  end

  @spec from(t()) :: Address.t()
  def from(%__MODULE__{from: from}), do: from

  @spec to(t()) :: Address.t()
  def to(%__MODULE__{to: to}), do: to

  @spec from_spec(map()) :: t()
  def from_spec(%{"from" => from, "to" => to}) do
    struct(__MODULE__, %{
      from: Address.from_spec(from),
      to: Address.from_spec(to)
    })
  end

  defimpl Jason.Encoder do
    def encode(value, opts) do
      Jason.Encode.map(Map.take(value, [:from, :to]), opts)
    end
  end
end
