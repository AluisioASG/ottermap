path = require 'path'
require 'LiveScript'

module.exports = (grunt) ->
  # Initialize the config with the only thing we know.
  grunt.config.init
    pkg: grunt.file.readJSON 'package.json'

  # Load targets from a task config file and merge them into the Grunt
  # config.
  loadTaskConfig = (filename) ->
    # The key is the file's basename sans extension.
    task = path.basename filename, path.extname filename
    # The value can be either an object or a function returning one.
    targets = require filename
    if typeof targets is 'function'
      targets = targets(grunt)
    # Merge the loaded targets into the task config.
    for own target, config of targets
      grunt.config.set [task, target], config

  # Assume all files under `grunt/config` and `grunt/userconfig`
  # are config files.
  grunt.file.expand(
    {filter: 'isFile'},
    ['./grunt/config/**', './grunt/userconfig/**']
  ).forEach loadTaskConfig

  (require 'load-grunt-tasks')(grunt)
  grunt.loadTasks 'grunt/tasks'
