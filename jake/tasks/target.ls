require! {
  fs
  server: 'connect'
  serverStatic: 'serve-static'
  Artifacts: '../artifacts'
  Tasks: '../util/tasks'
  ServerConfig: '../../build-config'.server
}


task 'target' (target) ->
  fail "No target specified" if not target?
  tasks = Tasks.resolve ...Artifacts[target] 
  Tasks.promiseSequence tasks .then -> target

task 'watch' <[target]> !->
  # `fs.watch` seems to sometimes emit double notifications for the
  # same event; guard against it by waiting before acting on it.
  # Based on code from `src/js/ui.ls`.
  const WATCH_CALLBACK_WAIT_INTERVAL = 15ms
  watchFile = (file, callback) !->
    var timer
    <-! fs.watch file
    clearTimeout timer
    timer := setTimeout callback, WATCH_CALLBACK_WAIT_INTERVAL, ...&

  target = jake.Task['target'].value
  targetTasks = Artifacts[target]

  jake.logger.log "Watching sources of target '#{target}' for changes…"
  # Walk over the reverse dependency map for the target.
  dependentsMap = Tasks.mapDependents targetTasks
  for let dependency, dependents of dependentsMap
    # Whenever the dependency changes, run its dependent tasks,
    # logging its success or failure.
    <-! watchFile dependency
    Tasks.promiseSequence dependents
    .done !->
      jake.logger.log "#{dependency} → #{dependents.map (.name) .join ', '}"
    , (err) !->
      jake.logger.error "Couldn't process #{dependency}: #{err}"

task 'serve' <[target]> !->
  target = jake.Task['target'].value
  rootDirs = switch target
    | \dev     => <[build src dist]>
    | \release => <[dist]>

  server!
    for dir in rootDirs
      ..use serverStatic dir, etag: false
    ..listen ServerConfig.port, ServerConfig.host
  jake.logger.log "
    Serving #{target} files at #{ServerConfig.host ? '*'}:#{ServerConfig.port}
  "
