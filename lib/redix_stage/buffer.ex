defmodule RedixStage.Buffer do
  use GenStage

  @max_buffers 128
  for idx <- 0..(@max_buffers-1) do
    def buffer_name(unquote(idx)) do
      unquote(:"redix_stage_buffer_#{idx}")
    end
  end

  def start_link(id) do
    GenStage.start_link(__MODULE__, :ok, name: buffer_name(id))
  end

  def init(:ok) do
    {:producer, {:queue.new(), 0}}
  end

  def push(buffer, cmd) when is_pid(buffer) or is_atom(buffer) do
    GenStage.cast(buffer, {:push, cmd})
  end
  def push(buffer_id, cmd) do
    push(buffer_name(buffer_id), cmd)
  end

  def handle_cast({:push, cmd}, {queue, demand}) do
    queue = :queue.in(cmd, queue)
    dispatch(queue, demand, [])
  end

  def handle_demand(incoming, {queue, pending}) do
    dispatch(queue, incoming + pending, [])
  end

  def dispatch(queue, 0, events) do
    {:noreply, Enum.reverse(events), {queue, 0}}
  end
  def dispatch(queue, demand, events) do
    case :queue.out(queue) do
      {{:value, event}, queue} ->
        dispatch(queue, demand - 1, [event | events])
      {:empty, queue} ->
        {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end
end
