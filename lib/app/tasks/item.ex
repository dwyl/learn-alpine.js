defmodule App.Tasks.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :index, :integer
    field :text, :string

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:text, :index])
    |> validate_required([:text])
  end
end
