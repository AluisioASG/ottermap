messagebar, allUsers, DBAPI <- define <[messagebar data/allUsers util/dbapi]>


# Member location database endpoint.
const MAP_MEMBERS_ENDPOINT = "ottmap/members"


# Update an user's location both locally and on the database.
syncUserLocation = (username, latlng, callback) !->
  # Get the user object, if any, and update the local collection.
  user = allUsers.select((.username is username))[0]
  debugger
  if not user?
    user = new User username
      ..|> allUsers.addUser
  user.setLocation [latlng.lat, latlng.lng]

  # Synchronize the change with the server.
  DBAPI \PUT, "#{MAP_MEMBERS_ENDPOINT}/#{user.username}",
    {location: user.location}
  , callback
  , !->
    messagebar.show "
      Oops!  Something prevented us from sending your location 
      to the database.  Do you mind trying again?
    " \danger


return syncUserLocation
