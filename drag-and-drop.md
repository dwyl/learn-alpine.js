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

There are quiet a few steps to do for this setup.
Hopefully this will be simplified with Phoenix 1.7 coming soon.
Don't hesite to open an issue on this Github repository if
you still think there are some missing information.







We can use `mix gen.live Tasks Item items text:string index:integer` to let Phoenix
create the structure for the lve items' page.

We can now focus on using the drag and drop html feature.

Add the draggable attribute

refs: 
- https://developer.mozilla.org/en-US/docs/Web/API/HTML_Drag_and_Drop_API
- https://www.youtube.com/watch?v=jfYWwQrtzzY
