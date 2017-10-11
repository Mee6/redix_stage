defmodule RedixStage do
  def cmd(phrase, cmd) do
    buffer_id = :erlang.phash2(phrase, buffers_num())
    RedixStage.Buffer.push(buffer_id,  cmd)
  end

  def cmd([c | _rest]=cmd) do
    cmd(c, cmd)
  end

  def buffers_num, do: System.schedulers()
end
