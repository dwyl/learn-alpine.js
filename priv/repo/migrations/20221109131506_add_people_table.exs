defmodule App.Repo.Migrations.AddPeopleTable do
  use Ecto.Migration

  def change do
    create table(:people) do
      add :name, :string
      add :picture, :string
      add :selected, :boolean, default: false

      timestamps()
    end
  end
end
