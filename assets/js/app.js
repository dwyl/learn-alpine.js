// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

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

    this.el.addEventListener("dragoverItem", e => {
      const currentItemId = e.detail.currentItemId
      const selectedItemId = e.detail.selectedItemId
      if( currentItemId != selectedItemId) {
        hook.pushEventTo("#items", "dragoverItem", {currentItemId: currentItemId, selectedItemId: selectedItemId})
      }
    })

    this.el.addEventListener("update-indexes", e => {
        const ids = [...document.querySelectorAll(".item")].map( i => i.dataset.id)
        hook.pushEventTo("#items", "updateIndexes", {ids: ids})
    })
  }
}

Hooks.Counter = {
  mounted() {
    const hook = this
    this.el.addEventListener("update-counter", e => {
      hook.pushEventTo("#counter", "update-counter", {counter: e.detail.counter})
    })
  }
}

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  dom:{
        onBeforeElUpdated(from, to) {
          if (from._x_dataStack) {
            window.Alpine.clone(from, to)
          }
        }
  },
  params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

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

window.addEventListener("phx:update-counter", (e) => {
    const counter = document.querySelector('#counter')
    Alpine.$data(counter).counter = e.detail.counter
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
