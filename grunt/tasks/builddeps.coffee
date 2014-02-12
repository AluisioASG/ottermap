module.exports = (grunt) ->
  'use strict'

  grunt.registerTask 'buildleaflet', "Run Leaflet's build system.", ->
    grunt.util.spawn
      cmd: 'jake'
      args: ['build[mvs1ju5]']
      opts:
        cwd: 'vendor/leaflet'
        stdio: 'inherit'
    , @async()

  grunt.registerTask 'builddeps', "Run the dependencies' build systems.", [
    'buildleaflet'
  ]
