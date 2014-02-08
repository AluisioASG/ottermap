dom, CSSAnimEvent <- define <[util/dom cssanimevent domReady!]>
{$id, $all, $sel, $addClass, $removeClass} = dom

var messagebar, lastAlertClass


# Show the message bar and display a message.  The alert class is the
# suffix of one of those provided by Bootstrap.
displayMessage = (message, alertClass) !->
  if alertClass
    alertClass = "alert-#{alertClass}"
  # Remember the alert class for the last message.
  lastAlertClass := alertClass

  # Update the message bar with the given parameters.
  (messagebar `$addClass` alertClass `$sel` \p).textContent = message

  # Display the message bar.
  $removeClass messagebar, \invisible \mb-hide

# Hide the message bar.
hideMessageBar = !->
  # First fade the message bar, then mark it as invisible and remove
  # the alert class.
  messagebar `$addClass` \mb-hide
  CSSAnimEvent.onTransitionEnd messagebar, !->
    messagebar `$addClass` \invisible `$removeClass` lastAlertClass


# Keep a reference to the message bar element.
messagebar = $id \messagebar

# Close the message bar when its close button is clicked.
(messagebar `$sel` \button.close).addEventListener \click hideMessageBar


# Define the module's API.
return
  show: displayMessage
  hide: hideMessageBar
