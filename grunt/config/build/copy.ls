module.exports = (grunt) ->
  'build/index.html':
    options:
      process: ->
        version = grunt.file.read grunt.config.get 'buildid.ottermap.dest'
        it.replace '{{VERSION}}' version
    src: 'src/index.html'
    dest: 'build/index.html'
