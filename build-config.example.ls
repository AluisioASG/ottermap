module.exports =
  'git-path': 'git'
  'db-config':
    backends: <[data/firebase data/dbapi]>
    urls:
      'firebase': do ->
        random = Math.floor (Math.random! * 0xffffffff) .toString 32
        "https://#{random}.firebaseio-demo.com"
      'dbapi': switch process.env['NODE_ENV']
        | \production => 'http://dbapi.mydomain.invalid'
        | otherwise   => 'http://localhost:8000'
