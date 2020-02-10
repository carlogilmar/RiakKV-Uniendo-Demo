defmodule Civile.Supervisor do
  use Supervisor

  def start_link do
    # riak_core appends _sup to the application name.
    Supervisor.start_link(__MODULE__, [], [name: :civile_sup])
  end

  def init(_args) do
    children = []
    supervise(children, strategy: :one_for_one, max_restarts: 5, max_seconds: 10)
  end

end
