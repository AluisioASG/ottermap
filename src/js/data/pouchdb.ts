import * as PouchDB from "pouchdb"
import {dbUrl} from "./backend"
import * as messagebar from "../messagebar"
import {trimIndent} from "../util/strings"
import * as model from "./model"


interface UserDocument {
  location: {lat: number, lng: number}
  lastAccess: string | null
}

// Our database model is: local first, synced to remote.
const db = new PouchDB("ottermap") as PouchDB.Database<UserDocument>
if (dbUrl != null) {
  db.sync(dbUrl!, {live: true, retry: true}).on("error", err => {
    messagebar.show(trimIndent(`
      We have lost connection with the mothership.
      Please reload to see new changes and upload your location.
    `, undefined, " "), "danger")
  })
}


// Make our life simpler when looking for an user.
function getUser(col: model.UserCollection, username: string): model.User | undefined {
  const users = col.select(user => user.username === username)
  return users[0]
}

function createUser(doc: PouchDB.Core.Document<UserDocument>): model.User {
  const user = new model.User(doc._id)
  user.setLocation(doc.location)
  if (doc.lastAccess != null) {
    user.setLastAccessTimestamp(new Date(doc.lastAccess))
  }
  return user
}

function updateUser(user: model.User, doc: PouchDB.Core.Document<UserDocument>): model.User {
  user.setLocation(doc.location)
  if (doc.lastAccess != null) {
    user.setLastAccessTimestamp(new Date(doc.lastAccess))
  } else {
    user.unsetLastAccessTimestamp()
  }
  return user
}

function addOrUpdateUser(
  col: model.UserCollection,
  doc: PouchDB.Core.Document<UserDocument>,
): model.User {
  let user = getUser(col, doc._id)
  if (user != null) {
    updateUser(user, doc)
  } else {
    user = createUser(doc)
    col.addUser(createUser(doc))
  }
  return user
}


/**
 * Fetch all users from the database and update the local collection.
 */
function fetchUsers(this: model.UserCollection): void {
  db.allDocs({include_docs: true}).then(result => {
    for (const {doc} of result.rows) {
      if (doc == null) continue
      this.addUser(createUser(doc))
    }
  })

  db.changes({
    since: "now",
    live: true,
    timeout: false,
    include_docs: true,
  }).on("change", change => {
    const doc = change.doc!
    const user = getUser(this, doc._id)
    if (change.deleted && user != null) {
      this.removeUser(user)
    } else {
      addOrUpdateUser(this, doc)
    }
  }).on("error", err => {
    messagebar.show(trimIndent(`
      Um, it seems our connection to the database was severed!
      Please reload to see new changes.
    `, undefined, " "), "danger")
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
  db.get(username).then(current => {
    const newDoc = {
      _id: username,
      _rev: current._rev,
      location: latlng,
      lastAccess: current.lastAccess,
    }
    addOrUpdateUser(this, newDoc)
    return db.put(newDoc)
  }, err => {
    if (err.status !== 404) throw err
    const doc = {
      _id: username,
      location: latlng,
      lastAccess: null,
    }
    addOrUpdateUser(this, doc)
    return db.put(doc)
  }).then(callback, () => {
    messagebar.show(trimIndent(`
      Oops!  Something prevented us from sending your location to the database.
      Do you mind trying again?
    `, undefined, " "), "danger")
  })
}

export default {fetchUsers, syncUserLocation}
