module.exports = (grunt) ->
  'use strict'

  grunt.registerMultiTask 'dbapiroot', 'Write path to DBAPI root to an AMD module.', ->
    dest = @options().dest
    grunt.file.write dest, """
      define(function(){
        return '#{@data.url}';
      });
    """
    grunt.log.writeln "File \"#{dest}\" created."
    return
