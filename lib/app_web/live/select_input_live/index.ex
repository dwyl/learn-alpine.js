defmodule AppWeb.SelectInputLive.Index do
  use AppWeb, :live_view
  alias App.Tasks

  def mount(_params, _session, socket) do
    people = Tasks.list_people()
    {:ok, assign(socket, :people, people)}
  end
end
