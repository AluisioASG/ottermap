path = require 'path'
require 'LiveScript'

module.exports = (grunt) ->
  gruntConfig =
    pkg: grunt.file.readJSON 'package.json'

  grunt.file.expand(
    {filter: 'isFile'},
    ['./grunt/config/**', './grunt/userconfig/**']
  ).forEach (filename) ->
    key = path.basename filename, '.ls'
    gruntConfig[key] = require filename

  grunt.initConfig gruntConfig
  (require 'load-grunt-tasks')(grunt)
  grunt.loadTasks 'grunt/tasks'
