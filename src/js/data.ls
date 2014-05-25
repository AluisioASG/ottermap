model <- define <[data/model]>


# Create a collection for all members in the database.
g_users = new model.UserCollection

# Keep a reference to the database backend.
g_backend = NullBackend = do
  syncUserLocation: !->
    throw new Error "data: database backend not defined"
  fetchUsers: !->
    throw new Error "data: database backend not defined"


# Expose the user collection.
users: g_users
# Allow the backend to be set once.
setBackend: (backend) !->
  if g_backend is NullBackend
    g_backend := backend
  else
    throw new Error "data: database backend can only be set once"
# Wrap the backend functions to operate on the user collection.
syncUserLocation: ->
  g_backend.syncUserLocation.apply g_users, arguments
fetchUsers: ->
  g_backend.fetchUsers.apply g_users, arguments
