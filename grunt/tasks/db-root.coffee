module.exports = (grunt) ->
  'use strict'

  grunt.registerMultiTask 'db-root', 'Write database URL to an AMD module.', ->
    undestinedTypes = []
    for own type, url of @data.urls
      dest = @options().dest[type]
      if not dest?
        undestinedTypes.push type
        continue

      expr = if /^javascript:/.test url
        url.substr 11
      else
        "'#{url}'"
      grunt.file.write dest, """
        define(function(){
          return #{expr};
        });
      """
      grunt.log.ok "File \"#{dest}\" created."

    if undestinedTypes.length isnt 0
      grunt.warn "No destination file set for type #{type}."
    return
