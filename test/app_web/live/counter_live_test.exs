defmodule AppWeb.CounterLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Index Counter" do
    test "Display counter", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.counter_index_path(conn, :index))

      assert html =~ "Counter LiveView"
    end

    test "handle_event test", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.counter_index_path(conn, :index))
      assert render_hook(view, "update-counter", %{"counter" => 1}) =~ "1"
    end

    test "handle_info test", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.counter_index_path(conn, :index))
      send(view.pid, {:counter, 1})
      assert render(view) =~ "1"
    end
  end
end
