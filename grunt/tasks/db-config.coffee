module.exports = (grunt) ->
  'use strict'

  grunt.registerMultiTask 'db-config', 'Write the database config to an AMD module.', ->
    {dest, backends} = @options()
    backends_str = JSON.stringify backends
    payload = """
      define({
        backends: #{backends_str},
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
    if @data.forceInclude
      payload.push "require(#{backends_str});"
    grunt.file.write dest, payload.join '\n'
    grunt.log.ok "File \"#{dest}\" created."
    return
