module.exports =
  options:
    dest: 'build/js/dbapi-root.js'
  'dev':
    url: 'javascript:"http://" + window.location.hostname + ":63558"'
  'release':
    url: 'http://v3.db.aasg.name'
