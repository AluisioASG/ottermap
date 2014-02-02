$ <- define <[jquery domReady!]>

var $shadows, lastAlertClass


# Keep a reference to the jQueryfied message bar element.
$messagebar = $ \#messagebar
# Setup events to show and hide the message bar.
.on \show (, type, message) !->
  # Allow `type` to not be specified.
  if not message?
    message = type
    messageClass = ''
  else
    messageClass = "alert-#{type}"

  displayMessage message, messageClass
.on \hide !->
  hideMessageBar!

# Close the message bar when its close button is clicked.
$messagebar.find \button.close .on \click !->
  $messagebar.trigger \hide


# Configure the message bar.  Currently this means only to specify
# the elements to be hidden when the bar is shown, if any.
setupMessageBar = (shadows) !->
  $shadows := $ shadows

# Show the message bar and display a message.  The alert class is the
# suffix of one of those provided by Bootstrap.
displayMessage = (message, alertClass) !->
  # Remember the alert class for the last message.
  lastAlertClass := alertClass

  # Update the message bar with the given parameters.
  $messagebar
  .addClass alertClass
  .find \p .text message .end!

  # Only show the message bar after the shadowed elements, if any,
  # are hidden.
  $shadows.slideUp!promise!done !->
    $messagebar.slideDown!

# Hide the message bar.
hideMessageBar = !->
  $messagebar.slideUp !->
    $messagebar.removeClass lastAlertClass
    # Show the shadowed elements again once the message bar is hidden.
    $shadows.slideDown!


# Handle an one-time message to setup the message bar.
$messagebar.on \setup (, shadows) !-> setupMessageBar shadows

# Allow the user to setup the message bar directly.
exports = (...args) !-> setupMessageBar void, args * \,
exports <<<
  setup: setupMessageBar
  show: displayMessage
  hide: hideMessageBar
