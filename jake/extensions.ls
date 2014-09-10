require! path


# Patch `jake.createTask` to, when creating file tasks, insert
# a prerequisite on the file's parent directory, if it has one.
# A `directory` task is also created if necessary.
createTask = jake.createTask
jake.createTask = (type) ->
  task = createTask ...
  return task unless type is \file

  targetDirectory = path.dirname task.name
  if targetDirectory not in <[. ..]>
    directory targetDirectory
    task.[]prereqs.unshift targetDirectory

  return task

# Jake's `rule` seems to not accept promises like the other taskers do.
# Create an alternative which always receives a promise.
global.promised-rule = (...args) ->
  # Parse the parameters just like Jake would do.
  [dest, src, ...args] = args
  while (arg = args.shift!)
    switch typeof! arg
    | \Function => action  = arg
    | \Array    => prereqs = arg
    | otherwise => opts    = arg
  # Adjust the tasker's parameters.
  prereqs ?= []
  (opts ?= {}).async = true
  fn = !-> action.apply this .then complete, fail
  # Invoke the real tasker.
  rule dest, src, prereqs, opts, fn
