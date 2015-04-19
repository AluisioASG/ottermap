require! {
  'then-fs': fs
  'promise': Promise
  'svgo': SVGO

  './util/file-transforms': FileTransforms
}


# Remove an artificial directory prerequisite inserted by
# our `jake.createTask` extension.
realPrereqs = (actionThis) ->
  isDirectory = (path) ->
    fs.existsSync path and fs.statSync path .isDirectory!
  let @ = actionThis.prereqs
    switch
    | @length is 0     => []
    | isDirectory @[0] => @[1 to]
    | otherwise        => this

# Make file transforms easily expressible in the API object.
transformAction = (transform) -> ->
  input = realPrereqs this .[0]
  FileTransforms.transform input, @name, transform
reduceAction = (reduce) -> ->
  input = realPrereqs this
  FileTransforms.reduce input, @name, reduce

# We don't have to instantiate this every time we need it.
svgOptimizer = new SVGO do
  plugins:
    {removeTitle: true}
    {removeXMLProcInst: false}


module.exports =
  # Transform a file by applying a function to its contents.
  transform: transformAction

  # Merge many files into one by applying a function to their contents.
  reduce: reduceAction

  # Copy a file.
  copy: transformAction (-> it)

  # Join files' contents like they were an array, using the given
  # string as separator.
  concat: (sep) -> reduceAction (.join sep)

  # Minify a SVG file using SVGO.
  optimizeSvg: transformAction (buffer) ->
    resolve, reject <-! new Promise _
    svgOptimizer.optimize "#{buffer}" (result) ->
      # Why not a Node.js-style callback like everyone else?
      | result.error => reject that
      | otherwise    => resolve result.data
