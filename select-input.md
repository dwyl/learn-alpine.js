<div align="center">

# Select Input

Search input to find items in dropdown.
</div>


## Create People

Let's create a `people` table:

```sh
mix ecto.gen.migration add_people_table
```

Add the following fields:

```exs
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
```

We have the `name`, `picture` and `selected` fields.
We'll update the selected value when the person's name is clicked in the
dropdown.

Let's now create a `Person` schema to manage the data `lib/app/tasks/person.ex`:


```elixir
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
```

Then in our `Tasks` context created in the `drag-and-drop` example, add the three
following functions, `lib/app/tasks.ex`:

```elixir
def get_person!(id), do: Repo.get!(Person, id)

def update_person(%Person{} = person, attrs) do
  person
  |> Person.changeset(attrs)
  |> Repo.update()
end

def list_people do
  Repo.all(from p in Person, order_by: [desc: p.selected, asc: p.name] )
end
```

Finally add people via the `priv/repo/seeds.exs` file:

```elixir
alias App.Tasks.Person

people = [
  %Person{
    name: "Person1",
    picture: "https://avatars.githubusercontent.com/...",
    selected: false
  }, # Add more people, see the seeds file in this repository
]
|> Enum.each(fn p -> App.Repo.insert!(p) end)
```

To make sure the seeds are inserted, run:

```sh
mix ecto.reset
```

If you check the `mix.exs` file you can see the `reset` is an alias for:


```elixir
"ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
"ecto.reset": ["ecto.drop", "ecto.setup"],
```

## Create a new live endpoint

In `lib/app_web/router.ex` add a new live endpoint:

```elixir
  scope "/", AppWeb do
    pipe_through :browser
    # other routes
    live "/select-input", SelectInputLive.Index, :index
  end
```

Create the `lib/app_web/live/select_input_live/index.ex` controller:

```elixir
defmodule AppWeb.SelectInputLive.Index do
  use AppWeb, :live_view
  alias App.Tasks

  @impl true
  def mount(_params, _session, socket) do
    people = Tasks.list_people()
    {:ok, assign(socket, :people, people)}
  end
end
```

And finally the `LiveView` template `lib/app_web/live/select_input_live/index.html.heex`:

```heex
<h1>Select Input</h1>
```

Run the server `mix phx.server` and you should be able to see the `/select-input` page.
