defmodule Civile.Service do

  def ping(v \\ 1) do
    IO.puts " === ping 😎 === "
    send_cmd("ping#{v}", {:ping, v})
  end

  def put(k, v) do
    IO.puts " === Service Put === "
    send_cmd(k, {:put, {k, v}})
  end

  def get(k) do
    IO.puts " === Service Get === "
    send_cmd(k, {:get, k})
  end

  defp send_cmd(k, cmd) do
    IO.puts " === Service Send CMD === "
    idx = :riak_core_util.chash_key({"civile", k})
    pref_list = :riak_core_apl.get_primary_apl(idx, 1, Civile.Service)

    [{index_node, _type}] = pref_list

    :riak_core_vnode_master.sync_command(index_node, cmd, Civile.VNode_master)
  end

end
