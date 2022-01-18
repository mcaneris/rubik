defmodule Rubik.Nodes.Data do
  @moduledoc false
  @types {:Data, [__MODULE__.Boolean, __MODULE__.Decimal, __MODULE__.Integer, __MODULE__.String]}

  def types(), do: @types
end
