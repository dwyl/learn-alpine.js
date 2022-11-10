<div align="center">

# Select Input

Search input to find items in a dropdown.
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

## Build the Alpine.js component

We're going to start by creating the html structure required for our input and dropdown:

```heex
<div class="w-72">
  <input type="text" class="w-full"/>

  <div>
    <ul class="border bg-white">
      <%= for person <- @people do %>
        <li><%= person.name %></li>
      <% end %>
    </ul>
  </div>
</div>
```

We have a `main` div containing the input text and another div which displays
the `ul` and `li`s html tags.

The "main" div is using a fixed defined by `w-72` and we apply the `w-full` to the input
to make sure the width matches the main div width.

We add `border bg-white` on the `ul` tag to create a border around the list
of items.

You  should now have something similar to:

![select-input](https://user-images.githubusercontent.com/6057298/201061261-6f4413b5-9b5f-4f91-bab3-b80caa836deb.png)

We can now use Alpine.js to hide/show the list of items:

```heex
<div class="w-72"
  x-data="{open: false}"
  x-on:click.away="open = false"
  x-on:keydown.escape="open = false"
>
  <input type="text" 
    class="w-full"
    x-on:input="open = true"
    x-on:focus="open = true"
  />

  <div>
    <ul class="border bg-white" x-show="open">
      <%= for person <- @people do %>
        <li><%= person.name %></li>
      <% end %>
    </ul>
  </div>
</div>
```

We have added `x-data="{open: false}"` to create the initial value to hide the
dropdown by default. We then use `x-show` on the `ul` tag. This will track
the `open` boolean value and display accordingly the items.

To change the `open` value we are using `input, focus, click.away` and `keywdown.escape`
events on the main div and the input.

The dropdown now should toggle when you start typing in the input.
However if there is some content under the input-select, this content will be
pushed down when the dropdown is opened. You can test it by adding a new paragraph:

```heex
<p class="w-72">More content, more content, more content,
  more content, more content,more content, more content,
  more content, more content,more content, more content,
  more content, more content,more content, more content,
  more content, more content,more content, more content,
  more content, more content,more content, more content,</p>
```

![image](https://user-images.githubusercontent.com/6057298/201067488-5e125e78-1706-46bb-b15c-bccd0637e427.png)
![image](https://user-images.githubusercontent.com/6057298/201067582-c34585a0-5769-433e-8d3b-6993b5a93686.png)

To fix this we can use the `absolute` and `relative` positions on the list

```heex
<div class="relative z-10">
    <ul class="absolute border bg-white" x-show="open">
      <%= for person <- @people do %>
        <li><%= person.name %></li>
      <% end %>
    </ul>
</div>
```

With `absolute` position the list of items is removed from the flow of the page
and placed relatively to its parent div containing the `relative` position.
To make sure that no other element on the page could be hiding the the dropdown
we have also added the `z-10` class to define a z-index value.

Before focusing on the styling of the items we can add the `drop-shadow-lg` class
to have an "hover" effect
and make sure there is a max height and we can scroll down the list by  using the 
`max-h-64` and `overflow-auto` classes:

```heex
<div class="relative z-11 drop-shadow-lg">
  <ul class="absolute border bg-white max-h-64 overflow-auto w-full" x-show="open">
    <%= for person <- @people do %>
      <li><%= person.name %></li>
    <% end %>
  </ul>
</div>
```
![image](https://user-images.githubusercontent.com/6057298/201071031-fa732ee6-10d3-416c-9e7d-c67e5bdc7f97.png)


For the items' style we can start with the following classes to add a border,
padding a cursor style and a background color on hover:

```heex
<li class="border-b p-2 cursor-pointer hover:bg-slate-200">
  <%= person.name %>
</li>
```

We now want to display three elements for our items, the profile picture, the name
and a check image to represent the `selected` value for the person. Let's start
with the image and the name:

```heex
<li class="border-b p-3 cursor-pointer hover:bg-slate-200">
  <div class="h-10">
    <div class="inline-flex items-center">
      <img src={person.picture} class="w-10 rounded-full mx-2"/>
      <%= person.name %>
    </div>
  </div>
</li>
```

We have created a new `div` inside the `li` with the class `h-10` to give a bit 
more height to the items. Then another `div` is used specifically for containing
the image and name. We are using the `flex` classes to be able to center the elements
vertically. Finally we have applied the `w-10 rounded-full mx-2` to the image
to make it round and to define its size and horizontal margin:

![image](https://user-images.githubusercontent.com/6057298/201084428-262f9ea7-7e15-4188-a2f3-1854be23eea9.png)


Finally to display the check icon, we are using a svg image from [Heroicons](https://heroicons.com/):

```heex
<div class="relative h-10">
  <div class="inline-flex items-center">
    <img src={person.picture} class="w-10 rounded-full mx-2" />
    <%= person.name %>
  </div>
  <%= if !person.selected do %>
    <svg
      class="absolute font-bold w-4 top-0 bottom-0 m-auto right-0 text-green-500"
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="currentColor"
    >
      <path
        fill-rule="evenodd"
        d="M19.916 4.626a.75.75 0 01.208 1.04l-9 13.5a.75.75 0 01-1.154.114l-6-6a.75.75 0 011.06-1.06l5.353 5.353 8.493-12.739a.75.75 0 011.04-.208z"
        clip-rule="evenodd"
      />
    </svg>
  <% end %>
</div>
```

First we have added a `relative` class in our item div, then in the svg we have the
following classes:

`class="absolute font-bold w-4 top-0 bottom-0 m-auto right-0 text-green-500"`

The `absolute` class with `right-0` places the check on the right side of the item.
the `top-0 bottom-0 m-auto` make the check center vertically:

![image](https://user-images.githubusercontent.com/6057298/201087061-e83efe08-9995-4948-8be7-bf1e2a1eecc4.png)

To finish the css styling, the last issue we want to fix is the overflow of the
person name:

![image](https://user-images.githubusercontent.com/6057298/201087240-f5ec8067-7029-4479-a065-9afa6aa8a45c.png)

```heex
<div class="inline-flex items-center w-52">
  <img src={person.picture} class="w-10 rounded-full mx-2" />
  <span class="overflow-hidden text-ellipsis whitespace-nowrap">
    <%= person.name %>
  </span>
</div>
```

We have added a fixed width the div `w-52`.
Then a span defines how to display the name when the text overflows. In our case
we add ellipsis.

![image](https://user-images.githubusercontent.com/6057298/201088626-ef06b1b4-f3dd-476d-a58f-1a48ba3165f5.png)


## Search and select people

To filter the list of people when we start to search add the following 
[Phoenix bindings](https://hexdocs.pm/phoenix_live_view/bindings.html) to the input:

```heex
<input
  type="text"
  class="w-full"
  x-on:input="open = true"
  x-on:focus="open = true"
  phx-keyup="filter-items"
  phx-debounce="250"
/>
```
We are sending the `filter-items` directly to the Phoenix server. We are also
using `phx-debounce="250"` to only send the event every 250ms.

In `lib/app_web/live/select_input_live/index.ex` handle the event with:

```elixir
@impl true
def handle_event("filter-items", %{"key" => _key, "value" => value}, socket) do
  people =
    Tasks.list_people()
    |> Enum.filter(fn p -> String.contains?(String.downcase(p.name), String.downcase(value)) end)

  {:noreply, assign(socket, :people, people)}
end
```

We filter the list of people by checking if the input search matches the person's name.


The other event we want to add is the toggle for the `selected` value.
We add an id and  a phx-hook, then we create a new event using Alpine.js `dispatch`:

```heex
<div id="list-items" class="relative z-10 drop-shadow-lg" phx-hook="SelectInput">
  <ul class="absolute border bg-white max-h-64 overflow-auto w-full" x-show="open">
    <%= for person <- @people do %>
      <li
        class="border-b p-2 cursor-pointer hover:bg-slate-200"
        x-on:click={"$dispatch('toggle-item', {id: #{person.id}})"}
      >
      ...
```

In `lib/assets/js/app.js` create the Hook:

```js
// Hook for selecte input example
Hooks.SelectInput = {
  mounted() {
    this.el.addEventListener("toggle-item", e => {
      this.pushEventTo("#list-items", "toggle", {id: e.detail.id})
    })
  }
}
```

And finally handle the `toggle` event in LiveView endpoint:

```elixir
@impl true
def handle_event("toggle", %{"id" => person_id}, socket) do
  person = Tasks.get_person!(person_id)
  Tasks.update_person(person, %{selected: !person.selected})

  people = Tasks.list_people()
  {:noreply, assign(socket, :people, people)}
end
```

You should now have a functional search input with dropdown!

If you think there is a better use of css/html to build this example, don't
hesitate to open an issue/PR, thanks!
