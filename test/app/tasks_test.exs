defmodule App.TasksTest do
  use App.DataCase

  alias App.Tasks

  describe "items" do
    alias App.Tasks.Item

    import App.TasksFixtures

    @invalid_attrs %{index: nil, text: nil}

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Tasks.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Tasks.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      valid_attrs = %{index: 42, text: "some text"}

      assert {:ok, %Item{} = item} = Tasks.create_item(valid_attrs)
      assert item.index == 42
      assert item.text == "some text"
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      update_attrs = %{index: 43, text: "some updated text"}

      assert {:ok, %Item{} = item} = Tasks.update_item(item, update_attrs)
      assert item.index == 43
      assert item.text == "some updated text"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_item(item, @invalid_attrs)
      assert item == Tasks.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Tasks.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Tasks.change_item(item)
    end
  end
end
