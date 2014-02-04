L, map, markerSVG <- define <[leaflet map text!map/marker.svg!strip]>


# Attribution notice for the marker icons.
const MARKER_ICON_ATTRIBUTION = do ->
  link = (href, text) -> "<a href='#{href}' rel='nofollow'>#{text}</a>"
  'Marker (“[Otter Track][1]”) © Katie M Westbrook, [The Noun Project][2]'
  .replace /\[(.+?)\]\[1\]/ link 'http://thenounproject.com/term/otter-track/3498/' \$1
  .replace /\[(.+?)\]\[2\]/ link 'http://thenounproject.com/' \$1

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

# Build a marker for a given user using the given icon.
buildMarker = (user, icon) ->
  new L.Marker user.location,
    icon: icon
    title: user.username
  .bindPopup buildPopup user.username


# Set the path to Leaflet's images, relative to the web page.
L.Icon.Default.imagePath = 'img'

# Add the attribution of the marker icon to the map.
map.attributionControl.addAttribution MARKER_ICON_ATTRIBUTION


# Define the module's API.
return
  # Create a marker for a member.
  buildMemberMarker: (user) ->
    marker = buildMarker user, DefaultIcon
    user.addEventListener \locationchange ({detail}) !->
      marker.setLatLng detail.newValue
    user.addEventListener \statuschange ({detail}) -> switch detail.newValue
      | \online   => marker.setIcon OnlineMemberIcon
      | \offline  => marker.setIcon OfflineMemberIcon
      | otherwise => marker.setIcon DefaultIcon
    return marker
