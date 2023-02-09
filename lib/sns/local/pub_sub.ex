defmodule SNS.Local.PubSub do
  use GenServer

  @max_timeout 30_000

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)

    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def subscribe(name \\ __MODULE__, topic, endpoint) do
    GenServer.call(name, {:subscribe, topic, endpoint})
  end

  def publish(name \\ __MODULE__, topic, message) do
    GenServer.call(name, {:publish, topic, message})
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:subscribe, topic, endpoint}, _from, state) do
    new_state = Map.update(state, topic, [endpoint], &[endpoint | &1])

    {:reply, {:ok, :subscribed}, new_state}
  end

  def handle_call({:publish, topic, message}, _from, state) do
    for endpoint <- Map.get(state, topic, []), do: do_publish(endpoint, message)

    {:reply, {:ok, :published}, state}
  end

  defp do_publish(endpoint, message) do
    json = Jason.encode!(%{"Type" => "Notification", "Message" => message})

    :hackney.post(
      endpoint,
      [{"content-type", "application/json"}],
      json,
      [recv_timeout: @max_timeout]
    )
  end
end
