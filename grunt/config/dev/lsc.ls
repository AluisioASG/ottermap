module.exports =
  options:
    bare: true
  'src':
    files: [
      expand: yes
      cwd: 'src'
      src: ['**/*.ls']
      dest: 'build/'
      rename: (dest, src) -> dest + src.replace /\.ls$/ '.js'
    ]
