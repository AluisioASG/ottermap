module.exports = (grunt) ->
  'js/marker.svg':
    src: 'src/img/marker.svg'
    dest: 'build/js/map/marker.svg'
  'dist/index.html':
    options:
      process: ->
        version = grunt.file.read grunt.config.get 'buildid.ottermap.dest'
        it.replace '{{VERSION}}' version
    src: 'src/index.html'
    dest: 'dist/index.html'
