L, dataAPI, map, layerControl, populateMarkerLayer <- define <[
  leaflet data map map/layers map/markers
]>


# Zoom level after a search with a single result.
const SEARCH_RESULT_ZOOM_LEVEL = 10


# Fetch all members and add a layer for them.
membersLayer = new L.MarkerClusterGroup
map.addLayer membersLayer
layerControl.addOverlay membersLayer, 'All members'
dataAPI.getLocationData (locationData) !->
  populateMarkerLayer membersLayer, locationData

# Add a layer for search results.
searchLayer = new L.MarkerClusterGroup
map.addLayer searchLayer
layerControl.addOverlay searchLayer, 'Search results'


# Define the module's API.
return
  # Display search results in their specific layer.
  displaySearchResults: (results) !->
    populateMarkerLayer searchLayer, results, true
    if results.length is 1
      # Zoom to the single result.
      map.setView results[0].location, SEARCH_RESULT_ZOOM_LEVEL,
        animate: true
