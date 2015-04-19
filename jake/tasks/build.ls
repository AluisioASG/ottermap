require! {
  path

  LiveScript
  'stylus': Stylus
  'promise': Promise

  '../artifacts': Artifacts
  '../actions': TaskActions
  '../util/file-transforms': FileTransforms
}


# Replace the version number placeholder in the about modal.
file 'build/index.html' <[
  src/index.html
  build/id
]> TaskActions.reduce ([html, buildId]) ->
  "#{html}".replace '{{VERSION}}' "#{buildId}"

# Copy the marker SVG file to the AMD module tree.
file 'build/js/map/marker.svg' <[
  src/img/marker.svg
]> TaskActions.optimizeSvg


# Get the name of the source file for a given transpiled
# destination file.
getSourceFilename = (srcExt, dstExt) ->
  dstExtRegexp = new RegExp "#{dstExt.replace /\./g '\\.'}$"
  (.replace /^build/ 'src' .replace dstExtRegexp, srcExt)

# Compile LiveScript files into JavaScript.
promised-rule /^build\/js\/.+\.js$/ (getSourceFilename \ls \js), ->
  buffer <~ FileTransforms.transform @source, @name
  LiveScript.compile "#{buffer}" bare: true filename: @source

# Compile Stylus stylesheets into plain CSS.
promised-rule /^build\/css\/.+\.css$/ (getSourceFilename \styl \css), ->
  buffer <~ FileTransforms.transform @source, @name
  (Promise.denodeify Stylus.render) "#{buffer}" filename: @source
