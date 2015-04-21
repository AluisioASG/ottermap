map, {users} <-! require <[map data]>


# Zoom level to use when focusing in a user.
const FOCUS_ZOOM_LEVEL = 11


# Find and focus on a given user whenever the URL fragment changes.
window.addEventListener \hashchange !->
  return unless targetUser = window.location.hash.slice 1
  if users.select (.username is targetUser) .0
    map.setView that.location, FOCUS_ZOOM_LEVEL

# If a user is passed when the page is loaded, focus on them as soon
# as they are added to the user list.
if targetUser = window.location.hash.slice 1
  maybeFocusUser = ({detail: user}) !->
    if user.username is targetUser
      map.setView user.location, FOCUS_ZOOM_LEVEL
      users.removeEventListener maybeFocusUser
  users.addEventListener \useradd maybeFocusUser
