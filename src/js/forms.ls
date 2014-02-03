$, messagebar, mapMembersAPI, mapUserAPI, syncUserLocation, allUsers <-! define <[
  jquery messagebar map/members map/user data/sync data/allUsers domReady!
]>

# Text shown in the message bar when a search yield no results.
const NO_SEARCH_RESULTS_MESSAGE = '
  Those who you seek lie beyond our perception… but others await.
'


getUsername = -> $ it .find 'input[name=username]' .val!

# Setup user search.
$ \#search-form
.on \submit !->
  username = getUsername this .toLowerCase!
  matches = allUsers.select -> (~it.username.toLowerCase!indexOf username)
  # If there are no results, at least clear the corresponding layer.
  mapMembersAPI.displaySearchResults matches
  if matches.length is 0
    messagebar.show NO_SEARCH_RESULTS_MESSAGE, \info
.on \reset !->
  mapMembersAPI.displaySearchResults []

var g_marker
$ \#update-form
# Setup marker placement.
.one \submit !->
  $ '.leaflet-control-geosearch' .fadeIn!
  g_marker := mapUserAPI.placeUserMarker getUsername this
# Setup user location upload.
.one \submit !->
  <-! $(this).on \submit
  # Reset the upload button's color now, and set it to indicate success
  # once the upload is completed.
  $uploadButton =
    $(this).find 'button[type=submit]'
    .removeClass \btn-success
    .addClass \btn-default
  syncUserLocation (getUsername this), g_marker.getLatLng!, !->
    $uploadButton.toggleClass 'btn-default btn-success'
