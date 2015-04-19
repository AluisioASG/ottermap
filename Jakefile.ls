# Our Jake tasks make use of some extensions, so load them now.
require './jake/extensions'

# Load all of our build tasks.
require './jake/tasks/prepare'
require './jake/tasks/generate'
require './jake/tasks/build'
require './jake/tasks/optimize'

# Create and import some build targets.  These are the ones you should
# be running from the command line.
require './jake/tasks/target'
require './jake/tasks/publish'
task 'clean' (...dirs) !-> dirs.forEach jake.rmRf
