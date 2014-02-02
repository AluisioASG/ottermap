L, dataAPI, map, markerSVG <- define <[
  leaflet data map text!map/marker.svg!strip
]>


# Attribution notice for the marker icons.
const MARKER_ICON_ATTRIBUTION = do ->
  link = (href, text) -> "<a href='#{href}' rel='nofollow'>#{text}</a>"
  'Marker (“[Otter Track][1]”) © Katie M Westbrook, [The Noun Project][2]'
  .replace /\[(.+?)\]\[1\]/ link 'http://thenounproject.com/term/otter-track/3498/' \$1
  .replace /\[(.+?)\]\[2\]/ link 'http://thenounproject.com/' \$1

# Interval between database queries for activity checks.
const OTTER_ACTIVITY_CHECK_INTERVAL = 90s * 1000ms

var DefaultIcon, OnlineMemberIcon, OfflineMemberIcon, SearchResultIcon
do ->
  # Create a standard marker icon tagged with the given class.
  buildIcon = (markerClass) ->
    new L.DivIcon do
      html: markerSVG
      iconSize: [42, 44]
      className: markerClass

  # Icon used for members with no activity record.
  DefaultIcon := buildIcon \marker-default
  # Icon used for members considered active.
  OnlineMemberIcon := buildIcon \marker-online
  # Icon used for members considered inactive.
  OfflineMemberIcon := buildIcon \marker-offline
  # Marker icon used for search results.
  SearchResultIcon := buildIcon \marker-searchresult


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
setupMarkerForActivityCheck = (username, marker) !->
  var interval
  stopChecking = !-> clearInterval interval
  interval = setInterval !->
    changeMarkerIconOnActivity username, marker, stopChecking
  , OTTER_ACTIVITY_CHECK_INTERVAL
  changeMarkerIconOnActivity username, marker, stopChecking

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

# Build a pop-up for the given user, containing their username
# and avatar.
buildPopup = (username) ->
  html_username = htmlify username
  avatar_url = "http://178.79.159.24/Time/api/avatar/img/#{slugify username}/"
  new L.Popup do
    closeButton: false
    closeOnClick: true
  .setContent """
    <figure class="avatar">
      <img src="#{avatar_url}" alt="#{html_username}'s avatar">
      <figcaption class="text-center">#{html_username}</figcaption>
    </figure>
  """

# Build a marker for a given user.
buildMarker = (username, location, isSearch) ->
  new L.Marker location,
    icon: if isSearch then SearchResultIcon else DefaultIcon
    title: username
  .bindPopup buildPopup username

# Populate a layer with markers for the given users.  If the given
# array is the result of a search, a special marker icon is used.
# Otherwise, the icon used depends on the user's online status.
populateMarkerLayer = (targetCluster, results, isSearch) ->
  # Create a marker for each search result.
  markers = for {username, location} in results
    marker = buildMarker username, location, isSearch
    # Target the marker for activity check if this is not
    # a search result.
    if not isSearch
      setupMarkerForActivityCheck username, marker
    marker
  # Reset the target layer cluster and add the new markers.
  targetCluster.clearLayers!addLayers markers


# Set the path to Leaflet's images, relative to the web page.
L.Icon.Default.imagePath = 'img'

# Add the attribution of the marker icon to the map.
map.attributionControl.addAttribution MARKER_ICON_ATTRIBUTION

# Export the layer populator function.
return populateMarkerLayer
