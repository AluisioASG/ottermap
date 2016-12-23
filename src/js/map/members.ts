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
    const marker = super.onAdd.apply(this, arguments) as HTMLDivElement
    marker.setAttribute("aria-haspopup", "true")
    ;($sel(marker, ".search-input")! as HTMLInputElement).type = "search"
    const cancel = $sel(marker, ".search-cancel")!
    cancel.parentNode!.removeChild(cancel)
    return marker
  }
}

export default new SearchControl({
  layer: membersLayer,
  circleLocation: false,
  initial: false,
  zoom: SEARCH_RESULT_ZOOM_LEVEL,
}).addTo(map)
