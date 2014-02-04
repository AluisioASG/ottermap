dom, events <-! define <[util/dom util/events domReady!]>
{$id, $all, $sel, $addClass, $toggleClass} = dom


# Minimum height for the map we're going to allow.
const MINIMUM_MAP_HEIGHT = 320px

# Time to wait until the current operation is completed.
const NEXT_TICK_INTERVAL = 1000ms / 25fps


# Prevent the browser from trying to submit the forms.
for form in $all \form
  form.addEventListener \submit (.preventDefault!)


# The update form can be in one of two states.  At first, the user
# can enter their username and then place a marker representing their
# location in the map.  At this moment, the form's function changes to
# allowing the user to upload their location to the database.
#
# Here, we change the text of the update form's submit button when this
# state transition happens, i.e. after the first click.
updateForm = $id \update-form

submitButton = updateForm `$sel` 'button[type=submit]'
  ..title = 'Place marker'
submitIcon = submitButton `$sel` 'span.glyphicon'
  .. `$addClass` \glyphicon-map-marker

events.listenOnce updateForm, \submit, !->
  submitButton.title = 'Upload location'
  $toggleClass submitIcon, \glyphicon-map-marker \glyphicon-cloud-upload


# Keep a reference to the map container handy.
mapContainer = $id \map

# Get the height of the element's padding and border.  Subtract
# from the element's `offsetHeight` to get its content height.
getExtra = (elem) ->
  computedElementStyle = window.getComputedStyle elem, null
  prop = -> parseInt computedElementStyle[it], 10

  (prop \paddingTop) +
  (prop \paddingBottom) +
  (prop \borderTopWidth) +
  (prop \borderBottomWidth)

# Get an element's content size.
getHeight = (elem) ->
  elem.offsetHeight - getExtra elem

# Set an element's content size.
setHeight = (elem, value) !->
  value -= getExtra elem
  if value >= 0
    elem.style.height = "#{value}px"


# Set the initial map height.
do resizeMap = !->
  # Get the window's and the map container's heights.
  currentHeight = getHeight mapContainer
  windowHeight = document.documentElement.clientHeight
  # Compute the new height as the current height of the map plus the
  # difference of height between the page container and the window.
  newHeight =
    $sel \.container |> getHeight
    |> (- currentHeight)
    |> (windowHeight -)
  # Make sure the new height is acceptable.
  if newHeight < MINIMUM_MAP_HEIGHT
    newHeight = windowHeight
  # Prevent unnecessary resizings.
  unless newHeight is currentHeight
    setHeight mapContainer, newHeight
    resizeEvent = document.createEvent \Event
      ..initEvent \resize false false
    mapContainer.dispatchEvent resizeEvent

# Resize the map whenever the window is resized.
window.addEventListener \resize !->
  # Schedule the resizing to happen after the specified timespan.
  # If the event is triggered again during that timespan, the handler
  # is rescheduled as before.
  #
  # Based on Lo-Dash's `debounce` function.
  clearTimeout timer
  timer = setTimeout !->
    timer := void
    resizeMap!
  , NEXT_TICK_INTERVAL


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
