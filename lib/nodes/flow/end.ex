defmodule Rubik.Nodes.Flow.End do
  @moduledoc """
  Documentation for `Rubik.Nodes.Flow.End`.
  """

  @node_type :executable
  @output :none
  @execute_pins [
    %{name: :execute, type: :execute}
  ]
  @pins []

  use Rubik.Node

  defimpl Rubik.Node.Executable do
    def morph(node), do: node

    def execute(_node, _any) do
      Rubik.Result.new(:none, :end)
    end
  end
end
