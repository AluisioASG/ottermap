export default {
  urls: {
    get dbapi(): string {
      throw new Error("Unsupported data backend 'dbapi'")
    },
    firebase: "https://ottermap-db.firebaseio.com",
    pouchdb: "http://localhost:5984/ottermap",
  },
}
