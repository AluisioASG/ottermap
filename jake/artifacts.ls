# The following build artifacts are created during the preparation,
# generation or build stages and are used as input by the tasks of
# the optimization stage.

# AMD modules used as input for the RequireJS optimizer.
exports.js = <[
  data.js
  data/config.js
  data/model.js
  data/dbapi.js
  data/firebase.js
  map.js
  map/user.js
  map/members.js
  map/layers.js
  map/markers.js
  map/marker.svg
  util/dom.js
  util/events.js
  util/queue.js
  util/dbapi.js
  forms.js
  messagebar.js
  ui.js
  focus.js
  main.js

  almond.js
  leaflet.js
  leaflet-providers.js
  firebase.js
  picomodal.js
  cssanimevent.js
  text.js
  domReady.js
]>.map ('build/js/' +)

# CSS stylesheets used as input for the Clean-css minifier.
exports.css = <[
  avatar-popup.css
  content.css
  top-level-layout.css
  main.css

  bootstrap-container.css
  leaflet-overrides.css
  picomodal-overrides.css

  leaflet.css
  bootstrap.css
]>.map ('build/css/' +)


# The following build artifacts are part of build targets.

# Third party dist files which we don't optimize and are therefore used
# in both development and deployment targets.
vendor_dist = <[
  fonts/glyphicons-halflings-regular.ttf
  fonts/glyphicons-halflings-regular.woff
  fonts/glyphicons-halflings-regular.woff2
  img/layers.png
  img/layers-2x.png
  img/marker-icon.png
  img/marker-icon-2x.png
  img/marker-shadow.png
  img/search-icon.png
]>.map ('dist/' +)

# Files which need to be available for live development.
exports.dev = vendor_dist ++ exports.js ++ exports.css ++ <[
  index.html
  js/require.js
]>.map ('build/' +)

# Files that comprise the deployment package and need to be built when
# creating it.
exports.release = vendor_dist ++ <[
  index.html
  js/main.js
  css/main.css
  img/logo.svg
]>.map ('dist/' +)
