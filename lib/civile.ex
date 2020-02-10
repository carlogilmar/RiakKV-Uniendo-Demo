defmodule Civile do
  use Application
  require Logger

  def start(_type, _args) do
    case Civile.Supervisor.start_link do
      {:ok, pid} ->
        {:ok, pid}
      {:error, reason} ->
        Logger.error("Unable to start Civile supervisor because: #{inspect reason}")
    end
  end
end
