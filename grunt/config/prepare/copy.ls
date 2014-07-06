module.exports =
  'bootstrap.fonts':
    files: [
      expand: yes
      cwd: 'vendor/bootstrap/fonts'
      src: <[**]>
      dest: 'dist/fonts/'
    ]
  # Copy images from Leaflet and its plugins.
  'leaflet.img':
    files: [{
      expand: yes
      cwd: 'vendor/leaflet/dist/images'
      src: <[**]>
      dest: 'dist/img/'
    }, {
      expand: yes
      cwd: 'vendor/leaflet-search/images'
      src: <[loader.gif search-icon.png]>
      dest: 'dist/img/'
    }]
  # RequireJS and plugins
  'require.js':
    files:
      'build/js/require.js': 'vendor/requirejs/require.js'
      'build/js/text.js': 'vendor/requirejs-text/text.js'
      'build/js/domReady.js': 'vendor/requirejs-domready/domReady.js'
  # AMDify some of the dependencies
  'cssanimevent.js':
    options:
      process: -> """
        define(function () {
          var CSSAnimEvent;
          #{it.replace /win(?:dow)?\.CSSAnimEvent/g 'CSSAnimEvent'}
          return CSSAnimEvent;
        });
      """
    src: 'vendor/cssanimevent/cssanimevent.js'
    dest: 'build/js/cssanimevent.js'
  'firebase.js':
    options:
      process: -> """
        define(function () {
          #{it}
          return Firebase;
        });
      """
    src: 'vendor/firebase/firebase.js'
    dest: 'build/js/firebase.js'
  'picomodal.js':
    options:
      process: (.replace /window\.define/g 'define')
    files:
      'build/js/picomodal.js': 'vendor/picomodal/src/picoModal.js'
