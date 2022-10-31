# Drag and drop

A drag and drop implementation using Alpine.js and
Phoenix LiveView to sort a list of items.

The drag and drop actions are visible in real time to any browsers connected
to the Phoenix LiveView application.

versions used:

- Phoenix: 1.6.15
- LiveView: 0.18
- Alpine.js: 3.x.x

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
be used to display our items.

Petal is using [Tailwind](https://tailwindcss.com/) and [Alpine.js](https://alpinejs.dev/),
so we first need to install them. Follow the installation steps described in https://petal.build/components
to install Tailwind and Petal Components. (see also https://github.com/dwyl/learn-tailwind#part-2-tailwind-in-phoenix)


Petal is using LiveView 0.18. To avoid dependencies conflict you also need to update your
LiveView version to 0.18. In `mix.exs` make sure you have:

```elixir
{:phoenix_live_view, "~> 0.18"}
```

While we are waiting for Phoenix 1.7 to be available we need to fix
a breaking change linked to LiveView 0.18.
The `live_flash/2` is now part of the [Phoenix.Component](https://hexdocs.pm/phoenix_live_view/0.18.3/Phoenix.Component.html#live_flash/2)
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
See the [Alpine.js documentation](https://alpinejs.dev/essentials/installation).

If you prefer to avoid using the Alpine.js cdn link, you can download and save
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
Don't hesitate to open an issue on this Github repository if
you still think there is some missing information.


## Create items

We can use the [mix phx.gen.live](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Live.html)
command:

run `mix phx.gen.live Tasks Item items text:string index:integer`

This will create the 
- `Tasks` [context](https://hexdocs.pm/phoenix/contexts.html)
- `Item` [schema](https://hexdocs.pm/ecto/Ecto.Schema.html)
- `items` table with the text and index fields

Templates and live controllers will also be created automatically.
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
And we are using the `table` Petal component to display the items.


We also need to update the form modal which creates new items. Update the 
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

Then we need to update our `Item` schema to be able to save a new item.
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

You should now be able to create new items and see them displayed!
However we need to make sure an `index` value is also created for the item.
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
### PubSub

[PubSub](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html) is used 
to send and listen to `messages`. Any clients connected to a `topic` can 
listen for new messages on this topic. 

In this section we are using PubSub to notify clients when new items are created.

The first step is to connect the client when the LiveView page is requested.
We are going to add helper functions in `lib/app/tasks.ex` to manages the PubSub
feature, and the first one to add is `subscribe`:

```elixir
# Make sure to add the alias
alias Phoenix.PubSub

# subscribe to the `liveview_items` topic
def subscribe() do
  PubSub.subscribe(App.PubSub, "liveview_items")
end
```

Then in `lib/app_web/live/item_live/index.ex`, update the `mount` function to:

```elixir
def mount(_params, _session, socket) do
  if connected?(socket), do: Tasks.subscribe()
  {:ok, assign(socket, :items, list_items())}
end
```

We are checking if the socket is properly connected to the client before calling
the new `subscribe` function.


We are going to write now the `notify` function which uses the 
[PubSub.broadcast](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html#broadcast/4)
function to dispatch messages to clients

In `lib/app/tasks.ex`:

```elixir
def notify({:ok, item}, event) do
  PubSub.broadcast(App.PubSub, "liveview_items", {event, item})
  {:ok, item}
end

def notify({:error, reason}, _event), do: {:error, reason}
```

Then call this function inside the `create_item` function:

```elixir
def create_item(attrs \\ %{}) do
  items = list_items()
  index = length(items) + 1

  %Item{}
  |> Item.changeset(Map.put(attrs, "index", index))
  |> Repo.insert()
  |> notify(:item_created)
end
```

The `notify` function will send the `:item_created` message to all clients.

Finally we need to listen to this new messages and update our liveview.
In `lib/app_web/live/item_live/index.ex`, add:

```elixir
@impl true
def handle_info({:item_created, _item}, socket) do
  items = list_items()
  {:noreply, assign(socket, items: items)}
end
```

When the client receive the `:item_created` we are getting the list of items
from the database and assigning the list to the socket. This will update the 
liveview template with the new created item.


## Drag and Drop

Now that we can create items, we can finally start to implement our
drag and drop feature.

To be able to use Alpine.js with Phoenix LiveView we need to update `asset/js/app.js`:

```javascript
let liveSocket = new LiveSocket("/live", Socket, {
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to)
      }
    }
  },
    params: {_csrf_token: csrfToken}
})
```

This is to make sure Alpine.js keeps track of the DOM changes created by LiveView.

Now we're going to start by adding a new background colour to the item being
dragged and remove the colour when the drag ends.

We are going to define an Alpine component using the [x-data](https://alpinejs.dev/directives/data)
attribute:

> Everything in Alpine starts with the x-data directive.
x-data defines a chunk of HTML as an Alpine component and 
provides the reactive data for that component to reference.

in `lib/app_web/live/item_live/index.html.heex`:

```html
<tbody id="items" >
  <%= for item <- @items do %>
    <.tr id={"item-#{item.id}"} x-data="{}" draggable="true">
      <.td><%= item.text %></.td>
      <.td><%= item.index %></.td>
    </.tr>
  <% end %>
</tbody>
```

We have also added the [`draggable` html attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/draggable)
to the `tr` tags.

To add an event listener to your html tag Alpine.js provides the [x-on](https://alpinejs.dev/directives/on)
attribute. Lets' listen for the [dragstart](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/dragstart_event)
and [dragend](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/dragend_event)
events:


```html
<tbody id="items" >
  <%= for item <- @items do %>
    <.tr id={"item-#{item.id}"} 
        draggable="true">
        x-data="{selected: false}"
        x-on:dragstart="selected = true"
        x-on:dragend="selected = false"
        x-bind:class="selected ? 'cursor-grabbing' : 'cursor-grab'"
      <.td><%= item.text %></.td>
      <.td><%= item.index %></.td>
    </.tr>
  <% end %>
</tbody>
```

When the `dragstart` event is triggered (i.e. an item is moved) we update the newly
`selected` value to `true` (this value has been initalised in the `x-data` attribute).
When the `dragend` event is triggered we set `selected` to false.

Finally we are using `x-bind:class` to add css class depending on the value of
`selected`. In this case we have customised the display of the cursor.

To make is a bit more obvious which item is currently moved, we want to change
the background colour for this item. We also want all connected clients to see
the new background colour.

Update the `tr` tag with the following:

```html
<.tr
  id={"item-#{item.id}"}
  x-data="{selected: false}"
  draggable="true"
  x-on:dragstart="selected = true; $dispatch('highlight', {id: $el.id})"
  x-on:dragend="selected = false; $dispatch('remove-highlight', {id: $el.id})"
  x-bind:class="selected ? 'cursor-grabbing' : 'cursor-grab'"
>
```

The [dispatch](https://alpinejs.dev/magics/dispatch) Alpine.js function sends
a new custom js event.
We are going to use [hooks](https://hexdocs.pm/phoenix_live_view/js-interop.html#client-hooks-via-phx-hook)
to listen for this event and then notify LiveView.

In `assets/js/app.js`, add:


```javascript
let Hooks = {};
Hooks.Items = {
  mounted() {
    const hook = this

    this.el.addEventListener("highlight", e => {
      hook.pushEventTo("#items", "highlight", {id: e.detail.id})
    })
    
    this.el.addEventListener("remove-highlight", e => {
      hook.pushEventTo("#items", "remove-highlight", {id: e.detail.id})
    })
  }
}
```

Then add the Hooks js object to the socket:

```javascript
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks, //Add hooks
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to)
      }
    }
  },
    params: {_csrf_token: csrfToken}
})
```

The last step for the hooks to initialised is to add `phx-hook` attribute
in our `lib/app_web/live/item_live/index.html.heex`:

```heex
<tbody id="items" phx-hook="Items">
```

Note that the value of `phx-hook` must be the same as `Hooks.Items = ...` define
in `app.js`

We now have the hooks listening to the `highlight` and `remove-highlight` events,
and we use the [pushEventTo](https://hexdocs.pm/phoenix_live_view/js-interop.html#client-hooks-via-phx-hook) 
function to send a message to the LiveView server.

Let's add the following code to handle the new messages in `lib/app_web/live/item_live/index.ex`:

```elixir
@impl true
def handle_event("highlight", %{"id" => id}, socket) do
  Tasks.drag_item(id)
  {:noreply, socket}
end

@impl true
def handle_event("remove-highlight", %{"id" => id}, socket) do
  Tasks.drop_item(id)
  {:noreply, socket}
end  @impl true
```

The `Tasks` functions `drag_item` and `drop_item` are using PubSub to send
a message to all clients to let them know which item is being moved:

In `lib/app/tasks.ex`:

```elixir
def drag_item(item_id) do
  PubSub.broadcast(App.PubSub, "liveview_items", {:drag_item, item_id})
end

def drop_item(item_id) do
  PubSub.broadcast(App.PubSub, "liveview_items", {:drop_item, item_id})
end
```

Then back in `lib/app_web/live/item_live/index.ex` we handle these events with:

```elixir
@impl true
def handle_info({:drag_item, item_id}, socket) do
  {:noreply, push_event(socket, "highlight", %{id: item_id})} 
end

@impl true
def handle_info({:drop_item, item_id}, socket) do
  {:noreply, push_event(socket, "remove-highlight", %{id: item_id})} 
end
```

The LiveView will send the `highlight` and `remove-highlight` to the client.
The final step is to handle these Phoenix events with [Phoenix.LiveView.JS](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.JS.html)
to add and remove the background colour via Tailwind css class.

In `assets/js/app.js` add the event listeners:

```javascript
window.addEventListener("phx:highlight", (e) => {
  document.querySelectorAll("[data-highlight]").forEach(el => {
    if(el.id == e.detail.id) {
        liveSocket.execJS(el, el.getAttribute("data-highlight"))
    }
  })
})

window.addEventListener("phx:remove-highlight", (e) => {
  document.querySelectorAll("[data-highlight]").forEach(el => {
    if(el.id == e.detail.id) {
        liveSocket.execJS(el, el.getAttribute("data-remove-highlight"))
    }
  })
})
```

For each item we are checking if the id match the id linked to the drag/drop event,
then execute the Phoenix.LiveView.JS function that we now have to define:

```heex
<.tr
  id={"item-#{item.id}"}
  x-data="{selected: false}"
  draggable="true"
  x-on:dragstart="selected = true; $dispatch('highlight', {id: $el.id})"
  x-on:dragend="selected = false; $dispatch('remove-highlight', {id: $el.id})"
  x-bind:class="selected ? 'cursor-grabbing' : 'cursor-grab'"
  data-highlight={JS.add_class("!bg-yellow-300")}
  data-remove-highlight={JS.remove_class("!bg-yellow-300")}
>
```
Note the call to `add_class` and `remove_class`. You might need to add
`alias Phoenix.LiveView.JS` in `lib/app_web/live/item_live/index.ex` to make
sure the two functions are accessible in the template.


Again there are a few steps to make sure the highlight for the selected item
is properly displayed. However all the clients should now be able to see
the drag/drop action!


So far we have added the code to be able to drag an item, however we haven't yet
implemented the code to sort the items.

We want to switch the positions of the items when the selected item is hovering
over another item. 
We are going to use the [dragover](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/dragover_event)
event for this:


```heex
<tbody id="items" phx-hook="Items" x-data="{selectedItem: null}">
  <%= for item <- @items do %>
    <.tr
      id={"item-#{item.id}"}
      x-data="{selected: false}"
      draggable="true"
      x-on:dragstart="selected = true; $dispatch('highlight', {id: $el.id}); selectedItem = $el"
      x-on:dragend="selected = false; $dispatch('remove-highlight', {id: $el.id}); selectedItem = null"
      x-bind:class="selected ? 'cursor-grabbing' : 'cursor-grab'"
      x-on:dragover.throttle="$dispatch('dragoverItem', {selectedItemId: selectedItem.id, currentItemId: $el.id})"
      data-highlight={JS.add_class("!bg-yellow-300")}
      data-remove-highlight={JS.remove_class("!bg-yellow-300")}
    >
```

We have added `x-data="{selectedItem: null}` to the `tbody` html tag.
This value represents which element is currently being moved.

Then we have 
`x-on:dragover.throttle="$dispatch('dragoverItem', {selectedItemId: selectedItem.id, currentItemId: $el.id})"`

The [throttle](https://alpinejs.dev/directives/on#throttle) Alpine.js modifier
will only send the event `dragoverItem` once every 250ms max.
Similar to how we manage the highlights events, we need to update the `app.js` file
and add to the Hooks:


```javascript
this.el.addEventListener("dragoverItem", e => {
  const currentItemId = e.detail.currentItemId
  const selectedItemId = e.detail.selectedItemId
  if( currentItemId != selectedItemId) {
    hook.pushEventTo("#items", "dragoverItem", {currentItemId: currentItemId, selectedItemId: selectedItemId})
  }
})
```

We only want to push the `dragoverItem` event to the server if the item is over
an item which is different than itself.


On the server side we now add

- in `lib/app_web/live/item_live/index.ex`:


```elixir
@impl true
def handle_event(
      "dragoverItem",
      %{"currentItemId" => current_item_id, "selectedItemId" => selected_item_id},
      socket
    ) do
  Tasks.dragover_item(current_item_id, selected_item_id)
  {:noreply, socket}
end

@impl true
def handle_info({:dragover_item, {current_item_id, selected_item_id}}, socket) do
  {:noreply,
   push_event(socket, "dragover-item", %{
     current_item_id: current_item_id,
     selected_item_id: selected_item_id
   })}
end
```

Where `Tasks.dragover_item\2` is defined as:

```elixir
def dragover_item(current_item_id, selected_item_id) do
  PubSub.broadcast(App.PubSub, "liveview_items", {:dragover_item, {current_item_id,selected_item_id }})
end
```

Finally we in `app.js`:

```javascript
window.addEventListener("phx:dragover-item", (e) => {
  const selectedItem = document.querySelector(`#${e.detail.selected_item_id}`)
  const currentItem = document.querySelector(`#${e.detail.current_item_id}`)

  const items = document.querySelector('#items')
  const listItems = [...document.querySelectorAll('.item')]

  if(listItems.indexOf(selectedItem) < listItems.indexOf(currentItem)){
    items.insertBefore(selectedItem, currentItem.nextSibling)
  }
  
  if(listItems.indexOf(selectedItem) > listItems.indexOf(currentItem)){
    items.insertBefore(selectedItem, currentItem)
  }
})
```
We compare the selected item position in the list with the "over" item
and use `insertBefore` js function to add our item at the correct DOM place.


You should now be able to see on different clients the selected item
moved into the list during the drag and drop. However we haven't updated the
indexes of the items yet.

We want to send a new event when the `dragend` is emitted:

```heex
<.tr
  id={"item-#{item.id}"}
  data-id={item.id}
  class="item"
  x-data="{selected: false}"
  draggable="true"
  x-on:dragstart="selected = true; $dispatch('highlight', {id: $el.id}); selectedItem = $el"
  x-on:dragend="selected = false; $dispatch('remove-highlight', {id: $el.id}); selectedItem = null; %dispatch('update-indexes')"
  x-bind:class="selected ? 'cursor-grabbing' : 'cursor-grab'"
  x-on:dragover.throttle="$dispatch('dragoverItem', {selectedItemId: selectedItem.id, currentItemId: $el.id})"
  data-highlight={JS.add_class("!bg-yellow-300")}
  data-remove-highlight={JS.remove_class("!bg-yellow-300")}
>
```

We have added the `data-id` attribute to store the item's id.

In `app.js` we listen to the event:

```javascript
this.el.addEventListener("update-indexes", e => {
    const ids = [...document.querySelectorAll(".item")].map( i => i.dataset.id)
    hook.pushEventTo("#items", "updateIndexes", {ids: ids})
})
```

We are creating a list of the items' id that we push to the LiveView server with the
event `updateIndexes`

In `lib/app_web/live/item_live/index.ex` we add a new `handle_event`

```elixir
def handle_event("updateIndexes", %{"ids" => ids}, socket) do
(  Tasks.update_items_index(ids)
  {:noreply, socket}
end
```

And in `tasks.ex`:

```elixir
def update_items_index(ids) do
  ids
  |> Enum.with_index(fn id, index ->
    item = get_item!(id)
    update_item(item, %{index: index + 1})
  end)

  PubSub.broadcast(App.PubSub, "liveview_items", :indexes_updated)
end
```

For each id a new index is created using `Enum.with_index` and the item is updated.
(This might not be the best implementation for updating a list of items, so 
if you think there is a better way to do this don't hesitate to open an issue, thanks!)

Finally similar to the way we tell clients a new item has been created, we 
broadcast a new message, `indexes_updated`:

```elxir
def handle_info(:indexes_updated, socket) do
  items = list_items()
  {:noreply, assign(socket, items: items)}
end
```

We fetch the list of items from the database and let LiveView update the UI
automatically.

You should now have a complete drag-and-drop feature shared with multiple
clients!
