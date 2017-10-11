defmodule RedixStage.Worker do
  use GenStage

  @max_demand 100

  def start_link(redis_url, buffers) do
    GenStage.start_link(__MODULE__, {redis_url, buffers})
  end

  def init({redis_url, buffers}) do
    buffer_opts = [max_demand: @max_demand]
    {:ok, conn} = Redix.start_link(redis_url)
    buffers = for buffer <- buffers, do: {buffer, buffer_opts}
    {:consumer, conn, subscribe_to: buffers}
  end

  def handle_events(events, _from, conn) do
    Redix.pipeline(conn, events)
    {:noreply, [], conn}
  end
end
