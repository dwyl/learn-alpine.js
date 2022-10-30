# Drag and drop

A drag and drop implementation using Alpine.js combine
with Phoenix LiveView to sort items in a list.


TOC

version used for this turorial:

Phoenix: 1.6.14
LiveView: 0.18

## Initialisation

Let's start by creating a new Phoenix application:

```sh
mix phx.new app --no-dashboard --no-gettext --no-mailer
```
Install the dependencies when asked:

```sh
Fetch and install dependencies? [Yn] y
```

Then follow the last instructions to make sure the Phoenix application
is running correctly:

```sh
cd app
mix ecto.create
mix phx.server
```

You should be able to see [localhost:4000/](localhost:4000/)

To build the UI we're going to use [Petal Components](https://petal.build/components).
Petal provides the [table](https://petal.build/components/table) components that will
use to display our items.

Petal is using [Tailwind](https://tailwindcss.com/) and [Alpine.js](https://alpinejs.dev/),
so we first need to install them. Follow the installation steps describe in https://petal.build/components
to install Tailwind and Petal Components. (see also https://github.com/dwyl/learn-tailwind#part-2-tailwind-in-phoenix)


Petal is using LiveView 0.18. To avoid dependecy conflict you need to update also your
LiveView version to 0.18. In `mix.exs` make sure you have:

```elixir
{:phoenix_live_view, "~> 0.18"}
```

While we are waiting for Phoenix 1.7 to be avalaible we need to fix
a breaking change linked to LiveView 0.18.
The `live_flash/2` is now part of [Phoenix.Component](https://hexdocs.pm/phoenix_live_view/0.18.3/Phoenix.Component.html#live_flash/2)
module. This function will be deprecated with Phoenix 1.7 but to make
sure our application can run we need to add this module in our `view_helper` function.

In `app_web.ex` and `import Phoenix.Component` in the `view_helper` function.

Before running the application we can clean the `lib/app_web/templates/layout/root.html.heex` file:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="csrf-token" content={csrf_token_value()} />
    <script defer src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js"></script>
    <%= live_title_tag(assigns[:page_title] || "App", suffix: " · Phoenix Framework") %>
    <link phx-track-static rel="stylesheet" href={Routes.static_path(@conn, "/assets/app.css")} />
    <script
      defer
      phx-track-static
      type="text/javascript"
      src={Routes.static_path(@conn, "/assets/app.js")}
    >
    </script>
  </head>
  <body>
    <%= @inner_content %>
  </body>
</html>
```

Note that we have added `<script defer src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js"></script>`
to the `head`. This will add Alpine.js features to our application.
See the [Alpine.js docuementation](https://alpinejs.dev/essentials/installation).

If you prefer to avoid using the Alpine.js cdn link, you can downaload and save
the content of the Alpine.js from https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js
into `assets/vendor/alpine.js` file and import in `app.js` with:

```js
import Alpine from "../vendor/alpine"
```



And the `lib/app_web/templates/page/index.html.heex`:

```html
<.container>
  <.h2 class="text-red-500">
    Hello App!
  </.h2>
</.container>
```

You can now run `mix deps.get` to make sure all dependencies are installed
and `mix phx.server`!

If you'd like to have the formatter working for the `.heex`
templates, you can update the `.formatter.exs` as describe in
https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.HTMLFormatter.html

There are a few steps to do for this setup.
Hopefully this will be simplified with Phoenix 1.7 coming soon.
Don't hesite to open an issue on this Github repository if
you still think there are some missing information.


## Create items

We can use the [mix phx.gen.live](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Live.html)
command:

run `mix phx.gen.live Tasks Item items text:string index:integer`

This will create the 
- `Tasks` [context](https://hexdocs.pm/phoenix/contexts.html)
- `Item` [schema](https://hexdocs.pm/ecto/Ecto.Schema.html)
- `items` table with the text and index fields

Templates and live controllers will also be crated automatically.
To keep the application simple we won't use the `edit`
and `delete` endpoints for items.

Update `lib/app_web/router.ex` with:

```elixir
  scope "/", AppWeb do
    pipe_through :browser
    live "/", ItemLive.Index, :index
    live "/items/new", ItemLive.Index, :new
  end
```

Update the created items templates to use
Petal components:

in `lib/app_web/live/item_live/index.html.heex`:

```heex
<.h1 class="text-lg">Listing Items</.h1>

<%= if @live_action in [:new, :edit] do %>
  <.modal return_to={Routes.item_index_path(@socket, :index)} title="New Item">
    <.live_component
      module={AppWeb.ItemLive.FormComponent}
      id={@item.id || :new}
      title={@page_title}
      action={@live_action}
      item={@item}
      return_to={Routes.item_index_path(@socket, :index)}
    />
  </.modal>
<% end %>

<.table>
  <thead>
    <.tr>
      <.th>Text</.th>
      <.th>Index</.th>
    </.tr>
  </thead>
  <tbody id="items">
    <%= for item <- @items do %>
      <.tr id={"item-#{item.id}"}>
        <.td><%= item.text %></.td>
        <.td><%= item.index %></.td>
      </.tr>
    <% end %>
  </tbody>
</.table>

<.button class="mt-3" link_type="live_patch" to={Routes.item_index_path(@socket, :new)} label="New Item"/>
```

Note that we have added the `title` attribute to the `modal` Petal component.
And we are using the `table` Petal component to dispaly the items.


We also need to update the form modal which create new items. Update the 
file in `lib/app_web/live/item_live/form_component.html.heex`:

```heex
<div>
  <.form
    let={f}
    for={@changeset}
    id="item-form"
    phx-target={@myself}
    phx-change="validate"
    phx-submit="save">
    
    <.form_field type="text_input" form={f} field={:text} placeholder="item" />
   
   <.button label="Save" phx_disable_with="Saving..." />
  </.form>
</div>
```

Now that our UI is fixed, we can focus on managing the events sent to the
liveView.

Let's first handle the event sent when the modal is closed.
The [Petal modal](https://petal.build/components/modals) sends the `close_modal`
event. Add the following function in `lib/app_web/live/item_live/index.ex`

```elixir
@impl true
def handle_event("close_modal", _, socket) do
  # Go back to the :index live action
  {:noreply, push_patch(socket, to: "/")}
end
```

Then we need to update our `Item` schema to able to save a new item.
Because we have removed from the modal form the `index` field, we also
want to remove the `validate_required` check for this field on the changeset.
Update `lib/app/tasks/item.ex`:

```elixir
def changeset(item, attrs) do
  item
  |> cast(attrs, [:text, :index])
  |> validate_required([:text])
end
```

You should now be able to create new items see them displayed!
However we need to make sure an index value for the created item.
Update the `create_item` function In `lib/app/tasks.ex`:

```elixir
def create_item(attrs \\ %{}) do
  items = list_items()
  index = length(items) + 1

  %Item{}
  |> Item.changeset(Map.put(attrs, "index", index))
  |> Repo.insert()
end
```
We make sure the item's index is equal to the number of existing items + 1.

Then we want to update the `list_items` function in the same file to get the
items order by their indexes:

```elixir
def list_items do
  Repo.all(from i in Item, order_by: i.index)
end
```

  update all to order by index
  PubSub

## Drag and Drop

  Alpine doc
  hook
  Update indexes

## Next

- add a new list
- drag and drop items between lists
- reorder lists

Thanks
refs: 
- https://developer.mozilla.org/en-US/docs/Web/API/HTML_Drag_and_Drop_API
- https://www.youtube.com/watch?v=jfYWwQrtzzY
