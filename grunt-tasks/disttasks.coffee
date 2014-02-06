module.exports = (grunt) ->
  'use strict'

  grunt.registerMultiTask 'fixcsspaths', '.', ->
    @files.forEach (files) ->
      src = files.src[0]
      dest = files.dest

      if not grunt.file.exists src
        grunt.log.error "Source file \"#{src}\" not found."
        return

      contents =
        (grunt.file.read src)
        .replace(/\.\.\/\b/g, '')
        # Work around callumlocke/resource-embedder#15
        .replace(/fonts\\glyphicons/g, 'fonts/glyphicons')
      grunt.file.write dest, contents
      grunt.log.writeln "File \"#{dest}\" created."
      return
    return

  grunt.registerTask 'publish', "Send the current release to GitHub Pages.", ->
    git = require 'grunt-gh-pages/lib/git'
    done = @async()
    git(['config', '--get-regexp', '^user\\.']).progress (out) ->
      gitconfig = {}
      String(out).trim().split('\n').forEach (entry) ->
        [key, val...] = entry.split ' '
        gitconfig[key] = val.join(' ').trim()
      grunt.config 'ghupload.options.user.name', gitconfig['user.name']
      grunt.config 'ghupload.options.user.email', gitconfig['user.email']
      grunt.task.run 'ghupload'
      done()
