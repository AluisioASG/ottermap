module.exports = (grunt) ->
  'main':
    options:
      mainConfigFile: 'build/js/main.js'
      baseUrl: 'build/js'
      name: 'main'
      out: 'dist/js/main.js'
      optimize: 'uglify2'
      # Use almond instead of require.js
      almond: true
      replaceRequireScript: [
        files: <[dist/index.html]>
        module: 'main'
        modulePath: 'js/main'
      ]
      # Insert the database backend modules even if not directly
      # requested.
      include:~ -> grunt.config.get 'db-config.options.backends'
