require, $ <- define <[
  require jquery
  ./dbapi-root
]>
const DBAPI_ROOT = require './dbapi-root'
const BT_CHECKIN_ENDPOINT = "#{DBAPI_ROOT}/blitzertracker/checkins"
const MAP_MEMBERS_ENDPOINT = "#{DBAPI_ROOT}/ottmap/members"

const RECENT_CHECKIN_THRESHOLD = 270s * 1000ms

var g_locationdata

updateLocationData = (username, latlng, callback) ->
  $.ajax do
    url: "#{MAP_MEMBERS_ENDPOINT}/#{username}"
    type: \PUT
    data:
      location: [latlng.lat, latlng.lng]
  .fail !->
    $ \#messagebar .trigger \show, [\danger, "
      Oops!  Something prevented us from sending your location 
      to the database.  Do you mind trying again?
    "]
  .done callback, !->
    return if not g_locationdata?
    for member in g_locationdata when member.username is username
      member.location = [latlng.lat, latlng.lng]

fetchLocationData = (callback) ->
  $.getJSON MAP_MEMBERS_ENDPOINT
  .fail !->
    $ \#messagebar .trigger \show, [\danger, "
      Oops!  Something prevented us from retrieving the list of members 
      from the database.  Do you mind reloading the page and trying again?
    "]
  .then (data) ->
    g_locationdata := data.map (e) ->
      username: e._id
      location: e.location
  #.then (collection) ->
  #  collection
  .then callback

getLocationData = (callback) !->
  | g_locationdata? => callback g_locationdata
  | otherwise       => fetchLocationData callback

onRecentCheckin = (username, yes_callback, no_callback, unknown_callback) ->
  $.getJSON "#{BT_CHECKIN_ENDPOINT}/#{username}"
  .fail (xhr) !->
    if xhr.status is 404
      unknown_callback? username
      return
    $ \#messagebar .trigger \show [\danger, "
      Hmm.  Something prevented us from fetching the last checkin timestamp of 
      a member from the database.  The map is still fully functional, though.
    "]
  .done ({lastCheckin}) !->
    checkinDate = new Date lastCheckin
    if (Date.now! - checkinDate.getTime!) <= RECENT_CHECKIN_THRESHOLD
      yes_callback username, checkinDate
    else
      no_callback? username, checkinDate


return {
  updateLocationData
  getLocationData
  onRecentCheckin
}
