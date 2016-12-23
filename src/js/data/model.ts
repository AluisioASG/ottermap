import * as L from "leaflet"
import * as events from "../util/events"


/** Time since the last check-in during which an user is considered to be
 *  online, in milliseconds. */
const RECENT_CHECKIN_THRESHOLD = 270000


export class User extends events.PausableEventTarget {
  username: string
  location: L.LatLng | void
  status: "online" | "offline" | void
  lastAccess: Date | void

  constructor(username: string) {
    super()
    this.username = username
    // Update the status whenever the last access timestamp changes.
    this.addEventListener("lastaccesschange", this.updateStatusFromLastAccess)
  }

  /**
   * Set a property and dispatch an event informing the change.
   */
  protected updateProperty(name: string, newValue: any, eventName: string): void {
    const oldValue = this[name]
    this[name] = newValue
    this.dispatchEvent(new events.SimpleEvent(eventName, {detail: {oldValue, newValue}}))
  }

  /**
   * Set the location property if unset or the new value differs from the
   * current one and dispatch an event informing the change.
   */
  setLocation(newLocation: L.LatLngExpression): void {
    // Normalize the location into Leaflet's `LatLng` object (note
    // that the constructor form doesn't support all the different
    // representations).
    const normalizedNewLocation = L.latLng(newLocation)
    if (this.location == null || !normalizedNewLocation.equals(this.location)) {
      this.updateProperty("location", normalizedNewLocation, "locationchange")
    }
  }

  /**
   * Set the status property if unset or the new value differs from the
   * current one and dispatch an event informing the change.
   */
  setStatus(newStatus: "online" | "offline" | null): void {
    if (this.status == null || newStatus !== this.status) {
      this.updateProperty("status", newStatus, "statuschange")
    }
  }

  /**
   * Set the last access timestamp property if unset or the new value differs
   * from the current one and dispatch an event informing the change.
   */
  setLastAccessTimestamp(newTimestamp: Date): void {
    if (this.lastAccess == null || newTimestamp.getTime() !== this.lastAccess.getTime()) {
      this.updateProperty("lastAccess", newTimestamp, "lastaccesschange")
    }
  }

  /**
   * Unset the last access timestamp property and dispatch an event
   * informing the change.
   */
  unsetLastAccessTimestamp(): void {
    if (this.lastAccess != null) {
      this.updateProperty("lastAccess", null, "lastaccesschange")
    }
  }

  /**
   * Update the status property based on the last access timestamp.
   */
  updateStatusFromLastAccess(): void {
    if (this.lastAccess == null) {
      this.setStatus(null)
    } else if ((Date.now() - this.lastAccess.getTime()) <= RECENT_CHECKIN_THRESHOLD) {
      this.setStatus("online")
    } else {
      this.setStatus("offline")
    }
  }
}


export class UserCollection extends events.PausableEventTarget {
  protected data: User[] = []

  constructor() {
    super()
  }

  /**
   * Add an item to the collection and dispatch an event about it.
   */
  addUser(user: User): void {
    this.data.push(user)
    this.dispatchEvent(new events.SimpleEvent("useradd", {detail: user}))
  }

  /**
   * Remove an item from the collection, dispatching an event on both the
   * collection and the item itself.
   */
  removeUser(user: User): boolean {
    const idx = this.data.indexOf(user)
    if (idx > -1) {
      delete this.data[idx]
      this.dispatchEvent(new events.SimpleEvent("userdel", {detail: user}))
      user.dispatchEvent(new events.SimpleEvent("unperson"))
      return true
    }
    return false
  }

  /**
   * Return the items in the collection that match the given predicate.
   * Defaults to returning all items.
   */
  select(predicate: (user: User) => boolean = () => true): User[] {
    return this.data.filter(predicate)
  }
}
