dom, events, picomodal <-! define <[util/dom util/events picomodal domReady!]>
{$id, $all, $sel, $addClass, $removeClass, $toggleClass} = dom


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


# Define the map container's height.
resizeMap = !->
  # Keep a reference to the map container.
  mapContainer = $id \map

  # Compute the new height as the window height sans the top bar.
  # The bar is fixed to the top of the document and the (also fixed)
  # map container's offset is set in the `top` CSS property, so we
  # just need to subtract this offset from the window's height.
  #
  # We assume the map container has no vertical padding or borders,
  # otherwise we'd need to take them into account.
  windowHeight = document.documentElement.clientHeight
  containerOffset = parseInt (window.getComputedStyle mapContainer)[\top], 10
  mapContainer.style.height = "#{windowHeight - containerOffset}px"
  document.createEvent \Event
    ..initEvent \resize false false
    mapContainer.dispatchEvent ..

# Set the map's initial height after a small delay.  We do this
# because Opera seems to not have loaded the style sheet by the
# time this code is running.
setTimeout resizeMap, NEXT_TICK_INTERVAL

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


# Apply the user-defined styles to the markers.
document.createElement \style
  ..innerHTML = [\
    ".marker-#{type - /\s/g} { #{that} }" \
    for type in ['default' 'online' 'offline']
    when localStorage["#{type} marker style"]?
  ] * '\n'
  document.head.appendChild ..


# Configure the modal dialogs.
readyModal = (contentId, buttonId) !->
  # Build the modal.
  # The modal's width has to be determined here too, otherwise it
  # appears too small on Internet Explorer.
  modal = picomodal do
    content: $id contentId
    closeHtml: '<button type="button" class="close">&times;</button>'
    width: if window.innerWidth < 768px then window.innerWidth else 600px
  # Unhide the modal content once it's out of the main document tree.
  modal.afterCreate !->
    modal.modalElem!firstElementChild.hidden = false
  # Show the modal when the corresponding button is clicked.
  $id buttonId .addEventListener \click modal~show

readyModal \about-modal \about-button
readyModal \settings-modal \settings-button
