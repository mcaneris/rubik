defmodule Rubik.Nodes.Map.Get do
  @moduledoc """
  Documentation for `Rubik.Nodes.Map.Get`.
  """

  @node_type :executable
  @output :any
  @pins [
    %{name: :map, type: :input, data_type: :list},
    %{name: :path, type: :input, data_type: :string}
  ]

  use Rubik.Node

  defimpl Rubik.Node.Executable do
    def morph(node), do: node

    def execute(node, args) do
      on_execute_address = Rubik.Node.get_on_execute_address(node)

      map = Keyword.fetch!(args, :map)

      path =
        Keyword.fetch!(args, :path)
        |> String.split("/")
        |> Enum.reject(&(&1 === ""))
        |> Enum.map(&String.to_atom/1)

      case path do
        [] ->
          map

        path ->
          Kernel.get_in(map, path)
      end
      |> Rubik.Data.new(:any)
      |> Rubik.Result.new(on_execute_address)
    end
  end
end
