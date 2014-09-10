require! {
  CleanCSS: 'clean-css'
  RequireJS: 'requirejs'
  Promise: 'promise'
  Artifacts: '../artifacts'
  TaskActions: '../actions'
  FileTransforms: '../util/file-transforms'
  '../../build-config'.'db-config'
}


# Minify the chirpingmustard.com logo.
file 'dist/img/logo.svg' <[
  src/img/logo.svg
]> TaskActions.optimizeSvg

# Concatenate and minify all the stylesheets.
file 'dist/css/main.css' Artifacts.css, ->
  buffer <- FileTransforms.transform 'build/css/main.css', @name
  new CleanCSS do
    processImport: true
    relativeTo: 'build/css'
  .minify "#{buffer}"

# Concatenate and minify all AMD modules.
file 'dist/js/main.js' Artifacts.js, ->
  resolve, reject <~! new Promise _
  RequireJS.optimize do
    baseUrl: 'build/js'
    name: 'almond'
    include: <[main]> ++ db-config.backends
    out: @name
    optimize: 'uglify2'
    !-> resolve void
    !-> reject it

# Copy the versioned `index.html` from the build directory and
# update it to load the main script directly.
file 'dist/index.html' <[
  build/index.html
]> TaskActions.transform ->
  "#{it}".replace do
    '<script src="js/require.js" data-main="js/main"></script>'
    '<script src="js/main.js"></script>'
