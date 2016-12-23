import "firebase"
import dbConfig from "../site-local/config"
import * as messagebar from "../messagebar"
import {trimIndent} from "../util/strings"
import * as model from "./model"


// Keep a global reference to the Firebase root.
const root = new Firebase(dbConfig.urls.firebase)

// Usernames may need to be escaped for Firebase.
function encodeUsername(username: string): string {
  return username.replace(/[%.#\/\$\[\]]/g, c => `%${c.charCodeAt(0).toString(16)}`)
}
function decodeUsername(username: string): string {
  return decodeURIComponent(username)
}

// Centralize the process of extracting the contents out of a data snapshot.
function extractInfo(snapshot: FirebaseDataSnapshot): [string, any] {
  return [decodeUsername(snapshot.key()), snapshot.val()]
}


/**
 * Fetch all users from the database and update the local collection.
 */
function fetchUsers(this: model.UserCollection): void {
  // Make our life simpler when looking for an user.
  const getUser = (username: string): model.User => {
    const users = this.select(user => user.username === username)
    if (users.length !== 1) {
      throw new Error(`data/firebase: ${users.length} users with username '${username}' found`)
    }
    return users[0]
  }

  // Install listeners for the events we want to monitor.
  root.on("child_added", (snapshot: FirebaseDataSnapshot) => {
    const [username, data] = extractInfo(snapshot)
    if (username === "location") return // FIXME
    const user = new model.User(username)
    user.setLocation(data.location)
    if (data.lastAccess != null) {
      user.setLastAccessTimestamp(new Date(data.lastAccess))
    }
    this.addUser(user)
  })
  root.on("child_removed", (snapshot: FirebaseDataSnapshot) => {
    const [username] = extractInfo(snapshot)
    this.removeUser(getUser(username))
  })
  root.on("child_changed", (snapshot: FirebaseDataSnapshot) => {
      const [username, data] = extractInfo(snapshot)
      const user = getUser(username)
      user.setLocation(data.location)
      if (data.lastAccess != null) {
        user.setLastAccessTimestamp(new Date(data.lastAccess))
      } else {
        user.unsetLastAccessTimestamp()
      }
  })
}

/**
 * Update an user's location both locally and on the database.
 */
function syncUserLocation(
  this: model.UserCollection,
  username: string,
  latlng: {lat: number, lng: number},
  callback: () => void,
): void {
  // All we need to do is to update the Firebase, and our listeners in
  // `allUsers` will resync the local collection.
  const db_username = encodeUsername(username)
  root.child(`${db_username}/location`).set(
    {lat: latlng.lat, lng: latlng.lng},
    (err: Error) => {
      if (err != null) {
        messagebar.show(trimIndent(`
          Oops!  Something prevented us from sending your location
          to the database.  Do you mind trying again?
        `, undefined, " "), "danger")
      } else {
        callback()
      }
    },
  )
}

export default {fetchUsers, syncUserLocation}
