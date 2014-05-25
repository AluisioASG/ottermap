module.exports = (grunt) ->
  'use strict'

  grunt.registerMultiTask 'db-root', 'Write database URL to an AMD module.', ->
    dest = @options().dest
    url = @data.url
    expr = if /^javascript:/.test url
      url.substr 11
    else
      "'#{url}'"
    grunt.file.write dest, """
      define(function(){
        return #{expr};
      });
    """
    grunt.log.writeln "File \"#{dest}\" created."
    return
