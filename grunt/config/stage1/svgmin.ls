module.exports =
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
