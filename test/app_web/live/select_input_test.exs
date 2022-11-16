defmodule AppWeb.SelectInpuLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  alias App.Tasks.Person

  describe "Index" do
    test "Display select input", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.select_input_index_path(conn, :index))

      assert html =~ "Select Input"
    end

    test "handle_event filter-items", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.select_input_index_path(conn, :index))
      assert render_hook(view, "filter-items", %{"key" => "", "value" => "Simon"})
    end

    test "handle_event toggle", %{conn: conn} do
      person = %Person{
        name: "Bob",
        picture: "https://avatars.githubusercontent.com/u/22345430?v=4",
        selected: false
      }

      p = App.Repo.insert!(person)
      {:ok, view, _html} = live(conn, Routes.select_input_index_path(conn, :index))
      assert render_hook(view, "toggle", %{"id" => "#{p.id}"})
    end
  end
end
