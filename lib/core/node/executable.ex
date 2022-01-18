defprotocol Rubik.Node.Executable do
  @moduledoc """
  Documentation for `Rubik.Node.Executable`.
  """

  @type args :: list(any())

  @spec morph(t()) :: t()
  def morph(node)

  @spec execute(node :: t(), args :: args()) :: Rubik.Result.t() | Rubik.Yield.t()
  def execute(node, args)
end
