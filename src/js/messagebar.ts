import CSSAnimEvent from "cssanimevent/cssanimevent"
import {$id, $all, $sel, $addClass, $removeClass} from "./util/dom"


// Keep a reference to the message bar element.
const messagebar = $id("messagebar")!
// Remember the alert class for the last message.
let lastAlertClass: string

// Close the message bar when its close button is clicked.
$sel(messagebar, "button.close")!.addEventListener("click", hide)


/**
 * Show the message bar and display a message.  The alert class is the
 * suffix of one of those provided by Bootstrap.
 */
export function show(message: string, alertClass: string): void {
  if (alertClass != null) {
    alertClass = `alert-${alertClass}`
  }
  lastAlertClass = alertClass

  // Update the message bar with the given parameters.
  $addClass(messagebar, alertClass)
  $sel(messagebar, "p")!.textContent = message

  // Display the message bar.
  $removeClass(messagebar, "invisible", "mb-hide")
}

/**
 * Hide the message bar.
 */
export function hide(): void {
  // First fade the message bar, then mark it as invisible and remove the
  // alert class.
  $addClass(messagebar, "mb-hide")
  CSSAnimEvent.onTransitionEnd(messagebar, () => {
    $addClass(messagebar, "invisible")
    $removeClass(messagebar, lastAlertClass)
  })
}
