L, messagebar, events, DBAPI <- define <[
  leaflet messagebar util/events util/dbapi
]>


# Member check-in database endpoint.
const BT_CHECKIN_ENDPOINT = "blitzertracker/checkins"

# Time since the last check-in during which an user is considered
# to be online.
const RECENT_CHECKIN_THRESHOLD = 270s * 1000ms

# Interval between database queries for check-in updates.
const CHECKIN_QUERY_INTERVAL = 90s * 1000ms


class User implements events.PausableEventTarget.prototype
  (@username) ->
    events.PausableEventTarget.call this
    @activityCheckInterval = setInterval @~checkStatus, CHECKIN_QUERY_INTERVAL
    @checkStatus!

  # Set a property and dispatch an event informing the change.
  updateProperty: (name, newValue, eventName) !->
    oldValue = @[name]
    @[name] = newValue
    @dispatchEvent new events.SimpleEvent eventName,
      detail: {oldValue, newValue}

  # Set the location property if unset or the new value differs
  # from the current one and dispatch an event informing the change.
  setLocation: (newLocation) !->
    # Normalize the location into Leaflet's `LatLng` object (note
    # that the constructor form doesn't support all the different
    # representations).
    newLocation = L.latLng newLocation
    if not newLocation.equals @location
      @updateProperty \location, newLocation, \locationchange

  # Set the status property if unset or the new value differs
  # from the current one and dispatch an event informing the change.
  setStatus: (newStatus) !->
    if not @status? or
       newStatus isnt @status
      @updateProperty \status, newStatus, \statuschange

  # Fetch the user's status from the database, updating the status
  # property accordingly.
  checkStatus: !->
    DBAPI \GET, "#{BT_CHECKIN_ENDPOINT}/#{@username}",
      void
    , (event) !~>
      {lastCheckin} = JSON.parse event.target.responseText
      @checkinDate = new Date lastCheckin
      if (Date.now! - @checkinDate.getTime!) <= RECENT_CHECKIN_THRESHOLD
        @setStatus \online
      else
        @setStatus \offline
    , (event) !~>
      @setStatus \unknown
      if event.target.status is 404
        # Just stop checking.
        clearInterval @activityCheckInterval
      else
        messagebar.show "
          Hmm.  Something prevented us from fetching the last check-in 
          timestamp of a member from the database.  The map is still 
          fully functional, though.
        " \danger

class UserCollection implements events.PausableEventTarget.prototype
  ->
    events.PausableEventTarget.call this
    @data = []
  # Add an item to the collection and dispatch an event about it.
  addUser: (user) !->
    @data.push user
    @dispatchEvent new events.SimpleEvent \useradd {detail: user}
  # Remove an item from the collection, dispatching an event on
  # both the collection and the item itself.
  removeUser: (user) ->
    if ~(@data.indexOf user)
      delete @data[~that]
      @dispatchEvent new events.SimpleEvent \userdel {detail: user}
      user.dispatchEvent new events.SimpleEvent \unperson
      return true
    return false
  # Return the items in the collection that match the given predicate.
  # Defaults to returning all items.
  select: (predicate=(-> true)) ->
    @data.filter -> predicate it


# Define the module's API.
return {
  User
  UserCollection
}
