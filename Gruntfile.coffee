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
        files: [
          expand: yes
          cwd: 'vendor/leaflet/dist/images'
          src: ['**']
          dest: 'dist/img/'
        ]
      'jquery.js':
        src: 'vendor/jquery/dist/jquery.js'
        dest: 'build/js/jquery.js'
      'require.js':
        files:
          'build/js/require.js': 'vendor/requirejs/require.js'
          'build/js/text.js': 'vendor/requirejs-text/text.js'
      'src':
        files: [
          expand: yes
          cwd: 'src'
          src: ['**', '!**/*.ls', '!**/*.styl', '!**/*.svg']
          dest: 'dist/'
        ]
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
          src: ['**/*.styl', '**/!_*.styl']
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
        ]
        dest: 'build/js/leaflet.js'
      'all.css':
        src: [
          'vendor/bootstrap/css/bootstrap.css'
          'vendor/bootstrap/css/bootstrap-theme.css'
          'vendor/leaflet/dist/leaflet.css'
          'vendor/leaflet-geosearch/src/css/l.geosearch.css'
          'vendor/leaflet-markercluster/dist/MarkerCluster.css'
          'vendor/leaflet-markercluster/dist/MarkerCluster.Default.css'
          'build/**/*.css'
          '!build/css/all.css'
        ]
        dest: 'build/css/all.css'
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
        dest: 'build/img/marker.svg'
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
      options:
        processImport: false
      'all.css':
        src: 'build/css/all.css'
        dest: 'dist/css/all.css'
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
    fixembedcss:
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
  grunt.loadNpmTasks 'grunt-gh-pages'
  grunt.loadNpmTasks 'grunt-lsc'
  grunt.loadNpmTasks 'grunt-requirejs'
  grunt.loadNpmTasks 'grunt-svgmin'


  grunt.registerMultiTask 'fixembedcss', 'Workaround for callumlocke/resource-embedder#15.', ->
    @files.forEach (files) ->
      src = files.src[0]
      dest = files.dest

      if not grunt.file.exists src
        grunt.log.error "Source file \"#{src}\" not found."
        return

      contents =
        (grunt.file.read src)
        .replace /fonts\\glyphicons/g, 'fonts/glyphicons'
      grunt.file.write dest, contents
      grunt.log.writeln "File \"#{dest}\" created."
      return
    return


  grunt.registerTask 'buildjquery', "Run jQuery's build system.", ->
    grunt.util.spawn
      grunt: true
      args: ['custom:' + [
        '-ajax/script'
        '-ajax/jsonp'
        '-deprecated'
        '-event/alias'
        '-offset'
        '-wrap'
        '-exports/global'
        ].join ','
      ]
      opts:
        cwd: 'vendor/jquery'
        stdio: 'inherit'
    , @async()

  grunt.registerTask 'buildleaflet', "Run Leaflet's build system.", ->
    grunt.util.spawn
      cmd: 'jake'
      args: ['build[mvs1ju5]']
      opts:
        cwd: 'vendor/leaflet'
        stdio: 'inherit'
    , @async()

  grunt.registerTask 'builddeps', "Run the dependencies' build systems.", [
    'buildjquery'
    'buildleaflet'
  ]


  grunt.renameTask 'gh-pages', 'ghupload'

  grunt.registerTask 'publish', "Send the current release to GitHub Pages.", ->
    git = require 'grunt-gh-pages/lib/git'
    done = @async()
    git(['config', '--get-regexp', '^user\\.']).progress (out) ->
      gitconfig = {}
      String(out).trim().split('\n').forEach (entry) ->
        [key, val...] = entry.split ' '
        gitconfig[key] = val.join(' ').trim()
      grunt.config 'ghupload.options.user.name', gitconfig['user.name']
      grunt.config 'ghupload.options.user.email', gitconfig['user.email']
      grunt.task.run 'ghupload'
      done()


  grunt.registerTask 'dev', "Build all the files required for active development.", [
    'copy'
    'lsc'
    'stylus'
    'concat'
    'svgmin'
  ]
  grunt.registerTask 'dist', "Build the files to be deployed.", [
    'cssmin'
    'requirejs'
    'uglify'
    'embed'
    'fixembedcss'
  ]

  grunt.registerTask 'release', "Release the build to GitHub Pages.", [
    'dev'
    'dist'
    'clean:dist'
    'publish'
  ]

  grunt.registerTask 'default', [
    'dev'
    'dist'
  ]
  grunt.registerTask 'rebuild', [
    'clean'
    'default'
    'clean:build'
  ]
