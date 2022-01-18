defmodule Rubik.Nodes.List do
  @moduledoc false
  @types {:List, [__MODULE__.Average, __MODULE__.Find, __MODULE__.Join, __MODULE__.Includes, __MODULE__.SortBy, __MODULE__.Sum, __MODULE__.Take]}

  def types(), do: @types
end
