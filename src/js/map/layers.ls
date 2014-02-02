L, map <-! define <[leaflet map]>


# Tile providers available for the user to select.  See the
# leaflet-providers plugin's documentation for available providers
# and required configuration.
TILE_PROVIDERS = <[
  Esri.NatGeoWorldMap
  Esri.WorldImagery
  OpenStreetMap.DE
  Stamen.Toner
  Stamen.Watercolor
]>

# Tile provider to be used if the user hasn't selected one before.
const DEFAULT_TILE_PROVIDER = \Esri.WorldImagery


# Instantiate a tile layer given a provider ID.
getLayerProvided = (provider) ->
  layer = L.tileLayer.provider provider
  layer <<<
    _ottmap_layer_provider:  provider

# Convert a provider ID into a human-readable name.
providerIdToLabel = (provider) ->
  provider.replace /\./g ': ' .replace /([a-z])([A-Z])/g '$1 $2'

# Make sure a given number is within the given bounds.
adjustWithinRange = (value, min, max) ->
  | value < min => min
  | value > max => max
  | otherwise   => value


# Remember the last base layer selected by the user.
map.addEventListener \baselayerchange (event) !->
  provider = event.layer._ottmap_layer_provider
  localStorage['last tile provider'] = provider
initialProvider = localStorage['last tile provider'] ? DEFAULT_TILE_PROVIDER
# Load the tile provider last selected by the user if it's not
# loaded by default anymore.
if initialProvider not in TILE_PROVIDERS
  TILE_PROVIDERS.push initialProvider

# Create and populate the layer selection control.  Usually we'd use
# `L.Control.Layers.Provided` supplied by `leaflet-providers`, but
# we need to record the provider's name so we can save and restore
# it later.
layerControl = new L.Control.Layers
for provider in TILE_PROVIDERS
  layer = getLayerProvided provider
  layerControl.addBaseLayer layer, providerIdToLabel provider
  if provider is initialProvider
    # Add the layer to the map if it's the default one.
    map.addLayer layer
    # Adjust the map's zoom level if necessary.
    adjustWithinRange map.getZoom!,
                      layer.options.minZoom,
                      layer.options.maxZoom
    |> map.setZoom
# Add the control to the map.
layerControl.addTo map

# Export the layer selection control.
return layerControl
