defmodule Rubik.IO do
  @moduledoc """
  Documentation for `Rubik.IO`.
  """

  @base_data_types [
    :boolean,
    :decimal,
    :integer,
    :list,
    :map,
    :string
  ]

  @date_data_types [
    :day,
    :month,
    :year
  ]

  @time_data_types [
    :hour,
    :time
  ]

  @data_types @base_data_types ++ @date_data_types ++ @time_data_types

  @type data_type ::
          unquote(
            @data_types
            |> Enum.map_join(" | ", &Kernel.inspect/1)
            |> Code.string_to_quoted!()
          )

  @callback new(binary(), data_type()) :: any()
  @callback data_types() :: list(data_type())

  defmacro __using__(_) do
    quote do
      @behaviour Rubik.IO
      Module.put_attribute(__MODULE__, :data_types, unquote(@data_types))
      Module.put_attribute(__MODULE__, :base_data_types, unquote(@base_data_types))
      Module.put_attribute(__MODULE__, :date_data_types, unquote(@date_data_types))
      Module.put_attribute(__MODULE__, :time_data_types, unquote(@time_data_types))

      @type t :: %__MODULE__{
              id: binary(),
              name: binary(),
              type: Rubik.IO.data_type()
            }

      defstruct [:id, :name, :type]

      @spec new(binary(), Rubik.IO.data_type()) :: t()
      def new(name, type) do
        id = Rubik.Common.ID.generate()
        type = Rubik.Common.Atom.ensure_atom(type)

        name =
          Rubik.Common.String.ensure_string(name)
          |> String.downcase()
          |> String.replace(" ", "_")
          |> String.to_atom()

        %__MODULE__{id: id, name: name, type: type}
      end

      @spec data_types() :: list(Rubik.IO.data_type())
      def data_types(), do: @data_types

      @spec grouped_data_types() :: list()
      def grouped_data_types() do
        [
          Base: @base_data_types,
          Date: @date_data_types,
          Time: @time_data_types
        ]
      end

      def from_spec(%{"id" => id, "name" => name, "type" => type}) do
        %__MODULE__{id: id, name: name, type: String.to_atom(type)}
      end

      defimpl Jason.Encoder do
        def encode(value, opts) do
          Jason.Encode.map(Map.take(value, [:id, :name, :type]), opts)
        end
      end
    end
  end
end
