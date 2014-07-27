dom, events, mapUserAPI, data <-! define <[
  util/dom util/events map/user data domReady!
]>
{$id, $sel, $addClass, $removeClass} = dom


# Time to wait until the current operation is completed.
const NEXT_TICK_INTERVAL = 1000ms / 25fps


getUsername = -> (it `$sel` 'input[name=username]') .value

var g_marker
$id \update-form
  # Setup marker placement.
  ..|> events.listenOnce _, \submit, !->
    geoSearchControl = $sel '.leaflet-control-geosearch'
    geoSearchControl.style.display = 'block'
    setTimeout !->
      geoSearchControl.style.opacity = '1'
    , NEXT_TICK_INTERVAL
    g_marker := mapUserAPI.placeUserMarker getUsername this
  # Setup user location upload.
  ..|> events.listenOnce _, \submit, !->
      <-! @addEventListener \submit
      # Reset the upload button's color now, and set it to indicate success
      # once the upload is completed.
      uploadButton = this `$sel` 'button[type=submit]'
      uploadButton `$removeClass` \btn-success `$addClass` \btn-primary
      data.syncUserLocation (getUsername this), g_marker.getLatLng!, !->
        uploadButton `$removeClass` \btn-primary `$addClass` \btn-success


# Synchronize a setting input field and the corresponding value in
# backing storage.
setupSettingField = (input_name, config_key) !->
  $sel "[name=#{input_name}]"
    ..value = localStorage[config_key] ? ''
    ..addEventListener \change !-> localStorage[config_key] = @value

setupSettingField 'setting-base-tiles'           'last tile provider'
setupSettingField 'setting-overlays'             'overlay providers'
setupSettingField 'setting-marker-style-default' 'default marker style'
setupSettingField 'setting-marker-style-online'  'online marker style'
setupSettingField 'setting-marker-style-offline' 'offline marker style'
