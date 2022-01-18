defmodule Rubik.Algorithm do
  @moduledoc """
  Documentation for `Rubik.Algorithm`.
  """

  alias Rubik.Address
  alias Rubik.Algorithm
  alias Rubik.Canvas
  alias Rubik.Connection
  alias Rubik.Input
  alias Rubik.Node
  alias Rubik.Nodes.Flow
  alias Rubik.Output

  @type t :: %__MODULE__{
          nodes: list(Node.Executable.t()),
          connections: list(Connection.t()),
          inputs: list(Input.t()),
          outputs: list(Output.t()),
          state: Algorithm.State.t(),
          canvas: Canvas.State.t()
        }

  defstruct nodes: [],
            connections: [],
            inputs: [],
            outputs: [],
            state: %Algorithm.State{},
            canvas: %Canvas.State{}

  @spec execute(t()) :: any()
  def execute(%__MODULE__{state: %{next: :init}} = algorithm) do
    start_node = start_node(algorithm)
    algorithm = Algorithm.Solver.solve(algorithm, start_node)
    execute(algorithm)
  end

  def execute(%__MODULE__{state: %{next: :end} = state} = algorithm) do
    end_node(algorithm)
    |> Node.input_pins()
    |> Enum.map(&{&1.name, &1.address})
    |> Enum.map(fn {name, address} ->
      {name, Algorithm.State.read(state, address)}
    end)
    |> Enum.reduce(%{}, fn {name, result}, map ->
      Map.put(map, name, result)
    end)
  end

  def execute(%__MODULE__{state: %{next: next}} = algorithm) do
    next_node = find_node(algorithm, next)
    algorithm = Algorithm.Solver.solve(algorithm, next_node)
    execute(algorithm)
  end

  @spec new() :: t()
  def new() do
    %__MODULE__{}
    |> generate_nodes()
  end

  @spec new(map()) :: t()
  def new(map) do
    struct(__MODULE__, map)
    |> generate_nodes()
  end

  @spec from_spec(map()) :: t()
  def from_spec(%{
        "state" => state,
        "inputs" => inputs,
        "outputs" => outputs,
        "nodes" => nodes,
        "canvas" => canvas,
        "connections" => connections
      }) do
    struct(__MODULE__, %{
      state: Rubik.Algorithm.State.from_spec(state),
      canvas: Rubik.Canvas.State.from_spec(canvas),
      nodes: Enum.map(nodes, &Rubik.Node.from_spec/1),
      inputs: Enum.map(inputs, &Rubik.Input.from_spec/1),
      outputs: Enum.map(outputs, &Rubik.Output.from_spec/1),
      connections: Enum.map(connections, &Rubik.Connection.from_spec/1)
    })
  end

  @spec generate_nodes(algorithm :: t()) :: t()
  defp generate_nodes(algorithm) do
    start_node = Flow.Start.new()
    end_node = Flow.End.new()

    algorithm
    |> add_node(start_node, 50, 200)
    |> add_node(end_node, 1050, 200)
  end

  defdelegate add_input(algorithm, input), to: Rubik.Algorithm.Inputs
  defdelegate remove_input(algorithm, input_id), to: Rubik.Algorithm.Inputs
  defdelegate save_inputs(algorithm, inputs), to: Rubik.Algorithm.Inputs

  defdelegate add_output(algorithm, output), to: Rubik.Algorithm.Outputs
  defdelegate remove_output(algorithm, output_id), to: Rubik.Algorithm.Outputs

  def from_address(%__MODULE__{connections: connections}, address),
    do: Rubik.Algorithm.Connections.from_address(connections, address)

  def reset_connections(algorithm) do
    Map.put(algorithm, :connections, [])
  end

  def add_node(%__MODULE__{nodes: nodes} = algorithm, node, x \\ 50, y \\ 50) do
    algorithm
    |> Canvas.State.position(node.id, x, y)
    |> Map.put(:nodes, nodes ++ [node])
  end

  @spec remove_node(t(), Node.Executable.t() | binary()) :: t()
  def remove_node(algorithm, %{id: id}), do: remove_node(algorithm, id)

  def remove_node(%__MODULE__{nodes: nodes, connections: connections} = algorithm, node_id) do
    nodes = Enum.reject(nodes, &(&1.id === node_id))
    connections = Enum.reject(connections, &Connection.of_node?(&1, node_id))

    algorithm
    |> Map.put(:nodes, nodes)
    |> Map.put(:connections, connections)
  end

  def update_node(%{nodes: nodes} = algorithm, node) do
    index = find_node_index(algorithm, node.id)
    nodes = List.update_at(nodes, index, fn _ -> node end)

    Map.put(algorithm, :nodes, nodes)
  end

  @spec find_node(t(), Address.t() | binary()) :: Node.Executable.t()
  def find_node(algorithm, %{node: node}) do
    find_node(algorithm, node)
  end

  def find_node(%{nodes: nodes}, node_id) do
    Enum.find(nodes, fn %{id: id} -> id === node_id end)
  end

  def find_node_index(%{nodes: nodes}, node_id) do
    Enum.find_index(nodes, fn %{id: id} -> id === node_id end)
  end

  def find_node_by_name(%{nodes: nodes}, node_name) do
    Enum.find(nodes, fn %{name: name} -> name === node_name end)
  end

  def node_data(algorithm, node_id, key, value) do
    node =
      find_node(algorithm, node_id)
      |> Node.save(key, value)
      |> Node.Executable.morph()

    update_node(algorithm, node)
  end

  def node_data(algorithm, node_id) do
    find_node(algorithm, node_id)
    |> Map.get(:data)
  end

  def node_data(algorithm, node_id, key) do
    find_node(algorithm, node_id)
    |> Map.get(:data)
    |> Map.get(key)
  end

  def next(%__MODULE__{state: state}), do: Algorithm.State.next(state)

  def next(%__MODULE__{state: state} = algorithm, term),
    do: Map.put(algorithm, :state, Algorithm.State.next(state, term))

  def yield(%__MODULE__{state: state}), do: Algorithm.State.yield(state)

  def yield(%__MODULE__{state: state} = algorithm, yield),
    do: Map.put(algorithm, :state, Algorithm.State.yield(state, yield))

  def start_node(algorithm) do
    find_node_by_name(algorithm, Rubik.Nodes.Flow.Start)
  end

  def end_node(algorithm) do
    find_node_by_name(algorithm, Rubik.Nodes.Flow.End)
  end

  @spec find_incoming(t(), Address.t()) :: Connection.t()
  def find_incoming(%{connections: connections}, address) do
    Enum.find(connections, fn %{to: to} -> to === address end)
  end

  @spec find_outgoing(t(), Address.t()) :: Connection.t()
  def find_outgoing(%{connections: connections}, %Address{} = address) do
    Enum.find(connections, fn %{from: from} -> from === address end)
  end

  @spec find_all_outgoing(t(), Address.t()) :: [Connection.t()]
  def find_all_outgoing(%{connections: connections}, %Address{} = address) do
    Enum.filter(connections, fn %{from: from} -> from === address end)
  end

  @spec add_connection(t(), Connection.t()) :: t()
  def add_connection(%{connections: connections} = algorithm, connection) do
    if Enum.member?(connections, connection) do
      algorithm
    else
      connections = connections ++ [connection]
      Map.put(algorithm, :connections, connections)
    end
  end

  @spec remove_connection(t(), binary() | Address.t()) :: t()
  def remove_connection(algorithm, address) when is_binary(address) do
    remove_connection(algorithm, Address.decode(address))
  end

  def remove_connection(%{connections: connections} = algorithm, address) do
    connections = Enum.reject(connections, &Connection.is_address_in?(&1, address))
    Map.put(algorithm, :connections, connections)
  end

  @spec set_connections(t(), list(Connection.t())) :: t()
  def set_connections(algorithm, connections) do
    Map.put(algorithm, :connections, connections)
  end

  defimpl Jason.Encoder do
    def encode(value, opts) do
      Jason.Encode.map(
        Map.take(value, [:nodes, :inputs, :outputs, :connections, :state, :canvas]),
        opts
      )
    end
  end
end
