module.exports = (grunt) ->
  'use strict'

  grunt.registerTask 'buildjquery', "Run jQuery's build system.", ->
    grunt.util.spawn
      grunt: true
      args: ['custom:' + [
        '-ajax/jsonp'
        '-ajax/script'
        '-core/ready'
        '-deprecated'
        '-event/alias'
        '-exports/global'
        '-offset'
        '-sizzle'
        '-wrap'
        ].join ','
      ]
      opts:
        cwd: 'vendor/jquery'
        stdio: 'inherit'
    , @async()

  grunt.registerTask 'buildleaflet', "Run Leaflet's build system.", ->
    grunt.util.spawn
      cmd: 'jake'
      args: ['build[mvs1ju5]']
      opts:
        cwd: 'vendor/leaflet'
        stdio: 'inherit'
    , @async()

  grunt.registerTask 'builddeps', "Run the dependencies' build systems.", [
    'buildjquery'
    'buildleaflet'
  ]
