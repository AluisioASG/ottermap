messagebar, model, DBAPI <- define <[messagebar data/model util/dbapi]>


# Member location database endpoint.
const MAP_MEMBERS_ENDPOINT = "ottmap/members"


# Create a collection for all members in the database.
allUsers = new model.UserCollection

# Fetch the members' location data from the database.
DBAPI \GET, MAP_MEMBERS_ENDPOINT,
  void
, !->
  data = JSON.parse @responseText
  for e in data
    new model.User e._id
      ..setLocation e.location
      ..|> allUsers.addUser
, !->
  messagebar.show "
    Oops!  Something prevented us from retrieving the list of members 
    from the database.  Do you mind reloading the page and trying again?
  " \danger


return allUsers
