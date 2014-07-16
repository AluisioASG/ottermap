require! compiler: 'connect-compiler'

module.exports =
  'development':
    options:
      base: <[build src dist]>
      keepalive: true
      middleware: (connect, options, middlewares) ->
        middlewares.unshift do
          connect.logger \dev
          compiler do
            log_level: \INFO
            enabled: <[livescript stylus]>
            src: 'src'
            dest: 'build'
        return middlewares
  'production':
    options:
      base: <[dist]>
      keepalive: true
      middleware: (connect, options, middlewares) ->
        connect.logger.token \isodate -> (new Date).toISOString!
        middlewares.unshift do
          connect.logger ':isodate :status :method :url [:response-time ms]'
          connect.compress!
        return middlewares
