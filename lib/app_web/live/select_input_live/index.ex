defmodule AppWeb.SelectInputLive.Index do
  use AppWeb, :live_view

  @people ~w(Tom Sam Bob Alex Jim Jo Simon George Rose Rosie Neil Pete AndThisIsAVeryLongNameWhichCantBeDisplayedInOneLine)

  def mount(_params, _session, socket) do
   {:ok, assign(socket, :people, @people)}
  end


end
