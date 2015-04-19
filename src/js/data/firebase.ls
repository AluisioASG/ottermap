Firebase, messagebar, dbconf, model <- define <[
  firebase messagebar data/config data/model
]>


# Keep a global reference to the Firebase root.
root = new Firebase dbconf.urls.firebase

# Usernames may need to be escaped for Firebase.
encodeUsername = (username) ->
  username.replace /[%.#\/\$\[\]]/g (ch) ->
    "%#{ch.charCodeAt 0 .toString 16}"
decodeUsername = decodeURIComponent

# Centralize the process of extracting the contents out of
# a data snapshot.
extractInfo = (snapshot) ->
  username = decodeUsername snapshot.key!
  data = snapshot.val!
  return [username, data]


# Fetch all users from the database and update the local collection.
fetchUsers: !->
  # Make our life simpler when looking for an user.
  getUser = (username) ~>
    users = @select (.username is username)
    if users.length isnt 1
      throw new Error "data/firebase: 
                       #{users.length} users with username #{username} found"
    return users[0]

  # Install listeners for the events we want to monitor.
  root.on \child_added (snapshot) !~>
      [username, data] = extractInfo snapshot
      new model.User username
        ..setLocation data.location
        ..setLastAccessTimestamp new Date that if data.lastAccess?
        ..|> @addUser
  root.on \child_removed (snapshot) !~>
      [username] = extractInfo snapshot
      getUser username |> @removeUser
  root.on \child_changed (snapshot) !~>
      [username, data] = extractInfo snapshot
      getUser username
        ..setLocation data.location
        if data.lastAccess?
          ..setLastAccessTimestamp new Date data.lastAccess
        else
          ..unsetLastAccessTimestamp!

# Update an user's location both locally and on the database.
syncUserLocation: (username, latlng, callback) !->
  # All we need to do is to update the Firebase, and our listeners in
  # `allUsers` will resync the local collection.
  db_username = encodeUsername username
  root.child "#{db_username}/location"
  .set do
    lat: latlng.lat
    lng: latlng.lng
    (err) !->
      if err?
        messagebar.show "
          Oops!  Something prevented us from sending your location 
          to the database.  Do you mind trying again?
        " \danger
      else
        callback!
