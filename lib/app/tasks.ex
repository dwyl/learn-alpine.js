defmodule App.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Tasks.Item
  alias Phoenix.PubSub

  # PubSub functions

  def subscribe() do
    PubSub.subscribe(App.PubSub, "liveview_items")
  end

  def notify({:ok, item}, event) do
    PubSub.broadcast(App.PubSub, "liveview_items", {event, item})
    {:ok, item}
  end

  def notify({:error, reason}, _event), do: {:error, reason}

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Repo.all(from i in Item, order_by: i.index)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    items = list_items()
    index = length(items) + 1

    %Item{}
    |> Item.changeset(Map.put(attrs, "index", index))
    |> Repo.insert()
    |> notify(:item_created)
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end

  def update_indexes(item_ids) do
    item_ids
    |> Enum.with_index(fn id, index ->
      item = get_item!(id)
      update_item(item, %{index: index + 1})
    end)

    {:ok, item_ids}
    |> notify(:item_created)
  end

  def item_selected(item_id) do
    PubSub.broadcast(App.PubSub, "liveview_items", {:item_selected, item_id})
  end

  def item_dropped(item_id) do
    PubSub.broadcast(App.PubSub, "liveview_items", {:item_dropped, item_id})
  end

  def drag_and_drop(item_id_over, item_id_dragged) do
    PubSub.broadcast(
      App.PubSub,
      "liveview_items",
      {:drag_and_drop, {item_id_over, item_id_dragged}}
    )
  end
end
