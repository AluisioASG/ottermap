module.exports = (grunt) ->
  'use strict'

  grunt.registerTask 'develop', "Build the project and run a test server.", [
    'auto.prepare'
    'auto.build'
    'connect:development'
  ]
  grunt.registerTask 'release', "Build and optimize the project, then run a test server.", [
    'auto.prepare'
    'auto.build'
    'auto.optimize'
    'connect:production'
  ]

  grunt.registerTask 'deploy', "Build the deployment package.", [
    'clean'
    'auto.prepare'
    'auto.build'
    'db-config:production'
    'auto.optimize'
  ]
