import * as L from "leaflet"
import "leaflet-geosearch"
import map from "../map"


// Zoom level after geosearch.
const GEOSEARCH_ZOOM_LEVEL = 15

// Geosearch provider.  See the L.GeoSearch plugin's documentation for
// available providers and required configuration.
const GEOSEARCH_PROVIDER = "OpenStreetMap"
import "leaflet-geosearch.js/l.geosearch.provider.openstreetmap"


// Add the search control to the map.
new L.Control.GeoSearch({
  provider: new L.GeoSearch.Provider[GEOSEARCH_PROVIDER](),
  zoomLevel: GEOSEARCH_ZOOM_LEVEL,
  showMarker: false,
}).addTo(map)


/**
 * Place a marker representing the user at the map's current location.
 */
export function placeUserMarker(title: string): L.Marker {
  const marker = L.marker(map.getCenter(), {
    icon: new L.Icon.Default(),
    draggable: true,
    title: title,
  }).addTo(map)
  map.addEventListener("click", (event: L.LeafletLocationEvent) => marker.setLatLng(event.latlng))
  return marker
}

/**
 * Remove the given user marker (returned by {@link placeUserMarker}) from
 * the map.
 */
export function removeUserMarker(marker: L.Marker): void {
  map.removeLayer(marker)
}
