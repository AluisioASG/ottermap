module.exports =
  options:
    backends: <[data/dbapi]>
    dest: 'build/js/data/config.js'
  'development':
    urls:
      'dbapi': 'http://localhost:8000'
  'production':
    urls:
      'dbapi': 'http://v3.db.aasg.name'
