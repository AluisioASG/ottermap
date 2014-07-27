path = require 'path'

module.exports = (grunt) ->
  'use strict'

  # git [cwd] args callback
  git = (argv...) ->
    callback = argv.pop()
    args = argv.pop()
    cwd = argv.pop()

    grunt.util.spawn
      cmd: (grunt.config.get 'git.path') ? 'git'
      args: args
      opts:
        cwd: cwd
    , callback


  grunt.registerMultiTask 'buildid', 'Write the current project version.', ->
    done = @async()
    {src, dest} = @files[0]
    src = path.resolve src[0]

    git src, ['describe', '--long', '--tags'], (error, result) ->
      version = unless error?
        result.stdout.trim()
          .replace(/-([0-9]+)-g([0-9a-f]+)$/, '+$1')
          .replace(/\+0$/, '')
      else
        grunt.log.error error
        grunt.log.error "Failed to retrieve revision from Git; falling back to package.json."
        package_json = JSON.parse grunt.file.read path.join src, 'package.json'
        "#{package_json.version}+unknown"

      grunt.file.write dest, version
      grunt.log.ok "File \"#{dest}\" created."
      done()


  grunt.registerTask 'publish', 'Send the current release to GitHub Pages.', ->
    done = @async()
    git ['config', '--get-regexp', '^user\\.'], (error, result) ->
      if error?
        done error
        return

      gitconfig = {}
      result.trim().split('\n').forEach (entry) ->
        [key, val...] = entry.split ' '
        gitconfig[key] = val.join(' ').trim()
      grunt.config 'gh-pages.options.user.name', gitconfig['user.name']
      grunt.config 'gh-pages.options.user.email', gitconfig['user.email']

      grunt.task.run 'gh-pages'
      done()
