dom, L, mapMarkersAPI, map, data <-! define <[
  util/dom leaflet map/markers map data
]>
{$sel} = dom


# Zoom level after a search with a single result.
const SEARCH_RESULT_ZOOM_LEVEL = 10


# Fetch all members and add a layer for them.
membersLayer = new L.MarkerClusterGroup
map.addLayer membersLayer
data.users.addEventListener \useradd ({detail: user}) !->
  marker = mapMarkersAPI.buildMemberMarker user
  membersLayer.addLayer marker
  user.addEventListener \unperson !->
    membersLayer.removeLayer marker

# Tweak and add the search control.
class SearchControl extends L.Control.Search
  -> super ...
  onAdd: ->
    super ...
      ..setAttribute \aria-haspopup \true
      .. `$sel` \.search-input
        ..type = \search
      .. `$sel` \.search-cancel
        ..parentNode.removeChild ..

new SearchControl do
  layer: membersLayer
  circleLocation: false
  initial: false
  zoom: SEARCH_RESULT_ZOOM_LEVEL
.addTo map
