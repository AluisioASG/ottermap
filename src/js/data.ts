import * as model from "./data/model"


interface DataBackend {
  fetchUsers(this: model.UserCollection): void
  syncUserLocation(
    this: model.UserCollection,
    username: string,
    latlng: {lat: number, lng: number},
    callback: () => void,
  ): void
}

const NullBackend = {
  syncUserLocation() {
    throw new Error("data: database backend not defined")
  },
  fetchUsers() {
    throw new Error("data: database backend not defined")
  },
}


// Create a collection for all members in the database.
export const users = new model.UserCollection()

// Keep a reference to the database backend.
let g_backend: DataBackend = NullBackend

// Allow the backend to be set once.
export function setBackend(backend: DataBackend): void {
  if (g_backend === NullBackend) {
    g_backend = backend
  } else {
    throw new Error("data: database backend can only be set once")
  }
}
// Wrap the backend functions to operate on the user collection.
export function syncUserLocation(
  username: string,
  latlng: {lat: number, lng: number},
  callback: () => void,
): void {
  g_backend.syncUserLocation.apply(users, arguments)
}
export function fetchUsers(): void {
  g_backend.fetchUsers.apply(users, arguments)
}
