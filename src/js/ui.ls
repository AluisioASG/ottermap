$ <-! define <[jquery messagebar domReady!]>

# Minimum height for the map we're going to allow.
const MINIMUM_MAP_HEIGHT = 320px

# Interval between map resizes.
const RESIZE_TRIGGER_INTERVAL = 125ms


# Setup the message bar, setting it to shadow the panel with the forms.
$ \#messagebar .trigger \setup '#topbar .panel'

# Prevent the browser from trying to submit the forms.
$ \form .on \submit (.preventDefault!)


# The update form can be in one of two states.  At first, the user
# can enter their username and then place a marker representing their
# location in the map.  At this moment, the form's function changes to
# allowing the user to upload their location to the database.
#
# Here, we change the text of the update form's submit button when this
# state transition happens, i.e. after the first click.
$updateForm = $ \#update-form

$submitButton =
  $updateForm.find 'button[type=submit]'
  .attr \title 'Place marker'
$submitIcon =
  $submitButton.find 'span.glyphicon'
  .addClass \glyphicon-map-marker

$ \#update-form .one \submit !->
  $submitButton.attr \title 'Upload location'
  $submitIcon.toggleClass 'glyphicon-map-marker glyphicon-cloud-upload'


# Keep a reference to the jQuerified map container handy.
$map = $ \#map

# Set the initial map height.
do resizeMap = !->
  currentHeight = $map.height!
  windowHeight = $ window .height!

  # Compute the new height as roughly the size of the window
  # sans the top panel.
  newHeight = windowHeight - ($ \.container .height! - currentHeight)
  # Make sure the new height is acceptable.
  if newHeight < MINIMUM_MAP_HEIGHT
    newHeight = windowHeight
  # Prevent unnecessary resizings.
  unless newHeight is currentHeight
    $map.height newHeight .trigger \resize
# Resize the map whenever the window is resized.
$map.on \resize !->
  # Schedule the resizing to happen after the specified timespan.
  # If the event is triggered again during that timespan, the handler
  # is rescheduled as before.
  #
  # Based on Lo-Dash's `debounce` function.
  clearTimeout timer
  timer = setTimeout !->
    timer := void
    resizeMap!
  , RESIZE_TRIGGER_INTERVAL


# Create a style element to hold our dynamically-build styles.
sheet = document.createElement \style
document.head.appendChild sheet

# Fill the style sheet.
do buildMarkersStylesheet = !->
  sheet.innerHTML = [\
    ".marker-#{type - /\s/g} { #{that} }" \
    for type in ['default' 'online' 'offline' 'search result']
    when localStorage["#{type} marker style"]?
  ] * '\n'

# Reload the style sheet whenever the `localStorage` keys
# are updated.
window.addEventListener \storage (evt) !->
  if evt.storageArea is localStorage and evt.key is / marker style$/
    buildMarkersStylesheet!
