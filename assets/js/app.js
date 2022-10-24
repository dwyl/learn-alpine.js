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
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Drag and Drop JS version:

// Select all the items that are draggable
// and the list of items where we can move an item to.
const draggables = document.querySelectorAll(".draggable");
const listItems = document.querySelector("#items");

// For all items add the `dragstart` event listener
draggables.forEach(dragable => {
  dragable.addEventListener('dragstart', () => {
      dragable.classList.add('bg-red-300', 'dragging')
  });
  
   dragable.addEventListener('dragend', () => {
      dragable.classList.remove('bg-red-300', 'dragging')
  });
})

listItems.addEventListener('dragover', e => {
    e.preventDefault()
    const draggable = document.querySelector('.dragging')
    const nextItem = getNextItem(e.clientY)
    console.log(nextItem)
    if (nextItem == null) {
      listItems.appendChild(draggable)
    } else {
      listItems.insertBefore(draggable, nextItem)
    }
})

function getNextItem(y) {
  const draggables = [...document.querySelectorAll(".draggable:not(.dragging)")]
  return draggables.reduce(function(nextItem, currentItem) {
    const box = currentItem.getBoundingClientRect()
    const offset = y - (box.y - (box.height / 2))
    
    if (offset < 0 && offset > nextItem.offset) {
        return {offset: offset, element: currentItem}
    } else {
        return nextItem
    }
  }, {offset: Number.NEGATIVE_INFINITY}).element
}



















