require! {
  fs
  Artifacts: '../artifacts'
  Tasks: '../util/tasks'
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
