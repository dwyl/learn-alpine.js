// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

// If you want to use Phoenix channels, run `mix help phx.gen.channeItem 2l`
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
import Alpine from "../vendor/alpine"


let Hooks = {}
Hooks.SortList = {
  mounted() {
    const hook = this
    this.el.addEventListener("sortListEvent", e => {
        // get list of ids in the new order
        const itemIds = [...document.querySelectorAll('.draggable')].map(e => e.dataset.id)
        hook.pushEventTo("#items", "sort-items", {itemIds: itemIds})
    })
    
    this.el.addEventListener("hightlightItem", e => {
        itemId = e.detail.id
        hook.pushEventTo("#items", "highlight-item", {itemId: itemId})
    })
    
    this.el.addEventListener("removeHighlight", e => {
        itemId = e.detail.id
        hook.pushEventTo("#items", "remove-highlight", {itemId: itemId})
    })
    
    
    this.el.addEventListener("dragElt", e => {
        idOver = e.detail.idOver
        idDragged = e.detail.idDragged
        // hook.pushEventTo("#items", "drag-elt", {idOver: idOver, idDragged: idDragged})
        if (idOver != idDragged) {
          hook.pushEventTo("#items", "drag-elt", {idOver: idOver, idDragged: idDragged})
        }
    })
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to)
      }
    }
  },
    params: {_csrf_token: csrfToken}
})

window.addEventListener(`phx:highlight`, (e) => {
  document.querySelectorAll(`[data-highlight]`).forEach(el => {

    if(el.id == e.detail.id){
      liveSocket.execJS(el, el.getAttribute("data-highlight"))
    }
  })
})

window.addEventListener(`phx:remove-highlight`, (e) => {
  document.querySelectorAll(`[data-remove-highlight]`).forEach(el => {

    if(el.id == e.detail.id){
      liveSocket.execJS(el, el.getAttribute("data-remove-highlight"))

    }
  })
})

window.addEventListener(`phx:drag-and-drop`, (e) => {
  overItem = document.querySelector(`#${e.detail.item_id_over}`)
  draggedItem = document.querySelector(`#${e.detail.item_id_dragged}`)
   const items = document.querySelector('#items')
   const listItems = [...document.querySelectorAll(".draggable")]
    //
    if (listItems.indexOf(draggedItem) < listItems.indexOf(overItem)) {
       items.insertBefore(draggedItem, overItem.nextSibling) 
    } 
    if (listItems.indexOf(draggedItem) > listItems.indexOf(overItem)) {
        items.insertBefore(draggedItem, overItem) 
    }
  // document.querySelectorAll(`[data-hover]`).forEach(el => {

  //   if(el.id == e.detail.id){
  //     liveSocket.execJS(el, el.getAttribute("data-hover"))
  //   }
  // })
})

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
//
// const draggables = document.querySelectorAll(".draggable");
// const listItems = document.querySelector("#items");
// 
// draggables.forEach(dragable => {
//   dragable.addEventListener('dragstart', () => {
//       dragable.classList.add('bg-red-100', 'dragging')
//   });
//   
//    dragable.addEventListener('dragend', () => {
//       dragable.classList.remove('bg-red-100', 'dragging')
//   });
// })
// 
// listItems.addEventListener('dragover', e => {
//     e.preventDefault()
//     const dragged = document.querySelector('.dragging')
//     const overItem = getOverItem(e.clientY)
//     const moving = direction(dragged, overItem)
//     if (moving == "down") {
//       listItems.insertBefore(dragged, overItem.nextSibling)
//     } 
// 
//     if (moving == "up"){
//       listItems.insertBefore(dragged, overItem)
//     }
// })
// 
// function getOverItem(y) {
//   const draggables = [...document.querySelectorAll(".draggable")]
//   return draggables.find( item => {
//     const box = item.getBoundingClientRect()
//     return  y > box.top && y < box.bottom
//   })
// }
// 
// function direction(dragged, overItem) {
//   const draggables = [...document.querySelectorAll(".draggable")]
//   if (draggables.indexOf(dragged) < draggables.indexOf(overItem)) {
//     return "down" 
//   } else {
//     return "up"
//   }
// }
