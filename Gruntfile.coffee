changeExt = (from, to) ->
  re = new RegExp "\\.#{from}$"
  (dest, src) ->
    dest + src.replace re, ".#{to}"

module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    # Base/lifecycle tasks
    clean:
      'build': ['build']
      'dist': ['dist/css', 'dist/js']
      'release': ['dist']
    ghupload:
      'dist':
        options:
          base: 'dist'
          message: 'Update release to v<%= pkg.version %>'
          add: true
        src: ['**']

    # Stage 1 tasks
    copy:
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
    dbapiroot:
      options:
        dest: 'build/js/dbapi-root.js'
      'dev':
          url: 'javascript:"http://" + window.location.hostname + ":63558"'
      'release':
          url: 'http://v3.db.aasg.name'
    wrap:
      'cssanimevent.js':
        options:
          wrapper: [
            'define(function () {\n'
            'return window.CSSAnimEvent;\n});'
          ]
        src: 'vendor/cssanimevent/cssanimevent.js'
        dest: 'build/js/cssanimevent.js'
    lsc:
      options:
        bare: true
      'src':
        files: [
          expand: yes
          cwd: 'src'
          src: ['**/*.ls']
          dest: 'build/'
          rename: changeExt 'ls', 'js'
        ]
    stylus:
      'src':
        files: [
          expand: yes
          cwd: 'src'
          src: ['**/*.styl', '!**/_*.styl']
          dest: 'build/'
          rename: changeExt 'styl', 'css'
        ]
    concat:
      'leaflet.js':
        options:
          separator: ';'
        src: [
          'vendor/leaflet/dist/leaflet-src.js'
          'vendor/leaflet-geosearch/src/js/l.control.geosearch.js'
          'vendor/leaflet-geosearch/src/js/l.geosearch.provider.openstreetmap.js'
          'vendor/leaflet-providers/leaflet-providers.js'
          'vendor/leaflet-markercluster/dist/leaflet.markercluster-src.js'
          'vendor/leaflet-search/dist/leaflet-search.src.js'
        ]
        dest: 'build/js/leaflet.js'
      'leaflet.css':
        src: [
          'vendor/leaflet/dist/leaflet.css'
          'vendor/leaflet-geosearch/src/css/l.geosearch.css'
          'vendor/leaflet-markercluster/dist/MarkerCluster.css'
          'vendor/leaflet-markercluster/dist/MarkerCluster.Default.css'
          'vendor/leaflet-search/dist/leaflet-search.src.css'
        ]
        dest: 'build/css/leaflet.css'
      'bootstrap.css':
        src: [
          'vendor/bootstrap/css/bootstrap.css'
          'vendor/bootstrap/css/bootstrap-theme.css'
        ]
        dest: 'build/css/bootstrap.css'
    svgmin:
      options:
        plugins: [
          {removeTitle: true}
          {removeViewBox: false}
          {removeXMLProcInst: false}
        ]
      'glyphicons.font':
        src: 'vendor/bootstrap/fonts/glyphicons-halflings-regular.svg'
        dest: 'dist/fonts/glyphicons-halflings-regular.svg'
      'marker':
        src: 'src/img/marker.svg'
        dest: 'build/js/map/marker.svg'
      'src':
        files: [
          expand: yes
          cwd: 'src'
          src: ['**/*.svg', '!img/marker.svg']
          dest: 'dist/'
        ]

    # Stage 2 tasks
    requirejs:
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

    # Stage 3 (dist) tasks
    cssmin:
      'all.css':
        src: 'build/css/main.css'
        dest: 'dist/css/main.css'
    uglify:
      options:
        compress: true
      'all.js':
        src: 'build/js/all.js'
        dest: 'dist/js/main.js'
    embed:
      options:
        threshold: '1024 KB'
      'index.html':
        src: 'dist/index.html'
        dest: 'dist/index.html'
    fixcsspaths:
      'index.html':
        src: 'dist/index.html'
        dest: 'dist/index.html'


  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-embed'
  grunt.loadNpmTasks 'grunt-wrap'
  grunt.loadNpmTasks 'grunt-gh-pages'
  grunt.loadNpmTasks 'grunt-lsc'
  grunt.loadNpmTasks 'grunt-requirejs'
  grunt.loadNpmTasks 'grunt-svgmin'
  grunt.loadTasks 'grunt-tasks'

  grunt.renameTask 'gh-pages', 'ghupload'
