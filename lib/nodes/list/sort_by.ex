defmodule Rubik.Nodes.List.SortBy do
  @moduledoc """
  Documentation for `Rubik.Nodes.List.SortBy`.
  """

  @node_type :executable
  @output :list
  @pins [
    %{name: :list, type: :input, data_type: :list},
    %{name: :key, type: :input, data_type: :string},
    %{
      name: :value_type,
      type: :data,
      data_type: :enum,
      options: {__MODULE__, :value_type_options, []}
    },
    %{name: :sort_order, type: :data, data_type: :enum, options: {__MODULE__, :order_options, []}}
  ]

  use Rubik.Node

  def order_options() do
    [{"Ascending", "asc"}, {"Descending", "desc"}]
  end

  def value_type_options() do
    [{"String", "string"}, {"Integer", "integer"}, {"Decimal", "decimal"}]
  end

  defimpl Rubik.Node.Executable do
    def morph(node), do: node

    def execute(%{data: %{value_type: value_type, sort_order: sort_order}} = node, args) do
      list = Keyword.fetch!(args, :list)
      key = Keyword.fetch!(args, :key)

      result =
        Enum.sort_by(
          list,
          fn item ->
            Rubik.Data.cast(%{
              type: Rubik.Common.Atom.ensure_atom(value_type),
              value: Map.get(item, String.to_atom(key))
            })
          end,
          Rubik.Common.Atom.ensure_atom(sort_order)
        )

      on_execute_address = Rubik.Node.get_on_execute_address(node)

      result
      |> Rubik.Data.new(:list)
      |> Rubik.Result.new(on_execute_address)
    end
  end
end
