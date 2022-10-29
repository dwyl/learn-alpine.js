# Drag and drop

A drag and drop implementation using Alpine.js combine
with Phoenix LiveView to sort items in a list.


Let's start by creating a new Phoenix application:

```sh
mix phx.new . --app app --no-dashboard --no-gettext --no-mailer
```

Then we install Tailwind, see https://github.com/dwyl/learn-tailwind#part-2-tailwind-in-phoenix
and add Petal Component, this to create the UI without starting from scratch.

We can use `mix gen.live Tasks Item items text:string index:integer` to let Phoenix
create the structure for the live items' page.

We can now focus on using the drag and drop html feature.

Add the draggable attribute

see: 
- https://developer.mozilla.org/en-US/docs/Web/API/HTML_Drag_and_Drop_API
- https://www.youtube.com/watch?v=jfYWwQrtzzY
