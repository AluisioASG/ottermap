import {syncUserLocation} from "./data"
import * as MapUser from "./map/user"
import {$id, $sel, $addClass, $removeClass} from "./util/dom"
import {listenOnce} from "./util/events"


/** Time to wait until the current operation is completed. */
const NEXT_TICK_INTERVAL = 40 /* 1000ms / 25fps */


function getUsername(form: HTMLElement): string {
  return ($sel(form, "input[name=username]")! as HTMLInputElement).value
}

let g_marker: L.Marker
const updateForm = $id("update-form")
// Setup marker placement.
listenOnce(updateForm as EventTarget, "submit", function(this: HTMLFormElement) {
  const geoSearchControl = $sel(".leaflet-control-geosearch")!
  geoSearchControl.style.display = "block"
  setTimeout(() => geoSearchControl.style.opacity = "1" , NEXT_TICK_INTERVAL)
  g_marker = MapUser.placeUserMarker(getUsername(this))
})
// Setup user location upload.
listenOnce(updateForm as EventTarget, "submit", function(this: HTMLFormElement) {
  this.addEventListener("submit", function(this: HTMLFormElement) {
    // Reset the upload button's color now, and set it to indicate success once
    // the upload is completed.
    const uploadButton = $sel(this, "button[type=submit]")!
    $removeClass(uploadButton, "btn-success")
    $addClass(uploadButton, "btn-primary")
    syncUserLocation(getUsername(this), g_marker.getLatLng(), () => {
      $removeClass(uploadButton, "btn-primary")
      $addClass(uploadButton, "btn-success")
    })
  })
})

/**
 * Synchronize a setting input field and the corresponding value in backing
 * storage.
 */
function setupSettingField(inputName: string, configKey: string): void {
  const inputField = $sel(`[name=${inputName}]`)! as HTMLInputElement
  inputField.value = localStorage[configKey] || ""
  inputField.addEventListener("change", function() { localStorage[configKey] = inputField.value })
}

setupSettingField("setting-base-tiles",           "last tile provider")
setupSettingField("setting-overlays",             "overlay providers")
setupSettingField("setting-marker-style-default", "default marker style")
setupSettingField("setting-marker-style-online",  "online marker style")
setupSettingField("setting-marker-style-offline", "offline marker style")
