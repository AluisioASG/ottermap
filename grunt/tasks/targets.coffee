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
    'embed'
    'fix-embed-css'
  ]

  grunt.registerTask 'deploy', "Build the deployment package.", [
    'clean'
    'dev'
    'db-config:production'
    'release'
    'clean:deploy'
  ]

  grunt.registerTask 'default', [
    'dev'
    'release'
  ]
