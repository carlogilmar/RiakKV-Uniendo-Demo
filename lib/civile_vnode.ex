defmodule Civile.VNode do
  @behaviour :riak_core_vnode

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

  ####################################

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

  def handoff_starting(_dest, state) do
    {true, state}
  end

  def handoff_cancelled(state) do
    {:ok, state}
  end

  def handoff_finished(_dest, state) do
    {:ok, state}
  end

  def handle_handoff_command(_fold_req, _sender, state) do
    {:noreply, state}
  end

  def is_empty(state) do
    {true, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  def delete(state) do
    {:ok, state}
  end

  def handle_handoff_data(_bin_data, state) do
    {:reply, :ok, state}
  end

  def encode_handoff_item(_k, _v) do
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
