# Load the whole application except for the data.
require <[ui forms map map/layers map/members map/user]>


# Now try to select the database backend.
data, config <-! require <[data data/config]>

# Try to read the backend from a `localStorage` preference.
# If it's unset or invalid, fallback to the first entry in the config.
backendId = localStorage['databaseBackend']
if backendId not in config.backends
  backendId = config.backends[0]

# Now that we know which module to load, do it, set it as database
# backend and then load all the users' data.
require [backendId] (backend) !->
  data.setBackend backend
  data.fetchUsers!
