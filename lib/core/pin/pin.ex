defmodule Rubik.Pin do
  @moduledoc """
  Definition for `Rubik.Pin`.
  """

  alias Rubik.Address

  @type pin_type :: :input | :output | :data
  @type t :: %__MODULE__{
          name: binary(),
          address: Address.t(),
          type: pin_type(),
          data_type: atom(),
          dynamic: boolean(),
          options: tuple() | mfa()
        }

  defstruct [:name, :address, :type, :data_type, :dynamic, :options]

  def from_definition(%{name: name, type: type} = map, node_id) do
    data_type = Map.get(map, :data_type, :none)
    options = Map.get(map, :options, {})
    dynamic = Map.get(map, :dynamic, false)

    %__MODULE__{
      name: name,
      type: type,
      data_type: data_type,
      address: Address.generate(node_id),
      dynamic: dynamic,
      options: options
    }
  end

  def from_definition(%{name: name, type: type} = map, node_id, pin_id) do
    data_type = Map.get(map, :data_type, :none)
    options = Map.get(map, :options, {})
    dynamic = Map.get(map, :dynamic, false)

    %__MODULE__{
      name: name,
      type: type,
      data_type: data_type,
      address: %Address{node: node_id, pin: pin_id},
      options: options,
      dynamic: dynamic
    }
  end

  def address(%__MODULE__{address: address}), do: address

  def is_of_type?(%__MODULE__{type: pin_type}, type), do: pin_type === type
  def is_input_pin?(%__MODULE__{type: type}), do: type === :input
  def is_data_pin?(%__MODULE__{type: type}), do: type === :data
  def is_output_pin?(%__MODULE__{type: type}), do: type === :output
  def is_execute_pin?(%__MODULE__{type: type}), do: type === :execute
  def is_on_execute_pin?(%__MODULE__{type: type}), do: type === :on_execute

  @spec from_spec(map()) :: t()
  def from_spec(%{
        "address" => address,
        "name" => name,
        "type" => type,
        "data_type" => data_type,
        "dynamic" => dynamic,
        "options" => options
      }) do
    struct(__MODULE__, %{
      address: Address.from_spec(address),
      name: String.to_atom(name),
      type: String.to_atom(type),
      data_type: String.to_atom(data_type),
      dynamic: dynamic,
      options: List.to_tuple(options)
    })
  end

  defimpl Jason.Encoder do
    def encode(value, opts) do
      map = Map.take(value, [:name, :address, :type, :data_type, :dynamic, :options])
      options = Map.get(value, :options, {}) |> Tuple.to_list()
      map = Map.put(map, :options, options)
      Jason.Encode.map(map, opts)
    end
  end
end
