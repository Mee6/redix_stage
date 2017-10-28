defmodule RedixStage.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    redis_url          = Application.get_env(:redix_stage, :redis_url, "redis://localhost")
    workers_multiplier = Application.get_env(:redix_stage, :workers_multiplier, 2)
    buffers_num        = RedixStage.buffers_num()
    workers_num        = buffers_num * workers_multiplier

    buffers =
      for i <- 0..buffers_num - 1 do
        worker(RedixStage.Buffer, [i], id: {:buffer, i})
      end

    buffers_names = for i <- 0..buffers_num - 1, do: RedixStage.Buffer.buffer_name(i)

    workers =
      for i <- 0..workers_num - 1 do
        worker(RedixStage.Worker, [redis_url, buffers_names], id: {:worker, i})
      end

    opts = [strategy: :one_for_one, name: RedixStage.Supervisor]
    Supervisor.start_link(buffers ++ workers, opts)
  end
end

