require! {
  'then-fs': fs
  'promise': Promise
}


module.exports =
  # Copy the source file's contents to the destination, transforming
  # its contents in the process via the given function.
  transform: (src, dest, transform) ->
    fs.readFile src
    .then transform
    .then fs.writeFile dest, _

  # Merge the source files into the destination using the given
  # reducer function to combine them.
  reduce: (src, dest, reduce) ->
    Promise.all src.map (fs.readFile _)
    .then reduce
    .then fs.writeFile dest, _
