module.exports =
  'src':
    files: [
      expand: yes
      cwd: 'src'
      src: <[**/*.styl !**/_*.styl]>
      dest: 'build/'
      rename: (dest, src) -> dest + src.replace /\.styl$/ '.css'
    ]
