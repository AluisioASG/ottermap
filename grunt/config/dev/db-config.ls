module.exports =
  options:
    backends: <[data/dbapi data/firebase]>
    dest: 'build/js/data/config.js'
  'development':
    urls:
      'dbapi': 'http://localhost:8000'
      'firebase': 'https://qnpy0tzg.firebaseio-demo.com'
  'production':
    urls:
      'dbapi': 'http://v3.db.aasg.name'
      'firebase': 'https://qnpy0tzg.firebaseio-demo.com'
