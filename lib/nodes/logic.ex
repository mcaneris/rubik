defmodule Rubik.Nodes.Logic do
  @moduledoc false
  @types {:Logic, [__MODULE__.And, __MODULE__.Or, __MODULE__.Not]}

  def types(), do: @types
end
