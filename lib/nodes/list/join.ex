defmodule Rubik.Nodes.List.Join do
  @moduledoc """
  Documentation for `Rubik.Nodes.List.Join`.
  """

  @node_type :executable
  @output :string
  @pins [
    %{name: :list, type: :input, data_type: :list},
    %{name: :separator, type: :input, data_type: :string},
    %{name: :string, type: :output, data_type: :decimal}
  ]

  use Rubik.Node

  defimpl Rubik.Node.Executable do
    def morph(node), do: node

    def execute(node, args) do
      separator = Keyword.fetch!(args, :separator)
      list = Keyword.fetch!(args, :list)

      result = Enum.join(list, separator)

      on_execute_address = Rubik.Node.get_on_execute_address(node)

      result
      |> Rubik.Data.new(:string)
      |> Rubik.Result.new(on_execute_address)
    end
  end
end
