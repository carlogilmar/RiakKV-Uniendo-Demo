defmodule Civile do
	use Application
	require Logger

	def start(_type, _args) do
		case Civile.Supervisor.start_link do
			{:ok, pid} ->
				:ok = :riak_core.register(vnode_module: Civile.VNode)
				:ok = :riak_core_node_watcher.service_up(Civile.Service, self())
				{:ok, pid}
			{:error, reason} ->
				Logger.error("Unable to start Civile supervisor because: #{inspect reason}")
		end
	end
end
