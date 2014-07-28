module.exports = (grunt) ->
  'use strict'

  grunt.registerTask 'buildleaflet', "Run Leaflet's build system.", ->
    jake = require '../../vendor/leaflet/node_modules/jake'
    oldcwd = process.cwd()
    process.chdir 'vendor/leaflet'
    jake.run 'build[mvs1ju5]'
    process.chdir oldcwd
  grunt.registerTask 'builddeps', "Run the dependencies' build systems.", [
    'buildleaflet'
  ]
