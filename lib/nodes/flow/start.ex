defmodule Rubik.Nodes.Flow.Start do
  @moduledoc """
  Documentation for `Rubik.Nodes.Flow.Start`.
  """

  @node_type :executable
  @output :none
  @execute_pins [
    %{name: :on_execute, type: :on_execute}
  ]
  @pins []

  use Rubik.Node

  defimpl Rubik.Node.Executable do
    def morph(node), do: node

    def execute(node, _args) do
      on_execute_address = Rubik.Node.get_on_execute_address(node)
      Rubik.Result.new(:none, on_execute_address)
    end
  end
end
