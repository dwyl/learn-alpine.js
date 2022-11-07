<div align="center">

![learn-alpinejs-logo](https://user-images.githubusercontent.com/194400/173522456-81ef8a00-7dcf-4300-8e87-281ab251878e.png)

Learn how to use **`Alpine.js`** to build **declarative + responsive UI _fast_**!

</div>

## Why? 🤷

We heard a lot about **`Alpine.js`** 
[online](https://github.com/dwyl/technology-stack/issues/87) 
and wanted to know what the fuss was about. <br />
We weren't disappointed.
You won't be either.
It's a compact, functional and performant library.


## What? 💡

**`Alpine.js`** lets you add 
[progressive enhancements](https://en.wikipedia.org/wiki/Progressive_enhancement)
to any **HTML** page
with _minimal_ in-line declarative code. 
This makes it easy to add attractive/useful UI elements 
such as toggle, fade-in/out, transitions and other effects.

If you've been building websites since the 
[**`jQuery`**](https://jquery.com/) 
days ... ⏳ <br />
We consider **`Alpine.js`** a good _declarative_ "successor" to **`jQuery`**.

> **Note**: **`Alpine.js`** is not _quite_ as elegant as 
[**`svelte`**](https://svelte.dev/).<br />
However **`svelte`** wants to "_own_" the 
[**`DOM`**](https://en.wikipedia.org/wiki/Document_Object_Model)
which means it doesn't play nicely with **`LiveView`** ... <br />
So this is our best option for now.


## Who? 👤

+ [x] Anyone building a Static website that needs good UI enhancements.
+ [x] People in the **`@dwyl`** team that want to understand how we're building our Web App(s).

<br />

## _How?_ 💻

Clone:

```sh
git clone git@github.com:dwyl/learn-alpine.js.git && cd learn-alpine.js
```

### Install ⬇️

We are using [Phoenix](https://github.com/dwyl/learn-phoenix-framework/)
to render the Alpine.js examples.

Run the following commands in your terminal:

```sh
mix deps.get
mix phx.server
```

Don't hesitate to open [issues](https://github.com/dwyl/learn-phoenix-framework/issues/)
if you have any questions linked to Phoenix!

Visit [localhost:4000](http://localhost:4000) where you can see a list of
examples we have created, for example:

<img width="784" alt="image" src="https://user-images.githubusercontent.com/194400/173512514-b32d0dec-8568-4518-b493-f18ce3f82e94.png">

e.g: https://dwyl.github.io/learn-alpine.js

Then you can follow the tutorial: 
https://alpinejs.dev/start-here

Or if you have a decent internet connection
this video is a good intro: 
https://youtu.be/r5iWCtfltso


### Stopwatch! ⏱️

Once you have a basic understanding of how Alpine.js's directives work.
checkout our Stopwatch example:
https://dwyl.github.io/learn-alpine.js/stopwatch.html

Code: [**`stopwatch.html`**](https://github.com/dwyl/learn-alpine.js/blob/main/stopwatch.html)

### Drag and drop

A Phoenix + Alpine.js application using drag and drop to sort items in table.

See [drag-and-drop.md](drag-and-drop.md)
