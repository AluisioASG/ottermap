module.exports =
  'all.js':
    options:
      mainConfigFile: 'build/js/main.js'
      baseUrl: 'build/js'
      name: 'main'
      out: 'build/js/all.js'
      optimize: 'none'
      # Use almond instead of require.js
      almond: true
      replaceRequireScript: [
        files: ['dist/index.html']
        module: 'main'
        modulePath: 'js/main'
      ]
