defmodule Rubik.Nodes do
  @moduledoc """
  Documentation for `Rubik.Nodes` module.
  """

  defmacro __using__(_) do
    quote do
      alias Rubik.Nodes
      alias Nodes.{Arithmetic, Data, Flow, List, Logic, Map}

      @core [Arithmetic, Data, Flow, List, Logic, Map]

      def types() do
        @core
        |> Enum.map(&apply(&1, :types, []))
        |> Enum.concat(@types)
        |> Nodes.insert_or_update_group()
      end
    end
  end

  def insert_or_update_group(types) do
    Enum.reduce(types, [], fn {group, nodes}, list ->
      Enum.find_index(list, fn {existing_group, _} -> existing_group === group end)
      |> case do
        nil ->
          list ++ [{group, nodes}]

        index ->
          update_at(list, nodes, index)
      end
    end)
  end

  def update_at(list, nodes, index) do
    List.update_at(list, index, fn {existing_group, existing_nodes} ->
      {existing_group, existing_nodes ++ nodes}
    end)
  end
end
