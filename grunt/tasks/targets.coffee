module.exports = (grunt) ->
  'use strict'

  grunt.registerTask 'dev', "Build the project in development mode.", [
    'copy'
    'db-config:development'
    'wrap'
    'lsc'
    'stylus'
    'concat'
    'svgmin'
  ]
  grunt.registerTask 'release', "Optimize the project build for release.", [
    'cssmin'
    'requirejs'
  ]

  grunt.registerTask 'deploy', "Build the deployment package.", [
    'clean'
    'dev'
    'db-config:production'
    'release'
  ]

  grunt.registerTask 'default', [
    'dev'
    'release'
  ]
