L, mapMarkersAPI, map, allUsers <-! define <[
  leaflet map/markers map data/allUsers
]>


# Zoom level after a search with a single result.
const SEARCH_RESULT_ZOOM_LEVEL = 10


# Fetch all members and add a layer for them.
membersLayer = new L.MarkerClusterGroup
map.addLayer membersLayer
allUsers.addEventListener \useradd ({detail: user}) !->
  marker = mapMarkersAPI.buildMemberMarker user
  membersLayer.addLayer marker
  user.addEventListener \unperson !->
    membersLayer.removeLayer marker

# Add the search control.
new L.Control.Search do
  layer: membersLayer
  circleLocation: false
  initial: false
  zoom: SEARCH_RESULT_ZOOM_LEVEL
.addTo map
