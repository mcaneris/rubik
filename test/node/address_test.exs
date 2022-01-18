defmodule AddressTest do
  use ExUnit.Case
  alias Rubik.Address
  doctest Address

  setup_all do
    address = Address.generate()
    %{address: address}
  end

  test "encodes an address", %{address: address} do
    assert Address.encode(address) === "#{address.node}::#{address.pin}"
  end

  test "decodes an encoded address", %{address: address} do
    assert Address.decode("#{address.node}::#{address.pin}") === address
  end
end
