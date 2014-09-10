require! {
  stream
  LeafletBuild: '../../../vendor/leaflet/build/build'
  TaskActions: '../../actions'
}


# Replace `console.log` with a null function for the duration of the
# given function's execution.
silence = (fn) ->
  oldLogger = console.log
  console.log = ->
  ret = fn!
  console.log = oldLogger
  return ret


# Do Leaflet's build system's job.
const LEAFLET_BUILD_CONFIGURATION = 'mvs1ju5'
# Get the list of source files, but do so silently.
leafletSources = silence ->
  LeafletBuild.getFiles LEAFLET_BUILD_CONFIGURATION .map ('vendor/leaflet/' +)
file 'vendor/leaflet/dist/leaflet-src.js', leafletSources, async: true, !->
  oldwd = process.cwd!
  process.chdir 'vendor/leaflet'
  LeafletBuild.build !->
    process.chdir oldwd
    complete!
  , LEAFLET_BUILD_CONFIGURATION

# Whenever we look for Leaflet, we mean its plugins too.
file 'build/js/leaflet.js' <[
  vendor/leaflet/dist/leaflet-src.js
  vendor/leaflet-geosearch/src/js/l.control.geosearch.js
  vendor/leaflet-geosearch/src/js/l.geosearch.provider.openstreetmap.js
  vendor/leaflet-providers/leaflet-providers.js
  vendor/leaflet-markercluster/dist/leaflet.markercluster-src.js
  vendor/leaflet-search/dist/leaflet-search.src.js
]> TaskActions.concat ';'

# Firebase seems to use the Closure API to define namespaces.  I can't
# figure out even if it's safe to scope `Firebase` to the module.
file 'build/js/firebase.js' <[
  vendor/firebase/firebase.js
]> TaskActions.transform ->
  """
    define(function () {
      #{it}
      return Firebase;
    });
  """

# PicoModal looks for `window.define`, which the RequireJS optimizer
# doesn't recognize.
file 'build/js/picomodal.js' <[
  vendor/picomodal/src/picoModal.js
]> TaskActions.transform ->
  "#{it}".replace /window\.(define)/g '$1'

# CSSAnimEvent can be easily constrained to a local scope and then
# exported from there.
file 'build/js/cssanimevent.js' <[
  vendor/cssanimevent/cssanimevent.js
]> TaskActions.transform ->
  contents = "#{it}".replace /\bwin(?:dow)?\.(CSSAnimEvent)/g '$1'
  """
    define(function () {
      var CSSAnimEvent;
      #{contents}
      return CSSAnimEvent;
    });
  """

file 'build/js/almond.js' <[
  vendor/almond/almond.js
]> TaskActions.copy

file 'build/js/require.js' <[
  vendor/requirejs/require.js
]> TaskActions.copy

file 'build/js/text.js' <[
  vendor/requirejs-text/text.js
]> TaskActions.copy

file 'build/js/domReady.js' <[
  vendor/requirejs-domready/domReady.js
]> TaskActions.copy
