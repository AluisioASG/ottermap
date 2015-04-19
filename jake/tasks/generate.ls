require! {
  path

  'then-fs': fs

  '../util/git': git
  '../../build-config': {'db-config': db-config}
}


# Get the application's version, either from Git or from package.json.
file 'build/id' ->
  git ...<[describe --long --tags]>
  .then (output) ->
    # v0.5.2-66-g0abcdef → v0.5.2+66
    output.trim!replace /-([0-9]+)-g([0-9a-f]+)$/ '+$1' .replace /\+0$/ ''
  , (error) ->
    jake.logger.error "Failed to retrieve revision from Git; falling back to package.json"
    version = require path.resolve('package.json') .version
    "v#{version}"
  .then fs.writeFile @name, _

# Write the database config module.
file 'build/js/data/config.js' ->
  # Serialize the database config as JSON…
  payload = JSON.stringify db-config, null, '\t'
    # …then revert computed values to JavaScript code.
    .replace /("javascript:.+"),?$/mg -> JSON.parse &1 .substr 11
  # Finally, export the object as an AMD module.
  fs.writeFile @name, "define(#{payload});"
