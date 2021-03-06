import OfflineRuntime = require("offline-plugin/runtime")
OfflineRuntime.install()

import "./ui"
import "./forms"
import "./map"
import "./map/layers"
import "./map/members"
import "./map/user"
import "./focus"

import * as data from "./data"
import backend from "./data/backend"
data.setBackend(backend)
data.fetchUsers()
