$, L, dataAPI, markerSVG, domReady <- define <[
  jquery leaflet data text!map/marker.svg!strip domReady
]>

# Initial geographical center of the map.
const MAP_ORIGIN = [23.433333, (Math.random! * 360) - 180]
# Map's initial zoom level.
const MAP_ZOOM_LEVEL = 2
# Zoom level after geosearch.
const GEOSEARCH_ZOOM_LEVEL = 15
# Zoom level after a search with a single result.
const SEARCH_RESULT_ZOOM_LEVEL = 10

# Geosearch provider.  See the L.GeoSearch plugin's documentation
# for available providers and required configuration.
const GEOSEARCH_PROVIDER = \OpenStreetMap
# Tile providers available for the user to select.  See the
# leaflet-providers plugin's documentation for available providers
# and required configuration.
const TILE_PROVIDERS = <[
  Esri.NatGeoWorldMap
  Esri.WorldImagery
  OpenStreetMap.DE
  Stamen.Toner
  Stamen.Watercolor
]>
# Tile provider to be used if the user hasn't selected one before.
const DEFAULT_TILE_PROVIDER = \Esri.WorldImagery

# Interval between database queries for activity checks.
const OTTER_ACTIVITY_CHECK_INTERVAL = 90s * 1000ms

# Attribution notice for the marker icons.
const MARKER_ICON_ATTRIBUTION = do ->
  link = (href, text) -> "<a href='#{href}' rel='nofollow'>#{text}</a>"
  'Marker (“[Otter Track][1]”) © Katie M Westbrook, [The Noun Project][2]'
  .replace /\[(.+?)\]\[1\]/ link 'http://thenounproject.com/term/otter-track/3498/' \$1
  .replace /\[(.+?)\]\[2\]/ link 'http://thenounproject.com/' \$1


# Set the path to Leaflet's images, relative to the web page.
L.Icon.Default.imagePath = 'img'

buildIcon = (markerClass) ->
  new L.DivIcon do
    html: markerSVG
    iconSize: [42, 44]
    className: markerClass

# Icon used for members with no activity record.
DefaultIcon = buildIcon \marker-default
# Icon used for members considered active.
OnlineMemberIcon = buildIcon \marker-online
# Icon used for members considered inactive.
OfflineMemberIcon = buildIcon \marker-offline
# Marker icon used for search results.
SearchResultIcon = buildIcon \marker-searchresult


# Query the database for a member's activity and change their
# marker's icon accordingly.  `clear_interval` is called if the
# member has no activity record.
changeMarkerIconOnActivity = (username, marker, clear_interval) !->
  dataAPI.onRecentCheckin username
  , !->
    marker.setIcon OnlineMemberIcon
  , !->
    marker.setIcon OfflineMemberIcon
  , !->
    marker.setIcon DefaultIcon
    clear_interval!

# Add a background task to check a member's activity record regularly.
setupMarkerForActivityCheck = (username, marker) ->
  var interval
  stopChecking = !-> clearInterval interval
  interval = setInterval !->
    changeMarkerIconOnActivity username, marker, stopChecking
  , OTTER_ACTIVITY_CHECK_INTERVAL
  changeMarkerIconOnActivity username, marker, stopChecking
  return marker

# Escape HTML special characters.
htmlify = do ->
  entities =
    '&': '&amp;'
    '<': '&lt;'
    '>': '&gt;'
    '"': '&quot;'
    "'": '&apos;'
  (.replace /[&<>"']/g (entities.))

# Slugify the username (see Django's django/utils/text.py) to fetch
# the user's avatar.
slugify = (.trim!replace /[-\s]+/g '-' .replace /[^\w-]/g '' .toLowerCase!)

# Populate a layer with markers for the given users.  If the given
# array is the result of a search, a special marker icon is used.
# Otherwise, the icon used depends on the user's online status.
populateMarkerLayer = (targetCluster, results, isSearch) ->
  # Select the initial marker icon.
  markerIcon = if isSearch then SearchResultIcon else DefaultIcon
  # Create a marker for each search result.
  markers = for {username, location} in results
    html_username = htmlify username
    slug = slugify username
    popup = new L.Popup do
      closeButton: false
      closeOnClick: true
    .setContent """
      <figure class="avatar">
        <img src="http://178.79.159.24/Time/api/avatar/img/#{slug}/" alt="#{html_username}'s avatar">
        <figcaption class="text-center">#{html_username}</figcaption>
      </figure>
    """
    marker = new L.Marker location,
      icon: markerIcon
      title: username
    .bindPopup popup
    # Target the marker for activity check if this is not
    # a search result.
    if not isSearch
      setupMarkerForActivityCheck username, marker
    marker

  # Reset the target layer cluster and add the new markers.
  targetCluster.clearLayers!
  targetCluster.addLayers markers

# Wrapper to keep the search layer hidden.
populateSearchLayer = (/* bound */ searchLayer, results) ->
  populateMarkerLayer searchLayer, results, true


# We only actually create and configure the map after the page's DOM
# is ready.  But to keep things isolated from the DOM, we do these
# things in a separated function.
getMap = (container) ->
  # Create the Leaflet map.
  map = new L.Map container,
    center: MAP_ORIGIN
    zoom: MAP_ZOOM_LEVEL
    worldCopyJump: true
    trackResize: false

  # Add an attribution to the marker icon.
  map.attributionControl.addAttribution MARKER_ICON_ATTRIBUTION

  # Disable zoom on double-click so as not to interfere with
  # marker placement.
  map.doubleClickZoom.disable!

  # Add the search control to the map.
  new L.Control.GeoSearch do
    provider: new L.GeoSearch.Provider[GEOSEARCH_PROVIDER]
    zoomLevel: GEOSEARCH_ZOOM_LEVEL
    showMarker: false
  .addTo map

  # Remember the last base layer selected by the user.
  map.on \baselayerchange (evt) !->
    provider = evt.layer._ottmap_layer_provider
    localStorage['last tile provider'] = provider
  initialTileProvider =
    localStorage['last tile provider'] ? DEFAULT_TILE_PROVIDER

  # Add the tile provider selection controls to the map.
  # Usually we'd use `L.Control.Layers.Provided` supplied by
  # `leaflet-providers`, but we need to register the provider's
  # name so we can save and restore it later.
  layerControl = new L.Control.Layers
  formatLabel = (.replace /\./g ': ' .replace /([a-z])([A-Z])/g '$1 $2')
  for provider in TILE_PROVIDERS
    layer = (L.tileLayer.provider provider) <<<
      _ottmap_layer_provider: provider
    # Add the layer to the map if it's the default one.
    if provider is initialTileProvider
      map.addLayer layer
      # Adjust the map's zoom level if necessary.
      if MAP_ZOOM_LEVEL < layer.options.minZoom
        map.setZoom layer.options.minZoom
      if MAP_ZOOM_LEVEL > layer.options.maxZoom
        map.setZoom layer.options.maxZoom
    layerControl.addBaseLayer layer, formatLabel provider
  layerControl.addTo map

  # Fetch all members and add a layer for them.
  dataAPI.getLocationData (locationData) !->
    membersLayer = new L.MarkerClusterGroup
    map.addLayer membersLayer
    populateMarkerLayer membersLayer, locationData
    layerControl.addOverlay membersLayer, 'All members'

  # Add a layer for search results.
  searchLayer = new L.MarkerClusterGroup
  map.addLayer searchLayer
  layerControl.addOverlay searchLayer, 'Search results'
  populateSearchLayer .= bind void, searchLayer

  return map

var g_map
domReady !->
  # Keep a reference to the jQuerified map container handy.
  $map = $ \#map

  # Clear the map container and create the Leaflet map.
  $map.empty!
  g_map := getMap $map[0]

  # Resize the map when the container is resized.
  $map.on \resize !-> g_map.invalidateSize!

  # Fit the world on the first container resize (except on
  # WebKit-based browsers).
  if navigator.userAgent isnt /\bAppleWebKit\b/
    $map.one \resize !-> g_map.fitWorld!


# Define the module's API.
return
  # Display the results in the search results layer.
  displaySearchResults: (results) !->
    populateSearchLayer results
    if results.length is 1
      # Zoom to the single result.
      g_map.setView results[0].location, SEARCH_RESULT_ZOOM_LEVEL,
        animate: true
  # Place a marker representing the user at the map's current location.
  placeUserMarker: (title) ->
    marker = L.marker g_map.getCenter!,
      icon: new L.Icon.Default
      draggable: true
      title: title
    .addTo g_map
    g_map.addEventListener \click (event) !->
      marker.setLatLng event.latlng
    return marker
  # Remove the given user marker (returned by `placeUserMarker`)
  # from the map.
  removeUserMarker: (marker) !->
    g_map.removeLayer marker
