defmodule Rubik.Address do
  @moduledoc """
  Documentation for `Rubik.Address`
  """

  defstruct [:node, :pin]
  @type t :: %__MODULE__{}

  @spec node(t()) :: binary()
  def node(%__MODULE__{node: node}), do: node

  @spec pin(t()) :: binary()
  def pin(%__MODULE__{pin: pin}), do: pin

  @doc """
  Decodes a binary representation of an `Rubik.Address`.
  """
  @spec decode(binary) :: t()
  def decode(binary) do
    [node, pin] = String.split(binary, "::", trim: true)
    %__MODULE__{node: node, pin: pin}
  end

  @doc """
  Encodes a `Rubik.Address` as a binary of form of `node::pin`.
  """
  @spec encode(t()) :: <<_::16, _::_*8>>
  def encode(%__MODULE__{node: node, pin: pin}) do
    node <> "::" <> pin
  end

  @doc """
  Generates a `Rubik.Address`.
  """
  @spec generate :: t()
  def generate() do
    %__MODULE__{node: Rubik.Common.ID.generate(), pin: Rubik.Common.ID.generate()}
  end

  @doc """
  Generates a `Rubik.Address` for a given node.
  """
  @spec generate(struct()) :: t()
  def generate(%{id: id} = node) when is_struct(node) do
    %__MODULE__{node: id, pin: Rubik.Common.ID.generate()}
  end

  @spec generate(binary) :: t()
  def generate(node) when is_binary(node) do
    %__MODULE__{node: node, pin: Rubik.Common.ID.generate()}
  end

  @spec from_spec(map()) :: t()
  def from_spec(%{"node" => node, "pin" => pin}) do
    struct(__MODULE__, %{
      node: node,
      pin: pin
    })
  end

  defimpl Jason.Encoder do
    def encode(value, opts) do
      Jason.Encode.map(Map.take(value, [:node, :pin]), opts)
    end
  end
end
