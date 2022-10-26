defmodule AppWeb.ItemLive.Index do
  use AppWeb, :live_view
  alias Phoenix.LiveView.JS
  alias App.Tasks
  alias App.Tasks.Item

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
  def handle_event("close_modal", _, socket) do
    # Go back to the :index live action
    {:noreply, push_patch(socket, to: "/")}
  end

  @impl true
  def handle_event("sort-items", %{"itemIds" => item_ids}, socket) do
    Tasks.update_indexes(item_ids)

    {:noreply, socket}
  end

  @impl true
  def handle_event("highlight-item", %{"itemId" => item_id}, socket) do
    Tasks.item_selected(item_id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove-highlight", %{"itemId" => item_id}, socket) do
    Tasks.item_dropped(item_id)
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "drag-elt",
        %{"idOver" => item_id_over, "idDragged" => item_id_dragged},
        socket
      ) do
    Tasks.drag_and_drop(item_id_over, item_id_dragged)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:item_created, _item}, socket) do
    items = list_items()
    {:noreply, assign(socket, items: items)}
  end

  @impl true
  def handle_info({:item_selected, item_id}, socket) do
    {:noreply, push_event(socket, "highlight", %{id: item_id})}
  end

  @impl true
  def handle_info({:item_dropped, item_id}, socket) do
    {:noreply, push_event(socket, "remove-highlight", %{id: item_id})}
  end

  @impl true
  def handle_info({:drag_and_drop, {item_id_over, item_id_dragged}}, socket) do
    {:noreply,
     push_event(socket, "drag-and-drop", %{
       item_id_over: item_id_over,
       item_id_dragged: item_id_dragged
     })}
  end

  defp list_items do
    Tasks.list_items()
  end
end
