defmodule App.Tasks.Person do
  use Ecto.Schema
  import Ecto.Changeset

  schema "people" do
    field :name, :string
    field :picture, :string
    field :selected, :boolean

    timestamps()
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:name, :picture, :selected])
    |> validate_required([:name, :picture])
  end
end
