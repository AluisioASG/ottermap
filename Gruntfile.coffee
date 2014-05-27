path = require 'path'
require 'LiveScript'

module.exports = (grunt) ->
  # Initialize the config with the only thing we know.
  grunt.config.init
    pkg: grunt.file.readJSON 'package.json'

  # Assume all files under `grunt/config` and `grunt/userconfig`
  # are config files.
  grunt.file.expand(
    {filter: 'isFile'},
    ['./grunt/config/**', './grunt/userconfig/**']
  ).forEach (filename) ->
    # The key is the file's basename sans extension.
    key = path.basename filename, path.extname filename
    # The value can be either an object or a function returning one.
    value = require filename
    if typeof value is 'function'
      value = value(grunt)
    grunt.config.set key, value

  (require 'load-grunt-tasks')(grunt)
  grunt.loadTasks 'grunt/tasks'
