module.exports =
  options:
    dest:
      'dbapi'    : 'build/js/dbapi-root.js'
  'development':
    urls:
      'dbapi'    : 'http://localhost:8000'
  'production':
    urls:
      'dbapi'    : 'http://v3.db.aasg.name'
