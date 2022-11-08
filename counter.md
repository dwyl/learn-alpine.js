<div align="center">

# Counter

Create a counter where the increment/decrement actions are dispatched to the
connected clients.
</div>

Start by adding a new live endpoint in `lib/app_web/router.ex`:

```elixir
live "/counter", CounterLive.Index, :index
```

Create the `mount`, `handle_event` and `handle_info` functions in

`lib/app_web/live/counter_live/index.ex`:

```elixir
defmodule AppWeb.CounterLive.Index do
  use AppWeb, :live_view
  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: PubSub.subscribe(App.PubSub, "counter")
    {:ok, socket}
  end

  @impl true
  def handle_event("update-counter", %{"counter" => counter}, socket) do
    PubSub.broadcast(App.PubSub, "counter", {:counter, counter}) 
    {:noreply, socket}
  end
  
  @impl true
  def handle_info({:counter, counter}, socket) do
   {:noreply, push_event(socket, "update-counter", %{counter: counter})}
  end
end
```

Add the `lib/app_web/live/counter_live/index.html.heex` template:

```heex
<h1 class="font-bold">Counter LiveView</h1>

<div x-data="{counter: 0}" id="counter" phx-hook="Counter">
  <button class="w-32 text-center bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded m-3"
          @click="counter = counter - 1; $dispatch('update-counter', {counter: counter})">-</button>
  <span class="font-bold m-3" x-text="counter"></span>
  <button class="w-32 text-center bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded m-3"
          @click="counter = counter + 1; $dispatch('update-counter', {counter: counter})">
  +
  </button>
</div>
```

This template creates the Alpine.js component to store and manage the counter value.
We also use Phoenix hook to dispatch the new value of the counter when changed 
to the other clients.

Finally in `assets/js/app.js` add the Hook and the event listener:

```js
Hooks.Counter = {
  mounted() {
    const hook = this
    this.el.addEventListener("update-counter", e => {
      hook.pushEventTo("#counter", "update-counter", {counter: e.detail.counter})
    })
  }
}

window.addEventListener("phx:update-counter", (e) => {
    const counter = document.querySelector('#counter')
    Alpine.$data(counter).counter = e.detail.counter
})
```

The interesting part of this example is the use of `Alpine.$data` to access
the value of the counter from outside of the Alpine.js component.

