import * as L from "leaflet"
import "leaflet-providers"
import map from "../map"
import {show as showMessageBar} from "../messagebar"
import {trimIndent} from "../util/strings"


/** Tile providers available for the user to select.  See the
 *  leaflet-providers plugin's documentation for available providers and
 *  required configuration. */
const TILE_PROVIDERS = [
  "OpenStreetMap.Mapnik",
  "Esri.WorldImagery",
  "NASAGIBS.ViirsEarthAtNight2012",
  "Stamen.Watercolor",
]

/** Tile provider to be used if the user hasn't selected one before. */
const DEFAULT_TILE_PROVIDER = "Esri.WorldImagery"


/**
 * Instantiate a tile layer given a provider ID.
 */
function getLayerProvided(provider: string) {
  try {
    const layer = L.tileLayer.provider(provider)
    layer._ottmap_layer_provider = provider
    return layer
  } catch (err) { // PROVIDER_NOT_FOUND
    let errmsg = err.toString()
    errmsg = `${errmsg[0].toLowerCase()}${errmsg.substr(1)}`
    showMessageBar(trimIndent(`
      Failed to get tile provider data: ${errmsg}.
      Please check your settings and reload the page.
    `, undefined, " "), "danger")
    return null
  }
}


/**
 * Convert a provider ID into a human-readable name.
 */
function providerIdToLabel(provider: string): string {
  return provider.replace(/\./g, ": ").replace(/([a-z])([A-Z])/g, "$1 $2")
}

/**
 * Make sure a given number is within the given bounds.
 */
function adjustWithinRange(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max)
}


// Remember the last base layer selected by the user.
map.addEventListener("baselayerchange", (event: L.LeafletLayerEvent) => {
  localStorage["last tile provider"] = event.layer._ottmap_layer_provider
})
const initialProvider = localStorage["last tile provider"] || DEFAULT_TILE_PROVIDER
// Load the tile provider last selected by the user if it's not loaded by
// default anymore.
if (!~TILE_PROVIDERS.indexOf(initialProvider)) {
  TILE_PROVIDERS.push(initialProvider)
}

// Create and populate the layer selection control.  Usually we'd use
// `L.Control.Layers.Provided` supplied by `leaflet-providers`, but we need
// to record the provider's name so we can save and restore it later.
const layerControl = new L.Control.Layers()
for (const provider of TILE_PROVIDERS) {
  const layer = getLayerProvided(provider)
  if (!layer) continue
  layerControl.addBaseLayer(layer, providerIdToLabel(provider))
  if (provider === initialProvider) {
    // Add the layer to the map if it's the default one.
    map.addLayer(layer)
    // Adjust the map's zoom level if necessary.
    map.setZoom(adjustWithinRange(map.getZoom(), layer.options.minZoom, layer.options.maxZoom))
  }
}
// Add to the map and layer control any overlays the user has specified.
if (localStorage["overlay providers"]) {
  for (const provider of localStorage["overlay providers"].split(/\s+/)) {
    const layer = getLayerProvided(provider)
    if (!layer) continue
    map.addLayer(layer)
    layerControl.addOverlay(layer, providerIdToLabel(provider))
  }
}
// Add the control to the map.
layerControl.addTo(map)
