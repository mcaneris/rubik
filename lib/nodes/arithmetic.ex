defmodule Rubik.Nodes.Arithmetic do
  @moduledoc false
  @types {:Arithmetic,
          [__MODULE__.Add, __MODULE__.Subtract, __MODULE__.Multiply, __MODULE__.Divide]}

  def types(), do: @types
end
