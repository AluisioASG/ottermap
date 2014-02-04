L, dom, events <- define <[leaflet util/dom util/events domReady!]>
{$id} = dom


# Initial geographical center of the map.
const MAP_ORIGIN = [23.433333, (Math.random! * 360) - 180]
# Map's initial zoom level.
const MAP_ZOOM_LEVEL = 2


# Get the map container, clear it and then create the Leaflet map.
container = $id \map
container.textContent = ''
map = new L.Map container,
  center: MAP_ORIGIN
  zoom: MAP_ZOOM_LEVEL
  worldCopyJump: true
  trackResize: false

# Disable zoom on double-click so as not to interfere with
# marker placement.
map.doubleClickZoom.disable!

# Resize the map when the container is resized.
container.addEventListener \resize !-> map.invalidateSize!

# Fit the world on the first container resize (except on
# WebKit-based browsers).
if navigator.userAgent isnt /\bAppleWebKit\b/
  events.listenOnce container, \resize, !->
    map.fitWorld!

return map
