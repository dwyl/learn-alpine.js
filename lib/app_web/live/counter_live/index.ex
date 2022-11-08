defmodule AppWeb.CounterLive.Index do
  use AppWeb, :live_view
  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: PubSub.subscribe(App.PubSub, "counter")
    {:ok, socket}
  end

  @impl true
  def handle_event("update-counter", %{"counter" => counter}, socket) do
    PubSub.broadcast(App.PubSub, "counter", {:counter, counter}) 
    {:noreply, socket}
  end
  
  @impl true
  def handle_info({:counter, counter}, socket) do
   {:noreply, push_event(socket, "update-counter", %{counter: counter})}
  end
end
