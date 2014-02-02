L, map <- define <[leaflet map]>


# Zoom level after geosearch.
const GEOSEARCH_ZOOM_LEVEL = 15

# Geosearch provider.  See the L.GeoSearch plugin's documentation
# for available providers and required configuration.
const GEOSEARCH_PROVIDER = \OpenStreetMap


# Add the search control to the map.
new L.Control.GeoSearch do
  provider: new L.GeoSearch.Provider[GEOSEARCH_PROVIDER]
  zoomLevel: GEOSEARCH_ZOOM_LEVEL
  showMarker: false
.addTo map


# Define the module's API.
return
  # Place a marker representing the user at the map's current location.
  placeUserMarker: (title) ->
    marker = L.marker map.getCenter!,
      icon: new L.Icon.Default
      draggable: true
      title: title
    .addTo map
    map.addEventListener \click (event) !->
      marker.setLatLng event.latlng
    return marker
  # Remove the given user marker (returned by `placeUserMarker`)
  # from the map.
  removeUserMarker: (marker) !->
    map.removeLayer marker
