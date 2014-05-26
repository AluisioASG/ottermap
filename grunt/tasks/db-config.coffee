module.exports = (grunt) ->
  'use strict'

  grunt.registerMultiTask 'db-config', 'Write the database config to an AMD module.', ->
    {dest, backends} = @options()
    payload = """
      define({
        backends: #{JSON.stringify backends},
        urls: {
    """.split '\n'
    for own name, url of @data.urls
      expr = if /^javascript:/.test url
        url.substr 11
      else
        JSON.stringify url
      payload.push "    #{JSON.stringify name}: #{expr},"
    Array::push.apply payload, """
        }
      });
    """.split '\n'
    grunt.file.write dest, payload.join '\n'
    grunt.log.ok "File \"#{dest}\" created."
    return
