import * as L from "leaflet"
import "leaflet-markercluster"
import "leaflet-search"
import {users} from "../data"
import map from "../map"
import {$sel} from "../util/dom"
import {listenOnce} from "../util/events"
import {buildMemberMarker} from "./markers"


/** Zoom level after a search with a single result. */
const SEARCH_RESULT_ZOOM_LEVEL = 10


// Fetch all members and add a layer for them.
const membersLayer = new L.MarkerClusterGroup()
map.addLayer(membersLayer)
// tslint:disable-next-line:arrow-parens
users.addEventListener("useradd", ({detail: user}) => {
  const marker = buildMemberMarker(user)
  membersLayer.addLayer(marker)
  listenOnce(user, "unperson", () => membersLayer.removeLayer(marker))
})

// Tweak and add the search control.
class SearchControl extends L.Control.Search {
  constructor(options: any) {
    super(options)
  }

  onAdd(): HTMLDivElement {
    const container = super.onAdd.apply(this, arguments) as HTMLDivElement
    // Tell screen readers that the search button has a popup.
    container.setAttribute("aria-haspopup", "true")
    // Specialize the search input field's type.
    ;($sel(container, ".search-input")! as HTMLInputElement).type = "search"
    // Remove the cancel icon; let the browser handle it.
    const cancel = $sel(container, ".search-cancel")!
    cancel.parentNode!.removeChild(cancel)
    // Better describe the button.
    ;($sel(container, ".search-button")! as HTMLAnchorElement).title = "Locate OTTer"
    return container
  }
}

export default new SearchControl({
  layer: membersLayer,
  circleLocation: false,
  initial: false,
  zoom: SEARCH_RESULT_ZOOM_LEVEL,
}).addTo(map)
