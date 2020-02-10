start_single:
	iex --name dev@127.0.0.1 -S mix run

start_node1:
	MIX_ENV=dev1 iex --name dev1@127.0.0.1 -S mix run

start_node2:
	MIX_ENV=dev2 iex --name dev2@127.0.0.1 -S mix run

start_node3:
	MIX_ENV=dev3 iex --name dev3@127.0.0.1 -S mix run

clean:
	rm -rf data_1 data_2 data_3 data log ring_data_dir*

setup:
	mix deps.get
