L, events <- define <[
  leaflet util/events
]>


# Time since the last check-in during which an user is considered
# to be online.
const RECENT_CHECKIN_THRESHOLD = 270s * 1000ms


class User implements events.PausableEventTarget.prototype
  (@username) ->
    events.PausableEventTarget.call this
    # Update the status whenever the last access timestamp changes.
    @addEventListener \lastaccesschange @updateStatusFromLastAccess

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

  # Set the last access timestamp property if unset or the new value
  # differs from the current one and dispatch an event informing the
  # change.
  setLastAccessTimestamp: (newTimestamp) !->
    if newTimestamp.getTime! isnt @lastAccess?getTime!
      @updateProperty \lastAccess, newTimestamp, \lastaccesschange

  # Unset the last access timestamp property and dispatch an event
  # informing the change.
  unsetLastAccessTimestamp: !->
    if @lastAccess?
      @updateProperty \lastAccess, null, \lastaccesschange

  # Update the status property based on the last access timestamp.
  updateStatusFromLastAccess: !->
    if not @lastAccess?
      @setStatus void
    else if (Date.now! - @lastAccess.getTime!) <= RECENT_CHECKIN_THRESHOLD
      @setStatus \online
    else
      @setStatus \offline


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
