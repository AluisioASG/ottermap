module.exports =
  'src':
    files: [
      expand: yes
      cwd: 'src'
      src: <[**/*.svg !img/marker.svg]>
      dest: 'dist/'
    ]
