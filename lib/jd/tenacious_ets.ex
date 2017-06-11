defmodule JD.TenaciousEts do
  use GenServer

  @server __MODULE__
  @registry __MODULE__

  def start do
    GenServer.start(__MODULE__, [], [name: @server])
  end

  def new(name, options) do
    owner = self()
    gift_data = :erlang.make_ref()
    tmp_owner = :erlang.whereis(@server)
    tab = GenServer.call(@server, {:get_ets, tmp_owner, owner, gift_data, name, options})
    receive do
      {:'ETS-TRANSFER', ^tab, ^tmp_owner, ^gift_data} ->
        tab
    end
  end

  def init(_) do
    registry = :ets.new(@registry, [])
    {:ok, registry}
  end

  def handle_call({:get_ets, tmp_owner, owner, gift_data, name, options}, _from, registry) do
    tab = get_or_create_ets(name, options, tmp_owner, registry)
    :ets.give_away(tab, owner, gift_data)
    {:reply, tab, registry}
  end

  def handle_info({:'ETS-TRANSFER', tab, _from_pid, _gift_data}, registry) do
    name = :ets.info(tab, :name)
    :ets.insert(registry, {name, tab})
    {:noreply, registry}
  end

  defp get_or_create_ets(name, options, tmp_owner, registry) do
    case :ets.lookup(registry, name) do
      [] ->
        :ets.new(name, [{:heir, tmp_owner, nil} | options])
      [{name, tab}] ->
        :ets.delete(registry, name)
        tab
    end
  end
end
