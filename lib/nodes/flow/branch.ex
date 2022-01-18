defmodule Rubik.Nodes.Flow.Branch do
  @moduledoc """
  Documentation for `Rubik.Nodes.Flow.Branch`.
  """

  @node_type :executable
  @output :none
  @pins [
    %{name: :condition, type: :input, data_type: :boolean}
  ]
  @execute_pins [
    %{name: :execute, type: :execute},
    %{name: :if_true, type: :on_execute},
    %{name: :if_false, type: :on_execute}
  ]

  use Rubik.Node

  defimpl Rubik.Node.Executable do
    def morph(node), do: node

    def execute(node, args) do
      condition = Keyword.fetch!(args, :condition) |> Rubik.Common.Boolean.ensure_boolean()

      if condition do
        on_execute_address = Rubik.Node.get_pin_address(node, :if_true)
        Rubik.Result.new(:none, on_execute_address)
      else
        on_execute_address = Rubik.Node.get_pin_address(node, :if_false)
        Rubik.Result.new(:none, on_execute_address)
      end
    end
  end
end
