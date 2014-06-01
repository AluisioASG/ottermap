module.exports = (grunt) ->
  'use strict'

  grunt.registerTask 'publish', 'Send the current release to GitHub Pages.', ->
    git = require 'grunt-gh-pages/lib/git'
    done = @async()
    git(['config', '--get-regexp', '^user\\.']).progress (out) ->
      gitconfig = {}
      String(out).trim().split('\n').forEach (entry) ->
        [key, val...] = entry.split ' '
        gitconfig[key] = val.join(' ').trim()
      grunt.config 'gh-pages.options.user.name', gitconfig['user.name']
      grunt.config 'gh-pages.options.user.email', gitconfig['user.email']
      grunt.task.run 'gh-pages'
      done()
