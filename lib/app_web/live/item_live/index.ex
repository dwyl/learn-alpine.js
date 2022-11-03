defmodule AppWeb.ItemLive.Index do
  use AppWeb, :live_view

  alias App.Tasks
  alias App.Tasks.Item
  alias Phoenix.LiveView.JS

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Tasks.subscribe()
    {:ok, assign(socket, :items, list_items())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Item")
    |> assign(:item, Tasks.get_item!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Item")
    |> assign(:item, %Item{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Items")
    |> assign(:item, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    item = Tasks.get_item!(id)
    {:ok, _} = Tasks.delete_item(item)

    {:noreply, assign(socket, :items, list_items())}
  end

  @impl true
  def handle_event("highlight", %{"id" => id}, socket) do
    Tasks.drag_item(id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove-highlight", %{"id" => id}, socket) do
    Tasks.drop_item(id)
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "dragoverItem",
        %{"currentItemId" => current_item_id, "selectedItemId" => selected_item_id},
        socket
      ) do
    Tasks.dragover_item(current_item_id, selected_item_id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("updateIndexes", %{"ids" => ids}, socket) do
    Tasks.update_items_index(ids)
    {:noreply, socket}
  end

  @impl true
  def handle_info(:indexes_updated, socket) do
    items = list_items()
    {:noreply, assign(socket, items: items)}
  end

  @impl true
  def handle_info({:dragover_item, {current_item_id, selected_item_id}}, socket) do
    {:noreply,
     push_event(socket, "dragover-item", %{
       current_item_id: current_item_id,
       selected_item_id: selected_item_id
     })}
  end

  @impl true
  def handle_info({:item_created, _item}, socket) do
    items = list_items()
    {:noreply, assign(socket, items: items)}
  end

  @impl true
  def handle_info({:drag_item, item_id}, socket) do
    {:noreply, push_event(socket, "highlight", %{id: item_id})}
  end

  @impl true
  def handle_info({:drop_item, item_id}, socket) do
    {:noreply, push_event(socket, "remove-highlight", %{id: item_id})}
  end

  defp list_items do
    Tasks.list_items()
  end
end
