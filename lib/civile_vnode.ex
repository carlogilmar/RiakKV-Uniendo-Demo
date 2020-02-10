defmodule Civile.VNode do
	require Logger
	@behaviour :riak_core_vnode

	require Record
	Record.defrecord :fold_req_v2, :riak_core_fold_req_v2, Record.extract(:riak_core_fold_req_v2, from_lib: "riak_core/include/riak_core_vnode.hrl")

	def start_vnode(partition) do
		:riak_core_vnode_master.get_vnode_pid(partition, __MODULE__)
	end

	def init([partition]) do
		table_name = :erlang.list_to_atom('civile_' ++ :erlang.integer_to_list(partition))

		table_id =
			:ets.new(table_name, [:set, {:write_concurrency, false}, {:read_concurrency, false}])

		state = %{
			partition: partition,
			table_name: table_name,
			table_id: table_id
		}

		{:ok, state}
	end

	def handle_command({:ping, v}, _sender, state = %{partition: partition}) do
		{:reply, {:pong, v + 1, node(), partition}, state}
	end

	def handle_command({:put, {k, v}}, _sender, state = %{table_id: table_id, partition: partition}) do
		:ets.insert(table_id, {k, v})
		res = {:ok, node(), partition, nil}
		{:reply, res, state}
	end

	def handle_command({:get, k}, _sender, state = %{table_id: table_id, partition: partition}) do
		res =
			case :ets.lookup(table_id, k) do
				[] ->
					{:ok, node(), partition, nil}

				[{_, value}] ->
					{:ok, node(), partition, value}
			end

		{:reply, res, state}
	end

	def handoff_starting(_dest, state = %{partition: partition}) do
		Logger.debug "handoff_starting #{partition}"
		{true, state}
	end

	def handoff_cancelled(state = %{partition: partition}) do
		Logger.debug "handoff_cancelled #{partition}"
		{:ok, state}
	end

	def handoff_finished(_dest, state = %{partition: partition}) do
		Logger.debug "handoff_finished #{partition}"
		{:ok, state}
	end

	def handle_handoff_command(fold_req_v2() = fold_req, _sender, state = %{table_id: table_id, partition: partition}) do
		Logger.debug "handoff #{partition}"
		foldfun = fold_req_v2(fold_req, :foldfun)
		acc0 = fold_req_v2(fold_req, :acc0)
		acc_final = :ets.foldl(fn {k, v}, acc_in ->
			Logger.debug "handoff #{partition}: #{k} #{v}"
			foldfun.(k, v, acc_in)
		end, acc0, table_id)
		{:reply, acc_final, state}
	end

	def handle_handoff_command(_request, _sender, state = %{partition: partition}) do
		Logger.debug "Handoff generic request, ignoring #{partition}"
		{:noreply, state}
	end

	def is_empty(state = %{table_id: table_id, partition: partition}) do
		is_empty = (:ets.first(table_id) == :"$end_of_table")
		Logger.debug "is_empty #{partition}: #{is_empty}"
		{is_empty, state}
	end

	def terminate(reason, %{partition: partition}) do
		Logger.debug "terminate #{partition}: #{reason}"
		:ok
	end

	def delete(state = %{table_id: table_id, partition: partition}) do
		Logger.debug "delete #{partition}"
		true = :ets.delete(table_id)
		{:ok, state}
	end

	def handle_handoff_data(bin_data, state = %{table_id: table_id, partition: partition}) do
		{k, v} = :erlang.binary_to_term(bin_data)
		:ets.insert(table_id, {k, v})
		Logger.debug "handle_handoff_data #{partition}: #{k} #{v}"
		{:reply, :ok, state}
	end

	def encode_handoff_item(k, v) do
		Logger.debug "encode_handoff_item #{k} #{v}"
		:erlang.term_to_binary({k, v})
	end

	def handle_coverage(_req, _key_spaces, _sender, state) do
		{:stop, :not_implemented, state}
	end

	def handle_exit(_pid, _reason, state) do
		{:noreply, state}
	end

	def handle_overload_command(_, _, _) do
		:ok
	end

	def handle_overload_info(_, _idx) do
		:ok
	end
end
