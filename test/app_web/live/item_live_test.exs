defmodule AppWeb.ItemLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.TasksFixtures

  @create_attrs %{"text" => "My Awesome Item"}

  defp create_item(_) do
    item = item_fixture()
    %{item: item}
  end

  describe "Index" do
    setup [:create_item]

    test "lists all items", %{conn: conn, item: item} do
      {:ok, _index_live, html} = live(conn, Routes.item_index_path(conn, :index))

      assert html =~ "Listing Items"
      assert html =~ item.text
    end

    test "saves new item", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      assert index_live |> element("a", "New Item") |> render_click() =~
               "New Item"

      assert_patch(index_live, Routes.item_index_path(conn, :new))

      {:ok, _, html} =
        index_live
        |> form("#item-form", item: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.item_index_path(conn, :index))

      assert html =~ "My Awesome Item"
    end

    test "handle_event highlight", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.item_index_path(conn, :index))
      assert render_hook(view, "highlight", %{"id" => 1})
    end

    test "handle_event remove-hightligh", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.item_index_path(conn, :index))
      assert render_hook(view, "remove-highlight", %{"id" => 1})
    end

    test "handle_event dragoverItem", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.item_index_path(conn, :index))
      assert render_hook(view, "dragoverItem", %{"currentItemId" => 1, "selectedItemId" => 2})
    end

    test "handle_info :item_created", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.item_index_path(conn, :index))
      send(view.pid, {:item_created, %{}})
      assert render(view) =~ "Listing Items"
    end

    test "handle_event updateIndexes", %{conn: conn} do
      {:ok, view, _html} = live(conn, Routes.item_index_path(conn, :index))
      assert render_hook(view, "updateIndexes", %{"ids" => []})
    end
  end
end
