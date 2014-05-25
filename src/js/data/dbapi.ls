messagebar, model, DBAPI <- define <[
  messagebar data/model util/dbapi
]>


# Member location database endpoint.
const MAP_MEMBERS_ENDPOINT = "ottmap/members"

# Member check-in database endpoint.
const BT_CHECKIN_ENDPOINT = "blitzertracker/checkins"

# Interval between database queries for check-in updates.
const CHECKIN_QUERY_INTERVAL = 90s * 1000ms


# Arrange so that the user's last access timestamp is periodically
# fetched from the database and updated in the model.
setupLastAccessCheck = (user) !->
  # Check the last access timestamp now and then.
  activityCheckInterval = setInterval checkStatus, CHECKIN_QUERY_INTERVAL
  checkStatus!

  function checkStatus
    DBAPI \GET, "#{BT_CHECKIN_ENDPOINT}/#{user.username}",
      void
    , (event) !->
      {lastCheckin} = JSON.parse event.target.responseText
      user.setLastAccessTimestamp new Date lastCheckin
    , (event) !->
      user.unsetLastAccessTimestamp!
      if event.target.status is 404
        # Just stop checking.
        clearInterval activityCheckInterval
      else
        messagebar.show "
          Hmm.  Something prevented us from fetching the last check-in 
          timestamp of a member from the database.  The map is still 
          fully functional, though.
        " \danger


# Fetch all users from the database and update the local collection.
fetchUsers: !->
  allUsers = this
  DBAPI \GET, MAP_MEMBERS_ENDPOINT,
    void
  , !->
    data = JSON.parse @responseText
    for e in data
      new model.User e._id
        ..setLocation e.location
        ..|> setupLastAccessCheck
        ..|> allUsers.addUser
  , !->
    messagebar.show "
      Oops!  Something prevented us from retrieving the list of members 
      from the database.  Do you mind reloading the page and trying again?
    " \danger

# Update an user's location both locally and on the database.
syncUserLocation: (username, latlng, callback) !->
  # Get the user object, if any, and update the local collection.
  user = @select((.username is username))[0]
  if not user?
    user = new model.User username
      ..setLocation [latlng.lat, latlng.lng]
      ..|> @addUser
  else
    user.setLocation [latlng.lat, latlng.lng]

  # Synchronize the change with the server.
  DBAPI \PUT, "#{MAP_MEMBERS_ENDPOINT}/#{user.username}",
    {location: [user.location.lat, user.location.lng]}
  , callback
  , !->
    messagebar.show "
      Oops!  Something prevented us from sending your location 
      to the database.  Do you mind trying again?
    " \danger
