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

  def notify({:ok, message}, event) do
    PubSub.broadcast(App.PubSub, "liveview_items", {event, message})
  end

  def notify({:error, reason}, _event), do: {:error, reason}

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Repo.all(Item)
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
      update_item(item, %{index: (index + 1)})
    end)


    {:ok, item_ids}
    |> notify(:item_created)
  end
end
