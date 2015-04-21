require! {
  path

  'then-fs': fs
  'promise': Promise
  'gh-pages': ghpages

  '../util/git': git
}


# Write the release files to the `gh-pages` branch and push it.
task 'publish' <[target build/id]> ->
  # Make sure the publishing is only done after a release build.
  if jake.Task['target'].value isnt 'release'
    fail "Publishing after a non-release build"

  # Get the user's info from this repository.
  git ...<[config --get-regexp ^user\\.]>
  .then (output) ->
    gitconfig = {}
    for entry in output.trim!split '\n'
      [key, ...val] = entry.split ' '
      gitconfig[key] = val.join ' ' .trim!
    return do
      user:
        name: gitconfig['user.name']
        email: gitconfig['user.email']
  # Also get the package's version from build/id.
  .then (ghpOptions) ->
    fs.readFile 'build/id'
    .then (version) ->
      ghpOptions <<< message: "Update release to #{version}"
  .then (ghpOptions) ->
    ghpOptions <<<
      add: true
    (Promise.denodeify ghpages.publish) path.resolve('dist'), ghpOptions
