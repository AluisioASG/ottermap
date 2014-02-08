dom, events <-! define <[util/dom util/events domReady!]>
{$id, $all, $sel, $addClass, $removeClass, $toggleClass} = dom


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
submitText = submitButton `$sel` 'span.button-text'
  ..textContent = 'Add yourself to the map'
submitIcon = submitButton `$sel` 'span.glyphicon'
  .. `$addClass` \glyphicon-map-marker

events.listenOnce updateForm, \submit, !->
  submitText.textContent = 'Upload location'
  $toggleClass submitIcon, \glyphicon-map-marker \glyphicon-cloud-upload
  updateForm `$sel` 'input[name=username]'
    .. `$removeClass` \hidden
    ..required = true
    ..focus!
    ..select!
  # Now that the input box is visible, we need the button to collapse
  # in smaller displays.
  submitText `$addClass` \hidden-xs


# Keep a reference to the map container handy.
mapContainer = $id \map

# Helper to get the computed value of a CSS property specified
# in pixels.
computedCssLength = (elem, prop, compstyle) ->
  compstyle ?= window.getComputedStyle elem, null
  parseInt compstyle[prop], 10

# Get or set an element's content size.
height = (elem, newValue) ->
  # Get the height of the element's padding and border.  Subtract
  # from the element's `offsetHeight` to get its content height.
  computedElementStyle = window.getComputedStyle elem, null
  prop = -> computedCssLength elem, it, computedElementStyle

  extraHeight =
    (prop \paddingTop) +
    (prop \paddingBottom) +
    (prop \borderTopWidth) +
    (prop \borderBottomWidth)

  if not newValue?
    return elem.offsetHeight - extraHeight
  else
    newValue -= extraHeight
    if newValue >= 0
      elem.style.height = "#{newValue}px"
    return


# Set the initial map height.
do resizeMap = !->
  # Get the window's and the map container's heights.
  currentHeight = height mapContainer
  windowHeight = document.documentElement.clientHeight
  # Compute the new height as the current height of the map plus the
  # difference of height between the page container and the window.
  newHeight = windowHeight - computedCssLength mapContainer, \top
  # Make sure the new height is acceptable.
  if newHeight < MINIMUM_MAP_HEIGHT
    newHeight = windowHeight
  # Prevent unnecessary resizings.
  unless newHeight is currentHeight
    height mapContainer, newHeight
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
    for type in ['default' 'online' 'offline']
    when localStorage["#{type} marker style"]?
  ] * '\n'

# Reload the style sheet whenever the `localStorage` keys
# are updated.
window.addEventListener \storage (evt) !->
  if evt.storageArea is localStorage and evt.key is / marker style$/
    buildMarkersStylesheet!
