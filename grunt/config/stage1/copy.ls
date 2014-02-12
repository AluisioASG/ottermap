module.exports =
  'bootstrap.fonts':
    files: [
      expand: yes
      cwd: 'vendor/bootstrap/fonts'
      src: ['**']
      dest: 'dist/fonts/'
    ]
  'leaflet.img':
    files: [{
      expand: yes
      cwd: 'vendor/leaflet/dist/images'
      src: ['**']
      dest: 'dist/img/'
    }, {
      expand: yes
      cwd: 'vendor/leaflet-search/images'
      src: ['loader.gif', 'search-icon.png']
      dest: 'dist/img/'
    }]
  'require.js':
    files:
      'build/js/require.js': 'vendor/requirejs/require.js'
      'build/js/text.js': 'vendor/requirejs-text/text.js'
      'build/js/domReady.js': 'vendor/requirejs-domready/domReady.js'
  'src':
    files: [
      expand: yes
      cwd: 'src'
      src: ['**', '!**/*.ls', '!**/*.styl', '!**/*.svg']
      dest: 'dist/'
    ]
