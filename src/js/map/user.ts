import * as L from "leaflet"
import {GeoSearchControl, OpenStreetMapProvider} from "leaflet-geosearch"
import map from "../map"
import {$sel, $addClass} from "../util/dom"


class CustomGeoSearchControl extends GeoSearchControl {
  constructor(options: GeoSearch.GeoSearchControlOptions) {
    super(options)
  }

  onAdd(): HTMLDivElement {
    const container = super.onAdd.apply(this, arguments) as HTMLDivElement
    const button = $sel(container, "a.leaflet-bar-part")! as HTMLAnchorElement
    // Tell screen readers that the search button has a popup.
    container.setAttribute("aria-haspopup", "true")
    // Set an icon to the search button.
    button.innerHTML = '<span class="glyphicon glyphicon-road"/>'
    // Better describe the button.
    button.title = "Search by address"
    return container
  }
}

// Add the search control to the map.
map.addControl(new CustomGeoSearchControl({
  provider: new OpenStreetMapProvider(),
  style: "button",
  showMarker: false,
}))


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
