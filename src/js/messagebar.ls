$ <- define <[jquery]>
setupMessageBar = (, shadows) !->
  $shadows = $ shadows
  $messagebar = $ \#messagebar

  # Setup events to show and hide the message bar.
  var messageClass
  $messagebar
  .on \show (, type, message) !->
    # Allow `type` to not be specified.
    if not message?
      message = type
      messageClass := ''
    else
      messageClass := "alert-#{type}"

    # Update the message bar with the given parameters.
    $messagebar
    .addClass messageClass
    .find \p .text message .end!

    # Only show the message bar after the shadowed elements, if any,
    # are hidden.
    $shadows.slideUp!promise!done !->
      $messagebar.slideDown!
  .on \hide !->
    $messagebar.slideUp !->
      $messagebar.removeClass messageClass
      # Show the shadowed elements again once the message bar is hidden.
      $shadows.slideDown!

  # Close the message bar when its close button is clicked.
  $messagebar.find \button.close .on \click !->
    $messagebar.trigger \hide


$ !->
  # Handle an one-call message to setup the message bar.
  $ \#messagebar .on \setup setupMessageBar

# Allow the user to setup the message bar directly.
return (...args) !-> setupMessageBar void, args * \,
