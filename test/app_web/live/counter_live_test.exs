defmodule AppWeb.CounterLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Index" do
    test "Display counter", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.counter_index_path(conn, :index))

      assert html =~ "Counter LiveView"
    end
  end
end
