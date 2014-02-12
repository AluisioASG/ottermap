module.exports =
  'all.js':
    options:
      mainConfigFile: 'build/js/main.js'
      baseUrl: 'build/js'
      name: 'main'
      out: 'dist/js/main.js'
      optimize: 'uglify2'
      # Use almond instead of require.js
      almond: true
      replaceRequireScript: [
        files: ['dist/index.html']
        module: 'main'
        modulePath: 'js/main'
      ]
