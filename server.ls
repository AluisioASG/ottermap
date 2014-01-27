# Paths
# =====

require! path

const SRC_DIR  = path.join __dirname, 'src'
const BLD_DIR  = path.join __dirname, 'build'
const DIST_DIR = path.join __dirname, 'dist'


# Development server setup
# ------------------------

getDevelopmentServer = ->
  require! connect
  require! compiler: 'connect-compiler'

  connect!
  .use connect.logger \dev
  .use compiler do
    log_level: \INFO
    enabled: <[livescript]>
    src: SRC_DIR
    dest: BLD_DIR
    options:
      livescript:
        bare: false
  .use connect.static BLD_DIR
  .use connect.static SRC_DIR
  .use connect.static DIST_DIR

# Production server setup
# -----------------------

getProductionServer = ->
  require! buffet
  require! connect

  connect.logger.token \isodate -> (new Date).toISOString!

  connect!
  .use connect.logger ':isodate :status :method :url [:response-time ms]'
  .use connect.compress!
  .use buffet DIST_DIR


# By-environment server selection
# ===============================

require! cfg: './config'

server = switch cfg.ENVIRONMENT
  | \production  => getProductionServer!
  | \development => getDevelopmentServer!

console.info "
  Starting server on 
  #{cfg.SERVER_ADDRESS}:#{cfg.SERVER_PORT} 
  in #{cfg.ENVIRONMENT} mode
"
server.listen cfg.SERVER_PORT, cfg.SERVER_ADDRESS
