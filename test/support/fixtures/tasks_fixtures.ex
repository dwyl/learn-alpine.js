defmodule App.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Tasks` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        index: 42,
        text: "some text"
      })
      |> App.Tasks.create_item()

    item
  end
end
