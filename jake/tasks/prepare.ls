require! {
  fs
  path
}


# This stage is named…
stage = path.basename module.filename, path.extname(module.filename)

# …and is actually made up of file in a subdirectory…
stagedir = path.resolve __dirname, stage

# …so load 'em all!
for file in fs.readdirSync stagedir
  require path.join(stagedir, file)
