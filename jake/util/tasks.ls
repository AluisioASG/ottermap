require! Promise: promise


# Resolve the given task name into an actual `Task`, synthesizing it
# from rules when necessary.
exports.resolve = (name) ->
  | &length > 1     => [exports.resolve .. for &]
  | jake.Task[name] => that
  | otherwise       => jake.attemptRule name, jake.defaultNamespace, 1

# A reverse dependency mapper.
exports.mapDependents = (queue) ->
  queue = queue[to]
  revdeps = {}

  while (file = queue.shift!)
    task = exports.resolve file
    # Add a reverse dependency for the file on each prerequisite, and
    # add the latter themselves to the file queue.  Skip directories in
    # both cases.
    for prereq in task.prereqs ? []
      continue if jake.Task[prereq] instanceof jake.DirectoryTask
      (revdeps[prereq] ?= []).push task
      queue.push prereq

  return revdeps

# Run a task and return a promise for its completion.
exports.promiseTask = (task) ->
  resolve, reject <-! new Promise _
  # Resolve or reject the promise once it finishes.  There's no need
  # to remove the event listeners since the promise can't be changed.
  task.once \complete resolve
  task.once \error reject
  task.reenable true
  task.invoke!

# Run a number of tasks in sequence and return a promise for the
# sequence's completion.
exports.promiseSequence = (tasks) ->
  tasks.reduce (promise, task) ->
    promise.then -> exports.promiseTask task
  , Promise.resolve!
