defmodule Rubik.Algorithm.Connections do
  @moduledoc """
  Documentation for `Rubik.Algorithm.Connections`.
  """

  alias Rubik.Address
  alias Rubik.Connection

  @spec from_address(list(Connection.t()), Address.t()) :: list(Address.t())
  def from_address(connections, address) do
    connections
    |> Enum.filter(&(&1.from === address))
    |> Enum.map(& &1.to)
  end
end
