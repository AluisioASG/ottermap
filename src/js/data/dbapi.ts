import dbConfig from "../site-local/config"
import * as messagebar from "../messagebar"
import DBAPI, {setRoot as setDbApiRoot} from "../util/dbapi"
import {trimIndent} from "../util/strings"
import * as model from "./model"


/** Member location database endpoint. */
const MAP_MEMBERS_ENDPOINT = "ottmap/members"

/** Member check-in database endpoint. */
const BT_CHECKIN_ENDPOINT = "blitzertracker/checkins"

/** Interval between database queries for check-in updates, in milliseconds. */
const CHECKIN_QUERY_INTERVAL = 90000


/** Set the DBAPI root. */
setDbApiRoot(dbConfig.urls.dbapi)


/**
 * Arrange so that a user's last access timestamp is periodically fetched
 * from the database and updated in the model.
 */
function setupLastAccessCheck(user: model.User): void {
  // Check the last access timestamp now and then.
  const activityCheckInterval = setInterval(checkStatus, CHECKIN_QUERY_INTERVAL)
  checkStatus()

  function checkStatus(): void {
    DBAPI(
      "GET",
      `${BT_CHECKIN_ENDPOINT}/${user.username}`,
      null,
      event => {
        const xhr = event.target as XMLHttpRequest
        const {lastCheckin} = JSON.parse(xhr.responseText)
        user.setLastAccessTimestamp(new Date(lastCheckin))
      },
      event => {
        const xhr = event.target as XMLHttpRequest
        user.unsetLastAccessTimestamp()
        if (xhr.status === 404) {
          // Just stop checking.
          clearInterval(activityCheckInterval)
        } else {
          messagebar.show(trimIndent(`
            Hmm.  Something prevented us from fetching the last check-in
            timestamp of a member from the database.  The map is still
            fully functional, though.
          `, undefined, " "), "danger")
        }
      }
    )
  }
}


/**
 * Fetch all users from the database and update the local collection.
 */
function fetchUsers(this: model.UserCollection): void {
  const allUsers = this
  DBAPI(
    "GET",
    MAP_MEMBERS_ENDPOINT,
    null,
    event => {
      const xhr = event.target as XMLHttpRequest
      const data = JSON.parse(xhr.responseText)
      for (let e of data) {
        const user = new model.User(e._id)
        user.setLocation(e.location)
        setupLastAccessCheck(user)
        allUsers.addUser(user)
      }
    },
    () => {
      messagebar.show(trimIndent(`
        Oops!  Something prevented us from retrieving the list of members
        from the database.  Do you mind reloading the page and trying again?
      `, undefined, " "), "danger")
    }
  )
}

/**
 *  Update an user's location both locally and on the database.
 */
function syncUserLocation(
   this: model.UserCollection,
   username: string,
   latlng: {lat: number, lng: number},
   callback: () => void
 ): void {
  // Get the user object, if any, and update the local collection.
  let user = this.select(user => user.username === username)[0]
  if (user != null) {
    user.setLocation([latlng.lat, latlng.lng])
  } else {
    user = new model.User(username)
    user.setLocation([latlng.lat, latlng.lng])
    this.addUser(user)
  }

  // Synchronize the change with the server.
  DBAPI(
    "PUT",
    `${MAP_MEMBERS_ENDPOINT}/${user.username}`,
    {location: [user.location.lat, user.location.lng]},
    callback,
    () => {
      messagebar.show(trimIndent(`
        Oops!  Something prevented us from sending your location
        to the database.  Do you mind trying again?
      `, undefined, " "), "danger")
    }
  )
}

export default {fetchUsers, syncUserLocation}
