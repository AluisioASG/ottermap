messagebar, events, mapMembersAPI, mapUserAPI, syncUserLocation, allUsers <-! define <[
  messagebar util/events map/members map/user data/sync data/allUsers domReady!
]>


# Text shown in the message bar when a search yield no results.
const NO_SEARCH_RESULTS_MESSAGE = '
  Those who you seek lie beyond our perception… but others await.
'

# Time to wait until the current operation is completed.
const NEXT_TICK_INTERVAL = 1000ms / 25fps


getUsername = -> it.querySelector 'input[name=username]' .value

# Setup user search.
document.getElementById \search-form
  ..addEventListener \submit !->
    username = getUsername this .toLowerCase!
    matches = allUsers.select -> (~it.username.toLowerCase!indexOf username)
    # If there are no results, at least clear the corresponding layer.
    mapMembersAPI.displaySearchResults matches
    if matches.length is 0
      messagebar.show NO_SEARCH_RESULTS_MESSAGE, \info
  ..addEventListener \reset !->
    mapMembersAPI.displaySearchResults []

var g_marker
document.getElementById \update-form
  # Setup marker placement.
  ..|> events.listenOnce _, \submit, !->
    geoSearchControl = document.querySelector '.leaflet-control-geosearch'
    geoSearchControl.style.display = 'block'
    setTimeout !->
      geoSearchControl.style.opacity = '1'
    , NEXT_TICK_INTERVAL
    g_marker := mapUserAPI.placeUserMarker getUsername this
  # Setup user location upload.
  ..|> events.listenOnce _, \submit, !->
      <-! this.addEventListener \submit
      # Reset the upload button's color now, and set it to indicate success
      # once the upload is completed.
      uploadButton = this.querySelector 'button[type=submit]'
        ..className -= /\bbtn-success\b/
        ..className += ' btn-default'
      syncUserLocation (getUsername this), g_marker.getLatLng!, !->
        uploadButton
          ..className -= /\bbtn-default\b/
          ..className += ' btn-success'
