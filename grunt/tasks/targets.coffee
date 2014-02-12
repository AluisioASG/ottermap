module.exports = (grunt) ->
  'use strict'

  grunt.registerTask 'dev', "Build all the files required for active development.", [
    'copy'
    'dbapi-root:dev'
    'wrap'
    'lsc'
    'stylus'
    'concat'
    'svgmin'
  ]
  grunt.registerTask 'dist', "Build the files to be deployed.", [
    'cssmin'
    'requirejs'
    'uglify'
    'embed'
    'fix-embed-css'
  ]

  grunt.registerTask 'release', "Release the build to GitHub Pages.", [
    'dev'
    'dbapi-root:release'
    'dist'
    'clean:dist'
    'publish'
  ]

  grunt.registerTask 'default', [
    'dev'
    'dist'
  ]
  grunt.registerTask 'rebuild', [
    'clean'
    'default'
    'clean:build'
  ]
