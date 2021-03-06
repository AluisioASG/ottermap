import L = require("leaflet")
import "leaflet-providers"
import clamp = require("lodash.clamp")
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

/** Map of tile layers to their names (for persistence). */
const tileLayerNames: WeakMap<L.Layer, string> = new WeakMap()


/**
 * Instantiate a tile layer given a provider ID.
 */
function getLayerProvided(provider: string) {
  try {
    const layer = L.tileLayer.provider(provider)
    tileLayerNames.set(layer, provider)
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
  return provider.replace(/\./g, ": ").replace(/([a-z])([A-Z0-9])/g, "$1 $2")
}


// Remember the last base layer selected by the user.
map.addEventListener("baselayerchange", (event: L.LayerEvent) => {
  localStorage["last tile provider"] = tileLayerNames.get(event.layer)
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
const layerControl = L.control.layers().addTo(map)
for (const provider of TILE_PROVIDERS) {
  const layer = getLayerProvided(provider)
  if (!layer) continue
  layerControl.addBaseLayer(layer, providerIdToLabel(provider))
  if (provider === initialProvider) {
    // Add the layer to the map if it's the default one.
    map.addLayer(layer)
    const layerOptions = (layer as any).options
    // Adjust the map's zoom level if necessary.
    map.setZoom(clamp(map.getZoom(), layerOptions.minZoom, layerOptions.maxZoom))
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
