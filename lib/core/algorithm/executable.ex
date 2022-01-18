defprotocol Rubik.Algorithm.Executable do
  @moduledoc """
  Documentation for `Rubik.Algorithm.Executable`.
  """
  @spec execute(algorithm :: any()) :: any()
  def execute(algorithm)
end
