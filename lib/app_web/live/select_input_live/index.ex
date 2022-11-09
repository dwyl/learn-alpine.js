defmodule AppWeb.SelectInputLive.Index do
  use AppWeb, :live_view
  alias App.Tasks

  @impl true
  def mount(_params, _session, socket) do
    people = Tasks.list_people()
    {:ok, assign(socket, :people, people)}
  end

  @impl true
  def handle_event("filter-items", %{"key" => _key, "value" => value}, socket) do
    people =
      Tasks.list_people()
      |> Enum.filter(fn p -> String.contains?(String.downcase(p.name), String.downcase(value)) end)

    {:noreply, assign(socket, :people, people)}
  end
end
