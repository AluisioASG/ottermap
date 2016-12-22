import {users} from "./data"
import map from "./map"
import {listenOnce} from "./util/events"


// Zoom level to use when focusing in a user.
const FOCUS_ZOOM_LEVEL = 11


// Find and focus on a given user whenever the URL fragment changes.
window.addEventListener("hashchange", () => {
  const targetUser = window.location.hash.slice(1)
  if (!targetUser) return
  const user = users.select(user => user.username === targetUser)[0]
  if (user != null) {
    map.setView(user.location, FOCUS_ZOOM_LEVEL)
  }
})

// If a user is passed when the page is loaded, focus on them as soon as
// they are added to the user list.
const targetUser = window.location.hash.slice(1)
if (targetUser) {
  listenOnce(users, "useradd", ({detail: user}) => {
    if (user.username === targetUser) {
      map.setView(user.location, FOCUS_ZOOM_LEVEL)
    }
  })
}
