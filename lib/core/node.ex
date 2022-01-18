defmodule Rubik.Node do
  @moduledoc """
  Documentation for `Rubik.Node`.
  """
  alias Rubik.{Address, Common, Node, Pin}

  @callback new() :: Node.Executable.t()

  defmacro __using__(_) do
    quote do
      type = Module.get_attribute(__MODULE__, :node_type, :executable)
      output = Module.get_attribute(__MODULE__, :output, :any)

      if is_nil(Module.get_attribute(__MODULE__, :execute_pins)) do
        Module.put_attribute(__MODULE__, :execute_pins, [
          %{name: :execute, type: :execute},
          %{name: :on_execute, type: :on_execute}
        ])
      end

      @behaviour Rubik.Node
      alias Rubik.{Address, Common, Node, Pin}

      defstruct id: nil,
                name: __MODULE__,
                type: type,
                output: output,
                pins: [],
                data: %{}

      @type t :: %__MODULE__{}

      @spec new() :: t()
      def new() do
        id = Common.ID.generate()

        struct(__MODULE__, %{id: id})
        |> generate_pins()
        |> generate_data()
      end

      def generate_pins(%{id: id, name: name, type: type, output: output} = node) do
        pins = if is_nil(@pins), do: [], else: @pins

        pins =
          pins
          |> Enum.map(&Pin.from_definition(&1, id))
          |> Enum.concat(generate_execute_pins(id, type))
          |> Enum.concat([generate_output_pin(id, output)])
          |> Enum.reject(&is_nil/1)

        Map.put(node, :pins, pins)
      end

      def generate_execute_pins(id, :executable) do
        @execute_pins
        |> Enum.map(&Pin.from_definition(&1, id))
      end

      def generate_execute_pins(_id, _type), do: []

      def generate_output_pin(id, :none), do: nil

      def generate_output_pin(id, type, name \\ :output) do
        %{name: name, type: :output, data_type: type}
        |> Pin.from_definition(id)
      end

      def generate_data(%{pins: pins} = node) do
        data = Rubik.Node.reset(pins)
        Map.put(node, :data, data)
      end

      defimpl Jason.Encoder do
        def encode(value, opts) do
          Jason.Encode.map(Map.take(value, [:id, :name, :data, :pins, :type, :output]), opts)
        end
      end
    end
  end

  @spec from_spec(map()) :: Node.Executable.t()
  def from_spec(%{
        "id" => id,
        "name" => name,
        "type" => type,
        "output" => output,
        "data" => data,
        "pins" => pins
      }) do
    struct(String.to_existing_atom(name), %{
      id: id,
      name: String.to_atom(name),
      type: String.to_atom(type),
      output: String.to_atom(output),
      data: Rubik.Common.Map.atomize(data),
      pins: Enum.map(pins, &Rubik.Pin.from_spec/1)
    })
  end

  @spec to_spec(Node.Executable.t()) :: map
  def to_spec(node) do
    Map.from_struct(node)
  end

  @spec is_executable(any()) :: boolean()
  def is_executable(%{data: data}) do
    data
    |> Map.to_list()
    |> Enum.all?(fn {_, value} -> !is_nil(value) end)
  end

  @spec save(Node.Executable.t(), atom(), any()) :: Node.Executable.t()
  def save(%{data: data} = node, variable, value) do
    variable = Common.Atom.ensure_atom(variable)
    data = Map.put(data, variable, value)
    Map.put(node, :data, data)
  end

  @spec read(any(), atom(), any()) :: any()
  def read(%{data: data}, variable, default \\ nil) do
    Map.get(data, variable, default)
  end

  @spec reset(list(map() | Pin.t())) :: map()
  def reset(pins) when is_list(pins) do
    pins
    |> Enum.filter(&Pin.is_data_pin?/1)
    |> Enum.reduce(%{}, &Map.put(&2, Map.get(&1, :name), nil))
  end

  @spec add_pin(Node.Executable.t(), Pin.t()) :: Node.Executable.t()
  def add_pin(%{pins: pins} = node, pin) do
    pins = pins ++ [pin]
    Map.put(node, :pins, pins)
  end

  @spec remove_pin(Node.Executable.t(), binary()) :: Node.Executable.t()
  def remove_pin(%{pins: pins} = node, pin_id) do
    pins = Enum.reject(pins, &(Address.pin(&1.address) === pin_id))
    Map.put(node, :pins, pins)
  end

  @spec remove_named_pin(Node.Executable.t(), binary()) :: Node.Executable.t()
  def remove_named_pin(%{pins: pins} = node, pin_name) do
    pins = Enum.reject(pins, &(&1.name === pin_name))
    Map.put(node, :pins, pins)
  end

  @spec data_pins(Node.Executable.t()) :: list(Pin.t())
  def data_pins(%{pins: pins}) do
    Enum.filter(pins, &(&1.type === :data))
  end

  @spec input_pins(Node.Executable.t()) :: list(Pin.t())
  def input_pins(%{pins: pins}) do
    Enum.filter(pins, &(&1.type === :input))
  end

  @spec output_pins(Node.Executable.t()) :: list(Pin.t())
  def output_pins(%{pins: pins}) do
    Enum.filter(pins, &(&1.type === :output))
  end

  @spec execute_pins(Node.Executable.t()) :: list(Pin.t())
  def execute_pins(%{pins: pins}) do
    Enum.filter(pins, &(&1.type === :execute))
  end

  @spec on_execute_pins(Node.Executable.t()) :: list(Pin.t())
  def on_execute_pins(%{pins: pins}) do
    Enum.filter(pins, &(&1.type === :on_execute))
  end

  @spec get_pin(Node.Executable.t(), atom()) :: Pin.t()
  def get_pin(%{pins: pins}, pin_name) do
    Enum.find(pins, fn %{name: name} -> name === pin_name end)
  end

  @spec get_pin_address(Node.Executable.t(), atom()) :: Address.t()
  def get_pin_address(node, name) do
    get_pin(node, name)
    |> Pin.address()
  end

  @spec get_execute_pin(Node.Executable.t()) :: Pin.t()
  def get_execute_pin(%{pins: pins}) do
    Enum.find(pins, fn %{name: name} -> name === :execute end)
  end

  @spec get_on_execute_pin(Node.Executable.t()) :: Pin.t()
  def get_on_execute_pin(%{pins: pins}) do
    Enum.find(pins, fn %{name: name} -> name === :on_execute end)
  end

  @spec get_output_pin(Node.Executable.t()) :: Pin.t()
  def get_output_pin(%{pins: pins}) do
    Enum.find(pins, fn %{name: name} -> name === :output end)
  end

  @spec get_output_pin_by_name(Node.Executable.t(), atom()) :: Pin.t()
  def get_output_pin_by_name(%{pins: pins}, name) do
    Enum.find(pins, fn %{type: type, name: pin_name} -> type === :output && name === pin_name end)
  end

  @spec get_execute_address(Node.Executable.t()) :: Address.t()
  def get_execute_address(node) do
    get_execute_pin(node)
    |> Pin.address()
  end

  @spec get_on_execute_address(Node.Executable.t()) :: Address.t()
  def get_on_execute_address(node) do
    get_on_execute_pin(node)
    |> Pin.address()
  end

  @spec get_output_address(Node.Executable.t()) :: Address.t()
  def get_output_address(node) do
    get_output_pin(node)
    |> Pin.address()
  end

  @spec is_data_node?(Node.Executable.t()) :: boolean()
  def is_data_node?(%{type: type}), do: type === :data
end
