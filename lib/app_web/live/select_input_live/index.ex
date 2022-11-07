defmodule AppWeb.SelectInputLive.Index do
  use AppWeb, :live_view

  @people ~w(Tom Sam Bob Alex Jim Jo)

  def mount(_params, _session, socket) do
   {:ok, assign(socket, :people, @people)}
  end


end
