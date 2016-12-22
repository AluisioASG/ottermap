import * as picomodal from "picomodal"
import {$id, $all, $sel, $addClass, $removeClass, $toggleClass} from "./util/dom"
import {listenOnce} from "./util/events"


/** Time to wait until the current operation is completed. */
const NEXT_TICK_INTERVAL = 40 /* 1000ms / 25fps */


// Prevent the browser from trying to submit the forms.
for (let form of $all("form")) {
  form.addEventListener("submit", evt => evt.preventDefault())
}


// The update form can be in one of two states.  At first, the user can
// enter their username and then place a marker representing their location
// in the map.  At this moment, the form's function changes to allowing the
// user to upload their location to the database.
//
// Here, we change the text of the update form's submit button when this
// state transition happens, i.e. after the first click.
const updateForm = $id("update-form")!
const submitButton = $sel(updateForm, "button[type=submit]")!
const submitText = $sel(submitButton, "span.button-text")!
submitText.textContent = "Add yourself to the map"
const submitIcon = $sel(submitButton, "span.glyphicon")!
$addClass(submitIcon, "glyphicon-map-marker")

listenOnce(updateForm, "submit", () => {
  submitText.textContent = "Upload location"
  $toggleClass(submitIcon, "glyphicon-map-marker", "glyphicon-cloud-upload")
  const usernameField = $sel(updateForm, "input[name=username]")! as HTMLInputElement
  $removeClass(usernameField, "hidden")
  usernameField.required = true
  usernameField.focus()
  usernameField.select()
  // Now that the input box is visible, we need the button to collapse in
  // smaller displays.
  $addClass(submitText, "hidden-xs")
})


/**
 * Define the map container's height.
 */
function resizeMap() {
  // Keep a reference to the map container.
  const mapContainer = $id("map")!

  // Compute the new height as the window height sans the top bar.  The bar
  // is fixed to the top of the document and the (also fixed) map container's
  // offset is set in the `top` CSS property, so we just need to subtract
  // this offset from the window's height.
  //
  // We assume the map container has no vertical padding or borders,
  // otherwise we'd need to take them into account.
  const windowHeight = document.documentElement.clientHeight
  const containerOffset = parseInt(window.getComputedStyle(mapContainer).top!, 10)
  mapContainer.style.height = `${windowHeight - containerOffset}px`

  const evt = document.createEvent("Event")
  evt.initEvent("resize", false, false)
  mapContainer.dispatchEvent(evt)
}

// Set the map's initial height after a small delay.  We do this because
// Opera seems to not have loaded the style sheet by the time this code is
// running.
setTimeout(resizeMap, NEXT_TICK_INTERVAL)

// Resize the map whenever the window is resized.
window.addEventListener("resize", () => {
  // Schedule the resizing to happen after the specified timespan.  If the
  // event is triggered again during that timespan, the handler is
  // rescheduled as before.
  //
  // Based on Lo-Dash's `debounce` function.
  let timer: number | null = null
  if (timer != null) {
    clearTimeout(timer)
  }
  timer = setTimeout(() => {
    timer = null
    resizeMap()
  }, NEXT_TICK_INTERVAL)
})


// Apply the user-defined styles to the markers.
const markerStyle = document.createElement("style")
markerStyle.innerHTML = ["default", "online", "offline"]
  .filter(mt => localStorage[`${mt} marker style`])
  .map(mt => `.marker-${mt.replace(/\s/g, "")} { ${localStorage[`${mt} marker style`]} }`)
  .join("\n")
document.head.appendChild(markerStyle)


/**
 * Configure the modal dialogs.
 */
function readyModal(contentId: string, buttonId: string): void {
  // Build the modal.
  // The modal's width has to be determined here too, otherwise it appears
  // too small on Internet Explorer.
  const modal = picomodal({
    content: $id(contentId),
    closeHtml: `<button type="button" class="close">&times;</button>`,
    width: window.innerWidth < 768 ? window.innerWidth : 600
  })
  // Unhide the modal content once it's out of the main document tree.
  modal.afterCreate(() => modal.modalElem().firstElementChild.hidden = false)
  // Show the modal when the corresponding button is clicked.
  $id(buttonId)!.addEventListener("click", () => modal.show())
}
readyModal("about-modal", "about-button")
readyModal("settings-modal", "settings-button")


// Remove the “no JavaScript” message once the map has been loaded.
listenOnce($id("map")!, "DOMSubtreeModified", () => {
  const msg = $id("noscript-msg")!
  msg.parentNode!.removeChild(msg)
})
